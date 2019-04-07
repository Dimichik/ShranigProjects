/*
 * Created by Дмитро on 05.04.2019.
 */
@isTest
public class TestTerritoryUserService {

	@IsTest(SeeAllData=true)
	static void createTerritoryUserMapTest(){
		List<TerrUser__c> terrUserList = [SELECT Id, User__c, Territory__c FROM TerrUser__c];
		System.assert(terrUserList.size() != 0);
		Map<Id, List<Id>> terrUserMap = new Map<Id, List<Id>>();
		Set<Id> users = new Set<Id>();
		for (TerrUser__c terrUser : terrUserList) {
			users.add(terrUser.User__c);
		}
		for (Id tempUserId : users) {
			terrUserMap.put(tempUserId, getTerritory(tempUserId, terrUserList));
		}
		System.debug(terrUserMap.values());
		System.assert(terrUserMap.size() != 0);
	}

	private static List<Id> getTerritory(Id userId, List<TerrUser__c> terrUserList) {
		List<Id> territoryList = new List<Id>();
		for (TerrUser__c terrUser : terrUserList) {
			if (terrUser.User__c == userId) {
				territoryList.add(terrUser.Territory__c);
			}
		}
		return territoryList;
	}

	@IsTest(SeeAllData = true)
	private static void getAllTerritory() {
		Id parentId = [
				SELECT Id, Name
				FROM Territory__c
				WHERE Name = 'Ukraine'
				LIMIT 1
		].Id;
		List<Territory__c> concreteResult = getAllChildsForParenTerritory(new Set<Id>{parentId});
		System.debug('concreteResult = ' + concreteResult);
	}

	private static List<Territory__c> getAllChildsForParenTerritory(Set<Id> parentId) {
		List<Territory__c> result = [SELECT Id, Name FROM Territory__c WHERE ParTerritory__c IN :parentId];
		if (result.size() > 0) {
			Set<Id> childsIds = getSetFromList(result, 'Id');
			result.addAll(getAllChildsForParenTerritory(childsIds));
			System.debug('childsIds = ' + result);
		}

		return result;
	}

	private static Set<Id> getSetFromList(List<sObject> listObjs, String searchField) {
		Set<Id> result = new Set<Id>();
		for (sObject curentSO : listObjs) {
			result.add((Id) curentSO.get(searchField));
		}
		return result;
	}
}