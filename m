From: linas@linas.org (Linas Vepstas)
Subject: Re: NFS on a freeswan gateway?
Date: Mon, 24 Jun 2002 19:23:17 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020625002317.GA16309@backlot.linas.org>
References: <20020624223641.GA16108@backlot.linas.org> <shsptygs21r.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dDRMvlgZJXvWKvBx"
Cc: Linas Vepstas <linas@linas.org>, nfs@lists.sourceforge.net,
	users@lists.freeswan.org, design@lists.freeswan.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from www.linas.org ([207.224.61.137] helo=backlot.linas.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Me7H-0003Tf-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Jun 2002 17:23:33 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsptygs21r.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi,

I think I made some progress on my freeswan/nfs-mount problem;
see below.

To summarize, it appears that freeswan and/or the linux kernel is=20
issueing packets from the ipsec0 interface that do not carry the
ipsec0-device default source address, but rather carry the source
address of eth0/eth1.  And that seems wrong to me:  if a gateway
machine creates a packet and puts it on the internal net, it should
be using the source address that is appropriate for the internal net:
i.e. it should be using the source address of the interface from
which the packet issued.=20

This seems to me to be a freeswan bug, and/or a kernel 'feature'. =20
Comments?=20

--linas



On Tue, Jun 25, 2002 at 01:13:36AM +0200, Trond Myklebust was heard to rema=
rk:
> >>>>> " " =3D=3D Linas Vepstas <linas@linas.org> writes:
>=20
>      > Hi, I am resending a message sent to the freeswan mailing list.
>      > As explained below, the default IP source address used in nfs
>      > mount requests is sometimes 'not appropriate' for certain
>      > packet-filtering/freeswan setups.
>=20
>      > I'd like to patch that part of the nfs/rpc client so that it
>      > uses an IP source address that is routing-wise 'closer' to the
>      > nfs server.  But I have damned little experience with the nfs
>      > kernel code (or nfs internals), and thus would like an opinion,
>      > or commnts, or, best yet, a pointer to a pre-existing patch.
>=20
> Both the client and the server use the standard IP socket layer
> code. There is no magic... IOW if ordinary sendmsg()/recvmsg() of UDP
> packets over the ipsec0 interface works (and the resulting address in
> the struct msghdr is correct) then NFS should work fine.

Yes, right.  Maybe I spoke too soon, or put on the wrong empahsis.

When I ran 'strace mount', I found normal/generic UDP behaviour:=20
bind(3, {sin_family=3DAF_INET, sin_port=3Dhtons(641), sin_addr=3Dinet_addr(=
"0.0.0.0")}}, 16) =3D 0

mount is binding a source address of all zeros, which the kernel fills
in; this is normal udp programming; so no problem yet.

The problem is, of course, tha the kernel fills in a source address
that corresponds to the device that the default gateway is on, which
is the box's external address.  I am not sure how or why the kernel
does this (other than that it seems to happen in ip_route_output()
in route.c, which calls inet_select_addr(), etc.)

> If, however, you are trying to use NAT or masquerading or something
> like that on the FreeSWAM gateways in order to translate 'internal
> addresses' into 'external addresses', then you are screwed: NAT is not
> an appropriate protocol for UDP services.

Well, yes, and no.  NAT is a red herring, because (1) the problem=20
occurs when there's no NAT on the box (2) if there was NAT on the box,
I'd still want/expect these particular packets to not be NAT'ed.

----------------
On further analysis,  I see now that *all* packets (tcp, icmp) and
not just the udp (rpc/nfs) packets get the 'external' address as the
source address.   That is, for example,

if I try to telnet to an internal address, on the far side of a freeswan
tunnel, from the freeswan gateway,  the packets get there and back just=20
fine (which means the gateway is working), but thier 'source' addresses
are the external-network adddress, rather than the expected/hoped-for
internal-network address.   =20

Thus, my problem: my nfs exports only allow internal IP addrs, but the
freeswan code is putting packets with 'external' source addresses on
the internal network.   I conclude: this is not an NFS problem,
this is a generic packet-routing problem.

I'm now thinnking that maybe this is a freeswan bug.  If its not=20
a freeswan bug, then its a kernel 'feature'.   At any rate, packets
that left the 'ipsec0' interface had the source address of the eth1=20
interface, which seems wrong to me ....


>=20
> Cheers,
>   Trond

--=20
pub  1024D/01045933 2001-02-01 Linas Vepstas (Labas!) <linas@linas.org>
PGP Key fingerprint =3D 8305 2521 6000 0B5E 8984  3F54 64A9 9A82 0104 5933
> >>>>> " " =3D=3D Linas Vepstas <linas@linas.org> writes:
>=20
>      > Hi, I am resending a message sent to the freeswan mailing list.
>      > As explained below, the default IP source address used in nfs
>      > mount requests is sometimes 'not appropriate' for certain
>      > packet-filtering/freeswan setups.
>=20
>      > I'd like to patch that part of the nfs/rpc client so that it
>      > uses an IP source address that is routing-wise 'closer' to the
>      > nfs server.  But I have damned little experience with the nfs
>      > kernel code (or nfs internals), and thus would like an opinion,
>      > or commnts, or, best yet, a pointer to a pre-existing patch.
>=20
> Both the client and the server use the standard IP socket layer
> code. There is no magic... IOW if ordinary sendmsg()/recvmsg() of UDP
> packets over the ipsec0 interface works (and the resulting address in
> the struct msghdr is correct) then NFS should work fine.
>=20
> If, however, you are trying to use NAT or masquerading or something
> like that on the FreeSWAM gateways in order to translate 'internal
> addresses' into 'external addresses', then you are screwed: NAT is not
> an appropriate protocol for UDP services.
>=20
> Cheers,
>   Trond

--=20
pub  1024D/01045933 2001-02-01 Linas Vepstas (Labas!) <linas@linas.org>
PGP Key fingerprint =3D 8305 2521 6000 0B5E 8984  3F54 64A9 9A82 0104 5933

--dDRMvlgZJXvWKvBx
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE9F7f1ZKmaggEEWTMRAn/dAJ45rkBhh61NwTThN1b93fmRBA0gRwCfRPlV
6iS/gyLs4eqBZ8nHIMzf74Y=
=pJuJ
-----END PGP SIGNATURE-----

--dDRMvlgZJXvWKvBx--


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
