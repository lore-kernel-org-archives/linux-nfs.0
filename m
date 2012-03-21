Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36490 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756123Ab2CUTqx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 15:46:53 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 00/12] NFSv4.1 file layout data server quick failover
Date: Wed, 21 Mar 2012 15:46:12 -0400
Message-Id: <1332359184-1887-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Changes from Version 1:

Patch removed as rpc_wake_up is now fixed.
-SUNRPC-add-rpc_drain_queue-to-empty-an-rpc_waitq.patch

Patch changed; the forechannel rpc_sleep_on slot_tbl_waitq action is
removed and it's functionality is moved into the rpc_call_prepare
routines.
- NFSv4.1-Check-invalid-deviceid-upon-slot-table-waitq.patch

Responded to the changes in the filelayout commit code:
Patch is simplified.
-NFSv4.1: send filelayout DS commits to the MDS on invalid deviceid

A bug fix and a cleanup.
- NFSv4.1 check for NULL pnfs_layout_hdr in pnfs scan commit lists
- NFSv4.1 have filelayout_initiate_commit return void

Currently, when a data server connection goes down due to a network partion,
a data server failure, or an administrative action, RPC tasks in various
stages of the RPC finite state machine (FSM) need to transmit and timeout
(or other failure) before being redirected towards an alternative server
(MDS or another DS).
This can take a very long time if the connection goes down during a heavy
I/O load where the data server fore channel session slot_tbl_waitq and the
transport sending/pending waitqs are populated with many requests.
(see RedHat Bugzilla 756212 "Redirecting I/O through the MDS after a data
server network partition is very slow")
The current code also keeps the client structure and the session to the failed
data server until umount.

These patches address this problem by setting data server RPC tasks to
RPC_TASK_SOFTCONN and handling the resultant connection errors as follows:

 * The pNFS deviceid is marked invalid which blocks any new pNFS io using that
deviceid.
 * The RPC done routines for READ, WRITE and COMMIT redirect the requests
to the new server (MDS) and send the request back through the RPC FSM.
 * An rpc_action which also redirects the request to the MDS on an invalid
deviceid is registered with the data server session fore channel
slot_tbl_waitq rpc_sleep_on calls and is executed upon wake up.
 * The data server session fore channel slot_tbl_waitq is drained using a
new rpc_drain_queue method.
 * All data server io requests reference the data server client structure
across io calls, and the client is dereferenced upon deviceid invalidation so
that the client (and the session) is freed upon the last (failed) redirected io.

Testing:
I use a pynfs file layout server with a DS to test. The pynfs server and DS
is modified to use the local host for MDS to DS communication. I add a
second ipv4 address to the single machine interface for the DS to client
communication. While a "dd" or a read/write heavy Connectathon test is
running, the DS ip address is removed from the ethernet interface, and the
client recovers io to the MDS.
I have tested READ and WRITE recovery multiple times, and have managed to
time the removal of the DS ip address during a DS COMMIT and have seen it
recover as well. :)


Comments welcome

--> Andy


Andy Adamson (12):
  NFSv4.1 move nfs4_reset_read and nfs_reset_write
  NFSv4.1: cleanup filelayout invalid deviceid handling
  NFSv4.1 cleanup filelayout invalid layout handling
  NFSv4.1 set RPC_TASK_SOFTCONN for filelayout DS RPC calls
  NFSv4.1: mark deviceid invalid on filelayout DS connection errors
  NFSv4.1: send filelayout DS commits to the MDS on invalid deviceid
  NFSv4.1 Check invalid deviceid upon slot table waitq wakeup
  NFSv4.1 wake up all tasks on un-connected DS slot table waitq
  NFSv4.1 ref count nfs_client across filelayout data server io
  NFSv4.1 de reference a disconnected data server client record
  NFSv4.1 check for NULL pnfs_layout_hdr in pnfs scan commit lists
  NFSv4.1 have filelayout_initiate_commit return void

 fs/nfs/internal.h          |   11 ++-
 fs/nfs/nfs4filelayout.c    |  204 +++++++++++++++++++++++++++++++------------
 fs/nfs/nfs4filelayout.h    |   28 +++++-
 fs/nfs/nfs4filelayoutdev.c |   54 ++++++------
 fs/nfs/nfs4proc.c          |   39 +--------
 fs/nfs/pnfs.h              |    3 +-
 fs/nfs/read.c              |    6 +-
 fs/nfs/write.c             |   13 ++--
 8 files changed, 221 insertions(+), 137 deletions(-)

-- 
1.7.6.4

