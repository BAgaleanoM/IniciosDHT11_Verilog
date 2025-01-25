// Uso de las primitivas

module example_1(x1,x2,x3,f);
  input x1,x2,x3;
  output f;

  and(g, x1, x2);
  not(k, x2);
  and(h,k,x3);
  or(f, g, h);

endmodule

// Uso del always

module example_always(a,b,c,d,out);
  output out;
  input a, b, c;
  
  always @ (a or b or c or d)
    out <= ~((a & ) | (c ^ d));

endmodule

// Operador condiciona ->(?)

module mux2to1(x0, x1, s, f);
  input x0, x1, s;
  output f;

  assign f = s ? x1 : x0; //Sí s(1) f = x1, si s(0) f = x0
  
endmodule

// Uso de if else (siempre dentro de un always)

module mux_con_ifelse(x0, x1, s, f);
  input x0, x1, s;
  output f;

  always @(x0, x1, s);
    if (s == 0)
      f = x0;
    else
      f = x1;
// también se puede usar else if para anidar más condiciones, termina siempre con else
endmodule

  
