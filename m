From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 15/29] knfsd: fix reply cache memory corruption
Date: Tue, 12 May 2009 15:55:58 -0400
Message-ID: <20090512195558.GB20719@fieldses.org>
References: <20090331202800.739621000@sgi.com> <20090331202943.252497000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:45519 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbZELTz4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 May 2009 15:55:56 -0400
In-Reply-To: <20090331202943.252497000@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 01, 2009 at 07:28:15AM +1100, Greg Banks wrote:
> Fix a regression in the reply cache introduced when the code was
> converted to use proper Linux lists.  When a new entry needs to be
> inserted, the case where all the entries are currently being used
> by threads is not correctly detected.  This can result in memory
> corruption and a crash.  In the current code this is an extremely
> unlikely corner case; it would require the machine to have 1024
> nfsd threads and all of them to be busy at the same time.  However,
> upcoming reply cache changes make this more likely; a crash due to
> this problem was actually observed in field.

OK, that does indeed sound hard to reproduce as is, but may as well
apply it for 2.6.31 now.--b.

> 
> Signed-off-by: Greg Banks <gnb@sgi.com>
> ---
> 
>  fs/nfsd/nfscache.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: bfields/fs/nfsd/nfscache.c
> ===================================================================
> --- bfields.orig/fs/nfsd/nfscache.c
> +++ bfields/fs/nfsd/nfscache.c
> @@ -177,8 +177,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
>  	}
>  	}
>  
> -	/* This should not happen */
> -	if (rp == NULL) {
> +	/* All entries on the LRU are in-progress. This should not happen */
> +	if (&rp->c_lru == &lru_head) {
>  		static int	complaints;
>  
>  		printk(KERN_WARNING "nfsd: all repcache entries locked!\n");
> 
> --
> Greg
