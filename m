Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:62550 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751319Ab3HTRWS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Aug 2013 13:22:18 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Remove the NFSv4 "open optimisation" from
 nfs_permission
Date: Tue, 20 Aug 2013 17:22:16 +0000
Message-ID: <9146DF7D-CBC0-4B28-9F60-DF448AD7BF1A@netapp.com>
References: <1377018821-18925-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377018821-18925-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good catch!

-dros

On Aug 20, 2013, at 1:13 PM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> Ever since commit 6168f62cb (Add ACCESS operation to OPEN compound)
> the NFSv4 atomic open has primed the access cache, and so nfs_permission
> will no longer do an RPC call on the wire.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/dir.c | 5 -----
> 1 file changed, 5 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 39e69d4..5d737bd 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -2245,11 +2245,6 @@ int nfs_permission(struct inode *inode, int mask)
> 		case S_IFLNK:
> 			goto out;
> 		case S_IFREG:
> -			/* NFSv4 has atomic_open... */
> -			if (nfs_server_capable(inode, NFS_CAP_ATOMIC_OPEN)
> -					&& (mask & MAY_OPEN)
> -					&& !(mask & MAY_EXEC))
> -				goto out;
> 			break;
> 		case S_IFDIR:
> 			/*
> -- 
> 1.8.3.1
> 

