import 'package:flutter/material.dart';

Color decorationColor = Colors.black.withValues(alpha: 0.1);

class JukeboxCard extends StatelessWidget {
  const JukeboxCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        height: 400, // Adjust as needed
        child: Row(
          children: [
            // Column 1 (Directory List)
            Expanded(
              flex: 1, // 1/3 width
              child: Container(
                decoration: BoxDecoration(
                  color: decorationColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Text(
                      "Music Directory",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Directory List Goes Here",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Column 2 (Now Playing + Queue)
            Expanded(
              flex: 2, // 2/3 width
              child: Column(
                children: [
                  // Now Playing (25% height)
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: decorationColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Now Playing",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Song Metadata Here",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Queue Playlist (75% height)
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: decorationColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          const Text(
                            "Queue Playlist",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Queue List Goes Here",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
