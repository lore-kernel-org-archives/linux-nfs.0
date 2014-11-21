Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:59621 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824AbaKUSAr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Nov 2014 13:00:47 -0500
Date: Fri, 21 Nov 2014 19:00:45 +0100
From: David Sterba <dsterba@suse.cz>
To: Omar Sandoval <osandov@osandov.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 5/5] btrfs: enable swap file support
Message-ID: <20141121180045.GF8568@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <cover.1416563833.git.osandov@osandov.com>
 <afd3c1009172a4a1cfa10e73a64caf35c631a6d4.1416563833.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <afd3c1009172a4a1cfa10e73a64caf35c631a6d4.1416563833.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 21, 2014 at 02:08:31AM -0800, Omar Sandoval wrote:
> Implement the swap file a_ops on btrfs. Activation simply checks for a usable
> swap file: it must be fully allocated (no holes), support direct I/O (so no
> compressed or inline extents) and should be nocow (I'm not sure about that last
> one).
> 
> Signed-off-by: Omar Sandoval <osandov@osandov.com>
> ---
>  fs/btrfs/inode.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 71 insertions(+)
> 
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index d23362f..b8fd36b 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -9442,6 +9442,75 @@ out_inode:
>  
>  }
>  
> +static int btrfs_swap_activate(struct swap_info_struct *sis, struct file *file,
> +			       sector_t *span)
> +{
> +	struct inode *inode = file_inode(file);
> +	struct btrfs_inode *ip = BTRFS_I(inode);

'ip' looks strange in context of a filesystem, please pick a different
name (eg. 'inode' or whatever).

> +	int ret = 0;
> +	u64 isize = inode->i_size;
> +	struct extent_state *cached_state = NULL;
> +	struct extent_map *em;
> +	u64 start, len;
> +
> +	if (ip->flags & BTRFS_INODE_COMPRESS) {
> +		/* Can't do direct I/O on a compressed file. */
> +		pr_err("BTRFS: swapfile is compressed");

Please use the btrfs_err macros everywhere.

> +		return -EINVAL;
> +	}
> +	if (!(ip->flags & BTRFS_INODE_NODATACOW)) {
> +		/* The swap file can't be copy-on-write. */
> +		pr_err("BTRFS: swapfile is copy-on-write");
> +		return -EINVAL;
> +	}
> +
> +	lock_extent_bits(&ip->io_tree, 0, isize - 1, 0, &cached_state);
> +
> +	/*
> +	 * All of the extents must be allocated and support direct I/O. Inline
> +	 * extents and compressed extents fall back to buffered I/O, so those
> +	 * are no good.
> +	 */
> +	start = 0;
> +	while (start < isize) {
> +		len = isize - start;
> +		em = btrfs_get_extent(inode, NULL, 0, start, len, 0);
> +		if (IS_ERR(em)) {
> +			ret = PTR_ERR(em);
> +			goto out;
> +		}
> +
> +		if (test_bit(EXTENT_FLAG_VACANCY, &em->flags) ||
> +		    em->block_start == EXTENT_MAP_HOLE) {

If the no-holes feature is enabled on the filesystem, there won't be any
such extent representing the hole. You have to check that each two
consecutive extents are adjacent.

> +			pr_err("BTRFS: swapfile has holes");
> +			ret = -EINVAL;
> +			goto out;
> +		}
> +		if (em->block_start == EXTENT_MAP_INLINE) {
> +			pr_err("BTRFS: swapfile is inline");

While the test is valid, this would mean that the file is smaller than
the inline limit, which is now one page. I think the generic swap code
would refuse such a small file anyway.

> +			ret = -EINVAL;
> +			goto out;
> +		}
> +		if (test_bit(EXTENT_FLAG_COMPRESSED, &em->flags)) {
> +			pr_err("BTRFS: swapfile is compresed");
> +			ret = -EINVAL;
> +			goto out;
> +		}

I think the preallocated extents should be refused as well. This means
the filesystem has enough space to hold the data but it would still have
to go through the allocation and could in turn stress the memory
management code that triggered the swapping activity in the first place.

Though it's probably still possible to reach such corner case even with
fully allocated nodatacow file, this should be reviewed anyway.

> +
> +		start = extent_map_end(em);
> +		free_extent_map(em);
> +	}
> +
> +out:
> +	unlock_extent_cached(&ip->io_tree, 0, isize - 1, &cached_state,
> +			     GFP_NOFS);
> +	return ret;
> +}
