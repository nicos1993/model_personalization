function [passive_hip,passive_ankle,passive_knee] = RienerEdrich_PassiveMoments(angles_hip,fixed_knee,angles_ankle,fixed_knee2,angles_knee,fixed_hip)

% Passive moments based on Riener & Edrich 1999 JoB

% Expects angles in degrees
passive_hip = exp(1.4655 - 0.0034.*fixed_knee - 0.0750.*angles_hip)...
    - exp(1.3403 - 0.0226.*fixed_knee + 0.0305.*angles_hip) + 8.072;

passive_ankle = exp(2.1016 - 0.0843.*angles_ankle - 0.0176.*fixed_knee2)...
    - exp(-7.9763 + 0.1949.*angles_ankle + 0.0008.*fixed_knee2) -1.792;

fixed_ankle = 0;
passive_knee = exp(1.800 - 0.0460*fixed_ankle - 0.0352.*angles_knee + 0.0217*fixed_hip)...
    - exp(-3.971 - 0.0004*fixed_ankle + 0.0495.*angles_knee - 0.0128*fixed_hip)...
    - 4.820 + exp(2.220 - 0.150.*angles_knee);

end