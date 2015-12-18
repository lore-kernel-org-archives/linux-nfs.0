Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:30829 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965372AbbLRVFc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Dec 2015 16:05:32 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <bfields@fieldses.org>, <hch@infradead.org>
Subject: [PATCH v2 0/3] NFSv4.2: Add support for the COPY operation
Date: Fri, 18 Dec 2015 16:05:23 -0500
Message-ID: <1450472727-19893-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add client and server support for the NFS v4.2 COPY operation,
and depend on the new copy_file_range() system call currently scheduled for
Linux 4.5.

Changes in v2:
- Preprocess filehandle op can choose between current_fh and save_fh
- NFSD doesnt' need to fsync() after vfs_copy_file_range() call
- Mark file as NFS_UNSTABLE in the copy return
- The client should send a commit if the file is copied with anything other
  than NFS_FILE_SYNC
- Fix conflicts with CLONE

Questions, comments, and other testing ideas would be greatly appreciated!

Thanks,
Anna


Anna Schumaker (4):
  NFSD: Don't pass filehandle to nfs4_preprocess_stateid_op()
  NFSD: Implement the COPY call
  NFS: Add COPY nfs operation
  vfs_copy_range() test program

 fs/nfs/nfs42.h            |   1 +
 fs/nfs/nfs42proc.c        | 100 +++++++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.c         | 146 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4file.c         |  23 ++++++++
 fs/nfs/nfs4proc.c         |   1 +
 fs/nfs/nfs4xdr.c          |   1 +
 fs/nfs/objlayout/Makefile |   0
 fs/nfsd/nfs4proc.c        | 110 +++++++++++++++++++++++++++-------
 fs/nfsd/nfs4state.c       |  10 +++-
 fs/nfsd/nfs4xdr.c         |  62 +++++++++++++++++++-
 fs/nfsd/state.h           |   7 ++-
 fs/nfsd/vfs.c             |  20 +++++++
 fs/nfsd/vfs.h             |   1 +
 fs/nfsd/xdr4.h            |  23 ++++++++
 include/linux/nfs4.h      |   1 +
 include/linux/nfs_fs_sb.h |   1 +
 include/linux/nfs_xdr.h   |  27 +++++++++
 nfscopy.c                 |  59 +++++++++++++++++++
 18 files changed, 563 insertions(+), 30 deletions(-)
 create mode 100644 fs/nfs/objlayout/Makefile
 create mode 100644 nfscopy.c

-- 
2.6.4

