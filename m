Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e18.ny.us.ibm.com ([129.33.205.208]:54284 "EHLO
	e18.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbbJ1ACP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Oct 2015 20:02:15 -0400
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Tue, 27 Oct 2015 20:02:15 -0400
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 4D29CC90043
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2015 19:50:23 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9S02CYF61931634
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2015 00:02:12 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9S02BCs011208
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2015 20:02:12 -0400
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: Malahal Naineni <malahal@us.ibm.com>
Subject: [PATCH] Close etab file's file descriptor on stat error.
Date: Tue, 27 Oct 2015 19:01:30 -0500
Message-Id: <1445990490-1941-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also, fixed erroneously closing file descriptor 0 at init time.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 utils/mountd/auth.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 330cab5..894a7a5 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -85,7 +85,7 @@ auth_reload()
 {
 	struct stat		stb;
 	static ino_t		last_inode;
-	static int		last_fd;
+	static int		last_fd = -1;
 	static unsigned int	counter;
 	int			fd;
 
@@ -93,11 +93,22 @@ auth_reload()
 		xlog(L_FATAL, "couldn't open %s", _PATH_ETAB);
 	} else if (fstat(fd, &stb) < 0) {
 		xlog(L_FATAL, "couldn't stat %s", _PATH_ETAB);
-	} else if (stb.st_ino == last_inode) {
+		close(fd);
+	} else if (last_fd != -1 && stb.st_ino == last_inode) {
+		/* We opened the etab file before, and its inode
+		 * number hasn't changed since then.
+		 */
 		close(fd);
 		return counter;
 	} else {
-		close(last_fd);
+		/* Need to process entries from the etab file.  Close
+		 * the file descriptor from the previous open (last_fd),
+		 * and keep the current file descriptor open to prevent
+		 * the file system reusing the current inode number
+		 * (last_inode).
+		 */
+		if (last_fd != -1)
+			close(last_fd);
 		last_fd = fd;
 		last_inode = stb.st_ino;
 	}
-- 
1.8.3.1

