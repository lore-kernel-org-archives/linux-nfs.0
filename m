Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50954 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753Ab1IRE1N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Sep 2011 00:27:13 -0400
Received: by bkbzt4 with SMTP id zt4so4484371bkb.19
        for <linux-nfs@vger.kernel.org>; Sat, 17 Sep 2011 21:27:11 -0700 (PDT)
Message-ID: <4E707FC1.2020607@tonian.com>
Date: Wed, 14 Sep 2011 12:19:45 +0200
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>, Peng Tao <bergwolf@gmail.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] pnfsblock: add missing rpc_put_mount and path_put
References: <1315945452-1575-1-git-send-email-rees@umich.edu>
In-Reply-To: <1315945452-1575-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We need to decide on a process here :)
If we would like to maintain a staging tree in front of Trond's
then to simplify merging and rebasing, fixes to code that's already
upstream, i.e. in linux-2.6 or already queued in nfs-2.6, that we decide
to send to Trond ahead of queue need to be queued in front of stuff in
the staging tree and the latter should be rebased on top of them.

Benny

On 2011-09-13 22:24, Jim Rees wrote:
> From: Peng Tao <bergwolf@gmail.com>
> 
> Reported-by: Jeff Layton <jlayton@redhat.com>
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  fs/nfs/blocklayout/blocklayout.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 9675ef9..8f97578 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -1009,17 +1009,20 @@ static int __init nfs4blocklayout_init(void)
>  			      mnt,
>  			      NFS_PIPE_DIRNAME, 0, &path);
>  	if (ret)
> -		goto out_remove;
> +		goto out_putrpc;
>  
>  	bl_device_pipe = rpc_mkpipe(path.dentry, "blocklayout", NULL,
>  				    &bl_upcall_ops, 0);
> +	path_put(&path);
>  	if (IS_ERR(bl_device_pipe)) {
>  		ret = PTR_ERR(bl_device_pipe);
> -		goto out_remove;
> +		goto out_putrpc;
>  	}
>  out:
>  	return ret;
>  
> +out_putrpc:
> +	rpc_put_mount();
>  out_remove:
>  	pnfs_unregister_layoutdriver(&blocklayout_type);
>  out_stop:
> @@ -1035,6 +1038,7 @@ static void __exit nfs4blocklayout_exit(void)
>  	pnfs_unregister_layoutdriver(&blocklayout_type);
>  	pnfsiod_stop();
>  	rpc_unlink(bl_device_pipe);
> +	rpc_put_mount();
>  }
>  
>  MODULE_ALIAS("nfs-layouttype4-3");
