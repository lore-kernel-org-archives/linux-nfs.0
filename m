Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57342 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752013AbdBUPjU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Feb 2017 10:39:20 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/4] Skipped unlocks
Date: Tue, 21 Feb 2017 10:39:13 -0500
Message-Id: <cover.1487691345.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Well over a year ago I made other attempts to fix the problem of NFS failing
to send an unlock when signalled.  Those attempts were terrible.

Here's another, smaller version that keeps two simple fixes and takes the
approach of skipping the wait if FL_CLOSE is set as was suggested by Trond.

I think this is probably a little late for 4.11.  Comments and review are
welcomed.

since v1:
	- add Christoph's reviewed-by on 1/4 and 2/4 and fixup switch
	  indentation on 2/4
since v2:
	- don't sleep in rpciod to wait for I/O completion, just send the unlock
	  immediately for both v3 and v4.

Benjamin Coddington (4):
  NFS4: remove a redundant lock range check
  NFS: Move the flock open mode check into nfs_flock()
  locks: Set FL_CLOSE when removing flock locks on close()
  NFS: Always send an unlock for FL_CLOSE

 fs/locks.c        |  2 +-
 fs/nfs/file.c     | 28 +++++++++++++++++++++-------
 fs/nfs/nfs4proc.c | 17 -----------------
 3 files changed, 22 insertions(+), 25 deletions(-)

-- 
2.9.3

