Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:42076 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759720AbaJaUxe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Oct 2014 16:53:34 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 0/2] NFS: Add ALLOCATE and DEALLOCATE support
Date: Fri, 31 Oct 2014 16:53:29 -0400
Message-ID: <1414788811-21339-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add client support for the ALLOCATE and DEALLOCATE operations
part of NFS v4.2, which are triggered by a vfs_fallocate() call.

Changes in v3:
- Call inode_newsize_ok() to check file limits (fixes xfstests generic/228)

These patches and the corresponding server changes are available in the
[fallocate] branch of

	git://git.linux-nfs.org/projects/anna/linux-nfs.git

Questions?  Comments?  Thougts?

Anna


Anna Schumaker (2):
  nfs: Add ALLOCATE support
  nfs: Add DEALLOCATE support

 fs/nfs/nfs42.h            |   2 +
 fs/nfs/nfs42proc.c        |  92 +++++++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.c         | 136 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h          |   1 +
 fs/nfs/nfs4file.c         |  26 +++++++++
 fs/nfs/nfs4proc.c         |   4 +-
 fs/nfs/nfs4xdr.c          |   2 +
 include/linux/nfs4.h      |   2 +
 include/linux/nfs_fs_sb.h |   2 +
 include/linux/nfs_xdr.h   |  28 ++++++++++
 10 files changed, 294 insertions(+), 1 deletion(-)

-- 
2.1.3

