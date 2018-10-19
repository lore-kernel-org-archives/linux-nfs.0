Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f176.google.com ([209.85.222.176]:36041 "EHLO
        mail-qk1-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727050AbeJSXgG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 19:36:06 -0400
Received: by mail-qk1-f176.google.com with SMTP id q184-v6so3172469qkd.3
        for <linux-nfs@vger.kernel.org>; Fri, 19 Oct 2018 08:29:31 -0700 (PDT)
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: trondmy@hammerspace.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 00/11] client-side support for "inter" SSC copy 
Date: Fri, 19 Oct 2018 11:29:21 -0400
Message-Id: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <kolga@netapp.com>

This patch series adds client-side support for doing NFSv4.2 "inter"
copy offload between different NFS servers.

In case of the "inter" SSC copy files reside on different servers and
thus under different superblocks and require that VFS removes the
restriction that src and dst files must be on the same superblock.

NFS's copy_file_range() determines if the copy is "intra" or "inter"
and for "inter" it sends the COPY_NOTIFY to the source server. Then,
it would send of an asynchronous COPY to the destination server. If 
an application cancels an in-flight COPY, OFFLOAD_CANCEL is sent to
both of the servers.

This patch series also include necessary client-side additions that
are performed by the destination server. The server needs an NFS
open that represents a source file without doing an actual open.
Two function nfs42_ssc_open/nfs42_ssc_close() are introduced to
accomplish it that make use of the VFS's alloc_file_pseudo() to
represent an open.

Also this particular open is marked (NFS_SVC_SSC_COPY_STATE) so
that if the destination server ever to receive stateid errors on
this stateid, it knows not to initiate state recovery (in case
when source server reboots). The recovery must be done by the
client and a new copy must be initiated. Therefore, in this case
the recovery needs to fail with EIO. 

Anna Schumaker (1):
  fs: Don't copy beyond the end of the file

Olga Kornievskaia (10):
  VFS permit cross device vfs_copy_file_range
  NFS test for intra vs inter COPY
  NFS NFSD defining nl4_servers structure needed by both
  NFS add COPY_NOTIFY operation
  NFS add ca_source_server<> to COPY
  NFS also send OFFLOAD_CANCEL to source server
  NFS inter ssc open
  NFS skip recovery of copy open on dest server
  NFS for "inter" copy treat ESTALE as ENOTSUPP
  NFS COPY handle ERR_OFFLOAD_DENIED

 Documentation/filesystems/vfs.txt |   4 +-
 fs/nfs/nfs42.h                    |  15 ++-
 fs/nfs/nfs42proc.c                | 129 ++++++++++++++++++++++---
 fs/nfs/nfs42xdr.c                 | 193 +++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4_fs.h                  |   8 ++
 fs/nfs/nfs4file.c                 | 123 +++++++++++++++++++++++-
 fs/nfs/nfs4proc.c                 |   6 +-
 fs/nfs/nfs4state.c                |  14 +++
 fs/nfs/nfs4xdr.c                  |   1 +
 fs/read_write.c                   |  16 ++--
 include/linux/nfs4.h              |  25 +++++
 include/linux/nfs_fs_sb.h         |   1 +
 include/linux/nfs_xdr.h           |  17 ++++
 13 files changed, 526 insertions(+), 26 deletions(-)

-- 
1.8.3.1
