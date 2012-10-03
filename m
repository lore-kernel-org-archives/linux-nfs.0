Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55390 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750955Ab2JCDLG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 23:11:06 -0400
Date: Wed, 3 Oct 2012 13:11:03 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Should "mount -o proto=udp" be usable against an IPv6 only
 server?
Message-ID: <20121003131103.57f299a4@notabene.brown>
In-Reply-To: <7459FD75-3B8A-4973-A732-1984A658C65D@oracle.com>
References: <20120918115450.5c65973f@notabene.brown>
	<F8762BC2-F211-482E-8B5A-A2E991E3F937@oracle.com>
	<20120918162948.47840d42@notabene.brown>
	<ECDC5BA9-29CC-4867-8737-CA1110E6C4C6@oracle.com>
	<20120919091904.624ee54b@notabene.brown>
	<ECD54A5F-C684-4057-96F5-1D29E7A9A551@oracle.com>
	<20121002152440.2e6a0c04@notabene.brown>
	<7459FD75-3B8A-4973-A732-1984A658C65D@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/EC..XXP7BLxHwhnWzQ4u+FW"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/EC..XXP7BLxHwhnWzQ4u+FW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 2 Oct 2012 07:24:23 -0700 Chuck Lever <chuck.lever@oracle.com> wrot=
e:

>=20
> On Oct 1, 2012, at 10:24 PM, NeilBrown wrote:
>=20
> > On Tue, 18 Sep 2012 21:00:01 -0400 Chuck Lever <chuck.lever@oracle.com>=
 wrote:
> >>> +A
> >>> +.I netid
> >>> +determines both the
> >>> +.I transport
> >>> +and
> >>> +.I network
> >>> +protocols, so for example
> >>=20
> >> "determines both the protocol family and transport" are closer to how =
these terms are defined in netconfig(5), and I prefer that formulation.  I =
still believe a citation of netconfig(5) would be correct and helpful.  A c=
itation in the SEE ALSO section should also be added.
> >=20
> > (SEE ALSO already mentions netconfig(5).)
> >=20
> > Don't you love standards....
> >=20
> > ISO OSI seems to use "network" for layer 3 and "transport" for layer 4,=
 which
> > is where I got that names I used.
> >=20
> > netconfig(5) uses "protocol family" and "protocol" respectively, and
> > "transport" to identify the combination of the two (which is also the
> > network_id).
> >=20
> > socket(2) also uses "protocol family" and "protocol", but uses AF as the
> > prefix for "protocol family" aka "address family" :-)
> >=20
> > This does serve to highlight the inappropriateness of using "proto=3D" =
to
> > specify the "transport", and the netconfig usage treats the "protocol" =
as a
> > just part of the "transport" (but allows e.g. "udp" to be both a protoc=
ol and
> > a transport depending on context).
> >=20
> > It looks like  "protocol" and "protocol family" are the most appropriate
> > terms in the Unix world, and the examples can clear up any uncertainty:
> >=20
> > ------------
> > A
> > .I netid
> > determines both the
> > .I protocol
> > and
> > .IR "protocol family" .
> > So for example
> > .B udp
> > selects UDP over IPv4 while
> > .B tcp6
> > selects TCP over IPv6.
> > -----------------
> >>=20
> >> As a matter of word smithing, I think starting a new sentence at "so f=
or example" would be easier to read.
> >=20
> > Agreed.
> >=20
> > So how about this.
> >=20
> > Thanks,
> > NeilBrown
> >=20
> >=20
> > From: Neil Brown <neilb@suse.de>
> > Date: Tue, 2 Oct 2012 15:21:46 +1000
> > Subject: [PATCH] mount.nfs mapage: clear up confusion between 'proto' a=
nd
> > 'transport'
> >=20
> > The mount option "proto=3D" actually set the "transport" which in
> > netconfig usage is the paring of a protocol (e.g. UDP, TCP) with
> > a protocol family (e.g. INET, INET6).
> >=20
> > This can cause confusion if people naively except "proto=3Dudp" to work
> > equally well on IPv6.
> >=20
> > So add some text to both nfs(5) and nfsmount.conf(5) to hopefully
> > clarify this.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> >=20
> > diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> > index da6d6d3..2741a60 100644
> > --- a/utils/mount/nfs.man
> > +++ b/utils/mount/nfs.man
> > @@ -1,5 +1,5 @@
> > .\"@(#)nfs.5"
> > -.TH NFS 5 "2 November 2007"
> > +.TH NFS 5 "19 September 2012"
> > .SH NAME
> > nfs \- fstab format and options for the
> > .B nfs
> > @@ -474,9 +474,17 @@ for NFS versions 2 and 3 only.
> > .BI proto=3D netid
> > The transport protocol name and protocol family the NFS client uses
> > to transmit requests to the NFS server for this mount point.
> > -If an NFS server has both an IPv4 and an IPv6 address, using a specific
> > -netid will force the use of IPv4 or IPv6 networking to communicate
> > -with that server.
> > +A
> > +.I netid
> > +determines both the
> > +.I protocol
> > +and
> > +.IR "protocol family" .
>=20
> Looking at this addition in context, the new sentence simply repeats the =
existing first sentence in the paragraph.  How about we clarify the existin=
g first sentence, and just add your example:

Good point!

>=20
> > proto=3Dnetid
> >=20
> > The protocol and protocol family the NFS client uses to transmit reques=
ts to the NFS server for this mount point.  For example, udp selects UDP ov=
er IPv4, while tcp6 selects TCP over IPv6.  If an NFS server has both an IP=
v4 and an IPv6 address, using a specific netid forces the use of IPv4 or IP=
v6 networking to communicate with that server.

I still don't like that last sentence.

>=20
> We have a slightly sticky problem, then.  TI-RPC brings more to the table=
 than udp/udp6 and tcp/tcp6.  For instance, we also now have rdma/rdma6 net=
ids (not mentioned anywhere, ha) and there is a local transport netid.  If =
there ever is support for RPC over SCTP, that would also get its own pair o=
f netids.  The problem is that not all of these netids are supported by NFS=
 right now.  I think nfs(5) might benefit by providing a list of supported =
netid values.
>=20
> This could make the above paragraph perhaps too long.  We should consider=
 adding a section to nfs(5) that discusses this in a little more detail.  T=
hat can be a separate patch, of course.
>

The current kernel only supports:

static const match_table_t nfs_xprt_protocol_tokens =3D {
	{ Opt_xprt_udp, "udp" },
	{ Opt_xprt_udp6, "udp6" },
	{ Opt_xprt_tcp, "tcp" },
	{ Opt_xprt_tcp6, "tcp6" },
	{ Opt_xprt_rdma, "rdma" },

	{ Opt_xprt_err, NULL }
};


So it seems reasonably just to list those.  nfs-tuils seems to support rdma6
too, so I assume that is coming soon to a kernel near me.

So how about we drop the reference to netconfig (though leave it in SEE ALS=
O)
and just be explicit about the short list.  That means 'rdma' is no longer a
special case.
??

Thanks,
NeilBrown

=46rom 3d2fb5a4a091f00494c0f655e4a02041c1f05aa3 Mon Sep 17 00:00:00 2001
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
index da6d6d3..11bbfc6 100644
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
+.BR udp ", " udp6 ", "tcp ", " tcp6 ", " rdma ", and " rdma6 .
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
+server.  Available options are
+.BR udp ", " udp6 ", "tcp ", " tcp6 ", " rdma ", and " rdma6 .
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

--Sig_/EC..XXP7BLxHwhnWzQ4u+FW
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUGusyDnsnt1WYoG5AQKhIw/9FkbeeoWkDlM6nAyutwqu3xdsV0GKbFp1
lMoWum8F5LlBZcZlWCd8OcIm8A1O+ZSdCXWc/+M1cf3sFc0wRKhvLxvtIaJyW/02
Uydqvy7O6PiNOuPXZP70hMLHJtTCN8wTt5xilubCO0nd88h2Px3YtysHlgZ8m90x
ieMWLT0YmvloniZbJ4I1MMzmyt75rqy11Ux9ZKlrUbDvvv2PP73V3vnXzCalaXRG
Lh4JrOeu/ROfScWzrTuFAZ+gHQfv+78itFZzLBg/mv+wHmo8kFP0FbAsnelfxpG0
gWyCs7yc8TzyWxNdsOJEM0PYaWF+DqJKmRHMqnsQllkAGcCwEKv+CPqhDVaNq3+Y
OJlIwKMv56Y9JGNYMdhk/pft6MtiD/R51AwZH3QuGFiaRcRcQrRx7STsJoZigY0x
kr4QB2OH2JM1ccUQJIKsYHlPUGSzK8JH6csXLQQnu0FqOWTI2/9mcCRp9kDKMbpL
zvQUmRxlRwNtCP6bDIXTyIBBgNe0CZCwCTqk3Bb4xQ6dlkEXQ+TYeLy0FwrfwncA
tw6MksS/y5MbPsniVB8vzC4ZBH3tTim+naO9foWOYzykKZWRRX+Mc2vKkUkFMB2z
ojHj3iAdwBNZAJyBfr+xntnHextVRaRAF+nkRgy9fdi51dt1J0OigQ5AAzpzjBru
Vjyh9b1ASyI=
=NB0z
-----END PGP SIGNATURE-----

--Sig_/EC..XXP7BLxHwhnWzQ4u+FW--
