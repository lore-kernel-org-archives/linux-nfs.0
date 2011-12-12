Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43953 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227Ab1LLToN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 14:44:13 -0500
Received: by eekc4 with SMTP id c4so1785048eek.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 11:44:12 -0800 (PST)
Message-ID: <4EE62402.6050008@tonian.com>
Date: Mon, 12 Dec 2011 17:55:46 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Tigran Mkrtchyan <kofemann@googlemail.com>
CC: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v3 5/5] nfsd41: use pinter to current stateid to avoid
 extra copy
References: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de> <1323621708-25138-6-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323621708-25138-6-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-11 18:41, Tigran Mkrtchyan wrote:
> From: Tigran Mkrtchyan <kofemann@gmail.com>
> 
> 
> Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
> ---
>  fs/nfsd/nfs4proc.c  |    6 +-----
>  fs/nfsd/nfs4state.c |    7 +++----
>  fs/nfsd/xdr4.h      |    3 +--
>  3 files changed, 5 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index f2f7dfa..b7d1a7b 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1126,10 +1126,7 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
>  static void
>  nfsd4_clear_currentstateid(struct nfsd4_compound_state *cstate)
>  {
> -	if (cstate->has_stateid) {
> -		memset(&cstate->current_stateid, 0, sizeof(stateid_t));
> -		cstate->has_stateid = false;
> -	}
> +	cstate->current_stateid = NULL;
>  }
>  /*
>   * COMPOUND call.
> @@ -1244,7 +1241,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  		if (!op->status) {
>  			if (opdesc->op_flags & PROVIDES_CURRENT_STATEID) {
>  				opdesc->op_set_currentstateid(cstate, &op->u);
> -				cstate->has_stateid = true;
>  			}
>  
>  			if (opdesc->op_flags & CLEARS_CURRENT_STATEID)
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index d7b8f25..be77cd3 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4553,16 +4553,15 @@ nfs4_state_shutdown(void)
>  static void
>  get_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
>  {
> -	if (cstate->has_stateid && CURRENT_STATEID(stateid))
> -		memcpy(stateid, &cstate->current_stateid, sizeof(stateid_t));
> +	if (cstate->current_stateid && CURRENT_STATEID(stateid))
> +		memcpy(stateid, cstate->current_stateid, sizeof(stateid_t));
>  }
>  
>  static void
>  put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
>  {
>  	if (cstate->minorversion) {
> -		memcpy(&cstate->current_stateid, stateid, sizeof(stateid_t));
> -		cstate->has_stateid = true;
> +		cstate->current_stateid = stateid;
>  	}
>  }
>  
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index b8435d20..0ad0846 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -54,8 +54,7 @@ struct nfsd4_compound_state {
>  	size_t			iovlen;
>  	u32			minorversion;
>  	u32			status;
> -	stateid_t               current_stateid;
> -	bool	has_stateid;
> +	stateid_t	*current_stateid;

Certainly looks neat.  I'm all for squashing this part of the patchset,
or just all of it...

Better be defined as const stateid_t * so its contents would be read only
for its consumers.

Benny

>  };
>  
>  static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
