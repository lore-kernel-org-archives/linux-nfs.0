Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v8 00/11] Fix OPEN/CLOSE races
Date: Mon,  6 Nov 2017 15:28:00 -0500
Message-Id: <20171106202811.70202-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

v2:
- Fix a sleep-while-atomic issue
- Clean up.    
- Add a tracepoint to help document wait incidents.
v3:
- Fix a state update issue
v4:
- Fix a race due to setting the state->flags before waiting on another
  compound (can cause issues if the other compound has an OPEN_DOWNGRADE).
- Fix stateid seqid wraparound.
v5:
- Fix race with wakeup after clearing NFS_STATE_CHANGE_WAIT
- Fix CLOSE, DELEGRETURN and LAYOUTRETURN issues with
  NFS4ERR_OLD_STATEID, which were causing stateid leakage
- cleanups
- Fix a typo in nfs_rename...
v6:
- Fix a compile issue when CONFIG_NFS_V4_1=n
v7:
- Fix a typo in nfs4_refresh_open_stateid (thanks Andrew Elble)
- Minor cleanups in nfs4_close_done, nfs4_delegreturn_done,
  nfs4_layoutreturn_done.
v8:
- Really fix compile issue when CONFIG_NFS_V4_1=n
- nfs_inode_find_state_and_recover() should also try to match the
  open_stateid.

Trond Myklebust (11):
  NFSv4: Fix OPEN / CLOSE race
  NFSv4: Add a tracepoint to document open stateid updates
  NFSv4: Fix open create exclusive when the server reboots
  NFS: Fix a typo in nfs_rename()
  NFSv4: Retry CLOSE and DELEGRETURN on NFS4ERR_OLD_STATEID.
  NFSv4: Don't try to CLOSE if the stateid 'other' field has changed
  pNFS: Retry NFS4ERR_OLD_STATEID errors in layoutreturn-on-close
  NFSv4: Retry NFS4ERR_OLD_STATEID errors in layoutreturn
  NFSv4: cleanup nfs4_close_done
  NFSv4: Clean up nfs4_delegreturn_done
  NFSv4: Check the open stateid when searching for expired state

 fs/nfs/delegation.c |  27 +++++
 fs/nfs/delegation.h |   1 +
 fs/nfs/dir.c        |   2 +-
 fs/nfs/nfs4_fs.h    |   7 ++
 fs/nfs/nfs4proc.c   | 293 +++++++++++++++++++++++++++++++++++++---------------
 fs/nfs/nfs4state.c  |  31 +++++-
 fs/nfs/nfs4trace.h  |   2 +
 fs/nfs/pnfs.c       |  18 ++++
 fs/nfs/pnfs.h       |   6 ++
 9 files changed, 300 insertions(+), 87 deletions(-)

-- 
2.13.6
