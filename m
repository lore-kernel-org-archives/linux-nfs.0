Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f194.google.com ([209.85.160.194]:57714 "EHLO
	mail-gy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755268Ab1IMQEY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 12:04:24 -0400
Received: by gyd10 with SMTP id 10so102941gyd.1
        for <linux-nfs@vger.kernel.org>; Tue, 13 Sep 2011 09:04:23 -0700 (PDT)
Date: Tue, 13 Sep 2011 11:16:56 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v7 12/26] pnfsblock: add device operations
Message-ID: <20110913111656.61942de5@corrin.poochiereds.net>
In-Reply-To: <20110913111441.4b2502b8@corrin.poochiereds.net>
References: <1312073576-11024-1-git-send-email-rees@umich.edu>
	<1312073576-11024-13-git-send-email-rees@umich.edu>
	<20110913111441.4b2502b8@corrin.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 13 Sep 2011 11:14:41 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Sat, 30 Jul 2011 20:52:42 -0400
> Jim Rees <rees@umich.edu> wrote:
> 
> > Signed-off-by: Jim Rees <rees@umich.edu>
> > Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> > [upcall bugfixes]
> > Signed-off-by: Peng Tao <peng_tao@emc.com>
> > ---
> >  fs/nfs/blocklayout/Makefile         |    2 +-
> >  fs/nfs/blocklayout/blocklayout.c    |   42 ++++++++
> >  fs/nfs/blocklayout/blocklayout.h    |   40 +++++++
> >  fs/nfs/blocklayout/blocklayoutdev.c |  191 +++++++++++++++++++++++++++++++++++
> >  fs/nfs/client.c                     |    2 +-
> >  include/linux/nfs.h                 |    2 +
> >  6 files changed, 277 insertions(+), 2 deletions(-)
> >  create mode 100644 fs/nfs/blocklayout/blocklayoutdev.c
> > 
> 
> [...]
> > +static const struct rpc_pipe_ops bl_upcall_ops = {
> > +	.upcall		= bl_pipe_upcall,
> > +	.downcall	= bl_pipe_downcall,
> > +	.destroy_msg	= bl_pipe_destroy_msg,
> > +};
> > +
> >  static int __init nfs4blocklayout_init(void)
> >  {
> > +	struct vfsmount *mnt;
> > +	struct path path;
> >  	int ret;
> >  
> >  	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
> >  
> >  	ret = pnfs_register_layoutdriver(&blocklayout_type);
> > +	if (ret)
> > +		goto out;
> > +
> > +	init_waitqueue_head(&bl_wq);
> > +
> > +	mnt = rpc_get_mount();
> > +	if (IS_ERR(mnt)) {
> > +		ret = PTR_ERR(mnt);
> > +		goto out_remove;
> > +	}
> > +
> 
> 
> Hmm...sorry for the late review on this, but I was just looking over
> this code as an example for some other stuff I'm working on...
> 
> I notice that the above code does a rpc_get_mount to get a reference to
> the rpc_pipefs mount, but I don't see where that reference is ever put.
>

My apologies, I somehow fat-fingered the "send" key in claws...

Anyway, I think that ref should be put in any of the error cases below,
and whenever the blocklayout pipe is destroyed. 

> > +	ret = vfs_path_lookup(mnt->mnt_root,
> > +			      mnt,
> > +			      NFS_PIPE_DIRNAME, 0, &path);
> > +	if (ret)
> > +		goto out_remove;
> > +
> > +	bl_device_pipe = rpc_mkpipe(path.dentry, "blocklayout", NULL,
> > +				    &bl_upcall_ops, 0);
> 


Also, "path" is never put here either. I think that should be done
unconditionally after rpc_mkpipe is called.

> > +	if (IS_ERR(bl_device_pipe)) {
> > +		ret = PTR_ERR(bl_device_pipe);
> > +		goto out_remove;
> > +	}
> > +out:
> > +	return ret;
> > +
> > +out_remove:
> > +	pnfs_unregister_layoutdriver(&blocklayout_type);
> >  	return ret;
> >  }
> >  
> 
> 
> 


-- 
Jeff Layton <jlayton@poochiereds.net>
