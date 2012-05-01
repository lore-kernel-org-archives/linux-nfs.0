Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43500 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754704Ab2EAWje (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 18:39:34 -0400
Date: Wed, 2 May 2012 08:39:26 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Adapt readdirplus to application usage patterns
Message-ID: <20120502083926.1583f5f7@notabene.brown>
In-Reply-To: <1335909983-26413-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1335909983-26413-1-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/3jYN1WSdw2xNH3D9PTMohJz"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/3jYN1WSdw2xNH3D9PTMohJz
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue,  1 May 2012 18:06:23 -0400 Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:

> While the use of READDIRPLUS is significantly more efficient than
> READDIR followed by many LOOKUP calls, it is still less efficient
> than just READDIR if the attributes are not required.
>=20
> This patch tracks when lookups are attempted on the directory,
> and uses that information to selectively disable READDIRPLUS
> on that directory.
> The first 'readdir' call is always served using READDIRPLUS.
> Subsequent calls only use READDIRPLUS if there was a successful
> lookup or revalidation on a child in the mean time.
>=20
> Credit for the original idea should go to Neil Brown. See:
>       http://www.spinics.net/lists/linux-nfs/msg19996.html
> However, the implementation in this patch differs from Neil's
> in that it focuses on tracking lookups rather than calls to
> stat().
>=20
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Neil Brown <neilb@suse.de>

Thanks!  Looks good.
Tracking lookups rather than getattr does make sense - more general.

> @@ -874,7 +897,9 @@ static int nfs_readdir(struct file *filp, void *diren=
t, filldir_t filldir)
>  	desc->file =3D filp;
>  	desc->dir_cookie =3D &dir_ctx->dir_cookie;
>  	desc->decode =3D NFS_PROTO(inode)->decode_dirent;
> -	desc->plus =3D NFS_USE_READDIRPLUS(inode);
> +	desc->plus =3D 0;
> +	if (nfs_use_readdirplus(inode, filp))
> +		desc->plus =3D 1;
> =20

This looks a bit odd to me.

        desc->plus =3D nfs_use_readdirplus(inode, filp):
??
Or if you think there is a type conflict:
        desc->plus =3D nfs_use_readdirplus(inode, file) ? 1 : 0;

But maybe you prefer the original - your choice of course.

Also, the current code will clear NFS_INO_ADVISE_RDPLUS if it gets -ETOOSMA=
LL,
and it will stay cleared until the inode falls out of cache and is reloaded.
The new code will set it again a lot sooner.  Is that likely to be a problem
(I don't remember what conditions lead to ETOOSMALL)?
In fact I think it will ignore  the ETOOSMALL and always retry with
readdirplus for the first read in a directory.  That doesn't seem good ?

Thanks,
NeilBrown


--Sig_/3jYN1WSdw2xNH3D9PTMohJz
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT6BmHjnsnt1WYoG5AQIvjRAAo6KibDoRRh3BxUIjp7z3t1RNS5OxzWcE
YPURfYFILHgqxsd3ZnBXkkposHVg9OEC4vMNsGwieWsxwnkK5mcrX5IM0O+jeS0G
Ua3DFbzYdZgcTIUGuynGDGV8OpM5Svk0q9yRWju1s/we0mxbtZp4JqVg9P+tCpYO
8fgLOp2w9x2E2hMwjvnbKd0a2d58q2v57Rbq/6P9c7VvKqb0VTmYCARSMuvLqggK
p1LGHUfSKtZA2YvRvBA5rSNl/tEmAHHGDqygR+woNLWmCGfd7bkGxMkEuIzQP3Qo
hLZDkV0nTk9KjIZvX+wSl5hzg03z41mIGMurlWPqWm54ZIng/UPBf3SWYg9AQ6wK
l+/LGEO7Dlgse6DmEMzxcjZhr/QeuByBzj2Nn3WrHh4BJ5/7DEN9Q9o5R1qhv0or
LvfO3uWUiUEtF1LnbbIz9fZ6HM9xBbHTzWduOu/zI/XBut/VgDb8ao5eCl24VJPW
aF/5KjefGPKWrdy57zhUTVzwqzFSfY+619fgKyLDAerJg6/srizrSBemaHInHeNh
eBliljTzCXDEyqdFPjjvjaT0g5nooIjuza+mPse+PY8UhRZTzQ3O8qw5WQocMXu7
8wy5HoVz+s7UVvKSJRt4tRyYjOprvuf+lrsPmuKG+ziB5kKXofODKVOwfeOQprH/
Yh9NkqGhSGs=
=QJxU
-----END PGP SIGNATURE-----

--Sig_/3jYN1WSdw2xNH3D9PTMohJz--
