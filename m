Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33784 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023Ab1LLPVP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 10:21:15 -0500
Received: by bkcjm19 with SMTP id jm19so1549142bkc.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 07:21:13 -0800 (PST)
Message-ID: <4EE61BE4.9060808@tonian.com>
Date: Mon, 12 Dec 2011 17:21:08 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Tigran Mkrtchyan <kofemann@googlemail.com>
CC: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v3 1/5] nfsd41: handle current stateid in open and close
References: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de> <1323621708-25138-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323621708-25138-2-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-11 18:41, Tigran Mkrtchyan wrote:
> From: Tigran Mkrtchyan <kofemann@gmail.com>
> 
> 
> Signed-off-by: Tigran Mkrtchyan <kofemann@gmail.com>
> ---
>  fs/nfsd/current_stateid.h |   11 ++++++++++
>  fs/nfsd/nfs4proc.c        |   47 ++++++++++++++++++++++++++++++++++++++------
>  fs/nfsd/nfs4state.c       |   36 ++++++++++++++++++++++++++++++++++
>  fs/nfsd/xdr4.h            |    2 +
>  4 files changed, 89 insertions(+), 7 deletions(-)
>  create mode 100644 fs/nfsd/current_stateid.h
> 
> diff --git a/fs/nfsd/current_stateid.h b/fs/nfsd/current_stateid.h
> new file mode 100644
> index 0000000..a83dd50
> --- /dev/null
> +++ b/fs/nfsd/current_stateid.h
> @@ -0,0 +1,11 @@
> +#ifndef _NFSD4_CURRENT_STATE_H
> +#define _NFSD4_CURRENT_STATE_H
> +
> +#include "state.h"
> +#include "xdr4.h"
> +
> +extern void nfsd4_set_openstateid(struct nfsd4_compound_state *, struct nfsd4_open *);
> +extern void nfsd4_get_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
> +extern void nfsd4_set_closestateid(struct nfsd4_compound_state *, struct nfsd4_close *);
> +
> +#endif   /* _NFSD4_CURRENT_STATE_H */
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index fa38336..4b8d81a 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -39,6 +39,7 @@
>  #include "cache.h"
>  #include "xdr4.h"
>  #include "vfs.h"
> +#include "current_stateid.h"
>  
>  #define NFSDDBG_FACILITY		NFSDDBG_PROC
>  
> @@ -556,7 +557,6 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  				     create->cr_name, create->cr_namelen,
>  				     &create->cr_iattr, S_IFSOCK, 0, &resfh);
>  		break;
> -

nit: I assume this cosmetic hunk can be dropped :)

>  	case NF4FIFO:
>  		status = nfsd_create(rqstp, &cstate->current_fh,
>  				     create->cr_name, create->cr_namelen,
> @@ -1001,6 +1001,8 @@ static inline void nfsd4_increment_op_stats(u32 opnum)
>  typedef __be32(*nfsd4op_func)(struct svc_rqst *, struct nfsd4_compound_state *,
>  			      void *);
>  typedef u32(*nfsd4op_rsize)(struct svc_rqst *, struct nfsd4_op *op);
> +typedef void(*stateid_setter)(struct nfsd4_compound_state *, void *);
> +typedef void(*stateid_getter)(struct nfsd4_compound_state *, void *);
>  
>  enum nfsd4_op_flags {
>  	ALLOWED_WITHOUT_FH = 1 << 0,	/* No current filehandle required */
> @@ -1026,6 +1028,9 @@ enum nfsd4_op_flags {
>  	 * the v4.0 case).
>  	 */
>  	OP_CACHEME = 1 << 6,
> +	CONSUMES_CURRENT_STATEID = 1 << 7,
> +	PROVIDES_CURRENT_STATEID = 1 << 8,
> +	CLEARS_CURRENT_STATEID = 1 << 9,
>  };
>  
>  struct nfsd4_operation {
> @@ -1034,6 +1039,8 @@ struct nfsd4_operation {
>  	char *op_name;
>  	/* Try to get response size before operation */
>  	nfsd4op_rsize op_rsize_bop;
> +	stateid_setter op_get_currentstateid;
> +	stateid_getter op_set_currentstateid;
>  };
>  
>  static struct nfsd4_operation nfsd4_ops[];
> @@ -1116,6 +1123,14 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
>  	return !(nextd->op_flags & OP_HANDLES_WRONGSEC);
>  }
>  
> +static void
> +nfsd4_clear_currentstateid(struct nfsd4_compound_state *cstate)
> +{
> +	if (cstate->has_stateid) {
> +		memset(&cstate->current_stateid, 0, sizeof(stateid_t));
> +		cstate->has_stateid = false;
> +	}

I'm a bit confused. In PATCH 0/5 you wrote:
"struct nfsd4_compound_state contains pointer to current stateid"
maybe it changes later in another patch. I'll be patient and keep reading ;-)

Also, you use both a belt and suspenders.
Instead of has_stateid I think you can just use the value of the
invalid stateid and all zeroes is a valid, special stateid.

> +}
>  /*
>   * COMPOUND call.
>   */
> @@ -1196,6 +1211,9 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  
>  		opdesc = OPDESC(op);
>  
> +		BUG_ON(opdesc->op_flags & PROVIDES_CURRENT_STATEID && 
> +			opdesc->op_flags & CLEARS_CURRENT_STATEID);
> +

If so, couldn't the op just use nfsd4_clear_currentstateid()
as its op_set_currentstateid?

>  		if (!cstate->current_fh.fh_dentry) {
>  			if (!(opdesc->op_flags & ALLOWED_WITHOUT_FH)) {
>  				op->status = nfserr_nofilehandle;
> @@ -1216,13 +1234,25 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  		if (op->status)
>  			goto encode_op;
>  
> -		if (opdesc->op_func)
> +		if (opdesc->op_func) {
> +			if (opdesc->op_flags & CONSUMES_CURRENT_STATEID)
> +				opdesc->op_get_currentstateid(cstate, &op->u);
>  			op->status = opdesc->op_func(rqstp, cstate, &op->u);
> -		else
> +		} else
>  			BUG_ON(op->status == nfs_ok);
>  
> -		if (!op->status && need_wrongsec_check(rqstp))
> -			op->status = check_nfsd_access(cstate->current_fh.fh_export, rqstp);
> +		if (!op->status) {
> +			if (opdesc->op_flags & PROVIDES_CURRENT_STATEID) {
> +				opdesc->op_set_currentstateid(cstate, &op->u);
> +				cstate->has_stateid = true;
> +			}
> +
> +			if (opdesc->op_flags & CLEARS_CURRENT_STATEID)
> +				nfsd4_clear_currentstateid(cstate);
> +
> +			if (need_wrongsec_check(rqstp))
> +				op->status = check_nfsd_access(cstate->current_fh.fh_export, rqstp);

Hmmm, if check_nfsd_access returns with a failure there's no point
in setting the current_stateid, is it?

> +		}
>  
>  encode_op:
>  		/* Only from SEQUENCE */
> @@ -1411,9 +1441,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  	},
>  	[OP_CLOSE] = {
>  		.op_func = (nfsd4op_func)nfsd4_close,
> -		.op_flags = OP_MODIFIES_SOMETHING,
> +		.op_flags = OP_MODIFIES_SOMETHING | CONSUMES_CURRENT_STATEID,

Looks like this also requires PROVIDES_CURRENT_STATEID
(or just ditch the flag so there can't be disagreement between the two :)

>  		.op_name = "OP_CLOSE",
>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_status_stateid_rsize,
> +		.op_get_currentstateid = (stateid_getter)nfsd4_get_closestateid,
> +		.op_set_currentstateid = (stateid_setter)nfsd4_set_closestateid,
>  	},
>  	[OP_COMMIT] = {
>  		.op_func = (nfsd4op_func)nfsd4_commit,
> @@ -1481,9 +1513,10 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  	},
>  	[OP_OPEN] = {
>  		.op_func = (nfsd4op_func)nfsd4_open,
> -		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
> +		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING | PROVIDES_CURRENT_STATEID,
>  		.op_name = "OP_OPEN",
>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_open_rsize,
> +		.op_set_currentstateid = (stateid_setter)nfsd4_set_openstateid,
>  	},
>  	[OP_OPEN_CONFIRM] = {
>  		.op_func = (nfsd4op_func)nfsd4_open_confirm,
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 47e94e3..278e0af 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -51,10 +51,12 @@ time_t nfsd4_grace = 90;
>  static time_t boot_time;
>  static stateid_t zerostateid;             /* bits all 0 */
>  static stateid_t onestateid;              /* bits all 1 */
> +static stateid_t currentstateid;         /* other all 0, seqid 1 */
>  static u64 current_sessionid = 1;
>  
>  #define ZERO_STATEID(stateid) (!memcmp((stateid), &zerostateid, sizeof(stateid_t)))
>  #define ONE_STATEID(stateid)  (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
> +#define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
>  
>  /* forward declarations */
>  static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
> @@ -4423,6 +4425,8 @@ nfs4_state_init(void)
>  		INIT_LIST_HEAD(&lock_ownerstr_hashtbl[i]);
>  	}
>  	memset(&onestateid, ~0, sizeof(stateid_t));
> +	/* seqid 1, other all 0 */
> +	currentstateid.si_generation = 1;


>  	INIT_LIST_HEAD(&close_lru);
>  	INIT_LIST_HEAD(&client_lru);
>  	INIT_LIST_HEAD(&del_recall_lru);
> @@ -4545,3 +4549,35 @@ nfs4_state_shutdown(void)
>  	nfs4_unlock_state();
>  	nfsd4_destroy_callback_queue();
>  }
> +
> +static void
> +get_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
> +{
> +	if (cstate->minorversion && CURRENT_STATEID(stateid))
> +		memcpy(stateid, &cstate->current_stateid, sizeof(stateid_t));
> +}
> +
> +static void
> +put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
> +{
> +	if (cstate->minorversion)
> +		memcpy(&cstate->current_stateid, stateid, sizeof(stateid_t));

you can also set has_stateid to true here...
(If you keep it. I'm not convinced yet it's really needed)

> +}
> +
> +void
> +nfsd4_set_openstateid(struct nfsd4_compound_state *cstate, struct nfsd4_open *open)
> +{
> +	put_stateid(cstate, &open->op_stateid);
> +}
> +
> +void
> +nfsd4_get_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
> +{
> +	get_stateid(cstate, &close->cl_stateid);
> +}
> +
> +void
> +nfsd4_set_closestateid(struct nfsd4_compound_state *cstate, struct nfsd4_close *close)
> +{
> +	get_stateid(cstate, &close->cl_stateid);
> +}
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 2364747..b8435d20 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -54,6 +54,8 @@ struct nfsd4_compound_state {
>  	size_t			iovlen;
>  	u32			minorversion;
>  	u32			status;
> +	stateid_t               current_stateid;
> +	bool	has_stateid;
>  };
>  
>  static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
