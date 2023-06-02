function [new_x,new_y,new_z] = rot_satpos(tk,x,y,z,omiga)

alpha = omiga*tk;
cl = cos(alpha);
sl = sin(alpha);
new_x=cl.*x+sl.*y;
new_y=-sl.*x+cl.*y;
new_z=z;
end