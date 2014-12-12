Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48108 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965570AbaLLKvZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2014 05:51:25 -0500
Date: Fri, 12 Dec 2014 11:51:22 +0100
From: David Sterba <dsterba@suse.cz>
To: Omar Sandoval <osandov@osandov.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v3 7/7] btrfs: enable swap file support
Message-ID: <20141212105122.GN27601@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <cover.1418173063.git.osandov@osandov.com>
 <0f9937165d8fc1b8b6332ac97e59593022e9fa5b.1418173063.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0f9937165d8fc1b8b6332ac97e59593022e9fa5b.1418173063.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 09, 2014 at 05:45:48PM -0800, Omar Sandoval wrote:
> +static void __clear_swapfile_extents(struct inode *inode)
> +{
> +	u64 isize = inode->i_size;
> +	struct extent_map *em;
> +	u64 start, len;
> +
> +	start = 0;
> +	while (start < isize) {
> +		len = isize - start;
> +		em = btrfs_get_extent(inode, NULL, 0, start, len, 0);
> +		if (IS_ERR(em))
> +			return;

This could transiently fail if there's no memory to allocate the em, and
would leak the following extents.

> +
> +		clear_bit(EXTENT_FLAG_SWAPFILE, &em->flags);
> +
> +		start = extent_map_end(em);
> +		free_extent_map(em);
> +	}
> +}
> +
> +static int btrfs_swap_activate(struct swap_info_struct *sis, struct file *file,
> +			       sector_t *span)
> +{
> +	struct inode *inode = file_inode(file);
> +	struct btrfs_fs_info *fs_info = BTRFS_I(inode)->root->fs_info;
> +	struct extent_io_tree *io_tree = &BTRFS_I(inode)->io_tree;
> +	int ret = 0;
> +	u64 isize = inode->i_size;
> +	struct extent_state *cached_state = NULL;
> +	struct extent_map *em;
> +	u64 start, len;
> +
> +	if (BTRFS_I(inode)->flags & BTRFS_INODE_COMPRESS) {
> +		/* Can't do direct I/O on a compressed file. */
> +		btrfs_err(fs_info, "swapfile is compressed");
> +		return -EINVAL;
> +	}
> +	if (!(BTRFS_I(inode)->flags & BTRFS_INODE_NODATACOW)) {
> +		/*
> +		 * Going through the copy-on-write path while swapping pages
> +		 * in/out and doing a bunch of allocations could stress the
> +		 * memory management code that got us there in the first place,
> +		 * and that's sure to be a bad time.
> +		 */
> +		btrfs_err(fs_info, "swapfile is copy-on-write");
> +		return -EINVAL;
> +	}
> +
> +	lock_extent_bits(io_tree, 0, isize - 1, 0, &cached_state);
> +
> +	/*
> +	 * All of the extents must be allocated and support direct I/O. Inline
> +	 * extents and compressed extents fall back to buffered I/O, so those
> +	 * are no good. Additionally, all of the extents must be safe for nocow.
> +	 */
> +	atomic_inc(&BTRFS_I(inode)->root->nr_swapfiles);
> +	start = 0;
> +	while (start < isize) {
> +		len = isize - start;
> +		em = btrfs_get_extent(inode, NULL, 0, start, len, 0);
> +		if (IS_ERR(em)) {

		IS_ERR_OR_NULL(em)
