Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47304 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755476AbaGOQ4i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 12:56:38 -0400
Date: Tue, 15 Jul 2014 09:56:37 -0700
From: Christoph Hellwig <hch@infradead.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/7] NFS: nfs4_lookup_revalidate: only evaluate parent if
 it will be used.
Message-ID: <20140715165637.GA22566@infradead.org>
References: <20140714011630.12562.1940.stgit@notabene.brown>
 <20140714012820.12562.14018.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140714012820.12562.14018.stgit@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 14, 2014 at 11:28:20AM +1000, NeilBrown wrote:
> nfs4_lookup_revalidate only uses 'parent' to get 'dir', and only
> uses 'dir' if 'inode == NULL'.
> 
> So we don't need to find out what 'parent' or 'dir' is until we
> know that 'inode' is NULL.
> 
> By moving 'dget_parent' inside the 'if', we can reduce the number of
> call sites for 'dput(parent)'.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

>  
>  	/* We can't create new files in nfs_open_revalidate(), so we
>  	 * optimize away revalidation of negative dentries.
>  	 */
>  	if (inode == NULL) {
> +		struct dentry *parent;
> +		struct inode *dir;
> +
> +		parent = dget_parent(dentry);
> +		dir = parent->d_inode;
>  		if (!nfs_neg_need_reval(dir, dentry, flags))
>  			ret = 1;
> +		dput(parent);
>  		goto out;

Seems like this could be further condensed to:

		struct dentry *parent = dget_parent(dentry);

		if (!nfs_neg_need_reval(parent->d_inode, dentry, flags))
			ret = 1;
		dput(parent);
		goto out;

or maybe even kill the goto out now that it's just a simple return
without additional work.

