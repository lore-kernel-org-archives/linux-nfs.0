Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38623 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752456AbaBUD0y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 22:26:54 -0500
Date: Fri, 21 Feb 2014 14:26:41 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        NFS <linux-nfs@vger.kernel.org>, Carsten Ziepke <kieltux@gmail.com>
Subject: Re: [PATCH - nfs-utils] Fix fallback from tcp to udp
Message-ID: <20140221142641.20e72abe@notabene.brown>
In-Reply-To: <20140220203701.GA13433@fieldses.org>
References: <20140218104307.34205fc8@notabene.brown>
	<53064057.70703@RedHat.com>
	<20140220203701.GA13433@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_//d.tq=oirllBlkZ2IWdvlum"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_//d.tq=oirllBlkZ2IWdvlum
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 20 Feb 2014 15:37:02 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, Feb 20, 2014 at 12:50:15PM -0500, Steve Dickson wrote:
> >=20
> >=20
> > On 02/17/2014 06:43 PM, NeilBrown wrote:
> > >=20
> > > Protocol negotiation in mount.nfs does not correctly negotiate with a
> > > server which only support NFSv3 and UDP.
> > >=20
> > > When mount.nfs attempts an NFSv4 mount and fails with ECONNREFUSED
> > > it does not fall back to NFSv3, as this is not recognised as a
> > > "does not support NFSv4" error.
> > > However ECONNREFUSED is a clear indication that the server doesn't
> > > support TCP, and ipso facto does not support NFSv4.
> > > So ECONNREFUSED should trigger a fallback from v4 to v2/3.
> > I'm also pretty this is the error returned when the server is=20
> > down or more pointy when server is rebooting...
>=20
> Probably worth checking that.

It is certainly possible that there is a window during boot when a server
will RST any SYN to port 2049.  The window may be very small, but it will
usually be there.

It is possible to configure a server to start listening before enabling the
interface, and so close the window completely.  But we certainly cannot
assume any server does this.

>=20
> > Do we really want to fallback at this point?
>=20
> >From a bz comment (#984901, not sure why it's private):
>=20
> Any NFS server has to support either tcp or rpcbind.  But it's OK for a
> server to support only of those two.  So the only way to handle both
> cases while continuing to retry after ECONNREFUSED is to alternate
> between trying nfs4/tcp and rpcbind until you can connect to one or the
> other.
>=20
> If it's the rpcbind call that succeeds first then I think we want to do
> one more try of nfs4/tcp just to make sure it didn't just come up,
> before falling back to v3.
>=20
> The rpcbind call is done in userspace, if I understand right, so I think
> this is doable.  Looking at utils/mount/ I don't understand the mount
> process well enough to understand exactly how to do it.  Maybe
> everything but the final nfs_sys_mount needs to be moved out of
> nfs_do_mount_v3v2 into a new nfs_do_probe_v3v2 and nfs_autonegotiate
> should alternate between nfs_try_mount_v4 and nfs_do_probe_v3v2 as long
> as both return ECONNREFUSED, calling nfs_try_mount_v3v2 only if
> nfs_try_mount_v4 has failed after a succesful nfs_do_probe_v3v2?
>=20
> Except the v3v2 mount logic seems to actually modify the mount_options,
> so probably that doesn't quite work.

I had come to much the same conclusion after reading Steve's mail:  when TCP
fails we need rpcbind to be sure what to do.
I suspect it should be fairly straight forward to implement (I'm less
pessimistic than you).  I'll have a go on Monday.

Thanks,
NeilBrown

--Sig_//d.tq=oirllBlkZ2IWdvlum
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUwbHcTnsnt1WYoG5AQKf1Q/+PxYVPLbcLaHXiDt5CAFSHmKEOA+wQBWw
N6izmh/z6nZ6qN2LO07Sla8gGDyiRSW/jfC/mWy0BXJhJoE1oDwEyttA/Sw31oRf
q26EKiwHC3TF4oezUR4fq+V0No54dTnp+LU73mlmkummpU/ooYi9iSXceioJBpGO
zlK6BVM4I2orN6NQ07Fua9IBWW1w8r0WbqNg0sQwcOJdWdkyDk49zjg1TJPO4qnN
3ytn7jr2oMHJWHXUoZ3vmIA49CCfv6/kRQqsBYaDB4FeCx2csPYdci45qyLVq1PD
zF4qrB0s2H7nvkgSoxkzKEfRRdrMS8iv9xBcZjJk5cdrXMKrsFwzpihsokvjDFBb
J7KPNJRN86qVMbd4ecqoLBPdyK3kQSNm8BoCHKc5lhTBYcpYqh8+slcu3VRJw8x6
SYRgOUG+6mmdPeH4Ax011D4jpkvhZEo6JXtvyBfToCjficYD2hdJ5CYL42BXnzj6
z94HEmPhYJ0SjEPN7rvlkMUU6FOehOn+LdsdNZMaPVG27orrXhu7H0Z2XH3kG0YP
Vtfo7UxexvkEctPMkqSiPkLR18EkBC/pxLxAZ3rQoQW5dJYF6g8o413SFn+5jS0r
T+fm9a3abSbdsrLPze6ghSrYxRn4L9ZdQMcRvPYwSBEiCAtEaDq9789csGgNvCzV
QsSD+Epccgc=
=TD1/
-----END PGP SIGNATURE-----

--Sig_//d.tq=oirllBlkZ2IWdvlum--
