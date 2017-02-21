Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:47758 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753218AbdBUTrF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Feb 2017 14:47:05 -0500
From: Weston Andros Adamson <dros@primarydata.com>
To: Bruce Fields <bfields@redhat.com>
CC: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@netapp.com>
Subject: Re: [PATCH 2/6] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Date: Tue, 21 Feb 2017 19:46:58 +0000
Message-ID: <261D4020-D9E4-4F1E-81CF-11EAAEABA684@primarydata.com>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1487470070-32358-3-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 18, 2017, at 9:07 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>=20
> From: Weston Andros Adamson <dros@netapp.com>
>=20
> We're not taking into account that the space needed for the (variable
> length) attr bitmap, with the result that we'd sometimes get a spurious
> ERANGE when the ACL data got close to the end of a page.
>=20
> Just add in an extra page to make sure.
>=20
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Thanks, you can add:

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>


> ---
> fs/nfs/nfs4proc.c | 8 ++------
> 1 file changed, 2 insertions(+), 6 deletions(-)
>=20
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 0a0eaecf9676..60501e10625d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5069,7 +5069,7 @@ static void nfs4_write_cached_acl(struct inode *ino=
de, struct page **pages, size
>  */
> static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, si=
ze_t buflen)
> {
> -=09struct page *pages[NFS4ACL_MAXPAGES] =3D {NULL, };
> +=09struct page *pages[NFS4ACL_MAXPAGES + 1] =3D {NULL, };
> =09struct nfs_getaclargs args =3D {
> =09=09.fh =3D NFS_FH(inode),
> =09=09.acl_pages =3D pages,
> @@ -5083,13 +5083,9 @@ static ssize_t __nfs4_get_acl_uncached(struct inod=
e *inode, void *buf, size_t bu
> =09=09.rpc_argp =3D &args,
> =09=09.rpc_resp =3D &res,
> =09};
> -=09unsigned int npages =3D DIV_ROUND_UP(buflen, PAGE_SIZE);
> +=09unsigned int npages =3D DIV_ROUND_UP(buflen, PAGE_SIZE) + 1;
> =09int ret =3D -ENOMEM, i;
>=20
> -=09/* As long as we're doing a round trip to the server anyway,
> -=09 * let's be prepared for a page of acl data. */
> -=09if (npages =3D=3D 0)
> -=09=09npages =3D 1;
> =09if (npages > ARRAY_SIZE(pages))
> =09=09return -ERANGE;
>=20
> --=20
> 2.9.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

