Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44892 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927Ab2HJFU4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Aug 2012 01:20:56 -0400
Date: Fri, 10 Aug 2012 15:20:39 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Zdenek Salvet <salvet@ics.muni.cz>,
        Lukas Hejtmanek <xhejtman@ics.muni.cz>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 backchannel authentication
Message-ID: <20120810152039.21eaa5a6@notabene.brown>
In-Reply-To: <1344527573.25447.17.camel@lade.trondhjem.org>
References: <20120806135517.GS25979@ics.muni.cz>
	<20120807154114.GA21460@fieldses.org>
	<1344355148.5781.31.camel@lade.trondhjem.org>
	<20120808075813.GW604@horn.ics.muni.cz>
	<1344431887.3423.4.camel@lade.trondhjem.org>
	<20120809080642.GE604@horn.ics.muni.cz>
	<20120809144530.GB6592@fieldses.org>
	<1344527573.25447.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/aa.axwjgUBUR8s2Sz/Z+4T+"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/aa.axwjgUBUR8s2Sz/Z+4T+
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 9 Aug 2012 15:53:01 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Thu, 2012-08-09 at 10:45 -0400, J. Bruce Fields wrote:
> > On Thu, Aug 09, 2012 at 10:06:42AM +0200, Zdenek Salvet wrote:
> > > On Wed, Aug 08, 2012 at 01:18:09PM +0000, Myklebust, Trond wrote:
> > > > > We don't see any hard failures because NFS protocol does
> > > > > not depend on working callback RPCs, but no delegations are grant=
ed
> > > > > (we had nfs-kernel-server package installed on clients before whi=
ch masked
> > > > > the bug).
> > > >=20
> > > > So your gripe that you object to us requiring you to run rpc.svcgss=
d in
> > > > order to obtain server features such as NFSv4 callbacks?
> > >=20
> > > Absolutely not! Just thinking why we did not notice the problem earli=
er ...
> >=20
> > I wonder if there's anything we could do to make this more automatic,
> > though: e.g., perhaps whichever scripts are launching one of the gss
> > daemons should be replaced by one that launches both, since that's
> > generally what you'll want for NFSv4.0.  (Not necessary for other
> > versions, but it doesn't hurt much.)
> >=20
> > Or perhaps they could be started on demand somehow.
>=20
> How is this any different to requiring that the user start rpc.statd
> before launching an NFSv3 mount? Just document the requirement if it
> isn't already clear enough, and we can move on.

'mount.nfs' checks if statd is running and will start it if it isn't ....
which will probably annoy systemd as it likes to keep daemons in their own
little box.  I guess systemd can be configured to register as statd and
auto-start it on the first 'are you there' request.

Could the same thing be done with rpc.svcgssd?  Get it to auto-start either
by mount.nfs checking and running something, or by systemd pre-registering
the RPC port or something?

NeilBrown


>=20
> The other source of confusion here, was that the rpc.svcgssd was
> delivered through a nfs-kernel-server package, which indicates that we
> first and foremost need to educate the distro packagers.
>=20


--Sig_/aa.axwjgUBUR8s2Sz/Z+4T+
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUCSaJznsnt1WYoG5AQL+gg//cRt49LhltsjEZpzFWpyKdXfJInDzqk7t
VHL1NgLF+MRPjmcJ/jUpsPVy15ppKdY7FJjTH9axdCZjoUVjNh6zhSYoXZWc6b73
kdM5en0dKeY/UHKzj+FmAxZoJHoRDrS+fXSAMC8WSWQiPWBVXStriUvMST/Jg71N
7CX6qsjqywi3tuKRNsBfD3WHEc88X3+wD1cZeoFFHOHNpo3DMzjolkh/t4mJU7VZ
dExCKdSpXnykfBKkU3eb+H4PxpI1lVBTaF4GJdvELr4278vq8fMtz8fDj536BkwC
oeP5cFoN4DS+H/BfWZ7z3ep71Mkz/I5FlpVZbgRu3q6GLMyBkTx0eS80nFUQ6XtO
dPuviQ1Hjgny98DaSd3BYwlzhvKM55+QtYGMave6aP+ZIP24uEGK4Ua0Lbe2QYy0
gXDMXaF8IEwgiRUrXaxrmKEVXMKgUrckJYAleG8L3h6/tztkoct3buiL4hi4XyLx
6lUl0wEMC66ZtxYo1/o8tUqRdVihn9e1J3WXbMxuoao4X6iBSSq4GzzhvaJws4FM
iAMtLkfZn6b8h/gFSzVDEdFTUiQyIENdndZOE9u1x6sob2NvgTCUmjqqzWO/SAen
uJG3xb5mMWtT4BaOflZz1dOKxfxre02hbwI2ahOyPh7JdAftJ+izWr6JLQk5+WuV
VpmD14s5Nkg=
=9dXI
-----END PGP SIGNATURE-----

--Sig_/aa.axwjgUBUR8s2Sz/Z+4T+--
