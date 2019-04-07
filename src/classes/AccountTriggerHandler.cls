/*
 * Created by Дмитро on 07.04.2019.
 */
public class AccountTriggerHandler {

	public static void beforeUpdate(List<SObject> newTerritory) {
		List<Account> accountToDelete = AccountTriggerService.changedTerritory(newTerritory);
		List<AccountShare> accShare = AccountTriggerService.deleteSharesAccount(accountToDelete);
		List<Contact__Share> contractShares = ContactSharingService.deleteAccessToContact(accountToDelete);
		if (!accShare.isEmpty()) {
			Database.Delete(accShare, false);
		}
		if (!contractShares.isEmpty()) {
			Database.Delete(contractShares, false);
		}
	}

	public static void afterUpdate(List<SObject> changedAccounts) {
		System.debug('afterUpdate');
		List<sObject> allShares = new List<sObject>();
		System.debug('changedAccounts = ' + changedAccounts);
		List<Account> changedTerritories = AccountTriggerService.changedTerritory(changedAccounts);
		System.debug('changedTerritories = ' + changedTerritories);
		List<Account> accountToRecalculateSharing = new List<Account>();
		for (Account acc : changedTerritories) {
			if (acc.Territory__c != null) {
				accountToRecalculateSharing.add(acc);
			}
		}
		System.debug('accountToRecalculateSharing = ' + accountToRecalculateSharing);
		Territory__c territories = [
				SELECT Id, Name, ParTerritory__c
				FROM Territory__c
				WHERE Id IN (SELECT Territory__c
				FROM Account
				WHERE Id IN :accountToRecalculateSharing)
				LIMIT 1
		];
		System.debug('territories = '  + territories);
		Set<Territory__c> allParentTerritories = getParentHierarchyTerritories(territories);
		System.debug('allParentTerritories = ' + allParentTerritories);
		List<User> users = [
				SELECT Id, Name
				FROM User
				WHERE Id IN
				(SELECT User__c
				FROM TerrUser__c
				WHERE Territory__r.Id IN :allParentTerritories)
		];
		System.debug('users = '  + users);
		for (User user : users) {
			List<Account> accounts = [SELECT Id FROM Account WHERE Territory__c = :territories.Id];
			List<AccountShare> accountsUserShares = AccountSharingService.shareAccessToAccount(accounts, user.Id);
			allShares.addAll(accountsUserShares);
			List<Contact__Share> contactsUserShares = ContactSharingService.shareAccessToContact(accounts, user.Id);
			allShares.addAll(contactsUserShares);
		}
		System.debug('allShares = '  + allShares);
		insert allShares;
	}

	private static Set<Territory__c> parentsTerritories = new Set<Territory__c>();

	public static Set<Territory__c> getParentHierarchyTerritories(Territory__c territory){
		parentsTerritories = new Set<Territory__c>();
		findParentTerritories(territory);
		return parentsTerritories;
	}

	private static Set<Territory__c> findParentTerritories(Territory__c childTerritory){
		parentsTerritories.add(childTerritory);
		List<Territory__c> territories = [SELECT Id, ParTerritory__c, Name FROM Territory__c WHERE Id =:childTerritory.ParTerritory__c];
		for (Territory__c territory : territories){
			parentsTerritories.add(territory);
			findParentTerritories(territory);
		}
		return parentsTerritories;
	}
}