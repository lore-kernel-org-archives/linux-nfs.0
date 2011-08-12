Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65241 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269Ab1HLPwX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Aug 2011 11:52:23 -0400
Subject: Re: Grace period NEVER ends
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Date: Fri, 12 Aug 2011 11:52:05 -0400
In-Reply-To: <4E4481F0.2050806@panasas.com>
References: <4E44790A.8000106@panasas.com> <4E447EEB.501@panasas.com>
	 <4E4481F0.2050806@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1313164325.10761.5.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-08-11 at 18:29 -0700, Boaz Harrosh wrote: 
> With this patch I'm back to the previous behavior. That is
> wait your grace period then continue.
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

BTW: restricting opens to CLAIM_PREVIOUS only during the grace period
seems wrong.

If I have already reclaimed my delegation, then why shouldn't I be able
to do a CLAIM_DELEGATE_CUR and/or CLAIM_DELEG_CUR_FH open? It is not as
if those can ever cause a lock that will conflict with some other
client's lock reclaims.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

