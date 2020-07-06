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
@IsTest
private class UserInfoControllerTest {
	@testSetup static void setup() {
		UserRole testVPRole =setupRole();
		List<User> testUserRecords = setupTestUsers(testVPRole);
		List<Group> testGroups =setupGroups();
		List<QueuesObject> testQueues = setupQueues(testGroups);
		List<PermissionSet> testPermissionSets = setupPermissionSets();
		List<GroupMember> testMembers = new List<GroupMember>();
		List<PermissionSetAssignment> testPermSetAssignments = new List<PermissionSetAssignment>();
                //Create Group and Queue Membership Entries
		for(Group testGroup: testGroups) {
			GroupMember testUserMembership = new GroupMember();
			testUserMembership.UserOrGroupId = testUserRecords[0].Id;
			testUserMembership.GroupId = testGroup.Id;
			testMembers.add(testUserMembership);
		}
		insert testMembers;
                //Create PermissionSet Membership Entries
		for(PermissionSet testPermSet: testPermissionSets) {
			PermissionSetAssignment psa = new PermissionSetAssignment(
				AssigneeId = testUserRecords[0].Id,
				PermissionSetId = testPermSet.Id);
			testPermSetAssignments.add(psa);
		}
		insert testPermSetAssignments;
	}
        /**Helper method to setup test User records */
	static List<User> setupTestUsers(UserRole testVPRole){
		List<User> testUserRecords = new List<User>();
                // Setup 4 Test Users
		Profile standardProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
		while (testUserRecords.size() < 6) {
			Blob b = Crypto.GenerateAESKey(128);
			String h = EncodingUtil.ConvertTohex(b);
			String uid = h.SubString(0,8);
			User testUser = new User(Alias = uid, Email= uid + '@test.com',
						 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
						 LocaleSidKey='en_US', ProfileId = standardProfile.Id, UserRoleId = testVPRole.Id,
						 TimeZoneSidKey='America/New_York', UserName= uid + '@test.com');
			testUserRecords.add(testUser);
		}
		insert testUserRecords;
		return testUserRecords;
	}
        /**Helper method to setup test role */
	static UserRole setupRole(){
                // Setup test Role
		UserRole testVPRole = new UserRole(DeveloperName = 'TestVPRole', Name = 'Test VP');
		insert testVPRole;
		return testVPRole;
	}
        /**Helper method to setup test groups */
	static List<Group> setupGroups(){
                //Setup Test Groups and Queues
		List<Group> testGroups = new  List<Group>();
		for (Integer i=0; i <20; i++) {
			Group testGroupForQueue = new Group(Name='testGroupForQueue'+i, type='Queue');
			Group testGroupForPublicGroup = new Group(Name='testGroupForPublicGroup'+i, type='Regular');
			testGroups.add(testGroupForQueue);
			testGroups.add(testGroupForPublicGroup);

		}
		insert testGroups;
		return testGroups;
	}
        /**Helper method to setup test queues */
	static List<QueuesObject> setupQueues(List<Group> testGroups){
		List<QueuesObject> testQueues = new List<QueuesObject>();
		for(Group testGroupRec: testGroups) {
			if(testGroupRec.type=='Queue') {
				QueuesObject testQueue = new QueueSObject(QueueID = testGroupRec.id, SobjectType = 'Case');
				testQueues.add(testQueue);
			}
		}
		insert testQueues;
		return testQueues;
	}
        /**Helper method to setup test permissionsets */
	static List<PermissionSet> setupPermissionSets(){
		List<PermissionSet> testPermSets = new List<PermissionSet>();
		for(Integer i=0; i <10; i++) {
			PermissionSet testPermSet = new PermissionSet(Label = 'mockPs'+i, Name = 'mockPs'+i);
			testPermSets.add(testPermSet);
		}
		insert testPermSets;
		return testPermSets;
	}

	@isTest static void testGetUserDetails(){
		Test.startTest();
		List <UserInfoController.UserInfoWrapper> userDetails = UserInfoController.getUserDetails();
		Test.StopTest();
		System.assertNotEquals(0,userDetails.size(),'User Listing is incorrect.');
		System.assertNotEquals('',userDetails[0].role,'User Role Assignment is incorrect.');
	}
}
