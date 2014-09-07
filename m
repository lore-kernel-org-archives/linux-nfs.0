Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f178.google.com ([209.85.220.178]:65457 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbaIGQl3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Sep 2014 12:41:29 -0400
Received: by mail-vc0-f178.google.com with SMTP id la4so14347289vcb.37
        for <linux-nfs@vger.kernel.org>; Sun, 07 Sep 2014 09:41:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410104201-32517-2-git-send-email-hch@lst.de>
References: <1410104201-32517-1-git-send-email-hch@lst.de>
	<1410104201-32517-2-git-send-email-hch@lst.de>
Date: Sun, 7 Sep 2014 12:41:28 -0400
Message-ID: <CAHQdGtTe_mi_0N6hGApfrx_3TtL7=btWZNc9wd3hrkMdLRVfzQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfs: update time staps on truncate
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 7, 2014 at 11:36 AM, Christoph Hellwig <hch@lst.de> wrote:
> The VFS handles attributes on truncate in a strange way, fix NFS to
> properly update timestamps on truncate().
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/inode.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 141c9f4..97bc485 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -507,8 +507,20 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
>         if (attr->ia_valid & ATTR_SIZE) {
>                 BUG_ON(!S_ISREG(inode->i_mode));
>
> +               /*
> +                * Calling conventions are a little "unconventional" for
> +                * truncate:
> +                *  - for truncate() the VFS does not set ATTR_CTIME and
> +                *    ATTR_MTIME, but we still need need to update the time
> +                *    stamps if we change the file size.
> +                *  - for ftruncate() the VFS sets ATTR_CTIME and ATTR_MTIME,
> +                *    and we always need to change the time stamp, even if
> +                *    the size does not change.
> +                */
>                 if (attr->ia_size == i_size_read(inode))
>                         attr->ia_valid &= ~ATTR_SIZE;
> +               else if (!(attr->ia_valid & (ATTR_CTIME | ATTR_MTIME)))
> +                       attr->ia_valid |= ATTR_CTIME | ATTR_MTIME;
>         }
>
>         /* Optimization: if the end result is no change, don't RPC */
> --
>

I'm still confused as to why we need this change to the client. In
RFC5661, Section 18.30.4 there is wording to the effect that:

   Changing the size of a file with SETATTR indirectly changes the
   time_modify and change attributes.  A client must account for this as
   size changes can result in data deletion.

There is similar wording in RFC3530 and even in RFC1813 (see section
3.3.2). Without this sort of guarantee by the server, you could, for
instance, get into nasty situations where the file changes, but the
NFSv3 client doesn't detect it.

So basically, I interpret the spec is saying that we should be able to
rely on the server figuring this out all by itself. I agree that we
have the special corner case of ftruncate(), but the VFS is still
setting the ATTR_CTIME|ATTR_MTIME flags for us in that case, right?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
