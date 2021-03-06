{ stdenv, fetchgit, fetchpatch, autoreconfHook, texinfo, ncurses, readline, zlib, lzo, openssl }:

stdenv.mkDerivation rec {
  name = "tinc-${version}";
  version = "1.1pre14";

  src = fetchgit {
    rev = "refs/tags/release-${version}";
    url = "git://tinc-vpn.org/tinc";
    sha256 = "05an2vj0a3wjv5w672wgzyixbydin5jpja5zv6x81bc72dms0ymc";
  };

  outputs = [ "out" "doc" ];

  nativeBuildInputs = [ autoreconfHook texinfo ];
  buildInputs = [ ncurses readline zlib lzo openssl ];

  prePatch = ''
    substituteInPlace configure.ac --replace UNKNOWN ${version}
  '';

  patches = [
    # Avoid infinite loop with "Error while reading from Linux tun/tap device (tun mode) /dev/net/tun: File descriptor in bad state" on network restart
    (fetchpatch {
      url = https://github.com/gsliepen/tinc/compare/acefa66...e4544db.patch;
      sha256 = "1jz7anqqzk7j96l5ifggc2knp14fmbsjdzfrbncxx0qhb6ihdcvn";
    })
  ];

  postInstall = ''
    rm $out/bin/tinc-gui
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  meta = with stdenv.lib; {
    description = "VPN daemon with full mesh routing";
    longDescription = ''
      tinc is a Virtual Private Network (VPN) daemon that uses tunnelling and
      encryption to create a secure private network between hosts on the
      Internet.  It features full mesh routing, as well as encryption,
      authentication, compression and ethernet bridging.
    '';
    homepage="http://www.tinc-vpn.org/";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ wkennington fpletz ];
  };
}
