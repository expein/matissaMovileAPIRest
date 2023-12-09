import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:matissamovile/pages/widget/textoFrom.dart';
import '../widget/AppBar.dart';

class PagePedidos extends StatefulWidget {
  final String clienteId;
  final String clienteCorreo;
  final String clienteContrasena;
  const PagePedidos({super.key, required this.clienteId, required this.clienteCorreo, required this.clienteContrasena});

  @override
  State<PagePedidos> createState() => _PagePedidosState();
}

class _PagePedidosState extends State<PagePedidos> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}