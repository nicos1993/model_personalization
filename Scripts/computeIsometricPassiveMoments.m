function [moments, angles] = computeIsometricPassiveMoments(model,angles,fixed_angle,coord_name,fixed_coord_name,fle_muscles,ext_muscles)

import org.opensim.modeling.*

coord = model.getCoordinateSet.get(coord_name);
fixed_coord = model.getCoordinateSet.get(fixed_coord_name);

state = model.initSystem;

muscleNames = ArrayStr();
model.getMuscles.getNames(muscleNames);

for k = 0:model.getMuscles.getSize-1
    if ~any(strcmp(fle_muscles,string(muscleNames.get(k))))
        model.getMuscles.get(k).setActivation(state,0.01);
    elseif any(strcmp(fle_muscles,string(muscleNames.get(k))))
        model.getMuscles.get(k).setActivation(state,0.01);
    end
end

passive_moments = zeros(length(angles),1);

muscle_all = 1;

muscleModel_type = string(model.getMuscles.get(0).getConcreteClassName());

for c = 1:length(angles)
    coord.setValue(state,deg2rad(angles(c)));
    fixed_coord.setValue(state,deg2rad(fixed_angle));


    try
        model.equilibrateMuscles(state);
    
        for m = 1:muscleNames.size
            if any(strcmp([fle_muscles ext_muscles],string(muscleNames.get(m-1))))
                thisMuscle = eval(muscleModel_type).safeDownCast(model.getMuscles.get(muscleNames.get(m-1)));
                mtu_length(muscle_all,c) = thisMuscle.getLength(state);
                moment_arm(muscle_all,c) = thisMuscle.computeMomentArm(state,coord);
                norm_fiber_length(muscle_all,c) = thisMuscle.getNormalizedFiberLength(state);
                tendon_force(muscle_all,c) = thisMuscle.getTendonForce(state);
                passive_force(muscle_all,c) = thisMuscle.getPassiveFiberForceAlongTendon(state);
                passive_moments(c) = passive_moments(c) + moment_arm(muscle_all,c)*passive_force(muscle_all,c);
    
                muscle_all = muscle_all + 1;
            end
        end

    catch

        for m = 1:muscleNames.size
            if any(strcmp([fle_muscles ext_muscles],string(muscleNames.get(m-1))))
                %thisMuscle = eval(muscleModel_type).safeDownCast(model.getMuscles.get(muscleNames.get(m-1)));
                mtu_length(muscle_all,c) = 0;
                moment_arm(muscle_all,c) = 0;
                norm_fiber_length(muscle_all,c) = 0;
                tendon_force(muscle_all,c) = 0;
                passive_force(muscle_all,c) = 0;
                passive_moments(c) = 0;
    
                muscle_all = muscle_all + 1;
            end
        end

    end

    muscle_all = 1;
end

zero_inds = find(passive_moments==0);

if ~isempty(zero_inds)
    passive_moments(zero_inds) = [];
    angles(zero_inds) = [];
end

moments = passive_moments;


end