Return-Path: <hch@lst.de>
Date: Wed, 27 Apr 2016 09:53:19 +0200
From: Christoph Hellwig <hch@lst.de>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org, hch@lst.de
Subject: Re: blocklayoutdriver and page_cache_next_hole
Message-ID: <20160427075319.GC28726@lst.de>
References: <alpine.OSX.2.19.9992.1604261302250.92748@planck>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.OSX.2.19.9992.1604261302250.92748@planck>
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 26, 2016 at 01:27:02PM -0400, Benjamin Coddington wrote:
> I'm doing some benchmarking on SCSI layout, and I ran into a case where
> bonnie++ seemingly stopped making forward progress.
> 
> bl_pg_init_write() wants to figure out how big the layout should be and uses
> page_cache_next_hole() pretty aggressively if the inode size isn't equal to
> the mapping.  Problem is that page_cache_next_hole() is fairly stupid about
> just walking through the page_cache radix tree by index.
> 
> The end result is that for fairly large files (>4G) my machine spends all
> its time in __radix_tree_lookup(), and I might as well just use regular NFS.

Haha.  One option is to simply optimize page_cache_next_hole, as that
should be easy and the read-ahead could would benefit as well.  Or make
NFS pass through the writeback size and stop hacking around upper layers
in the layout driver.  Both seem like useful options.
