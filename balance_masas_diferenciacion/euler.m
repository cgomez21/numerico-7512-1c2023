clear all;

function datos_balance = iterar_mes(vn, on, dn, h, dia_inicial, dia_final, numero_mes)
  # Datos
  caudales = load("caudales_mensuales.dat"); # m^3/s
  kbd_0 = 0.1; # 1/día
  ka = 0.01; # 1/día
  ko2 = 1.4; # g^2/m^6
  dbo_e = 20; # g/m^3
  od_e = 2; # g/m^3
  od_s = 9; # g/m^3
  # 20 -> 100%
  # 16 -> 80%

  # Obtengo los caudales y les cambio las unidades a m^3/dia
  qe = 86400 * caudales(numero_mes, 1);
  qs = 86400 * caudales(numero_mes, 2);

  datos_balance = zeros(dia_final-dia_inicial+1, 3);

  for i = 1:dia_final-dia_inicial+1
    kbd = kbd_0 * (on^2 / (on^2 + ko2));
    g = ka * vn * (od_s - on);
    p = kbd * vn * dn;

    fv = qe - qs;
    fo = ((qe*od_e - qs*on) + g - p)/vn;
    fd = ((qe*dbo_e - qs*dn) - p)/vn;

    vn = vn + h*fv;
    on = on + h*fo;
    dn = dn + h*fd;

    datos_balance(i, 1) = vn;
    datos_balance(i, 2) = on;
    datos_balance(i, 3) = dn;
  endfor
endfunction

function bal_anual = iterar_12_meses(v0, o0, d0, h)
  cantidad_datos = round(365.*(1/h));
  bal_anual = [zeros(cantidad_datos, 1), zeros(cantidad_datos, 1), zeros(cantidad_datos, 1)];

  for i = 1:12
    switch(i)
    case 1
      bal_anual(1:round(31.*1/h), :) = iterar_mes(v0, o0, d0, h, 1, round(31 .* 1/h), i);
    case 2
      bal_anual(round(31*1/h)+1:round(59.*1/h), :) = iterar_mes(bal_anual(round(31.*1/h), 1), bal_anual(round(31.*1/h), 2), bal_anual(round(31.*1/h), 3), h, round(31.*1/h)+1, round(59.*1/h), i);
    case 3
      bal_anual(round(59.*1/h)+1:round(90.*1/h), :) = iterar_mes(bal_anual(round(59.*1/h), 1), bal_anual(round(59.*1/h), 2), bal_anual(round(59.*1/h), 3), h, round(59.*1/h)+1, round(90.*1/h), i);
    case 4
      bal_anual(round(90*1/h)+1:round(112.*1/h), :) = iterar_mes(bal_anual(round(90.*1/h), 1), bal_anual(round(90.*1/h), 2), bal_anual(round(90.*1/h), 3), h, round(90*1/h)+1, round(112.*1/h), i);
    case 5
      bal_anual(round(112*1/h)+1:round(144.*1/h), :) = iterar_mes(bal_anual(round(112.*1/h), 1), bal_anual(round(112.*1/h), 2), bal_anual(round(112.*1/h), 3), h, round(112*1/h)+1, round(144.*1/h), i);
    case 6
      bal_anual(round(144*1/h)+1:round(175.*1/h), :) = iterar_mes(bal_anual(round(144.*1/h), 1), bal_anual(round(144.*1/h), 2), bal_anual(round(144.*1/h), 3), h, round(144*1/h)+1, round(175.*1/h), i);
    case 7
      bal_anual(round(175*1/h)+1:round(207.*1/h), :) = iterar_mes(bal_anual(round(175.*1/h), 1), bal_anual(round(175.*1/h), 2), bal_anual(round(175.*1/h), 3), h, round(175*1/h)+1, round(207.*1/h), i);
    case 8
      bal_anual(round(207*1/h)+1:round(239.*1/h), :) = iterar_mes(bal_anual(round(207.*1/h), 1), bal_anual(round(207.*1/h), 2), bal_anual(round(207.*1/h), 3), h, round(207*1/h)+1, round(239.*1/h), i);
    case 9
      bal_anual(round(239*1/h)+1:round(270.*1/h), :) = iterar_mes(bal_anual(round(239.*1/h), 1), bal_anual(round(239.*1/h), 2), bal_anual(round(239.*1/h), 3), h, round(239*1/h)+1, round(270.*1/h), i);
    case 10
      bal_anual(round(270*1/h)+1:round(302.*1/h), :) = iterar_mes(bal_anual(round(270.*1/h), 1), bal_anual(round(270.*1/h), 2), bal_anual(round(270.*1/h), 3), h, round(270*1/h)+1, round(302.*1/h), i);
    case 11
      bal_anual(round(302*1/h)+1:round(333.*1/h), :) = iterar_mes(bal_anual(round(302.*1/h), 1), bal_anual(round(302.*1/h), 2), bal_anual(round(302.*1/h), 3), h, round(302*1/h)+1, round(333.*1/h), i);
    case 12
      bal_anual(round(333*1/h)+1:round(365.*(1/h)), :) = iterar_mes(bal_anual(round(333.*1/h), 1), bal_anual(round(333.*1/h), 2), bal_anual(round(333.*1/h), 3), h, round(333*1/h)+1, round(365.*(1/h)), i);
    endswitch
  endfor
endfunction

v0 = 264.98 * (10.^6); # V0 obtenido por ajuste, y expresado en (m^3)
o0 = 0; # OD0
d0 = 0; # DBO0


h = 1; #en dias
euler_paso_diario(1:365, :) = iterar_12_meses(v0, o0, d0, h);
v = euler_paso_diario(365, 1);
o = euler_paso_diario(365, 2);
d = euler_paso_diario(365, 3);
euler_paso_diario(366:730, :) = iterar_12_meses(v, o, d, h);
v = euler_paso_diario(730, 1);
o = euler_paso_diario(730, 2);
d = euler_paso_diario(730, 3);
euler_paso_diario(731:1095, :) = iterar_12_meses(v, o, d, h);
v = euler_paso_diario(1095, 1);
o = euler_paso_diario(1095, 2);
d = euler_paso_diario(1095, 3);
euler_paso_diario(1096:1460, :) = iterar_12_meses(v, o, d, h);
v = euler_paso_diario(1460, 1);
o = euler_paso_diario(1460, 2);
d = euler_paso_diario(1460, 3);
euler_paso_diario(1461:1825, :) = iterar_12_meses(v, o, d, h);


h = 0.5;
euler_paso_medio_dia(1:730, :) = iterar_12_meses(v0, o0, d0, h);
v = euler_paso_medio_dia(730, 1);
o = euler_paso_medio_dia(730, 2);
d = euler_paso_medio_dia(730, 3);
euler_paso_medio_dia(731:1460, :) = iterar_12_meses(v, o, d, h);
v = euler_paso_medio_dia(1460, 1);
o = euler_paso_medio_dia(1460, 2);
d = euler_paso_medio_dia(1460, 3);
euler_paso_medio_dia(1461:2190, :) = iterar_12_meses(v, o, d, h);
v = euler_paso_medio_dia(2190, 1);
o = euler_paso_medio_dia(2190, 2);
d = euler_paso_medio_dia(2190, 3);
euler_paso_medio_dia(2191:2920, :) = iterar_12_meses(v, o, d, h);
v = euler_paso_medio_dia(2920, 1);
o = euler_paso_medio_dia(2920, 2);
d = euler_paso_medio_dia(2920, 3);
euler_paso_medio_dia(2921:3650, :) = iterar_12_meses(v, o, d, h);


h = 7;
euler_paso_semanal(1:52, :) = iterar_12_meses(v0, o0, d0, h);
v = euler_paso_semanal(52, 1);
o = euler_paso_semanal(52, 2);
d = euler_paso_semanal(52, 3);
euler_paso_semanal(53:104, :) = iterar_12_meses(v, o, d, h);
v = euler_paso_semanal(104, 1);
o = euler_paso_semanal(104, 2);
d = euler_paso_semanal(104, 3);
euler_paso_semanal(105:156, :) = iterar_12_meses(v, o, d, h);
v = euler_paso_semanal(156, 1);
o = euler_paso_semanal(156, 2);
d = euler_paso_semanal(156, 3);
euler_paso_semanal(157:208, :) = iterar_12_meses(v, o, d, h);
v = euler_paso_semanal(208, 1);
o = euler_paso_semanal(208, 2);
d = euler_paso_semanal(208, 3);
euler_paso_semanal(209:260, :) = iterar_12_meses(v, o, d, h);

et_euler_semanal = abs(euler_paso_semanal(53:260, 2:3) - euler_paso_medio_dia(744:14:3650, 2:3));
et_euler_diario = abs(euler_paso_diario(366:1825, 2:3) - euler_paso_medio_dia(732:2:3650, 2:3));

# desplazo los datos calculados para graficarlos desde el 0
euler_paso_diario(2:1826, :) = euler_paso_diario(1:1825, :);
euler_paso_diario(1, :) = [v0, o0, d0];

euler_paso_semanal(2:261, :) = euler_paso_semanal(1:260, :);
euler_paso_semanal(1, :) = [v0, o0, d0];

# Grafico de Volumen
plot(0:1825, euler_paso_diario(:, 1));
legend("Volumen");
title("Volumen simulado en 5 años");
xlabel ("t (dias)");
ylabel ("V(t)");
hold off;

print -djpeg euler_volumen_simulado.jpg;

# Graficos de concentracion con paso Diario
plot(0:1825, euler_paso_diario(:, 2));
hold on;
plot(0:1825, euler_paso_diario(:, 3));
legend("OD", "DBO");
title("Concentración de OD y DBO simuladas en 5 años");
xlabel ("t (dias)");
ylabel ("C(t)");
hold off;

print -djpeg euler_paso_diario.jpg;

# Grafico errores de truncamiento con paso diario
plot(0:1460, [0; et_euler_diario(:, 1)]); # grafico et OD
hold on;
plot(0:1460, [0; et_euler_diario(:, 2)]); # grafico et DBO
legend("Et OD", "Et DBO");
title("Errores de truncamiento de OD y DBO con paso diario");
xlabel ("t (dias)");
ylabel ("Et(t)");
hold off;

print -djpeg euler_errores_truncamiento_diario.jpg;

# Grafico errores de truncamiento con paso semanal
plot(0:208, [0; et_euler_semanal(:, 1)]); # grafico et OD
hold on;
plot(0:208, [0; et_euler_semanal(:, 2)]); # grafico et DBO
legend("Et OD", "Et DBO");
title("Error de truncamiento de OD y DBO con paso semanal");
xlabel ("t (semanas)");
ylabel ("Et(t)");
hold off;

print -djpeg euler_errores_truncamiento_semanal.jpg;

# Grafico con paso semanal
plot(0:260, euler_paso_semanal(:, 2)); # grafico et OD
hold on;
plot(0:260, euler_paso_semanal(:, 3)); # grafico et DBO
legend("OD", "DBO");
title("Concentración de OD y DBO simuladas en 5 años");
xlabel ("t (semanas)");
ylabel ("C(t)");
hold off;

print -djpeg euler_semanal.jpg;
