From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 07/44] nfsd41: create_session check replay first
Date: Tue, 16 Jun 2009 16:47:34 -0400
Message-ID: <20090616204734.GE3045@fieldses.org>
References: <1245115172-7030-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org, andros@netapp.com
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:39565 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085AbZFPUrf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2009 16:47:35 -0400
In-Reply-To: <1245115172-7030-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 04:19:32AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Replay processing needs to preceed other error processing.

Why?

--b.

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index bfc808b..5aef525 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1378,12 +1378,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  		}
>  		conf->cl_slot.sl_seqid++;
>  	} else if (unconf) {
> -		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
> -		    (ip_addr != unconf->cl_addr)) {
> -			status = nfserr_clid_inuse;
> -			goto out_cache;
> -		}
> -
>  		slot = &unconf->cl_slot;
>  		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid, 0);
>  		if (status) {
> @@ -1392,6 +1386,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  			goto out;
>  		}
>  
> +		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
> +		    (ip_addr != unconf->cl_addr)) {
> +			status = nfserr_clid_inuse;
> +			goto out_cache;
> +		}
> +
>  		slot->sl_seqid++; /* from 0 to 1 */
>  		move_to_confirmed(unconf);
>  
> -- 
> 1.6.3
> 
