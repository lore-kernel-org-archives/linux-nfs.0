Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:20664 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752253AbeBTQv5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Feb 2018 11:51:57 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v7 00/10] NFSD support for asynchronous COPY
Date: Tue, 20 Feb 2018 11:42:19 -0500
Message-ID: <20180220164229.65404-1-kolga@netapp.com>
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

v7 addresses Bruce's comments:
1. hardcoding returning 0bytes for the error case
2. shutting down copy before shutting down callback
3. adding the copy to the list of copies after the copy_task is initialized
4. introducing the async code but not enabling it until after the following
patches add creating and returning the unique stateid for the async copy.
5. changing copy's refcount from atomic_t to refcount_t
6. making sure that list sc_cp_list is accessed under the pstid->sc_lock

Olga Kornievskaia (10):
  NFSD CB_OFFLOAD xdr
  NFSD OFFLOAD_STATUS xdr
  NFSD OFFLOAD_CANCEL xdr
  NFSD xdr callback stateid in async COPY reply
  NFSD introduce asynch copy feature
  NFSD return nfs4_stid in nfs4_preprocess_stateid_op
  NFSD create new stateid for async copy
  NFSD handle OFFLOAD_CANCEL op
  NFSD support OFFLOAD_STATUS
  NFSD stop queued async copies on client shutdown

 fs/nfsd/netns.h        |   8 ++
 fs/nfsd/nfs4callback.c |  98 +++++++++++++++
 fs/nfsd/nfs4proc.c     | 317 ++++++++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4state.c    |  80 ++++++++++++-
 fs/nfsd/nfs4xdr.c      |  50 ++++++--
 fs/nfsd/nfsctl.c       |   1 +
 fs/nfsd/state.h        |  21 +++-
 fs/nfsd/xdr4.h         |  28 +++++
 fs/nfsd/xdr4cb.h       |  10 ++
 9 files changed, 576 insertions(+), 37 deletions(-)

-- 
1.8.3.1

