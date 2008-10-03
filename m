From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] NLM: Remove unused argument from svc_addsock() function
Date: Fri, 03 Oct 2008 17:15:38 -0400
Message-ID: <20081003211538.9870.88307.stgit@ingres.1015granger.net>
References: <20081003211305.9870.6835.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:27775 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbYJCVQE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:16:04 -0400
In-Reply-To: <20081003211305.9870.6835.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The svc_addsock() function no longer uses its "proto"
argument, so remove it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Neil Brown <neilb@suse.de>
---

 fs/nfsd/nfsctl.c               |    2 +-
 include/linux/sunrpc/svcsock.h |    5 +----
 net/sunrpc/svcsock.c           |    4 +---
 3 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 862dff5..97543df 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -614,7 +614,7 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 			return -EINVAL;
 		err = nfsd_create_serv();
 		if (!err) {
-			err = svc_addsock(nfsd_serv, fd, buf, NULL);
+			err = svc_addsock(nfsd_serv, fd, buf);
 			if (err >= 0) {
 				err = lockd_up();
 				if (err < 0)
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 8cff696..483e103 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -39,10 +39,7 @@ int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);
 void		svc_sock_update_bufs(struct svc_serv *serv);
 int		svc_sock_names(char *buf, struct svc_serv *serv, char *toclose);
-int		svc_addsock(struct svc_serv *serv,
-			    int fd,
-			    char *name_return,
-			    int *proto);
+int		svc_addsock(struct svc_serv *serv, int fd, char *name_return);
 void		svc_init_xprt_sock(void);
 void		svc_cleanup_xprt_sock(void);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index f91377c..95293f5 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1167,8 +1167,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 
 int svc_addsock(struct svc_serv *serv,
 		int fd,
-		char *name_return,
-		int *proto)
+		char *name_return)
 {
 	int err = 0;
 	struct socket *so = sockfd_lookup(fd, &err);
@@ -1203,7 +1202,6 @@ int svc_addsock(struct svc_serv *serv,
 		sockfd_put(so);
 		return err;
 	}
-	if (proto) *proto = so->sk->sk_protocol;
 	return one_sock_name(name_return, svsk);
 }
 EXPORT_SYMBOL_GPL(svc_addsock);

