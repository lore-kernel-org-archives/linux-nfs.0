Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44294 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702Ab2IRXTR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Sep 2012 19:19:17 -0400
Date: Wed, 19 Sep 2012 09:19:04 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Should "mount -o proto=udp" be usable against an IPv6 only
 server?
Message-ID: <20120919091904.624ee54b@notabene.brown>
In-Reply-To: <ECDC5BA9-29CC-4867-8737-CA1110E6C4C6@oracle.com>
References: <20120918115450.5c65973f@notabene.brown>
	<F8762BC2-F211-482E-8B5A-A2E991E3F937@oracle.com>
	<20120918162948.47840d42@notabene.brown>
	<ECDC5BA9-29CC-4867-8737-CA1110E6C4C6@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/j1gRNL/d_4nfKpaWr9cX/qt"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/j1gRNL/d_4nfKpaWr9cX/qt
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Sep 2012 11:31:28 -0400 Chuck Lever <chuck.lever@oracle.com> wro=
te:

>=20
> On Sep 18, 2012, at 2:29 AM, NeilBrown wrote:
>=20
> > On Tue, 18 Sep 2012 01:28:09 -0400 Chuck Lever <chuck.lever@oracle.com>=
 wrote:
> >=20
> >> Hi Neil-
> >>=20
> >> On Sep 17, 2012, at 9:54 PM, NeilBrown wrote:
> >>=20
> >>> It seems that with current nfs-utils, "proto=3Dudp" (either
> >>> in /etc/nfsmount.conf or on the command line) restricts the mount to =
using
> >>> IPv4, not IPv6.
> >>> For IPv6 you need "udp6".
> >>>=20
> >>> This isn't made crystal clear by the documentation.  I could fix the
> >>> documentation, but first I wanted to check if this really is appropri=
ate.
> >>> Is there a good reason for this, or should we make "udp" mean "udp4 o=
r udp6"
> >>> and require either "udp4" or "udp6" if we want a particular IP versio=
n.
> >>>=20
> >>> i.e. instead of treating the "proto=3D" value as a "netid", should we=
 treat it
> >>> as a "protoname" and match any "netid" in /etc/netconfig with that
> >>> "protoname"??
> >>=20
> >> This is working as designed.
> >>=20
> >> The meaning of each netid is defined in RFC 5665.  "udp" means UDP ove=
r IPv4.  This matches precisely what "proto=3Dudp" meant before TI-RPC.  Th=
ese netids force a particular protocol family when the server is specified =
by hostname and not IP address.
> >>=20
> >> What's more, we mean this to match the behavior of the Solaris mount c=
ommand, where "proto=3Dudp" also has this meaning.
> >>=20
> >> Which part of the documentation do you think is unclear?
> >>=20
> >=20
> > Hi Chuck,
> > Thanks for the reply.
> >=20
> > It is unfortunate that the tag "proto" is used to choose the "netid".
> > In common parlance, "udp" and "tcp" are protocols independent of the
> > underlying transport (IPv4 or IPv6)  much as "nfsv3" or "nfsv4" are
> > independent of the underlying transport (tcp, udp6, rdma etc).
> >=20
> > Give this obvious opportunity for confusion it would be good if the
> > documentation took significant steps to minimise it.
> >=20
> > I note that nfs(5) does mention /etc/netconfig and the "netid"s that it
> > contains.  However "udp6" and "tcp6" are never given as examples - doin=
g so
> > would help the reader see the import of the distinction.
> >=20
> >       proto=3Dnetid    The transport protocol name and protocol family =
the  NFS
> >                      client  uses  to transmit requests to the NFS serv=
er for
> >                      this mount point.  If an NFS server has both an IP=
v4 and
> >                      an  IPv6  address, using a specific netid will for=
ce the
> >                      use of IPv4 or IPv6 networking to communicate with=
  that
> >                      server.
> >=20
> > I don't think the second sentence would be very helpful to someone who =
didn't
> > already understand the subtleties.=20
> > Something like:
> >=20
> >    A particular netid completely specifies the protocol, so for example
> >    "tcp" is TCP over IPv4, and "udp6" is UDP over IPv6.  It is not poss=
ible
> >    to request "UDP" without also specifying which version of IP should =
be
> >    used.
>=20
> The "proto=3D" section is already five paragraphs long, thanks to the com=
plexity of transport autonegotiation and RPC timeout settings.  What might =
be better is simply to add "See netconfig(5) for a description of netids."

There are a lot of words in netconfig(5), very few of which are useful to a
sysadmin wanting to deploy NFS.  So I don't think that addition by itself
would be very helpful.

>=20
> >=20
> > man nfsmount.conf gives the example:
> >=20
> >       [ NFSMount_Global_Options ]
> >           Proto=3DTcp
> >=20
> >              The TCP protocol will be used on every NFS mount.
> >=20
> > which is incomplete.  Not just TCP, but TCP/IPv4 will be used on every =
NFS
> > mount.  And again, not IPv6 examples.
>=20
> Agreed, that should be fixed.  A simple reference to nfs(5) would probabl=
y be enough.

Necessary, but not sufficient I think.  References are useful, but if you
have to follow them to understand the documentation, then the documentation
is lacking.

>=20
> > (and nfsmount.conf doesn't mention the "default$OPTION=3Dvalue" syntax.=
..)
> >=20
> >=20
> > For a usability perspective, I think that treating "udp" as meaning
> > "udp/ipv4" is a serious mistake and I'm not at all convinced that "Sola=
ris
> > compatibility" is sufficient justification, but as I have no interest in
> > offering patches, I won't pursue that line of argument further :-)
>=20
> Others have been concerned about this point in the past, so let me contin=
ue just for a moment.  The selling point is backwards compatibility, which =
beats usability nearly every time (for better or worse).
>=20
> When support for IPv6 is introduced, we want the behavior of "proto=3Dudp=
" to stay the same.  Without TI-RPC support, it means connect to the server=
 via UDP on IPv4.  With TI-RPC, it means precisely the same thing.
>=20
> For example, suppose an administrator upgrades a system from an O/S witho=
ut NFS/IPv6 support to an O/S with NFS/IPv6 support.  Suppose further the u=
pgrade was done to get critical bug fixes, and the administrator has no int=
erest in IPv6 at the moment.
>=20
> Without any further administrative action, should the new O/S now assume =
that it is OK to use IPv6 for NFS mounts?  Because of the amount of plannin=
g and configuration needed to transition a network from IPv4 to IPv6, it wo=
uld be surprising to most people to find NFS suddenly going over IPv6 in th=
is case.
>=20
> Personally I think this is less confusing than "proto=3Dudp" meaning some=
thing different on old systems, or newer systems built without TI-RPC suppo=
rt, than it does on typical newer systems built with TI-RPC.  Think how muc=
h harder it would be to explain in nfs(5).  ;-)
>=20

So if the sysadmin says "nfsvers=3D3", then upgrading could change that from
nfsv3/tcp/ipv4 to nfsv3/tcp/ipv6.  However if they say "proto=3Dudp", then =
that
mustn't change from nfsv3/udp/ipv4 to nfsv3/udp/ipv6, even though it could
allow a change to nfsv4/udp/ipv4.
I don't really see that pattern here.

Isn't it much easier to say "proto=3Dudp means use UDP over whatever network
protocol is available" that to mention netconfig which looks to me like some
sort of internal implementation detail.

Would you support the following patch?

Thanks,
NeilBrown

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index da6d6d3..72b8a09 100644
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



--Sig_/j1gRNL/d_4nfKpaWr9cX/qt
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUFkBaDnsnt1WYoG5AQI01BAAtuGOT3BSSTIkYebIX/boSFbRg4QUe9Mf
SDd/s63fH3RSPdihjM88zfNeVacic96BMzlQNDzHz1vPSkfsy0aDPhF17/dmuBut
OufMYk8HEK+XFWZ1BKhGnFEqIz5DyT/gUWHLfkjKB9ZO0V2GlUXQ0zM/ujLUjXAw
mcGBqVvbHLtCXCI6I1cnDikMizHRDEo7o9CNDA3KXrrcEEfysIp9eMNJsiHo6JiC
wlUVaHKkriU5Xr5cptaXwWoFn7jHpo3/EvWXYOAiNMfgTzT9gSs9EdaAhL9psk1N
molzYUUSPmKILGsg0K3DoYW5SRsyqC7A68Mj0x0+5BSBg8ZtHlQpRpWDE1kzFLot
5tcrQi4mr9BSX60TRhOJbfOOWOorVZVMng5lJFvHh1wKpa5DDaHLOecYAgM5aO8s
NUCB3JiWewZ1J3BKmR0u2yAxDYjFnj5fm/raOXFfbMQyWWE7C/YapcXxmaS6iFQm
tDyd3Jfp9YeY/5gSoj/t2zPSMspxiwaKqaHgxz8+7paAZE5uVCDfP4TGqQ8u4aKl
KNJhtErKJwnoB+yZRpC5dIdsWrbo1VLpL8exLCNa0++a3stEtC6dX/IPWryYoRHw
4ETl2SDGlF68UlEFR/TyCZOnO8rDXvnl2AchvivlbK6or71Bf49PpN/A3qhBV/J2
NCla/BwKnjU=
=HuyJ
-----END PGP SIGNATURE-----

--Sig_/j1gRNL/d_4nfKpaWr9cX/qt--
