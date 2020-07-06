# Lightning Web Components User 360 App 

This app makes it simple to view Users and their Role, Profile, Public Group, Queues and Permission set assignments in Salesforce ORG. The app is built with SalesforceDX using Lightning Web Components.
This package can be installed on any org to view/export on user membership.

## Installation Instructions

## Installing User 360 using Salesforce DX

1. Set up your environment. Follow the steps in the [Quick Start: Lightning Web Components](https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/) Trailhead project. The steps include:

    - Sign up for a Developer org and enable Dev Hub
    - Install the current version of the Salesforce CLI
    - Install Visual Studio Code
    - Install the Visual Studio Code Salesforce extensions, including the Lightning Web Components extension

1. If you haven't already done so, authenticate with your Dev Hub org and provide it with an alias (MyDevHub):

    ```
    sfdx force:auth:web:login -d -a MyDevHub
    ```

1. Clone the sfdx-user360 repository:

    ```
    git clone https://github.com/swaminathan-pv/lwc-user360
    cd lwc-user360
    ```

1. Create a scratch org and provide it with an alias (**lwc-user360** in the command below):

    ```
    sfdx force:org:create -s -f config/project-scratch-def.json -a lwc-user360
    ```

1. Push the app to your scratch org:

    ```
    sfdx force:source:push
    ```

1. In the new scratch org permission setts assign View User 360 to your system admin user account that grants access to the app and tabs.
`sfdx force:user:permset:assign -n View_User360`


1. Open the scratch org:

    ```
    sfdx force:org:open
    ```


1. In App Launcher, select the **User 360** app.

## Resources






