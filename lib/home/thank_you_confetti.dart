import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ThankYouConfetti extends StatefulWidget {
  const ThankYouConfetti({super.key});

  @override
  State<ThankYouConfetti> createState() => _ThankYouConfetti();
}

class _ThankYouConfetti extends State<ThankYouConfetti> {
  late ConfettiController _controllerCenter;
  static bool _showOnlyOnce = true;

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (mounted && _showOnlyOnce) {
      _showOnlyOnce = false;
      _controllerCenter.play();
      Future.delayed(const Duration(milliseconds: 2500), () {
        _controllerCenter.stop();
      });
      return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 1),
          child: SafeArea(
              child: Stack(children: <Widget>[
            //CENTER -- Blast
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _controllerCenter,
                blastDirectionality: BlastDirectionality
                    .explosive, // don't specify a direction, blast randomly
                shouldLoop:
                    false, // start again as soon as the animation is finished
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ], // manually specify the colors to be used
                minimumSize: const Size(5,
                    10), // set the minimum potential size for the confetti (width, height)
                maximumSize: const Size(20,
                    50), // set the maximum potential size for the confetti (width, height)
                numberOfParticles: 100, // a lot of particles at once
                gravity: 0.3,
              ),
            ),
          ])));
    } else {
      return Container();
    }
  }
}
