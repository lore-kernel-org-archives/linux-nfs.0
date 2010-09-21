From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/6] nfsd: disable deferral for NFSv4
Date: Tue, 21 Sep 2010 17:01:24 -0400
Message-ID: <20100921210124.GD10570@fieldses.org>
References: <20100812065722.11459.18978.stgit@localhost.localdomain>
 <20100812070407.11459.2929.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35451 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754626Ab0IUVCv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 17:02:51 -0400
In-Reply-To: <20100812070407.11459.2929.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 12, 2010 at 05:04:07PM +1000, NeilBrown wrote:
> Now that a slight delay in getting a reply to an upcall doesn't
> require deferring of requests, request deferral for all NFSv4
> requests - the concept doesn't really fit with the v4 model.

Applied with a minor comment fix.

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  fs/nfsd/nfs4proc.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 59ec449..fca3621 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1031,8 +1031,8 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  	resp->cstate.session = NULL;
>  	fh_init(&resp->cstate.current_fh, NFS4_FHSIZE);
>  	fh_init(&resp->cstate.save_fh, NFS4_FHSIZE);
> -	/* Use the deferral mechanism only for NFSv4.0 compounds */
> -	rqstp->rq_usedeferral = (args->minorversion == 0);
> +	/* Don't use the deferral mechanism NFSv4. */
> +	rqstp->rq_usedeferral = 0;
>  
>  	/*
>  	 * According to RFC3010, this takes precedence over all other errors.
> 
> 
