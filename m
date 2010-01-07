From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/5] Re: [PATCH] improve the performance of large
 sequential write NFS workloads
Date: Thu, 07 Jan 2010 09:41:42 -0500
Message-ID: <20100107144137.17158.53673.stgit@localhost.localdomain>
References: <20100107143735.GA20300@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17898 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342Ab0AGOoj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 09:44:39 -0500
In-Reply-To: <20100107143735.GA20300@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Take 3. Incorporate Fengguang's suggestion that we change the name of
the force_commit flag.

Cheers
  Trond

---

Peter Zijlstra (1):
      VM: Split out the accounting of unstable writes from BDI_RECLAIMABLE

Trond Myklebust (4):
      NFS: Run COMMIT as an asynchronous RPC call when wbc->for_background is set
      VM/NFS: The VM must tell the filesystem when to free reclaimable pages
      VM: Don't call bdi_stat(BDI_UNSTABLE) on non-nfs backing-devices
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

