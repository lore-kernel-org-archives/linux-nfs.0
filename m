From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 07/47] nfsd41: define nfs41 error codes
Date: Mon, 30 Mar 2009 14:16:40 -0400
Message-ID: <20090330181640.GD31237@fieldses.org>
References: <49CDDFC2.4070402@panasas.com> <1238229075-9010-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:41381 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbZC3SQp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 14:16:45 -0400
In-Reply-To: <1238229075-9010-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 28, 2009 at 11:31:15AM +0300, Benny Halevy wrote:
> From: Marc Eshel <eshel@almaden.ibm.com>
> 
> Define all error code present in
> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-29.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: clean up error code definitions]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  include/linux/nfs.h       |    2 --
>  include/linux/nfsd/nfsd.h |   43 ++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 42 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/nfs.h b/include/linux/nfs.h
> index 1510a64..214d499 100644
> --- a/include/linux/nfs.h
> +++ b/include/linux/nfs.h
> @@ -109,8 +109,6 @@
>  	NFSERR_FILE_OPEN = 10046,      /*       v4 */
>  	NFSERR_ADMIN_REVOKED = 10047,  /*       v4 */
>  	NFSERR_CB_PATH_DOWN = 10048,   /*       v4 */
> -
> -	NFSERR_REPLAY_ME = 11001,	/* linux internal */

This renders "[PATCH v2 05/47] nfsd41: change NFSERR_REPLAY_ME" moot;
just drop that previous patch.

--b.

>  };
>  
>  /* NFSv2 file types - beware, these are not the same in NFSv3 */
> diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
> index 54beda1..ab9616d 100644
> --- a/include/linux/nfsd/nfsd.h
> +++ b/include/linux/nfsd/nfsd.h
> @@ -249,7 +249,44 @@ void		nfsd_lockd_shutdown(void);
>  #define	nfserr_cb_path_down	cpu_to_be32(NFSERR_CB_PATH_DOWN)
>  #define	nfserr_locked		cpu_to_be32(NFSERR_LOCKED)
>  #define	nfserr_wrongsec		cpu_to_be32(NFSERR_WRONGSEC)
> -#define	nfserr_replay_me	cpu_to_be32(NFSERR_REPLAY_ME)
> +#define nfserr_badiomode		cpu_to_be32(NFS4ERR_BADIOMODE)
> +#define nfserr_badlayout		cpu_to_be32(NFS4ERR_BADLAYOUT)
> +#define nfserr_bad_session_digest	cpu_to_be32(NFS4ERR_BAD_SESSION_DIGEST)
> +#define nfserr_badsession		cpu_to_be32(NFS4ERR_BADSESSION)
> +#define nfserr_badslot			cpu_to_be32(NFS4ERR_BADSLOT)
> +#define nfserr_complete_already		cpu_to_be32(NFS4ERR_COMPLETE_ALREADY)
> +#define nfserr_conn_not_bound_to_session cpu_to_be32(NFS4ERR_CONN_NOT_BOUND_TO_SESSION)
> +#define nfserr_deleg_already_wanted	cpu_to_be32(NFS4ERR_DELEG_ALREADY_WANTED)
> +#define nfserr_back_chan_busy		cpu_to_be32(NFS4ERR_BACK_CHAN_BUSY)
> +#define nfserr_layouttrylater		cpu_to_be32(NFS4ERR_LAYOUTTRYLATER)
> +#define nfserr_layoutunavailable	cpu_to_be32(NFS4ERR_LAYOUTUNAVAILABLE)
> +#define nfserr_nomatching_layout	cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT)
> +#define nfserr_recallconflict		cpu_to_be32(NFS4ERR_RECALLCONFLICT)
> +#define nfserr_unknown_layouttype	cpu_to_be32(NFS4ERR_UNKNOWN_LAYOUTTYPE)
> +#define nfserr_seq_misordered		cpu_to_be32(NFS4ERR_SEQ_MISORDERED)
> +#define nfserr_sequence_pos		cpu_to_be32(NFS4ERR_SEQUENCE_POS)
> +#define nfserr_req_too_big		cpu_to_be32(NFS4ERR_REQ_TOO_BIG)
> +#define nfserr_rep_too_big		cpu_to_be32(NFS4ERR_REP_TOO_BIG)
> +#define nfserr_rep_too_big_to_cache	cpu_to_be32(NFS4ERR_REP_TOO_BIG_TO_CACHE)
> +#define nfserr_retry_uncached_rep	cpu_to_be32(NFS4ERR_RETRY_UNCACHED_REP)
> +#define nfserr_unsafe_compound		cpu_to_be32(NFS4ERR_UNSAFE_COMPOUND)
> +#define nfserr_too_many_ops		cpu_to_be32(NFS4ERR_TOO_MANY_OPS)
> +#define nfserr_op_not_in_session	cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION)
> +#define nfserr_hash_alg_unsupp		cpu_to_be32(NFS4ERR_HASH_ALG_UNSUPP)
> +#define nfserr_clientid_busy		cpu_to_be32(NFS4ERR_CLIENTID_BUSY)
> +#define nfserr_pnfs_io_hole		cpu_to_be32(NFS4ERR_PNFS_IO_HOLE)
> +#define nfserr_seq_false_retry		cpu_to_be32(NFS4ERR_SEQ_FALSE_RETRY)
> +#define nfserr_bad_high_slot		cpu_to_be32(NFS4ERR_BAD_HIGH_SLOT)
> +#define nfserr_deadsession		cpu_to_be32(NFS4ERR_DEADSESSION)
> +#define nfserr_encr_alg_unsupp		cpu_to_be32(NFS4ERR_ENCR_ALG_UNSUPP)
> +#define nfserr_pnfs_no_layout		cpu_to_be32(NFS4ERR_PNFS_NO_LAYOUT)
> +#define nfserr_not_only_op		cpu_to_be32(NFS4ERR_NOT_ONLY_OP)
> +#define nfserr_wrong_cred		cpu_to_be32(NFS4ERR_WRONG_CRED)
> +#define nfserr_wrong_type		cpu_to_be32(NFS4ERR_WRONG_TYPE)
> +#define nfserr_dirdeleg_unavail		cpu_to_be32(NFS4ERR_DIRDELEG_UNAVAIL)
> +#define nfserr_reject_deleg		cpu_to_be32(NFS4ERR_REJECT_DELEG)
> +#define nfserr_returnconflict		cpu_to_be32(NFS4ERR_RETURNCONFLICT)
> +#define nfserr_deleg_revoked		cpu_to_be32(NFS4ERR_DELEG_REVOKED)
>  
>  /* error codes for internal use */
>  /* if a request fails due to kmalloc failure, it gets dropped.
> @@ -258,6 +295,10 @@ void		nfsd_lockd_shutdown(void);
>  #define	nfserr_dropit		cpu_to_be32(30000)
>  /* end-of-file indicator in readdir */
>  #define	nfserr_eof		cpu_to_be32(30001)
> +/* replay detected */
> +#define	nfserr_replay_me	cpu_to_be32(11001)
> +/* nfs41 replay detected */
> +#define	nfserr_replay_cache	cpu_to_be32(11002)
>  
>  /* Check for dir entries '.' and '..' */
>  #define isdotent(n, l)	(l < 3 && n[0] == '.' && (l == 1 || n[1] == '.'))
> -- 
> 1.6.2.1
> 
