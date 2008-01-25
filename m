From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 087/112] NFS: Fix use of copy_to_user() in idmap_pipe_upcall
Date: Fri, 25 Jan 2008 11:37:55 -0500
Message-ID: <20080125163754.31887.71948.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53199 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756801AbYAYRAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:32 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Lmo010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:29 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

The idmap_pipe_upcall() function expects the copy_to_user() function to
return a negative error value if the call fails, but copy_to_user()
returns an unsigned long number of bytes that couldn't be copied.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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
