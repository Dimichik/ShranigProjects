/*
 * Created by Дмитро on 07.04.2019.
 */
public class ReferenceSharingService {
	private static Set<Territory__c> parentsTerritories = new Set<Territory__c>();

	public static List<sObject> getContactToShareAccess(List<Reference__c> newReferences) {
		List<sObject> contactToShareAccess = new List<sObject>();
		List<Account> accountsForSharingNewContacts = new List<Account>();
		List<Account> accounts = [
				SELECT Id, Territory__c
				FROM Account
				WHERE Id IN (SELECT Account__c
				FROM Reference__c
				WHERE id IN :newReferences)
		];
		for (Account acc : accounts) {
			if (acc.Territory__c != null) {
				accountsForSharingNewContacts.add(acc);
			}
		}
		Territory__c territory = [
				SELECT Id, Name, ParTerritory__c
				FROM Territory__c
				WHERE Id IN (SELECT Territory__c
				FROM Account
				WHERE Id IN :accountsForSharingNewContacts)
				LIMIT 1
		];
		Set<Territory__c> allParentTerritories = getParentHierarchyTerritories(territory);
		List<User> users = [
				SELECT Id, Name
				FROM User
				WHERE Id IN
				(SELECT User__c
				FROM TerrUser__c
				WHERE Territory__r.Id IN :allParentTerritories)
		];
		for (User user : users) {
			List<Account> accountsToShare = [SELECT Id FROM Account WHERE Territory__c = :territory.Id];
			List<Contact__Share> contactsUserShares =
					ContactSharingService.shareAccessToContact(accountsToShare, user.Id);
			contactToShareAccess.addAll(contactsUserShares);
		}
		return contactToShareAccess;
	}

	private static Set < Territory__c > getParentHierarchyTerritories(Territory__c territory) {
		parentsTerritories = new Set < Territory__c > ();
		findParentTerritories(territory);
		return parentsTerritories;
	}

	private static Set < Territory__c > findParentTerritories(Territory__c childTerritory) {
		parentsTerritories.add(childTerritory);
		List < Territory__c> territories = [SELECT Id, ParTerritory__c, Name FROM Territory__c WHERE Id =:childTerritory.ParTerritory__c];
		for (Territory__c territory : territories) {
			parentsTerritories.add(territory);
			findParentTerritories(territory);
		}
		return parentsTerritories;
	}
}