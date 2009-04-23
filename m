From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/19] SUNRPC: pass buffer size to svc_sock_names()
Date: Thu, 23 Apr 2009 19:32:40 -0400
Message-ID: <20090423233240.17283.47256.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:29448 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbZDWXe3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:34:29 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adjust the synopsis of svc_sock_names() to pass in the size of the
output buffer.  Add a documenting comment.

This is a cosmetic change for now.  A subsequent patch will make sure
the buffer length is passed to one_sock_name(), where the length will
actually be useful.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c               |    3 ++-
 include/linux/sunrpc/svcsock.h |    4 +++-
 net/sunrpc/svcsock.c           |   19 +++++++++++++++++--
 3 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 1f1c215..b64a7fb 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -966,7 +966,8 @@ static ssize_t __write_ports_delfd(char *buf)
 		return -ENOMEM;
 
 	if (nfsd_serv != NULL)
-		len = svc_sock_names(buf, nfsd_serv, toclose);
+		len = svc_sock_names(nfsd_serv, buf,
+					SIMPLE_TRANSACTION_LIMIT, toclose);
 	if (len >= 0)
 		lockd_down();
 
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index e23241c..8271631 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -38,7 +38,9 @@ int		svc_recv(struct svc_rqst *, long);
 int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);
 void		svc_sock_update_bufs(struct svc_serv *serv);
-int		svc_sock_names(char *buf, struct svc_serv *serv, char *toclose);
+int		svc_sock_names(struct svc_serv *serv, char *buf,
+					const size_t buflen,
+					const char *toclose);
 int		svc_addsock(struct svc_serv *serv, const int fd,
 					char *name_return, const size_t len);
 void		svc_init_xprt_sock(void);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 6bec1e2..032b52e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -259,8 +259,23 @@ static int one_sock_name(char *buf, struct svc_sock *svsk)
 	return len;
 }
 
-int
-svc_sock_names(char *buf, struct svc_serv *serv, char *toclose)
+/**
+ * svc_sock_names - construct a list of listener names in a string
+ * @serv: pointer to RPC service
+ * @buf: pointer to a buffer to fill in with socket names
+ * @buflen: size of the buffer to be filled
+ * @toclose: pointer to '\0'-terminated C string containing the name
+ *		of a listener to be closed
+ *
+ * Fills in @buf with a '\n'-separated list of names of listener
+ * sockets.  If @toclose is not NULL, the socket named by @toclose
+ * is closed, and is not included in the output list.
+ *
+ * Returns positive length of the socket name string, or a negative
+ * errno value on error.
+ */
+int svc_sock_names(struct svc_serv *serv, char *buf, const size_t buflen,
+		   const char *toclose)
 {
 	struct svc_sock *svsk, *closesk = NULL;
 	int len = 0;

