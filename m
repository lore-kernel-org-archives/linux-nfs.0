Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40130 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750784Ab3FYKc7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jun 2013 06:32:59 -0400
Date: Tue, 25 Jun 2013 06:32:13 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org,
        dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: Re: [PATCH v4 06/14] locks: encapsulate the fl_link list handling
Message-ID: <20130625063213.615d8a83@corrin.poochiereds.net>
In-Reply-To: <20130625113704.89a686a55dcec684e5e99434@canb.auug.org.au>
References: <1371819502-26363-1-git-send-email-jlayton@redhat.com>
	<1371819502-26363-7-git-send-email-jlayton@redhat.com>
	<20130625113704.89a686a55dcec684e5e99434@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ShwMJupcxbTnBXyanQNalBy"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ShwMJupcxbTnBXyanQNalBy
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 25 Jun 2013 11:37:04 +1000
Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Jeff,
>=20
> Thanks for doing all this work!
>=20
> Trivial comments below.
>=20
> On Fri, 21 Jun 2013 08:58:14 -0400 Jeff Layton <jlayton@redhat.com> wrote:
> >
> > +static inline void
> > +locks_insert_global_locks(struct file_lock *fl)
> > +{
> > +	list_add_tail(&fl->fl_link, &file_lock_list);
> > +}
>=20
> We generally do not use "inline" in C files any more and leave it to the
> compiler to do that.  Also, without the "inline" these function headers
> should all be able to fit on single lines like the others here i.e.
>=20
> static void locks_insert_global_locks(struct file_lock *fl)
>=20

Thanks for helping review.

Usually that makes sense, but doesn't the compiler generally determine
that by counting the number of call sites? In this case, we'll have
several call sites and it probably wouldn't inline the function. That
makes this a little less efficient since we'll have to jump to this
routine, do the list_add_tail and then jump back.

That said, I'm not opposed to doing that since these routines grow a
bit in size later and we'll only do this when a lock is acquired or
dropped. I think Al has already merged most of this set into his
for-next branch though. Perhaps I can do a patch on top of that set
that removes the inline keywords from those functions?

--=20
Jeff Layton <jlayton@redhat.com>

--Sig_/ShwMJupcxbTnBXyanQNalBy
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJRyXG1AAoJEAAOaEEZVoIV188QALcuRamXPJN7nN/0F1U8vBST
dnkD9sbdZ9z69wiZxs+mlsNQrB9i/y5z8TdPII4EanP34WF/4J49/6A3sKbfF/76
d5QbvbNwovDd2W9jOdlJ6GJ9vy7BvMaDz9bVmykmGT+65BYyb/Pt1w2dC1TLf7CT
u2XfbmejGEYA7YUuW3nJhjDMDZCQiOGX2DPXX/+Fzp7keWoipMLaMR5UedoYe7Oh
mtG8YrxHOKrqLofY9QTzXaZ6J2URsfkpG75nF7RmKEwkJzpO5OAKrcJJrmzb1MjP
AdSPXgVziKoB0Xw/fxL8UH30Ery9JmhiWDqqJoX2XurCQx71O/+liFquNvdilUTI
gtwx5mlJAsmTGCMVz7EFq7Lv4nSLp6VI+f9fdP4UlA17i6JTBvug/29tvEVKC6FP
BsiHilT/59onUY8lVgfDp5XxgA/s7RdCPolbRChH4zvMdxmGOJ4P33kUFqWLRjn9
DfKsPFrozVBNmUjQc9mUnwzLjGgEIyX1PJSoyJihJZhKoOcyXRvMC+/hi1eYJuZA
H8u6vqXIyZE+PnLnS4Ki+J4tLXZcRMybZLCv9YrmUctJYdnujzRf7Don+pBAZ9we
rkwZH4sw3fFRz0NR8rjHuVXzsPhZtIsIfEjFbO3Xcon7JUFYKBFxGvqoZDLwAAUz
jqMvz+6wt0Lz2IFiMU56
=cqOu
-----END PGP SIGNATURE-----

--Sig_/ShwMJupcxbTnBXyanQNalBy--
