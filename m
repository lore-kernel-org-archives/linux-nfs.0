Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:17054 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276AbaICQTR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Sep 2014 12:19:17 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/4] NFS: Remove as many CONFIG_NFS_V3s as possible
Date: Wed, 3 Sep 2014 12:19:06 -0400
Message-ID: <1409761150-30257-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS client has a different module for each NFS version, but changing
compile options in one module usually causes everything else in the client
to recompile.  These patches begin to break inter-module dependencies with
the NFS v3 module.

Currently, toggling CONFIG_NFS_V3={n,m} will cause most of the NFS client and
random files in lockd, exofs and nfsd to recompile.  After applying these
patches, only fs/nfs/super.c will recompile when changing the existence of
NFS v3.

Changing the status of NFS v4 still causes way too much to recompile, but that
is an adventure for another day.

Questions? Comments? Thoughts?

Anna


Anna Schumaker (4):
  NFS: Unconditionally enable commit code
  NFS: Move v3 declarations out of internal.h
  NFS: Remove v3 not compiled check from validate_mount_data()
  NFS: Move NFS v3 acl functions to nfs3_fs.h

 fs/nfs/direct.c        | 14 -------------
 fs/nfs/internal.h      |  7 -------
 fs/nfs/nfs3_fs.h       | 34 +++++++++++++++++++++++++++++++
 fs/nfs/nfs3proc.c      |  1 +
 fs/nfs/nfs3super.c     |  1 +
 fs/nfs/super.c         | 11 ----------
 fs/nfs/write.c         | 54 --------------------------------------------------
 include/linux/nfs_fs.h | 41 --------------------------------------
 8 files changed, 36 insertions(+), 127 deletions(-)
 create mode 100644 fs/nfs/nfs3_fs.h

-- 
2.1.0

