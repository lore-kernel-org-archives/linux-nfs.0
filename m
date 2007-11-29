From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 37/38] knfsd: Modify write_ports to use svc_find_xprt service
Date: Thu, 29 Nov 2007 16:41:11 -0600
Message-ID: <20071129224111.14563.35243.stgit@dell3.ogc.int>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields-ag9A2Eb6PFsgsBAKwltoeQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:48891 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934199AbXK2XDn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:03:43 -0500
In-Reply-To: <20071129223917.14563.77633.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patch enhances the write_ports function as follows:

- Check if a server transport instance already exists before attempting to 
  create a new one, and 

- Implement the ability to remove a previously created server transport
  instance. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfsd/nfsctl.c      |   36 +++++++++++++++++++++++++++++++++---
 net/sunrpc/svc_xprt.c |    1 +
 2 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 1f998c0..e0e53e1 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -540,7 +540,7 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 		}
 		return err < 0 ? err : 0;
 	}
-	if (buf[0] == '-') {
+	if (buf[0] == '-' && isdigit(buf[1])) {
 		char *toclose = kstrdup(buf+1, GFP_KERNEL);
 		int len = 0;
 		if (!toclose)
@@ -557,16 +557,46 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 	/*
 	 * Add a transport listener by writing it's transport name
 	 */
-	if (isalnum(buf[0])) {
+	if (isalpha(buf[0])) {
 		int err;
 		char transport[16];
 		int port;
 		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
 			err = nfsd_create_serv();
-			if (!err)
+			if (!err) {
+				if (svc_find_xprt(nfsd_serv, transport,
+						  AF_UNSPEC, port))
+					return -EADDRINUSE;
+
 				err = svc_create_xprt(nfsd_serv,
 						      transport, port,
 						      SVC_SOCK_ANONYMOUS);
+			}
+			return err < 0 ? err : 0;
+		}
+	}
+	/*
+	 * Remove a transport by writing it's transport name and port number
+	 */
+	if (buf[0] == '-' && isalpha(buf[1])) {
+		struct svc_xprt *xprt;
+		int err = -EINVAL;
+		char transport[16];
+		int port;
+		if (sscanf(&buf[1], "%15s %4d", transport, &port) == 2) {
+			if (port == 0)
+				return -EINVAL;
+			lock_kernel();
+			if (nfsd_serv) {
+				xprt = svc_find_xprt(nfsd_serv, transport,
+						     AF_UNSPEC, port);
+				if (xprt) {
+					svc_close_xprt(xprt);
+					err = 0;
+				} else
+					err = -ENOENT;
+			}
+			unlock_kernel();
 			return err < 0 ? err : 0;
 		}
 	}
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 247f0fb..57d50db 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -810,6 +810,7 @@ void svc_close_xprt(struct svc_xprt *xprt)
 	clear_bit(XPT_BUSY, &xprt->xpt_flags);
 	svc_xprt_put(xprt);
 }
+EXPORT_SYMBOL_GPL(svc_close_xprt);
 
 void svc_close_all(struct list_head *xprt_list)
 {
