Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60315 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757666Ab2JKABT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Oct 2012 20:01:19 -0400
Date: Thu, 11 Oct 2012 11:01:26 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] mount.nfs mapage: clear up confusion between 'proto' and
 'transport'
Message-ID: <20121011110126.44669d79@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/62yx7810skgxwndJdSe4Taa"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/62yx7810skgxwndJdSe4Taa
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



The mount option "proto=3D" actually set the "transport" which in
netconfig usage is the pairing of a protocol (e.g. UDP, TCP) with
a protocol family (e.g. INET, INET6).

This can cause confusion if people naively except "proto=3Dudp" to work
equally well on IPv6.

So add some text to both nfs(5) and nfsmount.conf(5) to hopefully
clarify this.

Acked-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: NeilBrown <neilb@suse.de>

--
Hi Steve,
 please apply this to nfs-utils.
Thanks,
NeilBrown


diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index da6d6d3..c15de98 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1,5 +1,5 @@
 .\"@(#)nfs.5"
-.TH NFS 5 "2 November 2007"
+.TH NFS 5 "9 October 2012"
 .SH NAME
 nfs \- fstab format and options for the
 .B nfs
@@ -472,24 +472,15 @@ Use these options, along with the options in the abov=
e subsection,
 for NFS versions 2 and 3 only.
 .TP 1.5i
 .BI proto=3D netid
-The transport protocol name and protocol family the NFS client uses
-to transmit requests to the NFS server for this mount point.
-If an NFS server has both an IPv4 and an IPv6 address, using a specific
-netid will force the use of IPv4 or IPv6 networking to communicate
-with that server.
-.IP
-If support for TI-RPC is built into the
-.B mount.nfs
-command,
-.I netid
-is a valid netid listed in
-.IR /etc/netconfig .
-The value "rdma" may also be specified.
-If the
-.B mount.nfs
-command does not have TI-RPC support, then
+The
 .I netid
-is one of "tcp," "udp," or "rdma," and only IPv4 may be used.
+determines the transport that is used to communicate with the NFS
+server.  Available options are
+.BR udp ", " udp6 ", "tcp ", " tcp6 ", and " rdma .
+Those which end in
+.B 6
+use IPv6 addresses and are only available if support for TI-RPC is
+built in. Others use IPv4 addresses.
 .IP
 Each transport protocol uses different default
 .B retrans
@@ -569,19 +560,18 @@ This option can be used when mounting an NFS server
 through a firewall that blocks the rpcbind protocol.
 .TP 1.5i
 .BI mountproto=3D netid
-The transport protocol name and protocol family the NFS client uses
+The transport the NFS client uses
 to transmit requests to the NFS server's mountd service when performing
 this mount request, and when later unmounting this mount point.
 .IP
-If support for TI-RPC is built into the
+.I netid
+may be one of
+.BR udp ", and " tcp
+which use IPv4 address or, if TI-RPC is built into the
 .B mount.nfs
 command,
-.I netid
-is a valid netid listed in
-.IR /etc/netconfig .
-Otherwise,
-.I netid
-is one of "tcp" or "udp," and only IPv4 may be used.
+.BR udp6 ", and " tcp6
+which use IPv6 addresses.
 .IP
 This option can be used when mounting an NFS server
 through a firewall that blocks a particular transport.
@@ -773,21 +763,14 @@ Use these options, along with the options in the firs=
t subsection above,
 for NFS version 4 and newer.
 .TP 1.5i
 .BI proto=3D netid
-The transport protocol name and protocol family the NFS client uses
-to transmit requests to the NFS server for this mount point.
-If an NFS server has both an IPv4 and an IPv6 address, using a specific
-netid will force the use of IPv4 or IPv6 networking to communicate
-with that server.
-.IP
-If support for TI-RPC is built into the
-.B mount.nfs
-command,
-.I netid
-is a valid netid listed in
-.IR /etc/netconfig .
-Otherwise,
+The
 .I netid
-is one of "tcp" or "udp," and only IPv4 may be used.
+determines the transport that is used to communicate with the NFS
+server.  Supported options are
+.BR tcp ", " tcp6 ", and " rdma .
+.B tcp6
+use IPv6 addresses and is only available if support for TI-RPC is
+built in. Both others use IPv4 addresses.
 .IP
 All NFS version 4 servers are required to support TCP,
 so if this mount option is not specified, the NFS version 4 client
@@ -851,6 +834,8 @@ The DATA AND METADATA COHERENCE section discusses
 the behavior of this option in more detail.
 .TP 1.5i
 .BI clientaddr=3D n.n.n.n
+.TP 1.5i
+.BI clientaddr=3D n:n: ... :n
 Specifies a single IPv4 address (in dotted-quad form),
 or a non-link-local IPv6 address,
 that the NFS client advertises to allow servers
diff --git a/utils/mount/nfsmount.conf.man b/utils/mount/nfsmount.conf.man
index 12a3fe7..3aa3456 100644
--- a/utils/mount/nfsmount.conf.man
+++ b/utils/mount/nfsmount.conf.man
@@ -1,5 +1,5 @@
 .\"@(#)nfsmount.conf.5"
-.TH NFSMOUNT.CONF 5 "9 Mar 2008"
+.TH NFSMOUNT.CONF 5 "9 October 2012"
 .SH NAME
 nfsmount.conf - Configuration file for NFS mounts
 .SH SYNOPSIS
@@ -18,6 +18,10 @@ to particular variables using the
 .BR =3D=20
 operator, as in=20
 .BR Proto=3DTcp .
+The variables that can be assigned are exactly the set of NFS specific
+mount options listed in
+.BR nfs (5).
+.PP
 Sections are broken up into three basic categories:
 Global options, Server options and Mount Point options.
 .HP
@@ -54,7 +58,7 @@ are defined in the configuration file.
     Proto=3DTcp
 .RS
 .HP
-The TCP protocol will be used on every NFS mount.
+The TCP/IPv4 protocol will be used on every NFS mount.
 .HP
 .RE
 [ Server \(lqnfsserver.foo.com\(rq ]
@@ -62,10 +66,13 @@ The TCP protocol will be used on every NFS mount.
     rsize=3D32k
 .br
     wsize=3D32k
+.br
+    proto=3Dudp6
 .HP
 .RS
-A 33k (32768 bytes) block size will be used as the read and write
-size on all mounts to the 'nfsserver.foo.com' server.
+A 32k (32768 bytes) block size will be used as the read and write
+size on all mounts to the 'nfsserver.foo.com' server.  UDP/IPv6
+is the protocol to be used.
 .HP
 .RE
 .BR=20

--Sig_/62yx7810skgxwndJdSe4Taa
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUHYMVjnsnt1WYoG5AQI56g//YD6pW1OlvU9P+77R1wfha+xuoMb+0h3T
DU2/G9PDHIFTPXiouJVRQCu5W9hpvCHeJ5iawPug9ai6TZIlV/uuTLyztqhGtm+6
SC/7yqAOGnU2U2IebExZ+eBFFOO2UbzVZSfNy+rHmRwZ+ONWbN8GMy+3+EtKUU1X
VSRrWZ1LlgEa3Gw8ttpmNLf6SrwSMszcHIn/GcppumJERiecVlAU1S7MsgRzQ0kJ
Cw+CuU0NCM8PssD60ScXLLoS1PZNbNVi7PApEeKJhykC7+xx9hYlBQuzlUiT0yEF
IOgMEoAZYDwwlWP3Ny8GfNrg/frZnBh+rKhtkb9sj3dallsV5YwIHXqeQM49C2jf
LeJZiI8J6BU10l764tw5FyGdawH+iPZ4mcTtd56SaHgArW7/3yTgYPC0xDwe1s+B
QurOP0vO6JqQAnTMVY9n9WlVytnWTMAhqDUTyATJhX5//WtdbGaueP/3iN/yHQef
/oTvnaEojGzE1afk/NrJWMhT9FCpbImzmrGK7XdZWKctE6Yo0fl/OfzfpJIZ2VZ9
N25Tp7Def0pL/W/hPvSazUhksRy9hLA3us0TQCbquIJFQMzASuakdAAZaZ1MKnL8
nHYer9XpIkkJe6vQ98lJn772T7zBQDEpe40Zf5UtdXRdfBOJFoeNRk7lpg7jmjF5
aLqtEp/KXRs=
=GU5j
-----END PGP SIGNATURE-----

--Sig_/62yx7810skgxwndJdSe4Taa--
