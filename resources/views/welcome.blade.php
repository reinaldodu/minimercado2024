@extends('layouts.app')

@section('titulo', 'Mis productos')

@section('contenido')
    <h1 class="text-blue-700">LISTA DE PRODUCTOS</h1>
    <ul>
        @foreach ($productos as $producto)
            <li>{{$producto->nombre}} - Precio: {{$producto->precio}}</li>
        @endforeach
    </ul>
@endsection