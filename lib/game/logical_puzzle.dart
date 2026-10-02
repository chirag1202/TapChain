import 'level_config.dart';

/// The intended cause-and-effect chain, independent of physical coordinates.
///
/// The first generator release uses a simple relay. Additional node and edge
/// types are represented here so layout generation can grow without changing
/// the playable [LevelConfig] format.

enum PuzzleNodeType {
  starter,
  dominoRun,
  ball,
  box,
  drop,
  spring,
  platform,
  target,
  decoy,
}

class PuzzleNode {
  const PuzzleNode(this.id, this.type, {this.required = true});

  final String id;
  final PuzzleNodeType type;
  final bool required;
}

class PuzzleLink {
  const PuzzleLink(this.from, this.to, {this.required = true});

  final String from;
  final String to;
  final bool required;
}

class LogicalPuzzle {
  const LogicalPuzzle({required this.nodes, required this.links});

  final List<PuzzleNode> nodes;
  final List<PuzzleLink> links;

  PuzzleNode? get starter => _single(PuzzleNodeType.starter);
  PuzzleNode? get target => _single(PuzzleNodeType.target);

  PuzzleNode? _single(PuzzleNodeType type) {
    final matches = nodes.where((node) => node.type == type);
    return matches.length == 1 ? matches.single : null;
  }

  /// Returns diagnostics for malformed graphs, including required nodes that
  /// cannot be reached from the starter.
  List<String> validate() {
    final errors = <String>[];
    final ids = nodes.map((node) => node.id).toSet();
    if (ids.length != nodes.length) errors.add('Node ids must be unique.');
    if (starter == null) errors.add('Exactly one starter node is required.');
    if (target == null) errors.add('Exactly one target node is required.');
    for (final link in links) {
      if (!ids.contains(link.from) || !ids.contains(link.to)) {
        errors.add('Link ${link.from} -> ${link.to} has a missing endpoint.');
      }
    }
    final start = starter;
    if (start != null) {
      final reachable = <String>{start.id};
      var changed = true;
      while (changed) {
        changed = false;
        for (final link in links.where((link) => link.required)) {
          if (reachable.contains(link.from) &&
              ids.contains(link.to) &&
              reachable.add(link.to)) {
            changed = true;
          }
        }
      }
      for (final node in nodes.where((node) => node.required)) {
        if (!reachable.contains(node.id)) {
          errors.add('Required node "${node.id}" is disconnected.');
        }
      }
    }
    return errors;
  }
}

/// Physical geometry plus the intended logical chain and generator metadata.
/// The game consumes [level] exactly like a hand-authored level.
class GeneratedLevelDefinition {
  const GeneratedLevelDefinition({
    required this.level,
    required this.puzzle,
    required this.seed,
    required this.template,
    required this.difficulty,
    required this.complexityScore,
  });

  final LevelConfig level;
  final LogicalPuzzle puzzle;
  final int seed;
  final String template;
  final int difficulty;
  final double complexityScore;
}
