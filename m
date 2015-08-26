Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45084 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752770AbbHZUAd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Aug 2015 16:00:33 -0400
Date: Wed, 26 Aug 2015 16:00:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com
Subject: Re: [PATCH v3 14/20] nfsd: close cached files prior to a REMOVE or
 RENAME that would replace target
Message-ID: <20150826200032.GD4161@fieldses.org>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
 <1440069440-27454-15-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1440069440-27454-15-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 20, 2015 at 07:17:14AM -0400, Jeff Layton wrote:
> It's not uncommon for some workloads to do a bunch of I/O to a file and
> delete it just afterward. If knfsd has a cached open file however, then
> the file may still be open when the dentry is unlinked. If the
> underlying filesystem is nfs, then that could trigger it to do a
> sillyrename.

Possibly worth noting that situation doesn't currently occur upstream.

(And, another justification worth noting: space used by a file should be
deallocated on last unlink or close.  People do sometimes notice if it's
not, especially if the file is large.)

> On a REMOVE or RENAME scan the nfsd_file cache for open files that
> correspond to the inode, and proactively unhash and put their
> references. This should prevent any delete-on-last-close activity from
> occurring, solely due to knfsd's open file cache.

Is there anything here to prevent a new cache entry being added after
nfsd_file_close_inode and before the file is actually removed?

--b.

> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfsd/filecache.c | 25 +++++++++++++++++++++++++
>  fs/nfsd/filecache.h |  1 +
>  fs/nfsd/trace.h     | 17 +++++++++++++++++
>  fs/nfsd/vfs.c       | 17 +++++++++++++++--
>  4 files changed, 58 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
> index e48b536762aa..4bd683f03b6e 100644
> --- a/fs/nfsd/filecache.c
> +++ b/fs/nfsd/filecache.c
> @@ -283,6 +283,31 @@ nfsd_file_find_locked(struct inode *inode, unsigned int may_flags,
>  	return NULL;
>  }
>  
> +/**
> + * nfsd_file_close_inode - attempt to forcibly close a nfsd_file
> + * @inode: inode of the file to attempt to remove
> + *
> + * Walk the whole hash bucket, looking for any files that correspond to "inode".
> + * If any do, then unhash them and put the hashtable reference to them.
> + */
> +void
> +nfsd_file_close_inode(struct inode *inode)
> +{
> +	struct nfsd_file	*nf;
> +	struct hlist_node	*tmp;
> +	unsigned int		hashval = (unsigned int)hash_ptr(inode, NFSD_FILE_HASH_BITS);
> +	LIST_HEAD(dispose);
> +
> +	spin_lock(&nfsd_file_hashtbl[hashval].nfb_lock);
> +	hlist_for_each_entry_safe(nf, tmp, &nfsd_file_hashtbl[hashval].nfb_head, nf_node) {
> +		if (inode == nf->nf_inode)
> +			nfsd_file_unhash_and_release_locked(nf, &dispose);
> +	}
> +	spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
> +	trace_nfsd_file_close_inode(hashval, inode, !list_empty(&dispose));
> +	nfsd_file_dispose_list(&dispose);
> +}
> +
>  __be32
>  nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		  unsigned int may_flags, struct nfsd_file **pnf)
> diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
> index debd558ef786..191cdb25aa66 100644
> --- a/fs/nfsd/filecache.h
> +++ b/fs/nfsd/filecache.h
> @@ -26,6 +26,7 @@ int nfsd_file_cache_init(void);
>  void nfsd_file_cache_shutdown(void);
>  void nfsd_file_put(struct nfsd_file *nf);
>  struct nfsd_file *nfsd_file_get(struct nfsd_file *nf);
> +void nfsd_file_close_inode(struct inode *inode);
>  __be32 nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		  unsigned int may_flags, struct nfsd_file **nfp);
>  #endif /* _FS_NFSD_FILECACHE_H */
> diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
> index 2dac872d31e8..95af3b9c7b66 100644
> --- a/fs/nfsd/trace.h
> +++ b/fs/nfsd/trace.h
> @@ -139,6 +139,23 @@ TRACE_EVENT(nfsd_file_acquire,
>  			show_nf_may(__entry->nf_may), __entry->nf_file,
>  			be32_to_cpu(__entry->status))
>  );
> +
> +TRACE_EVENT(nfsd_file_close_inode,
> +	TP_PROTO(unsigned int hash, struct inode *inode, int found),
> +	TP_ARGS(hash, inode, found),
> +	TP_STRUCT__entry(
> +		__field(unsigned int, hash)
> +		__field(struct inode *, inode)
> +		__field(int, found)
> +	),
> +	TP_fast_assign(
> +		__entry->hash = hash;
> +		__entry->inode = inode;
> +		__entry->found = found;
> +	),
> +	TP_printk("hash=0x%x inode=0x%p found=%d", __entry->hash,
> +			__entry->inode, __entry->found)
> +);
>  #endif /* _NFSD_TRACE_H */
>  
>  #undef TRACE_INCLUDE_PATH
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 6cfd96adcc71..98d3b9d96480 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1583,6 +1583,15 @@ out_nfserr:
>  	goto out_unlock;
>  }
>  
> +static void
> +nfsd_close_cached_files(struct dentry *dentry)
> +{
> +	struct inode *inode = d_inode(dentry);
> +
> +	if (inode && S_ISREG(inode->i_mode))
> +		nfsd_file_close_inode(inode);
> +}
> +
>  /*
>   * Rename a file
>   * N.B. After this call _both_ ffhp and tfhp need an fh_put
> @@ -1652,6 +1661,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>  	if (ffhp->fh_export->ex_path.dentry != tfhp->fh_export->ex_path.dentry)
>  		goto out_dput_new;
>  
> +	nfsd_close_cached_files(ndentry);
>  	host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL, 0);
>  	if (!host_err) {
>  		host_err = commit_metadata(tfhp);
> @@ -1721,10 +1731,13 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
>  	if (!type)
>  		type = d_inode(rdentry)->i_mode & S_IFMT;
>  
> -	if (type != S_IFDIR)
> +	if (type != S_IFDIR) {
> +		nfsd_close_cached_files(rdentry);
>  		host_err = vfs_unlink(dirp, rdentry, NULL);
> -	else
> +	} else {
>  		host_err = vfs_rmdir(dirp, rdentry);
> +	}
> +
>  	if (!host_err)
>  		host_err = commit_metadata(fhp);
>  	dput(rdentry);
> -- 
> 2.4.3
