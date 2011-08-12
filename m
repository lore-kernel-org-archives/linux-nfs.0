Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34440 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845Ab1HLCQA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Aug 2011 22:16:00 -0400
Date: Thu, 11 Aug 2011 22:15:57 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Grace period NEVER ends
Message-ID: <20110812021556.GD9761@pad.fieldses.org>
References: <4E44790A.8000106@panasas.com>
 <4E447EEB.501@panasas.com>
 <4E4481F0.2050806@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E4481F0.2050806@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 11, 2011 at 06:29:20PM -0700, Boaz Harrosh wrote:
> With this patch I'm back to the previous behavior. That is
> wait your grace period then continue.

Is it true for some reason that the client never sends RECLAIM_COMPLETE?

--b.

> 
> ---
> NFSD: Remove a wrong check in nfs4_open
> 
> We are already doing the proper grace period checking
> farther down in nfs4_open. This check was just checking
> nothing and was totally unrelated to the comment about
> "RECLAIM_COMPLETE". It was a bug because if an open was
> coming before the grace period end, it would then never
> pass the condition of not being cl_firststate.
> 
> Boaz
> 
> ---
> @@ -295,15 +295,6 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
>  		return nfserr_inval;
>  
> -	/*
> -	 * RFC5661 18.51.3
> -	 * Before RECLAIM_COMPLETE done, server should deny new lock
> -	 */
> -	if (nfsd4_has_session(cstate) &&
> -	    !cstate->session->se_client->cl_firststate &&
> -	    open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
> -		return nfserr_grace;
> -
>  	if (nfsd4_has_session(cstate))
>  		copy_clientid(&open->op_clientid, cstate->session);
>  
> 
