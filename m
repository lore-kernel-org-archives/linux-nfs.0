From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/13] NFSD: Refactor __write_ports()
Date: Wed, 05 Nov 2008 12:28:51 -0500
Message-ID: <20081105172851.7330.48160.stgit@ingres.1015granger.net>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:42074 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbYKERaN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:30:13 -0500
In-Reply-To: <20081105172351.7330.50739.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  The __write_ports() function is a twisty little maze of
"if" statements, all alike.

The /proc/fs/nfsd/portlist file interface has grown in complexity
since it was first introduced.  Use recently introduced helpers to
refactor the portlist file's parser function into something easier to
read and expand.

I don't intend to expand it, but in subsequent patches I will fix a
few bugs, and introduce IPv6 support.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |  114 ++++++++++--------------------------------------------
 1 files changed, 21 insertions(+), 93 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 0e64d92..fa6441b 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -991,100 +991,28 @@ static ssize_t __write_ports_delxprt(char *buf, size_t size,
 
 static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 {
-	if (size == 0) {
-		int len = 0;
+	char transport[16];
+	int port;
+
+	if (size == 0)
+		return __write_ports_names(buf, size);
+
+	if (isdigit(buf[0]))
+		return __write_ports_addfd(buf, size);
+
+	if (buf[0] == '-' && isdigit(buf[1]))
+		return __write_ports_delfd(buf, size);
+
+	if (isalpha(buf[0]))
+		if (sscanf(buf, "%15s %4u", transport, &port) == 2)
+			return __write_ports_addxprt(buf, size,
+							transport, port);
+
+	if (buf[0] == '-' && isalpha(buf[1]))
+		if (sscanf(&buf[1], "%15s %4u", transport, &port) == 2)
+			return __write_ports_delxprt(buf, size,
+							transport, port);
 
-		if (nfsd_serv)
-			len = svc_xprt_names(nfsd_serv, buf, 0);
-		return len;
-	}
-	/* Either a single 'fd' number is written, in which
-	 * case it must be for a socket of a supported family/protocol,
-	 * and we use it as an nfsd socket, or
-	 * A '-' followed by the 'name' of a socket in which case
-	 * we close the socket.
-	 */
-	if (isdigit(buf[0])) {
-		char *mesg = buf;
-		int fd;
-		int err;
-		err = get_int(&mesg, &fd);
-		if (err)
-			return -EINVAL;
-		if (fd < 0)
-			return -EINVAL;
-		err = nfsd_create_serv();
-		if (!err) {
-			err = svc_addsock(nfsd_serv, fd, buf);
-			if (err >= 0) {
-				err = lockd_up();
-				if (err < 0)
-					svc_sock_names(buf+strlen(buf)+1, nfsd_serv, buf);
-			}
-			/* Decrease the count, but don't shutdown the
-			 * the service
-			 */
-			nfsd_serv->sv_nrthreads--;
-		}
-		return err < 0 ? err : 0;
-	}
-	if (buf[0] == '-' && isdigit(buf[1])) {
-		char *toclose = kstrdup(buf+1, GFP_KERNEL);
-		int len = 0;
-		if (!toclose)
-			return -ENOMEM;
-		if (nfsd_serv)
-			len = svc_sock_names(buf, nfsd_serv, toclose);
-		if (len >= 0)
-			lockd_down();
-		kfree(toclose);
-		return len;
-	}
-	/*
-	 * Add a transport listener by writing it's transport name
-	 */
-	if (isalpha(buf[0])) {
-		int err;
-		char transport[16];
-		int port;
-		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
-			err = nfsd_create_serv();
-			if (!err) {
-				err = svc_create_xprt(nfsd_serv,
-						      transport, port,
-						      SVC_SOCK_ANONYMOUS);
-				if (err == -ENOENT)
-					/* Give a reasonable perror msg for
-					 * bad transport string */
-					err = -EPROTONOSUPPORT;
-			}
-			return err < 0 ? err : 0;
-		}
-	}
-	/*
-	 * Remove a transport by writing it's transport name and port number
-	 */
-	if (buf[0] == '-' && isalpha(buf[1])) {
-		struct svc_xprt *xprt;
-		int err = -EINVAL;
-		char transport[16];
-		int port;
-		if (sscanf(&buf[1], "%15s %4d", transport, &port) == 2) {
-			if (port == 0)
-				return -EINVAL;
-			if (nfsd_serv) {
-				xprt = svc_find_xprt(nfsd_serv, transport,
-						     AF_UNSPEC, port);
-				if (xprt) {
-					svc_close_xprt(xprt);
-					svc_xprt_put(xprt);
-					err = 0;
-				} else
-					err = -ENOTCONN;
-			}
-			return err < 0 ? err : 0;
-		}
-	}
 	return -EINVAL;
 }
 

