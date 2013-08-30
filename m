Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46469 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755660Ab3H3Va2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Aug 2013 17:30:28 -0400
Date: Fri, 30 Aug 2013 17:30:27 -0400
To: linux-nfs@vger.kernel.org
Cc: Harshula Jayasuriya <harshula@redhat.com>
Subject: [PATCH] Revert "nfsd: nfs4_file_get_access: need to be more careful
 with O_RDWR"
Message-ID: <20130830213027.GA32015@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This reverts commit df66e75395c839c3a373bae897dbb1248f741b45.

nfsd4_lock can get a read-only or write-only reference when only a
read-write open is available.  This is normal.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5e609b1..eb9cf81 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -282,14 +282,19 @@ static unsigned int file_hashval(struct inode *ino)
 
 static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
 
+static void __nfs4_file_get_access(struct nfs4_file *fp, int oflag)
+{
+	WARN_ON_ONCE(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]));
+	atomic_inc(&fp->fi_access[oflag]);
+}
+
 static void nfs4_file_get_access(struct nfs4_file *fp, int oflag)
 {
-	WARN_ON_ONCE(!fp->fi_fds[oflag]);
 	if (oflag == O_RDWR) {
-		atomic_inc(&fp->fi_access[O_RDONLY]);
-		atomic_inc(&fp->fi_access[O_WRONLY]);
+		__nfs4_file_get_access(fp, O_RDONLY);
+		__nfs4_file_get_access(fp, O_WRONLY);
 	} else
-		atomic_inc(&fp->fi_access[oflag]);
+		__nfs4_file_get_access(fp, oflag);
 }
 
 static void nfs4_file_put_fd(struct nfs4_file *fp, int oflag)
-- 
1.7.9.5

