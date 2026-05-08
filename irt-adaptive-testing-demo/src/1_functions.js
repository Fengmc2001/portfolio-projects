//const result = document.getElementById("result");

const practice0 = () => {
  const min = -3;
  const max = 3;
  const step = 1;
  for (let theta = min; theta <= max; theta += step) {
    result.innerHTML += theta + ',';
  }
}
// practice0();

const norm = (theta) => {
  return Math.exp(-theta * theta / 2) / Math.sqrt(2 * Math.PI);
}

const normDist = (min, max, step) => {
  const dist = [];
  for (let theta = min; theta <= max; theta += step)
    dist.push(norm(theta) * step);
  return dist;
}

const practice1 = () => {
  const min = -3;
  const max = 3;
  const step = 1;
  const valueDist = normDist(min, max, step);
  for (let i = 0; i < valueDist.length; i++) {
    result.innerHTML += valueDist[i].toFixed(3) + '<br>';
  }
}
// practice1();

//ある能力値の下で正答率
const correctProbability = (theta, a, b) => {
  return 1 / (1 + Math.exp(-1.7 * a * (theta - b)));
}

//正答また誤答確率 x=1正答
const responseProbability = (x, theta, a, b) => {
  const p = correctProbability(theta, a, b);
  return Math.pow(p, x) * Math.pow(1 - p, 1 - x);
}

//min~maxの能力値の下で正答/誤答確率,x=1正答
const icc = (x, a, b, min, max, step) => {
  const iccDist = [];
  for (let theta = min; theta <= max; theta += step) {
    iccDist.push(responseProbability(x, theta, a, b));
  }
  return iccDist;
}

const practice2 = () => {
  result.innerHTML = responseProbability(0, 1, 1, 2).toFixed(3) + '<br>';
  const dist = icc(1, 1, 0, -3, 3, 1);
  for (let i = 0; i < dist.length; i += 1) {
    result.innerHTML += dist[i].toFixed(3) + ', ';
  }
}
// practice2();

const itemBank = [
  { a: 1, b: 0 },
  { a: 0.5, b: 3 }
];//aとbのバンク

//x:正誤答のarray
const bayes = (x, itemBank, min, max, step) => {
  const dist = normDist(min, max, step);//P(theta)
  x.forEach((eachX, index) => {
    const item = itemBank[index]; //itemBankから一つ問題セットを抽出
    const likehoodDist = icc(eachX, item.a, item.b, min, max, step);
    dist.forEach((_, theta, arr) =>
      arr[theta] *= likehoodDist[theta]);
    //P(theta)*P(X|theta)
  });

  //周辺尤度計算
  const marginalLikehood = dist.reduce((a, b) => a + b);//P(x)
  dist.forEach((_, theta, arr) =>
    arr[theta] /= marginalLikehood);//P(theta)*P(X|theta)
  return dist;
}

const argmax = arr => arr.indexOf(arr.reduce((a, b) => Math.max(a, b)));

const estimation = (x, itemBank, min, max, step) => {
  const probability = bayes(x, itemBank, min, max, step);
  return min + argmax(probability) * step;
}

const practice3 = () => {
  bayesDist = bayes([1], [{ a: 1, b: 0 }], -2, 2, 1);
  bayesDist.forEach((value) => result.innerHTML += value.toFixed(3) + ',');

  result.innerHTML += "<br>";
  result.innerHTML += estimation([1], [{ a: 1, b: 0 }], -2, 2, 1) + ', ';
}
// practice3();

const information = (theta, itemBank) => {
  let info = 0;
  itemBank.forEach(item => {
    const p = correctProbability(theta, item.a, item.b);
    info += 1.7 * 1.7 * item.a * item.a * p * (1 - p);
  });
  return info;
}

const standardError = (theta, intemBank) => {
  return 1.0 / Math.sqrt(information(theta, itemBank));
}

const practice4 = () => {
  result.innerHTML = information(0, [{ a: 1, b: 0 }]).toFixed(4) + "<br>";
}
// practice4();


/************************************/
/************************************/
/**********シミュレーション実験 ********/
/************************************/
/************************************/
const simulation = (Q_NUM, E_NUM) => {
  // アイテムバンク生成
  const itemBank = [];
  for (let i = 0; i < Q_NUM; i++) {
    itemBank.push({
      a: Math.random() * 2,  // [0, 2)
      b: (Math.random() - 0.5) * 6  // [-3, 3)
    });
  }

  // 受験者生成
  const examinee = [];
  for (let e = 0; e < E_NUM; e++) {
    examinee.push((Math.random() - 0.5) * 6);// [-3, 3)
  }

  // 受験者ごとの誤差
  const error = [];
  for (const theta of examinee) {
    const x = []; //正1

    for (const item of itemBank) {
      x.push(correctProbability(theta, item.a, item.b) > Math.random() ? 1 : 0);
    }

    error.push(Math.abs(theta - estimation(x, itemBank, -3, 3, 0.1)));
  }

  // 平均誤差
  return error.reduce((a, b) => a + b) / E_NUM;
};

// result.innerHTML += "課題1-1<br>受験者を固定する場合<br>";
// result.innerHTML += "問題数=10 受験者数=50<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation(10, 50) + "<br>";

// }
// result.innerHTML += "<br>";

// result.innerHTML += "問題数=50 受験者数=50<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation(50, 50) + "<br>";

// }
// result.innerHTML += "<br>";

// result.innerHTML += "問題数=100 受験者数=50<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation(100, 50) + "<br>";

// }
// result.innerHTML += "<br>";

// result.innerHTML += "問題数=150 受験者数=50<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation(150, 50) + "<br>";

// }
// result.innerHTML += "<br>";

// result.innerHTML += "問題数=200 受験者数=50<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation(200, 50) + "<br>";

// }
// result.innerHTML += "<br>";



// result.innerHTML += "問題数を固定する場合<br>";
// result.innerHTML += "問題数=50 受験者数=100<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation(50, 100) + "<br>";

// }
// result.innerHTML += "<br>";

// result.innerHTML += "問題数=50 受験者数=150<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation(50, 150) + "<br>";

// }
// result.innerHTML += "<br>";

// result.innerHTML += "問題数=50 受験者数=200<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation(50, 200) + "<br>";

// }
// result.innerHTML += "<br>";
// result.innerHTML += "問題数=50 受験者数=400<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation(50, 400) + "<br>";

// }
// result.innerHTML += "<br>";

// result.innerHTML += "<br><br>";


/************************************/
/************************************/
/**********シミュレーション実験 2 ******/
/************************************/
/************************************/

// 標準偏差 sigma を指定して正規分布生成器
function norm_dis(sigma = 1, mu = 0) {
  let u = 0, v = 0;
  while (u === 0) u = Math.random();
  while (v === 0) v = Math.random();
  const z = Math.sqrt(-2.0 * Math.log(u)) * Math.cos(2.0 * Math.PI * v);
  return mu + sigma * z;
}


const simulation2 = (Q_NUM, E_NUM, sigma) => {
  // アイテムバンク生成
  const itemBank = [];
  for (let i = 0; i < Q_NUM; i++) {
    itemBank.push({
      a: Math.random() * 2,  // [0, 2)
      b: norm_dis(sigma, 0)  // 正規分布
    });
  }

  // 受験者生成
  const examinee = [];
  for (let e = 0; e < E_NUM; e++) {
    examinee.push((Math.random() - 0.5) * 6);// [-3, 3)
  }

  // 受験者ごとの誤差
  const error = [];
  for (const theta of examinee) {
    const x = []; //正1

    for (const item of itemBank) {
      x.push(correctProbability(theta, item.a, item.b) > Math.random() ? 1 : 0);
    }

    error.push(Math.abs(theta - estimation(x, itemBank, -3, 3, 0.1)));
  }

  // 平均誤差
  return error.reduce((a, b) => a + b) / E_NUM;
};

// result.innerHTML += "<br><br>////////////課題1-2////////////<br><br>";

// result.innerHTML += "問題数=50 受験者数=50<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation(50, 50) + "<br>";

// }
// result.innerHTML += "<br>";

// result.innerHTML += "問題数=50 受験者数=50,sigma=0.5<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation2(50, 50, 0.5) + "<br>";

// }
// result.innerHTML += "<br>";

// result.innerHTML += "問題数=50 受験者数=50,sigma=1<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation2(50, 50, 1) + "<br>";

// }
// result.innerHTML += "<br>";

// result.innerHTML += "問題数=50 受験者数=50,sigma=2<br>";
// for (let i = 0; i < 5; i++) {
//   result.innerHTML += '平均誤差：' + simulation2(50, 50, 2) + "<br>";

// }
// result.innerHTML += "<br><br>";