From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/2] NFS: prevent remounts on shared superblocks
Date: Sat, 12 Apr 2008 12:19:08 -0400
Message-ID: <1208017148.8669.39.camel@heimdal.trondhjem.org>
References: <1208010798-22782-1-git-send-email-jlayton@redhat.com>
	 <1208010798-22782-2-git-send-email-jlayton@redhat.com>
	 <20080412104250.1e574c9f@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:33150 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098AbYDLQTM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Apr 2008 12:19:12 -0400
In-Reply-To: <20080412104250.1e574c9f-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sat, 2008-04-12 at 10:42 -0400, Jeff Layton wrote:
> On Sat, 12 Apr 2008 10:33:18 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > When we're given a remount request, we likely have some mount options
> > that will be changed. If the superblock is shared, however, we can't
> > allow those new options to be applied without affecting every mount
> > that's associated with this superblock. Track the number of mounts
> > associated with the superblock, and fail any remount attempts
> > that involve a shared superblock.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/client.c           |    1 +
> >  fs/nfs/super.c            |   15 +++++++++++++--
> >  include/linux/nfs_fs_sb.h |    1 +
> >  3 files changed, 15 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > index c5c0175..950f4d2 100644
> > --- a/fs/nfs/client.c
> > +++ b/fs/nfs/client.c
> > @@ -828,6 +828,7 @@ static struct nfs_server *nfs_alloc_server(void)
> >  
> >  	init_waitqueue_head(&server->active_wq);
> >  	atomic_set(&server->active, 0);
> > +	atomic_set(&server->mounts, 0);
> >  
> >  	server->io_stats = nfs_alloc_iostats();
> >  	if (!server->io_stats) {
> > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > index b49f90f..f080f1e 100644
> > --- a/fs/nfs/super.c
> > +++ b/fs/nfs/super.c
> > @@ -592,6 +592,7 @@ static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
> >  	struct nfs_server *server = NFS_SB(vfsmnt->mnt_sb);
> >  	struct rpc_clnt *rpc;
> >  
> > +	atomic_dec(&server->mounts);

This isn't going to work at all. The fact that nfs_umount_begin() was
called does not guarantee that the umount will actually happen:
AFAICS it will suffice to call umount while some other process is still
using the mountpoint in order to corrupt your counter.

Bind mounts will also defeat this counter, since 'mount --bind' doesn't
ever call down to the filesystem other than to resolve the paths.

> Just a note that I'm not truly thrilled with this patch, but didn't see
> any other way to do this. The s_count doesn't really seem to be
> suitable for checking this since it can get incremented for other
> reasons besides sharing superblocks.
> 
> The alternative would be to walk the list of mounts in the kernel and
> count the number that use this superblock. But with different mount
> namespaces I'm not sure how to do that...

I'm not sure that it is possible to track down all the namespaces.

Cheers
  Trond

