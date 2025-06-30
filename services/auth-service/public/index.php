<?php
use Illuminate\Http\Request;

require __DIR__.'/../vendor/autoload.php';

 = require_once __DIR__.'/../bootstrap/app.php';

 = ->make(Illuminate\Contracts\Http\Kernel::class);

 = ->handle(
     = Request::capture()
);

->send();
->terminate(, );
