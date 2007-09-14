From: Christoph Hellwig <hch@lst.de>
Subject: Re: [NFS] [PATH 04/19] ext2: new export ops
Date: Fri, 14 Sep 2007 17:01:09 +0200
Message-ID: <20070914150109.GA4154@lst.de>
References: <20070830131609.GE6834@lst.de> <20070914145803.GH21965@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070914145803.GH21965@sgi.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Sep 15, 2007 at 12:58:03AM +1000, Greg Banks wrote:
> These patches look good, and cleanup in this area is certainly a
> good thing.  One small comment: the easy filesystems (ext[234], efs,
> ntfs) might be cleaner if the per-fs get_inode function were a member
> of export_ops instead of an extra argument to generic_fh_to_dentry().
> That way you wouldn't need these two little helper functions in each
> filesystem, because you could point export_ops.fh_to_dentry directly
> at generic_fh_to_dentry.

I was pondering this, but in the end I prefer the cleaner layering of
the callback version.  This also mirrors what we do in other areas
(e.g. address_space operations)
