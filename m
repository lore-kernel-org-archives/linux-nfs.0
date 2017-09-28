Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:3623 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751813AbdI1R2l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:28:41 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 00/11] NFS support for "inter" server-to-server COPY
Date: Thu, 28 Sep 2017 13:28:28 -0400
Message-ID: <20170928172839.50741-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series builds on top of async COPY series.

In case, of the "inter" SSC copy files reside on different servers and
thus under different superblocks and require that VFS removes the
restriction that src and dst files must be on the same superblock.

NFS's copy_file_range() determines if the copy is "intra" or "inter"
and for "inter" it sends the COPY_NOTIFY to the source server. Then,
it would send of an asynchronous COPY to the destination server.

A couple of patches are added for the destination server acting as the
client when talking to the source server. It's now acting as a client
and needs to do a special "open" and "close". Since destination server
doesn't do an open on the wire, we "fake" create the needed data structures
and that's done in the new function nfs42_ssc_open(). To clean up this open
but not trigger the CLOSE on the wire, we have a new function
nfs42_ssc_close() that accomplishes that. This is patch "NFS inter ssc open"

Handling reboot of the destination server when client is waiting on the
CB_OFFLOAD happens when SEQUENCE discovers that destination server rebooted.
The open state initially is marked to be NFS_CLNT_DST_SSC_COPY_STATE
during the COPY. Then during the recovery if state is marked as such,
then look thru the list of copies for the server and see if any are
associated with this recovering open, if so mark the copy rebooted and
wake up the waiting copy. Upon wake up the waiting copy, will restart the
copy from scratch. This is patch "NFS skip recovery of copy open on
dest server".

If the server returned ESTALE or ERR_OFFLOAD_DENIED fallback on the 
traditional copy.

Olga Kornievskaia (11):
  VFS permit cross device vfs_copy_file_range
  NFS test for intra vs inter COPY
  NFS recover from destination server reboot for copies
  NFS NFSD defining nl4_servers structure needed by both
  NFS add COPY_NOTIFY operation
  NFS add ca_source_server<> to COPY
  NFS also send OFFLOAD_CANCEL to source server
  NFS inter ssc open
  NFS skip recovery of copy open on dest server
  NFS for "inter" copy treat ESTALE as ENOTSUPP
  NFS COPY handle ERR_OFFLOAD_DENIED

 Documentation/filesystems/vfs.txt |   6 ++
 fs/nfs/nfs42.h                    |  14 ++-
 fs/nfs/nfs42proc.c                | 141 +++++++++++++++++++++++++---
 fs/nfs/nfs42xdr.c                 | 193 +++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4_fs.h                  |  13 +++
 fs/nfs/nfs4file.c                 | 135 +++++++++++++++++++++++++-
 fs/nfs/nfs4proc.c                 |   6 +-
 fs/nfs/nfs4state.c                |  31 +++++-
 fs/nfs/nfs4xdr.c                  |   1 +
 fs/read_write.c                   |  13 ++-
 include/linux/nfs4.h              |  25 +++++
 include/linux/nfs_fs.h            |   2 +
 include/linux/nfs_fs_sb.h         |   1 +
 include/linux/nfs_xdr.h           |  17 ++++
 14 files changed, 571 insertions(+), 27 deletions(-)

-- 
1.8.3.1

