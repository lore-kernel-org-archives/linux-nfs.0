Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12006 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753013Ab1AEUvx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 15:51:53 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V8 04/13] SUNRPC register and unregister the back channel transport
Date: Wed,  5 Jan 2011 15:51:22 -0500
Message-Id: <1294260690-3095-5-git-send-email-andros@netapp.com>
In-Reply-To: <1294260690-3095-4-git-send-email-andros@netapp.com>
References: <1294260690-3095-1-git-send-email-andros@netapp.com>
 <1294260690-3095-2-git-send-email-andros@netapp.com>
 <1294260690-3095-3-git-send-email-andros@netapp.com>
 <1294260690-3095-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/svcsock.h |    1 -
 net/sunrpc/svcsock.c           |   20 ++++++++++++++++++++
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 3a45a80..1b353a7 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -45,7 +45,6 @@ int		svc_sock_names(struct svc_serv *serv, char *buf,
 int		svc_addsock(struct svc_serv *serv, const int fd,
 					char *name_return, const size_t len);
 void		svc_init_xprt_sock(void);
-void		svc_init_bc_xprt_sock(void);
 void		svc_cleanup_xprt_sock(void);
 struct svc_xprt *svc_sock_create(struct svc_serv *serv, int prot);
 void		svc_sock_destroy(struct svc_xprt *);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 6630f29..e6b66d8 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1222,6 +1222,24 @@ static struct svc_xprt_class svc_tcp_bc_class = {
 	.xcl_ops = &svc_tcp_bc_ops,
 	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 };
+
+static void svc_init_bc_xprt_sock(void)
+{
+	svc_reg_xprt_class(&svc_tcp_bc_class);
+}
+
+static void svc_cleanup_bc_xprt_sock(void)
+{
+	svc_unreg_xprt_class(&svc_tcp_bc_class);
+}
+#else /* CONFIG_NFS_V4_1 */
+static void svc_init_bc_xprt_sock(void)
+{
+}
+
+static void svc_cleanup_bc_xprt_sock(void)
+{
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 static struct svc_xprt_ops svc_tcp_ops = {
@@ -1247,12 +1265,14 @@ void svc_init_xprt_sock(void)
 {
 	svc_reg_xprt_class(&svc_tcp_class);
 	svc_reg_xprt_class(&svc_udp_class);
+	svc_init_bc_xprt_sock();
 }
 
 void svc_cleanup_xprt_sock(void)
 {
 	svc_unreg_xprt_class(&svc_tcp_class);
 	svc_unreg_xprt_class(&svc_udp_class);
+	svc_cleanup_bc_xprt_sock();
 }
 
 static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
-- 
1.6.6

