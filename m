Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652AbaCMVVX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2014 17:21:23 -0400
Date: Thu, 13 Mar 2014 17:21:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: emit a fsnotify_nameremove call in sillyrename
 codepath
Message-ID: <20140313172119.232397a5@tlielax.poochiereds.net>
In-Reply-To: <96492A5A-C738-4E20-88B9-D01995217981@primarydata.com>
References: <1394738651-26783-1-git-send-email-jlayton@redhat.com>
	<35EEB018-FD2D-4C52-AA6B-24B66B11D6B6@primarydata.com>
	<20140313162218.570e0819@tlielax.poochiereds.net>
	<96492A5A-C738-4E20-88B9-D01995217981@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 13 Mar 2014 16:47:49 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Mar 13, 2014, at 16:22, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Thu, 13 Mar 2014 16:08:01 -0400
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > 
> >> 
> >> On Mar 13, 2014, at 15:24, Jeff Layton <jlayton@redhat.com> wrote:
> >> 
> >>> If a file is sillyrenamed, then the generic vfs_unlink code will skip
> >>> emitting fsnotify events for it.
> >>> 
> >>> This patch has the sillyrename code do that instead.
> >>> 
> >>> In truth this is a little bit odd since we aren't actually removing the
> >>> dentry per-se, but renaming it. Still, this is probably the right thing
> >>> to do since it's what userland apps expect to see when an unlink()
> >>> occurs or some file is renamed on top of the dentry.
> >>> 
> >>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> >>> ---
> >>> fs/nfs/dir.c    | 1 +
> >>> fs/nfs/unlink.c | 2 ++
> >>> 2 files changed, 3 insertions(+)
> >>> 
> >>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> >>> index 4a48fe4b84b6..591aec9b1719 100644
> >>> --- a/fs/nfs/dir.c
> >>> +++ b/fs/nfs/dir.c
> >>> @@ -37,6 +37,7 @@
> >>> #include <linux/sched.h>
> >>> #include <linux/kmemleak.h>
> >>> #include <linux/xattr.h>
> >>> +#include <linux/fsnotify.h>
> >>> 
> >>> #include "delegation.h"
> >>> #include "iostat.h"
> >>> diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
> >>> index 11d78944de79..547ed0cd59db 100644
> >>> --- a/fs/nfs/unlink.c
> >>> +++ b/fs/nfs/unlink.c
> >>> @@ -355,6 +355,8 @@ static void nfs_async_rename_done(struct rpc_task *task, void *calldata)
> >>> 
> >>> 	if (task->tk_status != 0)
> >>> 		nfs_cancel_async_unlink(old_dentry);
> >>> +	else if (old_dentry->d_flags & DCACHE_NFSFS_RENAMED)
> >>> +		fsnotify_nameremove(old_dentry, S_ISDIR(old_dentry->d_inode->i_mode));
> >>> }
> >> 
> >> Any reason why we shouldn’t just do this in nfs_sillyrename() itself?
> >> 
> > 
> > We certainly could, but then you'd probably never get the event if the
> > process waiting on the async sillyrename got killed while waiting on
> > the reply.
> 
> Just send it anyway. The dentry will have been scheduled to be unlinked no matter whether or not the process is killed.
> 

Hrm, I dunno...

If we do that then we may end up sending the event before it has
actually occurred. I'm not sure if that's a problem or not, but it
seems iffy.

I don't get it though -- why not do this in the rpc_call_done handler?
If we do it there then we know we'll only send the event if the rename
succeeded.

-- 
Jeff Layton <jlayton@redhat.com>
