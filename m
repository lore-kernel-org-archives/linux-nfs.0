Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62826 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933175Ab1JaPS7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 11:18:59 -0400
Subject: Re: [PATCH] nfs: Fix unused variable warning.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Rakib Mullick <rakib.mullick@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        akpm@linux-foundation.org
Date: Mon, 31 Oct 2011 11:18:43 -0400
In-Reply-To: <1319798192.26450.1.camel@localhost.localdomain>
References: <1319798192.26450.1.camel@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320074323.4714.2.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-10-28 at 16:36 +0600, Rakib Mullick wrote: 
> When CONFIG_NFS=y, but CONFIG_NFS_V3_{,V4}=n we get the following warning:
> 
> 	fs/nfs/write.c: In function ‘nfs_writeback_done’:
> 	fs/nfs/write.c:1246:21: warning: unused variable ‘server’
> 
>  This patch fixes it.
> 
> Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
> ---
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 2219c88..e528e5c 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1243,7 +1243,6 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
>  {
>  	struct nfs_writeargs	*argp = &data->args;
>  	struct nfs_writeres	*resp = &data->res;
> -	struct nfs_server	*server = NFS_SERVER(data->inode);
>  	int status;
>  
>  	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
> @@ -1272,6 +1271,8 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
>  		 *	 as a dprintk() in order to avoid filling syslog.
>  		 */
>  		static unsigned long    complain;
> +		struct nfs_server	*server;
> +		server = NFS_SERVER(data->inode);
>  
>  		/* Note this will print the MDS for a DS write */
>  		if (time_before(complain, jiffies)) {

This will still cause a warning if you compile without RPC_DEBUG (e.g.
if CONFIG_SYSCTL isn't defined).

Since there is only one user, it seems better to just open-code the
NFS_SERVER(data->inode) in the dprintk()...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

