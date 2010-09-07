Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:54155 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756145Ab0IGScK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 14:32:10 -0400
Subject: Re: statfs() gives ESTALE error
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4C7F4AB7.5020802@bull.net>
References: <4C7E4469.70807@duchatelet.net>  <4C7F4AB7.5020802@bull.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Sep 2010 14:32:05 -0400
Message-ID: <1283884325.2788.59.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-09-02 at 08:56 +0200, Menyhart Zoltan wrote:
> Hi,
> 
> An NFS client executes a statfs("file", &buff) call.
> "file" exists / existed, the client has read / written it,
> but it has already closed it.
> 
> user_path(pathname, &path) looks up "file" successfully in the
> directory-cache  and restarts the aging timer of the directory-entry.
> Even if "file" has already been removed from the server, because the
> lookupcache=positive opcion I use, keeps the entries valid for a while.
> 
> nfs_statfs() returns ESTALE if "file" has already been removed from the
> server.
> 
> If the user application repeats the statfs("file", &buff) call, we
> are stuck: "file" remains young forever in the directory-cache.
> 
> Should not this directory-entry be cleaned up?
> 
> --- linux-2.6.32.x86_64-orig/fs/nfs/super.c     2010-08-02 14:34:57.000000000 +0200
> +++ linux-2.6.32.x86_64/fs/nfs/super.c  2010-08-31 16:57:30.000000000 +0200
> @@ -429,6 +429,22 @@
>          int error;
>   
>          error = server->nfs_client->rpc_ops->statfs(server, fh, &res);
> +       if (unlikely(error == -ESTALE)){
> +
> +               struct inode *pd_inode;
> +
> +               BUG_ON(dentry->d_parent == NULL);
> +               pd_inode = dentry->d_parent->d_inode;

Should be using dget_parent() to ensure that the parent directory
doesn't disappear beneath us while we're working on it (with a matching
d_put()).

> +               BUG_ON(pd_inode == NULL);

Why the 2 BUG_ON()? If the conditions are true, then the kernel will
Oops anyway.

> +               /*
> +                * This forces the revalidation code in nfs_lookup_revalidate() to do a
> +                * full lookup on all child dentries of 'dir' whenever a change occurs
> +                * on the server that might have invalidated our dcache.
> +                */
> +               spin_lock(&pd_inode->i_lock);
> +               nfs_force_lookup_revalidate(pd_inode);
> +               spin_unlock(&pd_inode->i_lock);

The above should probably be a nfs_zap_caches(). We need to not only
revalidate the lookup cache, but also to clear the readdir cache.

> +       }
>          if (error < 0)
>                  goto out_err;
>          buf->f_type = NFS_SUPER_MAGIC;
> 
> It's for the 2.6.32, yet the 2.6.36 dos not change from this aspect.

Can you fix the above, then resend (for 2.6.36) with a Signed-off-by:
line?

Cheers
  Trond

