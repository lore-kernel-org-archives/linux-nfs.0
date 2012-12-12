Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:40113 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754344Ab2LLAGI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2012 19:06:08 -0500
Date: Wed, 12 Dec 2012 11:05:54 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: NFS regression - EIO is returned instead of ENOSPC
Message-ID: <20121212110554.19d0d7da@notabene.brown>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA911923813@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121212092813.23afbc5f@notabene.brown>
	<20121212095304.368c9708@notabene.brown>
	<1355267807.23203.16.camel@lade.trondhjem.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA911923813@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/l4aZgn+TPddF6_aGVPMY6Pw"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/l4aZgn+TPddF6_aGVPMY6Pw
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 11 Dec 2012 23:20:38 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Tue, 2012-12-11 at 18:16 -0500, Trond Myklebust wrote:
> > Hmm... I can see 2 places where we're setting the PageError flag.
> >=20
> >      1. nfs_updatepage(): in this case, the error occurred when we tried
> >         to change the page contents. Since we're holding the page lock,
> >         and so rather than mark the page as bad, we could probably just
> >         write back existing dirty areas (using nfs_wb_page()) and then
> >         remove it from the mapping.
> >      2.  nfs_write_completion(): here the writeback error applies to the
> >         entire dirty area on the page, and there is no point in try to
> >         write back again. Better just evict the page from the page cache
> >         (which is what nfs_zap_mapping() is supposed to do). While
> >         setting the PageError flag does cause some of the writeback
> >         functions to return EIO, that's not really what we're after; we
> >         already report errors more completely via the open context.
> >=20
> > So for now, can't we just change nfs_set_pageerror() to not bother
> > setting the PG_error flag? Then in the future we might want to make
> > nfs_updatepage a bit more sophisticated in how it deals with those
> > errors...
>=20
> Ultimately, what I'm saying is that PageError is a hack for passing
> errors around. Since we have our own hack for doing the same, then why
> use PageError at all?
>=20

Sounds like a real possibility.

I just tested with

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9347ab7..e5da5e8 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -202,7 +202,6 @@ out:
 /* A writeback failed: mark the page as bad, and invalidate the page cache=
 */
 static void nfs_set_pageerror(struct page *page)
 {
-	SetPageError(page);
 	nfs_zap_mapping(page_file_mapping(page)->host, page_file_mapping(page));
 }
=20

and I get the correct "ENOSPC" error, so that's a good sign.

Tested-by: NeilBrown <neilb@suse.de>
if you like.

I've haven't tried to examine all the consequences of the change to ensure
there are no unintended side effect, but you know the code better than me so
if you think it is safe - I suspect it is.

Thanks,
NeilBrown

--Sig_/l4aZgn+TPddF6_aGVPMY6Pw
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUMfKYjnsnt1WYoG5AQLzTRAArbU6MhR5UbqWp88bk1drC0Ux/KtYyidt
JUVcinG6YRuFf19Yu3cXQLr7n42P42D7D8uAaqtyi6whZL8N+bntF+58hpB0ZUoV
fcFD6qlXNmBjrYsST2lCLYQQJlPBn0c8U4qjohK1WQeumqoKnoLsCLJchLH+kXmM
UymOUpO3wY69ETnxV5jQAZKEjX3tuQZs286K3rf2Yl3IlqMeoDgsCBHMuVSfQw/B
9TVwpoTf1Cey7c88f5Y9yfkBLVTdzTRbiLgLXrOGpLUlSR2Su4zm8CSnLqatXtCw
QYyhetbnXHgyQ+QPEeaG75Ciz4kg5bsbKWTLc4T62U4Qs1FCVAYDGaO02Q8arM9p
eVX2fu+YgnYh7SlfrwxkpZjh5F9a15qA1ksQZFlPhK2igyoFbCyk5JMo5PwylP7O
TcZq2wbfGQHF7iDgK7uAG4SCIkVmCOOS7QQ42j9n6dnqHoW6vOrvFMTsB9a7P26e
GmKYqTuxR/p26NGoz9qcN8tyVUL7sQqvkY7zpkl+TxLMEu9k4q3oRdRWD8H0tLns
GZCsqEbxHcM7ic/lUph35N8k71P2PzEOOHFJ5Y6exMq4Rt6+3aFplZ2T0OTXbukK
TQ85m6ATn77D9zJerZq1CE6Oho6o0qBzImpcCy0YC73OO5pl/KnOF19Icu0IRZ46
4ZqnfTUgJGI=
=PMRq
-----END PGP SIGNATURE-----

--Sig_/l4aZgn+TPddF6_aGVPMY6Pw--
