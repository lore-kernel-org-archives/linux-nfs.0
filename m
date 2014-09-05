Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41756 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317AbaIEVlC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Sep 2014 17:41:02 -0400
Date: Fri, 5 Sep 2014 17:40:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 07/17] nfsd: don't keep a pointer to the lease in
 nfs4_file
Message-ID: <20140905214058.GA5443@fieldses.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
 <1409834323-7171-8-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409834323-7171-8-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2014 at 08:38:33AM -0400, Jeff Layton wrote:
> Now that we don't need to pass in an actual lease pointer to
> vfs_setlease on unlock, we can stop tracking a pointer to the lease in
> the nfs4_file.
> 
> Switch all of the places that check the fi_lease to check fi_deleg_file
> instead. We always set that at the same time so it will have the same
> semantics.
> 
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfs4state.c | 10 ++++------
>  fs/nfsd/state.h     |  1 -
>  2 files changed, 4 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 0cd252916e1a..d0a6e8e022a2 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -680,11 +680,10 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
>  {
>  	lockdep_assert_held(&state_lock);
>  
> -	if (!fp->fi_lease)
> +	if (!fp->fi_deleg_file)
>  		return;
>  	if (atomic_dec_and_test(&fp->fi_delegees)) {
>  		vfs_setlease(fp->fi_deleg_file, F_UNLCK, NULL);
> -		fp->fi_lease = NULL;
>  		fput(fp->fi_deleg_file);
>  		fp->fi_deleg_file = NULL;
>  	}

Note the code in my for-3.18 branch is different here due to a couple
patches I've already taken from you.

--b.

> @@ -3061,8 +3060,8 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct knfsd_fh *fh)
>  	INIT_LIST_HEAD(&fp->fi_stateids);
>  	INIT_LIST_HEAD(&fp->fi_delegations);
>  	fh_copy_shallow(&fp->fi_fhandle, fh);
> +	fp->fi_deleg_file = NULL;
>  	fp->fi_had_conflict = false;
> -	fp->fi_lease = NULL;
>  	fp->fi_share_deny = 0;
>  	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
>  	memset(fp->fi_access, 0, sizeof(fp->fi_access));
> @@ -3803,13 +3802,12 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
>  	if (fp->fi_had_conflict)
>  		goto out_unlock;
>  	/* Race breaker */
> -	if (fp->fi_lease) {
> +	if (fp->fi_deleg_file) {
>  		status = 0;
>  		atomic_inc(&fp->fi_delegees);
>  		hash_delegation_locked(dp, fp);
>  		goto out_unlock;
>  	}
> -	fp->fi_lease = fl;
>  	fp->fi_deleg_file = filp;
>  	atomic_set(&fp->fi_delegees, 1);
>  	hash_delegation_locked(dp, fp);
> @@ -3842,7 +3840,7 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
>  	spin_lock(&state_lock);
>  	spin_lock(&fp->fi_lock);
>  	dp->dl_stid.sc_file = fp;
> -	if (!fp->fi_lease) {
> +	if (!fp->fi_deleg_file) {
>  		spin_unlock(&fp->fi_lock);
>  		spin_unlock(&state_lock);
>  		status = nfs4_setlease(dp);
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 4a89e00d7461..64f291a25a8c 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -477,7 +477,6 @@ struct nfs4_file {
>  	atomic_t		fi_access[2];
>  	u32			fi_share_deny;
>  	struct file		*fi_deleg_file;
> -	struct file_lock	*fi_lease;
>  	atomic_t		fi_delegees;
>  	struct knfsd_fh		fi_fhandle;
>  	bool			fi_had_conflict;
> -- 
> 1.9.3
> 
