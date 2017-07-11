Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:42314 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755486AbdGKQoT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:19 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 00/42] NFS/NFSD support for async and inter COPY
Date: Tue, 11 Jul 2017 12:43:34 -0400
Message-ID: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series provides support for NFSv4.2 COPY featuring support
for asynchronous copy and inter SSC copy.

In this iteration including both client and server side in one series
because server side does depend on client side patches. 

Client side:
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
are propagated to the VFS and application. Assuming that application
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

Server side:
This is server-side support for NFSv4.2 inter and async COPY which is
on top of existing intra sync COPY. It also depends on the NFS client
piece for NFSv4.2 to do client side of the destination server piece
in the inter SSC.

NFSD determines if COPY is intra or inter and if sync or async. For
inter, NSFD uses NFSv4.1 protocol and creates an internal mount point
(superblock).

To do asynchronous copies, NFSD creates a single threaded workqueue
and does not tie up an NFSD thread to complete the copy. Upon receiving
the COPY, it generates a unique copy stateid (stores a global list
for keeping track of state for OFFLOAD_STATUS to be queried by),
queues up a workqueue for the copy, and replies back to the client.
nfsd4_copy arguments that are allocated on the stack are copied for
the work item.

In the async copy handler, it calls into VFS copy_file_range() and
loops until it completes the requested copy size. If error is
encountered it's saved but also we save the amount of data copied
so far. Once done, the results are queued for the callback
workqueue and sent via CB_OFFLOAD. Also currently, choosing to clean
up the copy state information stored in the global list when cope is
done and not doing it when callback's release function (it could be
done there alternatively if needed it?).

On the source server, upon receiving a COPY_NOTIFY, it generate a
unique stateid that's kept in the global list. Upon receiving a READ
with a stateid, the code checks the normal list of open stateid and
now additionally, it'll check the copy state list as well before
deciding to either fail with BAD_STATEID or find one that matches.
The stored stateid is only valid to be used for the first time
with a choosen lease period (90s currently). When the source server
received an OFFLOAD_CANCEL, it will remove the stateid from the
global list. Otherwise, the copy stateid is removed upon the removal
of its "parent" stateid (open/lock/delegation stateid).

v3
Add support to delay the unmount of the source server on the destination
server for 90s to allow for consecutive COPY operations to reuse the 
session/clientid.  

Andy Adamson (9):
  NFS inter ssc open
  NFS add COPY_NOTIFY operation
  NFSD add ca_source_server<> to COPY
  NFSD generalize nfsd4_compound_state flag names
  NFSD add COPY_NOTIFY operation
  NFSD: allow inter server COPY to have a STALE source server fh
  NFSD add nfs4 inter ssc to nfsd4_copy
  NFSD return nfs4_stid in nfs4_preprocess_stateid_op
  NFSD Unique stateid_t for inter server to server COPY authentication

Anna Schumaker (1):
  fs: Don't copy beyond the end of the file

Olga Kornievskaia (32):
  VFS permit cross device vfs_copy_file_range
  NFS CB_OFFLOAD xdr
  NFS OFFLOAD_STATUS xdr
  NFS OFFLOAD_STATUS op
  NFS OFFLOAD_CANCEL xdr
  NFS COPY xdr handle async reply
  NFS add support for asynchronous COPY
  NFS handle COPY reply CB_OFFLOAD call race
  NFS export nfs4_async_handle_error
  NFS test for intra vs inter COPY
  NFS send OFFLOAD_CANCEL when COPY killed
  NFS handle COPY ERR_OFFLOAD_NO_REQS
  NFS if we got partial copy ignore errors
  NFS recover from destination server reboot for copies
  NFS NFSD defining nl4_servers structure needed by both
  NFS also send OFFLOAD_CANCEL to source server
  NFS skip recovery of copy open on dest server
  NFS also send OFFLOAD_CANCEL to source server
  NFS add a simple sync nfs4_proc_commit after async COPY
  NFSD CB_OFFLOAD xdr
  NFSD OFFLOAD_STATUS xdr
  NFSD OFFLOAD_CANCEL xdr
  NFSD xdr callback stateid in async COPY reply
  NFSD first draft of async copy
  NFSD handle OFFLOAD_CANCEL op
  NFSD stop queued async copies on client shutdown
  NFSD create new stateid for async copy
  NFSD define EBADF in nfserrno
  NFSD support OFFLOAD_STATUS
  NFSD remove copy stateid when vfs_copy_file_range completes
  NFSD delay the umount after COPY

 Documentation/filesystems/vfs.txt |   6 +
 fs/nfs/callback.h                 |  13 +
 fs/nfs/callback_proc.c            |  52 +++
 fs/nfs/callback_xdr.c             |  80 ++++-
 fs/nfs/client.c                   |   1 +
 fs/nfs/internal.h                 |  10 +
 fs/nfs/nfs42.h                    |  10 +-
 fs/nfs/nfs42proc.c                | 380 +++++++++++++++++++-
 fs/nfs/nfs42xdr.c                 | 388 +++++++++++++++++++-
 fs/nfs/nfs4_fs.h                  |  18 +-
 fs/nfs/nfs4client.c               |  15 +
 fs/nfs/nfs4file.c                 | 146 +++++++-
 fs/nfs/nfs4proc.c                 |  44 ++-
 fs/nfs/nfs4state.c                |  31 +-
 fs/nfs/nfs4xdr.c                  |   3 +
 fs/nfsd/Kconfig                   |  10 +
 fs/nfsd/netns.h                   |   8 +
 fs/nfsd/nfs4callback.c            |  95 +++++
 fs/nfsd/nfs4proc.c                | 727 ++++++++++++++++++++++++++++++++++++--
 fs/nfsd/nfs4state.c               | 149 +++++++-
 fs/nfsd/nfs4xdr.c                 | 266 +++++++++++++-
 fs/nfsd/nfsctl.c                  |   2 +
 fs/nfsd/nfsd.h                    |   2 +
 fs/nfsd/nfsproc.c                 |   1 +
 fs/nfsd/state.h                   |  34 +-
 fs/nfsd/xdr4.h                    |  61 +++-
 fs/nfsd/xdr4cb.h                  |  10 +
 fs/read_write.c                   |  16 +-
 include/linux/nfs4.h              |  37 ++
 include/linux/nfs_fs.h            |  11 +
 include/linux/nfs_fs_sb.h         |   5 +
 include/linux/nfs_xdr.h           |  33 ++
 32 files changed, 2563 insertions(+), 101 deletions(-)

-- 
1.8.3.1

