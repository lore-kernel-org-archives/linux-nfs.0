Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.molgen.mpg.de ([141.14.17.9]:51558 "EHLO mx1.molgen.mpg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330AbbLYMlb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Dec 2015 07:41:31 -0500
From: Donald Buczek <buczek@molgen.mpg.de>
To: linux-nfs@vger.kernel.org, anna.schumaker@netapp.com,
        trond.myklebust@primarydata.com
Cc: Donald Buczek <buczek@molgen.mpg.de>
Subject: [PATCH] nfs: do not deny execute access based on outdated mode in inode
Date: Fri, 25 Dec 2015 13:30:56 +0100
Message-Id: <1451046656-26319-1-git-send-email-buczek@molgen.mpg.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch fixes a problem, that a nfs4 client incorrectly denies
execute access based on outdated file mode (missing 'x' bit).
After the mode on the server is 'fixed' (chmod +x) further execution
attempts continue to fail, because the nfs ACCESS call updates
the access parameter but not the mode parameter or the mode in
the inode.

The access check based on the file mode is not required, because
the server already verified the clients rights.

Remove the test.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=109771
Signed-off-by: Donald Buczek <buczek@molgen.mpg.de>
---
 fs/nfs/dir.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ce5a218..ffc25b0 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2481,9 +2481,6 @@ force_lookup:
 			res = PTR_ERR(cred);
 	}
 out:
-	if (!res && (mask & MAY_EXEC) && !execute_ok(inode))
-		res = -EACCES;
-
 	dfprintk(VFS, "NFS: permission(%s/%lu), mask=0x%x, res=%d\n",
 		inode->i_sb->s_id, inode->i_ino, mask, res);
 	return res;
-- 
2.4.1

