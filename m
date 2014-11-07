Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:33512 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752975AbaKGToa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Nov 2014 14:44:30 -0500
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 0/3] NFS: Add ALLOCATE and DEALLOCATE support
Date: Fri, 7 Nov 2014 14:44:24 -0500
Message-ID: <1415389467-16547-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

These patches add client support for the ALLOCATE and DEALLOCATE operations
part of NFS v4.2, which are triggered by a vfs_fallocate() call.

Changes in v4:
- Check if we are modifying a regular file, and return nfserr_inval if not.

These patches and the corresponding server changes are available in the
[fallocate] branch of

	git://git.linux-nfs.org/projects/anna/linux-nfs.git

Questions?  Comments?  Thougts?

Anna


Anna Schumaker (3):
  VFS: Rename do_fallocate() to vfs_fallocate()
  nfsd: Add ALLOCATE support
  nfsd: Add DEALLOCATE support

 drivers/staging/android/ashmem.c |  2 +-
 fs/ioctl.c                       |  2 +-
 fs/nfsd/nfs4proc.c               | 51 ++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c                | 21 +++++++++++++++--
 fs/nfsd/vfs.c                    | 23 ++++++++++++++++++
 fs/nfsd/vfs.h                    |  2 ++
 fs/nfsd/xdr4.h                   |  9 +++++++
 fs/open.c                        |  5 ++--
 include/linux/fs.h               |  2 +-
 mm/madvise.c                     |  2 +-
 10 files changed, 111 insertions(+), 8 deletions(-)

-- 
2.1.3

