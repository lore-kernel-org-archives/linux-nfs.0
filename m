Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55169 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932514AbeDWWi2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Apr 2018 18:38:28 -0400
From: NeilBrown <neilb@suse.com>
To: Amir Goldstein <amir73il@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 24 Apr 2018 08:38:17 +1000
Cc: Neil Brown <neilb@suse.de>, Hugh Dickins <hughd@google.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [RESEND PATCH v2] tmpfs: allow decoding a file handle of an unlinked file
In-Reply-To: <CAOQ4uxg+qSLP0KwdW+h1tcPqOCQd+_pGZVXiePQB1TXCMBMctQ@mail.gmail.com>
References: <CAOQ4uxg+qSLP0KwdW+h1tcPqOCQd+_pGZVXiePQB1TXCMBMctQ@mail.gmail.com>
Message-ID: <87y3hdmtuu.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Mon, Apr 23 2018, Amir Goldstein wrote:

> tmpfs uses the helper d_find_alias() to find a dentry from a decoded
> inode, but d_find_alias() skips unhashed dentries, so unlinked files
> cannot be decoded from a file handle.
>
> This can be reproduced using xfstests test program open_by_handle:
> $ open_by handle -c /tmp/testdir
> $ open_by_handle -dk /tmp/testdir
> open_by_handle(/tmp/testdir/file000000) returned 116 incorrectly on an
> unlinked open file!
>
> To fix this, if d_find_alias() can't find a hashed alias, call
> d_find_any_alias() to return an unhashed one.
>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Amir Goldstein <amir73il@gmail.com>

Reviewed-by: NeilBrown <neilb@suse.com>

Looks reasonable to me.  You could possibly just use d_find_any_alias()
unconditionally, but there is sometimes a small benefit in getting a
hashed aliases if there is one.

Thanks,
NeilBrown

> ---
>
> Hi Andrew,
>
> I was nudging Hugh over at LSF/MM about this patch and he has
> suggested that I send it to you, because he has no idea about the
> exportfs parts.
>
> The test for decoding a file handle of an unlinked file has already
> been merged to xfstest generic/467 and the test is failing on tmpfs
> without this change.
>
> Can you please take this patch.
>
> Thanks,
> Amir.
>
>  mm/shmem.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 07a1d22807be..5d3fa4099f54 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -3404,6 +3404,15 @@ static int shmem_match(struct inode *ino, void *vfh)
>         return ino->i_ino == inum && fh[0] == ino->i_generation;
>  }
>
> +/* Find any alias of inode, but prefer a hashed alias */
> +static struct dentry *shmem_find_alias(struct inode *inode)
> +{
> +       struct dentry *alias = d_find_alias(inode);
> +
> +       return alias ?: d_find_any_alias(inode);
> +}
> +
> +
>  static struct dentry *shmem_fh_to_dentry(struct super_block *sb,
>                 struct fid *fid, int fh_len, int fh_type)
>  {
> @@ -3420,7 +3429,7 @@ static struct dentry *shmem_fh_to_dentry(struct
> super_block *sb,
>         inode = ilookup5(sb, (unsigned long)(inum + fid->raw[0]),
>                         shmem_match, fid->raw);
>         if (inode) {
> -               dentry = d_find_alias(inode);
> +               dentry = shmem_find_alias(inode);
>                 iput(inode);
>         }
>
> --
> 2.7.4

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlreYFkACgkQOeye3VZi
gbm/gRAAmeBdHi49iH261c+gTAhPbSuurRPZ3maYjV14oHezWAQuZzTtrAGHHRvG
sxgLy1gw3cwZDecpTLA9ZNkBtG/3TAYXS6Y9hfWPejucQfA3rxKbKkyFVMR1t/Z/
IEO+HgAg7Wngn5Pu09lMCA66Q9MW+Cq91nUrJ7uIkJR+5ySX7cf1iuwVoXzt6Div
4TqNHxdH1a/RNtXp68JtiehgC4g5OlKhtbo0EZDiXBfn7c2Xuma7qCMYjUo+WEtW
XjaO8v3HNQTK2j8rnjdD/MhFCSAMQRNULujm5NoA/JTpPgysact0UlNnYyoZFN5Y
4T0M7cm45QDIvkuY0ruQIQ8QXaGm7uFF8F3E5BpQxOiiNG27mdkhb+kfGdrTa9/D
a31Q8p9js/Jdbz4aQMtvShXJmUe//ivpjeOw3+4tfRoVOQk84PjC0QU/CRAbUIbn
IhYofFmvVfj0dPqaOIPNjlAKNRisFRdMNDTjDgqocLlgMGqAXSjh55H1/dCdGm0h
1N9VynKueFcd3SnF1g/sNHtg8alzhhQsS3RHdkllpUno4EyfNOod8YiIwQjXrabU
xVYX/nvyEb34Sr6L+l/am+qPEXLNdVCmFVEoL9vBlHV3CHdKDSR3c7x2jex9/E2T
3Fczxrqg3hemeO+e/RB6oGS3JAtCyfgXFgz8/s2iTWeiZHHqeyw=
=NXbh
-----END PGP SIGNATURE-----
--=-=-=--
