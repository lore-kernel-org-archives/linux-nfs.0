Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51851 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752738AbaIXCDH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 22:03:07 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 24 Sep 2014 11:28:32 +1000
Subject: [PATCH 0/5]  Remove possible deadlocks in nfs_release_page() - V3
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>,
        linux-fsdevel@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Peter Zijlstra <peterz@infradead.org>
Message-ID: <20140924012422.4838.29188.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This set includes acked-by's from Andrew and Peter so it should be
OK for all five patches to go upstream through the NFS tree.

I split the congestion tracking patch out from the wait-for-PG_private
patch as they are conceptually separate.

This set continues to perform well in my tests and addresses all
issues that have been raised.

Thanks a lot,
NeilBrown


---

NeilBrown (5):
      SCHED: add some "wait..on_bit...timeout()" interfaces.
      MM: export page_wakeup functions
      NFS: avoid deadlocks with loop-back mounted NFS filesystems.
      NFS: avoid waiting at all in nfs_release_page when congested.
      NFS/SUNRPC: Remove other deadlock-avoidance mechanisms in nfs_release_page()


 fs/nfs/file.c                   |   29 +++++++++++++++++++----------
 fs/nfs/write.c                  |    7 +++++++
 include/linux/pagemap.h         |   12 ++++++++++--
 include/linux/wait.h            |    5 ++++-
 kernel/sched/wait.c             |   36 ++++++++++++++++++++++++++++++++++++
 mm/filemap.c                    |   21 +++++++++++++++------
 net/sunrpc/sched.c              |    2 --
 net/sunrpc/xprtrdma/transport.c |    2 --
 net/sunrpc/xprtsock.c           |   10 ----------
 9 files changed, 91 insertions(+), 33 deletions(-)

-- 
Signature

