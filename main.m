clear; close all;
%% load data
loadData();
% data visualization, the heavy-tailed coefficient
% data visualization, the angular-doppler spectrum

%% 
getDoa();

T = 100;                 % 实验轮数
Ns = 20;                % 每轮样本数
max_iter = 150;          % 最大迭代次数
lamb = 1e4;
%% 预分配结果存储
% MM算法结果
mm_obj = nan(T, max_iter);      % 目标函数值
mm_time = zeros(T, 1);          % 运行时间

% Lasso结果
lasso_obj = nan(T, max_iter);    % 目标函数值 (MSE)
lasso_time = zeros(T, 1);        % 运行时间

%% 主实验循环
for round = 1:T
    fprintf('=== 实验轮次 %d/%d ===\n', round, T);

    % 1. 随机抽取样本
    randIdx = randperm(totalNumSamp, Ns);
    currentData = cluttersig_all(randIdx, :).';  % [MN x Ns]

    % 2. 运行MM算法
    tic;
    % [convgTol_mm, actual_iter, ~, ~, ~, ~, obj_mm, res_mm, stopIter] = MM_PD_20250302(...
    %     max_iter, currentData, SV_CUT, Doasig, PowerThermalNoise,...
    %     sparsity_level, Doavec, P_clutter_r);

    [originalObj, convgTol_mm, actual_iter, ~, ~, ~, ~, obj_mm, res_mm, stopIter] = MM_20250320(...
        max_iter, currentData, SV_CUT, Doasig, PowerThermalNoise,...
        sparsity_level, Doavec, P_clutter_r);

    mm_time(round) = toc;
    fprintf('单次mm实验收敛花费时间：%.2f s\n', mm_time(round))

    % 存储结果 (处理提前终止情况)
    mm_obj(round, 1:length(obj_mm)) = obj_mm;
    if length(obj_mm) < max_iter
        mm_obj(round, length(obj_mm)+1:end) = obj_mm(end);
    end

    % 3. 运行Lasso
    tic;
    [~, ~, ~, Outs_lasso] = LASSOestimate_105214(currentData, SV_CUT, lamb, PowerThermalNoise);
    lasso_time(round) = toc;


    % 存储结果
    lasso_obj(round, 1:length(Outs_lasso.objective)) = Outs_lasso.objective;
    if length(Outs_lasso.objective) < max_iter
        lasso_obj(round, length(Outs_lasso.objective)+1:end) = Outs_lasso.objective(end);
    end
end
%% gemini
mm_obj_shifted = zeros(size(mm_obj));
lasso_obj_shifted = zeros(size(lasso_obj));

for r = 1:T
    mm_obj_min = min(mm_obj(r, :));
    mm_obj_shif = mm_obj(r, :) + abs(mm_obj_min);
    mm_obj_shifted(r, :) = mm_obj_shif;


    % Lasso归一化
    lasso_obj_min = min(lasso_obj(r, :));
    lasso_obj_shif = lasso_obj(r, :) + abs(lasso_obj_min);
    lasso_obj_shifted(r, :) = lasso_obj_shif;
end

max_obj = max(mm_obj_shifted(:));
mm_obj_shifted = mm_obj_shifted/max_obj;

mean_mm = mean(mm_obj_shifted, 1);
std_mm = std(mm_obj_shifted, 0, 1);
ci_mm = 1.96*std_mm/sqrt(T);  % 95% CI


max_obj_lasso = max(lasso_obj_shifted(:));
mm_obj_shifted = lasso_obj_shifted/max_obj_lasso;

mean_lasso = mean(lasso_obj_shifted, 1);


std_lasso = std(lasso_obj_shifted, 0, 1);
ci_lasso = 1.96*std_lasso/sqrt(T);  % 95% CI



% 
% 
%  创建图形
figure('Position', [100 100 800 600]);

% 颜色方案和线型
lineColor = [0.0, 0.447, 0.741]; % 蓝色均值线
fillColor = [0.8, 0.8, 1];       % 浅蓝色置信区间填充
iterationsColor = [0.5 0.5 0.5]; % 迭代次数轴颜色

% 绘制收敛曲线带置信区间
iterations = 1:max_iter;

% 使用对数坐标系绘制均值线
meanLine = semilogy(iterations, mean_mm, '-', 'Color', lineColor, 'LineWidth', 1.5); % 调整线宽
hold on;

% % Lasso曲线
meanLine_lasso = semilogy(iterations, mean_lasso./mean_lasso(1), '-', 'Color', 'r', 'LineWidth', 1.5); % 调整线宽

