/*
 * Copyright (c) 2020 Swaminathan Venkatramanan <swaminathan.venkatramanan@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of mosquitto nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
public with sharing class UserInfoController {

	@AuraEnabled(cacheable = true)
	public static List <UserInfoWrapper> getUserDetails(){
		System.debug(LoggingLevel.INFO, '<<<Begin Getting UserDetails>>>');
		Map <Id, UserInfoWrapper> userDetails = new Map <Id,UserInfoWrapper>();
		List<UserInfoWrapper> userInfos = new List<UserInfoWrapper>();
		getUserInfo(userDetails);
		getPermissionSetMembershipInfo(userDetails);
		getGroupQueueMembershipInfo(userDetails);
		for(String userId: userDetails.keySet()) {
			userInfos.add(userDetails.get(userId));
		}
		System.debug(LoggingLevel.INFO, '<<<Completed Getting UserDetails>>>');
		return userInfos;
	}

	private static void getUserInfo(Map <Id, UserInfoWrapper> userDetails){
		System.debug(LoggingLevel.INFO, '<<<Begin Getting UserInfo>>>');
		for(User userRec: [SELECT Id, Name, Email, UserRole.Name, Profile.Name FROM User]) {
			UserInfoWrapper userInfo = new UserInfoWrapper();
			userInfo.id = userRec.Id;
			userInfo.userName = userRec.Name;
			userInfo.profile = userRec.Profile.Name;
			userInfo.role = userRec.UserRole.Name;
			userInfo.email = userRec.Email;
			userDetails.put(userRec.Id,userInfo);
		}
		System.debug(LoggingLevel.INFO, '<<<Completed Getting UserInfo>>>');
	}

	private static void getPermissionSetMembershipInfo(Map <Id, UserInfoWrapper> userDetails){
		System.debug(LoggingLevel.INFO, '<<<Begin Getting PermissionSetMembershipInfo>>>');
		for(PermissionSetAssignment userPermissionSetDetail: [SELECT AssigneeId, Assignee.Name, PermissionSet.Label FROM PermissionSetAssignment Where PermissionSet.isOwnedBYProfile = FALSE order by AssigneeId ]) {
			if(userDetails.containsKey(userPermissionSetDetail.AssigneeId)) {
				UserInfoWrapper userInfo = userDetails.get(userPermissionSetDetail.AssigneeId);
				String permissionSetAssignments = userInfo.permissionSetMembership == null ? '': userInfo.permissionSetMembership;
				if(permissionSetAssignments!='') {
					permissionSetAssignments = permissionSetAssignments + ',' + userPermissionSetDetail.PermissionSet.Label;
				}
				else{
					permissionSetAssignments =  userPermissionSetDetail.PermissionSet.Label;
				}
				userInfo.permissionSetMembership =  permissionSetAssignments;
			}
		}
		System.debug(LoggingLevel.INFO, '<<<Completed Getting PermissionSetMembershipInfo>>>');
	}

	private static void getGroupQueueMembershipInfo(Map <Id, UserInfoWrapper> userDetails){
		System.debug(LoggingLevel.INFO, '<<<Begin Getting GroupQueueMembershipInfo>>>');
		for(GroupMember gm: [SELECT Id, UserOrGroupId, group.name, group.type FROM GroupMember ]) {
                        // NOTE: Filtering out only User's memebership. OOG records constitute groups being part of queue
			if(userDetails.get(gm.UserOrGroupId)!=null) {
				if(gm.group.type =='Queue') {
					getQueueMembership(gm, userDetails);
				}
				else{
					getGroupMembership(gm, userDetails);
				}
			}
		}
		System.debug(LoggingLevel.INFO, '<<<Completed Getting GroupQueueMembershipInfo>>>');
	}

	private static void getQueueMembership(GroupMember gm, Map <Id, UserInfoWrapper> userDetails){
		System.debug(LoggingLevel.INFO, '<<<Begin Getting QueueMembership>>>');
		UserInfoWrapper userInfo = userDetails.get(gm.UserOrGroupId);
		String queueAssignments = userInfo.queueMembership == null ? '': userInfo.queueMembership;
		if(queueAssignments!='') {
			queueAssignments = queueAssignments + ',' + gm.group.Name;
		}
		else{
			queueAssignments =  gm.group.Name;
		}
		queueAssignments = queueAssignments + ',' + gm.group.Name;
		userInfo.queueMembership = queueAssignments;
		System.debug(LoggingLevel.INFO, '<<<Completed Getting QueueMembership>>>');
	}

	private static void getGroupMembership(GroupMember gm, Map <Id, UserInfoWrapper> userDetails){
		System.debug(LoggingLevel.INFO, '<<<Begin Getting GroupMembership>>>');
		UserInfoWrapper userInfo = userDetails.get(gm.UserOrGroupId);
		String groupAssignments = userInfo.groupMembership == null ? '': userInfo.groupMembership;
		if(groupAssignments!='') {
			groupAssignments = groupAssignments + ',' + gm.group.Name;
		}
		else{
			groupAssignments =  gm.group.Name;
		}
		userInfo.groupMembership = groupAssignments;
		System.debug(LoggingLevel.INFO, '<<<Completed Getting GroupMembership>>>');
	}
	@TestVisible
	private class UserInfoWrapper {
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
