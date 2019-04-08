trigger ReferenceTrigger on Reference__c (before insert, before update, after insert, after update, after delete, before delete) {
	if (Trigger.isBefore) {
		if (Trigger.isDelete) {
			ReferenceTriggerHandler.beforeDelete(Trigger.old);
		}
	}
	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			ReferenceTriggerHandler.afterInsert(Trigger.new);
		}
	}
}