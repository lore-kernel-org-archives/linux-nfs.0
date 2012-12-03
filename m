Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:34806 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751066Ab2LCVSe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2012 16:18:34 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Mon, 03 Dec 2012 16:18:32 -0500
From: David Quigley <dpquigl@davequigley.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] lnfs: Cleaned up compile warnings when
 =?UTF-8?Q?NFS=5FV=34=5FSECURITY=5FLABEL=20is=20not=20set=2E?=
In-Reply-To: <1354566254-546-1-git-send-email-steved@redhat.com>
References: <1354566254-546-1-git-send-email-steved@redhat.com>
Message-ID: <3e20ecd2416fc5a995ca152c8508f86c@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/03/2012 15:24, Steve Dickson wrote:
> This patch cleans up a number compile warnings when the
> label NFS code exists but is not configured to compile.
>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  fs/nfs/nfs4proc.c      | 36 ++++++++++++++++++++++++------------
>  include/linux/nfs_fs.h |  4 ++--
>  2 files changed, 26 insertions(+), 14 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 2c8dd55..02e3303 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -926,8 +926,8 @@ err_free_label:
>  #ifdef CONFIG_NFS_V4_SECURITY_LABEL
>  	if (server->caps & NFS_CAP_SECURITY_LABEL)
>  		nfs4_label_free(p->f_label);
> -#endif
>  err_free_p:
> +#endif
>  	kfree(p);
>  err:
>  	dput(parent);
> @@ -2438,9 +2438,10 @@ static struct inode *
>  nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx,
> int open_flags, struct iattr *attr)
>  {
>  	struct nfs4_state *state;
> -	struct nfs4_label l, *label = NULL;
> -
> +	struct nfs4_label *label = NULL;
>  #ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +	struct nfs4_label l;
> +
>  	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
>  		struct dentry *dentry = ctx->dentry;
>  		int error;
> @@ -3026,8 +3027,8 @@ static int _nfs4_proc_access(struct inode
> *inode, struct nfs_access_entry *entry
>  #ifdef CONFIG_NFS_V4_SECURITY_LABEL
>  	if (server->caps & NFS_CAP_SECURITY_LABEL)
>  		nfs4_label_free(res.label);
> -#endif
>  out:
> +#endif
>  	nfs_free_fattr(res.fattr);
>  	return status;
>  }
> @@ -3105,7 +3106,10 @@ static int
>  nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct
> iattr *sattr,
>  		 int flags)
>  {
> -	struct nfs4_label l, *ilabel = NULL;
> +	struct nfs4_label *ilabel = NULL;
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +	struct nfs4_label l;
> +#endif
>  	struct nfs_open_context *ctx;
>  	struct nfs4_state *state;
>  	int status = 0;
> @@ -3298,8 +3302,8 @@ static int _nfs4_proc_rename(struct inode
> *old_dir, struct qstr *old_name,
>  		nfs4_label_free(res.old_label);
>  		nfs4_label_free(res.new_label);
>  	}
> -#endif
>  out:
> +#endif
>  	return status;
>  }
>
> @@ -3418,7 +3422,9 @@ static struct nfs4_createdata
> *nfs4_alloc_createdata(struct inode *dir,
>  		nfs_fattr_init(data->res.fattr);
>  	}
>  	return data;
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
>  out_free:
> +#endif
>  	kfree(data);
>  	return NULL;
>  }
> @@ -3474,11 +3480,11 @@ static int nfs4_proc_symlink(struct inode
> *dir, struct dentry *dentry,
>  		struct page *page, unsigned int len, struct iattr *sattr)
>  {
>  	struct nfs4_exception exception = { };
> -	struct nfs4_label l, *label = NULL;
>  	int err;
> -
> -
> +	struct nfs4_label *label = NULL;
>  #ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +	struct nfs4_label l;
> +
>  	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
>  		err = security_dentry_init_security(dentry, sattr->ia_mode,
>  					&dentry->d_name, &l.label, &l.len);
> @@ -3522,7 +3528,10 @@ static int nfs4_proc_mkdir(struct inode *dir,
> struct dentry *dentry,
>  		struct iattr *sattr)
>  {
>  	struct nfs4_exception exception = { };
> -	struct nfs4_label l, *label = NULL;
> +	struct nfs4_label *label = NULL;
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +	struct nfs4_label l;
> +#endif
>  	int err;
>
>  #ifdef CONFIG_NFS_V4_SECURITY_LABEL
> @@ -3640,9 +3649,12 @@ out:
>  static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
>  		struct iattr *sattr, dev_t rdev)
>  {
> -	struct nfs4_exception exception = { };
> -	struct nfs4_label l, *label = NULL;
>  	int err;
> +	struct nfs4_exception exception = { };
> +	struct nfs4_label *label = NULL;
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +	struct nfs4_label l;
> +#endif
>
>  #ifdef CONFIG_NFS_V4_SECURITY_LABEL
>  	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL)) {
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 2ef01f8..f4bb5c4 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -502,8 +502,8 @@ extern void nfs4_label_init(struct nfs4_label *);
>  extern void nfs4_label_free(struct nfs4_label *);
>  #else
>  static inline struct nfs4_label *nfs4_label_alloc(gfp_t flags) {
> return NULL; }
> -static inline void nfs4_label_init(struct nfs4_label *) {}
> -static inline void nfs4_label_free(struct nfs4_label *label) {}
> +static inline void nfs4_label_init(void *label) {}
> +static inline void nfs4_label_free(void *label) {}
>  #endif
>
>  /*

Thanks for the patch. The question I have here is should I tag Steve's 
patch on the end of the patch set or should I integrate it back into the 
original patches?

Dave
