class SquadEntity {
  final String squadId;
  final String name;
  final String inviteCode;
  final int memberCount;

  const SquadEntity({
    required this.squadId,
    required this.name,
    required this.inviteCode,
    required this.memberCount,
  });
}

class SquadBoardMemberEntity {
  final String userId;
  final String displayName;
  final List<Map<String, dynamic>> deadlines;

  const SquadBoardMemberEntity({
    required this.userId,
    required this.displayName,
    required this.deadlines,
  });
}
