Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60399 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432Ab1J1Leo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Oct 2011 07:34:44 -0400
Date: Fri, 28 Oct 2011 07:34:43 -0400
To: Benny Halevy <benny@tonian.com>
Cc: bfields@netapp.com, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@tonian.com>
Subject: Re: [RFC] nfsd4: DEBUG: XDR_ERROR()
Message-ID: <20111028113443.GA3445@fieldses.org>
References: <1319741351-3794-1-git-send-email-benny@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319741351-3794-1-git-send-email-benny@tonian.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Did I just get moved to Netapp without anyone telling me?  Anyway:

On Thu, Oct 27, 2011 at 08:49:11PM +0200, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@tonian.com>
> 
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
> 
> Bruce, would you consider this patch to help
> debug xdr parsing errors by dprinting the line where the
> xdr error detected in a more relevant place?

I don't object to the goal, but:

	- I'd like to make this code less dependent on the preprocessor
	  rather than more.

	- In particular I don't like having goto's and goto labels
	  hidden in macros--I think they make the control flow less
	  obvious.

	- There have been exceptions (mea culpa!), but usually I think
	  that we should be able to catch xdr decoding problems early,
	  so having this debugging out in the field isn't as important
	  as debugging elsewhere.

--b.

> 
> Benny
> 
>  fs/nfsd/nfs4xdr.c |   76 +++++++++++++++++++++++++---------------------------
>  1 files changed, 37 insertions(+), 39 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 2f894c6..d5fd7d0 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -79,6 +79,12 @@
>  	return 0;
>  }
>  
> +#define XDR_ERROR()	do {			\
> +	dprintk("NFSD: xdr error (%s:%d)\n",	\
> +			__FILE__, __LINE__);	\
> +	goto xdr_error;				\
> +} while (0)
> +
>  #define DECODE_HEAD				\
>  	__be32 *p;				\
>  	__be32 status
> @@ -87,8 +93,6 @@
>  out:						\
>  	return status;				\
>  xdr_error:					\
> -	dprintk("NFSD: xdr error (%s:%d)\n",	\
> -			__FILE__, __LINE__);	\
>  	status = nfserr_bad_xdr;		\
>  	goto out
>  
> @@ -109,11 +113,8 @@
>  #define SAVEMEM(x,nbytes) do {			\
>  	if (!(x = (p==argp->tmp || p == argp->tmpp) ? \
>   		savemem(argp, p, nbytes) :	\
> - 		(char *)p)) {			\
> -		dprintk("NFSD: xdr error (%s:%d)\n", \
> -				__FILE__, __LINE__); \
> -		goto xdr_error;			\
> -		}				\
> + 		(char *)p))			\
> +		XDR_ERROR();			\
>  	p += XDR_QUADLEN(nbytes);		\
>  } while (0)
>  #define COPYMEM(x,nbytes) do {			\
> @@ -126,11 +127,8 @@
>  	if (nbytes <= (u32)((char *)argp->end - (char *)argp->p)) {	\
>  		p = argp->p;			\
>  		argp->p += XDR_QUADLEN(nbytes);	\
> -	} else if (!(p = read_buf(argp, nbytes))) { \
> -		dprintk("NFSD: xdr error (%s:%d)\n", \
> -				__FILE__, __LINE__); \
> -		goto xdr_error;			\
> -	}					\
> +	} else if (!(p = read_buf(argp, nbytes))) \
> +		XDR_ERROR();			\
>  } while (0)
>  
>  static void save_buf(struct nfsd4_compoundargs *argp, struct nfsd4_saved_compoundargs *savep)
> @@ -243,7 +241,7 @@ static int zero_clientid(clientid_t *clid)
>  	READ_BUF(4);
>  	READ32(bmlen);
>  	if (bmlen > 1000)
> -		goto xdr_error;
> +		XDR_ERROR();
>  
>  	READ_BUF(bmlen << 2);
>  	if (bmlen > 0)
> @@ -373,7 +371,7 @@ static int zero_clientid(clientid_t *clid)
>  			iattr->ia_valid |= ATTR_ATIME;
>  			break;
>  		default:
> -			goto xdr_error;
> +			XDR_ERROR();
>  		}
>  	}
>  	if (bmval[1] & FATTR4_WORD1_TIME_MODIFY_SET) {
> @@ -399,7 +397,7 @@ static int zero_clientid(clientid_t *clid)
>  			iattr->ia_valid |= ATTR_MTIME;
>  			break;
>  		default:
> -			goto xdr_error;
> +			XDR_ERROR();
>  		}
>  	}
>  	if (bmval[0] & ~NFSD_WRITEABLE_ATTRS_WORD0
> @@ -407,7 +405,7 @@ static int zero_clientid(clientid_t *clid)
>  	    || bmval[2] & ~NFSD_WRITEABLE_ATTRS_WORD2)
>  		READ_BUF(expected_len - len);
>  	else if (len != expected_len)
> -		goto xdr_error;
> +		XDR_ERROR();
>  
>  	DECODE_TAIL;
>  
> @@ -556,7 +554,7 @@ static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp,
>  	READ_BUF(28);
>  	READ32(lock->lk_type);
>  	if ((lock->lk_type < NFS4_READ_LT) || (lock->lk_type > NFS4_WRITEW_LT))
> -		goto xdr_error;
> +		XDR_ERROR();
>  	READ32(lock->lk_reclaim);
>  	READ64(lock->lk_offset);
>  	READ64(lock->lk_length);
> @@ -593,7 +591,7 @@ static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp,
>  	READ_BUF(32);
>  	READ32(lockt->lt_type);
>  	if((lockt->lt_type < NFS4_READ_LT) || (lockt->lt_type > NFS4_WRITEW_LT))
> -		goto xdr_error;
> +		XDR_ERROR();
>  	READ64(lockt->lt_offset);
>  	READ64(lockt->lt_length);
>  	COPYMEM(&lockt->lt_clientid, 8);
> @@ -612,7 +610,7 @@ static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp,
>  	READ_BUF(8);
>  	READ32(locku->lu_type);
>  	if ((locku->lu_type < NFS4_READ_LT) || (locku->lu_type > NFS4_WRITEW_LT))
> -		goto xdr_error;
> +		XDR_ERROR();
>  	READ32(locku->lu_seqid);
>  	status = nfsd4_decode_stateid(argp, &locku->lu_stateid);
>  	if (status)
> @@ -742,15 +740,15 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  	status = nfsd4_decode_share_access(argp, &open->op_share_access,
>  					   &open->op_deleg_want, &dummy);
>  	if (status)
> -		goto xdr_error;
> +		XDR_ERROR();
>  	status = nfsd4_decode_share_deny(argp, &open->op_share_deny);
>  	if (status)
> -		goto xdr_error;
> +		XDR_ERROR();
>  	READ_BUF(sizeof(clientid_t));
>  	COPYMEM(&open->op_clientid, sizeof(clientid_t));
>  	status = nfsd4_decode_opaque(argp, &open->op_owner);
>  	if (status)
> -		goto xdr_error;
> +		XDR_ERROR();
>  	READ_BUF(4);
>  	READ32(open->op_create);
>  	switch (open->op_create) {
> @@ -773,7 +771,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  			break;
>  		case NFS4_CREATE_EXCLUSIVE4_1:
>  			if (argp->minorversion < 1)
> -				goto xdr_error;
> +				XDR_ERROR();
>  			READ_BUF(8);
>  			COPYMEM(open->op_verf.data, 8);
>  			status = nfsd4_decode_fattr(argp, open->op_bmval,
> @@ -782,11 +780,11 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  				goto out;
>  			break;
>  		default:
> -			goto xdr_error;
> +			XDR_ERROR();
>  		}
>  		break;
>  	default:
> -		goto xdr_error;
> +		XDR_ERROR();
>  	}
>  
>  	/* open_claim */
> @@ -820,18 +818,18 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  	case NFS4_OPEN_CLAIM_FH:
>  	case NFS4_OPEN_CLAIM_DELEG_PREV_FH:
>  		if (argp->minorversion < 1)
> -			goto xdr_error;
> +			XDR_ERROR();
>  		/* void */
>  		break;
>  	case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
>  		if (argp->minorversion < 1)
> -			goto xdr_error;
> +			XDR_ERROR();
>  		status = nfsd4_decode_stateid(argp, &open->op_delegate_stateid);
>  		if (status)
>  			return status;
>  		break;
>  	default:
> -		goto xdr_error;
> +		XDR_ERROR();
>  	}
>  
>  	DECODE_TAIL;
> @@ -879,7 +877,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  	READ_BUF(4);
>  	READ32(putfh->pf_fhlen);
>  	if (putfh->pf_fhlen > NFS4_FHSIZE)
> -		goto xdr_error;
> +		XDR_ERROR();
>  	READ_BUF(putfh->pf_fhlen);
>  	SAVEMEM(putfh->pf_fhval, putfh->pf_fhlen);
>  
> @@ -1093,7 +1091,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  	READ64(write->wr_offset);
>  	READ32(write->wr_stable_how);
>  	if (write->wr_stable_how > 2)
> -		goto xdr_error;
> +		XDR_ERROR();
>  	READ32(write->wr_buflen);
>  
>  	/* Sorry .. no magic macros for this.. *
> @@ -1104,7 +1102,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  	if (avail + argp->pagelen < write->wr_buflen) {
>  		dprintk("NFSD: xdr error (%s:%d)\n",
>  				__FILE__, __LINE__);
> -		goto xdr_error;
> +		XDR_ERROR();
>  	}
>  	argp->rqstp->rq_vec[0].iov_base = p;
>  	argp->rqstp->rq_vec[0].iov_len = avail;
> @@ -1221,7 +1219,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  		READ32(dummy);
>  		break;
>  	default:
> -		goto xdr_error;
> +		XDR_ERROR();
>  	}
>  
>  	/* Ignore Implementation ID */
> @@ -1229,7 +1227,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  	READ32(dummy);
>  
>  	if (dummy > 1)
> -		goto xdr_error;
> +		XDR_ERROR();
>  
>  	if (dummy == 1) {
>  		/* nii_domain */
> @@ -1281,7 +1279,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  		READ32(sess->fore_channel.rdma_attrs);
>  	} else if (sess->fore_channel.nr_rdma_attrs > 1) {
>  		dprintk("Too many fore channel attr bitmaps!\n");
> -		goto xdr_error;
> +		XDR_ERROR();
>  	}
>  
>  	/* Back channel attrs */
> @@ -1298,7 +1296,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  		READ32(sess->back_channel.rdma_attrs);
>  	} else if (sess->back_channel.nr_rdma_attrs > 1) {
>  		dprintk("Too many back channel attr bitmaps!\n");
> -		goto xdr_error;
> +		XDR_ERROR();
>  	}
>  
>  	READ_BUF(8);
> @@ -1410,7 +1408,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  
>  	nbytes = test_stateid->ts_num_ids * sizeof(stateid_t);
>  	if (nbytes > (u32)((char *)argp->end - (char *)argp->p))
> -		goto xdr_error;
> +		XDR_ERROR();
>  
>  	test_stateid->ts_saved_args = argp;
>  	save_buf(argp, &test_stateid->ts_savedp);
> @@ -1588,16 +1586,16 @@ struct nfsd4_minorversion_ops {
>  	READ32(argp->opcnt);
>  
>  	if (argp->taglen > NFSD4_MAX_TAGLEN)
> -		goto xdr_error;
> +		XDR_ERROR();
>  	if (argp->opcnt > 100)
> -		goto xdr_error;
> +		XDR_ERROR();
>  
>  	if (argp->opcnt > ARRAY_SIZE(argp->iops)) {
>  		argp->ops = kmalloc(argp->opcnt * sizeof(*argp->ops), GFP_KERNEL);
>  		if (!argp->ops) {
>  			argp->ops = argp->iops;
>  			dprintk("nfsd: couldn't allocate room for COMPOUND\n");
> -			goto xdr_error;
> +			XDR_ERROR();
>  		}
>  	}
>  
> -- 
> 1.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
