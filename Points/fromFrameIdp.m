function [i,I_f,I_if] = fromFrameIdp(F,i_F)

% FROMFRAMEIDP  Transforms IDP from local frame to global frame.
%   I = FROMFRAMEIDP(F,IF) transforms the Inverse Depth point IF from the
%   local frame F to the global frame. The frame F can be specified either
%   with a 7-vector F=[T;Q], where T is the translation vector and Q the
%   orientation quaternion, of via a structure containing at least the
%   fields F.t, F.q, F.R and F.Rt (translation, quaternion, rotation matrix
%   and its transpose).
%
%   [I,I_f,I_if] = FROMFRAMEIDP(...) returns the Jacobians wrt F and IF.

xf  = i_F(1:3,:);
pyf = i_F(4:5,:);
sf  = i_F(6,:);

[t,q,R,Rt] = splitFrame(F);

if nargout == 1

    x  = fromFrame(F,xf);
    mf = py2vec(pyf);
    m  = R*mf;
    py = vec2py(m);

    i  = [x;py;s];

else

    if size(i_F,2) > 1
        error('Jacobians not available for multiple idps')
    else

        [x, X_f, X_xf] = fromFrame(F,xf);
        [mf, MF_pyf]   = py2vec(pyf);
        [m,M_q,M_mf]   = Rp(q,mf);
        [py,PY_m]      = vec2py(m);

        i    = [x;py;sf];

        PY_pyf = PY_m*M_mf*MF_pyf;

        I_f = [...
            X_f
            zeros(2,3) PY_m*M_q
            zeros(1,7)];

        I_if = [...
            X_xf          zeros(3,3)
            zeros(2,3) PY_pyf zeros(2,1)
            zeros(1,5)           1];

    end
end

return

%% jac

syms x y z a b c d X Y Z A B R real
F   = [x;y;z;a;b;c;d];
i_F = [X;Y;Z;A;B;R];

[i,I_f,I_if] = fromFrameIdp(F,i_F);

simplify(I_f  - jacobian(i,F))
simplify(I_if - jacobian(i,i_F))

