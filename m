Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:29199 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753217AbdCBQDV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:03:21 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 00/19] NFS support for inter and async COPY 
Date: Thu, 2 Mar 2017 11:01:04 -0500
Message-ID: <20170302160123.30375-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series provides support for NFSv4.2 COPY featuring support
for asynchronous copy and inter SSC copy.

In case, of the "inter" SSC copy files reside on different servers and
thus under different superblocks and require that VFS removes the
restriction that src and dst files must be on the same superblock.

NFS's copy_file_range() determines if the copy is "intra" or "inter"
and for "inter" it sends the COPY_NOTIFY to the source server. Then,
it would send of an asynchronous COPY to the server (destination in
case of "inter"). If server errs with ERR_OFFLOAD_NOREQS the copy will
be re-sent as a synchronous COPY. If application cancels an in-flight
COPY, OFFLOAD_CANCEL is sent to the source server.

If server replies to the COPY with the copy stateid, client will go
wait on the CB_OFFLOAD. To fend off the race between CB_OFFLOAD and
COPY reply, we check the list of pending callbacks before going to
wait. Client adds the copy to the global list of copy stateids for the
callback to look thru and signal the waiting copy.

If application cancels async COPY after reply is received, wait will be
interrupted and client will send OFFLOAD_CANCEL to the source and
destination servers (sending it as an async RPC in the context of the
nfsiod_workqueue).

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

If the source server is rebooted, the destination server will also know
about it and it will return the partial result via CB_OFFLOAD, then the
result will be propagated back to the application which will initiate
the new copy and new COPY_NOTIFY will be sent.

If CB_OFFLOAD returned an error and non negative value of partial copy
and error is not ENOSPC, then ignore the error and send the commit
and return partial result to the client to start the next copy.

On the destination server, it's now acting as a client and needs to do
a special "open" and "close". Since destination server doesn't do an open
on the wire, we "fake" create the needed data structures and that's done
in the new function nfs42_ssc_open(). To clean up this open but not trigger
the CLOSE on the wire, we have a new function nfs42_ssc_close() that
accomplishes that.

Anna Schumaker (1):
  fs: Don't copy beyond the end of the file

Andy Adamson (4):
  VFS permit cross device vfs_copy_file_range
  NFS inter ssc open
  NFS add COPY_NOTIFY operation
  NFS add ca_source_server<> to COPY

Olga Kornievskaia (14):
  VFS don't try clone if superblocks are different
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
  NFS skip recovery of copy open on dest server
  NFS recover from destination server reboot for copies
  NFS if we got partial copy ignore errors

 fs/nfs/callback.h         |  13 ++
 fs/nfs/callback_proc.c    |  52 +++++++
 fs/nfs/callback_xdr.c     |  80 +++++++++-
 fs/nfs/client.c           |   1 +
 fs/nfs/internal.h         |  10 ++
 fs/nfs/nfs42.h            |   9 +-
 fs/nfs/nfs42proc.c        | 352 ++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs42xdr.c         | 382 ++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4_fs.h          |  12 ++
 fs/nfs/nfs4client.c       |  15 ++
 fs/nfs/nfs4file.c         | 147 +++++++++++++++++-
 fs/nfs/nfs4proc.c         |   8 +-
 fs/nfs/nfs4state.c        |  31 +++-
 fs/nfs/nfs4xdr.c          |   3 +
 fs/read_write.c           |  12 +-
 include/linux/nfs4.h      |  36 +++++
 include/linux/nfs_fs.h    |  11 ++
 include/linux/nfs_fs_sb.h |   5 +
 include/linux/nfs_xdr.h   |  34 +++++
 19 files changed, 1171 insertions(+), 42 deletions(-)

-- 
1.8.3.1

