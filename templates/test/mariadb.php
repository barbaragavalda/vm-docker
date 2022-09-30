<?php

$host = 'mariadb';
$db = 'information_schema';
$user = 'optisistem';
$password = 'rtZYS9wJ7HWWNK';

$dsn = "mysql:host=$host;dbname=$db;charset=UTF8";

try {
	$pdo = new PDO($dsn, $user, $password);

	if ($pdo) {
		echo "<h1>Congratulations!</h1>";
        echo "<h2>Connection to $db successfully established!</h2>";
	}
} catch (PDOException $e) {
	echo $e->getMessage();
}