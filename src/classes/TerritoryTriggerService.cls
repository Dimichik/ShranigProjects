public class TerritoryTriggerService {

    public static void isUnique(List<SObject> newTerritories) {
        List<Territory__c> insertedTerritories = (List<Territory__c>) newTerritories;
        Set<Id> parentIds = getSetIdsFromList(newTerritories, 'ParTerritory__c');
        List<Territory__c> existingRecords = [
                SELECT Id
                        , Name
                FROM Territory__c
                WHERE ParTerritory__c IN :parentIds
        ];
        Set<String> existingTerrNames = getExistingTerrNames(existingRecords);

        for (Territory__c territory : insertedTerritories) {
                if (existingTerrNames.contains(territory.Name)) {
                    territory.addError('You already have ' + territory.Name);
            }
        }
    }

    private static Set<String> getExistingTerrNames(List<Territory__c> existedTerritories) {
        Set<String> existingTerrNames = new Set<String>();
        for (Territory__c currentTerritory : existedTerritories) {
            existingTerrNames.add(currentTerritory.Name);
        }
        return existingTerrNames;
    }

    private static Set<Id> getSetIdsFromList(List<SObject> inputList, String fieldName) {
        Set<Id> resIds = new Set<Id>();
        for (SObject sobj : inputList) {
            resIds.add((Id) sobj.get(fieldName));
        }
        return resIds;
    }
}