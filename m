Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38259 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750753Ab2JBFYj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 01:24:39 -0400
Date: Tue, 2 Oct 2012 15:24:40 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Should "mount -o proto=udp" be usable against an IPv6 only
 server?
Message-ID: <20121002152440.2e6a0c04@notabene.brown>
In-Reply-To: <ECD54A5F-C684-4057-96F5-1D29E7A9A551@oracle.com>
References: <20120918115450.5c65973f@notabene.brown>
	<F8762BC2-F211-482E-8B5A-A2E991E3F937@oracle.com>
	<20120918162948.47840d42@notabene.brown>
	<ECDC5BA9-29CC-4867-8737-CA1110E6C4C6@oracle.com>
	<20120919091904.624ee54b@notabene.brown>
	<ECD54A5F-C684-4057-96F5-1D29E7A9A551@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/kWpSVpOXHP6SwzvSX+FGM.D"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/kWpSVpOXHP6SwzvSX+FGM.D
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Sep 2012 21:00:01 -0400 Chuck Lever <chuck.lever@oracle.com> wro=
te:


> Out of interest, do you have a use case that could make positive use of a=
 "please use UDP but I don't care whether its IPv4 or IPv6" setting?

No, but that isn't really the point.
The point is that to anyone not well verse in the lore of TI-RPC, "proto=3D=
udp"
looks like it means "set the protocol to UDP", not "set the protocol to UDP
and the protocol family to IPv4".
One way to clear up the confusion would be to change the meaning of
"proto=3Dudp" to match what most people would epxect it to mean.
The other it to document the non-obvious semantics thoroughly.  I wanted to
consider both options.

> > +A
> > +.I netid
> > +determines both the
> > +.I transport
> > +and
> > +.I network
> > +protocols, so for example
>=20
> "determines both the protocol family and transport" are closer to how the=
se terms are defined in netconfig(5), and I prefer that formulation.  I sti=
ll believe a citation of netconfig(5) would be correct and helpful.  A cita=
tion in the SEE ALSO section should also be added.

(SEE ALSO already mentions netconfig(5).)

Don't you love standards....

ISO OSI seems to use "network" for layer 3 and "transport" for layer 4, whi=
ch
is where I got that names I used.

netconfig(5) uses "protocol family" and "protocol" respectively, and
"transport" to identify the combination of the two (which is also the
network_id).

socket(2) also uses "protocol family" and "protocol", but uses AF as the
prefix for "protocol family" aka "address family" :-)

This does serve to highlight the inappropriateness of using "proto=3D" to
specify the "transport", and the netconfig usage treats the "protocol" as a
just part of the "transport" (but allows e.g. "udp" to be both a protocol a=
nd
a transport depending on context).

It looks like  "protocol" and "protocol family" are the most appropriate
terms in the Unix world, and the examples can clear up any uncertainty:

------------
A
.I netid
determines both the
.I protocol
and
.IR "protocol family" .
So for example
.B udp
selects UDP over IPv4 while
.B tcp6
selects TCP over IPv6.
-----------------
>=20
> As a matter of word smithing, I think starting a new sentence at "so for =
example" would be easier to read.

Agreed.

So how about this.

Thanks,
NeilBrown


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
index da6d6d3..2741a60 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1,5 +1,5 @@
 .\"@(#)nfs.5"
-.TH NFS 5 "2 November 2007"
+.TH NFS 5 "19 September 2012"
 .SH NAME
 nfs \- fstab format and options for the
 .B nfs
@@ -474,9 +474,17 @@ for NFS versions 2 and 3 only.
 .BI proto=3D netid
 The transport protocol name and protocol family the NFS client uses
 to transmit requests to the NFS server for this mount point.
-If an NFS server has both an IPv4 and an IPv6 address, using a specific
-netid will force the use of IPv4 or IPv6 networking to communicate
-with that server.
+A
+.I netid
+determines both the
+.I protocol
+and
+.IR "protocol family" .
+So for example
+.B udp
+selects UDP over IPv4 while
+.B tcp6
+selects TCP over IPv6.
 .IP
 If support for TI-RPC is built into the
 .B mount.nfs
@@ -775,9 +783,17 @@ for NFS version 4 and newer.
 .BI proto=3D netid
 The transport protocol name and protocol family the NFS client uses
 to transmit requests to the NFS server for this mount point.
-If an NFS server has both an IPv4 and an IPv6 address, using a specific
-netid will force the use of IPv4 or IPv6 networking to communicate
-with that server.
+A
+.I netid
+determines both the
+.I transport
+and
+.I network
+protocols, so for example
+.B udp
+selects UDP over IPv4 while
+.B tcp6
+selects TCP over IPv6.
 .IP
 If support for TI-RPC is built into the
 .B mount.nfs
@@ -851,6 +867,8 @@ The DATA AND METADATA COHERENCE section discusses
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

--Sig_/kWpSVpOXHP6SwzvSX+FGM.D
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUGp6mDnsnt1WYoG5AQLRHxAAqd0+KFcGNDO5B7jKPMe6V+JM7PH7ahsV
oxro7Wwc6jRWAqGptNKM2X1ThKD6H2tJAy/mJl0BNKz9ayh7j44MOdmO7s4/dBsm
L+uSZ5bByiWlGLCRekYwoiKsoBIXDDGoPmE7711CvHoqLJWwFtNRDGSQjfCPAnwR
itFZOVLS9yRn44gaWm7FyyRWsndVo03XmS5T1xF4k/T1lDFz/7pX9ahBk8HY80gD
nrcB7Mu4ZNiJBNeE0BfjqIOEeXLjJklK3fqtFfONf/tsrny+pDL/VXG1lmEuhfpp
RrbsfQ8nn2P9vNxLXyxg+RfmKGdy2SahSpyAwWUlLKPo4j5/WM2Dh96Ub68nKve4
3vNyOY1XnWKVJHroTA5BisUDOUcNC6MwujMFBxDigjtyLDyj8nlX6sPg+0IQmUnJ
fRbzIC9gLILEiX1SdqGEJMz4RiXuEezquPxFOXIy5G0sUnaHyCX4sWJNPo8iO4jO
X1YonbklCbcWsnl1SZXM0xY97rSNMHdbKR7LuJpIJn1ve2h8a1fhVHoWVR+wROQR
3zBut+E7rhp/9SXXp+GRtce5NdqNRc3JGZdc3cyNarmWjImRftX7wfW7a9VJ0NXC
Q/iQ5mEY0W4zCNmEjR/nvBM4+rxBTOryksYV0vdoooeMHAKPo8WhNDdRpq82vAWm
igbeSAjBgjA=
=BJNr
-----END PGP SIGNATURE-----

--Sig_/kWpSVpOXHP6SwzvSX+FGM.D--
