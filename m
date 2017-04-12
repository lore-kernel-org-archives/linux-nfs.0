Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33256 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753060AbdDLS7Q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Apr 2017 14:59:16 -0400
Received: by mail-io0-f172.google.com with SMTP id k87so35585353ioi.0
        for <linux-nfs@vger.kernel.org>; Wed, 12 Apr 2017 11:59:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170405152914.GA57260@beast>
References: <20170405152914.GA57260@beast>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 12 Apr 2017 11:59:13 -0700
Message-ID: <CAGXu5j+t3Dm7ZBK=TwKoPWjJ3HUp1xUNoVd8xymSbk11iYTDJg@mail.gmail.com>
Subject: Re: [PATCH v2] NFS: Avoid cross-structure casting
To: LKML <linux-kernel@vger.kernel.org>
Cc: NeilBrown <neilb@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 5, 2017 at 8:29 AM, Kees Cook <keescook@chromium.org> wrote:
> When the call to nfs_devname() fails, the error path attempts to retain
> the error via the mnt variable, but this requires a cast across very
> different types (char * to struct vfsmount *), which the upcoming
> structure layout randomization plugin flags as being potentially
> dangerous in the face of randomization. This is a false positive, but
> what this code actually wants to do is retain the error value, so this
> patch explicitly sets it, instead of using what seems to be an
> unexpected cast.
>
> Signed-off-by: Kees Cook <keescook@chromium.org>

If I can get an Acked-by on this, I could push it via the gcc-plugin tree.

Thanks!

-Kees

> ---
> v2: duh, use ERR_CAST. thanks neilb!
> ---
>  fs/nfs/namespace.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
> index 786f17580582..8ca5d147124d 100644
> --- a/fs/nfs/namespace.c
> +++ b/fs/nfs/namespace.c
> @@ -259,9 +259,10 @@ struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
>         if (page == NULL)
>                 goto out;
>         devname = nfs_devname(dentry, page, PAGE_SIZE);
> -       mnt = (struct vfsmount *)devname;
> -       if (IS_ERR(devname))
> +       if (IS_ERR(devname)) {
> +               mnt = ERR_CAST(devname);
>                 goto free_page;
> +       }
>         mnt = nfs_do_clone_mount(NFS_SB(dentry->d_sb), devname, &mountdata);
>  free_page:
>         free_page((unsigned long)page);
> --
> 2.7.4
>
>
> --
> Kees Cook
> Pixel Security



-- 
Kees Cook
Pixel Security
