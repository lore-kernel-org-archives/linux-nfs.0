Return-Path: <SRS0=4cvb=NS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7794C0044C
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 18:57:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5A58020862
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 18:57:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A58020862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728585AbeKHE3d (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Nov 2018 23:29:33 -0500
Received: from fieldses.org ([173.255.197.46]:37142 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728173AbeKHE3d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Nov 2018 23:29:33 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 5BD9D1E67; Wed,  7 Nov 2018 13:57:53 -0500 (EST)
Date:   Wed, 7 Nov 2018 13:57:53 -0500
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 12/13] NFSD: allow inter server COPY to have a STALE
 source server fh
Message-ID: <20181107185753.GB19588@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-13-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019152905.32418-13-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 19, 2018 at 11:29:04AM -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> The inter server to server COPY source server filehandle
> is a foreign filehandle as the COPY is sent to the destination
> server.

Compounds can do a lot of different strange things, and I'm not
convinced this code handles every case correctly.  Examples: I think
that

	PUTFH
	TEST_STATEID
	SAVEFH
	COPY

will incorrectly return nfserr_stale if the PUTHF gets a foreign
filehandle, even though that filehandle is only used as the source of
the COPY.  And:

	PUTFH
	SAVEFH
	RENAME
	COPY

will pass an unverified source filehandle to rename.

I can think of a couple ways to get this right for certain:

	- delay all filehandle verification till the time the filehandle
	  isused.  That would make checking this simple, but it would
	  change our behavior so, for example PUTFH+READ with a bad
	  filehandle will return the error on the READ where it used to
	  return it on the PUTFH.  I don't know if that's a problem.

	- somewhere at the start of nfsd4_proc_compound, do one pass
	  through the compound checking where the filehandles will be
	  used and marking those ops that can skip checking.  E.g.:

		nfsd4_op *current, *saved

		foreach op in compound:
			- if op is putfh:
				current := op
			- if op is savefh:
				saved := current
			- if op is restorefh:
				current := saved
			- etc.
			- if op is copy:
				mark_no_verify(saved)

	  Or something like that.

--b.

> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/Kconfig    | 10 ++++++++++
>  fs/nfsd/nfs4proc.c | 45 ++++++++++++++++++++++++++++++++++++++++++---
>  fs/nfsd/nfsfh.h    |  5 ++++-
>  fs/nfsd/xdr4.h     |  1 +
>  4 files changed, 57 insertions(+), 4 deletions(-)
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
> index 43a83c7..59e9d0c 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -503,12 +503,21 @@ static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_stat
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
> +	if (ret == nfserr_stale && HAS_CSTATE_FLAG(cstate, NO_VERIFY_FH)) {
> +		CLEAR_CSTATE_FLAG(cstate, NO_VERIFY_FH);
> +		SET_FH_FLAG(&cstate->current_fh, NFSD4_FH_FOREIGN);
> +		ret = 0;
> +	}
> +#endif
> +	return ret;
>  }
>  
>  static __be32
> @@ -1957,6 +1966,26 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  		- rqstp->rq_auth_slack;
>  }
>  
> +#ifdef CONFIG_NFSD_V4_2_INTER_SSC
> +static bool _compound_contains_inter_copy(struct nfsd4_op *ops, int start,
> +					  int end)
> +{
> +	bool found = false;
> +	struct nfsd4_copy *copy;
> +	int i;
> +
> +	for (i = start; i < end; i++) {
> +		if (ops[i].opnum == OP_COPY) {
> +			copy = (struct nfsd4_copy *)&ops[i].u;
> +			if (copy->cp_src)
> +				found = true;
> +			break;
> +		}
> +	}
> +	return found;
> +}
> +#endif
> +
>  /*
>   * COMPOUND call.
>   */
> @@ -2019,13 +2048,23 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  				op->status = nfsd4_open_omfg(rqstp, cstate, op);
>  			goto encode_op;
>  		}
> +#ifdef CONFIG_NFSD_V4_2_INTER_SSC
> +		if (op->opnum == OP_PUTFH &&
> +			args->ops[resp->opcnt].opnum == OP_SAVEFH &&
> +			args->ops[resp->opcnt+1].opnum == OP_PUTFH &&
> +			_compound_contains_inter_copy(args->ops, resp->opcnt+2,
> +						      args->opcnt))
> +			SET_CSTATE_FLAG(cstate, NO_VERIFY_FH);
> +#endif
>  
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
> index 4a1e53d..c98ef64 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -45,6 +45,7 @@
>  
>  #define CURRENT_STATE_ID_FLAG (1<<0)
>  #define SAVED_STATE_ID_FLAG (1<<1)
> +#define NO_VERIFY_FH (1<<2)
>  
>  #define SET_CSTATE_FLAG(c, f) ((c)->sid_flags |= (f))
>  #define HAS_CSTATE_FLAG(c, f) ((c)->sid_flags & (f))
> -- 
> 1.8.3.1
