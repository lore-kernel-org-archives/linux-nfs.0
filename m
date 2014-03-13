Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:45606 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922AbaCMUIE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Mar 2014 16:08:04 -0400
Received: by mail-ie0-f180.google.com with SMTP id as1so1578563iec.39
        for <linux-nfs@vger.kernel.org>; Thu, 13 Mar 2014 13:08:04 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] nfs: emit a fsnotify_nameremove call in sillyrename codepath
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1394738651-26783-1-git-send-email-jlayton@redhat.com>
Date: Thu, 13 Mar 2014 16:08:01 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <35EEB018-FD2D-4C52-AA6B-24B66B11D6B6@primarydata.com>
References: <1394738651-26783-1-git-send-email-jlayton@redhat.com>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 13, 2014, at 15:24, Jeff Layton <jlayton@redhat.com> wrote:

> If a file is sillyrenamed, then the generic vfs_unlink code will skip
> emitting fsnotify events for it.
> 
> This patch has the sillyrename code do that instead.
> 
> In truth this is a little bit odd since we aren't actually removing the
> dentry per-se, but renaming it. Still, this is probably the right thing
> to do since it's what userland apps expect to see when an unlink()
> occurs or some file is renamed on top of the dentry.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfs/dir.c    | 1 +
> fs/nfs/unlink.c | 2 ++
> 2 files changed, 3 insertions(+)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 4a48fe4b84b6..591aec9b1719 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -37,6 +37,7 @@
> #include <linux/sched.h>
> #include <linux/kmemleak.h>
> #include <linux/xattr.h>
> +#include <linux/fsnotify.h>
> 
> #include "delegation.h"
> #include "iostat.h"
> diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
> index 11d78944de79..547ed0cd59db 100644
> --- a/fs/nfs/unlink.c
> +++ b/fs/nfs/unlink.c
> @@ -355,6 +355,8 @@ static void nfs_async_rename_done(struct rpc_task *task, void *calldata)
> 
> 	if (task->tk_status != 0)
> 		nfs_cancel_async_unlink(old_dentry);
> +	else if (old_dentry->d_flags & DCACHE_NFSFS_RENAMED)
> +		fsnotify_nameremove(old_dentry, S_ISDIR(old_dentry->d_inode->i_mode));
> }

Any reason why we shouldn’t just do this in nfs_sillyrename() itself?
_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

