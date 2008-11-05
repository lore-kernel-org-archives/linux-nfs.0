From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: Re: gssapi and nfs4
Date: Wed, 05 Nov 2008 14:18:54 -0500
Message-ID: <1225912734.3785.40.camel@pc.interlinx.bc.ca>
References: <1225813410.2247.279.camel@brian-laptop>
	 <89c397150811041000l93b9831w1e8dce2175c6d51f@mail.gmail.com>
	 <1225824797.2247.345.camel@brian-laptop>
	 <20081104224817.GB16121@fieldses.org>
	 <1225862729.13506.8.camel@pc.interlinx.bc.ca>
	 <20081105190235.GA969@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-bQvPrP4luO2bsixbmrud"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:3889 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910AbYKETTD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 14:19:03 -0500
Received: from linux.interlinx.bc.ca (d193-213-184.home3.cgocable.net [67.193.213.184])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id D83562807
	for <linux-nfs@vger.kernel.org>; Wed,  5 Nov 2008 14:19:00 -0500 (EST)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id DA4B6800A
	for <linux-nfs@vger.kernel.org>; Wed,  5 Nov 2008 14:18:56 -0500 (EST)
In-Reply-To: <20081105190235.GA969@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-bQvPrP4luO2bsixbmrud
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-05 at 14:02 -0500, J. Bruce Fields wrote:

> Unfortunately that last option's the only practical approach right now.

Other than exporting / of course.

> We're working to simplify this.

Great.

> If you want to.  If you want to just mount the whole of / at one point
> in the client filesystem, you can also do that, and the client will
> automatically mount the filesystems underneath as it traverses into
> them.

That is cool.
=20
> > /	10.75.22.0/24(sec=3Dkrb5,ro,insecure,sync,wdelay,no_subtree_check,roo=
t_squash,fsid=3D0,crossmnt)
> > /home   10.75.22.0/24(sec=3Dkrb5,rw,no_root_squash,sync,no_subtree_chec=
k)
> > /d      10.75.22.0/24(sec=3Dkrb5,rw,no_root_squash,sync,no_subtree_chec=
k,crossmnt)
> > /d/sub  pc(sec=3Dkrb5,rw,no_root_squash,sync,no_subtree_check)
> >=20
> > and on the clinet:
> >=20
> > pc # mount -t nfs4 -o sec=3Dkrb5 server:/ /mnt/server
> > pc # mount -t nfs4 -o sec=3Dkrb5 server:/home /mnt/server/home
> > pc # mount -t nfs4 -o sec=3Dkrb5 server:/d /d
> > pc # mount -t nfs4 -o sec=3Dkrb5 server:/d/sub /d/sub
> >=20
> > To have /home rw under /mnt/server.  It would be there but ro without
> > the second mount, yes?
> >=20
> > It also appears that for the above case of /d and /d/sub I need the
> > crossmnt option on /d or I don't see anything in /d/sub even though I'v=
e
> > exported and mounted it individually.  Does this seem like the expected
> > behaviour or a bug?
>=20
> That's expected.

But causes a problem as below...

> > It's important to be able to do because I might
> > want to be able to export /d to certain hosts without giving them acces=
s
> > to mountpoints within /d as I have done above with /d/sub and pc.  If I
> > use crossmnt which my experience is showing I need, then /d/sub is
> > exposed to all of 10.75.22.0/24 which is not what I want.
>=20
> If you add a separate export for /d/sub, I think it should override that
> behavior.

That's what I did and still, I have to use crossmnt on /d and that
exposes /d/sub it to everyone who gets access to /d where my intention
is to only expose /d/sub to the match/limit I put on /d/sub, which is
the single host "pc" in my above scneario.

Let me thank you for all of your great answers.

b.


--=-bQvPrP4luO2bsixbmrud
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkkR8Z0ACgkQl3EQlGLyuXDlmACeLpPdzMVf5ZjGqb1diyZgiu5Q
AkMAoLQvEKomhpsIJYUoTSEaAWmlsBRl
=3VSi
-----END PGP SIGNATURE-----

--=-bQvPrP4luO2bsixbmrud--

