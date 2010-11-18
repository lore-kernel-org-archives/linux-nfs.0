Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:45134 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758853Ab0KRPxQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 10:53:16 -0500
Subject: Re: [PATCH][BUG]: Pure nfs client performance using odirect.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101118103643.GA13235@linux.vnet.ibm.com>
Date: Thu, 18 Nov 2010 10:52:35 -0500
Cc: linux-nfs@vger.kernel.org, ffilz@us.ibm.com, jlayton@redhat.com
Message-Id: <3A90B9B1-69D0-43A4-8F2F-5358B8A39406@oracle.com>
References: <20101118103643.GA13235@linux.vnet.ibm.com>
To: arun@linux.vnet.ibm.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Nov 18, 2010, at 5:36 AM, Arun R Bharadwaj wrote:

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
> 		goto out;
> 	nfs_alloc_commit_data(dreq);
> 
> -	if (dreq->commit_data == NULL || count < wsize)
> +	if (dreq->commit_data == NULL || count <= wsize)
> 		sync = NFS_FILE_SYNC;
> 
> 	dreq->inode = inode;

This looks reasonable, though I haven't looked closely at the surrounding code.  It's probably been in the code for a very long time.  I'm surprised no-one caught it sooner.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




