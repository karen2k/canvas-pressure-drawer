// функция отрисовки, вызываемая событием таймера 
private void Draw(){
  // количество сегментов при расчете сплайна 
  int N = 30; // вспомогательные переменные для расчета сплайна 
  double X, Y;

  // n = count_po int s+1 означает что мы берем все созданные контрольные 
  // точки + ту, которая следует за мышью, для создания интерактивности приложения 
  int eps = 4, i, j, n = count_po int s+1, first;
  double xA, xB, xC, xD, yA, yB, yC, yD, t;
  double a0, a1, a2, a3, b0, b1, b2, b3;

  // начинает отрисовку кривой 
  Gl.glBegin( Gl.GL_LINE_STRIP);

  // используем все точки -1 (т,к. алгоритм 'зацепит' i+1 точку 
  for (i = 1; i < n-1; i++){
    // реализация представленного в теоретическом описании алгоритма для калькуляции сплайна 
    first = 1;
    xA = DrawingArray[i - 1, 0];
    xB = DrawingArray[i, 0];
    xC = DrawingArray[i + 1, 0];
    xD = DrawingArray[i + 2, 0];

    yA = DrawingArray[i - 1, 1];
    yB = DrawingArray[i, 1];
    yC = DrawingArray[i + 1, 1];
    yD = DrawingArray[i + 2, 1];

    a3 = (-xA + 3 * (xB - xC) + xD) / 6.0;

    a2 = (xA - 2 * xB + xC) / 2.0;

    a1 = (xC - xA) / 2.0;

    a0 = (xA + 4 * xB + xC) / 6.0;

    b3 = (-yA + 3 * (yB - yC) + yD) / 6.0;

    b2 = (yA - 2 * yB + yC) / 2.0;

    b1 = (yC - yA) / 2.0;

    b0 = (yA + 4 * yB + yC) / 6.0;

    // отрисовка сегментов 

    for (j = 0; j <= N; j++){
      // параметр t на отрезке от 0 до 1 
      t = ( double )j / ( double )N;

      // генерация координат 
      X = (((a3 * t + a2) * t + a1) * t + a0);
      Y = (((b3 * t + b2) * t + b1) * t + b0);

      // и установка вершин 
      if (first == 1){
        first = 0;
        Gl.glVertex2d(X, Y);
      }else
        Gl.glVertex2d(X, Y);
    }
  }
  Gl.glEnd();


  // завершаем рисование 
  Gl.glFlush();
}