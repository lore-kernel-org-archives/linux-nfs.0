From: Nico -telmich- Schottelius <nico-linux-next-xuaVFQXs+5hIG4jRRZ66WA@public.gmane.org>
Subject: Re: Updated Next/Trees, problems with nfs-git
Date: Tue, 5 Aug 2008 00:30:50 +0200
Message-ID: <20080804223050.GA4168@denkbrett.schottelius.org>
References: <20080804134444.GC4182@denkbrett.schottelius.org> <20080804150940.GF4182@denkbrett.schottelius.org> <20080804173556.GA25940@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FL5UXtIhxfXey3p5"
Cc: linux-next@vger.kernel.org, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.schottelius.org ([62.65.138.77]:50722 "EHLO
	mx2.schottelius.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755481AbYHDWbJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Aug 2008 18:31:09 -0400
In-Reply-To: <20080804173556.GA25940@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Bruce!

J. Bruce Fields [Mon, Aug 04, 2008 at 01:35:56PM -0400]:
> On Mon, Aug 04, 2008 at 05:09:40PM +0200, Nico -telmich- Schottelius wrot=
e:
> > Hello again!
> >=20
> > Found out that #linux-next should have been #nfsd-next and updated
> > the patch to match.
> >=20
> > Patch attached.
>=20
> I'm lost:
>=20
> > -nfs		git	git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git#linux-ne=
xt
> > +nfs		git	git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git#nfsd-next
>=20
> There is no branch named "nfsd-next" in that git repository.  (Do I
> misunderstand how this file is supposed to work?)  The only nfsd-next I
> know of is the one I push to at:
>=20
> 	git://linux-nfs.org/~bfields/linux.git nfsd-next

Sorry, I was somehow confused by the error reported in my original mail,
searched for something that matched my eyes and took the wrong git-tree
at http://git.linux-nfs.org/.

So it must in fact be
git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git#linux-next

Sorry for the inconvenience!

Nico

--FL5UXtIhxfXey3p5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiXgxoACgkQuL75KpiFGIxCVwCeLgOb70yLFLGoUe+GcK1VcGi3
XmwAmwdkA4wFTr/jSmrDVE89wSkjh6R9
=GGmU
-----END PGP SIGNATURE-----

--FL5UXtIhxfXey3p5--
