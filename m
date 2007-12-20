From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] NFS: Fix use of copy_to_user() in idmap_pipe_upcall
Date: Thu, 20 Dec 2007 14:54:42 -0500
Message-ID: <20071220195442.3280.68362.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:45829 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbXLTTy5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2007 14:54:57 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The idmap_pipe_upcall() function expects the copy_to_user() function to
return a negative error value if the call fails, but copy_to_user()
returns an unsigned long number of bytes that couldn't be copied.
    
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/idmap.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index c56fc7d..d93e071 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -358,17 +358,15 @@ idmap_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
 		  char __user *dst, size_t buflen)
 {
 	char *data = (char *)msg->data + msg->copied;
-	ssize_t mlen = msg->len - msg->copied;
-	ssize_t left;
-
-	if (mlen > buflen)
-		mlen = buflen;
+	size_t mlen = min(msg->len, buflen);
+	unsigned long left;
 
 	left = copy_to_user(dst, data, mlen);
-	if (left < 0) {
-		msg->errno = left;
-		return left;
+	if (left == mlen) {
+		msg->errno = -EFAULT;
+		return -EFAULT;
 	}
+
 	mlen -= left;
 	msg->copied += mlen;
 	msg->errno = 0;

