From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] SUNRPC: Fix use of copy_to_user() in gss_pipe_upcall()
Date: Thu, 20 Dec 2007 14:54:27 -0500
Message-ID: <20071220195427.3280.81386.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:45363 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847AbXLTTyq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2007 14:54:46 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The gss_pipe_upcall() function expects the copy_to_user() function to
return a negative error value if the call fails, but copy_to_user()
returns an unsigned long number of bytes that couldn't be copied.

Can rpc_pipefs actually retry a partially completed upcall read?  If
not, then gss_pipe_upcall() should punt any partial read, just like the
upcall logic in net/sunrpc/cache.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index a6e57d1..1fa7e76 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -472,16 +472,15 @@ gss_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
 		char __user *dst, size_t buflen)
 {
 	char *data = (char *)msg->data + msg->copied;
-	ssize_t mlen = msg->len;
-	ssize_t left;
+	size_t mlen = min(msg->len, buflen);
+	unsigned long left;
 
-	if (mlen > buflen)
-		mlen = buflen;
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

