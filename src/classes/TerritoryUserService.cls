/*
 * Created by Дмитро on 05.04.2019.
 */
public class TerritoryUserService {

	public static Map<Id, List<Id>> createTerritoryUserMap(List<sObject> terrUsers) {
		List<TerrUser__c> terrUserList = (List<TerrUser__c>) terrUsers;
		Map<Id, List<Id>> terrUserMap = new Map<Id, List<Id>>();
		Set<Id> users = new Set<Id>();
		for (TerrUser__c terrUser : terrUserList) {
			users.add(terrUser.User__c);
		}
		for (Id userId : users) {
			terrUserMap.put(userId, getTerritory(userId, terrUserList));
		}
		return terrUserMap;
	}

	public static List<Territory__c> getAllTerritory(List<id> territoryId) {
		List<Territory__c> territoryList = [SELECT id FROM Territory__c WHERE Id IN :territoryId];
		List<Territory__c> allChilds = getAllChildsFromParenTerritory(getSetFromList(territoryList, 'Id'));
		allChilds.addAll(territoryList);
		return allChilds;
	}

	public static List<sObject> shareAccessToUser(List<SObject> newTerritory){
		List<sObject> allShares = new List<sObject>();
		Map<Id, List<Id>> userTerrMap = TerritoryUserService.createTerritoryUserMap(newTerritory);
		for	(Id userId : userTerrMap.keySet()){
			List<Territory__c> territories = TerritoryUserService.getAllTerritory(userTerrMap.get(userId));
			List<Account> accounts = [SELECT Id FROM Account WHERE Territory__c IN :territories];
			List<AccountShare> accountsUserShares = AccountSharingService.shareAccessToAccount(accounts, userId);
			allShares.addAll(accountsUserShares);
			List<Contact__Share> contactsUserShares = ContactSharingService.shareAccessToContact(accounts, userId);
			allShares.addAll(contactsUserShares);
		}
		return allShares;
	}

	public static List<sObject> deleteShareAccessToUser(List<sObject> oldTerritory){
		List<sObject> allShares = new List<sObject>();
		Map<Id, List<Id>> userTerrMap = TerritoryUserService.createTerritoryUserMap(oldTerritory);
		for	(Id userId : userTerrMap.keySet()){
			List<Territory__c> territories = TerritoryUserService.getAllTerritory(userTerrMap.get(userId));
			List<Account> accounts = [SELECT Id FROM Account WHERE Territory__c IN :territories];
			List<AccountShare> accountsUserShares = AccountSharingService.deleteAccessToAccount(accounts, userId);
			allShares.addAll(accountsUserShares);
			List<Contact__Share> contactsUserShares = ContactSharingService.deleteAccessToContact(accounts, userId);
			allShares.addAll(contactsUserShares);
		}
		return allShares;
	}

	private static List<Territory__c> getAllChildsFromParenTerritory(Set<Id> parentId) {
		List<Territory__c> result = [
				SELECT Id
				FROM Territory__c
				WHERE ParTerritory__c IN :parentId
		];
		if (result.size() > 0) {
			Set<Id> childsIds = getSetFromList(result, 'Id');
			result.addAll(getAllChildsFromParenTerritory(childsIds));
		}
		return result;
	}

	private static Set<Id> getSetFromList(List<sObject> listObjects, String searchField) {
		Set<Id> result = new Set<Id>();
		for (sObject currentSObject : listObjects) {
			result.add((Id) currentSObject.get(searchField));
		}
		return result;
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
}