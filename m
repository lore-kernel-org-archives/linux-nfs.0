Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1A8AC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:53:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7CC5B21738
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:53:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726110AbfBSPxI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 10:53:08 -0500
Received: from fieldses.org ([173.255.197.46]:47016 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725820AbfBSPxI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 10:53:08 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 9EA591C9D; Tue, 19 Feb 2019 10:53:07 -0500 (EST)
Date:   Tue, 19 Feb 2019 10:53:07 -0500
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 09/10] NFSD: allow inter server COPY to have a STALE
 source server fh
Message-ID: <20190219155307.GA19603@fieldses.org>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-10-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130200348.59524-10-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 30, 2018 at 03:03:47PM -0500, Olga Kornievskaia wrote:
> The inter server to server COPY source server filehandle
> is a foreign filehandle as the COPY is sent to the destination
> server.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/Kconfig    | 10 ++++++++++
>  fs/nfsd/nfs4proc.c | 41 ++++++++++++++++++++++++++++++++++++-----
>  fs/nfsd/nfsfh.h    |  5 ++++-
>  fs/nfsd/xdr4.h     |  1 +
>  4 files changed, 51 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index 20b1c17..37ff3d5 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -131,6 +131,16 @@ config NFSD_FLEXFILELAYOUT
>  
>  	  If unsure, say N.
>  
> +config NFSD_V4_2_INTER_SSC
> +	bool "NFSv4.2 inter server to server COPY"
> +	depends on NFSD_V4 && NFS_V4_1 && NFS_V4_2
> +	help
> +	  This option enables support for NFSv4.2 inter server to
> +	  server copy where the destination server calls the NFSv4.2
> +	  client to read the data to copy from the source server.
> +
> +	  If unsure, say N.
> +
>  config NFSD_V4_SECURITY_LABEL
>  	bool "Provide Security Label support for NFSv4 server"
>  	depends on NFSD_V4 && SECURITY
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 70d03e9..2e28254 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -503,12 +503,20 @@ static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_stat
>  	    union nfsd4_op_u *u)
>  {
>  	struct nfsd4_putfh *putfh = &u->putfh;
> +	__be32 ret;
>  
>  	fh_put(&cstate->current_fh);
>  	cstate->current_fh.fh_handle.fh_size = putfh->pf_fhlen;
>  	memcpy(&cstate->current_fh.fh_handle.fh_base, putfh->pf_fhval,
>  	       putfh->pf_fhlen);
> -	return fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_BYPASS_GSS);
> +	ret = fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_BYPASS_GSS);
> +#ifdef CONFIG_NFSD_V4_2_INTER_SSC
> +	if (ret == nfserr_stale && putfh->no_verify) {
> +		SET_FH_FLAG(&cstate->current_fh, NFSD4_FH_FOREIGN);
> +		ret = 0;
> +	}
> +#endif
> +	return ret;
>  }
>  
>  static __be32
> @@ -1967,11 +1975,12 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  {
>  	struct nfsd4_compoundargs *args = rqstp->rq_argp;
>  	struct nfsd4_compoundres *resp = rqstp->rq_resp;
> -	struct nfsd4_op	*op;
> +	struct nfsd4_op	*op, *current_op, *saved_op;
>  	struct nfsd4_compound_state *cstate = &resp->cstate;
>  	struct svc_fh *current_fh = &cstate->current_fh;
>  	struct svc_fh *save_fh = &cstate->save_fh;
>  	__be32		status;
> +	int i;
>  
>  	svcxdr_init_encode(rqstp, resp);
>  	resp->tagp = resp->xdr.p;
> @@ -2006,6 +2015,27 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  		resp->opcnt = 1;
>  		goto encode_op;
>  	}
> +#ifdef CONFIG_NFSD_V4_2_INTER_SSC
> +	/* traverse all operation and if it's a COPY compound, mark the
> +	 * source filehandle to skip verification
> +	 */
> +	for (i = 0; i < args->opcnt; i++) {
> +		op = &args->ops[i];
> +		if (op->opnum == OP_PUTFH)
> +			current_op = op;
> +		else if (op->opnum == OP_SAVEFH)
> +			saved_op = current_op;
> +		else if (op->opnum == OP_RESTOREFH)
> +			current_op = saved_op;
> +		else if (op->opnum == OP_COPY) {
> +			struct nfsd4_copy *copy = (struct nfsd4_copy *)&op[i].u;
> +			struct nfsd4_putfh *putfh =
> +				(struct nfsd4_putfh *)&saved_op->u;
> +			if (!copy->cp_intra)
> +				putfh->no_verify = true;
> +		}
> +	}
> +#endif

This looks good, but could you please move this loop to a function of
its own?  (And do the usual trick of making that function a no-op when
INTER_SSC isn't defined.)

--b.

>  
>  	trace_nfsd_compound(rqstp, args->opcnt);
>  	while (!status && resp->opcnt < args->opcnt) {
> @@ -2021,13 +2051,14 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  				op->status = nfsd4_open_omfg(rqstp, cstate, op);
>  			goto encode_op;
>  		}
> -
> -		if (!current_fh->fh_dentry) {
> +		if (!current_fh->fh_dentry &&
> +				!HAS_FH_FLAG(current_fh, NFSD4_FH_FOREIGN)) {
>  			if (!(op->opdesc->op_flags & ALLOWED_WITHOUT_FH)) {
>  				op->status = nfserr_nofilehandle;
>  				goto encode_op;
>  			}
> -		} else if (current_fh->fh_export->ex_fslocs.migrated &&
> +		} else if (current_fh->fh_export &&
> +			   current_fh->fh_export->ex_fslocs.migrated &&
>  			  !(op->opdesc->op_flags & ALLOWED_ON_ABSENT_FS)) {
>  			op->status = nfserr_moved;
>  			goto encode_op;
> diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
> index 755e256..b9c7568 100644
> --- a/fs/nfsd/nfsfh.h
> +++ b/fs/nfsd/nfsfh.h
> @@ -35,7 +35,7 @@ static inline ino_t u32_to_ino_t(__u32 uino)
>  
>  	bool			fh_locked;	/* inode locked by us */
>  	bool			fh_want_write;	/* remount protection taken */
> -
> +	int			fh_flags;	/* FH flags */
>  #ifdef CONFIG_NFSD_V3
>  	bool			fh_post_saved;	/* post-op attrs saved */
>  	bool			fh_pre_saved;	/* pre-op attrs saved */
> @@ -56,6 +56,9 @@ static inline ino_t u32_to_ino_t(__u32 uino)
>  #endif /* CONFIG_NFSD_V3 */
>  
>  } svc_fh;
> +#define NFSD4_FH_FOREIGN (1<<0)
> +#define SET_FH_FLAG(c, f) ((c)->fh_flags |= (f))
> +#define HAS_FH_FLAG(c, f) ((c)->fh_flags & (f))
>  
>  enum nfsd_fsid {
>  	FSID_DEV = 0,
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 9d7318c..fbd18d6 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -221,6 +221,7 @@ struct nfsd4_lookup {
>  struct nfsd4_putfh {
>  	u32		pf_fhlen;           /* request */
>  	char		*pf_fhval;          /* request */
> +	bool		no_verify;	    /* represents foreigh fh */
>  };
>  
>  struct nfsd4_open {
> -- 
> 1.8.3.1
