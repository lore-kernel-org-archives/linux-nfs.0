Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:59743 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754642Ab0IHUZa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Sep 2010 16:25:30 -0400
Subject: Re: Re :statfs() gives ESTALE error
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4C8790AF.5010300@bull.net>
References: <4C7E4469.70807@duchatelet.net>  <4C8790AF.5010300@bull.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 08 Sep 2010 16:25:25 -0400
Message-ID: <1283977525.2905.18.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-09-08 at 15:33 +0200, Menyhart Zoltan wrote:
> Hi,
> 
> An NFS client executes a statfs("file", &buff) call.
> "file" exists / existed, the client has read / written it,
> but it has already closed it.
> 
> user_path(pathname, &path) looks up "file" successfully in the
> directory-cache  and restarts the aging timer of the directory-entry.
> Even if "file" has already been removed from the server, because the
> lookupcache=positive option I use, keeps the entries valid for a while.
> 
> nfs_statfs() returns ESTALE if "file" has already been removed from the
> server.
> 
> If the user application repeats the statfs("file", &buff) call, we
> are stuck: "file" remains young forever in the directory-cache.
> 
> Signed-off-by: Zoltan Menyhart  <Zoltan.Menyhart@bull.net>
---
Please include the above as part of the patch itself if you send it as
an attachment. Otherwise, I need to manually sew the two back together
before I can apply them through git.

> diff -Nru linux-2.6.36-rc3-orig/fs/nfs/super.c
> linux-2.6.36-rc3-new/fs/nfs/super.c
> --- linux-2.6.36-rc3-orig/fs/nfs/super.c        2010-08-29
> 17:36:04.000000000 +0200
> +++ linux-2.6.36-rc3-new/fs/nfs/super.c 2010-09-08 11:33:03.078684569
> +0200
> @@ -431,7 +431,15 @@
>                 goto out_err;
>  
>         error = server->nfs_client->rpc_ops->statfs(server, fh, &res);
> +       if (unlikely(error == -ESTALE)) {
>  
> +               struct dentry *pd_dentry;
> +
> +               if ((pd_dentry = dget_parent(dentry)) != NULL) {

Assignments inside an 'if ()' are frowned upon by the Linux style gods.
I'll fix this up.

> +                       nfs_zap_caches(pd_dentry->d_inode);
> +                       dput(pd_dentry);
> +               }
> +       }
>         nfs_free_fattr(res.fattr);
>         if (error < 0)
>                 goto out_err;

