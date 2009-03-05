From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/23] NFSD: Prevent a buffer overflow in svc_xprt_names()
Date: Thu, 05 Mar 2009 16:32:46 -0500
Message-ID: <20090305213245.21342.51669.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:22006 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754043AbZCEVdB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:33:01 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The svc_xprt_names() function can overflow its buffer if it's so near
the end of the passed in buffer that the "name too long" string still
doesn't fit.  Of course, it could never tell if it was near the end
of the passed in buffer, since its only caller passes in zero as the
buffer length.

Let's make this API a little safer.

Change svc_xprt_names() so it *always* checks for a buffer overflow,
and change its only caller to pass in the correct buffer length.

If svc_xprt_names() does overflow its buffer, just fail with a
reasonable errno code, instead of trying to write a message at the end
of the buffer.  I don't like this much, but I can't figure out a clean
way that's always safe to return some of the names, *and* an
indication that the buffer was not long enough.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c                |    2 +
 include/linux/sunrpc/svc_xprt.h |    2 +
 net/sunrpc/svc_xprt.c           |   56 +++++++++++++++++++++++++++------------
 3 files changed, 41 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index aa60191..b0f7300 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -887,7 +887,7 @@ static ssize_t __write_ports_names(char *buf)
 {
 	if (nfsd_serv == NULL)
 		return 0;
-	return svc_xprt_names(nfsd_serv, buf, 0);
+	return svc_xprt_names(nfsd_serv, buf, SIMPLE_TRANSACTION_LIMIT);
 }
 
 /*
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 819257c..aab050b 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -83,7 +83,7 @@ int	svc_port_is_privileged(struct sockaddr *sin);
 int	svc_print_xprts(char *buf, int maxlen);
 struct	svc_xprt *svc_find_xprt(struct svc_serv *serv, const char *xcl_name,
 			const sa_family_t family, const unsigned short port);
-int	svc_xprt_names(struct svc_serv *serv, char *buf, int buflen);
+int	svc_xprt_names(struct svc_serv *serv, char *buf, const int buflen);
 
 static inline void svc_xprt_get(struct svc_xprt *xprt)
 {
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 9d28051..da64e1a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1079,36 +1079,58 @@ struct svc_xprt *svc_find_xprt(struct svc_serv *serv, const char *xcl_name,
 }
 EXPORT_SYMBOL_GPL(svc_find_xprt);
 
-/*
- * Format a buffer with a list of the active transports. A zero for
- * the buflen parameter disables target buffer overflow checking.
+static int svc_one_xprt_name(const struct svc_xprt *xprt,
+			     char *pos, int remaining)
+{
+	int len;
+
+	len = snprintf(pos, remaining, "%s %u\n",
+			xprt->xpt_class->xcl_name,
+			svc_xprt_local_port(xprt));
+	if (len >= remaining)
+		return -ENAMETOOLONG;
+	return len;
+}
+
+/**
+ * svc_xprt_names - format a buffer with a list of transport names
+ * @serv: pointer to an RPC service
+ * @buf: pointer to a buffer to be filled in
+ * @buflen: length of buffer to be filled in
+ *
+ * Fills in @buf with a string containing a list of transport names,
+ * each name terminated with '\n'.
+ *
+ * Returns positive length of the filled-in string on success; otherwise
+ * a negative errno value is returned if an error occurs.
  */
-int svc_xprt_names(struct svc_serv *serv, char *buf, int buflen)
+int svc_xprt_names(struct svc_serv *serv, char *buf, const int buflen)
 {
 	struct svc_xprt *xprt;
-	char xprt_str[64];
-	int totlen = 0;
-	int len;
+	int len, totlen;
+	char *pos;
 
 	/* Sanity check args */
 	if (!serv)
 		return 0;
 
 	spin_lock_bh(&serv->sv_lock);
+
+	pos = buf;
+	totlen = 0;
 	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list) {
-		len = snprintf(xprt_str, sizeof(xprt_str),
-			       "%s %d\n", xprt->xpt_class->xcl_name,
-			       svc_xprt_local_port(xprt));
-		/* If the string was truncated, replace with error string */
-		if (len >= sizeof(xprt_str))
-			strcpy(xprt_str, "name-too-long\n");
-		/* Don't overflow buffer */
-		len = strlen(xprt_str);
-		if (buflen && (len + totlen >= buflen))
+		len = svc_one_xprt_name(xprt, pos, buflen - totlen);
+		if (len < 0) {
+			*buf = '\0';
+			totlen = len;
+		}
+		if (len <= 0)
 			break;
-		strcpy(buf+totlen, xprt_str);
+
+		pos += len;
 		totlen += len;
 	}
+
 	spin_unlock_bh(&serv->sv_lock);
 	return totlen;
 }

