trigger ReferenceTrigger on Reference__c (before insert, before update, after insert, after update, after delete, before delete) {
	if (Trigger.isBefore) {
		if (Trigger.isDelete) {
//			ReferenceTriggerHandler.beforeInsert(Trigger.new);
		}
	}
	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			ReferenceTriggerHandler.afterInsert(Trigger.new);
		}
		if (Trigger.isUpdate) {
			ReferenceTriggerHandler.afterUpdate(Trigger.old);
		}
		if (Trigger.isDelete) {
			ReferenceTriggerHandler.afterDelete(Trigger.old);
		}
	}
}