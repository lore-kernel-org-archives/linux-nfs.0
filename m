From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 2/2] SQUASHME: pnfs-submit: clean up nfs_lock_alloc_layout
Date: Tue, 13 Jul 2010 09:44:31 -0400
Message-ID: <AANLkTin5Wo-9paVQvfXZwDx5KZFkpSSspTCIN6vRCc8h@mail.gmail.com>
References: <4C3B611C.1000208@panasas.com>
	<1278960015-32215-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:62371 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755928Ab0GMNod convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 09:44:33 -0400
Received: by gwj18 with SMTP id 18so2692409gwj.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jul 2010 06:44:32 -0700 (PDT)
In-Reply-To: <1278960015-32215-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 12, 2010 at 2:40 PM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> Fix a bug where the function returned without taking the i_lock
> if the layout hdr was already allocated.
> Simplify by moving inode locking to caller.

No, the original function I sent had no such bug.

>
> Rename function as it no longer grabs the lock.
> Clean up the implementation so it's clearer what's going on
> and what are the likely cases vs. the unlikely ones.

I do not think this is any clearer!

>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> =A0fs/nfs/pnfs.c | =A0 42 ++++++++++++++++++++++--------------------
> =A01 files changed, 22 insertions(+), 20 deletions(-)
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 4ba7595..053a5c1 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -938,36 +938,37 @@ alloc_init_layout(struct inode *ino)
> =A0}
>
> =A0/*
> - * Lock and possibly allocate the inode layout
> + * Retrieve and possibly allocate the inode layout
> =A0*
> - * If successful, ino->i_lock is taken, and the caller must unlock.
> + * ino->i_lock must be taken by the caller.
> =A0*/
> =A0static struct pnfs_layout_type *
> -nfs_lock_alloc_layout(struct inode *ino)
> +pnfs_alloc_layout(struct inode *ino)
> =A0{
> + =A0 =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(ino);
> =A0 =A0 =A0 =A0struct pnfs_layout_type *new =3D NULL;
>
> - =A0 =A0 =A0 dprintk("%s Begin ino=3D%p layout=3D%p\n", __func__, in=
o, NFS_I(ino)->layout);
> + =A0 =A0 =A0 dprintk("%s Begin ino=3D%p layout=3D%p\n", __func__, in=
o, nfsi->layout);
>
> - =A0 =A0 =A0 if (NFS_I(ino)->layout =3D=3D NULL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new =3D alloc_init_layout(ino);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new =3D=3D NULL)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&ino->i_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (NFS_I(ino)->layout =3D=3D NULL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NFS_I(ino)->layout =3D =
new;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 if (new) {
> + =A0 =A0 =A0 BUG_ON(!spin_is_locked(&ino->i_lock));
> + =A0 =A0 =A0 if (likely(nfsi->layout))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return nfsi->layout;
> +
> + =A0 =A0 =A0 spin_unlock(&ino->i_lock);
> + =A0 =A0 =A0 new =3D alloc_init_layout(ino);
> + =A0 =A0 =A0 spin_lock(&ino->i_lock);
> +
> + =A0 =A0 =A0 if (likely(nfsi->layout =3D=3D NULL)) { =A0 =A0 /* Won =
the race? */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfsi->layout =3D new;
> + =A0 =A0 =A0 } else if (new) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Reference the layout accross i_lock=
 release and grab */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_layout(NFS_I(ino)->layout);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_layout(nfsi->layout);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&ino->i_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NFS_SERVER(ino)->pnfs_curr_ld->ld_io_o=
ps->free_layout(new);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&ino->i_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_layout_locked(NFS_I(ino)->layout);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_layout_locked(nfsi->layout);
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 return NFS_I(ino)->layout;
> + =A0 =A0 =A0 return nfsi->layout;
> =A0}
>
> =A0/*
> @@ -1055,10 +1056,11 @@ _pnfs_update_layout(struct inode *ino,
>
> =A0 =A0 =A0 =A0if (take_ref)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*lsegpp =3D NULL;
> - =A0 =A0 =A0 lo =3D nfs_lock_alloc_layout(ino);
> + =A0 =A0 =A0 spin_lock(&ino->i_lock);
> + =A0 =A0 =A0 lo =3D pnfs_alloc_layout(ino);
> =A0 =A0 =A0 =A0if (lo =3D=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dprintk("%s ERROR: can't get pnfs_layo=
ut_type\n", __func__);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unlock;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* Check to see if the layout for the given range alre=
ady exists */
> --
> 1.7.1.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
