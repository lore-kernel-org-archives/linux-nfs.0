Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48681 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756Ab3KYXXQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Nov 2013 18:23:16 -0500
Date: Tue, 26 Nov 2013 10:23:01 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: The return of the hanging "ls"...
Message-ID: <20131126102301.6cbbdb94@notabene.brown>
In-Reply-To: <A7CF3941-980F-4B96-B473-ECB46375CFCF@oracle.com>
References: <20131125155942.0a3e4ca1@notabene.brown>
	<A7CF3941-980F-4B96-B473-ECB46375CFCF@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/.8ZkQgAqVXC.DOIxg8Sd3Kg"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/.8ZkQgAqVXC.DOIxg8Sd3Kg
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 25 Nov 2013 09:59:39 -0500 Chuck Lever <chuck.lever@oracle.com> wro=
te:

> Hi Neil-
>=20
> On Nov 24, 2013, at 11:59 PM, NeilBrown <neilb@suse.de> wrote:
>=20
> >=20
> > Hi Trond,
> > I just noticed commit acdc53b2146c7ee67feb1f02f7bc3020126514b8 from 2010
> > reverts the effect commit 28c494c5c8d425e15b7b82571e4df6d6bc34594d from=
 Chunk
> > in 2007.
>=20
> I'm wondering if a subsequent commit changed filemap_write_and_wait().

I hadn't thought of that possibility.  I've just had a look at the
differences between  acdc53b2146c7ee6  and now and cannot find anything that
could be related.

Thanks,
NeilBrown

>=20
> There was some recent clean up that (very likely unintentionally) changed=
 the serialization of some of these VFS utility functions.
>=20
>=20
>=20


--Sig_/.8ZkQgAqVXC.DOIxg8Sd3Kg
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUpPb1Tnsnt1WYoG5AQJLTg//VjXW40ectoLS+1C6/Y/gdIPn4LDFaldN
kTxBom5vZ5zqYQ15Q374TiMq/8/gUvoxApkKTUM0ES5vyV8OXHl3219V6t/4JE4F
3I+Jq1DyXCKCX0gpWLew2E5a5Jia31rclBXoK71CsDQS2F46FDBq/WA8eNzhSK1k
nI130simJJ5j6jmZVbxLQHPSrNGIrYND1SYeGYe5A0q80pn/05MulG9pDvAerWi2
V13fLbgl2blTSXJAtADTbhQCpqBiFloJCvb5OQDHV2d0KoFtJKQpKuzLpVHAjFSf
8N3Gn3X76HsR2yds7ocrmcEhWanM1G8Y4+GkPsORf7C+jMdbOyklBu+4gC+GR+Ef
I1UMWFAF+iIZFLS//fCwkxxjzIDNPvGc/zwmQjZgQuEjBVbP8iTkJsGgW8XlJyrw
QaM/NxkRfYuLxSA2o8ua0Ufmyw5pztpt+nZq0LG+euQ2FTukFVuxcQa8dY1oPtjA
kEtVqCcBO4caqH78vjJ7qTpLdvsNM0NL9jBDXzZ+Pf3H/1Pjs2A+ALZzNt+lVRve
SefnEGBhA5VPvbLWItJShhp91wAe28QEGOjpGXWCrkEC+OPJTjL9kXGm6s4fVOfJ
NP2LXpFe9oYJJ+0g9GlNOWKekE8jxedh6bBHndW/UGIx+Oh0NbO9PQ+QBs9D+A3q
xn94NNel3/Y=
=eRKj
-----END PGP SIGNATURE-----

--Sig_/.8ZkQgAqVXC.DOIxg8Sd3Kg--
