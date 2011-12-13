Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57002 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753443Ab1LMIOp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Dec 2011 03:14:45 -0500
Received: by eekc4 with SMTP id c4so1988811eek.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Dec 2011 00:14:44 -0800 (PST)
Message-ID: <4EE70823.5070407@tonian.com>
Date: Tue, 13 Dec 2011 10:09:07 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Tigran Mkrtchyan <kofemann@googlemail.com>
CC: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v4 2/3] nfsd41: handle current stateid on lock and locku
References: <1323723627-413-1-git-send-email-tigran.mkrtchyan@desy.de> <1323723627-413-3-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323723627-413-3-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-12 23:00, Tigran Mkrtchyan wrote:
> From: Tigran Mkrtchyan <kofemann@gmail.com>
> 
> plus minor fixes

hopefully that's not the case anymore :)

> 
> Conflicts:
> 
> 	fs/nfsd/nfs4proc.c

ditto

> 
> Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
> ---
>  fs/nfsd/current_stateid.h |   11 ++++++++++-
>  fs/nfsd/nfs4proc.c        |    2 ++
>  fs/nfsd/nfs4state.c       |   22 ++++++++++++++++++++--
>  3 files changed, 32 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
> index a83dd50..21550b6 100644
> --- a/fs/nfsd/current_stateid.h
> +++ b/fs/nfsd/current_stateid.h
> @@ -4,8 +4,17 @@
>  #include "state.h"
>  #include "xdr4.h"
>  
> +/*
> + * functions to set current state id
> + */
>  extern void nfsd4_set_openstateid(struct nfsd4_compound_state *, struct nfsd4_open *);
> -extern void nfsd4_get_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
> +extern void nfsd4_set_lockstateid(struct nfsd4_compound_state *, struct nfsd4_lock *);
>  extern void nfsd4_set_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
>  
> +/*
> + * functions to consume current state id
> + */
> +extern void nfsd4_get_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
> +extern void nfsd4_get_lockustateid(struct nfsd4_compound_state *, struct nfsd4_locku *);
> +
>  #endif   /* _NFSD4_CURRENT_STATE_H */
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 3dfb235..90c532b 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1478,6 +1478,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  		.op_flags = OP_MODIFIES_SOMETHING,
>  		.op_name = "OP_LOCK",
>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_lock_rsize,
> +		.op_set_currentstateid = (stateid_setter)nfsd4_set_lockstateid,
>  	},
>  	[OP_LOCKT] = {
>  		.op_func = (nfsd4op_func)nfsd4_lockt,
> @@ -1488,6 +1489,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  		.op_flags = OP_MODIFIES_SOMETHING,
>  		.op_name = "OP_LOCKU",
>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
> +		.op_get_currentstateid = (stateid_getter)nfsd4_get_lockustateid,
>  	},
>  	[OP_LOOKUP] = {
>  		.op_func = (nfsd4op_func)nfsd4_lookup,
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 594b44e..58410b2 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4564,6 +4564,9 @@ put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
>  		cstate->current_stateid = stateid;
>  }
>  
> +/*
> + * functions to set current state id
> + */
>  void
>  nfsd4_set_openstateid(struct nfsd4_compound_state *cstate, struct nfsd4_open *open)
>  {
> @@ -4571,13 +4574,28 @@ nfsd4_set_openstateid(struct nfsd4_compound_state *cstate, struct nfsd4_open *op
>  }
>  
>  void
> +nfsd4_set_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
> +{
> +	put_stateid(cstate, &close->cl_stateid);
> +}
> +
> +void
> +nfsd4_set_lockstateid(struct nfsd4_compound_state *cstate, struct nfsd4_lock *lock)
> +{
> +	put_stateid(cstate, &lock->lk_resp_stateid);
> +}
> +
> +/*
> + * functions to consume current state id
> + */
> +void
>  nfsd4_get_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
>  {
>  	get_stateid(cstate, &close->cl_stateid);
>  }
>  
>  void
> -nfsd4_set_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
> +nfsd4_get_lockustateid(struct nfsd4_compound_state *cstate, struct nfsd4_locku *locku)
>  {
> -	get_stateid(cstate, &close->cl_stateid);
> +	get_stateid(cstate, &locku->lu_stateid);

Reading Section 8.2.3.  Special Stateids, for some reason (that I'm not sure of)
RFC5661 requires the following:

      The stateid passed to the operation in place
      of the special value has its "seqid" value set to zero, except
      when the current stateid is used by the operation CLOSE or
      OPEN_DOWNGRADE.

How about defining another get_stateid helper that will clear si_generation?

Benny

>  }
