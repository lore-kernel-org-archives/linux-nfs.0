Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt1-f193.google.com ([209.85.160.193]:45456 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726465AbeJSXfp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 19:35:45 -0400
Received: by mail-qt1-f193.google.com with SMTP id e10-v6so38706066qtq.12
        for <linux-nfs@vger.kernel.org>; Fri, 19 Oct 2018 08:29:10 -0700 (PDT)
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 00/13] server-side support for "inter" SSC copy
Date: Fri, 19 Oct 2018 11:28:52 -0400
Message-Id: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series adds support for NFSv4.2 copy offload feature
allowing copy between two different NFS servers.

This feature is enabled by the kernel module parameter --
inter_copy_offload_enable -- and by default is disabled. There is
also a kernel compile configuration of NFSD_V4_2_INTER_SSC that
adds dependency on the NFS client side functions called from the
server.

These patches work on top of 4 existing async intra copy offload
patches. For the "inter" SSC, the implementation only supports
asynchronous inter copy.

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

On the destination server, upon receiving a COPY request, the server
establishes the necessary clientid/session with the source server.
It calls into the NFS client code to establish the necessary
open stateid, filehandle, file description (without doing an NFS open).
Then the server calls into the copy_file_range() to preform the copy
where the source file will issue NFS READs and then do local file
system writes (this depends on the VFS ability to do cross device
copy_file_range().

Client-side patches are included for the ease of testing.

Anna Schumaker (1):
  fs: Don't copy beyond the end of the file

Olga Kornievskaia (12):
  VFS permit cross device vfs_copy_file_range
  NFS NFSD defining nl4_servers structure needed by both
  NFS inter ssc open
  NFS skip recovery of copy open on dest server
  NFSD fill-in netloc4 structure
  NFSD add ca_source_server<> to COPY
  NFSD return nfs4_stid in nfs4_preprocess_stateid_op
  NFSD add COPY_NOTIFY operation
  NFSD check stateids against copy stateids
  NFSD generalize nfsd4_compound_state flag names
  NFSD: allow inter server COPY to have a STALE source server fh
  NFSD add nfs4 inter ssc to nfsd4_copy

 Documentation/filesystems/vfs.txt |   4 +-
 fs/nfs/nfs4_fs.h                  |   8 +
 fs/nfs/nfs4file.c                 |  99 +++++++++
 fs/nfs/nfs4proc.c                 |   5 +-
 fs/nfs/nfs4state.c                |  14 ++
 fs/nfsd/Kconfig                   |  10 +
 fs/nfsd/nfs4proc.c                | 433 +++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfs4state.c               | 128 +++++++++--
 fs/nfsd/nfs4xdr.c                 | 168 ++++++++++++++-
 fs/nfsd/nfsd.h                    |  31 ++-
 fs/nfsd/nfsfh.h                   |   5 +-
 fs/nfsd/nfssvc.c                  |   6 +
 fs/nfsd/state.h                   |  18 +-
 fs/nfsd/xdr4.h                    |  26 ++-
 fs/read_write.c                   |  16 +-
 include/linux/nfs4.h              |  25 +++
 16 files changed, 929 insertions(+), 67 deletions(-)

-- 
1.8.3.1
