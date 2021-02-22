{ ansicolors
, attrs
, autobahn
, buildPythonPackage
, fetchFromGitHub
, jinja2
, lib
, mock
, pexpect
, psutil
, pyserial
, pytestCheckHook
, pytest-dependency
, pytest-mock
, pyudev
, pyusb
, pyyaml
, requests
, setuptools-scm
, xmodem
}:

buildPythonPackage rec {
  pname = "labgrid";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "labgrid-project";
    repo = "labgrid";
    rev = "v${version}";
    sha256 = "15298prs2f4wiyn8lf475qicp3y22lcjdcpwp2fmrya642vnr6w5";
  };

  patches = [
    ./0001-serialdriver-remove-pyserial-version-check.patch
  ];

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    ansicolors
    attrs
    autobahn
    jinja2
    pexpect
    pyserial
    pyudev
    pyusb
    pyyaml
    requests
    xmodem
  ];

  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION="${version}"
  '';

  checkInputs = [
    mock
    psutil
    pytestCheckHook
    pytest-mock
    pytest-dependency
  ];

  disabledTests = [
    "docker"
    "sshmanager"
  ];

  meta = with lib; {
    description = "Embedded control & testing library";
    homepage = "https://labgrid.org";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ emantor ];
    platforms = with platforms; linux;
  };
}
