Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40945 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751939Ab1HLQ0G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Aug 2011 12:26:06 -0400
Date: Fri, 12 Aug 2011 12:25:58 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Grace period NEVER ends
Message-ID: <20110812162558.GI16960@pad.fieldses.org>
References: <4E44790A.8000106@panasas.com>
 <4E447EEB.501@panasas.com>
 <4E4481F0.2050806@panasas.com>
 <1313164325.10761.5.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1313164325.10761.5.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 12, 2011 at 11:52:05AM -0400, Trond Myklebust wrote:
> On Thu, 2011-08-11 at 18:29 -0700, Boaz Harrosh wrote: 
> > With this patch I'm back to the previous behavior. That is
> > wait your grace period then continue.
> > 
> > ---
> > NFSD: Remove a wrong check in nfs4_open
> > 
> > We are already doing the proper grace period checking
> > farther down in nfs4_open. This check was just checking
> > nothing and was totally unrelated to the comment about
> > "RECLAIM_COMPLETE". It was a bug because if an open was
> > coming before the grace period end, it would then never
> > pass the condition of not being cl_firststate.
> > 
> > Boaz
> > 
> > ---
> > @@ -295,15 +295,6 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
> >  		return nfserr_inval;
> >  
> > -	/*
> > -	 * RFC5661 18.51.3
> > -	 * Before RECLAIM_COMPLETE done, server should deny new lock
> > -	 */
> > -	if (nfsd4_has_session(cstate) &&
> > -	    !cstate->session->se_client->cl_firststate &&
> > -	    open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
> > -		return nfserr_grace;
> > -
> 
> BTW: restricting opens to CLAIM_PREVIOUS only during the grace period
> seems wrong.
> 
> If I have already reclaimed my delegation, then why shouldn't I be able
> to do a CLAIM_DELEGATE_CUR and/or CLAIM_DELEG_CUR_FH open? It is not as
> if those can ever cause a lock that will conflict with some other
> client's lock reclaims.

I was assuming the client had to send a reclaim_complete before it could
do that, but... I think you're right, those must fall under the "reclaim
operations" that a client is allowed to do before the reclaim_complete.

I need to look at rfc 5661 10.2.1--I don't think we have that stuff
right at all.  Argh.

--b.
