/**
 * Created by Дмитро on 27.03.2019.
 */

public with sharing class TerritoryTriggerHandler {

    public static void beforeUpdate(List<SObject> newTerritory){
        TerritoryTriggerService.isUniqueTerritoryName(newTerritory);
    }

}