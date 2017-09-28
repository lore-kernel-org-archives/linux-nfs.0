Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:14889 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752475AbdI1RaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:30:19 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 00/10] NFSD support for asynchronous COPY 
Date: Thu, 28 Sep 2017 13:29:35 -0400
Message-ID: <20170928172945.50780-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To do asynchronous copies, NFSD creates a single threaded workqueue
and does not tie up an NFSD thread to complete the copy. Upon receiving
the COPY, it generates a unique copy stateid (stores a global list
for keeping track of state for OFFLOAD_STATUS to be queried by),
queues up a workqueue for the copy, and replies back to the client.
nfsd4_copy arguments that are allocated on the stack are copied for
the work item.

In the async copy handler, it calls into VFS copy_file_range() with
4MB chunks and loops until it completes the requested copy size. If
error is encountered it's saved but also we save the amount of data
copied so far. Once done, the results are queued for the callback
workqueue and sent via CB_OFFLOAD. Also currently, choosing to clean
up the copy state information stored in the global list when cope is
done and not doing it when callback's release function (it could be
done there alternatively if needed it?).

When the source server received an OFFLOAD_CANCEL, it will remove the
stateid from the global list and mark the copy cancelled. If its
cancelled we are choosing not to send the CB_OFFLOAD back to the client.

Olga Kornievskaia (10):
  NFSD CB_OFFLOAD xdr
  NFSD OFFLOAD_STATUS xdr
  NFSD OFFLOAD_CANCEL xdr
  NFSD xdr callback stateid in async COPY reply
  NFSD first draft of async copy
  NFSD return nfs4_stid in nfs4_preprocess_stateid_op
  NFSD create new stateid for async copy
  NFSD handle OFFLOAD_CANCEL op
  NFSD support OFFLOAD_STATUS
  NFSD stop queued async copies on client shutdown

 fs/nfsd/netns.h        |   8 ++
 fs/nfsd/nfs4callback.c |  97 +++++++++++++++++
 fs/nfsd/nfs4proc.c     | 276 ++++++++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4state.c    | 100 +++++++++++++++++-
 fs/nfsd/nfs4xdr.c      |  53 ++++++++--
 fs/nfsd/nfsctl.c       |   1 +
 fs/nfsd/state.h        |  27 ++++-
 fs/nfsd/xdr4.h         |  25 +++++
 fs/nfsd/xdr4cb.h       |  10 ++
 9 files changed, 559 insertions(+), 38 deletions(-)

-- 
1.8.3.1

