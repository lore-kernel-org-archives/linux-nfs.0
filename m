Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42313 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753230Ab2KLPNT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Nov 2012 10:13:19 -0500
Date: Mon, 12 Nov 2012 10:13:14 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: David Quigley <dpquigl@davequigley.com>
Cc: trond.myklebust@netapp.com, sds@tycho.nsa.gov, linux-nfs@vger.kernel.org,
        selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
        "Matthew N. Dodd" <Matthew.Dodd@sparta.com>,
        Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>,
        Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>,
        Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
Subject: Re: [PATCH 07/13] NFSv4: Introduce new label structure
Message-ID: <20121112151314.GG30713@fieldses.org>
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
 <1352700947-3915-8-git-send-email-dpquigl@davequigley.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1352700947-3915-8-git-send-email-dpquigl@davequigley.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 12, 2012 at 01:15:41AM -0500, David Quigley wrote:
> From: David Quigley <dpquigl@davequigley.com>
> 
> In order to mimic the way that NFSv4 ACLs are implemented we have created a
> structure to be used to pass label data up and down the call chain. This patch
> adds the new structure and new members to the required NFSv4 call structures.
> 
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
> Signed-off-by: David Quigley <dpquigl@davequigley.com>
> ---
>  fs/nfs/inode.c          | 40 ++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/xdr4.h          |  3 +++
>  include/linux/nfs4.h    |  8 ++++++++
>  include/linux/nfs_fs.h  | 14 ++++++++++++++
>  include/linux/nfs_xdr.h | 20 ++++++++++++++++++++
>  5 files changed, 85 insertions(+)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 5c7325c..0963ad9 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -246,6 +246,46 @@ nfs_init_locked(struct inode *inode, void *opaque)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +struct nfs4_label *nfs4_label_alloc(gfp_t flags)
> +{
> +	struct nfs4_label *label = NULL;
> +
> +	label = kzalloc(sizeof(struct nfs4_label) + NFS4_MAXLABELLEN, flags);

NFS4_MAXLABELLEN is 4096, but we usually try to avoid allocating more
than that in a single allocation.

> +	if (label == NULL)
> +		return NULL;
> +
> +	label->label = (void *)(label + 1);
> +	label->len = NFS4_MAXLABELLEN;
> +	/* 0 is the null format meaning that the data is not to be translated */
> +	label->lfs = 0;
> +	label->pi = 0;

What's "pi"?

--b.

> +	return label;
> +}
> +EXPORT_SYMBOL_GPL(nfs4_label_alloc);
> +
> +void nfs4_label_init(struct nfs4_label *label)
> +{
> +	if (label && label->label) {
> +		*(unsigned char *)label->label = 0;
> +		label->len = NFS4_MAXLABELLEN;
> +		/* 0 is the null format meaning that the data is not
> +		to be translated */
> +		label->lfs = 0;
> +		label->pi = 0;
> +	}
> +	return;
> +}
> +EXPORT_SYMBOL_GPL(nfs4_label_init);
> +
> +void nfs4_label_free(struct nfs4_label *label)
> +{
> +	kfree(label);
> +	return;
> +}
> +EXPORT_SYMBOL_GPL(nfs4_label_free);
> +#endif
> +
>  /*
>   * This is our front-end to iget that looks up inodes by file handle
>   * instead of inode number.
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index acd127d..ca8f30b 100644
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
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index f9235b4..862471f 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -28,6 +28,14 @@ struct nfs4_acl {
>  	struct nfs4_ace	aces[0];
>  };
>  
> +struct nfs4_label {
> +	uint32_t	lfs;
> +	uint32_t	pi;
> +	u32		len;
> +	void		*label;
> +};
> +
> +
>  typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
>  
>  struct nfs_stateid4 {
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 1cc2568..37a862c 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -489,6 +489,20 @@ extern int nfs_mountpoint_expiry_timeout;
>  extern void nfs_release_automount_timer(void);
>  
>  /*
> + * linux/fs/nfs/nfs4proc.c
> + */
> +
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +extern struct nfs4_label *nfs4_label_alloc(gfp_t flags);
> +extern void nfs4_label_init(struct nfs4_label *);
> +extern void nfs4_label_free(struct nfs4_label *);
> +#else
> +static inline struct nfs4_label *nfs4_label_alloc(gfp_t flags) { return NULL; }
> +static inline void nfs4_label_init(struct nfs4_label *) {}
> +static inline void nfs4_label_free(struct nfs4_label *label) {}
> +#endif
> +
> +/*
>   * linux/fs/nfs/unlink.c
>   */
>  extern void nfs_complete_unlink(struct dentry *dentry, struct inode *);
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index a0669d3..7e9347a 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -352,6 +352,7 @@ struct nfs_openargs {
>  	const u32 *		bitmask;
>  	const u32 *		open_bitmap;
>  	__u32			claim;
> +	const struct nfs4_label *label;
>  	struct nfs4_sequence_args	seq_args;
>  };
>  
> @@ -361,6 +362,7 @@ struct nfs_openres {
>  	struct nfs4_change_info	cinfo;
>  	__u32                   rflags;
>  	struct nfs_fattr *      f_attr;
> +	struct nfs4_label	*f_label;
>  	struct nfs_seqid *	seqid;
>  	const struct nfs_server *server;
>  	fmode_t			delegation_type;
> @@ -405,6 +407,7 @@ struct nfs_closeargs {
>  struct nfs_closeres {
>  	nfs4_stateid            stateid;
>  	struct nfs_fattr *	fattr;
> +	struct nfs4_label	*label;
>  	struct nfs_seqid *	seqid;
>  	const struct nfs_server *server;
>  	struct nfs4_sequence_res	seq_res;
> @@ -478,6 +481,7 @@ struct nfs4_delegreturnargs {
>  
>  struct nfs4_delegreturnres {
>  	struct nfs_fattr * fattr;
> +	struct nfs4_label	*label;
>  	const struct nfs_server *server;
>  	struct nfs4_sequence_res	seq_res;
>  };
> @@ -498,6 +502,7 @@ struct nfs_readargs {
>  
>  struct nfs_readres {
>  	struct nfs_fattr *	fattr;
> +	struct nfs4_label	*label;
>  	__u32			count;
>  	int                     eof;
>  	struct nfs4_sequence_res	seq_res;
> @@ -566,6 +571,7 @@ struct nfs_removeargs {
>  struct nfs_removeres {
>  	const struct nfs_server *server;
>  	struct nfs_fattr	*dir_attr;
> +	struct nfs4_label	*dir_label;
>  	struct nfs4_change_info	cinfo;
>  	struct nfs4_sequence_res 	seq_res;
>  };
> @@ -578,6 +584,8 @@ struct nfs_renameargs {
>  	const struct nfs_fh		*new_dir;
>  	const struct qstr		*old_name;
>  	const struct qstr		*new_name;
> +	const struct nfs4_label		*old_label;
> +	const struct nfs4_label		*new_label;
>  	struct nfs4_sequence_args	seq_args;
>  };
>  
> @@ -585,8 +593,10 @@ struct nfs_renameres {
>  	const struct nfs_server		*server;
>  	struct nfs4_change_info		old_cinfo;
>  	struct nfs_fattr		*old_fattr;
> +	struct nfs4_label		*old_label;
>  	struct nfs4_change_info		new_cinfo;
>  	struct nfs_fattr		*new_fattr;
> +	struct nfs4_label		*new_label;
>  	struct nfs4_sequence_res	seq_res;
>  };
>  
> @@ -634,6 +644,7 @@ struct nfs_setattrargs {
>  	struct iattr *                  iap;
>  	const struct nfs_server *	server; /* Needed for name mapping */
>  	const u32 *			bitmask;
> +	const struct nfs4_label		*label;
>  	struct nfs4_sequence_args 	seq_args;
>  };
>  
> @@ -669,6 +680,7 @@ struct nfs_getaclres {
>  
>  struct nfs_setattrres {
>  	struct nfs_fattr *              fattr;
> +	struct nfs4_label		*label;
>  	const struct nfs_server *	server;
>  	struct nfs4_sequence_res	seq_res;
>  };
> @@ -715,6 +727,7 @@ struct nfs3_setaclargs {
>  struct nfs_diropok {
>  	struct nfs_fh *		fh;
>  	struct nfs_fattr *	fattr;
> +	struct nfs4_label	*label;
>  };
>  
>  struct nfs_readlinkargs {
> @@ -844,6 +857,7 @@ struct nfs4_accessargs {
>  struct nfs4_accessres {
>  	const struct nfs_server *	server;
>  	struct nfs_fattr *		fattr;
> +	struct nfs4_label		*label;
>  	u32				supported;
>  	u32				access;
>  	struct nfs4_sequence_res	seq_res;
> @@ -866,6 +880,7 @@ struct nfs4_create_arg {
>  	const struct iattr *		attrs;
>  	const struct nfs_fh *		dir_fh;
>  	const u32 *			bitmask;
> +	const struct nfs4_label		*label;
>  	struct nfs4_sequence_args 	seq_args;
>  };
>  
> @@ -873,6 +888,7 @@ struct nfs4_create_res {
>  	const struct nfs_server *	server;
>  	struct nfs_fh *			fh;
>  	struct nfs_fattr *		fattr;
> +	struct nfs4_label		*label;
>  	struct nfs4_change_info		dir_cinfo;
>  	struct nfs4_sequence_res	seq_res;
>  };
> @@ -898,6 +914,7 @@ struct nfs4_getattr_res {
>  	const struct nfs_server *	server;
>  	struct nfs_fattr *		fattr;
>  	struct nfs4_sequence_res	seq_res;
> +	struct nfs4_label		*label;
>  };
>  
>  struct nfs4_link_arg {
> @@ -911,8 +928,10 @@ struct nfs4_link_arg {
>  struct nfs4_link_res {
>  	const struct nfs_server *	server;
>  	struct nfs_fattr *		fattr;
> +	struct nfs4_label		*label;
>  	struct nfs4_change_info		cinfo;
>  	struct nfs_fattr *		dir_attr;
> +	struct nfs4_label		*dir_label;
>  	struct nfs4_sequence_res	seq_res;
>  };
>  
> @@ -928,6 +947,7 @@ struct nfs4_lookup_res {
>  	const struct nfs_server *	server;
>  	struct nfs_fattr *		fattr;
>  	struct nfs_fh *			fh;
> +	struct nfs4_label		*label;
>  	struct nfs4_sequence_res	seq_res;
>  };
>  
> -- 
> 1.7.11.7
> 
