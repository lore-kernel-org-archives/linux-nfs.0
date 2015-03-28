Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36851 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376AbbC1Nuz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2015 09:50:55 -0400
Received: by padcy3 with SMTP id cy3so122377625pad.3
        for <linux-nfs@vger.kernel.org>; Sat, 28 Mar 2015 06:50:55 -0700 (PDT)
Message-ID: <5516B1B7.6020700@gmail.com>
Date: Sat, 28 Mar 2015 21:50:47 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv4: Return delegations synchronously in evict_inode
References: <1427475157-13904-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1427475157-13904-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2015/3/28 0:52, Trond Myklebust wrote:
> Kinglong Mee reports that asynchronous delegations are being killed
> by the call to rpc_shutdown_client() when unmounting. This can lead
> to state leakage on the server until the client lease expires.
> 
> Reported-by: Kinglong Mee <kinglongmee@gmail.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

With this patch, client can return delegation, destroy session and 
client id correctly. I'd like it.

Tested-by: Kinglong Mee <kinglongmee@gmail.com>

thanks,
Kinglong Mee

> ---
>  fs/nfs/delegation.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index a6ad68865880..08c624448750 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -514,7 +514,7 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
>  
>  	delegation = nfs_inode_detach_delegation(inode);
>  	if (delegation != NULL)
> -		nfs_do_return_delegation(inode, delegation, 0);
> +		nfs_do_return_delegation(inode, delegation, 1);
>  }
>  
>  /**
> 
