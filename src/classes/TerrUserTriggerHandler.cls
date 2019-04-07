/*
 * Created by Дмитро on 04.04.2019.
 */
public class TerrUserTriggerHandler {
	public static void afterInsert(List<SObject> newTerritory){
		insert shareAccessToUser(newTerritory);
	}

	public static void afterDelete(List<SObject> oldTerritory) {
		delete deleteShareAccessToUser(oldTerritory);
	}

	private static List<sObject> shareAccessToUser(List<SObject> newTerritory){
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

	private static List<sObject> deleteShareAccessToUser(List<sObject> oldTerritory){
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
}