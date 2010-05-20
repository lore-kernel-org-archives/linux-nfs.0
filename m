From: Tao Guo <glorioustao@gmail.com>
Subject: Re: [PATCH] pnfs: call layoutcommit after flushing inode's data to
	disk.
Date: Thu, 20 May 2010 12:42:35 +0800
Message-ID: <AANLkTikc6JXz1ubKJHxs0UJq-x80Mafsz4SKgkBPZgnf@mail.gmail.com>
References: <20100520032759.GA26892@vmware>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52876 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414Ab0ETEmh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 May 2010 00:42:37 -0400
Received: by vws9 with SMTP id 9so4452241vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 19 May 2010 21:42:36 -0700 (PDT)
In-Reply-To: <20100520032759.GA26892@vmware>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is for a bug introduced to 2.6.34. In 2.6.32 and 2.6.33 we call
layoutcommit in
nfs_sync_mapping_wait(), but in 2.6.34 we use sync_inode() to sync
inode's data, so
the layoutcommit code is gone.

BTW: In current code, layoutcommit_ctx will increase refcount of
nfs_inode's ctx, so if
layoutcommit_ctx is not NULL, we could not reach nfs4_close_context
=2E.. --> __nfs_close().
So pnfs_layoutcommit_inode() in __nfs_close() will not be called in
whatever situation.
Why we have to use nfs_inode's ctx as layoutcommit_ctx, since we only
need its rpc_creds
actually?

On Thu, May 20, 2010 at 11:28 AM, Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org> wrote:
> Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
> ---
> =C2=A0fs/nfs/write.c | =C2=A0 =C2=A08 +++++++-
> =C2=A01 files changed, 7 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index d3e1645..b4f48b2 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1558,6 +1558,7 @@ int nfs_write_inode(struct inode *inode, struct=
 writeback_control *wbc)
> =C2=A0*/
> =C2=A0int nfs_wb_all(struct inode *inode)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 int ret;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct writeback_control wbc =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.sync_mode =3D=
 WB_SYNC_ALL,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.nr_to_write =3D=
 LONG_MAX,
> @@ -1565,7 +1566,12 @@ int nfs_wb_all(struct inode *inode)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.range_end =3D=
 LLONG_MAX,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0};
>
> - =C2=A0 =C2=A0 =C2=A0 return sync_inode(inode, &wbc);
> + =C2=A0 =C2=A0 =C2=A0 ret =3D sync_inode(inode, &wbc);
> +#ifdef CONFIG_NFS_V4_1
> + =C2=A0 =C2=A0 =C2=A0 if (!ret && NFS_I(inode)->layoutcommit_ctx)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D pnfs_layou=
tcommit_inode(inode, 1);
> +#endif
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> =C2=A0}
>
> =C2=A0int nfs_wb_page_cancel(struct inode *inode, struct page *page)
> --
> 1.6.3.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>



--=20
tao.
