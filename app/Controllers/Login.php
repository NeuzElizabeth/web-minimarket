<?php
namespace App\Controllers;

use CodeIgniter\Controller;
use App\Models\UsuarioModel;

class Login extends Controller
{
    public function index()
    {
        return view('login');
    }

    public function authenticate()
    {
        $session = session();
        $model = new UsuarioModel();
        $username = $this->request->getPost('username');
        $password = $this->request->getPost('password');

        $user = $model->where('email', $username)->orWhere('dni', $username)->first();// Busca el usuario por email o dni en la base de datos y lo almacena en la variable $user

        if ($user && password_verify($password, $user['contraseña'])) {// Verifica si el usuario y la contraseña son correctos y si lo son, inicia sesión
            // Guarda el ID del usuario en la sesión
            $session->set([
                'id_usuario' => $user['id_usuario'],
                'isLoggedIn' => true
            ]);
            $session->set('user', $user);
            return redirect()->to(base_url('admin/home'));
        } else {// Si el usuario o la contraseña son incorrectos, muestra un mensaje de error
            $session->setFlashdata('error', 'Usuario o contraseña incorrectos');
            return redirect()->to(base_url('admin/login'));
        }
    }

    public function logout()
    {
        $session = session();
        $session->destroy();
        return redirect()->to(base_url('admin/login'));
    }

    public function create()
    {
        $session = session();
        $model = new UsuarioModel();
    
        $nombre = $this->request->getPost('nombre');
        $dni = $this->request->getPost('dni');
    
        // Verificar si el nombre o el DNI ya existen en la base de datos
        $usuarioExistente = $model->where('nombre', $nombre)->orWhere('dni', $dni)->first();
    
        if ($usuarioExistente) {
            $session->setFlashdata('error', 'El nombre o DNI ya están registrados');
            return redirect()->back()->withInput();
        }
    
        $data = [
            'nombre' => $nombre,
            'apellido' => $this->request->getPost('apellido'),
            'email' => $this->request->getPost('email'),
            'telefono' => $this->request->getPost('telefono'),
            'dni' => $dni,
            'contraseña' => $this->request->getPost('contraseña'),
            'tipo_usuario' => 'cliente',
        ];
    
        $model->save($data);
        return redirect()->to(base_url('admin/login'));
    }
}