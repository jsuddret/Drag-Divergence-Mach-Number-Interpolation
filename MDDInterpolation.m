%% AUTHOR: JAKE SUDDRETH
clc; clear all;
% TAKE IN USER INPUT
prompt = "Coefficient of Lift: ";
lift_coefficient = input(prompt);
prompt = "Thickness ratio: ";
thickness_ratio = input(prompt);
prompt = "Wing sweep angle (degrees): ";
wing_sweep = input(prompt);
drag_divergence_mach_number = drag_divergence_mach(lift_coefficient, thickness_ratio, wing_sweep);
fprintf("Drag-divergence Mach number: %f\n", drag_divergence_mach_number);
%% FUNCTION
function output = drag_divergence_mach(cl, tc, lambda)
% DATA
thickness = [0.08 0.1 0.12];
MDD2 = [0.806 0.784 0.762; NaN 0.822 0.801; NaN 0.868 0.844; NaN NaN NaN];
MDD3 = [0.785 0.764 0.744; 0.824 0.802 0.781; 0.863 0.839 0.818; NaN 0.905 0.884];
MDD4 = [0.763 0.744 0.727; 0.799 0.779 0.761; 0.835 0.814 0.796; 0.898 0.876 0.855];
MDD5 = [0.742 0.724 0.708; 0.775 0.756 0.741; 0.809 0.790 0.775; 0.860 0.842 0.824];
MDD6 = [0.716 0.703 0.692; 0.750 0.735 0.722; 0.781 0.764 0.750; 0.860 0.812 0.797];
% HANDLE NaN
thicknessfit = [thickness thickness thickness thickness]';
lambdafit = [0 0 0 15 15 15 25 25 25 35 35 35]';
MDD2fit = [MDD2(1, :) MDD2(2, :) MDD2(3, :) MDD2(4, :)]';
MDD2fit = MDD2fit(MDD2fit > 0);
thicknessfit2 = [0.08 0.1 0.12 0.1 0.12 0.1 0.12]';
lambdafit2 = [0 0 0 15 15 25 25]';
MDD3fit = [MDD3(1, :) MDD3(2, :) MDD3(3, :) MDD3(4, :)]';
MDD3fit = MDD3fit(MDD3fit > 0);
thicknessfit3 = [0.08 0.1 0.12 0.08 0.1 0.12 0.08 0.1 0.12 0.1 0.12]';
lambdafit3 = [0 0 0 15 15 15 25 25 25 35 35]';
MDD4fit = [MDD4(1, :) MDD4(2, :) MDD4(3, :) MDD4(4, :)]';
MDD5fit = [MDD5(1, :) MDD5(2, :) MDD5(3, :) MDD5(4, :)]';
MDD6fit = [MDD6(1, :) MDD6(2, :) MDD6(3, :) MDD6(4, :)]';
% SURFACE FITS
sfit2 = fit([thicknessfit2, lambdafit2], MDD2fit, "poly22");
sfit3 = fit([thicknessfit3, lambdafit3], MDD3fit, "poly23");
sfit4 = fit([thicknessfit, lambdafit], MDD4fit, "poly23");
sfit5 = fit([thicknessfit, lambdafit], MDD5fit, "poly23");
sfit6 = fit([thicknessfit, lambdafit], MDD6fit, "poly23");
% PLOT SURFACE FITS
figure
plot(sfit2);
hold on;
plot(sfit3);
plot(sfit4);
plot(sfit5);
plot(sfit6);
xlabel("Thickness ratio");
ylabel("Sweep angle (degrees)");
zlabel("Drag divergence Mach number");
title("M_D_D versus \Lambda, t/c for all Coefficients of Lift");
colorbar('eastoutside')
% EXTRACT DRAG DIVERGENCE MACH NUMBER WITH LINEAR INTERPOLATION
if cl >= 0.2 && cl <= 0.3
    a = feval(sfit2, [tc, lambda]);
    b = feval(sfit3, [tc, lambda]);
    output = interpolate_fit(0.2, 0.3, cl, a, b);
elseif cl >= 0.3 && cl <= 0.4
    a = feval(sfit3, [tc, lambda]);
    b = feval(sfit4, [tc, lambda]);
    output = interpolate_fit(0.3, 0.4, cl, a, b);
elseif cl >= 0.4 && cl <= 0.5
    a = feval(sfit4, [tc, lambda]);
    b = feval(sfit5, [tc, lambda]);
    output = interpolate_fit(0.4, 0.5, cl, a, b);
elseif cl >= 0.5 && cl <= 0.6
    a = feval(sfit5, [tc, lambda]);
    b = feval(sfit6, [tc, lambda]);
    output = interpolate_fit(0.5, 0.6, cl, a, b);
else % PREVENT EXTRAPOLATION
    output = NaN;
    fprintf("Error. Cannot find accurate solution.\nEnter coefficient of lift within the following bounds: [0.2, 0.6].");
end
end
function output = interpolate_fit(cla, clb, cl, svala, svalb)
output = svala + (svalb - svala) / (clb - cla) * (cl - cla);
end