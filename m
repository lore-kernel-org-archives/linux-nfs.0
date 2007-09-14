From: Greg Banks <gnb@sgi.com>
Subject: Re: [NFS] [PATH 10/19] xfs: new export ops
Date: Sat, 15 Sep 2007 02:46:06 +1000
Message-ID: <20070914164606.GH25610@sgi.com>
References: <20070830131641.GK6834@lst.de> <20070914152216.GI21965@sgi.com> <20070914160349.GB6461@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070914160349.GB6461@lst.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Sep 14, 2007 at 06:03:49PM +0200, Christoph Hellwig wrote:
> On Sat, Sep 15, 2007 at 01:22:16AM +1000, Greg Banks wrote:
> > Not really a comment on your patches, but I got the original logic
> > wrong here.  The VFS_32BITINODES flag only affects newly allocated
> > inodes and is no guarantee that any particular inode is < 2^32-1.
> > It's possible for an unlucky user to perform a sequence of mounts
> > and IO which results in large inode numbers despite the presence of
> > that flag; we recently saw this happen by accident on a customer site.
> > So the right thing to do is probably to check the inode number against
> > (u32)~0.  Unfortunately, given the current encoding scheme, you have to
> > check both the inode and the parent inode, which complicates the logic.
> 
> I'll see if we can do anything later on.  But for now I'll leave it
> as-is becaue this file will be merge hell anyway when both vfs removal
> and exporting changes hit the tree..

Fair 'nuff.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.
