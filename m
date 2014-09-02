Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:28745 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125AbaIBRbF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Sep 2014 13:31:05 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] NFS: Add v4.2 SEEK support
Date: Tue, 2 Sep 2014 13:30:59 -0400
Message-ID: <1409679060-32313-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds support for the NFS v4.2 operation SEEK.

I think nfs4proc.c and nfs4xdr.c have grown out of control, and I would like
to avoid adding new functions to these files unless absolutely necessary.
Therefore, I created nfs42proc.c and nfs42xdr.h in an attempt to separate
out the new code.

Changes is v2:
- Remove dots from filenames to keep Christoph happy :)

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
 fs/nfs/nfs42proc.c        | 39 +++++++++++++++++++
 fs/nfs/nfs42xdr.h         | 98 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h          |  7 ++++
 fs/nfs/nfs4client.c       |  2 +
 fs/nfs/nfs4file.c         | 68 ++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |  1 -
 fs/nfs/nfs4xdr.c          |  7 ++++
 fs/nfsd/nfs4proc.c        |  2 +-
 include/linux/nfs4.h      |  3 ++
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   | 19 +++++++++
 14 files changed, 262 insertions(+), 2 deletions(-)
 create mode 100644 fs/nfs/nfs42.h
 create mode 100644 fs/nfs/nfs42proc.c
 create mode 100644 fs/nfs/nfs42xdr.h

-- 
2.1.0

