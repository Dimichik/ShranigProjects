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
				WHERE UserOrGroupId =: userId AND ParentId IN (SELECT Contact__c FROM Reference__c WHERE Account__c IN :accounts)
		];
		return contactSharedList;
	}

	public static List<Contact__Share> deleteAccessToContact(List<Account> accounts) {
		List<Contact__Share> contactsShareToDelete = [SELECT Id, ParentId FROM Contact__Share WHERE ParentId IN (SELECT Contact__c FROM Reference__c WHERE Account__c IN :accounts)];
		return contactsShareToDelete;
	}
}