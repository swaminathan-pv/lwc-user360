/**
 * TODO: Get sample header and update
 */
public with sharing class UserInfoController {

	@AuraEnabled(cacheable = true)
	public static List <UserInfo> getUserDetails(){
                //TODO: Add debug/Info statements to all methods
		Map <Id, UserInfo> userDetails = new Map <Id,UserInfo>();
		List<UserInfo> userInfos = new List<UserInfo>();
		getUserInfo(userDetails);
		getPermissionSetMembershipInfo(userDetails);
		getGroupQueueMembershipInfo(userDetails);
		for(String userId: userDetails.keySet()) {
			userInfos.add(userDetails.get(userId));
		}
		return userInfos;
	}

	private static void getUserInfo(Map <Id, UserInfo> userDetails){
		for(User userRec: [SELECT Id, Name, Email, UserRole.Name, Profile.Name FROM User]) {
			UserInfo userRecordInfo = new UserInfo();
			userRecordInfo.id = userRec.Id;
			userRecordInfo.userName = userRec.Name;
			userRecordInfo.profile = userRec.Profile.Name;
			userRecordInfo.role = userRec.UserRole.Name;
			userRecordInfo.email = userRec.Email;
			userDetails.put(userRec.Id,userRecordInfo);
		}
	}

	private static void getPermissionSetMembershipInfo(Map <Id, UserInfo> userDetails){
		for(PermissionSetAssignment userPermissionSetDetail: [SELECT AssigneeId, Assignee.Name, PermissionSet.Label FROM PermissionSetAssignment Where PermissionSet.isOwnedBYProfile = FALSE order by AssigneeId ]) {
			if(userDetails.containsKey(userPermissionSetDetail.AssigneeId)) {
				UserInfo userRecordInfo = userDetails.get(userPermissionSetDetail.AssigneeId);
				String permissionSetAssignments = userRecordInfo.permissionSetMembership == null ? '': userRecordInfo.permissionSetMembership;
				if(permissionSetAssignments!='') {
					permissionSetAssignments = permissionSetAssignments + ',' + userPermissionSetDetail.PermissionSet.Label;
				}
				else{
					permissionSetAssignments =  userPermissionSetDetail.PermissionSet.Label;
				}
				userRecordInfo.permissionSetMembership =  permissionSetAssignments;
			}
		}
	}

	private static void getGroupQueueMembershipInfo(Map <Id, UserInfo> userDetails){
		for(GroupMember gm: [SELECT Id, UserOrGroupId, group.name, group.type FROM GroupMember ]) {
                        // TODO: Filtering out only User's memebership. OOG records constitute groups being part of queue
			if(userDetails.get(gm.UserOrGroupId)!=null) {
				if(gm.group.type =='Queue') {
					getQueueMembership(gm, userDetails);
				}
				else{
					getGroupMembership(gm, userDetails);
				}
			}
		}
	}

	private static void getQueueMembership(GroupMember gm, Map <Id, UserInfo> userDetails){
		UserInfo userRecordInfo = userDetails.get(gm.UserOrGroupId);
		String queueAssignments = userRecordInfo.queueMembership == null ? '': userRecordInfo.queueMembership;
		if(queueAssignments!='') {
			queueAssignments = queueAssignments + ',' + gm.group.Name;
		}
		else{
			queueAssignments =  gm.group.Name;
		}
		queueAssignments = queueAssignments + ',' + gm.group.Name;
		userRecordInfo.queueMembership = queueAssignments;
	}

	private static void getGroupMembership(GroupMember gm, Map <Id, UserInfo> userDetails){
		UserInfo userRecordInfo = userDetails.get(gm.UserOrGroupId);
		String groupAssignments = userRecordInfo.groupMembership == null ? '': userRecordInfo.groupMembership;
		if(groupAssignments!='') {
			groupAssignments = groupAssignments + ',' + gm.group.Name;
		}
		else{
			groupAssignments =  gm.group.Name;
		}
		userRecordInfo.groupMembership = groupAssignments;
	}

	private class UserInfo {
		@AuraEnabled public String id {get; set;}
		@AuraEnabled public String userName {get; set;}
		@AuraEnabled public String role {
			get { return role; }
			set { role = value == null? '':value; }
		}
		@AuraEnabled public String email {get; set;}
		@AuraEnabled public String profile {get; set;}
		@AuraEnabled public String permissionSetMembership {get; set;}
		@AuraEnabled public String groupMembership {get; set;}
		@AuraEnabled public String queueMembership {get; set;}
	}
}
