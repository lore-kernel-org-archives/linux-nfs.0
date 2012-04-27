Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20489 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752606Ab2D0VpK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 17:45:10 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@rhel-62.androsad.fake>
Subject: [PATCH Version 4 00/13] NFSv4.1 file layout data server quick failover
Date: Fri, 27 Apr 2012 17:53:40 -0400
Message-Id: <1335563633-7191-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@rhel-62.androsad.fake>

This is a RFC. The patches will be tested throughly next week. They
are based upon Fred Issaman's direct IO patches.

-->Andy

Changes from Version 3:

- added module parameters for setting the DS timeo and retrans
- rewrote filelayout_reset_read/write using pnfs_read/write_don_resend_to_mds() 
- simply check the plh_segs list and if it is empty, do not send a layoutreturn
- moved nfs_put_client outside of spin_lock in nfs4_ds_disconnect
- added NFSv4.1 resend LAYOUTGET on data server invalid layout errors

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

The module parameters dataserver_timeo and dataserver_retrans are equivalent to
the mount parameters of the same name. They determine how long the client
waits to recover from a DS disconnect error. E.g. how long the client waits
to begin recovery to the MDS, and how long the recovery takes - which can 
take up to (timeo * retrans * number of DS session slots).
 
These patches address this problem by setting data server RPC tasks to
RPC_TASK_SOFTCONN and handling the resultant connection errors as follows:

On a DS disconnect error, the pNFS deviceid is marked invalid which blocks any
new pNFS io using that deviceid. The RPC done routines for READ, WRITE and
COMMIT redirect failed requests to the MDS. The read/write RPC prepare
routines redirect the tasks that are awakened from the data server session
fore channel slot_tbl_waitq.

All data server io requests reference the data server client structure
across io calls, and the client is dereferenced upon deviceid invalidation so
that the client (and the session) is freed upon the last (failed) redirected io.

Testing:
I use a pynfs file layout server with a DS to test. The pynfs server and DS
is modified to use the local host for MDS to DS communication. I add a
second ipv4 address to the single machine interface for the DS to client
communication. While a "dd" or a read/write heavy Connectathon test is
running, the DS ip address is removed from the ethernet interface, and the
time the removal of the DS ip address during a DS COMMIT and have seen it
recover as well. :)


Andy Adamson (13):
  NFSv4.1 do not send LAYOUTRETURN when there are no layout segments
  NFSv4.1: cleanup filelayout invalid deviceid handling
  NFSv4.1 cleanup filelayout invalid layout handling
  NFSv4.1 set RPC_TASK_SOFTCONN for filelayout DS RPC calls
  NFSv4.1 data server timeo and retrans module parameters
  NFSv4.1: mark deviceid invalid on filelayout DS connection errors
  NFSv4.1 remove nfs4_reset_write and nfs4_reset_read
  NFSv4.1 Check invalid deviceid upon slot table waitq wakeup
  NFSv4.1 wake up all tasks on un-connected DS slot table waitq
  NFSv4.1 send layoutreturn to fence disconnected data server
  NFSv4.1 ref count nfs_client across filelayout data server io
  NFSv4.1 dereference a disconnected data server client record
  NFSv4.1 resend LAYOUTGET on data server invalid layout errors

 fs/nfs/client.c            |   12 +--
 fs/nfs/internal.h          |   12 +-
 fs/nfs/nfs4filelayout.c    |  237 +++++++++++++++++++++++++++++++-------------
 fs/nfs/nfs4filelayout.h    |   45 ++++++++-
 fs/nfs/nfs4filelayoutdev.c |   77 +++++++++-----
 fs/nfs/nfs4proc.c          |   35 -------
 fs/nfs/pnfs.c              |   10 ++-
 fs/nfs/pnfs.h              |    5 +
 fs/nfs/read.c              |    6 +-
 fs/nfs/write.c             |   13 ++-
 10 files changed, 291 insertions(+), 161 deletions(-)

