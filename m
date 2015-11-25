Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35784 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbbKYWNP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2015 17:13:15 -0500
Received: by igl9 with SMTP id 9so102622099igl.0
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2015 14:13:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1448477445-17853-1-git-send-email-jeff.layton@primarydata.com>
References: <1448477445-17853-1-git-send-email-jeff.layton@primarydata.com>
From: Steve French <smfrench@gmail.com>
Date: Wed, 25 Nov 2015 16:12:54 -0600
Message-ID: <CAH2r5mu6ruACC72NXD=CAH+C3Sa-fbNdMtBSbFTE=0Q+uwtToA@mail.gmail.com>
Subject: Re: [PATCH] nfs: ensure that attrcache is revalidated after a SETATTR
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I tested it on a previously failing chmod/chattr/stat scenario (where
client was relying on cached mode even though server didn't return
post op attributes, and so reported an incorrect mode in stat) and it
fixes that

Reviewed-and-Tested-by: Steve French <steve.french@primarydata.com>

On Wed, Nov 25, 2015 at 12:50 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> If we get no post-op attributes back from a SETATTR operation, then no
> attributes will of course be updated during the call to
> nfs_update_inode.
>
> We know however that the attributes are invalid at that point, since we
> just changed some of them. At the very least, the ctime will be bogus.
> If we get no post-op attributes back on the call, mark the attrcache
> invalid to reflect that fact.
>
> Reviewed-by: Steve French <steve.french@primarydata.com>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfs/inode.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index ffdf9b9e88ab..31b0a52223a7 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -618,7 +618,10 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr,
>                 nfs_inc_stats(inode, NFSIOS_SETATTRTRUNC);
>                 nfs_vmtruncate(inode, attr->ia_size);
>         }
> -       nfs_update_inode(inode, fattr);
> +       if (fattr->valid)
> +               nfs_update_inode(inode, fattr);
> +       else
> +               NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
>         spin_unlock(&inode->i_lock);
>  }
>  EXPORT_SYMBOL_GPL(nfs_setattr_update_inode);
> --
> 2.4.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Thanks,

Steve
