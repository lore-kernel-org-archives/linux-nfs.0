Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:6150 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756569AbaIIOt7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 10:49:59 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] NFS: Add ALLOCATE and DEALLOCATE support
Date: Tue, 9 Sep 2014 10:49:54 -0400
Message-ID: <1410274196-30841-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add client support for the ALLOCATE and DEALLOCATE operations
part of NFS v4.2.

These operations are triggered by a vfs_fallocate() call, and we determine
which to use based on if the FALLOC_FL_PUNCH_HOLE flag is set.

Anna Schumaker (2):
  nfs: Add ALLOCATE support
  nfs: Add DEALLOCATE support

 fs/nfs/nfs42proc.c        |  74 +++++++++++++++++++++++++
 fs/nfs/nfs42xdr.h         | 136 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h          |   3 +
 fs/nfs/nfs4client.c       |   2 +-
 fs/nfs/nfs4file.c         |  47 ++++++++++++++++
 fs/nfs/nfs4proc.c         |   2 +-
 fs/nfs/nfs4xdr.c          |   2 +
 include/linux/nfs4.h      |   2 +
 include/linux/nfs_fs_sb.h |   2 +
 include/linux/nfs_xdr.h   |  28 ++++++++++
 10 files changed, 296 insertions(+), 2 deletions(-)

-- 
2.1.0

