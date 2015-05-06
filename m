Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:33596 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbbEFW1D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 18:27:03 -0400
Received: by qctx5 with SMTP id x5so12536222qct.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 May 2015 15:27:02 -0700 (PDT)
Subject: [PATCH] nfs: stat(2) fails during cthon04 basic test5 on NFSv4.0
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 06 May 2015 18:26:58 -0400
Message-ID: <20150506221845.9617.15746.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When running the Connectathon basic tests against a Solaris NFS
server over NFSv4.0, test5 reports that stat(2) returns a file size
of zero instead of 1MB.

On success, nfs_commit_inode() can return a positive result; see
other call sites such as nfs_file_fsync_commit() and
nfs_commit_unstable_pages().

The call site recently added in nfs_wb_all() does not prevent that
positive return value from leaking to its callers. If it leaks
through nfs_sync_inode() back to nfs_getattr(), that causes stat(2)
to return a positive return value to user space while also not
filling in the passed-in struct stat.

Additional clean up: the new logic in nfs_wb_all() is rewritten in
bfields-normal form.

Fixes: 5bb89b4702e2 ("NFSv4.1/pnfs: Separate out metadata . . .")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Hi Trond-

This fixes yesterday's issue for me. I've tested with xfstests
and Connectathon over NFSv4.0 against Solaris and Linux NFS servers.


 fs/nfs/write.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d12a4be..dfc19f1 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1845,12 +1845,15 @@ int nfs_wb_all(struct inode *inode)
 	trace_nfs_writeback_inode_enter(inode);
 
 	ret = filemap_write_and_wait(inode->i_mapping);
-	if (!ret) {
-		ret = nfs_commit_inode(inode, FLUSH_SYNC);
-		if (!ret)
-			pnfs_sync_inode(inode, true);
-	}
+	if (ret)
+		goto out;
+	ret = nfs_commit_inode(inode, FLUSH_SYNC);
+	if (ret < 0)
+		goto out;
+	pnfs_sync_inode(inode, true);
+	ret = 0;
 
+out:
 	trace_nfs_writeback_inode_exit(inode, ret);
 	return ret;
 }

