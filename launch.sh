#! /bin/bash

JAR_FILE="/opt/extremexp-dsl-framework/eu.extremexp.dsl.parent/eu.extremexp.dsl.ide/target/eu.extremexp.dsl.ide-1.0.0-SNAPSHOT-ls.jar"

while [ -f "$JAR_FILE" ] ; do
        java -jar "$JAR_FILE"
done

echo "cannot find $JAR_FILE"
exit 1 
