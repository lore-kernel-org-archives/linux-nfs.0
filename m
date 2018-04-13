Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:52109 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750940AbeDMRCA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Apr 2018 13:02:00 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v8 0/9] NFSD support for async COPY
Date: Fri, 13 Apr 2018 13:01:49 -0400
Message-ID: <20180413170158.17589-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To do asynchronous copies, NFSD creates a new kthread to handle the request.
Upon receiving the COPY, it generates a unique copy stateid (stored in a
global list for keeping track of state for OFFLOAD_STATUS to be queried by),
starts the thread, and replies back to the client. nfsd4_copy arguments that
are allocated on the stack are copies for the kthread.

For the async copy handler, copy is done in the loop for the requested
number of bytes. If an error is encountered and partial copy has happened,
a successful partial copy is returned in the CB_OFFLOAD. vfs_copy_file_range
is called with 4MB chunks for both async and sync, allowing for 4MB
granularity of OFFLOAD_STATUS queiry. Once copy is done, the results are
queued for the callback workqueue and sent via CB_OFFLOAD.

When the server received an OFFLOAD_CANCEL, it will find the kthread running
the copy and will send a SIGPENDING and kthread_stop() and it will interrupt
the ongoing do_splice() and once vfs returns we are choosing not to send
the CB_OFFLOAD back to the client.

When the server receives an OFFLOAD_STATUS, it will find the kthread running
the copy and will locate within the copy state the current number of bytes
copied so far.

v8 addressing comments from the reviews
-- add comment in the code that we ignore error on copy
-- changed "fh_dst/src" to "file_dst/src"
-- dropped keeping "net", "stid" from the nfsd4_copy
-- removed "remove" arg from cleanup_async_copy()
-- reworked shutdown copy patch to 1) check for on going copies in
client_has_state() 2) reworked a bit the signalling code to incorporate
code that made sure only 1 thread can stop the thread. otherwise, if
somehow 2 things are trying to shutdown the copy, the 2nd one will hang.
-- removed storing parent state in the nfsd4_copy structure
-- removed nfs4_cp_state as we no longer need the list of them and moved
the stateid_t into nfsd4_copy itself
-- no longer taking a reference on the nfs4_client as on destruction
of that structure we make sure to store any copies.

Olga Kornievskaia (9):
  NFSD CB_OFFLOAD xdr
  NFSD OFFLOAD_STATUS xdr
  NFSD OFFLOAD_CANCEL xdr
  NFSD xdr callback stateid in async COPY reply
  NFSD introduce async copy feature
  NFSD create new stateid for async copy
  NFSD handle OFFLOAD_CANCEL op
  NFSD support OFFLOAD_STATUS
  NFSD stop ongoing async copies on client shutdown

 fs/nfsd/netns.h        |   8 ++
 fs/nfsd/nfs4callback.c |  98 +++++++++++++++++
 fs/nfsd/nfs4proc.c     | 290 ++++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfs4state.c    |  38 ++++++-
 fs/nfsd/nfs4xdr.c      |  50 +++++++--
 fs/nfsd/nfsctl.c       |   1 +
 fs/nfsd/state.h        |  10 ++
 fs/nfsd/xdr4.h         |  28 +++++
 fs/nfsd/xdr4cb.h       |  10 ++
 9 files changed, 509 insertions(+), 24 deletions(-)

-- 
1.8.3.1

