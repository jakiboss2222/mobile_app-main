import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import '../api/api_service.dart';

class RegisterPages extends StatefulWidget {
  const RegisterPages({super.key});

  @override
  State<RegisterPages> createState() => _RegisterPagesState();
}

class _RegisterPagesState extends State<RegisterPages> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tglLahirController = TextEditingController();
  String? _jenisKelamin;
  final _alamat = TextEditingController();
  final _angkatan = TextEditingController();
  final _id_tahun = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isObscure = true;

  void _registerAct() async {
    if (_formKey.currentState!.validate()) {
      try {
        final dio = Dio();
        final response = await dio.post(
          '${ApiService.baseUrl}auth/register',
          data: {
            'nama': _nameController.text,
            'tgl_lahir': _tglLahirController.text,
            'jenis_kelamin': _jenisKelamin,
            'alamat': _alamat.text,
            'angkatan': _angkatan.text,
            'id_tahun': _id_tahun.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          },
        );

        if (response.data['status'] == 200) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Registrasi Berhasil',
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal registrasi: $e")),
        );
      }
    }
  }

  Future<void> _pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1999),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _tglLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/SWU_HD.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.75),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:Color.fromARGB(255, 236, 239, 245),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),

                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Name",
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Name tidak boleh kosong" : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _tglLahirController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Tanggal Lahir",
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: _pilihTanggal,
                          validator: (v) =>
                              v!.isEmpty ? "Tanggal lahir wajib diisi" : null,
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _jenisKelamin,
                          decoration: const InputDecoration(
                            labelText: "Jenis Kelamin",
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "L",
                              child: Text("Laki-laki"),
                            ),
                            DropdownMenuItem(
                              value: "P",
                              child: Text("Perempuan"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _jenisKelamin = value;
                            });
                          },
                          validator: (v) =>
                              v == null ? "Pilih jenis kelamin" : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Email tidak boleh kosong" : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _alamat,
                          decoration: const InputDecoration(
                            labelText: "Alamat",
                            prefixIcon: Icon(Icons.home),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Alamat tidak boleh kosong" : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _angkatan,
                          decoration: const InputDecoration(
                            labelText: "Angkatan",
                            prefixIcon: Icon(Icons.school),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Angkatan tidak boleh kosong" : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _id_tahun,
                          decoration: const InputDecoration(
                            labelText: "Tahun Masuk",
                            prefixIcon: Icon(Icons.date_range),
                          ),
                          validator: (v) => v!.isEmpty
                              ? "Tahun Masuk tidak boleh kosong"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Password tidak boleh kosong" : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Konfirmasi password wajib diisi";
                            }
                            if (v != _passwordController.text) {
                              return "Password tidak sama";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _registerAct,
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Sudah punya akun? Login",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
