From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Use GFP_NOFS in nfs_direct_req_alloc
Date: Tue, 08 Sep 2009 18:32:58 -0400
Message-ID: <1252449178.8099.64.camel@heimdal.trondhjem.org>
References: <20090908220230.7590.69833.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819AbZIHWd3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2009 18:33:29 -0400
In-Reply-To: <20090908220230.7590.69833.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-09-08 at 18:05 -0400, Chuck Lever wrote:
> Don't dive into memory reclaim in the NFS direct I/O paths, otherwise
> we can deadlock.
> 
> Reported by: Wengang Wang <wen.gang.wang@oracle.com>
> Fix-suggested-by: Zach Brown <zach.brown@oracle.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Wait... What??? How does an O_DIRECT read or write allocation deadlock
with memory reclaim? Both the read and the write path call
nfs_direct_req_alloc() before they pin any user pages in memory.

Trond

> ---
> 
> Trond-
> 
> Thoughts?
> 
>  fs/nfs/direct.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index e4e089a..00f06b8 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -149,7 +149,7 @@ static inline struct nfs_direct_req *nfs_direct_req_alloc(void)
>  {
>  	struct nfs_direct_req *dreq;
>  
> -	dreq = kmem_cache_alloc(nfs_direct_cachep, GFP_KERNEL);
> +	dreq = kmem_cache_alloc(nfs_direct_cachep, GFP_NOFS);
>  	if (!dreq)
>  		return NULL;
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
