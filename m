Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15942 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932827Ab0AFU7d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 15:59:33 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/6] Re: [PATCH] improve the performance of large
 sequential write NFS workloads
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
        Steve Rago <sar@nec-labs.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jens.axboe" <jens.axboe@oracle.com>,
        Peter Staubach <staubach@redhat.com>,
        Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Date: Wed, 06 Jan 2010 15:51:10 -0500
Message-ID: <20100106205110.22547.85345.stgit@localhost.localdomain>
In-Reply-To: <20100106200928.GB22781@quack.suse.cz>
References: <20100106200928.GB22781@quack.suse.cz>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

OK, here is the full series so far. I'm resending because I had to fix
up a couple of BDI_UNSTABLE typos in Peter's patch...

Cheers
  Trond

---

Peter Zijlstra (1):
      VM: Split out the accounting of unstable writes from BDI_RECLAIMABLE

Trond Myklebust (5):
      NFS: Run COMMIT as an asynchronous RPC call when wbc->for_background is set
      VM: Use per-bdi unstable accounting to improve use of wbc->force_commit
      VM: Don't call bdi_stat(BDI_UNSTABLE) on non-nfs backing-devices
      VM/NFS: The VM must tell the filesystem when to free reclaimable pages
      VFS: Ensure that writeback_single_inode() commits unstable writes


 fs/fs-writeback.c           |   31 ++++++++++++++++++++++++++++++-
 fs/nfs/client.c             |    1 +
 fs/nfs/file.c               |    1 +
 fs/nfs/inode.c              |   16 ----------------
 fs/nfs/internal.h           |    3 ++-
 fs/nfs/super.c              |    2 --
 fs/nfs/write.c              |   39 +++++++++++++++++++++++++++++++++++----
 include/linux/backing-dev.h |    9 ++++++++-
 include/linux/fs.h          |    9 +++++++++
 include/linux/writeback.h   |    5 +++++
 mm/backing-dev.c            |    6 ++++--
 mm/filemap.c                |    2 +-
 mm/page-writeback.c         |   30 ++++++++++++++++++++++++------
 mm/truncate.c               |    2 +-
 14 files changed, 121 insertions(+), 35 deletions(-)

