Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:35659 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755617Ab0BATRv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2010 14:17:51 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] More short subjects for 2.6.34
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 01 Feb 2010 14:17:06 -0500
Message-ID: <20100201191415.20189.39710.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here are some performance metric accounting fixes to consider for
2.6.34.  Also, a close(2) optimization for O_DIRECT files.

---

Chuck Lever (5):
      NFS: Make close(2) asynchronous when closing NFS O_DIRECT files
      NFS: Improve NFS iostat byte count accuracy for writes
      NFS: Account for NFS bytes read via the splice API
      NFS: Fix byte accounting for generic NFS reads
      NFS: Proper accounting for NFS VFS calls


 fs/nfs/file.c  |   30 ++++++++++++++++++++++--------
 fs/nfs/inode.c |    7 +------
 2 files changed, 23 insertions(+), 14 deletions(-)

-- 
Chuck Lever
