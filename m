Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:46790 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750853AbcCHV4D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Mar 2016 16:56:03 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <bfields@fieldses.org>, <hch@infradead.org>
Subject: [PATCH v3 0/3] NFSv4.2: Add support for the COPY operation
Date: Tue, 8 Mar 2016 16:55:54 -0500
Message-ID: <1457474158-16050-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add client and server support for the NFS v4.2 COPY operation,
and make use of the new copy_file_range() system call.

Changes in v3:
- Add nfs_commit_file() function to sent a commit after a copy.
- Update exception handling to match Christoph's recent changes.
- Server should check for copying beyond the end of the file.

Questions, comments, and other testing ideas would be greatly appreciated!

Thanks,
Anna


Anna Schumaker (4):
  NFS: Add nfs_commit_file()
  NFS: Add COPY nfs operation
  NFSD: Implement the COPY call
  vfs_copy_range() test program

 fs/nfs/internal.h         |   1 +
 fs/nfs/nfs42.h            |   1 +
 fs/nfs/nfs42proc.c        | 105 +++++++++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.c         | 146 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4file.c         |  23 ++++++++
 fs/nfs/nfs4proc.c         |   1 +
 fs/nfs/nfs4xdr.c          |   1 +
 fs/nfs/pagelist.c         |   6 +-
 fs/nfs/write.c            |  41 +++++++++++--
 fs/nfsd/nfs4proc.c        |  98 +++++++++++++++++++++++++++----
 fs/nfsd/nfs4xdr.c         |  63 +++++++++++++++++++-
 fs/nfsd/vfs.c             |   6 ++
 fs/nfsd/vfs.h             |   1 +
 fs/nfsd/xdr4.h            |  23 ++++++++
 include/linux/nfs4.h      |   1 +
 include/linux/nfs_fs_sb.h |   1 +
 include/linux/nfs_xdr.h   |  26 +++++++++
 nfscopy.c                 |  59 +++++++++++++++++++
 18 files changed, 584 insertions(+), 19 deletions(-)
 create mode 100644 nfscopy.c

-- 
2.7.2

