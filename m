Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52933 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005AbaEGT6Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 May 2014 15:58:24 -0400
Date: Wed, 7 May 2014 15:58:23 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 37/70] NFSd: nfs4_preprocess_seqid_op should only set
 *stpp on success
Message-ID: <20140507195823.GA9710@fieldses.org>
References: <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-38-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-38-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Patch-sequencing nit: I'm guessing this wasn't actually a problem until
previous patches added sequenceid reference counting, turning this case
into a reference leak.

Therefore to avoid a temporary regression we should probably make this
change before introducing the reference counting rather than after.

--b.

On Fri, Apr 18, 2014 at 02:44:31PM -0400, Trond Myklebust wrote:
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index b9d6da652fb1..03a3f51d2828 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4068,6 +4068,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
>  {
>  	__be32 status;
>  	struct nfs4_stid *s;
> +	struct nfs4_ol_stateid *stp = NULL;
>  
>  	dprintk("NFSD: %s: seqid=%d stateid = " STATEID_FMT "\n", __func__,
>  		seqid, STATEID_VAL(stateid));
> @@ -4077,10 +4078,13 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
>  				      cstate->minorversion, nn);
>  	if (status)
>  		return status;
> -	*stpp = openlockstateid(s);
> -	nfsd4_cstate_assign_replay(cstate, (*stpp)->st_stateowner);
> +	stp = openlockstateid(s);
> +	nfsd4_cstate_assign_replay(cstate, stp->st_stateowner);
>  
> -	return nfs4_seqid_op_checks(cstate, stateid, seqid, *stpp);
> +	status = nfs4_seqid_op_checks(cstate, stateid, seqid, stp);
> +	if (!status)
> +		*stpp = stp;
> +	return status;
>  }
>  
>  static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
> -- 
> 1.9.0
> 
