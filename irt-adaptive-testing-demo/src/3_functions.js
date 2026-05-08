const getItem = async (i) => {
  const response = await fetch('2_itemBank.json?v=' + Date.now());
  const data = await response.json();
  return data[i];
}

const goBack = async () => {
  if (exam.history.length === 0) return;

  const prev = exam.history.pop(); // 戻る
  exam.n = prev.n;
  exam.theta = prev.theta;
  exam.x = prev.x;
  exam.bank = prev.bank;
  exam.ans = prev.ans;
  exam.time = prev.time;
  //startTime = prev.startTime;
  confidence.splice(0, confidence.length, ...prev.confidence);

  const item = await getItem(exam.n);

  if (item && item.type === "confidence") {
    startSurvey(item);
  } else {
    createExam(item);
  }
}


// getItem(0).then(item => console.log(item));

const exam = {};
//edit2-2
const confidence = [];

const startTesting = async () => {
  exam.n = 0;//解答数
  exam.x = [];//正誤
  exam.theta = 0;//能力値
  exam.time = [];
  exam.bank = [];//項目履歴
  //edit2-1
  exam.ans = [];
  startTime = Date.now();
  exam.history = [];
  createExam(await getItem(0));
  //edit3-3
}

document.getElementById('back-btn').onclick = goBack;
document.getElementById('exam-box').onsubmit = (e) => {
  e.preventDefault();
  continueTesting();
}

const continueTesting = async () => {
  let item = await getItem(exam.n);
  if (item.type !== 'confidence') {
    //get back up
    exam.history.push({
      n: exam.n,
      theta: exam.theta,
      x: [...exam.x],
      bank: [...exam.bank],
      ans: [...exam.ans],
      time: [...exam.time],
      confidence: [...confidence],
      startTime
    });
  }


  const choice = parseInt(document.getElementById('exam-box').choices.value);

  item = await getItem(exam.n);

  // タイム
  if (item.type !== 'confidence') {
    exam.time.push((Date.now() - startTime));
    startTime = Date.now();
    console.log(exam.time);



    if (choice == 4) {
      //未解答の場合
      exam.x.push(-1);
      exam.ans.push("未回答");
      exam.n++;
    } else {
      //有効回答
      exam.x.push(choice == item.correct ? 1 : 0);
      exam.ans.push(item.choices[choice]);
      exam.bank.push(item);
      exam.n++;
      exam.theta = estimation(exam.x.filter(v => v >= 0), exam.bank, -3, 3, 0.1);//未回答を飛び
    }
    console.log(exam.x);
    console.log(exam.ans);
    console.log(exam.theta);
    //exam.n++;
    //exam.theta = exam.x.reduce((a, b) => a + b) / exam.n;
  }
  else {
    confidence.push(item.choices[choice]);
    exam.n++;
  }

  item = await getItem(exam.n);

  if (item && item.type !== 'confidence') {
    createExam(item);
  }
  else if (item && item.type === 'confidence') {
    startSurvey(item);
  }
  else {
    finishTesting();
  }
}


const startSurvey = async (item) => {
  // //edit2-2
  const questionArea = document.getElementById('question-area');
  questionArea.innerHTML = "<h3>自信度アンケート<br>" + item.question + "</h3>";

  if (item.type === "confidence") {
    const choices = item.choices;
    const choiceArea = document.getElementById('choice-area');
    //同様に追加
    choiceArea.classList.add("m-3");

    choiceArea.innerHTML = '';
    choices.forEach((eachChoice, index) => {
      const input = document.createElement('input');
      input.id = 'choice' + index;
      input.type = 'radio';
      input.name = 'choices';
      input.value = index;
      input.style.cursor = 'pointer';
      input.classList.add("form-check-input");
      input.required = true;


      const label = document.createElement('label');
      label.setAttribute('for', 'choice' + index);
      label.innerHTML = eachChoice;
      label.style.cursor = 'pointer';
      label.classList.add("form-check-label");

      const div = document.createElement('div');
      div.appendChild(input);
      div.appendChild(label);
      div.classList.add("form-check");
      choiceArea.appendChild(div);
    });
  }
}


const finishTesting = async () => {
  const answered = exam.x.filter(v => v >= 0);
  const correctCount = answered.filter(v => v === 1).length;
  const wrongCount = answered.filter(v => v === 0).length;
  const unansweredCount = exam.x.filter(v => v === -1).length;


  const correctRate = (answered.length > 0) ? (correctCount / answered.length) : 0;
  const errorRate = (answered.length > 0) ? (wrongCount / answered.length) : 0;//回答した項目だけ

  let result = `
  <div class="card m-4 p-4 shadow-sm">
    <h2 class="card-title text-center">試験終了</h2>
    <div class="card-body">
      <p class="fs-5">あなたの能力値は${exam.theta.toFixed(3)} です。</p>
      <p class="fs-5">${answered.length}問中で<br>あなたの正答率: ${correctRate.toFixed(3)}</p>
      <p class="fs-5">あなたの誤謬率:${errorRate.toFixed(3)} </p>
      <p class="fs-5">あなたが未回答の問題数: ${unansweredCount}</p>
      <p class="fs-5">あなたの自信度は 「${confidence.join('、')}」</p>
    </div>
  </div>
`;


  document.getElementById('exam-box').innerHTML = result;

  const table = document.createElement("table");
  table.className = "mx-auto";
  const tr = table.createTHead().insertRow();
  const headers = ["問", "あなたの解答", "正誤", "回答時間"];
  headers.forEach(header => {
    const th = document.createElement("th");
    th.textContent = header;
    tr.appendChild(th);
  });


  for (let i = 0; i < exam.x.length; i++) {
    const row = table.insertRow();
    let ansResult;
    if (exam.x[i] === 1) {
      ansResult = "○";
    } else if (exam.x[i] === 0) {
      ansResult = "×";
    } else {
      ansResult = "—";
    }
    //edit2-1

    const ansText = exam.ans[i];
    const ansTime = (exam.time[i] / 1000).toFixed(1) + "s";
    const columns = [i + 1, ansText, ansResult, ansTime];
    columns.forEach(column => {
      const td = document.createElement('td');
      td.textContent = column;
      row.appendChild(td);
    });

    //edit2-1
    row.classList.add(exam.x[i] == 1 ? "correct" : "wrong");

  }

  document.getElementById("exam-box").appendChild(table);
}


const createExam = (item) => {
  const questionArea = document.getElementById('question-area');
  //問題追加
  questionArea.innerHTML = "<h3>第" + (exam.n + 1) + "問<br>" + item.question + "</h3>";

  const choices = item.choices;
  const choiceArea = document.getElementById('choice-area');
  choiceArea.classList.add("m-3");
  choiceArea.innerHTML = '';
  choices.forEach((eachChoice, index) => {

    const input = document.createElement('input');
    input.id = 'choice' + index;
    input.type = 'radio';
    input.name = 'choices';
    input.value = index;
    input.style.cursor = 'pointer';
    input.classList.add("form-check-input");
    input.required = true;

    const label = document.createElement('label');
    label.setAttribute('for', 'choice' + index);
    label.innerHTML = eachChoice;
    label.style.cursor = 'pointer';
    label.classList.add("form-check-label");


    const div = document.createElement('div');
    div.appendChild(input);
    div.appendChild(label);
    div.classList.add("form-check");
    choiceArea.appendChild(div);
  });
}




startTesting();