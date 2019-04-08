/*
 * Created by Дмитро on 07.04.2019.
 */
public class AccountTriggerHandler {


	public static void beforeUpdate(List<SObject> newTerritory) {
		List<Account> accountToDelete = AccountTriggerService.changedTerritory(newTerritory);
		List<AccountShare> accShare = AccountSharingService.deleteSharesAccount(accountToDelete);
		List<Contact__Share> contractShares = ContactSharingService.deleteAccessToContact(accountToDelete);
			Database.Delete(accShare, false);
		if (!contractShares.isEmpty()) {
			Database.Delete(contractShares, false);
		}
	}

	public static void afterUpdate(List<SObject> changedAccounts) {
		List<sObject> allShares = new List<sObject>();
		List<Account> changedTerritories = AccountTriggerService.changedTerritory(changedAccounts);
		List<Account> accountToRecalculateSharing = new List<Account>();
		for (Account acc : changedTerritories) {
			if (acc.Territory__c != null) {
				accountToRecalculateSharing.add(acc);
			}
		}
		Territory__c territory = [
				SELECT Id, Name, ParTerritory__c
				FROM Territory__c
				WHERE Id IN (SELECT Territory__c
				FROM Account
				WHERE Id IN :accountToRecalculateSharing)
				LIMIT 1
		];
		Set<Territory__c> allParentTerritories = AccountTriggerService.getParentHierarchyTerritories(territory);
		List<User> users = [
				SELECT Id, Name
				FROM User
				WHERE Id IN
				(SELECT User__c
				FROM TerrUser__c
				WHERE Territory__r.Id IN :allParentTerritories)
		];
		for (User user : users) {
			List<Account> accounts = [SELECT Id FROM Account WHERE Territory__c = :territory.Id];
			List<AccountShare> accountsUserShares = AccountSharingService.shareAccessToAccount(accounts, user.Id);
			allShares.addAll(accountsUserShares);
			List<Contact__Share> contactsUserShares = ContactSharingService.shareAccessToContact(accounts, user.Id);
			allShares.addAll(contactsUserShares);
		}
		insert allShares;
	}

	public static void beforeDelete(List<SObject> oldAccount) {
		List<Contact__Share> contractShares = ContactSharingService.deleteAccessToContact(oldAccount);
		if (!contractShares.isEmpty()) {
			Database.Delete(contractShares, false);
		}
	}
}