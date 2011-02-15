Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34099 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454Ab1BOJZc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 04:25:32 -0500
Date: Tue, 15 Feb 2011 04:25:31 -0500
From: Christoph Hellwig <hch@infradead.org>
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Fred Isaman <iisaman@netapp.com>, Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 08/16] pnfs: wave 3: lseg refcounting
Message-ID: <20110215092531.GB29871@infradead.org>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
 <1297711116-3139-9-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1297711116-3139-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> +_put_lseg_common(struct pnfs_layout_segment *lseg)

The naming of _put_lseg_common is pretty weird compared to standard Linux
function naming.  I'd either expect __put_lseg or put_lseg_common.

> +{
> +	struct inode *ino = lseg->pls_layout->plh_inode;

Please call this inode.  ino is usually used for variables of type ino_t.


> +	BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
> +	list_del(&lseg->pls_list);
> +	if (list_empty(&lseg->pls_layout->plh_segs)) {
> +		set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
> +		/* Matched by initial refcount set in alloc_init_layout_hdr */
> +		put_layout_hdr_locked(lseg->pls_layout);
> +	}
> +	rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
> +}
> +



> @@ -242,22 +257,35 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
>  		atomic_read(&lseg->pls_refcount),
>  		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
>  	if (atomic_dec_and_test(&lseg->pls_refcount)) {
> +		_put_lseg_common(lseg);
>  		list_add(&lseg->pls_list, tmp_list);
>  		return 1;
>  	}
>  	return 0;

Given that put_lseg_locked is pretty trivial now, and has a awkward
calling convention I would just inline it into the only caller.

> +static void
> +put_lseg(struct pnfs_layout_segment *lseg)
> +{
> +	struct inode *ino;

Again, please call this inode.

> +
> +	if (!lseg)
> +		return;
> +
> +	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
> +		atomic_read(&lseg->pls_refcount),
> +		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
> +	ino = lseg->pls_layout->plh_inode;
> +	if (atomic_dec_and_lock(&lseg->pls_refcount, &ino->i_lock)) {
> +		LIST_HEAD(free_me);
> +
> +		_put_lseg_common(lseg);
> +		list_add(&lseg->pls_list, &free_me);
> +		spin_unlock(&ino->i_lock);
> +		pnfs_free_lseg_list(&free_me);
> +	}

What's the point of the list operations here?  You'd be much better to
just do a

	free_lseg(lseg);

after releasing the lock.

