From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/19] SUNRPC: pass buffer size to svc_addsock()
Date: Thu, 23 Apr 2009 19:32:33 -0400
Message-ID: <20090423233232.17283.65955.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:46574 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755606AbZDWXed (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:34:33 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adjust the synopsis of svc_addsock() to pass in the size of the output
buffer.  Add a documenting comment.

This is a cosmetic change for now.  A subsequent patch will make sure
the buffer length is passed to one_sock_name(), where the length will
actually be useful.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c               |    2 +-
 include/linux/sunrpc/svcsock.h |    3 ++-
 net/sunrpc/svcsock.c           |   16 +++++++++++++---
 3 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6a1cd90..1f1c215 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -943,7 +943,7 @@ static ssize_t __write_ports_addfd(char *buf)
 	if (err != 0)
 		goto out;
 
-	err = svc_addsock(nfsd_serv, fd, buf);
+	err = svc_addsock(nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT);
 	if (err < 0)
 		lockd_down();
 
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 483e103..e23241c 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -39,7 +39,8 @@ int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);
 void		svc_sock_update_bufs(struct svc_serv *serv);
 int		svc_sock_names(char *buf, struct svc_serv *serv, char *toclose);
-int		svc_addsock(struct svc_serv *serv, int fd, char *name_return);
+int		svc_addsock(struct svc_serv *serv, const int fd,
+					char *name_return, const size_t len);
 void		svc_init_xprt_sock(void);
 void		svc_cleanup_xprt_sock(void);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8b08328..6bec1e2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1128,9 +1128,19 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	return svsk;
 }
 
-int svc_addsock(struct svc_serv *serv,
-		int fd,
-		char *name_return)
+/**
+ * svc_addsock - add a listener socket to an RPC service
+ * @serv: pointer to RPC service to which to add a new listener
+ * @fd: file descriptor of the new listener
+ * @name_return: pointer to buffer to fill in with name of listener
+ * @len: size of the buffer
+ *
+ * Fills in socket name and returns positive length of name if successful.
+ * Name is terminated with '\n'.  On error, returns a negative errno
+ * value.
+ */
+int svc_addsock(struct svc_serv *serv, const int fd, char *name_return,
+		const size_t len)
 {
 	int err = 0;
 	struct socket *so = sockfd_lookup(fd, &err);

