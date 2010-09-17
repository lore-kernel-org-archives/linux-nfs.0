Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36631 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752771Ab0IQVom convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 17:44:42 -0400
Subject: Re: [PATCH 0/6] Replace NFSROOT mount option parsing
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100910200001.13167.61153.stgit@seurat.1015granger.net>
References: <20100910200001.13167.61153.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 17 Sep 2010 17:44:10 -0400
Message-ID: <1284759850.16091.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-09-10 at 16:03 -0400, Chuck Lever wrote:
> Trond-
> 
> For 2.6.37, it would be nice to eliminate the redundant mount option
> parsing logic in fs/nfs/nfsroot.c.  Merged up to 2.6.36-rc, and
> compile-tested.
> 
> We had discussed, as a first step, merging these into linux-next.
> I unit-tested these on late 2.6.34-rc kernels, so there might be an
> additional detail or two to clean up.
> 
> ---
> 
> Chuck Lever (6):
>       SUNRPC: Remove rpcb_getport_sync()
>       NFS: Allow NFSROOT debugging messages to be enabled dynamically
>       NFS: Clean up nfsroot.c
>       NFS: Use super.c for NFSROOT mount option parsing
>       NFS: Clean up NFSROOT command line parsing
>       NFS: Remove \t from mount debugging message
> 
> 
>  Documentation/filesystems/nfs/nfsroot.txt |   22 +
>  Documentation/kernel-parameters.txt       |    5 
>  fs/nfs/mount_clnt.c                       |    2 
>  fs/nfs/nfsroot.c                          |  566 +++++++++--------------------
>  include/linux/nfs_fs.h                    |   10 -
>  include/linux/sunrpc/clnt.h               |    1 
>  init/do_mounts.c                          |   12 -
>  net/sunrpc/rpcb_clnt.c                    |   51 ---
>  8 files changed, 208 insertions(+), 461 deletions(-)
> 

Thanks! Queued up in the nfs-for-2.6.37 branch...

Cheers
  Trond
