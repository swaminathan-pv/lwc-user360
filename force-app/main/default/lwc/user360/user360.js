import { LightningElement, track, wire } from 'lwc';
import getUserDetails from '@salesforce/apex/UserInfoController.getUserDetails';
const columns = [
    { label: 'User Name', fieldName: 'userLink', type: 'url', wrapText: true, typeAttributes: { label: { fieldName: 'userName' }, tooltip: 'Go to detail page', target: '_blank' } },
    { label: 'Profile', fieldName: 'profile', type: 'text', wrapText: true },
    { label: 'Role', fieldName: 'role', type: 'text', wrapText: true },
    { label: 'Email', fieldName: 'email', type: 'text', wrapText: true },
    { label: 'Permission Set', fieldName: 'permissionSetMembership', type: 'text', wrapText: true, cellAttributes: { alignment: 'left' } },
    { label: 'Groups', fieldName: 'groupMembership', type: 'text', wrapText: true, cellAttributes: { alignment: 'left' } },
    { label: 'Queues', fieldName: 'queueMembership', type: 'text', wrapText: true, cellAttributes: { alignment: 'left' } }
];
export default class User360 extends LightningElement {
    @track error;
    @track columns = columns;
    @track userRecords; //All opportunities available for data table
    @track showTable = false; //Used to render table after we get the data from apex controller
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @track displayEmptyMessage = true; //Flag to control empty message display
    @wire(getUserDetails)
    wusers({ error, data }) {
        if (data) {
            let recs = [];
            for (let i = 0; i < data.length; i++) {
                let userDetail = {};
                userDetail.rowNumber = '' + (i + 1);
                // TODO: Use Navigation component
                userDetail.userLink = '/' + data[i].id;
                userDetail = Object.assign(userDetail, data[i]);
                recs.push(userDetail);
            }
            this.userRecords = recs;
            this.showTable = true;
        }
        else {
            this.error = error;
        }
    }
    //Capture the event fired from the paginator component
    handlePaginatorChange(event) {
        this.displayEmptyMessage = false;
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
    }
    //Capture the event fired from the paginator component
    handleEmptySearchResults(event) {
        this.recordsToDisplay = event.detail;
        this.displayEmptyMessage = true;
        console.log('<<<Empty results');
    }
}