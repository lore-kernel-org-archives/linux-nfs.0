From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC, PATCH 3/4] svc: Add svc_xprt_names service to replace
	svc_sock_names
Date: Fri, 19 Oct 2007 16:45:28 -0500
Message-ID: <20071019214528.31422.51364.stgit@dell3.ogc.int>
References: <20071019214058.31422.35615.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iizeq-0005vV-Bs
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:45:28 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iizev-0008H4-Gp
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:45:33 -0700
In-Reply-To: <20071019214058.31422.35615.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Create a transport independent version of the svc_sock_names function.

The toclose capability of the svc_sock_names service can be implemented
using the svc_xprt_find and svc_xprt_close services.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfsd/nfsctl.c                |    2 +-
 include/linux/sunrpc/svc_xprt.h |    5 +++--
 net/sunrpc/svc_xprt.c           |   35 +++++++++++++++++++++++++++++++++++
 3 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 0dfc130..3335270 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -503,7 +503,7 @@ static ssize_t write_ports(struct file *
 		int len = 0;
 		lock_kernel();
 		if (nfsd_serv)
-			len = svc_sock_names(buf, nfsd_serv, NULL);
+			len = svc_xprt_names(nfsd_serv, buf, 0);
 		unlock_kernel();
 		return len;
 	}
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 5dba9a5..b7d94ef 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -82,6 +82,7 @@ static inline void svc_xprt_get(struct s
 void	svc_delete_xprt(struct svc_xprt *xprt);
 void	svc_close_xprt(struct svc_xprt *xprt);
 int	svc_print_xprts(char *buf, int maxlen);
-struct svc_xprt *
-svc_find_xprt(struct svc_serv *serv, char *xprt_class, int af, int port);
+struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xprt_class,
+			       int af, int port);
+int	svc_xprt_names(struct svc_serv *serv, char *buf, int buflen);
 #endif /* SUNRPC_SVC_XPRT_H */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 13aacec..6b2c73c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -993,3 +993,38 @@ struct svc_xprt *svc_find_xprt(struct sv
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
+			       svc_local_port(xprt));
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

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
