Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:61828 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbaKYSSV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2014 13:18:21 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 0/2] NFS: Add ALLOCATE and DEALLOCATE support
Date: Tue, 25 Nov 2014 13:18:14 -0500
Message-ID: <1416939496-27078-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add client support for the ALLOCATE and DEALLOCATE operations
part of NFS v4.2, which are triggered by a vfs_fallocate() call.

Changes in v5:
- Make _nfs42_proc_fallocate() and nfs42_proc_fallocate() static to prevent
  missing prototype warnings (Thanks, Trond!).

These patches and the corresponding server changes are available in the
[fallocate] branch of

	git://git.linux-nfs.org/projects/anna/linux-nfs.git

Questions?  Comments?  Thougts?

Anna


Anna Schumaker (2):
  nfs: Add ALLOCATE support
  nfs: Add DEALLOCATE support

 fs/nfs/inode.c            |   1 +
 fs/nfs/nfs42.h            |   2 +
 fs/nfs/nfs42proc.c        |  75 +++++++++++++++++++++++++
 fs/nfs/nfs42xdr.c         | 139 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h          |   1 +
 fs/nfs/nfs4file.c         |  31 +++++++++++
 fs/nfs/nfs4proc.c         |   4 +-
 fs/nfs/nfs4xdr.c          |   2 +
 include/linux/nfs4.h      |   2 +
 include/linux/nfs_fs_sb.h |   2 +
 include/linux/nfs_xdr.h   |  14 +++++
 11 files changed, 272 insertions(+), 1 deletion(-)

-- 
2.1.3

