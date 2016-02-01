Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753585AbcBAV0C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Feb 2016 16:26:02 -0500
Date: Mon, 1 Feb 2016 16:26:01 -0500
To: NeilBrown <neilb@suse.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Dave Chinner <dchinner@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC] VFS: Improve fairness when locking the
 per-superblock s_anon list
Message-ID: <20160201212601.GE5499@fieldses.org>
References: <87fuxh1bo8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87fuxh1bo8.fsf@notabene.neil.brown.name>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 29, 2016 at 11:17:43AM +1100, NeilBrown wrote:
> bit-spin-locks, as used for dcache hash chains, are not fair.
> This is not a problem for the dcache hash table as different CPUs are
> likely to access different entries in the hash table so high contention
> is not expected.
> However anonymous dentryies (created by NFSD) all live on a single hash
> chain "s_anon" and the bitlock on this can be highly contended, resulting
> in soft-lockup warnings.

Just out of curiosity, because I can't recall seeing complaints about
warnings, when do you see it happen?  Server reboot, maybe?

It should be hitting that __d_obtain_alias() case only when a filehandle
lookup finds a file without a cached dentry, which is an important case
to handle, but not normally what I'd expect to be the common case.  Am I
forgetting something?

--b.

> 
> So introduce a global (fair) spinlock and take it before grabing the
> bitlock on s_anon.  This provides fairness and makes the warnings go away.
> 
> We could alternately use s_inode_list_lock, or add another spinlock
> to struct super_block.  Suggestions?
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> Dave: I'd guess you would be against using the new s_inode_list_lock
> for this because it is already highly contended - yes?
> Is it worth adding another spinlock to 'struct super_block' ?
> 
> Thanks,
> NeilBrown
> 
> 
>  fs/dcache.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 92d5140de851..e83f1ac1540c 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -104,6 +104,8 @@ static unsigned int d_hash_shift __read_mostly;
>  
>  static struct hlist_bl_head *dentry_hashtable __read_mostly;
>  
> +static DEFINE_SPINLOCK(s_anon_lock);
> +
>  static inline struct hlist_bl_head *d_hash(const struct dentry *parent,
>  					unsigned int hash)
>  {
> @@ -490,10 +492,14 @@ void __d_drop(struct dentry *dentry)
>  		else
>  			b = d_hash(dentry->d_parent, dentry->d_name.hash);
>  
> +		if (b == &dentry->d_sb->s_anon)
> +			spin_lock(&s_anon_lock);
>  		hlist_bl_lock(b);
>  		__hlist_bl_del(&dentry->d_hash);
>  		dentry->d_hash.pprev = NULL;
>  		hlist_bl_unlock(b);
> +		if (b == &dentry->d_sb->s_anon)
> +			spin_unlock(&s_anon_lock);
>  		dentry_rcuwalk_invalidate(dentry);
>  	}
>  }
> @@ -1978,9 +1984,11 @@ static struct dentry *__d_obtain_alias(struct inode *inode, int disconnected)
>  	spin_lock(&tmp->d_lock);
>  	__d_set_inode_and_type(tmp, inode, add_flags);
>  	hlist_add_head(&tmp->d_u.d_alias, &inode->i_dentry);
> +	spin_lock(&s_anon_lock);
>  	hlist_bl_lock(&tmp->d_sb->s_anon);
>  	hlist_bl_add_head(&tmp->d_hash, &tmp->d_sb->s_anon);
>  	hlist_bl_unlock(&tmp->d_sb->s_anon);
> +	spin_unlock(&s_anon_lock);
>  	spin_unlock(&tmp->d_lock);
>  	spin_unlock(&inode->i_lock);
>  	security_d_instantiate(tmp, inode);
> -- 
> 2.7.0
> 


