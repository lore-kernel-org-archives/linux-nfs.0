Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64911 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449Ab3AWTHN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 14:07:13 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
CC: David Quigley <selinux@davequigley.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 07/14] NFSv4: Introduce new label structure
Date: Wed, 23 Jan 2013 19:07:10 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA918333550@sacexcmbx05-prd.hq.netapp.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
	 <1358862042-27520-8-git-send-email-steved@redhat.com>
In-Reply-To: <1358862042-27520-8-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
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
> ---
>  fs/nfs/inode.c          | 40 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/nfs4.h    |  8 ++++++++
>  include/linux/nfs_fs.h  | 14 ++++++++++++++
>  include/linux/nfs_xdr.h | 20 ++++++++++++++++++++
>  4 files changed, 82 insertions(+)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index ebeb94c..761bc17 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -255,6 +255,46 @@ nfs_init_locked(struct inode *inode, void *opaque)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +struct nfs4_label *nfs4_label_alloc(gfp_t flags)
> +{
> +	struct nfs4_label *label = NULL;
> +
> +	label = kzalloc(sizeof(struct nfs4_label) + NFS4_MAXLABELLEN, flags);
> +	if (label == NULL)
> +		return NULL;
> +
> +	label->label = (void *)(label + 1);

This is ugly. Why not use the more common construct of defining

struct nfs4_label {
	....
	char label[NFS4_MAXLABELLEN];
};

Also, note that if NFS4_MAXLABELLEN == 4096, then the actual allocation
above will result in an 8k memory slab being allocated. It would be nice
to shrink that. Do we really expect 4k label sizes?

> +	label->len = NFS4_MAXLABELLEN;
> +	/* 0 is the null format meaning that the data is not to be translated */
> +	label->lfs = 0;
> +	label->pi = 0;

If the label is allocated using kzalloc(), then the fields are trivially
initialised to '0'.

> +	return label;
> +}
> +EXPORT_SYMBOL_GPL(nfs4_label_alloc);
> +
> +void nfs4_label_init(struct nfs4_label *label)
> +{
> +	if (label && label->label) {
> +		*(unsigned char *)label->label = 0;
> +		label->len = NFS4_MAXLABELLEN;

Is this the length of the label or of the buffer? If the latter, do we
really need that, given that the size is a constant?

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
> index 1cc2568..f745f2c 100644
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
> +static inline void nfs4_label_init(void *label) {}
> +static inline void nfs4_label_free(void *label) {}
> +#endif
> +
> +/*
>   * linux/fs/nfs/unlink.c
>   */
>  extern void nfs_complete_unlink(struct dentry *dentry, struct inode *);
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index fac114d..0b79127 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -350,6 +350,7 @@ struct nfs_openargs {
>  	const u32 *		bitmask;
>  	const u32 *		open_bitmap;
>  	__u32			claim;
> +	const struct nfs4_label *label;
>  };
>  
>  struct nfs_openres {
> @@ -359,6 +360,7 @@ struct nfs_openres {
>  	struct nfs4_change_info	cinfo;
>  	__u32                   rflags;
>  	struct nfs_fattr *      f_attr;
> +	struct nfs4_label	*f_label;
>  	struct nfs_seqid *	seqid;
>  	const struct nfs_server *server;
>  	fmode_t			delegation_type;
> @@ -403,6 +405,7 @@ struct nfs_closeres {
>  	struct nfs4_sequence_res	seq_res;
>  	nfs4_stateid            stateid;
>  	struct nfs_fattr *	fattr;
> +	struct nfs4_label	*label;
>  	struct nfs_seqid *	seqid;
>  	const struct nfs_server *server;
>  };
> @@ -476,6 +479,7 @@ struct nfs4_delegreturnargs {
>  struct nfs4_delegreturnres {
>  	struct nfs4_sequence_res	seq_res;
>  	struct nfs_fattr * fattr;
> +	struct nfs4_label	*label;

Err... Is this needed? I couldn't find any code that uses it...

Ditto on most of the struct nfs4_*args declarations, and several of the
struct nfs4_*res too...

>  	const struct nfs_server *server;
>  };
>  
> @@ -496,6 +500,7 @@ struct nfs_readargs {
>  struct nfs_readres {
>  	struct nfs4_sequence_res	seq_res;
>  	struct nfs_fattr *	fattr;
> +	struct nfs4_label	*label;
>  	__u32			count;
>  	int                     eof;
>  };
> @@ -564,6 +569,7 @@ struct nfs_removeres {
>  	struct nfs4_sequence_res 	seq_res;
>  	const struct nfs_server *server;
>  	struct nfs_fattr	*dir_attr;
> +	struct nfs4_label	*dir_label;
>  	struct nfs4_change_info	cinfo;
>  };
>  
> @@ -576,6 +582,8 @@ struct nfs_renameargs {
>  	const struct nfs_fh		*new_dir;
>  	const struct qstr		*old_name;
>  	const struct qstr		*new_name;
> +	const struct nfs4_label		*old_label;
> +	const struct nfs4_label		*new_label;
>  };
>  
>  struct nfs_renameres {
> @@ -583,8 +591,10 @@ struct nfs_renameres {
>  	const struct nfs_server		*server;
>  	struct nfs4_change_info		old_cinfo;
>  	struct nfs_fattr		*old_fattr;
> +	struct nfs4_label		*old_label;
>  	struct nfs4_change_info		new_cinfo;
>  	struct nfs_fattr		*new_fattr;
> +	struct nfs4_label		*new_label;
>  };
>  
>  /*
> @@ -632,6 +642,7 @@ struct nfs_setattrargs {
>  	struct iattr *                  iap;
>  	const struct nfs_server *	server; /* Needed for name mapping */
>  	const u32 *			bitmask;
> +	const struct nfs4_label		*label;
>  };
>  
>  struct nfs_setaclargs {
> @@ -667,6 +678,7 @@ struct nfs_getaclres {
>  struct nfs_setattrres {
>  	struct nfs4_sequence_res	seq_res;
>  	struct nfs_fattr *              fattr;
> +	struct nfs4_label		*label;
>  	const struct nfs_server *	server;
>  };
>  
> @@ -712,6 +724,7 @@ struct nfs3_setaclargs {
>  struct nfs_diropok {
>  	struct nfs_fh *		fh;
>  	struct nfs_fattr *	fattr;
> +	struct nfs4_label	*label;
>  };
>  
>  struct nfs_readlinkargs {
> @@ -842,6 +855,7 @@ struct nfs4_accessres {
>  	struct nfs4_sequence_res	seq_res;
>  	const struct nfs_server *	server;
>  	struct nfs_fattr *		fattr;
> +	struct nfs4_label		*label;
>  	u32				supported;
>  	u32				access;
>  };
> @@ -864,6 +878,7 @@ struct nfs4_create_arg {
>  	const struct iattr *		attrs;
>  	const struct nfs_fh *		dir_fh;
>  	const u32 *			bitmask;
> +	const struct nfs4_label		*label;
>  };
>  
>  struct nfs4_create_res {
> @@ -871,6 +886,7 @@ struct nfs4_create_res {
>  	const struct nfs_server *	server;
>  	struct nfs_fh *			fh;
>  	struct nfs_fattr *		fattr;
> +	struct nfs4_label		*label;
>  	struct nfs4_change_info		dir_cinfo;
>  };
>  
> @@ -895,6 +911,7 @@ struct nfs4_getattr_res {
>  	struct nfs4_sequence_res	seq_res;
>  	const struct nfs_server *	server;
>  	struct nfs_fattr *		fattr;
> +	struct nfs4_label		*label;
>  };
>  
>  struct nfs4_link_arg {
> @@ -909,8 +926,10 @@ struct nfs4_link_res {
>  	struct nfs4_sequence_res	seq_res;
>  	const struct nfs_server *	server;
>  	struct nfs_fattr *		fattr;
> +	struct nfs4_label		*label;
>  	struct nfs4_change_info		cinfo;
>  	struct nfs_fattr *		dir_attr;
> +	struct nfs4_label		*dir_label;
>  };
>  
> 
> @@ -926,6 +945,7 @@ struct nfs4_lookup_res {
>  	const struct nfs_server *	server;
>  	struct nfs_fattr *		fattr;
>  	struct nfs_fh *			fh;
> +	struct nfs4_label		*label;
>  };
>  
>  struct nfs4_lookup_root_arg {

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
