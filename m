Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45195 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945979Ab2K2AbL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 19:31:11 -0500
Date: Thu, 29 Nov 2012 11:30:51 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] gssd: base the size of the fd array on the
 RLIMIT_NOFILE limit.
Message-ID: <20121129113051.046bc658@notabene.brown>
In-Reply-To: <20121128131054.GB11651@fieldses.org>
References: <20121128010939.2475.13123.stgit@notabene.brown>
	<20121128011123.2475.13691.stgit@notabene.brown>
	<20121128131054.GB11651@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_//i1lZFFD=uFYlm1inq5SOXo"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_//i1lZFFD=uFYlm1inq5SOXo
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 28 Nov 2012 08:10:55 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, Nov 28, 2012 at 12:11:23PM +1100, Neil Brown wrote:
> > We have previously raised the size of the 'pollarray' once (32 -> 256)
> > and I have had another request to make it bigger.
> > Rather than changing the hard-coded value, make it depend on
> > RLIMIT_NOFILE.  This is an upper limit on the size of the array
> > that can be passed to poll() anyway.
>=20
> Sounds like a good idea.
>=20
> Just out of curiosity: how does it fail?  I guess mounts just start
> failing at some point--how do people find the workaround?

Error seems to be

rpcsec_gss: gss_init_sec_context: (major) Miscellaneous failure - (minor) C=
annot contact any KDC for requested realm

in rpc.gssd logs.

I guess people could read the source to find the work around .... not ideal
though.  I guess we should get gssd to generate some more helpful message.

The seem to be further problems that the customer is experiencing so I might
wait until they are completely resolved to ensure I have complete
understanding before I propose a further patch.

NeilBrown


--Sig_//i1lZFFD=uFYlm1inq5SOXo
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBULaswjnsnt1WYoG5AQKQ4Q/+N5cvBYAlpDbYVBP/TJES6vA7no94qDP7
s+QkHEHXuHiA9Zxx6hSsd54Y6wAaEGsiMKsBncPJ70qDS0JeA7bIkoPcI20R/XP7
FeXuz1gPoprYoLQYkqhRGwDidVuwtTg0slPapfMFeoUPbJakNkaRvebDyXyFWvIx
/bBXGeR4hmYamkSblRGan/l+20NQwtle4jaseTdfKG3nhIPFHF9bBGDc6ecMKBtE
R380v4xlak34cYQQYH1RMzIrD1KiwJyI+YOU47HLWPk9T9ryGVF939VXwS1Kvlu/
iSuYxeQP04XEZTPxqMktq5zgk47dc28qppQHkdh34tDFlotcXuNimaAsx+6alBe3
HWxyS/WG+ZrCheeRGLANop2ZNKTHnyQvnBAHUtImhNy9fTfw3I3qnQjbj1dPll3E
GmbUVazgYY+yPyKMvy1/zY43MiX7LezZFdAAAHNO2WsnHinox80iEqvCdIGMNOax
FrJPgx7wnqdGS2VwtCC2KZ9WWVf4jWc16kOGaTSp7gfQYbKv1/3X1Rg/oBijYrwJ
LGw1wWu9emwo653Gh+AiRaUA5PM/ogB0Xpy/06CWQ7m1OrrqHhpBmBgkPDpWvJMr
NPajZzp7gTzkwWI4ggG/riOlBRI59jnJCnjsSDCdZ8ClaVI19vdODizvYRQi1+tp
Au2+7C5iXuc=
=bUL9
-----END PGP SIGNATURE-----

--Sig_//i1lZFFD=uFYlm1inq5SOXo--
