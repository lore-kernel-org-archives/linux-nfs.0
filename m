Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34989 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755543Ab0LEMu4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Dec 2010 07:50:56 -0500
Date: Sun, 5 Dec 2010 07:50:46 -0500
From: Jeff Layton <jlayton@redhat.com>
To: arun@linux.vnet.ibm.com
Cc: linux-nfs@vger.kernel.org, ffilz@us.ibm.com
Subject: Re: [PATCH][BUG]: Pure nfs client performance using odirect.
Message-ID: <20101205075046.18e37436@tlielax.poochiereds.net>
In-Reply-To: <20101118103643.GA13235@linux.vnet.ibm.com>
References: <20101118103643.GA13235@linux.vnet.ibm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 18 Nov 2010 16:06:43 +0530
Arun R Bharadwaj <arun@linux.vnet.ibm.com> wrote:

> Pure nfs client performance using odirect.
> 
> When an application opens a file with O_DIRECT flag, if the size of
> the data that is written is equal to wsize, the client sends a
> WRITE RPC with stable flag set to UNSTABLE followed by a single
> COMMIT RPC rather than sending a single WRITE RPC with the stable
> flag set to FILE_SYNC. This a bug.
> 
> Patch to fix this.
> 
> Signed-off-by: Arun R Bharadwaj <arun@linux.vnet.ibm.com>
> 
> Index: linux-2.6.36-rc7/fs/nfs/direct.c
> ===================================================================
> --- linux-2.6.36-rc7.orig/fs/nfs/direct.c	2010-11-18 15:53:15.904972002 +0530
> +++ linux-2.6.36-rc7/fs/nfs/direct.c	2010-11-18 15:54:01.184972001 +0530
> @@ -867,7 +867,7 @@
>  		goto out;
>  	nfs_alloc_commit_data(dreq);
>  
> -	if (dreq->commit_data == NULL || count < wsize)
> +	if (dreq->commit_data == NULL || count <= wsize)
>  		sync = NFS_FILE_SYNC;
>  
>  	dreq->inode = inode;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Looks right to me.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
