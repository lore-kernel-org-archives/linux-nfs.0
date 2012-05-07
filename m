Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1780 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756571Ab2EGOHe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 May 2012 10:07:34 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFS: Don't do a full flush to disk on close() if we hold a delegation
Date: Mon,  7 May 2012 10:07:29 -0400
Message-Id: <1336399651-6596-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we hold a delegation then we know that it should be safe to continue
to cache the data beyond the close(). However since the process that wrote
the data may die after close(), we may still want to send the data to
server before those RPCSEC_GSS credentials expire. We therefore compromise
by starting writeback to the server, but don't wait for completion.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/file.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index aa9b709..8eda8a6 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -174,6 +174,13 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 	if ((file->f_mode & FMODE_WRITE) == 0)
 		return 0;
 
+	/*
+	 * If we're holding a write delegation, then just start the i/o
+	 * but don't wait for completion (or send a commit).
+	 */
+	if (nfs_have_delegation(inode, FMODE_WRITE))
+		return filemap_fdatawrite(file->f_mapping);
+
 	/* Flush writes to the server and return any errors */
 	return vfs_fsync(file, 0);
 }
-- 
1.7.7.6

