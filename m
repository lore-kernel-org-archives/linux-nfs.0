Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:43862 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759786AbaJaUxx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Oct 2014 16:53:53 -0400
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 0/3] NFSD: Add ALLOCATE and DEALLOCATE support
Date: Fri, 31 Oct 2014 16:53:43 -0400
Message-ID: <1414788826-21474-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

These patches add server support for the ALLOCATE and DEALLOCATE operations
part of NFS v4.2.

Changes in v3:
- Add back the do_fallocate() -> vfs_fallocate() patch
- Do Christoph's suggested cleanups to nfsd4_vfs_fallocate()

These patches and the corresponding client changes are available in the
[fallocate] branch of:

	git://git.linux-nfs.org/projects/anna/linux-nfs.git


Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (3):
  VFS: Rename do_fallocate() to vfs_fallocate()
  nfsd: Add ALLOCATE support
  nfsd: Add DEALLOCATE support

 drivers/staging/android/ashmem.c |  2 +-
 fs/ioctl.c                       |  2 +-
 fs/nfsd/nfs4proc.c               | 51 ++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c                | 21 +++++++++++++++--
 fs/nfsd/vfs.c                    | 20 ++++++++++++++++
 fs/nfsd/vfs.h                    |  2 ++
 fs/nfsd/xdr4.h                   |  9 +++++++
 fs/open.c                        |  5 ++--
 include/linux/fs.h               |  2 +-
 mm/madvise.c                     |  2 +-
 10 files changed, 108 insertions(+), 8 deletions(-)

-- 
2.1.3

