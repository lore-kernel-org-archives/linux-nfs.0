From: Christoph Hellwig <hch@lst.de>
Subject: [PATH 00/19] export operations rewrite
Date: Thu, 30 Aug 2007 15:15:38 +0200
Message-ID: <20070830131538.GA6834@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This patchset is a medium scale rewrite of the export operations
interface.  The goal is to make the interface less complex, and
easier to understand from the filesystem side, aswell as preparing
generic support for exporting of 64bit inode numbers.

This touches all nfs exporting filesystems, and I've done testing
on all of the filesystems I have here locally (xfs, ext2, ext3, reiserfs,
jfs)

Compared to the last version posted earlier this year I've moved the
generic fh_to_dentry and generic_fh_to_parent method to libfs.c so
that the filesystems don't have to pull in the exportfs module but
only nfsd has to.  That means I have to expose that ugly exportfs_d_alloc
helper, but I have plans to get rid of that one entirely by merging
it with d_alloc_anon.  More on that in another patch series.

Note that this patch series is against mainline.  There will be some
xfs changes landing in -mm soon that revamp lots of the code touched
here.  They should hopefully include the first path in the series so
it can be simply dropped, but the xfs conversion will need some smaller
updates.  I will send this update as soon as the xfs tree updates get
pulled into -mm.


--
