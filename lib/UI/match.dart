import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TableScreen extends StatefulWidget {
  final String code;

  const TableScreen({Key? key, required this.code}) : super(key: key);

  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List _table = [];
  bool _isLoading = true;

  // Fetching the table data from https://www.football-data.org/
  Future<void> getTable() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://api.football-data.org/v4/competitions/${widget.code}/standings'),
        headers: {'X-Auth-Token': 'd3ddcf3196274c0a95eae812d76ba26b'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final standings = (data['standings'] as List?)?.firstWhere(
          (s) => s['type'] == 'TOTAL',
          orElse: () => null,
        );

        if (standings != null && standings['table'] != null) {
          setState(() {
            _table = standings['table'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _table = [];
            _isLoading = false;
          });
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        setState(() {
          _table = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching table: $e');
      setState(() {
        _table = [];
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getTable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Football Standings'),
        backgroundColor: const Color.fromARGB(255, 112, 14, 56),
      ),
      body: Container(
        color: const Color(0xffe70066),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _table.length,
                itemBuilder: (context, index) {
                  final team = _table[index];
                  final teamImageUrl = team['team']['crest'] ?? '';
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      leading: teamImageUrl.isNotEmpty
                          ? Image.network(
                              teamImageUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.error, size: 40),
                      title:
                          Text('${team['position']} - ${team['team']['name']}'),
                      subtitle: Text(
                          'Games Played: ${team['playedGames']} | Wins: ${team['won']} | Draws: ${team['draw']} | Losses: ${team['lost']} | GD: ${team['goalDifference']} | Points: ${team['points']}'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
