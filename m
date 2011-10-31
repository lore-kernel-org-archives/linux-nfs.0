Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13418 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933499Ab1JaRn4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 13:43:56 -0400
Subject: Re: [PATCH] nfs: Fix unused variable warning.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Rakib Mullick <rakib.mullick@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        akpm@linux-foundation.org
Date: Mon, 31 Oct 2011 13:43:54 -0400
In-Reply-To: <CADZ9YHhq91+Td03OjWbX0rwHwb6Y7QhicsuDqqAUSy2O8=05BA@mail.gmail.com>
References: <1319798192.26450.1.camel@localhost.localdomain>
	 <1320074323.4714.2.camel@lade.trondhjem.org>
	 <CADZ9YHhq91+Td03OjWbX0rwHwb6Y7QhicsuDqqAUSy2O8=05BA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320083034.4714.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-31 at 23:12 +0600, Rakib Mullick wrote: 
> On Mon, Oct 31, 2011 at 9:18 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Fri, 2011-10-28 at 16:36 +0600, Rakib Mullick wrote:
> >
> > This will still cause a warning if you compile without RPC_DEBUG (e.g.
> > if CONFIG_SYSCTL isn't defined).
> >
> I didn't get any warning with CONFIG_SYSCTL=n.
> 
> > Since there is only one user, it seems better to just open-code the
> > NFS_SERVER(data->inode) in the dprintk()...
> 
> Okay, it seems reasonable. We can simply remove 'server'. Please
> consider the following patch (also attached, might have some white
> space issue).
> 
> ---
> 
>  When CONFIG_NFS=y and CONFIG_NFS_V3_{,V4}=n we get the following warning.
> 	
> 	fs/nfs/write.c: In function ‘nfs_writeback_done’:
> 	fs/nfs/write.c:1246:21: warning: unused variable ‘server’
> 
>  Remove the variable 'server' to fix the above warning.
> 
> Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
> ---
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 2219c88..a2e4b27 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1243,7 +1243,6 @@ void nfs_writeback_done(struct rpc_task *task,
> struct nfs_write_data *data)
>  {
>  	struct nfs_writeargs	*argp = &data->args;
>  	struct nfs_writeres	*resp = &data->res;
> -	struct nfs_server	*server = NFS_SERVER(data->inode);
>  	int status;
> 
>  	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
> @@ -1277,7 +1276,7 @@ void nfs_writeback_done(struct rpc_task *task,
> struct nfs_write_data *data)
>  		if (time_before(complain, jiffies)) {
>  			dprintk("NFS:       faulty NFS server %s:"
>  				" (committed = %d) != (stable = %d)\n",
> -				server->nfs_client->cl_hostname,
> +				data->inode->nfs_client->cl_hostname,
				 ^^^^^^^^^^^^
NFS_SERVER(data->inode)->nfs_client....

> 				resp->verf->committed, argp->stable);
>  			complain = jiffies + 300 * HZ;
>  		}

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

