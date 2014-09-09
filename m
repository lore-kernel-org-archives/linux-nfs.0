Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:18653 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756569AbaIIOtx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 10:49:53 -0400
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] NFSD: Add ALLOCATE and DEALLOCATE support
Date: Tue, 9 Sep 2014 10:49:39 -0400
Message-ID: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

These patches add server support for the ALLOCATE and DEALLOCATE operations
part of NFS v4.2.

The first patch in this series renames a VFS-level function for consistency
with how other VFS functions are named.  Who is the correct person to carry
this patch?

The remaining patches add the new operations.

Anna

Anna Schumaker (3):
  VFS: Rename do_fallocate() to vfs_fallocate()
  nfsd: Add ALLOCATE support
  nfsd: Add DEALLOCATE support

 drivers/staging/android/ashmem.c |  2 +-
 fs/ioctl.c                       |  2 +-
 fs/nfsd/nfs4proc.c               | 58 ++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c                | 38 ++++++++++++++++++++++++--
 fs/nfsd/vfs.c                    | 13 +++++++++
 fs/nfsd/vfs.h                    |  1 +
 fs/nfsd/xdr4.h                   | 16 +++++++++++
 fs/open.c                        |  5 ++--
 include/linux/fs.h               |  2 +-
 mm/madvise.c                     |  2 +-
 10 files changed, 131 insertions(+), 8 deletions(-)

-- 
2.1.0

