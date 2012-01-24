Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f174.google.com ([209.85.212.174]:62168 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754924Ab2AXOGi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2012 09:06:38 -0500
Received: by wics10 with SMTP id s10so2967998wic.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2012 06:06:36 -0800 (PST)
Message-ID: <4F1EBAE9.6040707@tonian.com>
Date: Tue, 24 Jan 2012 16:06:33 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Tigran Mkrtchyan <kofemann@googlemail.com>, bfields@fieldses.org
CC: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v7 10/10] nfsd41: use current stateid by value
References: <1327357415-30099-1-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1327357415-30099-1-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-01-24 00:23, Tigran Mkrtchyan wrote:
> From: Tigran Mkrtchyan <kofemann@gmail.com>
> 
> 
> Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
> ---
>  fs/nfsd/current_stateid.h |    1 +
>  fs/nfsd/nfs4proc.c        |   12 +++++++++---
>  fs/nfsd/nfs4state.c       |   19 +++++++++++++++----
>  fs/nfsd/xdr4.h            |    6 ++++--
>  4 files changed, 29 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
> index d8c9992..4123551 100644
> --- a/fs/nfsd/current_stateid.h
> +++ b/fs/nfsd/current_stateid.h
> @@ -4,6 +4,7 @@
>  #include "state.h"
>  #include "xdr4.h"
>  
> +extern void clear_current_stateid(struct nfsd4_compound_state *cstate);
>  /*
>   * functions to set current state id
>   */
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index dffc9bd..56c1977 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -453,7 +453,10 @@ nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		return nfserr_restorefh;
>  
>  	fh_dup2(&cstate->current_fh, &cstate->save_fh);
> -	cstate->current_stateid = cstate->save_stateid;
> +	if (cstate->has_ssid) {
> +		memcpy(&cstate->current_stateid, &cstate->save_stateid, sizeof(stateid_t));
> +		cstate->has_csid = true;
> +	}
>  	return nfs_ok;
>  }
>  
> @@ -465,7 +468,10 @@ nfsd4_savefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		return nfserr_nofilehandle;
>  
>  	fh_dup2(&cstate->save_fh, &cstate->current_fh);
> -	cstate->save_stateid = cstate->current_stateid;
> +	if (cstate->has_csid) {
> +		memcpy(&cstate->save_stateid, &cstate->current_stateid, sizeof(stateid_t));
> +		cstate->has_ssid = true;
> +	}
>  	return nfs_ok;
>  }
>  
> @@ -1238,7 +1244,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  				opdesc->op_set_currentstateid(cstate, &op->u);
>  
>  			if (opdesc->op_flags & OP_CLEAR_STATEID)
> -				cstate->current_stateid = NULL;
> +				clear_current_stateid(cstate);
>  
>  			if (need_wrongsec_check(rqstp))
>  				op->status = check_nfsd_access(cstate->current_fh.fh_export, rqstp);
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 9c5a239..c6d2980 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4699,15 +4699,26 @@ nfs4_state_shutdown(void)
>  static void
>  get_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
>  {
> -	if (cstate->current_stateid && CURRENT_STATEID(stateid))
> -		memcpy(stateid, cstate->current_stateid, sizeof(stateid_t));
> +	if (cstate->has_csid && CURRENT_STATEID(stateid))
> +		memcpy(stateid, &cstate->current_stateid, sizeof(stateid_t));
>  }
>  
>  static void
>  put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
>  {
> -	if (cstate->minorversion)
> -		cstate->current_stateid = stateid;
> +	if (cstate->minorversion) {
> +		memcpy(&cstate->current_stateid, stateid, sizeof(stateid_t));
> +		cstate->has_csid = true;
> +	}
> +}
> +
> +void
> +clear_current_stateid(struct nfsd4_compound_state *cstate)
> +{
> +	if (cstate->has_csid) {
> +		memcpy(&cstate->current_stateid, &zero_stateid, sizeof(stateid_t));

This shouldn't be needed as long as has_csid is set to false, right?

> +		cstate->has_csid = false;
> +	}
>  }
>  
>  /*
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 2ae378e..3692ba8 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -54,8 +54,10 @@ struct nfsd4_compound_state {
>  	size_t			iovlen;
>  	u32			minorversion;
>  	u32			status;
> -	const stateid_t	*current_stateid;
> -	const stateid_t	*save_stateid;
> +	stateid_t	current_stateid;
> +	bool			has_csid; /* true if compound has current state id */
> +	stateid_t	save_stateid;
> +	bool 			has_ssid; /* true if compound has saved state id */

This is a pretty big overhead for the status bits.
I'm not sure what Bruce's stand but using single-bit bit fields or
flags would be more space efficient...

Benny

>  };
>  
>  static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
