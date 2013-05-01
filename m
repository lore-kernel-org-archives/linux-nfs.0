Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:52295 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755455Ab3EAS73 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 May 2013 14:59:29 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        "Linux FS devel list" <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 09/17] NFSv4: Introduce new label structure
Date: Wed, 1 May 2013 18:59:24 +0000
Message-ID: <1367434764.4189.33.camel@leira.trondhjem.org>
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
	 <1367240239-19326-10-git-send-email-SteveD@redhat.com>
In-Reply-To: <1367240239-19326-10-git-send-email-SteveD@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-04-29 at 08:57 -0400, Steve Dickson wrote:
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
>  fs/nfs/inode.c            | 28 ++++++++++++++++++++++++++++
>  include/linux/nfs4.h      |  7 +++++++
>  include/linux/nfs_fs.h    | 18 ++++++++++++++++++
>  include/linux/nfs_xdr.h   | 21 +++++++++++++++++++++
>  include/uapi/linux/nfs4.h |  2 +-
>  5 files changed, 75 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 1f94167..c88255c 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -257,6 +257,34 @@ nfs_init_locked(struct inode *inode, void *opaque)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags)
> +{
> +	struct nfs4_label *label = NULL;
> +	int minor_version = server->nfs_client->cl_minorversion;
> +
> +	if (minor_version < 2)
> +		return label;
> +
> +	if (!(server->caps & NFS_CAP_SECURITY_LABEL))
> +		return label;
> +
> +	label = kzalloc(sizeof(struct nfs4_label), flags);
> +	if (label == NULL)
> +		return ERR_PTR(-ENOMEM);
> +
> +	label->label = kzalloc(NFS4_MAXLABELLEN, flags);
> +	if (label->label == NULL) {
> +		kfree(label);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +	label->len = NFS4_MAXLABELLEN;
> +
> +	return label;
> +}
> +EXPORT_SYMBOL_GPL(nfs4_label_alloc);
> +#endif
> +
>  /*
>   * This is our front-end to iget that looks up inodes by file handle
>   * instead of inode number.
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 6f44cc1..4c61ef4 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -32,6 +32,13 @@ struct nfs4_acl {
>  	struct nfs4_ace	aces[0];
>  };
>  
> +struct nfs4_label {
> +	uint32_t	lfs;
> +	uint32_t	pi;
> +	u32		len;
> +	char	*label;
> +};
> +
>  typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
>  
>  struct nfs_stateid4 {
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 1cc2568..e0e1806 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -489,6 +489,24 @@ extern int nfs_mountpoint_expiry_timeout;
>  extern void nfs_release_automount_timer(void);
>  
>  /*
> + * linux/fs/nfs/nfs4proc.c
> + */
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +extern struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags);
> +static inline void nfs4_label_free(struct nfs4_label *label)
> +{
> +	if (label) {
> +		kfree(label->label);
> +		kfree(label);
> +	}
> +	return;
> +}
> +#else
> +static inline struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags) { return NULL; }
> +static inline void nfs4_label_free(void *label) {}
> +#endif
> +
> +/*
>   * linux/fs/nfs/unlink.c
>   */
>  extern void nfs_complete_unlink(struct dentry *dentry, struct inode *);
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index 9f2dba3..4d2fdf6 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -351,6 +351,7 @@ struct nfs_openargs {
>  	const u32 *		bitmask;
>  	const u32 *		open_bitmap;
>  	__u32			claim;
> +	const struct nfs4_label *label;
>  };
>  
>  struct nfs_openres {
> @@ -360,6 +361,7 @@ struct nfs_openres {
>  	struct nfs4_change_info	cinfo;
>  	__u32                   rflags;
>  	struct nfs_fattr *      f_attr;
> +	struct nfs4_label	*f_label;
>  	struct nfs_seqid *	seqid;
>  	const struct nfs_server *server;
>  	fmode_t			delegation_type;
> @@ -404,6 +406,7 @@ struct nfs_closeres {
>  	struct nfs4_sequence_res	seq_res;
>  	nfs4_stateid            stateid;
>  	struct nfs_fattr *	fattr;
> +	struct nfs4_label	*label;
>  	struct nfs_seqid *	seqid;
>  	const struct nfs_server *server;
>  };
> @@ -477,6 +480,7 @@ struct nfs4_delegreturnargs {
>  struct nfs4_delegreturnres {
>  	struct nfs4_sequence_res	seq_res;
>  	struct nfs_fattr * fattr;
> +	struct nfs4_label	*label;
>  	const struct nfs_server *server;
>  };
>  
> @@ -497,6 +501,7 @@ struct nfs_readargs {
>  struct nfs_readres {
>  	struct nfs4_sequence_res	seq_res;
>  	struct nfs_fattr *	fattr;
> +	struct nfs4_label	*label;

Why do we need to check labels on close, delegreturn, read, remove,
rename, etc? Do any of those operations cause our cached labels to
change?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
