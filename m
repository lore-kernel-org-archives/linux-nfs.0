Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37456 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752140Ab3BLWy1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 17:54:27 -0500
Date: Tue, 12 Feb 2013 17:54:25 -0500
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 14/15] NFSD: Server implementation of MAC Labeling
Message-ID: <20130212225425.GM10267@fieldses.org>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
 <1360327163-20360-15-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1360327163-20360-15-git-send-email-SteveD@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 08, 2013 at 07:39:22AM -0500, Steve Dickson wrote:
> From: David Quigley <dpquigl@davequigley.com>
> 
> This patch adds the ability to encode and decode file labels on the server for
> the purpose of sending them to the client and also to process label change
> requests from the client.
> 
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> ---
>  fs/nfsd/nfs4proc.c |  41 +++++++++++++++++++
>  fs/nfsd/nfs4xdr.c  | 116 ++++++++++++++++++++++++++++++++++++++++++++++++++---
>  fs/nfsd/nfsd.h     |   8 ++--
>  fs/nfsd/vfs.c      |  30 ++++++++++++++
>  fs/nfsd/vfs.h      |   2 +
>  fs/nfsd/xdr4.h     |   3 ++
>  6 files changed, 191 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 9d1c5db..898092d 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -42,6 +42,36 @@
>  #include "current_stateid.h"
>  #include "netns.h"
>  
> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> +#include <linux/security.h>
> +
> +static inline void
> +nfsd4_security_inode_setsecctx(struct svc_fh *resfh, struct nfs4_label *label, u32 *bmval)
> +{
> +	struct inode *inode = resfh->fh_dentry->d_inode;
> +	int status;
> +
> +	mutex_lock(&inode->i_mutex);
> +	status = security_inode_setsecctx(resfh->fh_dentry,
> +		label->label, label->len);
> +	mutex_unlock(&inode->i_mutex);
> +
> +	if (status)
> +		/*
> +		 * We should probably fail the whole open at this point,
> +		 * but we've already created or opened the file, so it's 
> +		 * too late; So this seems the least of evils:
> +		 */
> +		bmval[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
> +		
> +	return;
> +}
> +#else 
> +static inline void 
> +nfsd4_security_inode_setsecctx(struct svc_fh *resfh, struct nfs4_label *label, u32 *bmval)
> +{ }
> +#endif
> +
>  #define NFSDDBG_FACILITY		NFSDDBG_PROC
>  
>  static u32 nfsd_attrmask[] = {
> @@ -230,6 +260,9 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
>  					(u32 *)open->op_verf.data,
>  					&open->op_truncate, &open->op_created);
>  
> +		if (!status && open->op_label != NULL) 
> +			nfsd4_security_inode_setsecctx(resfh, open->op_label, open->op_bmval);
> +
>  		/*
>  		 * Following rfc 3530 14.2.16, use the returned bitmask
>  		 * to indicate which attributes we used to store the
> @@ -599,6 +632,9 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	if (status)
>  		goto out;
>  
> +	if (create->cr_label != NULL)
> +		nfsd4_security_inode_setsecctx(&resfh, create->cr_label, create->cr_bmval);
> +
>  	if (create->cr_acl != NULL)
>  		do_set_nfs4_acl(rqstp, &resfh, create->cr_acl,
>  				create->cr_bmval);
> @@ -888,6 +924,11 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  					    setattr->sa_acl);
>  	if (status)
>  		goto out;
> +	if (setattr->sa_label != NULL)
> +		status = nfsd4_set_nfs4_label(rqstp, &cstate->current_fh,
> +				setattr->sa_label);
> +	if (status)
> +		goto out;
>  	status = nfsd_setattr(rqstp, &cstate->current_fh, &setattr->sa_iattr,
>  				0, (time_t)0);
>  out:
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 0dc1158..0124b43 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -55,6 +55,11 @@
>  #include "cache.h"
>  #include "netns.h"
>  
> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> +#include <linux/security.h>
> +#endif
> +
> +
>  #define NFSDDBG_FACILITY		NFSDDBG_XDR
>  
>  /*
> @@ -242,7 +247,8 @@ nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
>  
>  static __be32
>  nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
> -		   struct iattr *iattr, struct nfs4_acl **acl)
> +		   struct iattr *iattr, struct nfs4_acl **acl,
> +		   struct nfs4_label **label)
>  {
>  	int expected_len, len = 0;
>  	u32 dummy32;
> @@ -386,6 +392,50 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  			goto xdr_error;
>  		}
>  	}
> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> +	if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
> +		uint32_t pi;
> +		uint32_t lfs;
> +
> +		READ_BUF(4);
> +		len += 4;
> +		READ32(lfs);
> +		READ_BUF(4);
> +		len += 4;
> +		READ32(pi);
> +		READ_BUF(4);
> +		len += 4;
> +		READ32(dummy32);
> +		READ_BUF(dummy32);
> +		len += (XDR_QUADLEN(dummy32) << 2);
> +		READMEM(buf, dummy32);
> +
> +		if (dummy32 > NFS4_MAXLABELLEN)
> +			return nfserr_resource;
> +
> +		*label = kzalloc(sizeof(struct nfs4_label), GFP_KERNEL);

So we don't want to allocate these the same way we did on the client?

> +		if (*label == NULL) {
> +			host_err = -ENOMEM;
> +			goto out_nfserr;
> +		}
> +
> +		(*label)->label = kmalloc(dummy32 + 1, GFP_KERNEL);
> +		if ((*label)->label == NULL) {
> +			host_err = -ENOMEM;
> +			kfree(*label);
> +			goto out_nfserr;
> +		}
> +
> +		(*label)->len = dummy32;
> +		memcpy((*label)->label, buf, dummy32);
> +		((char *)(*label)->label)[dummy32] = '\0';
> +		(*label)->pi = pi;
> +		(*label)->lfs = lfs;
> +
> +		defer_free(argp, kfree, (*label)->label);
> +		defer_free(argp, kfree, *label);

Hm: looking at defer_free and nfsd4_release_compoundargs: looks like
argp->to_free is effectively a stack, so these will get freed in the
reverse order: *label first, then (*label)->label.  That's trouble.

So, I think we want the order of those two defer_free()'s reversed.

Or we could just allocate the whole things as one chunk as on the client
and not have to worry about this kind of thing.  I think I'd prefer that
to trying to keep the allocation as small as possible.  We're only using
this memory temporarily so it's not as though we need to have tons of
struct nfs4_labels allocated at the same time anyway.

> +	}
> +#endif
>  	if (bmval[0] & ~NFSD_WRITEABLE_ATTRS_WORD0
>  	    || bmval[1] & ~NFSD_WRITEABLE_ATTRS_WORD1
>  	    || bmval[2] & ~NFSD_WRITEABLE_ATTRS_WORD2)
> @@ -575,7 +625,7 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
>  		return status;
>  
>  	status = nfsd4_decode_fattr(argp, create->cr_bmval, &create->cr_iattr,
> -				    &create->cr_acl);
> +				    &create->cr_acl, &create->cr_label);
>  	if (status)
>  		goto out;
>  
> @@ -825,7 +875,7 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
>  		case NFS4_CREATE_UNCHECKED:
>  		case NFS4_CREATE_GUARDED:
>  			status = nfsd4_decode_fattr(argp, open->op_bmval,
> -				&open->op_iattr, &open->op_acl);
> +				&open->op_iattr, &open->op_acl, &open->op_label);
>  			if (status)
>  				goto out;
>  			break;
> @@ -839,7 +889,7 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
>  			READ_BUF(NFS4_VERIFIER_SIZE);
>  			COPYMEM(open->op_verf.data, NFS4_VERIFIER_SIZE);
>  			status = nfsd4_decode_fattr(argp, open->op_bmval,
> -				&open->op_iattr, &open->op_acl);
> +				&open->op_iattr, &open->op_acl, &open->op_label);
>  			if (status)
>  				goto out;
>  			break;
> @@ -1061,7 +1111,7 @@ nfsd4_decode_setattr(struct nfsd4_compoundargs *argp, struct nfsd4_setattr *seta
>  	if (status)
>  		return status;
>  	return nfsd4_decode_fattr(argp, setattr->sa_bmval, &setattr->sa_iattr,
> -				  &setattr->sa_acl);
> +				  &setattr->sa_acl, &setattr->sa_label);
>  }
>  
>  static __be32
> @@ -1970,6 +2020,50 @@ nfsd4_encode_aclname(struct svc_rqst *rqstp, int whotype, uid_t id, int group,
>  			      FATTR4_WORD0_RDATTR_ERROR)
>  #define WORD1_ABSENT_FS_ATTRS FATTR4_WORD1_MOUNTED_ON_FILEID
>  
> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> +static inline __be32
> +nfsd4_encode_security_label(struct svc_rqst *rqstp, struct dentry *dentry, __be32 **pp, int *buflen)
> +{
> +	void *context;
> +	int err;
> +	int len;
> +	uint32_t pi = 0;
> +	uint32_t lfs = 0;
> +	__be32 *p = *pp;
> +
> +	err = 0;
> +	(void)security_inode_getsecctx(dentry->d_inode, &context, &len);
> +	if (len < 0)
> +		return nfserrno(len);
> +
> +	if (*buflen < ((XDR_QUADLEN(len) << 2) + 4 + 4 + 4)) {
> +		err = nfserr_resource;
> +		goto out;
> +	}
> +
> +	/* XXX: A call to the translation code should be placed here
> +	 * for now send 0  until we have that to indicate the null
> +	 * translation */ 
> +
> +	if ((*buflen -= 4) < 0)
> +		return nfserr_resource;
> +
> +	WRITE32(lfs);	
> +	WRITE32(pi);
> +	p = xdr_encode_opaque(p, context, len);
> +	*buflen -= (XDR_QUADLEN(len) << 2) + 4;
> +
> +	*pp = p;
> +out:
> +	security_release_secctx(context, len);
> +	return err;
> +}
> +#else
> +static inline __be32
> +nfsd4_encode_security_label(struct svc_rqst *rqstp, struct dentry *dentry, __be32 **pp, int *buflen)
> +{ return 0; }
> +#endif
> +
>  static __be32 fattr_handle_absent_fs(u32 *bmval0, u32 *bmval1, u32 *rdattr_err)
>  {
>  	/* As per referral draft:  */
> @@ -2111,6 +2205,10 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>  
>  		if (!aclsupport)
>  			word0 &= ~FATTR4_WORD0_ACL;
> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> +		if (word2)
> +			word2 |= FATTR4_WORD2_SECURITY_LABEL;
> +#endif

Please just fix the definition of NFSD4_1_SUPPORTED_ATTRS_WORD2.  (The
ifdef can go in that definition.)

Although: don't we need to check whether the exported filesystem
supports security labels?

>  		if (!word2) {
>  			if ((buflen -= 12) < 0)
>  				goto out_resource;
> @@ -2423,6 +2521,14 @@ out_acl:
>  			get_parent_attributes(exp, &stat);
>  		WRITE64(stat.ino);
>  	}
> +	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
> +		status = nfsd4_encode_security_label(rqstp, dentry,
> +				&p, &buflen);
> +		if (status == nfserr_resource)
> +			goto out_resource;

Just remove that, there's no real point to the out_resource goto.

> +		if (status)
> +			goto out;

> +	}
>  	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
>  		WRITE32(3);
>  		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index de23db2..727fe44 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -308,10 +308,10 @@ void		nfsd_lockd_shutdown(void);
>   | FATTR4_WORD1_OWNER	        | FATTR4_WORD1_OWNER_GROUP  | FATTR4_WORD1_RAWDEV           \
>   | FATTR4_WORD1_SPACE_AVAIL     | FATTR4_WORD1_SPACE_FREE   | FATTR4_WORD1_SPACE_TOTAL      \
>   | FATTR4_WORD1_SPACE_USED      | FATTR4_WORD1_TIME_ACCESS  | FATTR4_WORD1_TIME_ACCESS_SET  \
> - | FATTR4_WORD1_TIME_DELTA   | FATTR4_WORD1_TIME_METADATA    \
> - | FATTR4_WORD1_TIME_MODIFY     | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_MOUNTED_ON_FILEID)
> + | FATTR4_WORD1_TIME_DELTA	| FATTR4_WORD1_TIME_METADATA | FATTR4_WORD1_TIME_MODIFY     \
> + | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_MOUNTED_ON_FILEID)

Did that actually change anything?  If not, just leave the formatting
alone.

>  
> -#define NFSD4_SUPPORTED_ATTRS_WORD2 0
> +#define NFSD4_SUPPORTED_ATTRS_WORD2 FATTR4_WORD2_SECURITY_LABEL

That should be conditional on CONFIG_NFSD_V4_SECURITY_LABEL, shouldn't
it?

>  
>  #define NFSD4_1_SUPPORTED_ATTRS_WORD0 \
>  	NFSD4_SUPPORTED_ATTRS_WORD0
> @@ -350,7 +350,7 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
>  #define NFSD_WRITEABLE_ATTRS_WORD1 \
>  	(FATTR4_WORD1_MODE | FATTR4_WORD1_OWNER | FATTR4_WORD1_OWNER_GROUP \
>  	| FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
> -#define NFSD_WRITEABLE_ATTRS_WORD2 0
> +#define NFSD_WRITEABLE_ATTRS_WORD2 FATTR4_WORD2_SECURITY_LABEL
>  
>  #define NFSD_SUPPATTR_EXCLCREAT_WORD0 \
>  	NFSD_WRITEABLE_ATTRS_WORD0
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index d586117..0567fdc 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -28,6 +28,7 @@
>  #include <asm/uaccess.h>
>  #include <linux/exportfs.h>
>  #include <linux/writeback.h>
> +#include <linux/security.h>
>  
>  #ifdef CONFIG_NFSD_V3
>  #include "xdr3.h"
> @@ -621,6 +622,35 @@ int nfsd4_is_junction(struct dentry *dentry)
>  		return 0;
>  	return 1;
>  }
> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> +__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +		struct nfs4_label *label)
> +{
> +	__be32 error;
> +	int host_error;
> +	struct dentry *dentry;
> +
> +	/* Get inode */

That comment's unnecessary.

> +	/* XXX: should we have a MAY_SSECCTX? */

I don't know, should we?

--b.

> +	error = fh_verify(rqstp, fhp, 0 /* S_IFREG */, NFSD_MAY_SATTR);
> +	if (error)
> +		return error;
> +
> +	dentry = fhp->fh_dentry;
> +
> +	mutex_lock(&dentry->d_inode->i_mutex);
> +	host_error = security_inode_setsecctx(dentry, label->label, label->len);
> +	mutex_unlock(&dentry->d_inode->i_mutex);
> +	return nfserrno(host_error);
> +}
> +#else
> +__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +		struct nfs4_label *label)
> +{
> +	return -EOPNOTSUPP;
> +}
> +#endif
> +
>  #endif /* defined(CONFIG_NFSD_V4) */
>  
>  #ifdef CONFIG_NFSD_V3
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index 359594c..49c6cc0 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -55,6 +55,8 @@ int nfsd_mountpoint(struct dentry *, struct svc_export *);
>  __be32          nfsd4_set_nfs4_acl(struct svc_rqst *, struct svc_fh *,
>                      struct nfs4_acl *);
>  int             nfsd4_get_nfs4_acl(struct svc_rqst *, struct dentry *, struct nfs4_acl **);
> +__be32          nfsd4_set_nfs4_label(struct svc_rqst *, struct svc_fh *,
> +		    struct nfs4_label *);
>  #endif /* CONFIG_NFSD_V4 */
>  __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
>  				char *name, int len, struct iattr *attrs,
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 0889bfb..9e7e663 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -118,6 +118,7 @@ struct nfsd4_create {
>  	struct iattr	cr_iattr;           /* request */
>  	struct nfsd4_change_info  cr_cinfo; /* response */
>  	struct nfs4_acl *cr_acl;
> +	struct nfs4_label *cr_label;
>  };
>  #define cr_linklen	u.link.namelen
>  #define cr_linkname	u.link.name
> @@ -246,6 +247,7 @@ struct nfsd4_open {
>  	struct nfs4_file *op_file;          /* used during processing */
>  	struct nfs4_ol_stateid *op_stp;	    /* used during processing */
>  	struct nfs4_acl *op_acl;
> +	struct nfs4_label *op_label;
>  };
>  #define op_iattr	iattr
>  
> @@ -330,6 +332,7 @@ struct nfsd4_setattr {
>  	u32		sa_bmval[3];        /* request */
>  	struct iattr	sa_iattr;           /* request */
>  	struct nfs4_acl *sa_acl;
> +	struct nfs4_label *sa_label;
>  };
>  
>  struct nfsd4_setclientid {
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
