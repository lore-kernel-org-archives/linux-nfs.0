From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] NFSD: Enable NFS server use of PF_INET6
Date: Wed, 13 Jan 2010 16:10:48 -0500
Message-ID: <20100113211048.19409.86029.stgit@localhost.localdomain>
References: <20100113210650.19409.38009.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:29814 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab0AMVLE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jan 2010 16:11:04 -0500
In-Reply-To: <20100113210650.19409.38009.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Try to use an PF_INET6 listener for NFSD if IPv6 is enabled in the
kernel.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   36 +++++++++++++++++++++++++++++-------
 fs/nfsd/nfssvc.c |   27 ++++++++++++++++++++++-----
 2 files changed, 51 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 2604c3e..7ebb7a5 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -981,6 +981,26 @@ static ssize_t __write_ports_delfd(char *buf)
 	return len;
 }
 
+static ssize_t __write_ports_create_xprt(struct svc_serv *serv,
+					 const char *transport,
+					 const int family,
+					 const unsigned short port)
+{
+	int err;
+
+	err = svc_create_xprt(serv, transport, family, port,
+						SVC_SOCK_ANONYMOUS);
+
+	if (err < 0) {
+		/* Give a reasonable perror msg for bad transport string */
+		if (err == -ENOENT)
+			err = -EPROTONOSUPPORT;
+		return err;
+	}
+
+	return 0;
+}
+
 /*
  * A transport listener is added by writing it's transport name and
  * a port number.
@@ -1000,14 +1020,16 @@ static ssize_t __write_ports_addxprt(char *buf)
 	if (err != 0)
 		return err;
 
-	err = svc_create_xprt(nfsd_serv, transport,
-				PF_INET, port, SVC_SOCK_ANONYMOUS);
-	if (err < 0) {
-		/* Give a reasonable perror msg for bad transport string */
-		if (err == -ENOENT)
-			err = -EPROTONOSUPPORT;
+	err = __write_ports_create_xprt(nfsd_serv, transport, PF_INET, port);
+	if (err < 0)
 		return err;
-	}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	err = __write_ports_create_xprt(nfsd_serv, transport, PF_INET6, port);
+	if (err < 0 && err != -EAFNOSUPPORT)
+		return err;
+#endif	/* CONFIG_IPV6 || CONFIG_IPV6_MODULE */
+
 	return 0;
 }
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 171699e..7af14c1 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -275,14 +275,32 @@ int nfsd_create_serv(void)
 	return err;
 }
 
-static int nfsd_init_socks(int port)
+static int nfsd_create_xprt(const char *transport, const unsigned short port)
+{
+	int ret;
+
+	ret = svc_create_xprt(nfsd_serv, transport, PF_INET, port,
+							SVC_SOCK_DEFAULTS);
+	if (ret < 0)
+		return ret;
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	ret = svc_create_xprt(nfsd_serv, transport, PF_INET6, port,
+							SVC_SOCK_DEFAULTS);
+	if (ret < 0 && ret != -EAFNOSUPPORT)
+		return ret;
+#endif	/* CONFIG_IPV6 || CONFIG_IPV6_MODULE */
+
+	return 0;
+}
+
+static int nfsd_init_socks(const unsigned short port)
 {
 	int error;
 	if (!list_empty(&nfsd_serv->sv_permsocks))
 		return 0;
 
-	error = svc_create_xprt(nfsd_serv, "udp", PF_INET, port,
-					SVC_SOCK_DEFAULTS);
+	error = nfsd_create_xprt("udp", port);
 	if (error < 0)
 		return error;
 
@@ -290,8 +308,7 @@ static int nfsd_init_socks(int port)
 	if (error < 0)
 		return error;
 
-	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
-					SVC_SOCK_DEFAULTS);
+	error = nfsd_create_xprt("tcp", port);
 	if (error < 0)
 		return error;
 

