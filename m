From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfsd: have __write_ports_add/delxprt get/put lockd references for transports
Date: Thu, 17 Jun 2010 10:17:47 -0400
Message-ID: <1276784267-28500-3-git-send-email-jlayton@redhat.com>
References: <1276784267-28500-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, chris-TF6qbakwsgc2epGFuHBODCp2UmYkHbXO@public.gmane.org,
	linux-kernel@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37305 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932869Ab0FQOWR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 10:22:17 -0400
In-Reply-To: <1276784267-28500-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd_last_thread expects that any socket on sv_permsocks will hold a
lockd reference. Make sure that __write_ports_addxprt takes a lockd
reference for each socket it creates and have __write_ports_delxprt
release references when it closes a socket.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfsctl.c |   59 ++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 42 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 9e8645a..365aee0 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -989,6 +989,21 @@ static ssize_t __write_ports_delfd(char *buf)
 	return len;
 }
 
+static int
+nfsd_shutdown_xprt(const char *transport, const unsigned short family,
+		     const int port)
+{
+	struct svc_xprt *xprt;
+
+	xprt = svc_find_xprt(nfsd_serv, transport, family, port);
+	if (xprt == NULL)
+		return -ENOTCONN;
+
+	svc_close_xprt(xprt);
+	svc_xprt_put(xprt);
+	return 0;
+}
+
 /*
  * A transport listener is added by writing it's transport name and
  * a port number.
@@ -996,7 +1011,6 @@ static ssize_t __write_ports_delfd(char *buf)
 static ssize_t __write_ports_addxprt(char *buf)
 {
 	char transport[16];
-	struct svc_xprt *xprt;
 	int port, err;
 
 	if (sscanf(buf, "%15s %4u", transport, &port) != 2)
@@ -1014,20 +1028,29 @@ static ssize_t __write_ports_addxprt(char *buf)
 	if (err < 0)
 		goto out_err;
 
+	err = lockd_up();
+	if (err != 0) {
+		nfsd_shutdown_xprt(transport, PF_INET, port);
+		goto out_err;
+	}
+
 	err = svc_create_xprt(nfsd_serv, transport,
 				PF_INET6, port, SVC_SOCK_ANONYMOUS);
-	if (err < 0 && err != -EAFNOSUPPORT)
-		goto out_close;
+	if (err < 0 && err != -EAFNOSUPPORT) {
+		nfsd_shutdown_xprt(transport, PF_INET, port);
+		goto out_err;
+	}
+
+	err = lockd_up();
+	if (err != 0) {
+		nfsd_shutdown_xprt(transport, PF_INET6, port);
+		nfsd_shutdown_xprt(transport, PF_INET, port);
+		goto out_err;
+	}
 
 	/* Decrease the count, but don't shut down the service */
 	nfsd_serv->sv_nrthreads--;
 	return 0;
-out_close:
-	xprt = svc_find_xprt(nfsd_serv, transport, PF_INET, port);
-	if (xprt != NULL) {
-		svc_close_xprt(xprt);
-		svc_xprt_put(xprt);
-	}
 out_err:
 	svc_destroy(nfsd_serv);
 	return err;
@@ -1039,9 +1062,8 @@ out_err:
  */
 static ssize_t __write_ports_delxprt(char *buf)
 {
-	struct svc_xprt *xprt;
 	char transport[16];
-	int port;
+	int port, err;
 
 	if (sscanf(&buf[1], "%15s %4u", transport, &port) != 2)
 		return -EINVAL;
@@ -1049,13 +1071,16 @@ static ssize_t __write_ports_delxprt(char *buf)
 	if (port < 1 || port > USHRT_MAX || nfsd_serv == NULL)
 		return -EINVAL;
 
-	xprt = svc_find_xprt(nfsd_serv, transport, AF_UNSPEC, port);
-	if (xprt == NULL)
-		return -ENOTCONN;
+	/* PF_INET6 sockets are considered optional */
+	err = nfsd_shutdown_xprt(transport, PF_INET6, port);
+	if (err == 0)
+		lockd_down();
 
-	svc_close_xprt(xprt);
-	svc_xprt_put(xprt);
-	return 0;
+	err = nfsd_shutdown_xprt(transport, PF_INET, port);
+	if (err == 0)
+		lockd_down();
+
+	return err;
 }
 
 static ssize_t __write_ports(struct file *file, char *buf, size_t size)
-- 
1.5.5.6

