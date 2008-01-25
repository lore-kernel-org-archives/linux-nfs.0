From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 041/112] NFS: Prevent nfs_getattr() hang during heavy write
	workloads
Date: Fri, 25 Jan 2008 11:37:36 -0500
Message-ID: <20080125163735.31887.45520.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14345 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755001AbYAYQ7u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:50 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxdtC010119
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:49 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

POSIX requires that ctime and mtime, as reported by the stat(2) call,
reflect the activity of the most recent write(2).  To that end, nfs_getattr()
flushes pending dirty writes to a file before doing a GETATTR to allow the
NFS server to set the file's size, ctime, and mtime properly.

However, nfs_getattr() can be starved when a constant stream of application
writes to a file prevents nfs_wb_nocommit() from completing.  This usually
results in hangs of programs doing a stat against an NFS file that is being
written.  "ls -l" is a common victim of this behavior.

To prevent starvation, hold the file's i_mutex in nfs_getattr() to
freeze applications writes temporarily so the client can more quickly obtain
clean values for a file's size, mtime, and ctime.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index cd0e57f..cc3a09d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -461,9 +461,18 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
 	int err;
 
-	/* Flush out writes to the server in order to update c/mtime */
-	if (S_ISREG(inode->i_mode))
+	/*
+	 * Flush out writes to the server in order to update c/mtime.
+	 *
+	 * Hold the i_mutex to suspend application writes temporarily;
+	 * this prevents long-running writing applications from blocking
+	 * nfs_wb_nocommit.
+	 */
+	if (S_ISREG(inode->i_mode)) {
+		mutex_lock(&inode->i_mutex);
 		nfs_wb_nocommit(inode);
+		mutex_unlock(&inode->i_mutex);
+	}
 
 	/*
 	 * We may force a getattr if the user cares about atime.
