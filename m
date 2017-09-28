Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:51203 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751339AbdI1R2W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:28:22 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 00/12] NFS support for async intra COPY
Date: Thu, 28 Sep 2017 13:28:07 -0400
Message-ID: <20170928172819.50703-1-kolga@netapp.com>
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
arep propagated to the VFS and application. Assuming that application
will deal with a partial result and continue from the new offset if needed.

If server errs with ERR_OFFLOAD_NOREQS the copy will be re-sent as a
synchronous COPY. If application cancels an in-flight COPY,
OFFLOAD_CANCEL is sent to the server (sending it as an async RPC in the
context of the nfsid_workqueue).

v4:
separated async patches from the async+inter series
update the code based on the constifying patches that went for 4.13
addressed minor comments provided by Anna

Anna Schumaker (1):
  fs: Don't copy beyond the end of the file

Olga Kornievskaia (11):
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

 fs/nfs/callback.h         |  12 +++
 fs/nfs/callback_proc.c    |  54 +++++++++++
 fs/nfs/callback_xdr.c     |  81 +++++++++++++++-
 fs/nfs/client.c           |   1 +
 fs/nfs/nfs42.h            |   5 +-
 fs/nfs/nfs42proc.c        | 233 ++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs42xdr.c         | 187 ++++++++++++++++++++++++++++++++++---
 fs/nfs/nfs4_fs.h          |   5 +-
 fs/nfs/nfs4client.c       |  15 +++
 fs/nfs/nfs4proc.c         |  37 +++++++-
 fs/nfs/nfs4xdr.c          |   2 +
 fs/read_write.c           |   3 +
 include/linux/nfs4.h      |   2 +
 include/linux/nfs_fs.h    |   9 ++
 include/linux/nfs_fs_sb.h |   4 +
 include/linux/nfs_xdr.h   |  14 +++
 16 files changed, 641 insertions(+), 23 deletions(-)

-- 
1.8.3.1

