Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:32975 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab2HaIA1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Aug 2012 04:00:27 -0400
MIME-Version: 1.0
In-Reply-To: <20120831043352.GA23663@NickAndBarb.net>
References: <20120829162527.GA3635@NickAndBarb.net>
	<20120829151641.20cde4bc@corrin.poochiereds.net>
	<20120831043352.GA23663@NickAndBarb.net>
Date: Fri, 31 Aug 2012 12:00:26 +0400
Message-ID: <CAKywueSY+NOV3irDm9YxepeCyJJhh82o2mgmDLogr+hJPbaYig@mail.gmail.com>
Subject: Re: WARNING: at fs/inode.c:280 drop_nlink+0x31/0x33()
From: Pavel Shilovsky <piastryyy@gmail.com>
To: Nick Pasich <Nick@nickandbarb.net>
Cc: Jeff Layton <jlayton@redhat.com>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/8/31 Nick Pasich <Nick@nickandbarb.net>:
> Jeff,
>
> I applied this patch to Kernel 3.5.3 from Pavel and the
> the warning is gone with no problems.
>
> Thanks,
>
> --( Nick Pasich
>
> ##########################################################
>
> From df2d6b1fbf2401c5ee04f2ac143ea0954e3a87a6 Mon Sep 17 00:00:00 2001
> From: Pavel Shilovsky <pshilovsky@samba.org>
> Date: Fri, 13 Jul 2012 11:59:45 +0400
> Subject: [PATCH] CIFS: Protect i_nlink from being negative
>
> that can cause warning messages.
>
> Signed-off-by: Pavel Shilovsky <pshilovsky@samba.org>
> ---
>  fs/cifs/inode.c |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
>
> diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
> index 7354877..88afb1a 100644
> --- a/fs/cifs/inode.c
> +++ b/fs/cifs/inode.c
> @@ -1110,6 +1110,15 @@ undo_setattr:
>                 goto out_close;
>  }
>
> +/* copied from fs/nfs/dir.c with small changes */
> +static void
> +cifs_drop_nlink(struct inode *inode)
> +{
> +       spin_lock(&inode->i_lock);
> +       if (inode->i_nlink > 0)
> +               drop_nlink(inode);
> +       spin_unlock(&inode->i_lock);
> +}
>
>  /*
>   * If dentry->d_inode is null (usually meaning the cached dentry
> @@ -1166,13 +1175,13 @@ retry_std_delete:
>  psx_del_no_retry:
>                 if (!rc) {
>                                 if (inode)
> -                       drop_nlink(inode);
> +                       cifs_drop_nlink(inode);
>                 } else if (rc == -ENOENT) {
>                                 d_drop(dentry);
>                 } else if (rc == -ETXTBSY) {
>                                 rc = cifs_rename_pending_delete(full_path, dentry, xid);
>                                 if (rc == 0)
> -                       drop_nlink(inode);
> +                       cifs_drop_nlink(inode);
>                 } else if ((rc == -EACCES) && (dosattr == 0) && inode) {
>                                 attrs = kzalloc(sizeof(*attrs), GFP_KERNEL);
>                                 if (attrs == NULL) {
> --
> 1.7.3.3
>
> ##########################################################
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-cifs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

This one fixes only a part of the problem. Now we have another patch
for this problem:

https://git.samba.org/sfrench/?p=sfrench/cifs-2.6.git;a=commitdiff;h=b7ca69289680cf631fb20b7d436467c4ec1153cd;hp=6dab7ede9390d4d937cb89feca932e4fd575d2da

-- 
Best regards,
Pavel Shilovsky.
