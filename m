Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f169.google.com ([209.85.220.169]:60156 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476AbaHUPbZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 11:31:25 -0400
Received: by mail-vc0-f169.google.com with SMTP id le20so11061671vcb.28
        for <linux-nfs@vger.kernel.org>; Thu, 21 Aug 2014 08:31:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1408633667-24177-1-git-send-email-hch@lst.de>
References: <1408633667-24177-1-git-send-email-hch@lst.de>
Date: Thu, 21 Aug 2014 11:31:24 -0400
Message-ID: <CAHQdGtTniQYMUpOnKnG8H8W5WJsAysZA-FYCy1SHGOpFUebJBg@mail.gmail.com>
Subject: Re: [PATCH] nfs: update time staps on truncate
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph,

On Thu, Aug 21, 2014 at 11:07 AM, Christoph Hellwig <hch@lst.de> wrote:
> The VFS handles attributes on truncate in a strange way, fix NFS to handle
> it properly by copying a small code sniplet from XFS.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/inode.c | 22 +++++++++++++++++++++-
>  1 file changed, 21 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 577a36f..5bbd991 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -505,8 +505,28 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
>                 attr->ia_valid &= ~ATTR_MODE;
>
>         if (attr->ia_valid & ATTR_SIZE) {
> -               if (!S_ISREG(inode->i_mode) || attr->ia_size == i_size_read(inode))
> +               if (!S_ISREG(inode->i_mode) ||
> +                   attr->ia_size == i_size_read(inode))
>                         attr->ia_valid &= ~ATTR_SIZE;
> +
> +               /*
> +                * Only change the c/mtime if we are changing the size or we
> +                * are explicitly asked to change it.  This handles the
> +                * semantic difference between truncate() and ftruncate() as
> +                * implemented in the VFS.
> +                *
> +                * The regular truncate() case without ATTR_CTIME and
> +                * ATTR_MTIME is a special case where we need to update the
> +                * times despite not having these flags set.  For all other
> +                * operations the VFS set these flags explicitly if it wants
> +                * a timestamp update.
> +                */
> +               if (attr->ia_size != i_size_read(inode) &&
> +                   !(attr->ia_valid & (ATTR_CTIME | ATTR_MTIME))) {
> +                       attr->ia_ctime = attr->ia_mtime =
> +                               current_fs_time(inode->i_sb);
> +                       attr->ia_valid |= ATTR_CTIME | ATTR_MTIME;
> +               }
>         }
>

We shouldn't need to set attr->ia_ctime/ia_mtime above. We should set
the file time to the server clock time.
Also note that instead of checking attr->ia_size !=
i_size_read(inode), the above should check attr->ia_valid & ATTR_SIZE
due to the optimisation above.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
