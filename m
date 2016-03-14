Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58838 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015AbcCNSqW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2016 14:46:22 -0400
Date: Mon, 14 Mar 2016 14:46:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: recover: fix memory leak
Message-ID: <20160314184621.GA20554@fieldses.org>
References: <1457345403-7195-1-git-send-email-sudipm.mukherjee@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1457345403-7195-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 07, 2016 at 03:40:03PM +0530, Sudip Mukherjee wrote:
> nfsd4_cltrack_grace_start() will allocate the memory for grace_start but
> when we returned due to error we missed freeing it.

Thanks, applying for 4.6.--b.

> 
> Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
> ---
>  fs/nfsd/nfs4recover.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 195fe26..66eaeb1 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -1266,6 +1266,7 @@ nfsd4_umh_cltrack_init(struct net *net)
>  	/* XXX: The usermode helper s not working in container yet. */
>  	if (net != &init_net) {
>  		pr_warn("NFSD: attempt to initialize umh client tracking in a container ignored.\n");
> +		kfree(grace_start);
>  		return -EINVAL;
>  	}
>  
> -- 
> 1.9.1
