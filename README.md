This project is an autonomous mobile robot developed as part of the Embedded Systems course at Princess Sumaya University for Technology (PSUT).

The goal was to design and implement a real-time embedded system capable of autonomous navigation tasks such as line following, obstacle avoidance, and environment interaction under real-world hardware constraints.

The project was built around a PIC16F877A microcontroller and focuses on system-level design, hardware–software integration, and timing-critical embedded control.

🎥 Demo:
https://www.youtube.com/shorts/tULyxAehodA

System Capabilities
-Line following
-Obstacle detection and avoidance
-Autonomous navigation logic
-Multi-motor drive control
-Real-time sensor-based decision making

Hardware Architecture
Core components:
-Microcontroller: PIC16F877A
-Drive system: 4 DC motors
-Motor drivers: H-bridges
-Actuation: Servo motor
-Sensors: Ultrasonic + IR modules
-Power: External supply with voltage regulation

The system was designed to support:
-independent control of four motors
-reliable power delivery to logic and actuators
-real-time sensor acquisition

Software Architecture
The software was written in C and structured around a modular, state-based control system.
Key aspects:
-Finite-state control model
-Timer-based scheduling and timing-critical loops
-Non-blocking sensor handling
-Separate motor control, sensing, and decision layers
-Real-time response to environment changes

Timers were heavily used to manage:
-motor control updates
-sensor sampling
-control loop execution
The focus was on keeping the system responsive, predictable, and stable despite limited resources.

Control Logic & System Design
The system logic was built around:
-continuous sensor sampling
-real-time decision evaluation
-prioritized motion behaviors

Major design points included:
-transitioning from a 2-wheel to a 4-wheel drive system
-coordinating four DC motors with different real-world characteristics
-handling timing and synchronization between sensing and actuation
-structuring control flow to avoid blocking behavior

Key Engineering Challenges
-Hardware–software integration across multiple modules
-Managing four motors and their non-uniform real-world behavior
-Timing and synchronization using microcontroller timers
-Debugging under real-world constraints where failures were not deterministic
-Maintaining system stability and responsiveness

Build & Run
Target MCU: PIC16F877A
Toolchain: (mikroC)

Steps:
-Compile the project
-Program on easypic development board
-Power system
-Place robot on track

Future Improvements
-RTOS-based task scheduling
-Better sensor fusion
-Closed-loop motor speed control
-Embedded Linux / ROS integration
-Higher-level autonomous behaviors

Acknowledgments

Developed by:
Talal Barakat, Yacoub Yousef, Omar Alshamali

Supervised by:
Dr. Belal Sababha
Princess Sumaya University for Technology
