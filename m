Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48934 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751288Ab3HLGxQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Aug 2013 02:53:16 -0400
Date: Mon, 12 Aug 2013 16:53:06 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] remove incorrect "Lock reclaim failed" warning when
 delegation is in force.
Message-ID: <20130812165306.728d2841@notabene.brown>
In-Reply-To: <1375977089.4590.4.camel@leira.trondhjem.org>
References: <20130808125937.126d8ef1@notabene.brown>
	<1375977089.4590.4.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/GGtJpFGA_3dIJGGy2DkTNJg"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/GGtJpFGA_3dIJGGy2DkTNJg
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 8 Aug 2013 15:51:30 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-08-08 at 12:59 +1000, NeilBrown wrote:
> > Hi,
> >  I'm trying to track down a strange problem with state ids going bad
> >  (possibly linked to ntp changing the system time on the non-Linux serv=
er)
> >  and am still learning about how the state management works.
> >=20
> >  But I've come across an error where I don't think there should be one.
> >=20
> >  For whatever reason the client gets a BAD_STATEID on a file that it ha=
s a
> >  lock on.  The open gets a write delegation so that when it runs
> >  nfs4_reclaim_locks(), nfs4_lock_reclaim aborts early without doing any=
thing
> >  (it doesn't need to because there is a delegation).
> >  But the code below then checks that NFS_LOCK_INITIALIZED is set on all=
 lock
> >  states.  But it isn't because nfs4_clear_open_state cleared it and
> >  nfs4_lock_reclaim didn't bother setting it.
> >=20
> >  So I think the error should only be printed if there is no delegated s=
tate,
> >  hence this patch.
> >=20
> >  Does it look right, or have I misunderstood something?
> >=20
>=20
> Hi Neil,
>=20
> That analysis looks correct. Can you resend the patch with an
> appropriate signed-off-by and changelog entry?

Thanks.  I've resent separately.

NeilBrown

--Sig_/GGtJpFGA_3dIJGGy2DkTNJg
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUgiGUjnsnt1WYoG5AQJPDhAAjOx12KdCT+vjkG9SXjbbgV3lE8LP5k9w
OdOY+pDgSLaslw4h/GsnNY8aDVqDsLISvUP/8bmsvwqqnPuITVBUWKAkKQk6jJRM
eQRmgRJnVg9d14z7BaOdBbIyG5BhUia2oxNvTZXip1Q95B4hDUy0QU+E/ZKx2tuG
GrVIUJRQ+C3M1fHBrc0FysgHTZ/Lg+a7OHHMunQY09L5O/A06OnGDkJMqjVtBIIF
tYR8Oxnc2B3zDE0d3mBorPKxev+nW6voCmNoIDFkiF6CNzpKXEFAvNo1vsRyoEVY
uMLEmdm1FHXgT7qvDetmDB2XhmqGltf1bu+/oy0qr24wcYcY/E0Ys3LpCoWjaGY5
Yz/F7f5k158v7iV/OV/aK7dy8rV3aaD4yq+nh1pBAAKLPFCeQw8rvrhv5S4nUAeN
8aCTFFYZz56r4gUES2fG3XQpOfHBMbKffj4pMfb1ffm1UhqvezuCdVxUfi1mP3gG
6GuMeKICaCWR7wwfElcCJ1yXDgz7iBlvFINMxFqS93vnK8csXthNMyooLhhGqvwu
hBDyk+Kc+OAVI3sDmbVv5XmFiFPoo/llEOusMyTPGfNpCrFaebzfwjKOSYTnml+z
Ffodh+QD0fdpw16nnoz+E3dyUDwLOCaaSt1tKI9PqO0phpKrNK4wWE/VLher+gqY
F28QftrvM6g=
=CjNv
-----END PGP SIGNATURE-----

--Sig_/GGtJpFGA_3dIJGGy2DkTNJg--
