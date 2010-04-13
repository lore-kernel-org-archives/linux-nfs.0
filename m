Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15369 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752945Ab0DMVyi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Apr 2010 17:54:38 -0400
Subject: [GIT PULL] Please pull NFS client fixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 13 Apr 2010 17:54:21 -0400
Message-ID: <1271195661.6413.212.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/client.c           |    3 ++-
 fs/nfs/dir.c              |    2 +-
 fs/nfs/inode.c            |    8 ++++----
 fs/nfs/nfs4proc.c         |    4 +++-
 fs/nfs/write.c            |   44 ++++++++++++++++++++++++++++----------------
 include/linux/nfs_fs_sb.h |    1 +
 6 files changed, 39 insertions(+), 23 deletions(-)

commit 0df5dd4aae211edeeeb84f7f84f6d093406d7c22
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Apr 11 16:48:44 2010 -0400

    NFSv4: fix delegated locking
    
    Arnaud Giersch reports that NFSv4 locking is broken when we hold a
    delegation since commit 8e469ebd6dc32cbaf620e134d79f740bf0ebab79 (NFSv4:
    Don't allow posix locking against servers that don't support it).
    
    According to Arnaud, the lock succeeds the first time he opens the file
    (since we cannot do a delegated open) but then fails after we start using
    delegated opens.
    
    The following patch fixes it by ensuring that locking behaviour is
    governed by a per-filesystem capability flag that is initially set, but
    gets cleared if the server ever returns an OPEN without the
    NFS4_OPEN_RESULT_LOCKTYPE_POSIX flag being set.
    
    Reported-by: Arnaud Giersch <arnaud.giersch@iut-bm.univ-fcomte.fr>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 2c61be0a9478258f77b66208a0c4b1f5f8161c3c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 9 19:54:50 2010 -0400

    NFS: Ensure that the WRITE and COMMIT RPC calls are always uninterruptible
    
    We always want to ensure that WRITE and COMMIT completes, whether or not
    the user presses ^C. Do this by making the call asynchronous, and allowing
    the user to do an interruptible wait for rpc_task completion.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a6305ddb080fb483ca41ca56cacb6f96089f0c8e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 9 19:07:08 2010 -0400

    NFS: Fix a race with the new commit code
    
    This patch fixes a race which occurs due to the fact that we release the
    PG_writeback flag while still holding the nfs_page locked.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b80c3cb628f0ebc241b02e38dd028969fb8026a2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Apr 9 19:07:07 2010 -0400

    NFS: Ensure that writeback_single_inode() calls write_inode() when syncing
    
    Since writeback_single_inode() checks the inode->i_state flags _before_ it
    flushes out the data, we need to ensure that the I_DIRTY_DATASYNC flag is
    already set. Otherwise we risk not seeing a call to write_inode(), which
    again means that we break fsync() et al...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1544fa0f7a46241582abc48f07b74f3d846379e4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Mar 25 13:54:49 2010 -0400

    NFS: Fix the mode calculation in nfs_find_open_context
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 80e60639f1b7c121a7fea53920c5a4b94009361a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Mar 25 13:51:05 2010 -0400

    NFSv4: Fall back to ordinary lookup if nfs4_atomic_open() returns EISDIR
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org


