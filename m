Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55531 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763157Ab3DCTPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 15:15:07 -0400
Date: Wed, 3 Apr 2013 15:15:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: convert the file_hashtbl to a hlist
Message-ID: <20130403191506.GF6044@fieldses.org>
References: <1364907719-9616-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364907719-9616-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 02, 2013 at 09:01:59AM -0400, Jeff Layton wrote:
> We only ever traverse the hash chains in the forward direction, so a
> double pointer list head isn't really necessary.

Thanks, applying.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4state.c | 14 ++++----------
>  fs/nfsd/state.h     |  2 +-
>  2 files changed, 5 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2efb034..e1c29d6 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -137,7 +137,7 @@ static inline void
>  put_nfs4_file(struct nfs4_file *fi)
>  {
>  	if (atomic_dec_and_lock(&fi->fi_ref, &recall_lock)) {
> -		list_del(&fi->fi_hash);
> +		hlist_del(&fi->fi_hash);
>  		spin_unlock(&recall_lock);
>  		iput(fi->fi_inode);
>  		nfsd4_free_file(fi);
> @@ -181,7 +181,7 @@ static unsigned int file_hashval(struct inode *ino)
>  	return hash_ptr(ino, FILE_HASH_BITS);
>  }
>  
> -static struct list_head file_hashtbl[FILE_HASH_SIZE];
> +static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
>  
>  static void __nfs4_file_get_access(struct nfs4_file *fp, int oflag)
>  {
> @@ -2303,7 +2303,6 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
>  	unsigned int hashval = file_hashval(ino);
>  
>  	atomic_set(&fp->fi_ref, 1);
> -	INIT_LIST_HEAD(&fp->fi_hash);
>  	INIT_LIST_HEAD(&fp->fi_stateids);
>  	INIT_LIST_HEAD(&fp->fi_delegations);
>  	fp->fi_inode = igrab(ino);
> @@ -2312,7 +2311,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
>  	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
>  	memset(fp->fi_access, 0, sizeof(fp->fi_access));
>  	spin_lock(&recall_lock);
> -	list_add(&fp->fi_hash, &file_hashtbl[hashval]);
> +	hlist_add_head(&fp->fi_hash, &file_hashtbl[hashval]);
>  	spin_unlock(&recall_lock);
>  }
>  
> @@ -2498,7 +2497,7 @@ find_file(struct inode *ino)
>  	struct nfs4_file *fp;
>  
>  	spin_lock(&recall_lock);
> -	list_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
> +	hlist_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
>  		if (fp->fi_inode == ino) {
>  			get_nfs4_file(fp);
>  			spin_unlock(&recall_lock);
> @@ -4775,11 +4774,6 @@ struct nfs4_client *nfsd_find_client(struct sockaddr_storage *addr, size_t addr_
>  void
>  nfs4_state_init(void)
>  {
> -	int i;
> -
> -	for (i = 0; i < FILE_HASH_SIZE; i++) {
> -		INIT_LIST_HEAD(&file_hashtbl[i]);
> -	}
>  	INIT_LIST_HEAD(&del_recall_lru);
>  }
>  
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 1a8c739..5350dac 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -390,7 +390,7 @@ static inline struct nfs4_lockowner * lockowner(struct nfs4_stateowner *so)
>  /* nfs4_file: a file opened by some number of (open) nfs4_stateowners. */
>  struct nfs4_file {
>  	atomic_t		fi_ref;
> -	struct list_head        fi_hash;    /* hash by "struct inode *" */
> +	struct hlist_node       fi_hash;    /* hash by "struct inode *" */
>  	struct list_head        fi_stateids;
>  	struct list_head	fi_delegations;
>  	/* One each for O_RDONLY, O_WRONLY, O_RDWR: */
> -- 
> 1.7.11.7
> 
