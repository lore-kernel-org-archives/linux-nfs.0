Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51327 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751591AbaC2Te5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 29 Mar 2014 15:34:57 -0400
Date: Sat, 29 Mar 2014 15:34:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Idan Kedar <idank@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: Don't return NFS4ERR_RESTOREFH for NFSv4.1+
Message-ID: <20140329193456.GE11085@fieldses.org>
References: <1396118619-12771-1-git-send-email-trond.myklebust@primarydata.com>
 <1396118619-12771-2-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1396118619-12771-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 29, 2014 at 02:43:39PM -0400, Trond Myklebust wrote:
> RFC5661 obsoletes NFS4ERR_RESTOREFH in favour of NFS4ERR_NOFILEHANDLE.

Looks right.  Any objection to just making this nfserr_restorefh in the
4.0 case as well?  Hard to imagine how that could cause a 4.0 client any
problem.

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4proc.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 82189b208af3..eeee4418d44a 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -536,8 +536,11 @@ static __be32
>  nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		void *arg)
>  {
> -	if (!cstate->save_fh.fh_dentry)
> +	if (!cstate->save_fh.fh_dentry) {
> +		if (nfsd4_has_session(cstate))
> +			return nfserr_nofilehandle;
>  		return nfserr_restorefh;
> +	}
>  
>  	fh_dup2(&cstate->current_fh, &cstate->save_fh);
>  	if (HAS_STATE_ID(cstate, SAVED_STATE_ID_FLAG)) {
> -- 
> 1.9.0
> 
