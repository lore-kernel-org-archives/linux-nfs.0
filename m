Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17535 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752730Ab0AYWjH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:39:07 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/12] Re: [PATCH] improve the performance of large
 sequential write NFS workloads
To: linux-nfs@vger.kernel.org
Cc: Wu Fengguang <fengguang.wu@intel.com>,
        Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
        Steve Rago <sar@nec-labs.com>, Jens Axboe <jens.axboe@oracle.com>,
        Peter Staubach <staubach@redhat.com>,
        Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@ZenIV.linux.org.uk>
Date: Mon, 25 Jan 2010 17:15:45 -0500
Message-ID: <20100125221544.16750.70574.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This patch series is a follow up to the series that was posted on Jan
8th. Following the discussion with Christoph and Al, I've rebased the
patch series on top of Al's 'write_inode' branch (see
http://git.kernel.org/?p=linux/kernel/git/viro/vfs-2.6.git;a=summary).

The main changes compared to the previous iteration of these patches are
as follows:
  - Rewrite to take advantage of Christoph's improvements to the
    s_op->write_inode() callback, and writeback_single_inode().

  - Added a bunch of cleanups to simplify the NFS writeback code by
    using sync_inode() where possible.

  - Appended a tentative fix for the mmap() lockdep issue.

If you would like to test it out, please feel free to pull the
"performance-for-next" branch from
        git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git

I hope to start submitting this into the linux-next tree within a few
days unless there are objections.

Cheers
  Trond

---

Peter Zijlstra (1):
      VM: Split out the accounting of unstable writes from BDI_RECLAIMABLE

Trond Myklebust (11):
      NFS: Remove requirement for inode->i_mutex from nfs_invalidate_mapping
      NFS: Clean up nfs_sync_mapping
      NFS: Simplify nfs_wb_page()
      NFS: Replace __nfs_write_mapping with sync_inode()
      NFS: Simplify nfs_wb_page_cancel()
      NFS: Ensure inode is always marked I_DIRTY_DATASYNC, if it has unstable pages
      NFS: Run COMMIT as an asynchronous RPC call when wbc->for_background is set
      VM/NFS: The VM must tell the filesystem when to free reclaimable pages
      NFS: Reduce the number of unnecessary COMMIT calls
      NFS: Cleanup - move nfs_write_inode() into fs/nfs/write.c
      VM: Don't call bdi_stat(BDI_UNSTABLE) on non-nfs backing-devices


 fs/nfs/client.c             |    1 
 fs/nfs/dir.c                |    2 
 fs/nfs/inode.c              |   67 +-----------
 fs/nfs/symlink.c            |    2 
 fs/nfs/write.c              |  233 ++++++++++++-------------------------------
 include/linux/backing-dev.h |    9 +-
 include/linux/nfs_fs.h      |   12 --
 include/linux/writeback.h   |    5 +
 mm/backing-dev.c            |    6 +
 mm/filemap.c                |    2 
 mm/page-writeback.c         |   30 ++++--
 mm/truncate.c               |    2 
 12 files changed, 118 insertions(+), 253 deletions(-)

-- 
Signature
