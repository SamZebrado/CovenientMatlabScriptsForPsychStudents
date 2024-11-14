% demo_copy_legend - Demonstrates usage of copy_legend function

% Step 1: Create a source figure with a legend
fig1 = figure('Name', 'Source Figure');
ax1 = subplot(1, 2, 1);
plot(rand(10, 2));
legend('Line 1', 'Line 2', 'Location', 'northeast');
title('Source Subplot with Legend');

% Step 2: Create a target figure without a legend
fig2 = figure('Name', 'Target Figure');
ax2 = subplot(1, 2, 1);
plot(rand(10, 2));
title('Target Subplot without Legend');

% Copy the legend from the source subplot to the target subplot
copy_legend(ax1, ax2);

% Optional: Copy the legend to a new position in the target subplot
figure(fig2); % Bring the target figure to focus
ax3 = subplot(1, 2, 2);
plot(rand(10, 2));
title('Another Target Subplot without Legend');
customPosition = [0.7, 0.8, 0.1, 0.1]; % Custom position for the legend

% Copy legend from source to this new subplot with a custom position
copy_legend(ax1, ax3, customPosition);

% Display completion message
disp('Legends have been copied to the target figure subplots.');
