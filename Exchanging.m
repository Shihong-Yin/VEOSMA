function change_X = Exchanging(inti_X,i,j)
a = inti_X(i);
b = inti_X(j);
change_X = inti_X;
change_X(i) = b;
change_X(j) = a;
end

