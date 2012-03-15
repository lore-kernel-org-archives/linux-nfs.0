Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030581Ab2COSk4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Mar 2012 14:40:56 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 1 00/11] NFSv4.1 file layout data server quick failover
Date: Thu, 15 Mar 2012 14:40:39 -0400
Message-Id: <1331836850-5195-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

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

Clean-up patches:
0001-NFSv4.1-move-nfs4_reset_read-and-nfs_reset_write.patch
0002-NFSv4.1-cleanup-filelayout-invalid-deviceid-handling.patch
0003-NFSv4.1-cleanup-filelayout-invalid-layout-handling.patch

Quick failover patches:
0004-NFSv4.1-set-RPC_TASK_SOFTCONN-for-filelayout-DS-RPC-.patch
0005-NFSv4.1-mark-deviceid-invalid-on-filelayout-DS-conne.patch
0006-NFSv4.1-send-filelayout-DS-commits-to-the-MDS-on-inv.patch
0007-NFSv4.1-Check-invalid-deviceid-upon-slot-table-waitq.patch
0008-SUNRPC-add-rpc_drain_queue-to-empty-an-rpc_waitq.patch
0009-NFSv4.1-wake-up-all-tasks-on-un-connected-DS-slot-ta.patch
0010-NFSv4.1-ref-count-nfs_client-across-filelayout-data-.patch
0011-NFSv4.1-de-reference-a-disconnected-data-server-clie.patch


Andy Adamson (11):
  NFSv4.1 move nfs4_reset_read and nfs_reset_write
  NFSv4.1: cleanup filelayout invalid deviceid handling
  NFSv4.1 cleanup filelayout invalid layout handling
  NFSv4.1 set RPC_TASK_SOFTCONN for filelayout DS RPC calls
  NFSv4.1: mark deviceid invalid on filelayout DS connection errors
  NFSv4.1: send filelayout DS commits to the MDS on invalid deviceid
  NFSv4.1 Check invalid deviceid upon slot table waitq wakeup
  SUNRPC: add rpc_drain_queue to empty an rpc_waitq
  NFSv4.1 wake up all tasks on un-connected DS slot table waitq
  NFSv4.1 ref count nfs_client across filelayout data server io
  NFSv4.1 de reference a disconnected data server client record

 fs/nfs/internal.h            |   11 +-
 fs/nfs/nfs4filelayout.c      |  207 +++++++++++++++++++++++++++++++-----------
 fs/nfs/nfs4filelayout.h      |   28 +++++-
 fs/nfs/nfs4filelayoutdev.c   |   54 ++++++-----
 fs/nfs/nfs4proc.c            |   43 +--------
 fs/nfs/read.c                |    6 +-
 fs/nfs/write.c               |   13 ++-
 include/linux/nfs_xdr.h      |    1 +
 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/sched.c           |   27 ++++++
 10 files changed, 257 insertions(+), 134 deletions(-)

-- 
1.7.6.4

