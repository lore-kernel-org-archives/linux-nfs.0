From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 40/51] nfsd41: CREATE_EXCLUSIVE4_1
Date: Mon, 17 Nov 2008 16:13:42 +0200
Message-ID: <49217C16.6050007@panasas.com>
References: <491895A0.3040809@panasas.com> <1226350465-11617-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:12505 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752081AbYKQONp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:13:45 -0500
In-Reply-To: <1226350465-11617-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:54 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> Implement the CREATE_EXCLUSIVE4_1 open mode conforming to
> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
> 
> This mode allows the client to atomically create a file
> if it doesn't exist while setting some of its attributes.
> 
> It must be implemented if the server supports persistent
> reply cache and/or pnfs.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4proc.c        |   15 +++++++++++++++
>  fs/nfsd/nfs4xdr.c         |   21 +++++++++++++++++++++
>  include/linux/nfs4.h      |    8 +++++++-
>  include/linux/nfsd/xdr4.h |   10 ++++------
>  4 files changed, 47 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 5164040..9401d56 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -93,6 +93,21 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
>  	open->op_truncate = 0;
>  
>  	if (open->op_create) {
> +		/* FIXME: check session persistence and pnfs flags.
> +		 * The nfsv4.1 spec requires the following semantics:
> +		 *
> +		 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
> +		 * Reply Cache  | server |                 |
> +		 * -------------+--------+-----------------+--------------------
> +		 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
> +		 *              |        |                 | (SHOULD)
> +		 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
> +		 *              |        |                 | (SHOULD NOT)
> +		 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
> +		 * yes          | no     | GUARDED4        | GUARDED4
> +		 * yes          | yes    | GUARDED4        | GUARDED4
> +		 */
> +
>  		/*
>  		 * Note: create modes (UNCHECKED,GUARDED...) are the same
>  		 * in NFSv4 as in v3.
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 227434c..04a9088 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -264,6 +264,14 @@ static u32 nfsd_attrmask[] = {
>  	NFSD_WRITEABLE_ATTRS_WORD2
>  };
>  
> +#if defined(CONFIG_NFSD_V4_1)
> +static u32 nfsd41_ex_attrmask[] = {
> +	NFSD_SUPPATTR_EXCLCREAT_WORD0,
> +	NFSD_SUPPATTR_EXCLCREAT_WORD1,
> +	NFSD_SUPPATTR_EXCLCREAT_WORD2
> +};
> +#endif /* CONFIG_NFSD_V4_1 */
> +
>  static __be32
>  nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval, u32 *writable,
>  		   struct iattr *iattr, struct nfs4_acl **acl)
> @@ -690,6 +698,19 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
>  			READ_BUF(8);
>  			COPYMEM(open->op_verf.data, 8);
>  			break;
> +#if defined(CONFIG_NFSD_V4_1)

review 11-13: get rid of #ifdef

> +		case NFS4_CREATE_EXCLUSIVE4_1:
> +			if (argp->minorversion < 1)
> +				goto xdr_error;
> +			READ_BUF(8);
> +			COPYMEM(open->op_verf.data, 8);
> +			status = nfsd4_decode_fattr(argp, open->op_bmval,
> +				nfsd41_ex_attrmask, &open->op_iattr,
> +				&open->op_acl);
> +			if (status)
> +				goto out;
> +			break;
> +#endif /* CONFIG_NFSD_V4_1 */
>  		default:
>  			goto xdr_error;
>  		}
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 5471adf..0aa4971 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -350,7 +350,13 @@ enum opentype4 {
>  enum createmode4 {
>  	NFS4_CREATE_UNCHECKED = 0,
>  	NFS4_CREATE_GUARDED = 1,
> -	NFS4_CREATE_EXCLUSIVE = 2
> +	NFS4_CREATE_EXCLUSIVE = 2,
> +	/*
> +	 * New to NFSv4.1. If session is persistent,
> +	 * GUARDED4 MUST be used. Otherwise, use
> +	 * EXCLUSIVE4_1 instead of EXCLUSIVE4.
> +	 */
> +	NFS4_CREATE_EXCLUSIVE4_1 = 3
>  };
>  
>  enum limit_by4 {
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index 7812e8c..17b0a3e 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -220,10 +220,8 @@ struct nfsd4_open {
>  	u32		op_create;     	    /* request */
>  	u32		op_createmode;      /* request */
>  	u32		op_bmval[3];        /* request */
> -	union {                             /* request */
> -		struct iattr	iattr;                      /* UNCHECKED4,GUARDED4 */
> -		nfs4_verifier	verf;                                /* EXCLUSIVE4 */
> -	} u;
> +	struct iattr	iattr;              /* UNCHECKED4, GUARDED4, EXCLUSIVE4_1 */
> +	nfs4_verifier	verf;               /* EXCLUSIVE4 */
>  	clientid_t	op_clientid;        /* request */
>  	struct xdr_netobj op_owner;           /* request */
>  	u32		op_seqid;           /* request */
> @@ -238,8 +236,8 @@ struct nfsd4_open {
>  	struct nfs4_stateowner *op_stateowner; /* used during processing */
>  	struct nfs4_acl *op_acl;
>  };
> -#define op_iattr	u.iattr
> -#define op_verf		u.verf
> +#define op_iattr	iattr
> +#define op_verf		verf
>  
>  struct nfsd4_open_confirm {
>  	stateid_t	oc_req_stateid		/* request */;
