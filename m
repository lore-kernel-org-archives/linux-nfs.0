Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11869 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754346Ab1IMPL0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 11:11:26 -0400
Date: Tue, 13 Sep 2011 11:14:41 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v7 12/26] pnfsblock: add device operations
Message-ID: <20110913111441.4b2502b8@corrin.poochiereds.net>
In-Reply-To: <1312073576-11024-13-git-send-email-rees@umich.edu>
References: <1312073576-11024-1-git-send-email-rees@umich.edu>
	<1312073576-11024-13-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 30 Jul 2011 20:52:42 -0400
Jim Rees <rees@umich.edu> wrote:

> Signed-off-by: Jim Rees <rees@umich.edu>
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> [upcall bugfixes]
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> ---
>  fs/nfs/blocklayout/Makefile         |    2 +-
>  fs/nfs/blocklayout/blocklayout.c    |   42 ++++++++
>  fs/nfs/blocklayout/blocklayout.h    |   40 +++++++
>  fs/nfs/blocklayout/blocklayoutdev.c |  191 +++++++++++++++++++++++++++++++++++
>  fs/nfs/client.c                     |    2 +-
>  include/linux/nfs.h                 |    2 +
>  6 files changed, 277 insertions(+), 2 deletions(-)
>  create mode 100644 fs/nfs/blocklayout/blocklayoutdev.c
> 

[...]
> +static const struct rpc_pipe_ops bl_upcall_ops = {
> +	.upcall		= bl_pipe_upcall,
> +	.downcall	= bl_pipe_downcall,
> +	.destroy_msg	= bl_pipe_destroy_msg,
> +};
> +
>  static int __init nfs4blocklayout_init(void)
>  {
> +	struct vfsmount *mnt;
> +	struct path path;
>  	int ret;
>  
>  	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
>  
>  	ret = pnfs_register_layoutdriver(&blocklayout_type);
> +	if (ret)
> +		goto out;
> +
> +	init_waitqueue_head(&bl_wq);
> +
> +	mnt = rpc_get_mount();
> +	if (IS_ERR(mnt)) {
> +		ret = PTR_ERR(mnt);
> +		goto out_remove;
> +	}
> +


Hmm...sorry for the late review on this, but I was just looking over
this code as an example for some other stuff I'm working on...

I notice that the above code does a rpc_get_mount to get a reference to
the rpc_pipefs mount, but I don't see where that reference is ever put.

> +	ret = vfs_path_lookup(mnt->mnt_root,
> +			      mnt,
> +			      NFS_PIPE_DIRNAME, 0, &path);
> +	if (ret)
> +		goto out_remove;
> +
> +	bl_device_pipe = rpc_mkpipe(path.dentry, "blocklayout", NULL,
> +				    &bl_upcall_ops, 0);

> +	if (IS_ERR(bl_device_pipe)) {
> +		ret = PTR_ERR(bl_device_pipe);
> +		goto out_remove;
> +	}
> +out:
> +	return ret;
> +
> +out_remove:
> +	pnfs_unregister_layoutdriver(&blocklayout_type);
>  	return ret;
>  }
>  



-- 
Jeff Layton <jlayton@redhat.com>
