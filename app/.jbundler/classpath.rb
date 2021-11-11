require 'jar_dependencies'
JBUNDLER_LOCAL_REPO = Jars.home
JBUNDLER_JRUBY_CLASSPATH = []
JBUNDLER_JRUBY_CLASSPATH.freeze
JBUNDLER_TEST_CLASSPATH = []
JBUNDLER_TEST_CLASSPATH.freeze
JBUNDLER_CLASSPATH = []
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/org/apache/kafka/connect-json/3.0.0/connect-json-3.0.0.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/com/fasterxml/jackson/datatype/jackson-datatype-jdk8/2.12.3/jackson-datatype-jdk8-2.12.3.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/org/apache/kafka/kafka-streams/3.0.0/kafka-streams-3.0.0.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/com/fasterxml/jackson/core/jackson-core/2.12.3/jackson-core-2.12.3.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/com/fasterxml/jackson/core/jackson-annotations/2.12.3/jackson-annotations-2.12.3.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/org/lz4/lz4-java/1.7.1/lz4-java-1.7.1.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/org/slf4j/slf4j-simple/2.0.0-alpha5/slf4j-simple-2.0.0-alpha5.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/org/glassfish/external/commons-codec-repackaged/10.0-b28/commons-codec-repackaged-10.0-b28.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/org/rocksdb/rocksdbjni/6.19.3/rocksdbjni-6.19.3.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/org/slf4j/slf4j-api/2.0.0-alpha5/slf4j-api-2.0.0-alpha5.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/javax/ws/rs/javax.ws.rs-api/2.1.1/javax.ws.rs-api-2.1.1.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/com/github/luben/zstd-jni/1.5.0-2/zstd-jni-1.5.0-2.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/org/apache/kafka/kafka-clients/3.0.0/kafka-clients-3.0.0.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/com/fasterxml/jackson/core/jackson-databind/2.12.3/jackson-databind-2.12.3.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/org/apache/kafka/connect-api/3.0.0/connect-api-3.0.0.jar')
JBUNDLER_CLASSPATH << (JBUNDLER_LOCAL_REPO + '/org/xerial/snappy/snappy-java/1.1.8.1/snappy-java-1.1.8.1.jar')
JBUNDLER_CLASSPATH.freeze
