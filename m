From: Christoph Hellwig <hch@lst.de>
Subject: Re: [NFS] [PATH 10/19] xfs: new export ops
Date: Fri, 14 Sep 2007 18:03:49 +0200
Message-ID: <20070914160349.GB6461@lst.de>
References: <20070830131641.GK6834@lst.de> <20070914152216.GI21965@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070914152216.GI21965@sgi.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Sep 15, 2007 at 01:22:16AM +1000, Greg Banks wrote:
> Not really a comment on your patches, but I got the original logic
> wrong here.  The VFS_32BITINODES flag only affects newly allocated
> inodes and is no guarantee that any particular inode is < 2^32-1.
> It's possible for an unlucky user to perform a sequence of mounts
> and IO which results in large inode numbers despite the presence of
> that flag; we recently saw this happen by accident on a customer site.
> So the right thing to do is probably to check the inode number against
> (u32)~0.  Unfortunately, given the current encoding scheme, you have to
> check both the inode and the parent inode, which complicates the logic.

I'll see if we can do anything later on.  But for now I'll leave it
as-is becaue this file will be merge hell anyway when both vfs removal
and exporting changes hit the tree..

