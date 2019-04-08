/*
 * Created by Дмитро on 07.04.2019.
 */
public class ReferenceTriggerHandler {

	public static void afterInsert(List<SObject> newReferences) {
		insert ReferenceSharingService.getContactToShareAccess(newReferences);
	}

	public static void afterUpdate(List<SObject> newReference) {

	}

	public static void beforeDelete(List<Reference__c> oldReference) {
		Database.delete(ContactSharingService.deleteAccessToContactFromReference(oldReference), false);
	}
}