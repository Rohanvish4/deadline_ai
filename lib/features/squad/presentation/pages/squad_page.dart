import 'package:deadline_ai/features/squad/presentation/cubit/squad_cubit.dart';
import 'package:deadline_ai/features/squad/presentation/cubit/squad_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SquadPage extends StatefulWidget {
  const SquadPage({super.key});

  @override
  State<SquadPage> createState() => _SquadPageState();
}

class _SquadPageState extends State<SquadPage> {
  final _createController = TextEditingController();
  final _joinController = TextEditingController();
  final _liveMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SquadCubit>().loadSquads();
  }

  @override
  void dispose() {
    _createController.dispose();
    _joinController.dispose();
    _liveMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SquadCubit, SquadState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<SquadCubit>();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Squad Sync',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('Create or join squads and sync updates in real-time.'),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _createController,
                      decoration: const InputDecoration(labelText: 'New squad name'),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () => cubit.createSquad(_createController.text),
                        child: const Text('Create squad'),
                      ),
                    ),
                    const Divider(height: 24),
                    TextField(
                      controller: _joinController,
                      decoration: const InputDecoration(labelText: 'Invite code'),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: state.isLoading
                            ? null
                            : () => cubit.joinSquad(_joinController.text.trim().toUpperCase()),
                        child: const Text('Join squad'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (state.squads.isEmpty)
              const Text('No squads yet')
            else
              ...state.squads.map(
                (squad) => Card(
                  child: ListTile(
                    title: Text(squad.name),
                    subtitle: Text('Invite: ${squad.inviteCode} • Members: ${squad.memberCount}'),
                    trailing: TextButton(
                      onPressed: () => cubit.openBoard(squad.squadId),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            if (state.activeSquadId != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Squad board',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => cubit.leaveActiveSquad(),
                    child: const Text('Leave squad'),
                  ),
                ],
              ),
              ...state.board.map(
                (member) => Card(
                  child: ListTile(
                    title: Text(member.displayName),
                    subtitle: Text('Shared deadlines: ${member.deadlines.length}'),
                  ),
                ),
              ),
              TextField(
                controller: _liveMessageController,
                decoration: const InputDecoration(labelText: 'Broadcast message to squad'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    cubit.sendLiveUpdate(_liveMessageController.text);
                    _liveMessageController.clear();
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send live update'),
                ),
              ),
              const SizedBox(height: 8),
              ...state.liveMessages.map(
                (message) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.message_outlined),
                  title: Text(message),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
