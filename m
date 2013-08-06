Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f179.google.com ([209.85.212.179]:52351 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755954Ab3HFQIN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Aug 2013 12:08:13 -0400
Received: by mail-wi0-f179.google.com with SMTP id hr7so614656wib.6
        for <linux-nfs@vger.kernel.org>; Tue, 06 Aug 2013 09:08:11 -0700 (PDT)
Date: Tue, 6 Aug 2013 18:08:15 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
To: rwheeler@redhat.com, avati@redhat.com, viro@ZenIV.linux.org.uk
Cc: bfoster@redhat.com, dhowells@redhat.com, eparis@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        swhiteho@redhat.com, mszeredi@suse.cz
Subject: Re: [PATCH 2/4] vfs: check unlinked ancestors before mount
Message-ID: <20130806160815.GA29888@tucsk.piliscsaba.szeredi.hu>
References: <1375799403-28544-1-git-send-email-miklos@szeredi.hu>
 <1375799403-28544-3-git-send-email-miklos@szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1375799403-28544-3-git-send-email-miklos@szeredi.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 06, 2013 at 04:30:01PM +0200, Miklos Szeredi wrote:
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> We check submounts before doing d_drop() on a non-empty directory dentry in
> NFS (have_submounts()).  But we do not exclude a racing mount.  Nor do we
> prevent mounts to be added to the disconnected subtree using relative paths
> after the d_drop().
> 
> This patch fixes these issues by checking for unlinked (unhashed, non-root)
> ancestors before proceeding with the mount.  This is done after setting
> DCACHE_MOUNTED on the soon-to-be mountpoint and with the rename seqlock
> taken for write.  This ensures that the only one of have_submounts() or
> has_unlinked_ancestor() can succeed.
> 
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> ---
>  fs/dcache.c    | 28 ++++++++++++++++++++++++++++
>  fs/internal.h  |  1 +
>  fs/namespace.c |  9 +++++++++
>  3 files changed, 38 insertions(+)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index ba429d9..eae7cc1 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1103,6 +1103,34 @@ rename_retry:
>  }
>  EXPORT_SYMBOL(have_submounts);
>  
> +static bool __has_unlinked_ancestor(struct dentry *dentry)
> +{
> +	struct dentry *this;
> +
> +	for (this = dentry; !IS_ROOT(this); this = this->d_parent) {
> +		if (d_unhashed(this))

Actually we need to take ->d_lock around this d_unhashed() since the __d_drop()
is done outside the read read_seqbegin/read_seqretry() region but with d_lock
held.

Thanks,
Miklos

> +			return true;
> +	}
> +	return false;
> +}
> +
> +/*
> + * Called by mount code to check if the mountpoint is reachable (e.g. NFS can
> + * unhash a directory dentry and then the complete subtree can become
> + * unreachable).
> + */
> +bool has_unlinked_ancestor(struct dentry *dentry)
> +{
> +	bool found;
> +
> +	/* Need exclusion wrt. check_submounts_and_drop() */
> +	write_seqlock(&rename_lock);
> +	found = __has_unlinked_ancestor(dentry);
> +	write_sequnlock(&rename_lock);
> +
> +	return found;
> +}
> +
>  /*
>   * Search the dentry child list of the specified parent,
>   * and move any unused dentries to the end of the unused
> diff --git a/fs/internal.h b/fs/internal.h
> index 7c5f01c..d232355 100644
> --- a/fs/internal.h
> +++ b/fs/internal.h
> @@ -126,6 +126,7 @@ extern int invalidate_inodes(struct super_block *, bool);
>   * dcache.c
>   */
>  extern struct dentry *__d_alloc(struct super_block *, const struct qstr *);
> +extern bool has_unlinked_ancestor(struct dentry *dentry);
>  
>  /*
>   * read_write.c
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 7b1ca9b..bb92a9c 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -634,6 +634,15 @@ static struct mountpoint *new_mountpoint(struct dentry *dentry)
>  	}
>  	dentry->d_flags |= DCACHE_MOUNTED;
>  	spin_unlock(&dentry->d_lock);
> +
> +	if (has_unlinked_ancestor(dentry)) {
> +		spin_lock(&dentry->d_lock);
> +		dentry->d_flags &= ~DCACHE_MOUNTED;
> +		spin_unlock(&dentry->d_lock);
> +		kfree(mp);
> +		return ERR_PTR(-ENOENT);
> +	}
> +
>  	mp->m_dentry = dentry;
>  	mp->m_count = 1;
>  	list_add(&mp->m_hash, chain);
> -- 
> 1.8.1.4
> 
