Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53234 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbaIPFca (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Sep 2014 01:32:30 -0400
From: NeilBrown <neilb@suse.de>
To: Peter Zijlstra <peterz@infradead.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Ingo Molnar <mingo@redhat.com>
Date: Tue, 16 Sep 2014 15:31:34 +1000
Subject: [PATCH 0/4] Remove possible deadlocks in nfs_release_page()
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jeff Layton <jeff.layton@primarydata.com>
Message-ID: <20140916051911.22257.24658.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Because nfs_release_page() submits a 'COMMIT' nfs request and waits
for it to complete, and does this during memory reclaim, it is
susceptible to deadlocks if memory allocation happens anywhere in
sending the COMMIT message.  If the NFS server is on the same host
(i.e. loop-back NFS), then any memory allocations in the NFS server
can also cause deadlocks.

nfs_release_page() already has some code to avoid deadlocks in some
circumstances, but these are not sufficient for loopback NFS.

This patch set changes the approach to deadlock avoidance.  Rather
than detecting cases that could deadlock and avoiding the COMMIT, it
always tries the COMMIT, but only waits a short time (1 second).
This avoid any deadlock possibility at the expense of not waiting
longer than 1 second even if no deadlock is pending.

nfs_release_page() does not *need* to wait longer - all callers that
matter handle a failure gracefully - they move on to other pages.

This set:
 - adds some "_timeout()" functions to "wait_on_bit".  Only a
   wait_on_page version is actually used.
 - exports page wake_up support.  NFS knows that the COMMIT is complete
   when PG_private is clear.  So nfs_release_page will use
   wait_on_page_bit_killable_timeout to wait for the bit to clear,
   and needs access to wake_up_page()
 - changes nfs_release_page() to use
    wait_on_page_bit_killable_timeout()
 - removes the other deadlock avoidance mechanisms from
   nfs_release_page, so that PF_FSTRANS is again only used
   by XFS.

As such, it needs buy-in from sched people, mm people, and NFS people.
Assuming I get that buy-in, suggests for how these patches can flow
into mainline would be appreciated ... I daren't hope they can all go
in through one tree....

Thanks,
NeilBrown


---

NeilBrown (4):
      SCHED: add some "wait..on_bit...timeout()" interfaces.
      MM: export page_wakeup functions
      NFS: avoid deadlocks with loop-back mounted NFS filesystems.
      NFS/SUNRPC: Remove other deadlock-avoidance mechanisms in nfs_release_page()


 fs/nfs/file.c                   |   22 ++++++++++++----------
 fs/nfs/write.c                  |    2 ++
 include/linux/pagemap.h         |   12 ++++++++++--
 include/linux/wait.h            |    5 ++++-
 kernel/sched/wait.c             |   36 ++++++++++++++++++++++++++++++++++++
 mm/filemap.c                    |   21 +++++++++++++++------
 net/sunrpc/sched.c              |    2 --
 net/sunrpc/xprtrdma/transport.c |    2 --
 net/sunrpc/xprtsock.c           |   10 ----------
 9 files changed, 79 insertions(+), 33 deletions(-)

-- 
Signature

