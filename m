Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:32891 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751311AbdCQVES (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 17:04:18 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v2 00/12] NFS (just) async support for COPY 
Date: Fri, 17 Mar 2017 17:03:45 -0400
Message-ID: <20170317210357.48079-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In version 2:
This series separates support for async COPY (no inter support). 

Simple timings to demonstrate the usefulness of the async copy
implementation.
This is async "intra" SSC vs normal copy vs upstream sync SSC
time ./nfscopy /mnt/1024MB.txt 0 /mnt/1024 0 10240000000
real    1m47.036s
user    0m0.001s
sys     0m0.002s

time cp /mnt/1024MB.txt /mnt/1024
real    3m10.121s
user    0m0.060s
sys     0m9.365s

(existing "intra" client against "intra" server)
time ./nfscopy /mnt/1024MB.txt 0 /mnt/1024 0 10240000000
real    2m45.975s
user    0m0.022s
sys     0m0.452s

>From version 1 cover letter:
Client sends an asynchronous COPY to the server (always). If server 
errs with ERR_OFFLOAD_NOREQS the copy will be re-sent as a synchronous
COPY. If application cancels an in-flight COPY, OFFLOAD_CANCEL is sent
to the source server.

If server replies to the COPY with the copy stateid, client will go
wait on the CB_OFFLOAD. To fend off the race between CB_OFFLOAD and
COPY reply, we check the list of pending callbacks before going to
wait. Client adds the copy to the global list of copy stateids for the
callback to look thru and signal the waiting copy.

If application cancels async COPY after reply is received, wait will be
interrupted and client will send OFFLOAD_CANCEL to the server (sending 
it as an async RPC in the context of the nfsiod_workqueue).

When the client receives reply from the CB_OFFLOAD with some bytes and
committed how is UNSTABLE, then COMMIT is sent to the server. The results
arep propagated to the VFS and application. Assuming that application
will deal with a partial result and continue from the new offset if needed.

Handling reboot of the destination server when client is waiting on the
CB_OFFLOAD happens when SEQUENCE discovers that destination server rebooted.
The open state initially is marked to be NFS_CLNT_DST_SSC_COPY_STATE
during the COPY. Then during the recovery if state is marked as such,
then look thru the list of copies for the server and see if any are
associated with this recovering open, if so mark the copy rebooted and
wake up the waiting copy. Upon wake up the waiting copy, will restart the
copy from scratch.

If CB_OFFLOAD returned an error and non negative value of partial copy
and error is not ENOSPC, then ignore the error and send the commit
and return partial result to the client to start the next copy.

Olga Kornievskaia (12):
  NFS CB_OFFLOAD xdr
  NFS OFFLOAD_STATUS xdr
  NFS OFFLOAD_STATUS op
  NFS OFFLOAD_CANCEL xdr
  NFS COPY xdr handle async reply
  NFS add support for asynchronous COPY
  NFS handle COPY reply CB_OFFLOAD call race
  NFS send OFFLOAD_CANCEL when COPY killed
  NFS make COPY synchronous xdr configurable
  NFS handle COPY ERR_OFFLOAD_NO_REQS
  NFS if we got partial copy ignore errors
  NFS recover from destination server reboot for copies

 fs/nfs/callback.h         |  13 +++
 fs/nfs/callback_proc.c    |  52 +++++++++++
 fs/nfs/callback_xdr.c     |  80 ++++++++++++++++-
 fs/nfs/client.c           |   1 +
 fs/nfs/nfs42.h            |   3 +-
 fs/nfs/nfs42proc.c        | 222 ++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs42xdr.c         | 177 +++++++++++++++++++++++++++++++++---
 fs/nfs/nfs4_fs.h          |   4 +
 fs/nfs/nfs4client.c       |  15 ++++
 fs/nfs/nfs4file.c         |   9 +-
 fs/nfs/nfs4proc.c         |   2 +
 fs/nfs/nfs4state.c        |  15 ++++
 fs/nfs/nfs4xdr.c          |   2 +
 include/linux/nfs4.h      |   2 +
 include/linux/nfs_fs.h    |  11 +++
 include/linux/nfs_fs_sb.h |   4 +
 include/linux/nfs_xdr.h   |  14 +++
 17 files changed, 605 insertions(+), 21 deletions(-)

-- 
1.8.3.1

