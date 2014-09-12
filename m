Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f182.google.com ([209.85.160.182]:33210 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985AbaILDDq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 23:03:46 -0400
Received: by mail-yk0-f182.google.com with SMTP id 131so68091ykp.27
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 20:03:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410490895-12684-1-git-send-email-tao.peng@primarydata.com>
References: <1410490895-12684-1-git-send-email-tao.peng@primarydata.com>
From: Peng Tao <tao.peng@primarydata.com>
Date: Fri, 12 Sep 2014 11:03:25 +0800
Message-ID: <CAKVebiVBcmDNajbCWFYqVtm6qRGqkrEN1aUzZcji4RdK-C7F+w@mail.gmail.com>
Subject: Re: [PATCH] nfs41: change PNFS_LAYOUTRET_ON_SETATTR to only return on chown/truncate
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Peng Tao <tao.peng@primarydata.com>, Christoph Hellwig <hch@lst.de>,
        Boaz Harrosh <boaz@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sorry, sent out wrong patch. Please ignore this.

On Fri, Sep 12, 2014 at 11:01 AM, Peng Tao <tao.peng@primarydata.com> wrote:
> Both blocks layout and objects layout want to use it to avoid CB_LAYOUTRECALL
> but that should only happen if client is doing chown or truncate. So change
> PNFS_LAYOUTRET_ON_SETATTR to follow the logic and not to send layoutreturn
> unnecessarily.
>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Boaz Harrosh <boaz@plexistor.com>
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 3 ++-
>  fs/nfs/pnfs.h     | 3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 7dd8aca..e55bd0f 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3213,7 +3213,8 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
>         struct nfs4_label *label = NULL;
>         int status;
>
> -       if (pnfs_ld_layoutret_on_setattr(inode))
> +       if (pnfs_ld_layoutret_on_setattr(inode) &&
> +           sattr->ia_valid & (ATTR_UID|ATTR_GID|ATTR_SIZE))
>                 pnfs_commit_and_return_layout(inode);
>
>         nfs_fattr_init(fattr);
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index aca3dff..1765ea8 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -68,7 +68,8 @@ enum {
>  };
>
>  enum layoutdriver_policy_flags {
> -       /* Should the pNFS client commit and return the layout upon a setattr */
> +       /* Should the pNFS client commit and return the layout upon a setattr
> +        * that changes uid/gid/size. */
>         PNFS_LAYOUTRET_ON_SETATTR       = 1 << 0,
>         PNFS_LAYOUTRET_ON_ERROR         = 1 << 1,
>  };
> --
> 1.9.1
>
