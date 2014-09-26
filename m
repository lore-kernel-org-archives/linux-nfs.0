Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:7282 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755368AbaIZR6v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2014 13:58:51 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v3] NFS: Add v4.2 SEEK support
Date: Fri, 26 Sep 2014 13:58:47 -0400
Message-ID: <1411754328-18589-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds support for the NFS v4.2 operation SEEK.  I add this
operation to new NFS v4.2 XDR and proc files to help ease the maintenance
burden on new operations.

Changes in v3:
- Rename nfs42xdr.h -> nfs42xdr.c
- Use nfs_v4_2_minor_ops to set up initial capabilities
- Do more work in nfs42proc.c (check capabilities, find correct stateids ...)

This patch and the corresponding server changes are available in the [seek]
branch of:

	git://git.linux-nfs.org/projects/anna/linux-nfs.git

Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (1):
  NFS: Implement SEEK

 fs/nfs/Makefile           |  1 +
 fs/nfs/inode.c            |  2 +
 fs/nfs/nfs42.h            | 14 +++++++
 fs/nfs/nfs42proc.c        | 69 +++++++++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.c         | 98 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h          |  3 ++
 fs/nfs/nfs4file.c         | 25 ++++++++++++
 fs/nfs/nfs4proc.c         |  4 +-
 fs/nfs/nfs4xdr.c          |  7 ++++
 include/linux/nfs4.h      |  3 ++
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   | 19 +++++++++
 12 files changed, 244 insertions(+), 2 deletions(-)
 create mode 100644 fs/nfs/nfs42.h
 create mode 100644 fs/nfs/nfs42proc.c
 create mode 100644 fs/nfs/nfs42xdr.c

-- 
2.1.0

