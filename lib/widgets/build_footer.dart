import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HiddenFooter extends StatefulWidget {
  @override
  _HiddenFooterState createState() => _HiddenFooterState();
}

class _HiddenFooterState extends State<HiddenFooter>
    with SingleTickerProviderStateMixin {
  bool _isFooterVisible = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFooter() {
    setState(() {
      _isFooterVisible = !_isFooterVisible;
      if (_isFooterVisible) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse();
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print("Could not launch URL: $e");
    }
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required int index,
    String? subtitle,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool _isHovering = false;
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 280,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(_isHovering ? 0.15 : 0.1),
                    color.withOpacity(_isHovering ? 0.08 : 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color.withOpacity(_isHovering ? 0.3 : 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: _isHovering ? 20 : 0,
                    spreadRadius: _isHovering ? 2 : 0,
                    offset: Offset(0, _isHovering ? 8 : 0),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: FaIcon(
                      icon,
                      size: 24,
                      color: color.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: color.withOpacity(0.9),
                            letterSpacing: 0.4,
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: color.withOpacity(0.7),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: color.withOpacity(0.6),
                  ),
                ],
              ),
            )
                .animate(target: _isHovering ? 1 : 0)
                .scale(
                    begin: Offset(1, 1),
                    end: Offset(1.02, 1.02),
                    duration: 200.ms,
                    curve: Curves.easeOutCubic)
                .animate(delay: 100.ms * index)
                .slideX(
                    begin: 0.3,
                    end: 0,
                    duration: 800.ms,
                    curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 280,
      height: 1,
      margin: EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.onSurface.withOpacity(0),
            Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            Theme.of(context).colorScheme.onSurface.withOpacity(0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hidden Footer
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: 800.ms,
            child: _isFooterVisible
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        key: ValueKey("footer"),
                        padding: EdgeInsets.fromLTRB(32, 36, 32, 36),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.85),
                              Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.95),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(40)),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 50,
                              spreadRadius: 0,
                              offset: Offset(0, -10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            Container(
                              width: 50,
                              height: 5,
                              margin: EdgeInsets.only(bottom: 32),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            )
                                .animate(delay: 200.ms)
                                .scale(
                                    duration: 400.ms, curve: Curves.easeOutBack)
                                .fadeIn(),

                            // Title
                            Text(
                              "Let's Connect!",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: 0.5,
                              ),
                            )
                                .animate(delay: 300.ms)
                                .fadeIn(duration: 400.ms)
                                .slideY(begin: 0.3, end: 0),

                            SizedBox(height: 8),

                            Text(
                              "Choose your preferred way to get in touch",
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                                letterSpacing: 0.3,
                              ),
                            )
                                .animate(delay: 400.ms)
                                .fadeIn(duration: 400.ms)
                                .slideY(begin: 0.3, end: 0),

                            SizedBox(height: 32),

                            // Contact Buttons
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildSocialButton(
                                  icon: FontAwesomeIcons.github,
                                  label: "Follow on GitHub",
                                  subtitle: "Check out my latest projects",
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  onTap: () =>
                                      _launchUrl("https://github.com/ehamzadz"),
                                  index: 0,
                                ),
                                SizedBox(height: 16),
                                _buildSocialButton(
                                  icon: FontAwesomeIcons.whatsapp,
                                  label: "Chat on WhatsApp",
                                  subtitle: "Quick responses, available 24/7",
                                  color: Color(0xFF25D366),
                                  onTap: () =>
                                      _launchUrl("https://wa.me/+213672138811"),
                                  index: 1,
                                ),
                                SizedBox(height: 16),
                                _buildSocialButton(
                                  icon: FontAwesomeIcons.envelope,
                                  label: "Send an Email",
                                  subtitle: "For business inquiries",
                                  color: Theme.of(context).colorScheme.primary,
                                  onTap: () =>
                                      _launchUrl("mailto:eHamzaDZ@pm.me"),
                                  index: 2,
                                ),
                              ],
                            ),

                            _buildDivider(),

                            // Footer Text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_rounded,
                                  size: 16,
                                  color: Colors.red.withOpacity(0.8),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Made with love by eHamzaDZ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            )
                                .animate(delay: 600.ms)
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: 0.2, end: 0),
                          ],
                        ),
                      ),
                    ),
                  )
                    .animate()
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                    .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 800.ms,
                        curve: Curves.easeOutCubic)
                : SizedBox.shrink(),
          ),
        ),
        // Toggle Button
        Positioned(
          bottom: 28,
          left: 28,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Transform.rotate(
              angle: _animation.value * 3.14159,
              child: FloatingActionButton.large(
                onPressed: _toggleFooter,
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  _isFooterVisible
                      ? Icons.close_rounded
                      : Icons.chat_bubble_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          )
              .animate(target: _isFooterVisible ? 1 : 0)
              .scale(
                  begin: Offset(1, 1), end: Offset(1.1, 1.1), duration: 200.ms)
              .shimmer(duration: 1000.ms, color: Colors.white24),
        ),
      ],
    );
  }
}
