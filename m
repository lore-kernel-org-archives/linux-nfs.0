From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 40/40] svc: Add svc_xprt_names service to replace svc_sock_names
Date: Sun, 30 Dec 2007 21:08:37 -0600
Message-ID: <20071231030837.8430.35769.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41610 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753122AbXLaDIi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:08:38 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Create a transport independent version of the svc_sock_names function.

The toclose capability of the svc_sock_names service can be implemented
using the svc_xprt_find and svc_xprt_close services.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfsd/nfsctl.c                |    2 +-
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svc_xprt.c           |   35 +++++++++++++++++++++++++++++++++++
 3 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 2e4e6ff..10c13ed 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -503,7 +503,7 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 		int len = 0;
 		lock_kernel();
 		if (nfsd_serv)
-			len = svc_sock_names(buf, nfsd_serv, NULL);
+			len = svc_xprt_names(nfsd_serv, buf, 0);
 		unlock_kernel();
 		return len;
 	}
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 68862d5..6fd7b01 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -81,6 +81,7 @@ void	svc_delete_xprt(struct svc_xprt *xprt);
 int	svc_port_is_privileged(struct sockaddr *sin);
 int	svc_print_xprts(char *buf, int maxlen);
 struct	svc_xprt *svc_find_xprt(struct svc_serv *, char *, int, int);
+int	svc_xprt_names(struct svc_serv *serv, char *buf, int buflen);
 
 static inline void svc_xprt_get(struct svc_xprt *xprt)
 {
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index f239928..5545c1e 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1013,3 +1013,38 @@ struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xcl_name,
 	return found;
 }
 EXPORT_SYMBOL_GPL(svc_find_xprt);
+
+/*
+ * Format a buffer with a list of the active transports. A zero for
+ * the buflen parameter disables target buffer overflow checking.
+ */
+int svc_xprt_names(struct svc_serv *serv, char *buf, int buflen)
+{
+	struct svc_xprt *xprt;
+	char xprt_str[64];
+	int totlen = 0;
+	int len;
+
+	/* Sanity check args */
+	if (!serv)
+		return 0;
+
+	spin_lock_bh(&serv->sv_lock);
+	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list) {
+		len = snprintf(xprt_str, sizeof(xprt_str),
+			       "%s %d\n", xprt->xpt_class->xcl_name,
+			       svc_xprt_local_port(xprt));
+		/* If the string was truncated, replace with error string */
+		if (len >= sizeof(xprt_str))
+			strcpy(xprt_str, "name-too-long\n");
+		/* Don't overflow buffer */
+		len = strlen(xprt_str);
+		if (buflen && (len + totlen >= buflen))
+			break;
+		strcpy(buf+totlen, xprt_str);
+		totlen += len;
+	}
+	spin_unlock_bh(&serv->sv_lock);
+	return totlen;
+}
+EXPORT_SYMBOL_GPL(svc_xprt_names);
