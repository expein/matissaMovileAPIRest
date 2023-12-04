import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expansion_tile_card/expansion_tile_card.dart';
import '../widget/AppBar.dart';

class PageCitas extends StatefulWidget {
  const PageCitas({Key? key}) : super(key: key);

  @override
  State<PageCitas> createState() => _PageCitasState();
}

class _PageCitasState extends State<PageCitas> {
  TimeOfDay? selectedTime;
  DateTime? selectedDate;
  List<Map<String, dynamic>> servicios = [];
  List<Map<String, dynamic>> citas = [];
  Map<String, dynamic>? selectedService;

  String fecha() {
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;

    String fecha = '$year-$month-$day';

    return fecha;
  }

  @override
  void initState() {
    super.initState();
    fetchServicios();
    fetchCitas();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemCount: citas.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ExpansionTileCard(
                  initialElevation: 2,
                  expandedColor: const Color.fromARGB(255, 216, 216, 216),
                  baseColor: const Color.fromRGBO(226, 212, 255, 1),
                  title: Text('Servicio: ${citas[index]['servicio']}'),
                  subtitle:
                      Text('Feca registro: ${citas[index]['fechaRegistro']}'),
                  leading: const Icon(Icons.cut),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  children: <Widget>[
                    const Divider(
                      thickness: 1.0,
                      height: 1.0,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Estado'),
                              subtitle: citas[index]['estado'] == 1
                                  ?  const Text('Activo')
                                  :  const Text('Desactivado'),
                              trailing: citas[index]['estado'] == 1
                                  ?  const Icon(Icons.check) 
                                  :  const Icon(Icons.close),
                            ),
                            ListTile(
                              title: const Text('Precio'),
                              subtitle: Text('${citas[index]['costoTotal']}'),
                              trailing: const Icon(Icons.monetization_on),
                            ),
                            ListTile(
                              title: const Text('Fecha de la cita'),
                              subtitle: Text('${citas[index]['fechaCita']}'),
                              trailing: const Icon(Icons.event),
                            ),
                            ListTile(
                              title: const Text('Hora de la cita'),
                              subtitle: Text('${citas[index]['horaCita']}'),
                              trailing: const Icon(Icons.schedule),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                        color:  Color(0xFFa7e3e1)
                      ),
                      child: ButtonBar(
                        alignment: MainAxisAlignment.spaceAround,
                        buttonHeight: 52.0,
                        buttonMinWidth: 90.0,
                        children: [
                          // TextButton(
                          //   onPressed: () => _showForm(_journals[index]['id']),
                          //   child: const Column(
                          //     children: [
                          //       Icon(Icons.edit, color: Colors.black54,),
                          //       Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                          //       Text("Editar", style: TextStyle(color: Colors.black54))
                          //     ],
                          //   )
                          // ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      title: Text("Alerta!"),
                                      content: Text("¿Seguro quieres cancelar la cita?"),
                                      actions: [
                                      TextButton(
                                        onPressed: () async{
                                        await deleteData(citas[index]['_id']);
                                        await fetchCitas();
                                        Navigator.of(context).pop();
                                        },
                                        child: Text("Aceptar")
                                      ),
                                      TextButton(
                                        onPressed: ()=>Navigator.of(context).pop(),
                                        child: Text("Cancelar")
                                      )
                                    ]
                                  );
                                }
                              );
                            },
                            child: const Column(
                              children: [
                                Icon(Icons.delete, color: Colors.black54,),
                                Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                                Text("Eliminar", style: TextStyle(color: Colors.black54))
                              ],
                            )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddCitaModal(context);
        },
      ),
    );
  }

  Future<void> _showAddCitaModal(BuildContext context) async {
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 200),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      selectedDate =
          DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
      // ignore: use_build_context_synchronously
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButton<Map<String, dynamic>>(
                      value: selectedService,
                      onChanged: (Map<String, dynamic>? newValue) {
                        setState(() {
                          selectedService = newValue;
                        });
                      },
                      items:
                          servicios.map<DropdownMenuItem<Map<String, dynamic>>>(
                        (Map<String, dynamic> servicio) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: servicio,
                            child: Text(servicio['nombre']),
                          );
                        },
                      ).toList(),
                      hint: Text('Selecciona un servicio'),
                    ),
                    SizedBox(height: 16),
                    if (selectedService != null) ...[
                      Text('${selectedService!['nombre']}'),
                      Text('${selectedService!['precio']}'),
                      Text('${selectedService!['duracion']}h'),
                      Text(
                          '${selectedDate!.toLocal().toIso8601String().split('T')[0]}'),
                      Text(
                          "${selectedTime?.hour}:${selectedTime?.minute.toString().padLeft(2, '0')}")
                    ],
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedService != null) {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Aviso'),
                                content: Text('¿Estas seguro de agendar la cita?'),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      await postNuevaCita(
                                        selectedService!['precio'],
                                        selectedService!['nombre'],
                                        '${selectedDate!.toLocal().toIso8601String().split('T')[0]}',
                                        "${selectedTime?.hour}:${selectedTime?.minute.toString().padLeft(2, '0')}",
                                      );
                                      await fetchCitas();
                                      Navigator.of(context).pop();
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context){
                                          return AlertDialog(
                                            title: Text("Exito"),
                                            content: Text("Cita agendada exitosamente"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: Text("Aceptar")
                                              )
                                            ]
                                          );
                                        }
                                      );
                                    },
                                    
                                    child: Text('Agendar'),
                                  ),
                                  TextButton(
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancelar")
                                  )
                                ],
                              );
                            },
                          );
                        } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Aviso'),
                                content: Text('Elija un servicio.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Aceptar'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Text('Agendar'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  Future<void> fetchCitas() async {
    final response =
        await http.get(Uri.parse('https://matissa.onrender.com/api/citas'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> newCitas = [];
      for (var item in jsonData) {
        newCitas.add({
          '_id': item['_id'],
          'fechaRegistro': item['fechaRegistro'],
          'horaCita': item['horaCita'],
          'costoTotal': item['costoTotal'],
          'servicio': item['servicio'],
          'fechaCita': item['fechaCita'],
          'estado': item['estado'],
          // Agrega más campos según la estructura de tus citas
        });
      }

      setState(() {
        citas = newCitas;
      });

      print('Citas: $citas');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<String> postNuevaCita(int costoTotal, String servicio,
      String fechaCita, String horaCita) async {
    final url = Uri.parse('https://matissa.onrender.com/api/citas');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cliente': "Santiago Alzate Olivero",
        'fechaRegistro': '${fecha()}',
        'costoTotal': costoTotal,
        'servicio': servicio,
        'fechaCita': fechaCita,
        'horaCita': horaCita,
        'estado': 1
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      dynamic idValue = responseData['_id'];
      String nuevaCitaId =
          idValue is Map ? idValue['\$oid'].toString() : idValue.toString();
      print('Nueva cita creada con ID: $nuevaCitaId');
      return nuevaCitaId;
    } else {
      print('Error: ${response.statusCode}');
      return '';
    }
  }

  Future<void> fetchServicios() async {
    final response =
        await http.get(Uri.parse('https://matissa.onrender.com/api/servicios'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Map<String, dynamic>> newData = [];
      for (var item in jsonData) {
        newData.add({
          'id': item['_id'],
          'nombre': item['nombre'],
          'precio': item['precio'],
          'duracion': item['duracion'],
        });
      }

      setState(() {
        servicios = newData;
      });

      print('Servicios: $servicios');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> deleteData(String idCita) async {
    final response = await http.delete(Uri.parse('https://matissa.onrender.com/api/citas/$idCita'));

    if (response.statusCode == 200) {
      // La respuesta fue exitosa
      print('Response data: ${response.body}');
    } else {
      // Ocurrió un error
      print('Error: ${response.statusCode}');
    }
  }
}
