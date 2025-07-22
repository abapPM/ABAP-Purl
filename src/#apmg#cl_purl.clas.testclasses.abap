CLASS ltcl_purl DEFINITION FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT FINAL.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_purl_test,
        description    TYPE string,
        purl           TYPE string,
        canonical_purl TYPE string,
        type           TYPE string,
        namespace      TYPE string,
        name           TYPE string,
        version        TYPE string,
        qualifiers     TYPE string_table,
        subpath        TYPE string,
        is_invalid     TYPE abap_bool,
      END OF ty_purl_test.

    DATA:
      p     TYPE ty_purl_test,
      tests TYPE STANDARD TABLE OF ty_purl_test WITH KEY description.

    METHODS:
      setup,
      test FOR TESTING.

ENDCLASS.

CLASS ltcl_purl IMPLEMENTATION.

  METHOD setup.

    CLEAR p. " 1
    p-description = 'valid maven purl'.
    p-purl = 'pkg:maven/org.apache.commons/io@1.3.4'.
    p-canonical_purl = 'pkg:maven/org.apache.commons/io@1.3.4'.
    p-type = 'maven'.
    p-namespace = 'org.apache.commons'.
    p-name = 'io'.
    p-version = '1.3.4'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 2
    p-description = 'basic valid maven purl without version'.
    p-purl = 'pkg:maven/org.apache.commons/io'.
    p-canonical_purl = 'pkg:maven/org.apache.commons/io'.
    p-type = 'maven'.
    p-namespace = 'org.apache.commons'.
    p-name = 'io'.
    p-version = ''.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 3
    p-description = 'valid go purl without version and with subpath'.
    p-purl = 'pkg:GOLANG/google.golang.org/genproto#/googleapis/api/annotations/'.
    p-canonical_purl = 'pkg:golang/google.golang.org/genproto#googleapis/api/annotations'.
    p-type = 'golang'.
    p-namespace = 'google.golang.org'.
    p-name = 'genproto'.
    p-version = ''.
    p-subpath = 'googleapis/api/annotations'.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 4
    p-description = 'valid go purl with version and subpath'.
    p-purl = 'pkg:GOLANG/google.golang.org/genproto@abcdedf#/googleapis/api/annotations/'.
    p-canonical_purl = 'pkg:golang/google.golang.org/genproto@abcdedf#googleapis/api/annotations'.
    p-type = 'golang'.
    p-namespace = 'google.golang.org'.
    p-name = 'genproto'.
    p-version = 'abcdedf'.
    p-subpath = 'googleapis/api/annotations'.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 5
    p-description = 'invalid subpath - unencoded subpath cannot contain ..'.
    p-purl = 'pkg:GOLANG/google.golang.org/genproto@abcdedf#/googleapis/%2E%2E/api/annotations/'.
    p-canonical_purl = 'pkg:golang/google.golang.org/genproto@abcdedf#googleapis/api/annotations'.
    p-type = 'golang'.
    p-namespace = 'google.golang.org'.
    p-name = 'genproto'.
    p-version = 'abcdedf'.
    p-subpath = 'googleapis/../api/annotations'.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 6
    p-description = 'invalid subpath - unencoded subpath cannot contain .'.
    p-purl = 'pkg:GOLANG/google.golang.org/genproto@abcdedf#/googleapis/%2E/api/annotations/'.
    p-canonical_purl = 'pkg:golang/google.golang.org/genproto@abcdedf#googleapis/api/annotations'.
    p-type = 'golang'.
    p-namespace = 'google.golang.org'.
    p-name = 'genproto'.
    p-version = 'abcdedf'.
    p-subpath = 'googleapis/./api/annotations'.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 7
    p-description = 'bitbucket namespace and name should be lowercased'.
    p-purl = 'pkg:bitbucket/birKenfeld/pyGments-main@244fd47e07d1014f0aed9c'.
    p-canonical_purl = 'pkg:bitbucket/birkenfeld/pygments-main@244fd47e07d1014f0aed9c'.
    p-type = 'bitbucket'.
    p-namespace = 'birkenfeld'.
    p-name = 'pygments-main'.
    p-version = '244fd47e07d1014f0aed9c'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 8
    p-description = 'github namespace and name should be lowercased'.
    p-purl = 'pkg:github/Package-url/p-Spec@244fd47e07d1004f0aed9c'.
    p-canonical_purl = 'pkg:github/package-url/p-spec@244fd47e07d1004f0aed9c'.
    p-type = 'github'.
    p-namespace = 'package-url'.
    p-name = 'p-spec'.
    p-version = '244fd47e07d1004f0aed9c'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 9
    p-description = 'debian can use qualifiers'.
    p-purl = 'pkg:deb/debian/curl@7.50.3-1?arch=i386&distro=jessie'.
    p-canonical_purl = 'pkg:deb/debian/curl@7.50.3-1?arch=i386&distro=jessie'.
    p-type = 'deb'.
    p-namespace = 'debian'.
    p-name = 'curl'.
    p-version = '7.50.3-1'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'arch=i386' TO p-qualifiers.
    APPEND 'distro=jessie' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 10
    p-description = 'docker uses qualifiers and hash image id as versions'.
    p-purl = 'pkg:docker/customer/dockerimage@sha256:244fd47e07d1004f0aed9c?repository_url=gcr.io'.
    p-canonical_purl = 'pkg:docker/customer/dockerimage@sha256:244fd47e07d1004f0aed9c?repository_url=gcr.io'.
    p-type = 'docker'.
    p-namespace = 'customer'.
    p-name = 'dockerimage'.
    p-version = 'sha256:244fd47e07d1004f0aed9c'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'repository_url=gcr.io' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 11
    p-description = 'Java gem can use a qualifier'.
    p-purl = 'pkg:gem/jruby-launcher@1.1.2?Platform=java'.
    p-canonical_purl = 'pkg:gem/jruby-launcher@1.1.2?platform=java'.
    p-type = 'gem'.
    p-namespace = ''.
    p-name = 'jruby-launcher'.
    p-version = '1.1.2'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'platform=java' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 12
    p-description = 'maven often uses qualifiers'.
    p-purl = 'pkg:Maven/org.apache.xmlgraphics/batik-anim@1.9.1?classifier=sources&repositorY_url=repo.spring.io/release'.
    p-canonical_purl = 'pkg:maven/org.apache.xmlgraphics/batik-anim@1.9.1?classifier=sources&repository_url=repo.spring.io/release'.
    p-type = 'maven'.
    p-namespace = 'org.apache.xmlgraphics'.
    p-name = 'batik-anim'.
    p-version = '1.9.1'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'classifier=sources' TO p-qualifiers.
    APPEND 'repository_url=repo.spring.io/release' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 13
    p-description = 'maven pom reference'.
    p-purl = 'pkg:Maven/org.apache.xmlgraphics/batik-anim@1.9.1?extension=pom&repositorY_url=repo.spring.io/release'.
    p-canonical_purl = 'pkg:maven/org.apache.xmlgraphics/batik-anim@1.9.1?extension=pom&repository_url=repo.spring.io/release'.
    p-type = 'maven'.
    p-namespace = 'org.apache.xmlgraphics'.
    p-name = 'batik-anim'.
    p-version = '1.9.1'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'extension=pom' TO p-qualifiers.
    APPEND 'repository_url=repo.spring.io/release' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 14
    p-description = 'maven can come with a type qualifier'.
    p-purl = 'pkg:Maven/net.sf.jacob-project/jacob@1.14.3?classifier=x86&type=dll'.
    p-canonical_purl = 'pkg:maven/net.sf.jacob-project/jacob@1.14.3?classifier=x86&type=dll'.
    p-type = 'maven'.
    p-namespace = 'net.sf.jacob-project'.
    p-name = 'jacob'.
    p-version = '1.14.3'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'classifier=x86' TO p-qualifiers.
    APPEND 'type=dll' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 15
    p-description = 'npm can be scoped'.
    p-purl = 'pkg:npm/%40angular/animation@12.3.1'.
    p-canonical_purl = 'pkg:npm/%40angular/animation@12.3.1'.
    p-type = 'npm'.
    p-namespace = '@angular'.
    p-name = 'animation'.
    p-version = '12.3.1'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 16
    p-description = 'nuget names are case sensitive'.
    p-purl = 'pkg:Nuget/EnterpriseLibrary.Common@6.0.1304'.
    p-canonical_purl = 'pkg:nuget/EnterpriseLibrary.Common@6.0.1304'.
    p-type = 'nuget'.
    p-namespace = ''.
    p-name = 'EnterpriseLibrary.Common'.
    p-version = '6.0.1304'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 17
    p-description = 'pypi names have special rules and not case sensitive'.
    p-purl = 'pkg:PYPI/Django_package@1.11.1.dev1'.
    p-canonical_purl = 'pkg:pypi/django-package@1.11.1.dev1'.
    p-type = 'pypi'.
    p-namespace = ''.
    p-name = 'django-package'.
    p-version = '1.11.1.dev1'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 18
    p-description = 'rpm often use qualifiers'.
    p-purl = 'pkg:Rpm/fedora/curl@7.50.3-1.fc25?Arch=i386&Distro=fedora-25'.
    p-canonical_purl = 'pkg:rpm/fedora/curl@7.50.3-1.fc25?arch=i386&distro=fedora-25'.
    p-type = 'rpm'.
    p-namespace = 'fedora'.
    p-name = 'curl'.
    p-version = '7.50.3-1.fc25'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'arch=i386' TO p-qualifiers.
    APPEND 'distro=fedora-25' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 19
    p-description = 'a scheme is always required'.
    p-purl = 'EnterpriseLibrary.Common@6.0.1304'.
    p-canonical_purl = 'EnterpriseLibrary.Common@6.0.1304'.
    p-type = ''.
    p-namespace = ''.
    p-name = 'EnterpriseLibrary.Common'.
    p-version = ''.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 20
    p-description = 'a type is always required'.
    p-purl = 'pkg:EnterpriseLibrary.Common@6.0.1304'.
    p-canonical_purl = 'pkg:EnterpriseLibrary.Common@6.0.1304'.
    p-type = ''.
    p-namespace = ''.
    p-name = 'EnterpriseLibrary.Common'.
    p-version = '6.0.1304'.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 21
    p-description = 'a name is required'.
    p-purl = 'pkg:maven/@1.3.4'.
    p-canonical_purl = 'pkg:maven/@1.3.4'.
    p-type = 'maven'.
    p-namespace = ''.
    p-name = ''.
    p-version = ''.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 22
    p-description = 'slash / after scheme is not significant'.
    p-purl = 'pkg:/maven/org.apache.commons/io'.
    p-canonical_purl = 'pkg:maven/org.apache.commons/io'.
    p-type = 'maven'.
    p-namespace = 'org.apache.commons'.
    p-name = 'io'.
    p-version = ''.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 23
    p-description = 'double slash // after scheme is not significant'.
    p-purl = 'pkg://maven/org.apache.commons/io'.
    p-canonical_purl = 'pkg:maven/org.apache.commons/io'.
    p-type = 'maven'.
    p-namespace = 'org.apache.commons'.
    p-name = 'io'.
    p-version = ''.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 24
    p-description = 'slash /// after scheme is not significant'.
    p-purl = 'pkg:///maven/org.apache.commons/io'.
    p-canonical_purl = 'pkg:maven/org.apache.commons/io'.
    p-type = 'maven'.
    p-namespace = 'org.apache.commons'.
    p-name = 'io'.
    p-version = ''.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 25
    p-description = 'valid maven purl with case sensitive namespace and name'.
    p-purl = 'pkg:maven/HTTPClient/HTTPClient@0.3-3'.
    p-canonical_purl = 'pkg:maven/HTTPClient/HTTPClient@0.3-3'.
    p-type = 'maven'.
    p-namespace = 'HTTPClient'.
    p-name = 'HTTPClient'.
    p-version = '0.3-3'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 26
    p-description = 'valid maven purl containing a space in the version and qualifier'.
    p-purl = 'pkg:maven/mygroup/myartifact@1.0.0%20Final?mykey=my%20value'.
    p-canonical_purl = 'pkg:maven/mygroup/myartifact@1.0.0%20Final?mykey=my%20value'.
    p-type = 'maven'.
    p-namespace = 'mygroup'.
    p-name = 'myartifact'.
    p-version = '1.0.0 Final'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'mykey=my value' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 27
    p-description = 'checks for invalid qualifier keys'.
    p-purl = 'pkg:npm/myartifact@1.0.0?in%20production=true'.
    p-canonical_purl = ''.
    p-type = 'npm'.
    p-namespace = ''.
    p-name = 'myartifact'.
    p-version = '1.0.0'.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND 'in production=true' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 28
    p-description = 'valid conan purl'.
    p-purl = 'pkg:conan/cctz@2.3'.
    p-canonical_purl = 'pkg:conan/cctz@2.3'.
    p-type = 'conan'.
    p-namespace = ''.
    p-name = 'cctz'.
    p-version = '2.3'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 29
    p-description = 'valid conan purl with namespace and qualifier channel'.
    p-purl = 'pkg:conan/bincrafters/cctz@2.3?channel=stable'.
    p-canonical_purl = 'pkg:conan/bincrafters/cctz@2.3?channel=stable'.
    p-type = 'conan'.
    p-namespace = 'bincrafters'.
    p-name = 'cctz'.
    p-version = '2.3'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'channel=stable' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 30
    p-description = 'invalid conan purl only namespace'.
    p-purl = 'pkg:conan/bincrafters/cctz@2.3'.
    p-canonical_purl = 'pkg:conan/bincrafters/cctz@2.3'.
    p-type = 'conan'.
    p-namespace = 'bincrafters'.
    p-name = 'cctz'.
    p-version = '2.3'.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 31
    p-description = 'invalid conan purl only channel qualifier'.
    p-purl = 'pkg:conan/cctz@2.3?channel=stable'.
    p-canonical_purl = 'pkg:conan/cctz@2.3?channel=stable'.
    p-type = 'conan'.
    p-namespace = ''.
    p-name = 'cctz'.
    p-version = '2.3'.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND 'channel=stable' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 32
    p-description = 'valid conda purl with qualifiers'.
    p-purl = 'pkg:conda/absl-py@0.4.1?build=py36h06a4308_0&channel=main&subdir=linux-64&type=tar.bz2'.
    p-canonical_purl = 'pkg:conda/absl-py@0.4.1?build=py36h06a4308_0&channel=main&subdir=linux-64&type=tar.bz2'.
    p-type = 'conda'.
    p-namespace = ''.
    p-name = 'absl-py'.
    p-version = '0.4.1'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'build=py36h06a4308_0' TO p-qualifiers.
    APPEND 'channel=main' TO p-qualifiers.
    APPEND 'subdir=linux-64' TO p-qualifiers.
    APPEND 'type=tar.bz2' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 33
    p-description = 'valid cran purl'.
    p-purl = 'pkg:cran/A3@0.9.1'.
    p-canonical_purl = 'pkg:cran/A3@0.9.1'.
    p-type = 'cran'.
    p-namespace = ''.
    p-name = 'A3'.
    p-version = '0.9.1'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 34
    p-description = 'invalid cran purl without name'.
    p-purl = 'pkg:cran/@0.9.1'.
    p-canonical_purl = 'pkg:cran/@0.9.1'.
    p-type = 'cran'.
    p-namespace = ''.
    p-name = ''.
    p-version = '0.9.1'.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 35
    p-description = 'invalid cran purl without version'.
    p-purl = 'pkg:cran/A3'.
    p-canonical_purl = 'pkg:cran/A3'.
    p-type = 'cran'.
    p-namespace = ''.
    p-name = 'A3'.
    p-version = ''.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 36
    p-description = 'valid swift purl'.
    p-purl = 'pkg:swift/github.com/Alamofire/Alamofire@5.4.3'.
    p-canonical_purl = 'pkg:swift/github.com/Alamofire/Alamofire@5.4.3'.
    p-type = 'swift'.
    p-namespace = 'github.com/Alamofire'.
    p-name = 'Alamofire'.
    p-version = '5.4.3'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 37
    p-description = 'invalid swift purl without namespace'.
    p-purl = 'pkg:swift/Alamofire@5.4.3'.
    p-canonical_purl = 'pkg:swift/Alamofire@5.4.3'.
    p-type = 'swift'.
    p-namespace = ''.
    p-name = 'Alamofire'.
    p-version = '5.4.3'.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 38
    p-description = 'invalid swift purl without name'.
    p-purl = 'pkg:swift/github.com/Alamofire/@5.4.3'.
    p-canonical_purl = 'pkg:swift/github.com/Alamofire/@5.4.3'.
    p-type = 'swift'.
    p-namespace = 'github.com/Alamofire'.
    p-name = ''.
    p-version = '5.4.3'.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 39
    p-description = 'invalid swift purl without version'.
    p-purl = 'pkg:swift/github.com/Alamofire/Alamofire'.
    p-canonical_purl = 'pkg:swift/github.com/Alamofire/Alamofire'.
    p-type = 'swift'.
    p-namespace = 'github.com/Alamofire'.
    p-name = 'Alamofire'.
    p-version = ''.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 40
    p-description = 'valid hackage purl'.
    p-purl = 'pkg:hackage/AC-HalfInteger@1.2.1'.
    p-canonical_purl = 'pkg:hackage/AC-HalfInteger@1.2.1'.
    p-type = 'hackage'.
    p-namespace = ''.
    p-name = 'AC-HalfInteger'.
    p-version = '1.2.1'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 41
    p-description = 'name and version are always required'.
    p-purl = 'pkg:hackage'.
    p-canonical_purl = 'pkg:hackage'.
    p-type = 'hackage'.
    p-namespace = ''.
    p-name = ''.
    p-version = ''.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 42
    p-description = 'minimal Hugging Face model'.
    p-purl = 'pkg:huggingface/distilbert-base-uncased@043235d6088ecd3dd5fb5ca3592b6913fd516027'.
    p-canonical_purl = 'pkg:huggingface/distilbert-base-uncased@043235d6088ecd3dd5fb5ca3592b6913fd516027'.
    p-type = 'huggingface'.
    p-namespace = ''.
    p-name = 'distilbert-base-uncased'.
    p-version = '043235d6088ecd3dd5fb5ca3592b6913fd516027'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 43
    p-description = 'Hugging Face model with staging endpoint'.
    p-purl = 'pkg:huggingface/microsoft/deberta-v3-base@559062ad13d311b87b2c455e67dcd5f1c8f65111?repository_url=https://hub-ci.huggingface.co'.
    p-canonical_purl = 'pkg:huggingface/microsoft/deberta-v3-base@559062ad13d311b87b2c455e67dcd5f1c8f65111?repository_url=https://hub-ci.huggingface.co'.
    p-type = 'huggingface'.
    p-namespace = 'microsoft'.
    p-name = 'deberta-v3-base'.
    p-version = '559062ad13d311b87b2c455e67dcd5f1c8f65111'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'repository_url=https://hub-ci.huggingface.co' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 44
    p-description = 'Hugging Face model with various cases'.
    p-purl = 'pkg:huggingface/EleutherAI/gpt-neo-1.3B@797174552AE47F449AB70B684CABCB6603E5E85E'.
    p-canonical_purl = 'pkg:huggingface/EleutherAI/gpt-neo-1.3B@797174552ae47f449ab70b684cabcb6603e5e85e'.
    p-type = 'huggingface'.
    p-namespace = 'EleutherAI'.
    p-name = 'gpt-neo-1.3B'.
    p-version = '797174552ae47f449ab70b684cabcb6603e5e85e'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 45
    p-description = 'MLflow model tracked in Azure Databricks (case insensitive)'.
    p-purl = 'pkg:mlflow/CreditFraud@3?repository_url=https://adb-5245952564735461.0.azuredatabricks.net/api/2.0/mlflow'.
    p-canonical_purl = 'pkg:mlflow/creditfraud@3?repository_url=https://adb-5245952564735461.0.azuredatabricks.net/api/2.0/mlflow'.
    p-type = 'mlflow'.
    p-namespace = ''.
    p-name = 'creditfraud'.
    p-version = '3'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'repository_url=https://adb-5245952564735461.0.azuredatabricks.net/api/2.0/mlflow' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 46
    p-description = 'MLflow model tracked in Azure ML (case sensitive)'.
    p-purl = 'pkg:mlflow/CreditFraud@3?repository_url=https://westus2.api.azureml.ms/mlflow/v1.0/subscriptions/a50f2011-fab8-4164-af23-c62881ef8c95/resourceGroups/TestResourceGroup/providers/Microsoft.MachineLearningServices/workspaces/TestWorkspace'.
    p-canonical_purl =
    'pkg:mlflow/CreditFraud@3?repository_url=https://westus2.api.azureml.ms/mlflow/v1.0/subscriptions/a50f2011-fab8-4164-af23-c62881ef8c95/resourceGroups/TestResourceGroup/providers/Microsoft.MachineLearningServices/workspaces/TestWorkspace'.
    p-type = 'mlflow'.
    p-namespace = ''.
    p-name = 'CreditFraud'.
    p-version = '3'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'repository_url=https://westus2.api.azureml.ms/mlflow/v1.0/subscriptions/a50f2011-fab8-4164-af23-c62881ef8c95/resourceGroups/TestResourceGroup/providers/Microsoft.MachineLearningServices/workspaces/TestWorkspace' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 47
    p-description = 'MLflow model with unique identifiers'.
    p-purl = 'pkg:mlflow/trafficsigns@10?model_uuid=36233173b22f4c89b451f1228d700d49&run_id=410a3121-2709-4f88-98dd-dba0ef056b0a&repository_url=https://adb-5245952564735461.0.azuredatabricks.net/api/2.0/mlflow'.
    p-canonical_purl = 'pkg:mlflow/trafficsigns@10?model_uuid=36233173b22f4c89b451f1228d700d49&repository_url=https://adb-5245952564735461.0.azuredatabricks.net/api/2.0/mlflow&run_id=410a3121-2709-4f88-98dd-dba0ef056b0a'.
    p-type = 'mlflow'.
    p-namespace = ''.
    p-name = 'trafficsigns'.
    p-version = '10'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND 'model_uuid=36233173b22f4c89b451f1228d700d49' TO p-qualifiers.
    APPEND 'run_id=410a3121-2709-4f88-98dd-dba0ef056b0a' TO p-qualifiers.
    APPEND 'repository_url=https://adb-5245952564735461.0.azuredatabricks.net/api/2.0/mlflow' TO p-qualifiers.
    APPEND p TO tests.

    CLEAR p. " 48
    p-description = 'composer names are not case sensitive'.
    p-purl = 'pkg:composer/Laravel/Laravel@5.5.0'.
    p-canonical_purl = 'pkg:composer/laravel/laravel@5.5.0'.
    p-type = 'composer'.
    p-namespace = 'laravel'.
    p-name = 'laravel'.
    p-version = '5.5.0'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 49
    p-description = 'cpan distribution name are case sensitive'.
    p-purl = 'pkg:cpan/DROLSKY/DateTime@1.55'.
    p-canonical_purl = 'pkg:cpan/DROLSKY/DateTime@1.55'.
    p-type = 'cpan'.
    p-namespace = 'DROLSKY'.
    p-name = 'DateTime'.
    p-version = '1.55'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 50
    p-description = 'cpan module name are case sensitive'.
    p-purl = 'pkg:cpan/URI::PackageURL@2.11'.
    p-canonical_purl = 'pkg:cpan/URI::PackageURL@2.11'.
    p-type = 'cpan'.
    p-namespace = ''.
    p-name = 'URI::PackageURL'.
    p-version = '2.11'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 51
    p-description = 'cpan module name like distribution name'.
    p-purl = 'pkg:cpan/Perl-Version@1.013'.
    p-canonical_purl = 'pkg:cpan/Perl-Version@1.013'.
    p-type = 'cpan'.
    p-namespace = ''.
    p-name = 'Perl-Version'.
    p-version = '1.013'.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 52
    p-description = 'cpan distribution name like module name'.
    p-purl = 'pkg:cpan/GDT/URI::PackageURL@2.11'.
    p-canonical_purl = 'pkg:cpan/GDT/URI::PackageURL'.
    p-type = 'cpan'.
    p-namespace = 'GDT'.
    p-name = 'URI::PackageURL'.
    p-version = ''.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 53
    p-description = 'cpan valid module name'.
    p-purl = 'pkg:cpan/DateTime@1.55'.
    p-canonical_purl = 'pkg:cpan/DateTime@1.55'.
    p-type = 'cpan'.
    p-namespace = ''.
    p-name = 'DateTime'.
    p-version = '1.55'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 54
    p-description = 'cpan valid module name without version'.
    p-purl = 'pkg:cpan/URI'.
    p-canonical_purl = 'pkg:cpan/URI'.
    p-type = 'cpan'.
    p-namespace = ''.
    p-name = 'URI'.
    p-version = ''.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 55 - note: bintray is not an approved valid type
    p-description = 'ensure namespace allows multiple segments'.
    p-purl = 'pkg:bintray/apache/couchdb/couchdb-mac@2.3.0'.
    p-canonical_purl = 'pkg:bintray/apache/couchdb/couchdb-mac@2.3.0'.
    p-type = 'bintray'.
    p-namespace = 'apache/couchdb'.
    p-name = 'couchdb-mac'.
    p-version = '2.3.0'.
    p-subpath = ''.
    p-is_invalid = abap_false.
    APPEND p TO tests.

    CLEAR p. " 56
    p-description = 'invalid encoded colon : between scheme and type'.
    p-purl = 'pkg%3Amaven/org.apache.commons/io'.
    p-canonical_purl = ''.
    p-type = 'maven'.
    p-namespace = 'org.apache.commons'.
    p-name = 'io'.
    p-version = ''.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 57
    p-description = 'check for invalid character in type'.
    p-purl = 'pkg:n&g?inx/nginx@0.8.9'.
    p-canonical_purl = ''.
    p-type = ''.
    p-namespace = ''.
    p-name = 'nginx'.
    p-version = '0.8.9'.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 58
    p-description = 'check for type that starts with number'.
    p-purl = 'pkg:3nginx/nginx@0.8.9'.
    p-canonical_purl = ''.
    p-type = ''.
    p-namespace = ''.
    p-name = 'nginx'.
    p-version = '0.8.9'.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

    CLEAR p. " 59
    p-description = 'check for colon in type'.
    p-purl = 'pkg:nginx:a/nginx@0.8.9'.
    p-canonical_purl = ''.
    p-type = ''.
    p-namespace = ''.
    p-name = 'nginx'.
    p-version = '0.8.9'.
    p-subpath = ''.
    p-is_invalid = abap_true.
    APPEND p TO tests.

  ENDMETHOD.

  METHOD test.

    " Note: bintray is not an approved type so we exclude it
    LOOP AT tests INTO p WHERE type <> 'bintray'.
      TRY.
          DATA(msg) = |{ sy-tabix }: { p-description }: |.

          IF sy-tabix = 99.
            BREAK-POINT.
          ENDIF.

          DATA(purl) = /apmg/cl_purl=>parse( p-purl ).

          IF p-is_invalid = abap_true.
            cl_abap_unit_assert=>fail( msg && 'is_invalid' ).
          ENDIF.

          cl_abap_unit_assert=>assert_equals(
            act = purl->components-scheme
            exp = 'pkg'
            msg = msg && 'scheme' ).
          cl_abap_unit_assert=>assert_equals(
            act = purl->components-type
            exp = p-type
            msg = msg && 'type' ).
          cl_abap_unit_assert=>assert_equals(
            act = purl->components-namespace
            exp = p-namespace
            msg = msg && 'namespace' ).
          cl_abap_unit_assert=>assert_equals(
            act = purl->components-name
            exp = p-name
            msg = msg && 'name' ).
          cl_abap_unit_assert=>assert_equals(
            act = purl->components-version
            exp = p-version
            msg = msg && 'version' ).
          cl_abap_unit_assert=>assert_equals(
            act = lines( purl->components-qualifiers )
            exp = lines( p-qualifiers )
            msg = msg && 'qualifiers' ).
          cl_abap_unit_assert=>assert_equals(
            act = purl->components-subpath
            exp = p-subpath
            msg = msg && 'subpath' ).

        CATCH /apmg/cx_error INTO DATA(error).
          IF p-is_invalid = abap_false.
            cl_abap_unit_assert=>fail( |{ msg }{ error->get_text( ) }| ).
          ENDIF.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
