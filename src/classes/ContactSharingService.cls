/*
 * Created by Дмитро on 07.04.2019.
 */
/*
 * Created by Дмитро on 07.04.2019.
 */
public class ContactSharingService {

	public static List<Contact__Share> shareAccessToContact(List<Account> accounts, Id userId) {
		List<Reference__c> references = [SELECT Id, Contact__r.Id FROM Reference__c WHERE Account__c IN :accounts];
		List<Contact__Share> contactSharedList = new List<Contact__Share>();
		for (Reference__c reference : references) {
			Contact__share contactShare = new Contact__share();
			contactShare.AccessLevel = 'Edit';
			contactShare.ParentId = reference.Contact__r.Id;
			contactShare.UserOrGroupId = userId;
			contactSharedList.add(contactShare);
		}
		return contactSharedList;
	}

	public static List<Contact__Share> deleteAccessToContact(List<Account> accounts, Id userId) {
		List<Contact__Share> contactSharedList = [
				SELECT id
				FROM Contact__Share
				WHERE UserOrGroupId =: userId AND ParentId IN (SELECT Contact__c
				FROM Reference__c
				WHERE Account__c IN :accounts)
		];
		return contactSharedList;
	}

	public static List<Contact__Share> deleteAccessToContactFromReference(List<Reference__c> references) {
		Map<Contact__c, List<Reference__c>> contactListMap = new Map<Contact__c, List<Reference__c>>();
		Set<Contact__Share> contactShareSet = new Set<Contact__Share>();
		List<Contact__Share> contactShareToDelete = new List<Contact__Share>();
		List<Contact__c> contactToStay = new List<Contact__c>();
		List<Contact__c> selectedContacts = [
				SELECT id
				FROM Contact__c
				WHERE id IN (SELECT Contact__c
				FROM Reference__c
				WHERE id IN :references)
		];
		List<Reference__c> referenceList = [
				SELECT Account__c, Contact__c
				FROM Reference__c
				WHERE Contact__c IN :selectedContacts
		];
		for (Contact__c contact : selectedContacts) {
			List<Reference__c> tempReferences = new List<Reference__c>();
			for (Reference__c ref : referenceList) {
				if (ref.Contact__c == contact.Id) {
					tempReferences.add(ref);
				}
			}
			contactListMap.put(contact, referenceList);
		}
		for (Contact__c cont : contactListMap.keySet()) {
			List<Reference__c> referenceForCurrContact = contactListMap.get(cont);
			List<AccountShare> currAccShares = [
					SELECT id, UserOrGroupId
					FROM AccountShare
					WHERE AccountId IN (SELECT Account__c
					FROM Reference__c
					WHERE id IN :referenceForCurrContact)
			];
			for (AccountShare accShares1 : currAccShares) {
				for (AccountShare accShares2 : currAccShares) {
					if (accShares1.UserOrGroupId == accShares2.UserOrGroupId && accShares1.Id != accShares2.Id) {
						contactToStay.add(cont);
					}
				}
			}
		}

		List<Contact__Share> contactsToCheckOnDelete = [
				SELECT Id, ParentId, UserOrGroupId
				FROM Contact__Share
				WHERE ParentId IN (SELECT Contact__c
				FROM Reference__c
				WHERE id IN :references)
		];
		for (Contact__Share contShare : contactsToCheckOnDelete) {
			contactShareSet.add(contShare);
		}
		for (Contact__Share contShare : contactShareSet) {
			for (Contact__c cont : contactToStay) {
				if (contShare.ParentId == cont.Id) {
					contactShareSet.remove(contShare);
				}
			}
		}
		for (Contact__Share contShare : contactShareSet){
			contactShareToDelete.add(contShare);
		}
		return contactShareToDelete;
	}

	public static List<Contact__Share> deleteAccessToContact(List<Account> accounts) {
		List<Contact__Share> contactsShareToDelete = [SELECT Id, ParentId FROM Contact__Share WHERE ParentId IN (SELECT Contact__c FROM Reference__c WHERE Account__c IN :accounts)];
		return contactsShareToDelete;
	}
}