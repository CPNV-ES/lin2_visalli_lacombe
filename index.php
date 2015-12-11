<html>
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" type="text/css" href="css/style.css">
<title>Site example</title>
</head>
        <?php

        try
        {
        $base= new PDO('mysql:host=localhost;dbname=votredb;charset=utf8', 'user', 'password');
        }
                catch(Exception $e){

                die('Erreur : '.$e->getMessage());

                }

        ?>
<body>
        <form action="index.php" method="get">
        <h2>Example h2</h2>
                <h3>Example h3 :</h3>
                <input type="text" name="nom" required="required">
                <br />

                <input type="submit" value="Go" class="submit-button">
        </form>

<p>This page was created for testing the system</p>
 <?php

echo phpinfo();

 ?>
</body>
</html>
