Return-Path: <SRS0=QdOa=QZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1662C10F01
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 19:32:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9BAE8217F9
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 19:32:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725939AbfBRTcT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 14:32:19 -0500
Received: from fieldses.org ([173.255.197.46]:45258 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726191AbfBRTcT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Feb 2019 14:32:19 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 7AC14957; Mon, 18 Feb 2019 14:32:18 -0500 (EST)
Date:   Mon, 18 Feb 2019 14:32:18 -0500
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Subject: Re: [PATCH RFC 4/4] NFSD: Prototype support for IMA on NFS (server)
Message-ID: <20190218193218.GA5879@fieldses.org>
References: <20190214203336.6469.34750.stgit@manet.1015granger.net>
 <20190214204326.6469.25843.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214204326.6469.25843.stgit@manet.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Feb 14, 2019 at 03:43:26PM -0500, Chuck Lever wrote:
> When NFSv4 Security Label support is enabled and kernel Integrity
> and IMA support is enabled (via CONFIG), then build in code to
> handle the "security.ima" xattr. The NFS server converts incoming
> GETATTR and SETATTR calls to acesses and updates of the xattr.
> 
> The FATTR4 bit is made up; meaning we still have to go through a
> standards process to allocate a bit that all NFS vendors agree on.
> Thus there is no guarantee this prototype will interoperate with
> others or with a future standards-based implementation.

Why the dependence on CONFIG_NFSD_V4_SECURITY_LABEL?

(Also, I wonder if we actually need CONFIG_NFSD_V4_SECURITY_LABEL or if
we could just remove it, or replace it by CONFIG_SECURITY where
necessary.)

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/nfs4proc.c |   15 ++++++++++++++
>  fs/nfsd/nfs4xdr.c  |   54 ++++++++++++++++++++++++++++++++++++++++++++++------
>  fs/nfsd/nfsd.h     |   10 ++++++++++
>  fs/nfsd/vfs.c      |   32 +++++++++++++++++++++++++++++++
>  fs/nfsd/vfs.h      |    3 +++
>  fs/nfsd/xdr4.h     |    3 +++
>  fs/xattr.c         |    3 ++-
>  7 files changed, 113 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 0cfd257..ad205f9 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -106,6 +106,10 @@
>  	if ((bmval[2] & FATTR4_WORD2_SECURITY_LABEL) &&
>  			!(exp->ex_flags & NFSEXP_SECURITY_LABEL))
>  		return nfserr_attrnotsupp;
> +#ifndef CONFIG_IMA
> +	if (bmval[2] & FATTR4_WORD2_LINUX_IMA)
> +		return nfserr_attrnotsupp;
> +#endif
>  	if (writable && !bmval_is_subset(bmval, writable))
>  		return nfserr_inval;
>  	if (writable && (bmval[2] & FATTR4_WORD2_MODE_UMASK) &&
> @@ -979,6 +983,11 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
>  				&setattr->sa_label);
>  	if (status)
>  		goto out;
> +	if (setattr->sa_ima.len)
> +		status = nfsd4_set_ima_metadata(rqstp, &cstate->current_fh,
> +						&setattr->sa_ima);
> +	if (status)
> +		goto out;
>  	status = nfsd_setattr(rqstp, &cstate->current_fh, &setattr->sa_iattr,
>  				0, (time_t)0);
>  out:
> @@ -2135,6 +2144,12 @@ static inline u32 nfsd4_getattr_rsize(struct svc_rqst *rqstp,
>  		ret += NFS4_MAXLABELLEN + 12;
>  		bmap2 &= ~FATTR4_WORD2_SECURITY_LABEL;
>  	}
> +#ifdef CONFIG_IMA
> +	if (bmap2 & FATTR4_WORD2_LINUX_IMA) {
> +		ret += NFS4_MAXIMALEN + 4;
> +		bmap2 &= ~FATTR4_WORD2_LINUX_IMA;
> +	}
> +#endif
>  	/*
>  	 * Largest of remaining attributes are 16 bytes (e.g.,
>  	 * supported_attributes)
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 3de42a7..19e9f25 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -39,6 +39,7 @@
>  #include <linux/statfs.h>
>  #include <linux/utsname.h>
>  #include <linux/pagemap.h>
> +#include <linux/xattr.h>
>  #include <linux/sunrpc/svcauth_gss.h>
>  
>  #include "idmap.h"
> @@ -318,7 +319,8 @@ static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
>  static __be32
>  nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  		   struct iattr *iattr, struct nfs4_acl **acl,
> -		   struct xdr_netobj *label, int *umask)
> +		   struct xdr_netobj *label, int *umask,
> +		   struct xdr_netobj *ima)
>  {
>  	struct timespec ts;
>  	int expected_len, len = 0;
> @@ -455,7 +457,6 @@ static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
>  			goto xdr_error;
>  		}
>  	}
> -
>  	label->len = 0;
>  	if (IS_ENABLED(CONFIG_NFSD_V4_SECURITY_LABEL) &&
>  	    bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
> @@ -489,6 +490,23 @@ static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
>  		*umask = dummy32 & S_IRWXUGO;
>  		iattr->ia_valid |= ATTR_MODE;
>  	}
> +#if defined(CONFIG_NFSD_V4_SECURITY_LABEL) && defined(CONFIG_IMA)
> +	ima->len = 0;
> +	if (bmval[2] & FATTR4_WORD2_LINUX_IMA) {
> +		READ_BUF(4);
> +		len += 4;
> +		dummy32 = be32_to_cpup(p++);
> +		READ_BUF(dummy32);
> +		if (dummy32 > NFS4_MAXIMALEN)
> +			return nfserr_badlabel;
> +		len += (XDR_QUADLEN(dummy32) << 2);
> +		READMEM(buf, dummy32);
> +		ima->len = dummy32;
> +		ima->data = svcxdr_dupstr(argp, buf, dummy32);
> +		if (!ima->data)
> +			return nfserr_jukebox;
> +	}
> +#endif
>  	if (len != expected_len)
>  		goto xdr_error;
>  
> @@ -684,7 +702,7 @@ static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp,
>  
>  	status = nfsd4_decode_fattr(argp, create->cr_bmval, &create->cr_iattr,
>  				    &create->cr_acl, &create->cr_label,
> -				    &create->cr_umask);
> +				    &create->cr_umask, &create->cr_ima);
>  	if (status)
>  		goto out;
>  
> @@ -936,7 +954,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  		case NFS4_CREATE_GUARDED:
>  			status = nfsd4_decode_fattr(argp, open->op_bmval,
>  				&open->op_iattr, &open->op_acl, &open->op_label,
> -				&open->op_umask);
> +				&open->op_umask, &open->op_ima);
>  			if (status)
>  				goto out;
>  			break;
> @@ -951,7 +969,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  			COPYMEM(open->op_verf.data, NFS4_VERIFIER_SIZE);
>  			status = nfsd4_decode_fattr(argp, open->op_bmval,
>  				&open->op_iattr, &open->op_acl, &open->op_label,
> -				&open->op_umask);
> +				&open->op_umask, &open->op_ima);
>  			if (status)
>  				goto out;
>  			break;
> @@ -1188,7 +1206,8 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  	if (status)
>  		return status;
>  	return nfsd4_decode_fattr(argp, setattr->sa_bmval, &setattr->sa_iattr,
> -				  &setattr->sa_acl, &setattr->sa_label, NULL);
> +				  &setattr->sa_acl, &setattr->sa_label, NULL,
> +				  &setattr->sa_ima);
>  }
>  
>  static __be32
> @@ -2430,6 +2449,7 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
>  		.dentry	= dentry,
>  	};
>  	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
> +	struct xdr_netobj ima = { 0, NULL };
>  
>  	BUG_ON(bmval1 & NFSD_WRITEONLY_ATTRS_WORD1);
>  	BUG_ON(!nfsd_attrs_supported(minorversion, bmval));
> @@ -2489,6 +2509,16 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
>  				goto out_nfserr;
>  		}
>  	}
> +	if (bmval2 & FATTR4_WORD2_LINUX_IMA) {
> +		err = vfs_getxattr_alloc(dentry, XATTR_NAME_IMA,
> +					 (char **)&ima.data, 0,
> +					 GFP_KERNEL);
> +		if (err == -ENODATA)
> +			bmval2 &= ~FATTR4_WORD2_LINUX_IMA;
> +		else if (err < 0)
> +			goto out_nfserr;
> +		ima.len = err;
> +	}
>  #endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
>  
>  	status = nfsd4_encode_bitmap(xdr, bmval0, bmval1, bmval2);
> @@ -2510,6 +2540,9 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
>  			supp[0] &= ~FATTR4_WORD0_ACL;
>  		if (!contextsupport)
>  			supp[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
> +#ifndef CONFIG_IMA
> +		supp[2] &= ~FATTR4_WORD2_LINUX_IMA;
> +#endif
>  		if (!supp[2]) {
>  			p = xdr_reserve_space(xdr, 12);
>  			if (!p)
> @@ -2913,6 +2946,14 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
>  			goto out;
>  	}
>  
> +	if (bmval2 & FATTR4_WORD2_LINUX_IMA) {
> +		p = xdr_reserve_space(xdr, sizeof(__be32) +
> +				      xdr_align_size(ima.len));
> +		if (!p)
> +			goto out_resource;
> +		xdr_encode_netobj(p, &ima);
> +	}
> +
>  	attrlen = htonl(xdr->buf->len - attrlen_offset - 4);
>  	write_bytes_to_xdr_buf(xdr->buf, attrlen_offset, &attrlen, 4);
>  	status = nfs_ok;
> @@ -2922,6 +2963,7 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
>  	if (context)
>  		security_release_secctx(context, contextlen);
>  #endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
> +	kfree(ima.data);
>  	kfree(acl);
>  	if (tempfh) {
>  		fh_put(tempfh);
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index 0668999..93be978 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -353,7 +353,12 @@ static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
>  
>  /* 4.2 */
>  #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> +#ifdef CONFIG_IMA
> +#define NFSD4_2_SECURITY_ATTRS \
> +	(FATTR4_WORD2_SECURITY_LABEL	| FATTR4_WORD2_LINUX_IMA)
> +#else
>  #define NFSD4_2_SECURITY_ATTRS		FATTR4_WORD2_SECURITY_LABEL
> +#endif
>  #else
>  #define NFSD4_2_SECURITY_ATTRS		0
>  #endif
> @@ -393,8 +398,13 @@ static inline bool nfsd_attrs_supported(u32 minorversion, const u32 *bmval)
>  	(FATTR4_WORD1_MODE | FATTR4_WORD1_OWNER | FATTR4_WORD1_OWNER_GROUP \
>  	| FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
>  #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> +#ifdef CONFIG_IMA
> +#define MAYBE_FATTR4_WORD2_SECURITY_LABEL \
> +	(FATTR4_WORD2_SECURITY_LABEL | FATTR4_WORD2_LINUX_IMA)
> +#else
>  #define MAYBE_FATTR4_WORD2_SECURITY_LABEL \
>  	FATTR4_WORD2_SECURITY_LABEL
> +#endif
>  #else
>  #define MAYBE_FATTR4_WORD2_SECURITY_LABEL 0
>  #endif
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 7dc98e1..159b0fc 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -543,12 +543,44 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	inode_unlock(d_inode(dentry));
>  	return nfserrno(host_error);
>  }
> +
> +#ifdef CONFIG_IMA
> +__be32 nfsd4_set_ima_metadata(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +			      struct xdr_netobj *ima)
> +{
> +	struct dentry *dentry;
> +	int host_error;
> +	__be32 error;
> +
> +	error = fh_verify(rqstp, fhp, 0 /* S_IFREG */, NFSD_MAY_SATTR);
> +	if (error)
> +		return error;
> +	dentry = fhp->fh_dentry;
> +
> +	inode_lock(d_inode(dentry));
> +	host_error = __vfs_setxattr_noperm(dentry, XATTR_NAME_IMA,
> +					   ima->data, ima->len, 0);
> +	inode_unlock(d_inode(dentry));
> +	return nfserrno(host_error);
> +}
> +#else
> +__be32 nfsd4_set_ima_metadata(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +			      struct xdr_netobj *ima)
> +{
> +	return nfserr_notsupp;
> +}
> +#endif
>  #else
>  __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		struct xdr_netobj *label)
>  {
>  	return nfserr_notsupp;
>  }
> +__be32 nfsd4_set_ima_metadata(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +			      struct xdr_netobj *ima)
> +{
> +	return nfserr_notsupp;
> +}
>  #endif
>  
>  __be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index a7e1073..acfc2b0 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -55,6 +55,9 @@ __be32		nfsd_setattr(struct svc_rqst *, struct svc_fh *,
>  #ifdef CONFIG_NFSD_V4
>  __be32          nfsd4_set_nfs4_label(struct svc_rqst *, struct svc_fh *,
>  		    struct xdr_netobj *);
> +__be32		nfsd4_set_ima_metadata(struct svc_rqst *rqstp,
> +				       struct svc_fh *fhp,
> +				       struct xdr_netobj *ima);
>  __be32		nfsd4_vfs_fallocate(struct svc_rqst *, struct svc_fh *,
>  				    struct file *, loff_t, loff_t, int);
>  __be32		nfsd4_clone_file_range(struct file *, u64, struct file *,
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index feeb6d4..2f3307f 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -123,6 +123,7 @@ struct nfsd4_create {
>  	struct nfsd4_change_info  cr_cinfo; /* response */
>  	struct nfs4_acl *cr_acl;
>  	struct xdr_netobj cr_label;
> +	struct xdr_netobj cr_ima;
>  };
>  #define cr_datalen	u.link.datalen
>  #define cr_data		u.link.data
> @@ -255,6 +256,7 @@ struct nfsd4_open {
>  	struct nfs4_clnt_odstate *op_odstate; /* used during processing */
>  	struct nfs4_acl *op_acl;
>  	struct xdr_netobj op_label;
> +	struct xdr_netobj op_ima;
>  };
>  
>  struct nfsd4_open_confirm {
> @@ -339,6 +341,7 @@ struct nfsd4_setattr {
>  	struct iattr	sa_iattr;           /* request */
>  	struct nfs4_acl *sa_acl;
>  	struct xdr_netobj sa_label;
> +	struct xdr_netobj sa_ima;
>  };
>  
>  struct nfsd4_setclientid {
> diff --git a/fs/xattr.c b/fs/xattr.c
> index 0d6a6a4..fbbb021 100644
> --- a/fs/xattr.c
> +++ b/fs/xattr.c
> @@ -202,7 +202,7 @@ int __vfs_setxattr_noperm(struct dentry *dentry, const char *name,
>  
>  	return error;
>  }
> -
> +EXPORT_SYMBOL_GPL(__vfs_setxattr_noperm);
>  
>  int
>  vfs_setxattr(struct dentry *dentry, const char *name, const void *value,
> @@ -295,6 +295,7 @@ int __vfs_setxattr_noperm(struct dentry *dentry, const char *name,
>  	*xattr_value = value;
>  	return error;
>  }
> +EXPORT_SYMBOL_GPL(vfs_getxattr_alloc);
>  
>  ssize_t
>  __vfs_getxattr(struct dentry *dentry, struct inode *inode, const char *name,
