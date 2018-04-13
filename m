Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:56804 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750867AbeDMRDR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Apr 2018 13:03:17 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v8 00/13] NFS support for async intra COPY
Date: Fri, 13 Apr 2018 13:03:01 -0400
Message-ID: <20180413170314.17634-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the client side to always request an asynchronous copy.

If server replies to the COPY with the copy stateid, client will go
wait on the CB_OFFLOAD. To fend off the race between CB_OFFLOAD and
COPY reply, we check the list of pending callbacks before going to
wait. Client adds the copy to the global list of copy stateids for the
callback to look thru and signal the waiting copy.

When the client receives reply from the CB_OFFLOAD with some bytes and
committed how is UNSTABLE, then COMMIT is sent to the server. The results
are propagated to the VFS and application. Assuming that application
will deal with a partial result and continue from the new offset if needed.

If server errs with ERR_OFFLOAD_NOREQS the copy will be re-sent as a
synchronous COPY. If application cancels an in-flight COPY,
OFFLOAD_CANCEL is sent to the server (sending it as an async RPC in the
context of the nfsid_workqueue).

v8. 
- added patch 13 to handle reboot recovery of the server or network
partition. this patch was a part of the initial "inter async" series
but never got added to the async series. without this patch if the
server goes away, thread that was doing the copy would be hanging
waiting for the callback that would never arrive.



Anna Schumaker (1):
  fs: Don't copy beyond the end of the file

Olga Kornievskaia (12):
  NFS CB_OFFLOAD xdr
  NFS OFFLOAD_STATUS xdr
  NFS OFFLOAD_STATUS op
  NFS OFFLOAD_CANCEL xdr
  NFS COPY xdr handle async reply
  NFS add support for asynchronous COPY
  NFS handle COPY reply CB_OFFLOAD call race
  NFS export nfs4_async_handle_error
  NFS send OFFLOAD_CANCEL when COPY killed
  NFS handle COPY ERR_OFFLOAD_NO_REQS
  NFS add a simple sync nfs4_proc_commit after async COPY
  NFS recover from destination server reboot for copies

 fs/nfs/callback.h         |  12 +++
 fs/nfs/callback_proc.c    |  54 ++++++++++
 fs/nfs/callback_xdr.c     |  81 ++++++++++++++-
 fs/nfs/client.c           |   1 +
 fs/nfs/nfs42.h            |   5 +-
 fs/nfs/nfs42proc.c        | 251 ++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs42xdr.c         | 189 +++++++++++++++++++++++++++++++---
 fs/nfs/nfs4_fs.h          |   8 +-
 fs/nfs/nfs4client.c       |  15 +++
 fs/nfs/nfs4file.c         |   9 +-
 fs/nfs/nfs4proc.c         |  38 ++++++-
 fs/nfs/nfs4state.c        |  15 +++
 fs/nfs/nfs4xdr.c          |   2 +
 fs/read_write.c           |   3 +
 include/linux/nfs4.h      |   2 +
 include/linux/nfs_fs.h    |  11 ++
 include/linux/nfs_fs_sb.h |   4 +
 include/linux/nfs_xdr.h   |  14 +++
 18 files changed, 689 insertions(+), 25 deletions(-)

-- 
1.8.3.1

