import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Implementar lógica de búsqueda aquí
    // Por ejemplo, llamar a una función de callback
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 18),
      child: Row(
        children: [
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.6,
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.start,
              cursorHeight: 20,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.pink,
                ),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Buscar servicios...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(45),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.3 * 255).toInt()),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.slider_horizontal_3,
                color: Colors.pink,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.3 * 255).toInt()),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.filter_alt_outlined,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
    );
  }
}
