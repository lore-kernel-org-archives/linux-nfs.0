From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/23] SUNRPC: pass buffer size to svc_addsock()
Date: Thu, 05 Mar 2009 16:32:53 -0500
Message-ID: <20090305213253.21342.19445.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:35860 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754153AbZCEVdK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:33:10 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index b0f7300..917578f 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -912,7 +912,7 @@ static ssize_t __write_ports_addfd(char *buf)
 	if (err != 0)
 		goto out;
 
-	err = svc_addsock(nfsd_serv, fd, buf);
+	err = svc_addsock(nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT);
 	if (err != 0)
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
index ac6cd65..61ca2dd 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1159,9 +1159,19 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
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

