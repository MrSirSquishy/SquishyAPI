# SquishyAPI

Discord tag: mrsirsquishy
Everything me: 
https://mrsirsquishy.notion.site/mrsirsquishy/Squishy-e825d3a72f29453799f6970e7d0dd107#328c79ebd3324f14be7cd7c743cb99a3

<h5>All Rights Reserved. Do not Redistribute without explicit permission.</h5>


Documentation:
https://mrsirsquishy.notion.site/Squishy-API-Guide-3e72692e93a248b5bd88353c96d8e6c5

<h3>Current Feature List:</h3>

- Eye Movement: moves an eye based on the head rotation that should work with any general eye type. 
- Tail Physics: This will add physics to your tails when you spin, move, jump, etc. Has the option to have an idle tail movement, and can work with a tail with any number of segments. 
- Ear Physics: This adds physics to your ear(s) when you move, and has options for different ear types. 
- Crouch Animation(returned): Allows you to easily set a crouch pose, or crouch/uncroch animations, and even crawl/uncrawl animations/poses
- Bewb Physics: This can add bewb physics to your avatar, which for some reason is also versatile for non-tiddy related activities
- Randimation: Used to be known as `squapi.blink`, this will randomly play a given animation, most commonly used for blinking
- Hover Point: Used to be known as `squapi.floatPoint`, this will allow you to have an object float naturally to it's normal position.(with optional experimental collision)
- Vanilla Leg: This applies vanilla leg movement to a given object, but allows you to modify the strength of the movement and enable/disable it on command.(example use: legs under a dress)
- Vanilla Arm: Like above, but arm
- Bounce Walk: Makes your avatar bounce when they walk. 
- First Person Hand: Allows you to have more control over displaying your hand in first person, or even just having a custom element for your hand. 
- *Smooth Head: Smooths your head movement with additional depth added to it, `squapi.smoothTorso` and `squapi.smoothHeadWithNeck` have been removed, and instead these capabilities have been given to smooth head. You can input either a single head element like normal, or you can input a table of elements(for example torso, neck, head) and the rotation can be distributed between these. 

- (advanced)Bounce object has been replaced by BERP, which is cleaner and more consistent, and works with respect to dt.(also has been added BERP3D for 3d vectors) 
