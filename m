Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:37682 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156AbaIKLPZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 07:15:25 -0400
Received: by mail-qa0-f50.google.com with SMTP id cm18so18467733qab.23
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 04:15:24 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 11 Sep 2014 07:15:21 -0400
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: remove BUG possibility in nfs4_open_and_get_state
Message-ID: <20140911071521.71bcc537@tlielax.poochiereds.net>
In-Reply-To: <20140911161937.29dd4a31@notabene.brown>
References: <20140911161937.29dd4a31@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/0HlqVcY+T6GUPwSlVrlcF3f"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/0HlqVcY+T6GUPwSlVrlcF3f
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 11 Sep 2014 16:19:37 +1000
NeilBrown <neilb@suse.de> wrote:

>=20
>=20
> commit 4fa2c54b5198d09607a534e2fd436581064587ed
>     NFS: nfs4_do_open should add negative results to the dcache.
>=20
> used "d_drop(); d_add();" to ensure that a dentry was hashed
> as a negative cached entry.
> This is not safe if the dentry has an non-NULL ->d_inode.
> It will trigger a BUG_ON in d_instantiate().
> In that case, d_delete() is needed.
>=20
> Also, only d_add if the dentry is currently unhashed, it seems
> pointless removed and re-adding it unchanged.
>=20
> Reported-by: Christoph Hellwig <hch@infradead.org>
> Fixes: 4fa2c54b5198d09607a534e2fd436581064587ed
> Cc: Jeff Layton <jeff.layton@primarydata.com>
> Link: http://lkml.kernel.org/r/20140908144525.GB19811@infradead.org
> Signed-off-by: NeilBrown <neilb@suse.de>
>=20
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 7dd8aca31c29..ac2dd953fc18 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2226,9 +2226,13 @@ static int _nfs4_open_and_get_state(struct nfs4_op=
endata *opendata,
>  	ret =3D _nfs4_proc_open(opendata);
>  	if (ret !=3D 0) {
>  		if (ret =3D=3D -ENOENT) {
> -			d_drop(opendata->dentry);
> -			d_add(opendata->dentry, NULL);
> -			nfs_set_verifier(opendata->dentry,
> +			dentry =3D opendata->dentry;
> +			if (dentry->d_inode)
> +				d_delete(dentry);
> +			else if (d_unhashed(dentry))
> +				d_add(dentry, NULL);
> +
> +			nfs_set_verifier(dentry,
>  					 nfs_save_change_attribute(opendata->dir->d_inode));
>  		}
>  		goto out;

Acked-by: Jeff Layton <jlayton@primarydata.com>

--Sig_/0HlqVcY+T6GUPwSlVrlcF3f
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUEYRJAAoJEAAOaEEZVoIVE5IP/1UfVPOik0ZKv6rYVAf8nhkt
b4fDkDUgXXBMH3DLTw+sB/CKDjyWMlBNBivESlSd9aGOHmRiKORXJGejJlnOJJIn
Jd5oPmD5pMaVj7a0oNnWCjPfuVQcaCxTmhirFEJ/7snHisFhso09RIBJfBDx0Rha
y7sgckUY0uXScSsnpcrpeAlcLQaAfMu/Umm9pjSt1NPBpxpywkV9917L0nmn293g
Xk+5k73uCKKKi0JJSy5Ys1Pkfd/QX/E+y43glVaFAaw9cPoF9DA2ER91U1ImAU4z
T1VURitzc3fG+EdCZE6vt98t91oljjKFAKsLY3JDWac4gRXjj5VqTT5ioSAZvpVC
SiZF9oDeKvf6QaEvnq+treu6bim+7pmrJBKoEENHEtjnf10R8AbMjB88uFZ8JAGN
sPZQo0oOleE78/L6gMmsPLvqt6HLhfWOKOybxxpz8xCzIznXnRVhsaARlEXpQudp
mGeoJ1S3rE24smsKLJ5MEMZ3O5PxUN1xNHg/M3kd1KGmnOjawWp4DDQZmaI2XgKU
9xH4rq5gsd2v0ydXg8W+lfW9K91vPo+0/DgaHGH4vACera1542V4Q/MmkruAeiPv
Bk+3qzykS7EK5l3RZa6DLUhkxFA7gMBugsBjqBGh8xyv2p7jVxfw6io8qBhEWTKF
TXXLC7ZHty5LUwrX2LfM
=/xoc
-----END PGP SIGNATURE-----

--Sig_/0HlqVcY+T6GUPwSlVrlcF3f--
