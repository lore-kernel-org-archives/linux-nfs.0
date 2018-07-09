Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:50458 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932813AbeGIT00 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Jul 2018 15:26:26 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v9 0/9] NFSD support for async COPY
Date: Mon, 9 Jul 2018 15:26:29 -0400
Message-ID: <20180709192638.44799-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <olga.kornievskaia@gmail.com>

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

v9:
-- added module parameter (async_copy_offload_enable) to turns on async
copy processing on the server
-- fixes some kbuild errors from the previous submission


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
 fs/nfsd/nfs4proc.c     | 291 ++++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfs4state.c    |  38 ++++++-
 fs/nfsd/nfs4xdr.c      |  50 +++++++--
 fs/nfsd/nfsctl.c       |   1 +
 fs/nfsd/nfssvc.c       |   6 +
 fs/nfsd/state.h        |  10 ++
 fs/nfsd/xdr4.h         |  29 +++++
 fs/nfsd/xdr4cb.h       |  10 ++
 10 files changed, 517 insertions(+), 24 deletions(-)

-- 
1.8.3.1

