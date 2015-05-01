Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51326 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077AbbEACXn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2015 22:23:43 -0400
Date: Fri, 1 May 2015 12:23:33 +1000
From: NeilBrown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150501122333.1476c999@notabene.brown>
In-Reply-To: <20150501020324.GP889@ZenIV.linux.org.uk>
References: <20150422150703.GA1247@fieldses.org>
	<20150423094431.1a8aa68b@notabene.brown>
	<5538EB18.7080802@gmail.com>
	<20150424130045.6bbdb2f9@notabene.brown>
	<553E2784.6020906@gmail.com>
	<20150429125728.69ddfc6c@notabene.brown>
	<20150429191934.GA23980@fieldses.org>
	<20150430075225.21a71056@notabene.brown>
	<20150430213602.GB9509@fieldses.org>
	<20150501115326.51f5613a@notabene.brown>
	<20150501020324.GP889@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/La7ce7cFaPhKB2J.XTUQtIQ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/La7ce7cFaPhKB2J.XTUQtIQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 1 May 2015 03:03:24 +0100 Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Fri, May 01, 2015 at 11:53:26AM +1000, NeilBrown wrote:
> > While writing that I began to wonder if lookup_one_len is really the ri=
ght
> > interface to be used, even though it was introduced (in 2.3.99pre2-4)
> > specifically for nfsd.
> > The problem is that it assumes things about the filesystem.  So it makes
> > perfect sense for various filesystems to use it on themselves, but I'm =
not
> > sure how *right* it is for nfsd (or cachefiles etc) to use it on some
> > *other* filesystem.
> > The particular issue is that it avoids the d_revalidate call.
> > Both vfat and reiserfs have that call ... I wonder if that could ever b=
e a
> > problem.
> >=20
> > So I'm really leaning towards creating a variant of kern_path_mountpoin=
t and
> > using a variant of that which takes a length.
>=20
> NAK.  As in, "no way in hell".  And yes, lookup_one_len() *does* revalida=
te -
> RTFS(lookup_dcache), please.

Damn - I always seems to get lost when I'm following those call paths.
 lookup_one_len -> __lookup_hash -> lookup_dcache -> d_lookup,d_revalidate =
-> __d_lookup
                                 -> lookup_real -> i_op->lookup

I think I was confusing __lookup_hash with __d_lookup in my thoughts.

>=20
> What kind of consistency warranties do callers expect, BTW?  You do reali=
ze
> that between iterate_dir() and callbacks an entry might have been removed
> and/or replaced?

For READDIR_PLUS, lookup_one_len is called on each name and it requires
i_mutex, so the code currently holds i_mutex over the whole sequence.
This is triggering a deadlock.

We could just grab/drop i_mutex over each call to lookup_one_len(), but that
sort of thing is usually frowned upon, and we don't really always *need*
i_mutex if the lookup can be served from the d_cache.

So I'm looking for the best way to perform the lookup without holding i_mut=
ex
for too long.

It sounds like you are suggesting something like lookup_one_len_unlocked(),
which .... uhm...

I was going to say uses lookup_dcache, but that needs i_mutex.
It calls d_lookup(), which doesn't seem to really need i_mutex, and
d_revalidate().
Does the later need i_mutex?  I don't think so.
So maybe it is just how d_lookup handles failure that needs i_mutex.

So lookup_one_len_unlocked() could call d_lookup and d_revalidate and if
that all worked nicely, return the result. If it didn't, grab i_mutex and t=
ry
again??

Or do we just wear the cost of taking i_mutex for each name in the directory
during READDIR_PLUS?

Thanks,
NeilBrown


> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/La7ce7cFaPhKB2J.XTUQtIQ
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVULjpjnsnt1WYoG5AQJP6w//Y1Yykb2AxJnFcf35talYHhT2ItDwTns7
ABLWEaLTe5PGm8ujFQhhK4S3mMRzq47zAv3O6dszjqkHJYYVaRg7FUDKQhFkixn/
nN1/7BkpRDvsx05S9Zc0Zlz8XLJrLQCXHGUNBkal5bAe4YSVhdMnQLZnzRM8Uqma
4ptWmFbHyyiCcALTPLCnWDOo3/C6K/YYPjwf6v/bYMRnUp/Nc8AF6MC8Mr0KRpNH
3pX0QTJ0ImWYLHDYiyfkcPZlq05zAm9dhG8QpoEjDbSd3mv4EQQUzyV0T95GyEmf
gcRJJQp0Kue3nm9gDghAGH85oXwztaiIaEinqp19VSdhyJR2Q5gz4APcUNPBRQbS
j8CnM26gGfJLxJefipC16692P4d71Y8cOhGLDqXH4WK2lrSf8f4V8k58Bc8zNurE
HG7TahBl7EozbZvIvE9sXhgH8y0hBAeffULW94JkjPoTbgPWSIfiTImyJWX2/DIc
Lc3oH3vA+GkxS8DRkaKgq/dOYpZP24QqIEUZHCWlmIxLFfI45wP2VTkBGh8PO3kv
SG+r9uoB+FwVw0rBxl+4cmUhoWpg7VXuBVgoku8DKpt+SLUUBCQpEZgFHGI2EIam
+V6HTpfHuxSXVP8KG3vQlpb80h+iVdl41EFo5aUcs8G3YufO1turtmkuPlWQBLR5
MBjFxBTHS6E=
=i5pN
-----END PGP SIGNATURE-----

--Sig_/La7ce7cFaPhKB2J.XTUQtIQ--
