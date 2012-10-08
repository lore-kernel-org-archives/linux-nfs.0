Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34877 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751477Ab2JHDfp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Oct 2012 23:35:45 -0400
Date: Mon, 8 Oct 2012 14:35:50 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Should "mount -o proto=udp" be usable against an IPv6 only
 server?
Message-ID: <20121008143550.68b4aa45@notabene.brown>
In-Reply-To: <11D4587E-7739-4D31-836D-D63177D13302@oracle.com>
References: <11D4587E-7739-4D31-836D-D63177D13302@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/5TGpxW.BKIDPS.ssTtfm472"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/5TGpxW.BKIDPS.ssTtfm472
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 3 Oct 2012 21:15:16 -0700 Chuck Lever <chuck.lever@oracle.com> wrot=
e:

> Hi-
>=20
> Unfortunately our corporate e-mail server lost your e-mail from yesterday=
.  I read it last night and was going to reply this morning, but it was gon=
e from my mailbox.  I'm not sure how to preserve the thread structure at th=
is point.
>=20
> I'm OK with the nfsmount.conf() changes, and the addition of IPv6 syntax =
to the clientaddr=3D option.
>=20
> >> The protocol and protocol family the NFS client uses to transmit reque=
sts to the NFS server for this mount point.  For example, udp selects UDP o=
ver IPv4, while tcp6 selects TCP over IPv6.  If an NFS server has both an I=
Pv4 and an IPv6 address, using a specific netid forces the use of IPv4 or I=
Pv6 networking to communicate with that server.
> >=20
> > I still don't like that last sentence.
>=20
> Can you say why?

Its meaning is not at all clear.  It tells me that some set of circumstances
will "force the use of IPv4 or IPv6 networking" - given that their isn't
really any other sort of networking (except maybe RDMA?), I'm not at all
surprised that it will either use IPv4 or IPv6.  But the sentence doesn't
tell me how the netid has anything to do with this obvious outcome.

Even if I'm generous and understand that some specific netids will force IP=
v4
while other specific netids will force IPv6 (and conveniently forget that
'rdma' won't force either), this is true whether the NFS server is
dual-stack, or has either possible single stack.  So the introductory clause
it irrelevant to the conclusion.

>=20
> While that sentence could be made more precise, this is one of the key re=
asons NFS with netids works the way it does.  Dual-stack NFS servers will b=
e pervasive for some time to come.
>=20
> Other comments:
>=20
>   o "rdma6" is not supported, and should not be explicitly listed.

Even though support/nfs/getport.c mentioned it...
OK, I'll remove that.  I was assuming it might be close given that nfs-utils
seemed to support it, but apparently not.

>=20
>   o "mountproto=3Drdma[6]" is not supported.
>=20
>   o We discourage the use of UDP with NFSv4 (in fact it may no longer be =
supported).  The NFSv4 proto=3D language should not list "udp" or "udp6."

It does work ...
I guess if I change it to "Supported options" rather than "Available option=
s"
I can bring my self to remove those two...

Is this worth an acked-by yet :-)

Thanks,
NeilBrown

=46rom d960e53f3271b9bc1d398d13aee856c4a675df81 Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Tue, 2 Oct 2012 15:21:46 +1000
Subject: [PATCH] mount.nfs mapage: clear up confusion between 'proto' and
 'transport'

The mount option "proto=3D" actually set the "transport" which in
netconfig usage is the paring of a protocol (e.g. UDP, TCP) with
a protocol family (e.g. INET, INET6).

This can cause confusion if people naively except "proto=3Dudp" to work
equally well on IPv6.

So add some text to both nfs(5) and nfsmount.conf(5) to hopefully
clarify this.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index da6d6d3..1eeba80 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1,5 +1,5 @@
 .\"@(#)nfs.5"
-.TH NFS 5 "2 November 2007"
+.TH NFS 5 "19 September 2012"
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
@@ -573,15 +564,14 @@ The transport protocol name and protocol family the N=
FS client uses
 to transmit requests to the NFS server's mountd service when performing
 this mount request, and when later unmounting this mount point.
 .IP
-If support for TI-RPC is built into the
+.I netid
+may be one of
+.BR udp ", " tcp ", and " rdma
+which use IPv4 address or, if TI-RPC is built into the
 .B mount.nfs
 command,
-.I netid
-is a valid netid listed in
-.IR /etc/netconfig .
-Otherwise,
-.I netid
-is one of "tcp" or "udp," and only IPv4 may be used.
+.BR udp6 ", " tcp6 ", and " rdma6
+which use IPv6 addresses.
 .IP
 This option can be used when mounting an NFS server
 through a firewall that blocks a particular transport.
@@ -773,21 +763,15 @@ Use these options, along with the options in the firs=
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
+.BR tcp ", " tcp6 ", and" rdma .
+Those which end in
+.B 6
+use IPv6 addresses and are only available if support for TI-RPC is
+built in. Others use IPv4 addresses.
 .IP
 All NFS version 4 servers are required to support TCP,
 so if this mount option is not specified, the NFS version 4 client
@@ -851,6 +835,8 @@ The DATA AND METADATA COHERENCE section discusses
 the behavior of this option in more detail.
 .TP 1.5i
 .BI clientaddr=3D n.n.n.n
+.TP 1.5i
+.BI clientaddr=3D n:n: ... :n
 Specifies a single IPv4 address (in dotted-quad form),
 or a non-link-local IPv6 address,
 that the NFS client advertises to allow servers
diff --git a/utils/mount/nfsmount.conf.man b/utils/mount/nfsmount.conf.man
index 12a3fe7..2258296 100644
--- a/utils/mount/nfsmount.conf.man
+++ b/utils/mount/nfsmount.conf.man
@@ -1,5 +1,5 @@
 .\"@(#)nfsmount.conf.5"
-.TH NFSMOUNT.CONF 5 "9 Mar 2008"
+.TH NFSMOUNT.CONF 5 "19 September 2012"
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



--Sig_/5TGpxW.BKIDPS.ssTtfm472
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUHJKFjnsnt1WYoG5AQLOAQ//XoBB1opbpiJNlbR4ncIbbSGb2w/FDrLB
3BFcpTV+kSwTl5md6ozxiT5k5TnAJLEI7QCGhgDRUPHqTDJJ1Bf0o2/B/v1tXrGd
lwgXSmcXPtbLCxoxLk3GHKakDOqcYpj0NZUQWTHkbKspzRu6JHXXf1l5zbFA4e3G
8hOEjNyzB31ClYRvmQr6e6E2eP2ZGzd5CD195JgejnQZ2hwb13cOngqrTdvirrzJ
9iceF82zF1FTova68jEdNawalGkIdDq9+yLP7eAY9vId7oQtPL2BQVwDnHSv/vse
QrqRG/CxkGikUDRkRIwMOkEZ0WDgyOzibYOWXwztopKmt6HEaRE59/hqe/IkCfOY
RuSfJEXNEnRp0qMk15LnUJjpQXs4H+IxD3eUVlPMzf/pTN1fbu/WGMACapkPkfw/
dYbf6g+D5RXchjdu7qJOZLD1ghjfeP1F9wpGKhdpLIiJ6H+oX0csigNxjA2ahqve
WmDQhLB1+cvzdjCLzeASUAiJrakdyiMzuX4dX/zu8FdPy2g6fLkl1I3WHBN2jsWs
OSbFDnR2eMzIuoNtvBqSAhLwtU03fY4/7ntQCETpbX8CeiCALgkSnBfkdl/lM5So
SlU+y+xfMPUOO1Bd29nwALv7mfJZFxcTxTW8nTSNmxNkPVXJJ+tFMgu7Khw6Dku4
rYcpKRK14X0=
=8POD
-----END PGP SIGNATURE-----

--Sig_/5TGpxW.BKIDPS.ssTtfm472--
