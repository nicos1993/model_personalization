clear
clc
close all

import org.opensim.modeling.*

% Toggle to save plots
save_plot = 'Yes';



knee_angle = 10;
hip_angles = (-30:5:120);

knee_angles = (0:5:120);
hip_angle = 70;

ankle_angles = (-30:5:30);
fixed_knee_ankle = 80;

% Generate passive experimental moment curves
[passive_hip_moments_RE, passive_ankle_moments_RE, passive_knee_moments_RE] = RienerEdrich_PassiveMoments(hip_angles,knee_angle,ankle_angles,fixed_knee_ankle,knee_angles,hip_angle);

% Generate set of curves in RienerEdrich1999 for matching configurations
[passive_hip_moments_RE_0, passive_ankle_moments_RE_0, passive_knee_moments_RE_0] = RienerEdrich_PassiveMoments(hip_angles,0,ankle_angles,0,knee_angles,0);
[passive_hip_moments_RE_45, passive_ankle_moments_RE_60, passive_knee_moments_RE_90] = RienerEdrich_PassiveMoments(hip_angles,45,ankle_angles,60,knee_angles,90);

if strcmp(save_plot,'Yes')

    figure();
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot('Position',[0.1, 0.6, 0.25, 0.25])
    plot(hip_angles,passive_hip_moments_RE_0,'k','LineWidth',2.5);
    hold on
    plot(hip_angles,passive_hip_moments_RE_45,'r','LineWidth',2.5);
    xlabel('Joint Angle (deg)',FontWeight='bold');
    ylabel({'Passive Hip', 'Flexion-Extension', 'Moment (Nm)'},FontWeight='bold');
    legend({'Knee Angle = 0 deg','Knee Angle = 45 deg'},'Box','off','Location','southwest')
    set(gca, 'FontSize', 20);
    set(gca, 'Box', 'off');
    set(gca, 'LineWidth', 2.5);
    
    subplot('Position',[0.1, 0.25, 0.25, 0.25])
    plot(knee_angles,passive_knee_moments_RE_0,'k','LineWidth',2.5);
    hold on
    plot(knee_angles,passive_knee_moments_RE_90,'r','LineWidth',2.5);
    xlabel('Joint Angle (deg)',FontWeight='bold');
    ylabel({'Passive Knee', 'Flexion-Extension', 'Moment (Nm)'},FontWeight='bold');
    legend({'Hip Angle = 0 deg','Hip Angle = 90 deg'},'Box','off')
    set(gca, 'FontSize', 20);
    set(gca, 'Box', 'off');
    set(gca, 'LineWidth', 2.5);
    
    subplot('Position',[0.5, 0.6, 0.25, 0.25])
    plot(ankle_angles,passive_ankle_moments_RE_0,'k','LineWidth',2.5);
    hold on
    plot(ankle_angles,passive_ankle_moments_RE_60,'r','LineWidth',2.5);
    xlabel('Joint Angle (deg)',FontWeight='bold');
    ylabel({'Passive Ankle', 'Dorsiflexion-Plantarflexion', 'Moment (Nm)'},FontWeight='bold');
    legend({'Knee Angle = 0 deg','Knee Angle = 60 deg'},'Box','off')
    set(gca, 'FontSize', 20);
    set(gca, 'Box', 'off');
    set(gca, 'LineWidth', 2.5);

    filename = 'Plots/passive_moments_RienerEdrich.png';
    saveas(gcf, filename, 'png');

end

model_R = Model('Models\Rajagopal2016.osim');

model_op = ModelProcessor(model_R);
model_op.append(ModOpScaleMaxIsometricForce(2));
model_R_strong = model_op.process();
model_R_strong.initSystem();

model_RLU = Model('Models\RajagopalLaiUhlrich2023.osim');

model_R_DGF = Model('Models\Rajagopal2016_wDGFmuscles.osim');

model_RLU_DGF = Model('Models\RajagopalLaiUhlrich2023_wDGFmuscles.osim');

model_H = Model('Models\FullBodyModel_SimpleArms_Hamner2010_Markers_v4_x.osim');

model_op = ModelProcessor(model_H);
model_op.append(ModOpScaleMaxIsometricForce(2));
model_H_strong = model_op.process();
model_H_strong.initSystem();

hip = 'hip_flexion_r';
knee = 'knee_angle_r';
ankle = 'ankle_angle_r';

hipExtMuscles = ["addmagDist_r","addmagIsch_r","addmagMid_r",...
    "addmagProx_r","glmax1_r","glmax2_r","glmax3_r","glmed1_r","glmed2_r",...
    "glmed3_r","glmin3_r","semimem_r","semiten_r","bflh_r"];
hipFleMuscles = ["addbrev_r","addlong_r","glmin1_r","grac_r","iliacus_r",...
    "psoas_r","recfem_r","sart_r","tfl_r"];
kneeExtMuscles = ["recfem_r","vasint_r","vasmed_r","vaslat_r"];
kneeFleMuscles = ["gasmed_r","grac_r","sart_r","semimem_r","semiten_r","bflh_r","bfsh_r","gaslat_r"];
ankleExtMuscles = ["fdl_r","fhl_r","gasmed_r","perbrev_r","perlong_r",...
    "soleus_r","tibpost_r"];
ankleFleMuscles = ["edl_r","ehl_r","tibant_r"];

% Hamner muscle naming convention
hipExtMuscles_H = ["add_long_r","add_mag1_r","add_mag2_r",...
    "add_mag3_r","glut_max1_r","glut_max2_r","glut_max3_r","glut_med3_r","glut_min3_r",...
    "semimem_r","semiten_r","bifemlh_r"];
hipFleMuscles_H = ["add_brev_r","add_long_r","glut_med1_r","glut_min1_r","grac_r","iliacus_r",...
    "psoas_r","rect_fem_r","sar_r","tfl_r","pect_r"];

kneeExtMuscles_H = ["rect_fem_r","vas_int_r","vas_lat_r","vas_med_r"];
kneeFleMuscles_H = ["bifemlh_r","bifemsh_r","grac_r","lat_gas_r","med_gas_r",...
    "sar_r","semimem_r","semiten_r"];

ankleExtMuscles_H = ["flex_dig_r","flex_hal_r","lat_gas_r","med_gas_r","per_brev_r",...
    "per_long_r","soleus_r","tib_post_r"];
ankleFleMuscles_H = ["ext_dig_r","ext_hal_r","per_tert_r","tib_ant_r"];


[passiveHipMoments_R,passiveHipAngles_R] = computeIsometricPassiveMoments(model_R,hip_angles,knee_angle,hip,knee,hipFleMuscles,hipExtMuscles);
[passiveHipMoments_RLU,passiveHipAngles_RLU] = computeIsometricPassiveMoments(model_RLU,hip_angles,knee_angle,hip,knee,hipFleMuscles,hipExtMuscles);
[passiveHipMoments_R_DGF,passiveHipAngles_R_DGF] = computeIsometricPassiveMoments(model_R_DGF,hip_angles,knee_angle,hip,knee,hipFleMuscles,hipExtMuscles);
[passiveHipMoments_RLU_DGF,passiveHipAngles_RLU_DGF] = computeIsometricPassiveMoments(model_RLU_DGF,hip_angles,knee_angle,hip,knee,hipFleMuscles,hipExtMuscles);
[passiveHipMoments_R_strong,passiveHipAngles_R_strong] = computeIsometricPassiveMoments(model_R_strong,hip_angles,knee_angle,hip,knee,hipFleMuscles,hipExtMuscles);

figure();
set(gcf, 'Position', get(0, 'Screensize'));
plot(passiveHipAngles_R,passiveHipMoments_R,'k','LineWidth',2.5);
hold on
plot(passiveHipAngles_RLU,passiveHipMoments_RLU,'r','LineWidth',2.5,'LineStyle','-');
plot(passiveHipAngles_R_DGF,passiveHipMoments_R_DGF,'b','LineWidth',2.5,'LineStyle','--');
plot(passiveHipAngles_RLU_DGF,passiveHipMoments_RLU_DGF,'r','LineWidth',2.5,'LineStyle','--');
plot(passiveHipAngles_R_strong,passiveHipMoments_R_strong,'g','LineWidth',2.5,'LineStyle','--');
plot(hip_angles,passive_hip_moments_RE,'c','LineWidth',2.5,'LineStyle','--');
xlabel('Joint Angle (deg)',FontWeight='bold');
ylabel('Passive Hip Flexion-Extension Moment (Nm)',FontWeight='bold');
legend({'Rajagopal2016','RajagopalLaiUhlrich2023','Rajagopal2016-DGF','RajagopalLaiUhlrich2023-DGF','Rajagopal2016-strong','RienerEdrich1999'},'Box','off')
set(gca, 'FontSize', 20);
set(gca, 'Box', 'off');
set(gca, 'LineWidth', 2.5);

if strcmp(save_plot,'Yes')
    filename = 'Plots/passive_hip_moments.png';
    saveas(gcf, filename, 'png');
end

[passiveKneeMoments_R,passiveKneeAngles_R] = computeIsometricPassiveMoments(model_R,knee_angles,hip_angle,knee,hip,kneeFleMuscles,kneeExtMuscles);
[passiveKneeMoments_RLU,passiveKneeAngles_RLU] = computeIsometricPassiveMoments(model_RLU,knee_angles,hip_angle,knee,hip,kneeFleMuscles,kneeExtMuscles);
[passiveKneeMoments_R_DGF,passiveKneeAngles_R_DGF] = computeIsometricPassiveMoments(model_R_DGF,knee_angles,hip_angle,knee,hip,kneeFleMuscles,kneeExtMuscles);
[passiveKneeMoments_RLU_DGF,passiveKneeAngles_RLU_DGF] = computeIsometricPassiveMoments(model_RLU_DGF,knee_angles,hip_angle,knee,hip,kneeFleMuscles,kneeExtMuscles);
[passiveKneeMoments_R_strong,passiveKneeAngles_R_strong] = computeIsometricPassiveMoments(model_R_strong,knee_angles,hip_angle,knee,hip,kneeFleMuscles,kneeExtMuscles);

figure;
set(gcf, 'Position', get(0, 'Screensize'));
plot(passiveKneeAngles_R,passiveKneeMoments_R,'k','LineWidth',2.5);
hold on
plot(passiveKneeAngles_RLU,passiveKneeMoments_RLU,'r','LineWidth',2.5,'LineStyle','-');
plot(passiveKneeAngles_R_DGF,passiveKneeMoments_R_DGF,'b','LineWidth',2.5,'LineStyle','--');
plot(passiveKneeAngles_RLU_DGF,passiveKneeMoments_RLU_DGF,'r','LineWidth',2.5,'LineStyle','--');
plot(passiveKneeAngles_R_strong,passiveKneeMoments_R_strong,'g','LineWidth',2.5,'LineStyle','--');
plot(knee_angles,passive_knee_moments_RE,'c','LineWidth',2.5,'LineStyle','--');
xlabel('Joint Angle (deg)',FontWeight='bold');
ylabel('Passive Knee Flexion-Extension Moment (Nm)',FontWeight='bold');
legend({'Rajagopal2016','RajagopalLaiUhlrich2023','Rajagopal2016-DGF','RajagopalLaiUhlrich2023-DGF','Rajagopal2016-strong','RienerEdrich1999'},'Box','off')
set(gca, 'FontSize', 20);
set(gca, 'Box', 'off');
set(gca, 'LineWidth', 2.5);

if strcmp(save_plot,'Yes')
    filename = 'Plots/passive_knee_moments.png';
    saveas(gcf, filename, 'png');
end

[passiveAnkleMoments_R,passiveAnkleAngles_R] = computeIsometricPassiveMoments(model_R,ankle_angles,fixed_knee_ankle,ankle,knee,ankleFleMuscles,ankleExtMuscles);
[passiveAnkleMoments_RLU,passiveAnkleAngles_RLU] = computeIsometricPassiveMoments(model_RLU,ankle_angles,fixed_knee_ankle,ankle,knee,ankleFleMuscles,ankleExtMuscles);
[passiveAnkleMoments_R_DGF,passiveAnkleAngles_R_DGF] = computeIsometricPassiveMoments(model_R_DGF,ankle_angles,fixed_knee_ankle,ankle,knee,ankleFleMuscles,ankleExtMuscles);
[passiveAnkleMoments_RLU_DGF,passiveAnkleAngles_RLU_DGF] = computeIsometricPassiveMoments(model_RLU_DGF,ankle_angles,fixed_knee_ankle,ankle,knee,ankleFleMuscles,ankleExtMuscles);
[passiveAnkleMoments_R_strong,passiveAnkleAngles_R_strong] = computeIsometricPassiveMoments(model_R_strong,ankle_angles,fixed_knee_ankle,ankle,knee,ankleFleMuscles,ankleExtMuscles);

figure;
set(gcf, 'Position', get(0, 'Screensize'));
plot(passiveAnkleAngles_R,passiveAnkleMoments_R,'k','LineWidth',2.5);
hold on
plot(passiveAnkleAngles_RLU,passiveAnkleMoments_RLU,'r','LineWidth',2.5,'LineStyle','-');
plot(passiveAnkleAngles_R_DGF,passiveAnkleMoments_R_DGF,'b','LineWidth',2.5,'LineStyle','--');
plot(passiveAnkleAngles_RLU_DGF,passiveAnkleMoments_RLU_DGF,'r','LineWidth',2.5,'LineStyle','--');
plot(passiveAnkleAngles_R_strong,passiveAnkleMoments_R_strong,'g','LineWidth',2.5,'LineStyle','--');
plot(ankle_angles,passive_ankle_moments_RE,'c','LineWidth',2.5,'LineStyle','--');
xlabel('Joint Angle (deg)',FontWeight='bold');
ylabel('Passive Ankle Dorsiflexion-Plantarflexion Moment (Nm)',FontWeight='bold');
legend({'Rajagopal2016','RajagopalLaiUhlrich2023','Rajagopal2016-DGF','RajagopalLaiUhlrich2023-DGF','Rajagopal2016-strong','RienerEdrich1999'},'Box','off')
set(gca, 'FontSize', 20);
set(gca, 'Box', 'off');
set(gca, 'LineWidth', 2.5);

if strcmp(save_plot,'Yes')
    filename = 'Plots/passive_ankle_moments.png';
    saveas(gcf, filename, 'png');
end

[allHipFlexMoments_R,allHipFlexAngles_R] = computeIsometricMoments(model_R,hip_angles,knee_angle,hip,knee,hipFleMuscles,hipExtMuscles);
[allHipExtMoments_R,allHipExtAngles_R] = computeIsometricMoments(model_R,hip_angles,knee_angle,hip,knee,hipExtMuscles,hipFleMuscles);
[allHipFlexMoments_RLU,allHipFlexAngles_RLU] = computeIsometricMoments(model_RLU,hip_angles,knee_angle,hip,knee,hipFleMuscles,hipExtMuscles);
[allHipExtMoments_RLU,allHipExtAngles_RLU] = computeIsometricMoments(model_RLU,hip_angles,knee_angle,hip,knee,hipExtMuscles,hipFleMuscles);
[allHipFlexMoments_R_DGF,allHipFlexAngles_R_DGF] = computeIsometricMoments(model_R_DGF,hip_angles,knee_angle,hip,knee,hipFleMuscles,hipExtMuscles);
[allHipExtMoments_R_DGF,allHipExtAngles_R_DGF] = computeIsometricMoments(model_R_DGF,hip_angles,knee_angle,hip,knee,hipExtMuscles,hipFleMuscles);
[allHipFlexMoments_RLU_DGF,allHipFlexAngles_RLU_DGF] = computeIsometricMoments(model_RLU_DGF,hip_angles,knee_angle,hip,knee,hipFleMuscles,hipExtMuscles);
[allHipExtMoments_RLU_DGF,allHipExtAngles_RLU_DGF] = computeIsometricMoments(model_RLU_DGF,hip_angles,knee_angle,hip,knee,hipExtMuscles,hipFleMuscles);
[allHipFlexMoments_R_strong,allHipFlexAngles_R_strong] = computeIsometricMoments(model_R_strong,hip_angles,knee_angle,hip,knee,hipFleMuscles,hipExtMuscles);
[allHipExtMoments_R_strong,allHipExtAngles_R_strong] = computeIsometricMoments(model_R_strong,hip_angles,knee_angle,hip,knee,hipExtMuscles,hipFleMuscles);

[allHipFlexMoments_H_strong,allHipFlexAngles_H_strong] = computeIsometricMoments(model_H_strong,hip_angles,-knee_angle,hip,knee,hipFleMuscles_H,hipExtMuscles_H);
[allHipExtMoments_H_strong,allHipExtAngles_H_strong] = computeIsometricMoments(model_H_strong,hip_angles,-knee_angle,hip,knee,hipExtMuscles_H,hipFleMuscles_H);

figure;
set(gcf, 'Position', get(0, 'Screensize'));
plot(allHipFlexAngles_R,allHipFlexMoments_R,'k','LineWidth',2.5);
hold on
plot(allHipFlexAngles_RLU,allHipFlexMoments_RLU,'r','LineWidth',2.5,'LineStyle','-');
plot(allHipFlexAngles_R_DGF,allHipFlexMoments_R_DGF,'b','LineWidth',2.5,'LineStyle','--');
plot(allHipFlexAngles_RLU_DGF,allHipFlexMoments_RLU_DGF,'r','LineWidth',2.5,'LineStyle','--');
plot(allHipFlexAngles_R_strong,allHipFlexMoments_R_strong,'g','LineWidth',2.5,'LineStyle','--');
plot(allHipFlexAngles_H_strong,allHipFlexMoments_H_strong,'c','LineWidth',2.5,'LineStyle','-');
plot(allHipExtAngles_R,allHipExtMoments_R,'k','LineWidth',2.5);
plot(allHipExtAngles_RLU,allHipExtMoments_RLU,'r','LineWidth',2.5,'LineStyle','-');
plot(allHipExtAngles_R_DGF,allHipExtMoments_R_DGF,'b','LineWidth',2.5,'LineStyle','--');
plot(allHipExtAngles_RLU_DGF,allHipExtMoments_RLU_DGF,'r','LineWidth',2.5,'LineStyle','--');
plot(allHipExtAngles_R_strong,allHipExtMoments_R_strong,'g','LineWidth',2.5,'LineStyle','--');
plot(allHipExtAngles_H_strong,allHipExtMoments_H_strong,'c','LineWidth',2.5,'LineStyle','-');
xlabel('Joint Angle (deg)',FontWeight='bold');
ylabel('Hip Flexion-Extension Moment (Nm)',FontWeight='bold');
legend({'Rajagopal2016','RajagopalLaiUhlrich2023','Rajagopal2016-DGF','RajagopalLaiUhlrich2023-DGF','Rajagopal2016-strong','Hamner2010-strong'},'Box','off')
set(gca, 'FontSize', 20);
set(gca, 'Box', 'off');
set(gca, 'LineWidth', 2.5);

if strcmp(save_plot,'Yes')
    filename = 'Plots/active_passive_hip_moments.png';
    saveas(gcf, filename, 'png');
end

[allKneeFlexMoments_R,allKneeFlexAngles_R] = computeIsometricMoments(model_R,knee_angles,hip_angle,knee,hip,kneeFleMuscles,kneeExtMuscles);
[allKneeExtMoments_R,allKneeExtAngles_R] = computeIsometricMoments(model_R,knee_angles,hip_angle,knee,hip,kneeExtMuscles,kneeFleMuscles);
[allKneeFlexMoments_RLU,allKneeFlexAngles_RLU] = computeIsometricMoments(model_RLU,knee_angles,hip_angle,knee,hip,kneeFleMuscles,kneeExtMuscles);
[allKneeExtMoments_RLU,allKneeExtAngles_RLU] = computeIsometricMoments(model_RLU,knee_angles,hip_angle,knee,hip,kneeExtMuscles,kneeFleMuscles);
[allKneeFlexMoments_R_DGF,allKneeFlexAngles_R_DGF] = computeIsometricMoments(model_R_DGF,knee_angles,hip_angle,knee,hip,kneeFleMuscles,kneeExtMuscles);
[allKneeExtMoments_R_DGF,allKneeExtAngles_R_DGF] = computeIsometricMoments(model_R_DGF,knee_angles,hip_angle,knee,hip,kneeExtMuscles,kneeFleMuscles);
[allKneeFlexMoments_RLU_DGF,allKneeFlexAngles_RLU_DGF] = computeIsometricMoments(model_RLU_DGF,knee_angles,hip_angle,knee,hip,kneeFleMuscles,kneeExtMuscles);
[allKneeExtMoments_RLU_DGF,allKneeExtAngles_RLU_DGF] = computeIsometricMoments(model_RLU_DGF,knee_angles,hip_angle,knee,hip,kneeExtMuscles,kneeFleMuscles);
[allKneeFlexMoments_R_strong,allKneeFlexAngles_R_strong] = computeIsometricMoments(model_R_strong,knee_angles,hip_angle,knee,hip,kneeFleMuscles,kneeExtMuscles);
[allKneeExtMoments_R_strong,allKneeExtAngles_R_strong] = computeIsometricMoments(model_R_strong,knee_angles,hip_angle,knee,hip,kneeExtMuscles,kneeFleMuscles);

[allKneeFlexMoments_H_strong,allKneeFlexAngles_H_strong] = computeIsometricMoments(model_H_strong,-knee_angles,hip_angle,knee,hip,kneeFleMuscles_H,kneeExtMuscles_H);
[allKneeExtMoments_H_strong,allKneeExtAngles_H_strong] = computeIsometricMoments(model_H_strong,-knee_angles,hip_angle,knee,hip,kneeExtMuscles_H,kneeFleMuscles_H);

figure;
set(gcf, 'Position', get(0, 'Screensize'));
plot(allKneeFlexAngles_R,allKneeFlexMoments_R,'k','LineWidth',2.5);
hold on
plot(allKneeFlexAngles_RLU,allKneeFlexMoments_RLU,'r','LineWidth',2.5,'LineStyle','-');
plot(allKneeFlexAngles_R_DGF,allKneeFlexMoments_R_DGF,'b','LineWidth',2.5,'LineStyle','--');
plot(allKneeFlexAngles_RLU_DGF,allKneeFlexMoments_RLU_DGF,'r','LineWidth',2.5,'LineStyle','--');
plot(allKneeFlexAngles_R_strong,allKneeFlexMoments_R_strong,'g','LineWidth',2.5,'LineStyle','--');
plot(-allKneeFlexAngles_H_strong,allKneeFlexMoments_H_strong,'c','LineWidth',2.5,'LineStyle','-');
plot(allKneeExtAngles_R,allKneeExtMoments_R,'k','LineWidth',2.5);
plot(allKneeExtAngles_RLU,allKneeExtMoments_RLU,'r','LineWidth',2.5,'LineStyle','-');
plot(allKneeExtAngles_R_DGF,allKneeExtMoments_R_DGF,'b','LineWidth',2.5,'LineStyle','--');
plot(allKneeExtAngles_RLU_DGF,allKneeExtMoments_RLU_DGF,'r','LineWidth',2.5,'LineStyle','--');
plot(allKneeExtAngles_R_strong,allKneeExtMoments_R_strong,'g','LineWidth',2.5,'LineStyle','--');
plot(-allKneeExtAngles_H_strong,allKneeExtMoments_H_strong,'c','LineWidth',2.5,'LineStyle','-');
xlabel('Joint Angle (deg)',FontWeight='bold');
ylabel('Knee Flexion-Extension Moment (Nm)',FontWeight='bold');
legend({'Rajagopal2016','RajagopalLaiUhlrich2023','Rajagopal2016-DGF','RajagopalLaiUhlrich2023-DGF','Rajagopal2016-strong','Hamner2010-strong'},'Box','off')
set(gca, 'FontSize', 20);
set(gca, 'Box', 'off');
set(gca, 'LineWidth', 2.5);

if strcmp(save_plot,'Yes')
    filename = 'Plots/active_passive_knee_moments.png';
    saveas(gcf, filename, 'png');
end

[allAnkleFlexMoments_R,allAnkleFlexAngles_R] = computeIsometricMoments(model_R,ankle_angles,fixed_knee_ankle,ankle,knee,ankleFleMuscles,ankleExtMuscles);
[allAnkleExtMoments_R,allAnkleExtAngles_R] = computeIsometricMoments(model_R,ankle_angles,fixed_knee_ankle,ankle,knee,ankleExtMuscles,ankleFleMuscles);
[allAnkleFlexMoments_RLU,allAnkleFlexAngles_RLU] = computeIsometricMoments(model_RLU,ankle_angles,fixed_knee_ankle,ankle,knee,ankleFleMuscles,ankleExtMuscles);
[allAnkleExtMoments_RLU,allAnkleExtAngles_RLU] = computeIsometricMoments(model_RLU,ankle_angles,fixed_knee_ankle,ankle,knee,ankleExtMuscles,ankleFleMuscles);
[allAnkleFlexMoments_R_DGF,allAnkleFlexAngles_R_DGF] = computeIsometricMoments(model_R_DGF,ankle_angles,fixed_knee_ankle,ankle,knee,ankleFleMuscles,ankleExtMuscles);
[allAnkleExtMoments_R_DGF,allAnkleExtAngles_R_DGF] = computeIsometricMoments(model_R_DGF,ankle_angles,fixed_knee_ankle,ankle,knee,ankleExtMuscles,ankleFleMuscles);
[allAnkleFlexMoments_RLU_DGF,allAnkleFlexAngles_RLU_DGF] = computeIsometricMoments(model_RLU_DGF,ankle_angles,fixed_knee_ankle,ankle,knee,ankleFleMuscles,ankleExtMuscles);
[allAnkleExtMoments_RLU_DGF,allAnkleExtAngles_RLU_DGF] = computeIsometricMoments(model_RLU_DGF,ankle_angles,fixed_knee_ankle,ankle,knee,ankleExtMuscles,ankleFleMuscles);
[allAnkleFlexMoments_R_strong,allAnkleFlexAngles_R_strong] = computeIsometricMoments(model_R_strong,ankle_angles,fixed_knee_ankle,ankle,knee,ankleFleMuscles,ankleExtMuscles);
[allAnkleExtMoments_R_strong,allAnkleExtAngles_R_strong] = computeIsometricMoments(model_R_strong,ankle_angles,fixed_knee_ankle,ankle,knee,ankleExtMuscles,ankleFleMuscles);

[allAnkleFlexMoments_H_strong,allAnkleFlexAngles_H_strong] = computeIsometricMoments(model_H_strong,ankle_angles,-fixed_knee_ankle,ankle,knee,ankleFleMuscles_H,ankleExtMuscles_H);
[allAnkleExtMoments_H_strong,allAnkleExtAngles_H_strong] = computeIsometricMoments(model_H_strong,ankle_angles,-fixed_knee_ankle,ankle,knee,ankleExtMuscles_H,ankleFleMuscles_H);

figure;
set(gcf, 'Position', get(0, 'Screensize'));
plot(allAnkleFlexAngles_R,allAnkleFlexMoments_R,'k','LineWidth',2.5);
hold on
plot(allAnkleFlexAngles_RLU,allAnkleFlexMoments_RLU,'r','LineWidth',2.5,'LineStyle','-');
plot(allAnkleFlexAngles_R_DGF,allAnkleFlexMoments_R_DGF,'b','LineWidth',2.5,'LineStyle','--');
plot(allAnkleFlexAngles_RLU_DGF,allAnkleFlexMoments_RLU_DGF,'r','LineWidth',2.5,'LineStyle','--');
plot(allAnkleFlexAngles_R_strong,allAnkleFlexMoments_R_strong,'g','LineWidth',2.5,'LineStyle','--');
plot(allAnkleFlexAngles_H_strong,allAnkleFlexMoments_H_strong,'c','LineWidth',2.5,'LineStyle','-');
plot(allAnkleExtAngles_R,allAnkleExtMoments_R,'k','LineWidth',2.5);
plot(allAnkleExtAngles_RLU,allAnkleExtMoments_RLU,'r','LineWidth',2.5,'LineStyle','-');
plot(allAnkleExtAngles_R_DGF,allAnkleExtMoments_R_DGF,'b','LineWidth',2.5,'LineStyle','--');
plot(allAnkleExtAngles_RLU_DGF,allAnkleExtMoments_RLU_DGF,'r','LineWidth',2.5,'LineStyle','--');
plot(allAnkleExtAngles_R_strong,allAnkleExtMoments_R_strong,'g','LineWidth',2.5,'LineStyle','--');
plot(allAnkleExtAngles_H_strong,allAnkleExtMoments_H_strong,'c','LineWidth',2.5,'LineStyle','-');
xlabel('Joint Angle (deg)',FontWeight='bold');
ylabel('Ankle Dorsiflexion-Plantarflexion Moment (Nm)',FontWeight='bold');
legend({'Rajagopal2016','RajagopalLaiUhlrich2023','Rajagopal2016-DGF','RajagopalLaiUhlrich2023-DGF','Rajagopal2016-strong','Hamner2010-strong'},'Box','off')
set(gca, 'FontSize', 20);
set(gca, 'Box', 'off');
set(gca, 'LineWidth', 2.5);

if strcmp(save_plot,'Yes')
    filename = 'Plots/active_passive_ankle_moments.png';
    saveas(gcf, filename, 'png');
end







