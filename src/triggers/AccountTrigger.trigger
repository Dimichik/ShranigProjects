trigger AccountTrigger on Account (before insert, before update, after update, after insert, before delete) {
	if (Trigger.isBefore) {
		if (Trigger.isUpdate) {
			AccountTriggerHandler.beforeUpdate(Trigger.new);
		}
		if (Trigger.isDelete) {
			AccountTriggerHandler.beforeDelete(Trigger.old);
		}
	}
	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			AccountTriggerHandler.afterUpdate(Trigger.old);
		}
	}
}