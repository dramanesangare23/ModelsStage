include "alldifferent.mzn";

%ensemble des vehicules therminques
int : nbreVehiculeThermique;
set of int: VehiculeThermiques = 1..nbreVehiculeThermique;
array[VehiculeThermiques] of int : identifiantVT;

%L'ensemble de tous les vehicules
set of int : lesVehicules;

% variables : quel vehicule affecter a quelle tournee
array[Tournees] of var lesVehicules : tourneeVehicule;
array[Tournees] of var 0..max(distanceTournee) : kmElec;

%Les contraintes minizinc sur les variables

%ensemble des vehicules electriques
int : nbreVehiculeElectrique;
set of int : VehiculeElectriques = 1..nbreVehiculeElectrique;
array[VehiculeElectriques] of int : identifiantVE;
%autonomie de chaque VE
array[VehiculeElectriques] of int : autonomie;
%niveau de batterie de chaque VE
array[VehiculeElectriques] of int : niveauBatterie;

%nbre de tournees
int : nbreTournee;
set of int : Tournees = 1..nbreTournee;
%distance de chaque tournee
array[Tournees] of int : distanceTournee;


% Un vehicule par tournee
constraint alldifferent(tourneeVehicule);
% L'autonomie et le niveau de batterie du VE sont suffisants pour effectuer la tournee
constraint forall(t in Tournees)(
	forall(ve in VehiculeElectriques)(
		(tourneeVehicule[t] = identifiantVE[ve]) -> 
		(	autonomie[ve] * niveauBatterie[ve] > distanceTournee[t]
		 /\ kmElec[t] = distanceTournee[t])
	)
);

% affectation d'un vehicule thermique et dans ce cas kmElec est nul
constraint forall(t in Tournees)(
	forall(vt in VehiculeThermiques)(
		tourneeVehicule[t] = identifiantVT[vt] -> kmElec[t] = 0
	)
);

%maximiser le nombre de km de tounrnee fait par les vehicules electriques
solve maximize sum([kmElec[t] | t in Tournees]);


%affichage
output
[show("\n----------------------------------------------------------------------------------------------")] ++
[show("\nAux tournees suivantes (distances) sont affectes des vehicules electriques : ")] ++
[show(t in Tournees where kmElec[t] != 0)(distanceTournee[t])]++
[show("\nAux tournees suivantes (distances) sont affectes des vehicules thermiques : ")] ++
[show(i in Tournees where kmElec[i] = 0)(distanceTournee[i])]++
[show("\n----------------------------------------------------------------------------------------------")] ++
["\nLes vehicules electriques parcourent ", show(sum(t in Tournees)(kmElec[t])), " km"]++
["\nLes vehicules thermiques parcourent ", show(sum(t in Tournees)(distanceTournee[t])-sum(t in Tournees)(kmElec[t])), " km"]++
[show("\n----------------------------------------------------------------------------------------------")] ++
[show("\nLes affectations : \n")]++
[show("DistTournee = ")]++[show_int(3, distanceTournee[t]) ++ "  " | t in Tournees, ]++[show("\n")]++
[show("Vehicule ID = ")]++[show_int(3, tourneeVehicule[t]) ++ "  " | t in Tournees]
;

