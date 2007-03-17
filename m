From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 0/18] export operations rewrite
Date: Sat, 17 Mar 2007 01:09:46 +0000
Message-ID: <20070317010946.GA24947@infradead.org>
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
