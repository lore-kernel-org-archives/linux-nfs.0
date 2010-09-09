Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21822 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854Ab0IIUUs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 16:20:48 -0400
Date: Thu, 9 Sep 2010 16:20:37 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfs: introduce mount option '-olocal_lock' to make
 locks local
Message-ID: <20100909162037.20c4ebec@tlielax.poochiereds.net>
In-Reply-To: <4C893746.6090202@suse.de>
References: <4C893746.6090202@suse.de>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 10 Sep 2010 01:06:38 +0530
Suresh Jayaraman <sjayaraman@suse.de> wrote:

> NFS clients since 2.6.12 support flock locks by emulating fcntl byte-range
> locks. Due to this, some windows applications which seem to use both flock
> (share mode lock mapped as flock by Samba) and fcntl locks sequentially on
> the same file, can't lock as they falsely assume the file is already locked.
> The problem was reported on a setup with windows clients accessing excel files
> on a Samba exported share which is originally a NFS mount from a NetApp filer.
> 
> Older NFS clients (< 2.6.12) did not see this problem as flock locks were
> considered local. To support legacy flock behavior, this patch adds a mount
> option "-olocal_lock=" which can take the following values:
> 
>    'none'  		- Neither flock locks or fcntl/posix locks are local
>    'flock'/'posix' 	- flock locks are local
	^^^^^^^
"posix" ought to be synonymous with "fcntl". "flock" was a BSD-ism.

It may be better to keep it simple though and drop either "posix" or
"fcntl". No need to add unneeded synonyms on a brand new mount option.

>    'fcntl' 		- fcntl locks are local
>    'all'		- Both flock locks and fcntl/posix locks are local
> 
> Testing:
> 
> This patch was tested by using -olocal_lock option with different values and
> the NLM calls were noted from the network packet capture.
> 
>    'none'  - NLM calls were seen during both flock() and fcntl(), flock lock
>    	     was granted, fcntl was denied
>    'flock' - no NLM calls for flock(), NLM call was seen for fcntl(),
>    	     granted
>    'fcntl' - NLM call was seen for flock() - granted, no NLM call for fcntl()
>    'all'   - no NLM calls were seen during both flock() and fcntl()
> 
> Also, with these patches ensured that the exisiting behavior of '-olock' and
> '-onolock' didn't change.
> 
> Cc: Neil Brown <neilb@suse.de>
> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
> ---
>  fs/nfs/client.c           |    6 +++-
>  fs/nfs/file.c             |   35 +++++++++++++++++++++++----------
>  fs/nfs/super.c            |   47 +++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/nfs_mount.h |    5 +++-
>  4 files changed, 79 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 4e7df2a..5f01f42 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -635,7 +635,8 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
>   */
>  static void nfs_destroy_server(struct nfs_server *server)
>  {
> -	if (!(server->flags & NFS_MOUNT_NONLM))
> +	if (!(server->flags & NFS_MOUNT_LOCAL_FLOCK) ||
> +			!(server->flags & NFS_MOUNT_LOCAL_FCNTL))
>  		nlmclnt_done(server->nlm_host);
>  }
>  
> @@ -657,7 +658,8 @@ static int nfs_start_lockd(struct nfs_server *server)
>  
>  	if (nlm_init.nfs_version > 3)
>  		return 0;
> -	if (server->flags & NFS_MOUNT_NONLM)
> +	if ((server->flags & NFS_MOUNT_LOCAL_FLOCK) &&
> +			(server->flags & NFS_MOUNT_LOCAL_FCNTL))
>  		return 0;
>  
>  	switch (clp->cl_proto) {
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index eb51bd6..e338d37 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -684,7 +684,8 @@ static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
>  	return ret;
>  }
>  
> -static int do_getlk(struct file *filp, int cmd, struct file_lock *fl)
> +static int
> +do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
>  {
>  	struct inode *inode = filp->f_mapping->host;
>  	int status = 0;
> @@ -699,7 +700,7 @@ static int do_getlk(struct file *filp, int cmd, struct file_lock *fl)
>  	if (nfs_have_delegation(inode, FMODE_READ))
>  		goto out_noconflict;
>  
> -	if (NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM)
> +	if ((NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) || is_local)
>  		goto out_noconflict;
>  
>  	status = NFS_PROTO(inode)->lock(filp, cmd, fl);
> @@ -730,7 +731,8 @@ static int do_vfs_lock(struct file *file, struct file_lock *fl)
>  	return res;
>  }
>  
> -static int do_unlk(struct file *filp, int cmd, struct file_lock *fl)
> +static int
> +do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
>  {
>  	struct inode *inode = filp->f_mapping->host;
>  	int status;
> @@ -746,14 +748,15 @@ static int do_unlk(struct file *filp, int cmd, struct file_lock *fl)
>  	 * 	still need to complete the unlock.
>  	 */
>  	/* Use local locking if mounted with "-onolock" */
> -	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM))
> +	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) || !is_local)
>  		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
>  	else
>  		status = do_vfs_lock(filp, fl);
>  	return status;
>  }
>  
> -static int do_setlk(struct file *filp, int cmd, struct file_lock *fl)
> +static int
> +do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
>  {
>  	struct inode *inode = filp->f_mapping->host;
>  	int status;
> @@ -767,7 +770,7 @@ static int do_setlk(struct file *filp, int cmd, struct file_lock *fl)
>  		goto out;
>  
>  	/* Use local locking if mounted with "-onolock" */
> -	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM))
> +	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM) || !is_local)
>  		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
>  	else
>  		status = do_vfs_lock(filp, fl);
> @@ -791,6 +794,7 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
>  {
>  	struct inode *inode = filp->f_mapping->host;
>  	int ret = -ENOLCK;
> +	int is_local = 0;
>  
>  	dprintk("NFS: lock(%s/%s, t=%x, fl=%x, r=%lld:%lld)\n",
>  			filp->f_path.dentry->d_parent->d_name.name,
> @@ -804,6 +808,9 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
>  	if (__mandatory_lock(inode) && fl->fl_type != F_UNLCK)
>  		goto out_err;
>  
> +	if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FCNTL)
> +		is_local = 1;
> +
>  	if (NFS_PROTO(inode)->lock_check_bounds != NULL) {
>  		ret = NFS_PROTO(inode)->lock_check_bounds(fl);
>  		if (ret < 0)
> @@ -811,11 +818,11 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
>  	}
>  
>  	if (IS_GETLK(cmd))
> -		ret = do_getlk(filp, cmd, fl);
> +		ret = do_getlk(filp, cmd, fl, is_local);
>  	else if (fl->fl_type == F_UNLCK)
> -		ret = do_unlk(filp, cmd, fl);
> +		ret = do_unlk(filp, cmd, fl, is_local);
>  	else
> -		ret = do_setlk(filp, cmd, fl);
> +		ret = do_setlk(filp, cmd, fl, is_local);
>  out_err:
>  	return ret;
>  }
> @@ -825,6 +832,9 @@ out_err:
>   */
>  static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
>  {
> +	struct inode *inode = filp->f_mapping->host;
> +	int is_local = 0;
> +
>  	dprintk("NFS: flock(%s/%s, t=%x, fl=%x)\n",
>  			filp->f_path.dentry->d_parent->d_name.name,
>  			filp->f_path.dentry->d_name.name,
> @@ -833,14 +843,17 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
>  	if (!(fl->fl_flags & FL_FLOCK))
>  		return -ENOLCK;
>  
> +	if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FLOCK)
> +		is_local = 1;
> +
>  	/* We're simulating flock() locks using posix locks on the server */
>  	fl->fl_owner = (fl_owner_t)filp;
>  	fl->fl_start = 0;
>  	fl->fl_end = OFFSET_MAX;
>  
>  	if (fl->fl_type == F_UNLCK)
> -		return do_unlk(filp, cmd, fl);
> -	return do_setlk(filp, cmd, fl);
> +		return do_unlk(filp, cmd, fl, is_local);
> +	return do_setlk(filp, cmd, fl, is_local);
>  }
>  
>  /*
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index ec3966e..c0d51dc 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -100,6 +100,7 @@ enum {
>  	Opt_addr, Opt_mountaddr, Opt_clientaddr,
>  	Opt_lookupcache,
>  	Opt_fscache_uniq,
> +	Opt_local_lock,
>  
>  	/* Special mount options */
>  	Opt_userspace, Opt_deprecated, Opt_sloppy,
> @@ -171,6 +172,7 @@ static const match_table_t nfs_mount_option_tokens = {
>  
>  	{ Opt_lookupcache, "lookupcache=%s" },
>  	{ Opt_fscache_uniq, "fsc=%s" },
> +	{ Opt_local_lock, "local_lock=%s" },
>  
>  	{ Opt_err, NULL }
>  };
> @@ -236,6 +238,23 @@ static match_table_t nfs_lookupcache_tokens = {
>  	{ Opt_lookupcache_err, NULL }
>  };
>  
> +enum {
> +	Opt_local_lock_all, Opt_local_lock_flock, Opt_local_lock_fcntl,
> +	Opt_local_lock_none,
> +
> +	Opt_local_lock_err
> +};
> +
> +static match_table_t nfs_local_lock_tokens = {
> +	{ Opt_local_lock_all, "all" },
> +	{ Opt_local_lock_flock, "flock" },
> +	{ Opt_local_lock_fcntl, "fcntl" },
> +	{ Opt_local_lock_fcntl, "posix" },
> +	{ Opt_local_lock_none, "none" },
> +
> +	{ Opt_local_lock_err, NULL }
> +};
> +
>  
>  static void nfs_umount_begin(struct super_block *);
>  static int  nfs_statfs(struct dentry *, struct kstatfs *);
> @@ -1412,6 +1431,34 @@ static int nfs_parse_mount_options(char *raw,
>  			mnt->fscache_uniq = string;
>  			mnt->options |= NFS_OPTION_FSCACHE;
>  			break;
> +		case Opt_local_lock:
> +			string = match_strdup(args);
> +			if (string == NULL)
> +				goto out_nomem;
> +			token = match_token(string, nfs_local_lock_tokens,
> +					args);
> +			kfree(string);
> +			switch (token) {
> +			case Opt_local_lock_all:
> +				mnt->flags |= (NFS_MOUNT_LOCAL_FLOCK |
> +					       NFS_MOUNT_LOCAL_FCNTL);
> +				break;
> +			case Opt_local_lock_flock:
> +				mnt->flags |= NFS_MOUNT_LOCAL_FLOCK;
> +				break;
> +			case Opt_local_lock_fcntl:
> +				mnt->flags |= NFS_MOUNT_LOCAL_FCNTL;
> +				break;
> +			case Opt_local_lock_none:
> +				mnt->flags &= ~(NFS_MOUNT_LOCAL_FLOCK |
> +						NFS_MOUNT_LOCAL_FCNTL);
> +				break;
> +			default:
> +				dfprintk(MOUNT, "NFS:	invalid	"
> +						"local_lock argument\n");
> +				return 0;
> +			};
> +			break;
>  
>  		/*
>  		 * Special options
> diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
> index 5d59ae8..652d7e9 100644
> --- a/include/linux/nfs_mount.h
> +++ b/include/linux/nfs_mount.h
> @@ -56,7 +56,6 @@ struct nfs_mount_data {
>  #define NFS_MOUNT_TCP		0x0040	/* 2 */
>  #define NFS_MOUNT_VER3		0x0080	/* 3 */
>  #define NFS_MOUNT_KERBEROS	0x0100	/* 3 */
> -#define NFS_MOUNT_NONLM		0x0200	/* 3 */
>  #define NFS_MOUNT_BROKEN_SUID	0x0400	/* 4 */
>  #define NFS_MOUNT_NOACL		0x0800	/* 4 */
>  #define NFS_MOUNT_STRICTLOCK	0x1000	/* reserved for NFSv4 */
> @@ -71,4 +70,8 @@ struct nfs_mount_data {
>  #define NFS_MOUNT_NORESVPORT		0x40000
>  #define NFS_MOUNT_LEGACY_INTERFACE	0x80000
>  
> +#define NFS_MOUNT_LOCAL_FLOCK	0x100000
> +#define NFS_MOUNT_LOCAL_FCNTL	0x200000
> +#define NFS_MOUNT_NONLM	 	(NFS_MOUNT_LOCAL_FLOCK | NFS_MOUNT_LOCAL_FCNTL)
> +
>  #endif


-- 
Jeff Layton <jlayton@redhat.com>
