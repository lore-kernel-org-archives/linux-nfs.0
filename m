From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 085/112] SUNRPC: Fix use of copy_to_user() in
	gss_pipe_upcall()
Date: Fri, 25 Jan 2008 11:37:54 -0500
Message-ID: <20080125163754.31887.98510.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14327 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753687AbYAYQ7o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:44 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxfeo019943
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:44 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

The gss_pipe_upcall() function expects the copy_to_user() function to
return a negative error value if the call fails, but copy_to_user()
returns an unsigned long number of bytes that couldn't be copied.

Can rpc_pipefs actually retry a partially completed upcall read?  If
not, then gss_pipe_upcall() should punt any partial read, just like the
upcall logic in net/sunrpc/cache.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 1f2d85e..6dac387 100644
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
