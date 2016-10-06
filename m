Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50079 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751772AbcJFGjd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Oct 2016 02:39:33 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 06 Oct 2016 17:39:24 +1100
Cc: fdmanana@kernel.org, linux-btrfs@vger.kernel.org,
        NFS List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] exportfs: be careful to only return expected errors.
In-Reply-To: <877fbxperp.fsf@notabene.neil.brown.name>
References: <1465491191-28102-1-git-send-email-fdmanana@kernel.org> <874m7i8oou.fsf@notabene.neil.brown.name> <20160722015904.GB29969@fieldses.org> <87bn1q75ut.fsf@notabene.neil.brown.name> <20160722200843.GA7463@fieldses.org> <877fbxperp.fsf@notabene.neil.brown.name>
Message-ID: <87h98q3rs3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 04 2016, NeilBrown wrote:

>
>
> When nfsd calls fh_to_dentry, it expect ESTALE or ENOMEM as errors.
> In particular it can be tempting to return ENOENT, but this is not
> handled well by nfsd.
>
> Rather than requiring strict adherence to error code code filesystems,
> treat all unexpected error codes the same as ESTALE.  This is safest.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>
> I didn't add a dprintk for unexpected error messages, partly
> because dprintk isn't usable in exportfs.  I could have used pr_debug()
> but I really didn't see much value.
>
> This has been tested together with the btrfs change, and it restores
> correct functionality.
>
> Thanks,
> NeilBrown


Hi Bruce,
 I notice that this patch isn't in -next, but the btrfs change which
 motivated it is.
 That means, unless there is some other work around somewhere, btrfs
 might start having problems with nfs export.

 Can we get this patch into 4.9-rc??

 Or has someone fixed it a different way?

Thanks,
NeilBrown


>
>  fs/exportfs/expfs.c      | 10 ++++++----
>  include/linux/exportfs.h | 13 +++++++------
>  2 files changed, 13 insertions(+), 10 deletions(-)
>
> diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
> index 207ba8d627ca..a4b531be9168 100644
> --- a/fs/exportfs/expfs.c
> +++ b/fs/exportfs/expfs.c
> @@ -428,10 +428,10 @@ struct dentry *exportfs_decode_fh(struct vfsmount *=
mnt, struct fid *fid,
>  	if (!nop || !nop->fh_to_dentry)
>  		return ERR_PTR(-ESTALE);
>  	result =3D nop->fh_to_dentry(mnt->mnt_sb, fid, fh_len, fileid_type);
> -	if (!result)
> -		result =3D ERR_PTR(-ESTALE);
> -	if (IS_ERR(result))
> -		return result;
> +	if (PTR_ERR(result) =3D=3D -ENOMEM)
> +		return ERR_CAST(result);
> +	if (IS_ERR_OR_NULL(result))
> +		return ERR_PTR(-ESTALE);
>=20=20
>  	if (d_is_dir(result)) {
>  		/*
> @@ -541,6 +541,8 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mn=
t, struct fid *fid,
>=20=20
>   err_result:
>  	dput(result);
> +	if (err !=3D -ENOMEM)
> +		err =3D -ESTALE;
>  	return ERR_PTR(err);
>  }
>  EXPORT_SYMBOL_GPL(exportfs_decode_fh);
> diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
> index b03c0625fa6e..5ab958cdc50b 100644
> --- a/include/linux/exportfs.h
> +++ b/include/linux/exportfs.h
> @@ -157,12 +157,13 @@ struct fid {
>   *    @fh_to_dentry is given a &struct super_block (@sb) and a file hand=
le
>   *    fragment (@fh, @fh_len). It should return a &struct dentry which r=
efers
>   *    to the same file that the file handle fragment refers to.  If it c=
annot,
> - *    it should return a %NULL pointer if the file was found but no acce=
ptable
> - *    &dentries were available, or an %ERR_PTR error code indicating why=
 it
> - *    couldn't be found (e.g. %ENOENT or %ENOMEM).  Any suitable dentry =
can be
> - *    returned including, if necessary, a new dentry created with d_allo=
c_root.
> - *    The caller can then find any other extant dentries by following the
> - *    d_alias links.
> + *    it should return a %NULL pointer if the file cannot be found, or an
> + *    %ERR_PTR error code of %ENOMEM if a memory allocation failure occu=
rred.
> + *    Any other error code is treated like %NULL, and will cause an %EST=
ALE error
> + *    for callers of exportfs_decode_fh().
> + *    Any suitable dentry can be returned including, if necessary, a new=
 dentry
> + *    created with d_alloc_root.  The caller can then find any other ext=
ant
> + *    dentries by following the d_alias links.
>   *
>   * fh_to_parent:
>   *    Same as @fh_to_dentry, except that it returns a pointer to the par=
ent
> --=20
> 2.9.2

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX9fGcAAoJEDnsnt1WYoG5w/4QAIEn4ntd57wgyL7jpoKV9zQ4
XXd2b1IWX+0Zw780N1+8lFZIrVhDAg9cz6di/PI9GHDI11RywjhjZPUOOgB1GADi
GbBAG8ixmkgFuY5VqDR4z5vJCLlHePd1d0UBas6vpOtHcsY06fhEyYjVurIRBZc1
M9BBZSLjXzrwsYikclJH/YGJeQOf2GwHrtQ+O8j5n8ReGVL4UMrrkjuW7mvAGLLv
WYUOwT2TGivKI2BLGi2LQXevr30ild/V+ohTI/wGLqgH/QSdI7z2B5qOk/miann+
JEO2tTNqDcTittUoLPLgCWKNFim8Y1tzLxHRIKsgqTeYrLZ0nP1a0/H9bPcq1WSJ
7fZPc5vy43hKad54xSn30KvlvycohSBWdfAagOL8r66lORCDJonOT+jBqAH/Ko7P
Y/JuPnFR4qQfu9YhJZfZTMN59Y8P9rqjISgjWXyuWJ4rA+edfDTJn0h1WnQX6Esx
aE3e0Qp5V46vWW4yY09+sEWo+OvWaGHhimmPQOpNPICBCl863VDaZwPkmKyREGFG
QBkV6PTtbzsdeKN6Bj9lUZs/d/UknZ5iL/p25jTr+9wOyPugS1tbkCwHvzE5WBwS
GfQco8eXNxxqaGONtZ2a2SVJ6oFcOecTykxhaTXB5/sSuxgTM/EhnJabnQGRh3Y3
jy05Kcwy2UMu8mPQopuD
=MMtl
-----END PGP SIGNATURE-----
--=-=-=--
