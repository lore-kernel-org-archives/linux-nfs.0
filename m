Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52470 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934924AbdBQSqV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 13:46:21 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/4] Skipped unlocks
Date: Fri, 17 Feb 2017 13:46:16 -0500
Message-Id: <cover.1487356965.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Well over a year ago I made other attempts to fix the problem of NFS failing
to send an unlock when signalled.  Those attempts were terrible.

Here's another, smaller version that keeps two simple fixes and splits out
the behavior for waiting on I/O completion to be different for the v3 and v4
case.  For v4, we can easily ensure the unlock is always sent by having the
rpc_task perform the wait.  For v3, that approach would require significant
changes to the way NLM works, so a simpler approach of skipping the wait is
used as was suggested by Trond.

I think this is probably a little late for 4.11.  Comments and review are
welcomed.

since v1:
	- add Christoph's reviewed-by on 1/4 and 2/4 and fixup switch
	  indentation on 2/4

Benjamin Coddington (4):
  NFS4: remove a redundant lock range check
  NFS: Move the flock open mode check into nfs_flock()
  locks: Set FL_CLOSE when removing flock locks on close()
  NFS: Always wait for I/O completion before unlock

 fs/locks.c        |  2 +-
 fs/nfs/file.c     | 31 ++++++++++++++++---------------
 fs/nfs/nfs3proc.c | 13 +++++++++++++
 fs/nfs/nfs4proc.c | 24 +++++++-----------------
 fs/nfs/pagelist.c |  1 +
 5 files changed, 38 insertions(+), 33 deletions(-)

-- 
2.9.3

