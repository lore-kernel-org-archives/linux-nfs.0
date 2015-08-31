Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:56411 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751901AbbHaTuV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2015 15:50:21 -0400
From: <andros@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <Anna.Schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 00/16] NFSv4.2: Add support for inter-server to server COPY
Date: Mon, 31 Aug 2015 15:49:50 -0400
Message-ID: <1441050606-40897-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

These patches add client and server support for NFSv4.2 inter-server to
server copy offload. These patches build upon Anna Schumaker's COPY Operation
patches which are in turn built upon Zack Brown's VFS vfs_copy_file_range
syscall. Additional functionality is added to the COPY operation past what
Anna added. The COPY_NOTIFY operation is added.

The first three patches change Zach Brown's vfs_copy_file_range implementation.
The first two patches relax the check for only performing copy offload between
files with the same mount and super block, moving that check into a helper
function that can be called (e.g. BTRFS) in a file systems copy_file_range
function. The third patch changes vfs_copy_file_range to call the destination
file (file_out) copy_file_range f_ops proceedure instead of the file_in version.

The remaining patches implement the COPY_NOTIFY operation and the inter-ssc
changes to the COPY operation.  One source server using NL4_NETADDR is
currently supported. I used the test program from Anna's COPY
operation patch set.

I put this patch set out knowing it will need to be merged with Zach Brown's
VFS work, Anna Schumaker's intra-ssc COPY and Peng Tao's NFS CLONE patches.

Questions, comments, and other testing ideas welcome.

-->Andy


Andy Adamson (12):
  VFS: Separate cross fs check from vfs_copy_file_range
  BTRFS: Use VFS copy offload helper
  VFS SQUASH use file_out instead of file_in for copy_file_range
  NFS add same file check and flush source and destination for COPY
  NFS add inter ssc functions to nfs42proc
  NFS add COPY_NOTIFY operation
  NFSD add ca_source_server<> to COPY
  NFSD add COPY_NOTIFY operation
  NFS add ca_source_server<> to COPY
  NFSD generalize nfsd4_compound_state flag names
  NFSD: allow inter server COPY to have a STALE source server fh
  NFSD add nfs4 inter ssc to nfsd4_copy

Olga Kornievskaia (4):
  NFS COPY xdr changes
  NFS in copy use stateid returned by copy_notify
  NFS always use openstateid in COPY_NOTIFY
  NFSD: extra stateid checking in read for interserver copy

 fs/btrfs/ioctl.c              |   3 +
 fs/nfs/nfs42.h                |   2 +-
 fs/nfs/nfs42proc.c            | 238 ++++++++++++++++++++-
 fs/nfs/nfs42xdr.c             | 213 ++++++++++++++++++-
 fs/nfs/nfs4_fs.h              |   9 +-
 fs/nfs/nfs4file.c             |  17 +-
 fs/nfs/nfs4proc.c             |   8 +-
 fs/nfs/nfs4state.c            |   2 +-
 fs/nfs/nfs4xdr.c              |   1 +
 fs/nfsd/Kconfig               |  10 +
 fs/nfsd/nfs4proc.c            | 473 ++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/nfs4state.c           |  15 +-
 fs/nfsd/nfs4xdr.c             | 203 +++++++++++++++++-
 fs/nfsd/nfsd.h                |   2 +
 fs/nfsd/state.h               |   8 +
 fs/nfsd/xdr4.h                |  29 ++-
 fs/read_write.c               |  38 ++--
 include/linux/fs.h            |   1 +
 include/linux/nfs4.h          |   7 +
 include/linux/nfs4intercopy.h |  39 ++++
 include/linux/nfs_fs_sb.h     |   1 +
 include/linux/nfs_xdr.h       |  28 +++
 22 files changed, 1282 insertions(+), 65 deletions(-)
 create mode 100644 include/linux/nfs4intercopy.h

-- 
1.8.3.1

