#RehabMe

Rehabilitation therapists estimate that 75% of the patients are not performing rehab exercises at home. Because most patients only go to rehab institutions once a week, or less frequently, in-home rehab exercises are critical for their recovery. Unfortunately from therapists’ estimation tells us a lot more could be done to improve in-home rehab activities, and to help patients better recover.

RehabMe is designed to motivate patients to do their in-home rehab exercises by using multiple motivation schemes such as digital badges and reminders, and connect patients and therapists remotely so that therapists know how their patients are performing at home.

###User Flow
The mobile application itself is self-contained, meaning that the smartphone is the only requirement to operate our app. Selected usage data is sent to Parse, our cloud platform, and  queries data from the cloud platform and visualize the data. ![User flowchart](img_readme/data_flow.png)

#RehabMe Mobile
![Control flowchart](img_readme/control_flow.png)
Each block represents one interface, or view controller, that users will see and perform operations on. Details of the diagram are explained below, with additional figures.###Login
![Login](img_readme/login.tif)The first time entrance to the app requires the user to either register or log in to use the app. We also provide a Facebook login so that users can create an account using their Facebook login information.
2. The app begins with the exercise card deck view controller. Here, all the exercises are represented by cards. Each card contains the name of the exercise, how many times and how long it should be performed, along with a picture illustration of the exercise, as can be seen in Figure 4.3.3. There is a button “start” under each card. When pressed, the app enters the card detail view controller that displays the detailed instructions of the exercises (Figure 4.4). There are three buttons on the bottom: a “timer” button, a camera icon button, and a “done” button.
