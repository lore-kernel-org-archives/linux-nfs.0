Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 187DBC4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:46:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D7BAB207E0
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:46:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MHWGKcSF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726614AbfDBXqV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:46:21 -0400
Received: from mail-pf1-f196.google.com ([209.85.210.196]:42181 "EHLO
        mail-pf1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725842AbfDBXqV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:46:21 -0400
Received: by mail-pf1-f196.google.com with SMTP id r15so7143382pfn.9
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:46:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=obHKsIcIA3cagcyeDtka1uSmBNSBbodnwe/IhXVMit4=;
        b=MHWGKcSFrjztyKurlHE6krB0ciQq3hmYBYIVWnOeMQZf1Rjm/SzV6phKuAXEM9Fk3e
         glOCAfMMIKj+uN8n53Vuu2ZK3cGkHTM2tUpfMKINOixJqtBXcp6vTTNyRyZgNMqZi38L
         +xjbIj+b9Bm83RN9MGXci9Zha5t2nqSx2Nv6SSuwnOVNtSwI0jTkYfnwRScrsy6/wgnf
         Qgd8XFb//BMGQAQiF+OXbMYrUY6bv6JeqDGNR9exIvCvIFH4DqRJDpqEyqCMX33Aw+fo
         mlii7NDTo96VbYbsGiykmGVulO/bu6ys1SomOX60Bzu6SS8DIjLTg4z84IwNQ+kM5Cl0
         k7pg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=obHKsIcIA3cagcyeDtka1uSmBNSBbodnwe/IhXVMit4=;
        b=gBCrTwuQzSzm7I6QDe+uKBtItO1pB1afq51vdabtb1du0KATVvrgzo5VKri8hnvqgz
         ZFCkI5pEH88VSclaBRoiAgqMB6qAMETLJvMMzyooe5Gp/iTcfDoqasGoeZA6UoxnVmjt
         sMiaX2mdSrCM1ljcdWGvh378Cak6Cohsojvs6kEgUWxO7YBPb9LYb7CjDu3Rnv9KCKsG
         UtTENNVhOyMT+AXdT5nzNnu1eWWtACwrO4Mb2pHAod3+oSN/sQMXMOQ/AOspp/+HGpC2
         p0C0ImyuCuWlSWqyjLVhXguWMOuc8mnO8KQ/fGk9kcPcznE3noruSZDt3DyFG9PNHM1k
         9LqQ==
X-Gm-Message-State: APjAAAVZkBm90BlG1Uws47PyGcS/WHYWBkbeGigy//jpT71MmmYi2VgK
        fJ0072I3RtWwh793VVE1T2eZ9kM=
X-Google-Smtp-Source: APXvYqzOxJ8Bm2O5wpH6iA+1+li0an9pVBHE2A4X2ssbJ1u7ArrxXJIT28gJer3gnUkbHBVSkeYE8g==
X-Received: by 2002:a65:5343:: with SMTP id w3mr50594939pgr.232.1554248779619;
        Tue, 02 Apr 2019 16:46:19 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id y12sm38011643pgq.64.2019.04.02.16.46.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:46:19 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] SUNRPC: Cache the process user cred in the RPC server listener
Date:   Tue,  2 Apr 2019 16:44:07 -0700
Message-Id: <20190402234411.28204-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190402234411.28204-1-trond.myklebust@hammerspace.com>
References: <20190402234411.28204-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In order to be able to interpret uids and gids correctly in knfsd, we
should cache the user namespace of the process that created the RPC
server's listener. To do so, we refcount the credential of that process.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/lockd/svc.c                  |  3 ++-
 fs/nfs/callback.c               |  7 +++++--
 fs/nfsd/nfsctl.c                | 16 ++++++++--------
 fs/nfsd/nfsd.h                  |  2 +-
 fs/nfsd/nfssvc.c                | 14 +++++++-------
 include/linux/sunrpc/svc_xprt.h |  4 +++-
 include/linux/sunrpc/svcsock.h  |  3 ++-
 net/sunrpc/svc_xprt.c           | 12 ++++++++----
 net/sunrpc/svcsock.c            |  4 +++-
 9 files changed, 39 insertions(+), 26 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 96bb74c919f9..82aa0f35e43d 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -190,12 +190,13 @@ static int create_lockd_listener(struct svc_serv *serv, const char *name,
 				 struct net *net, const int family,
 				 const unsigned short port)
 {
+	const struct cred *cred = current_cred();
 	struct svc_xprt *xprt;
 
 	xprt = svc_find_xprt(serv, name, net, family, 0);
 	if (xprt == NULL)
 		return svc_create_xprt(serv, name, net, family, port,
-						SVC_SOCK_DEFAULTS);
+						SVC_SOCK_DEFAULTS, cred);
 	svc_xprt_put(xprt);
 	return 0;
 }
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 15c9575e0e7a..7817ad94a6ba 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -41,11 +41,13 @@ static struct svc_program nfs4_callback_program;
 
 static int nfs4_callback_up_net(struct svc_serv *serv, struct net *net)
 {
+	const struct cred *cred = current_cred();
 	int ret;
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 
 	ret = svc_create_xprt(serv, "tcp", net, PF_INET,
-				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
+				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS,
+				cred);
 	if (ret <= 0)
 		goto out_err;
 	nn->nfs_callback_tcpport = ret;
@@ -53,7 +55,8 @@ static int nfs4_callback_up_net(struct svc_serv *serv, struct net *net)
 		nn->nfs_callback_tcpport, PF_INET, net->ns.inum);
 
 	ret = svc_create_xprt(serv, "tcp", net, PF_INET6,
-				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
+				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS,
+				cred);
 	if (ret > 0) {
 		nn->nfs_callback_tcpport6 = ret;
 		dprintk("NFS: Callback listener port = %u (af %u, net %x)\n",
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 2dc5a73cc464..4f9d9ea9ddfd 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -439,7 +439,7 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 			return rv;
 		if (newthreads < 0)
 			return -EINVAL;
-		rv = nfsd_svc(newthreads, net);
+		rv = nfsd_svc(newthreads, net, file->f_cred);
 		if (rv < 0)
 			return rv;
 	} else
@@ -717,7 +717,7 @@ static ssize_t __write_ports_names(char *buf, struct net *net)
  * a socket of a supported family/protocol, and we use it as an
  * nfsd listener.
  */
-static ssize_t __write_ports_addfd(char *buf, struct net *net)
+static ssize_t __write_ports_addfd(char *buf, struct net *net, const struct cred *cred)
 {
 	char *mesg = buf;
 	int fd, err;
@@ -736,7 +736,7 @@ static ssize_t __write_ports_addfd(char *buf, struct net *net)
 	if (err != 0)
 		return err;
 
-	err = svc_addsock(nn->nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT);
+	err = svc_addsock(nn->nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT, cred);
 	if (err < 0) {
 		nfsd_destroy(net);
 		return err;
@@ -751,7 +751,7 @@ static ssize_t __write_ports_addfd(char *buf, struct net *net)
  * A transport listener is added by writing it's transport name and
  * a port number.
  */
-static ssize_t __write_ports_addxprt(char *buf, struct net *net)
+static ssize_t __write_ports_addxprt(char *buf, struct net *net, const struct cred *cred)
 {
 	char transport[16];
 	struct svc_xprt *xprt;
@@ -769,12 +769,12 @@ static ssize_t __write_ports_addxprt(char *buf, struct net *net)
 		return err;
 
 	err = svc_create_xprt(nn->nfsd_serv, transport, net,
-				PF_INET, port, SVC_SOCK_ANONYMOUS);
+				PF_INET, port, SVC_SOCK_ANONYMOUS, cred);
 	if (err < 0)
 		goto out_err;
 
 	err = svc_create_xprt(nn->nfsd_serv, transport, net,
-				PF_INET6, port, SVC_SOCK_ANONYMOUS);
+				PF_INET6, port, SVC_SOCK_ANONYMOUS, cred);
 	if (err < 0 && err != -EAFNOSUPPORT)
 		goto out_close;
 
@@ -799,10 +799,10 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size,
 		return __write_ports_names(buf, net);
 
 	if (isdigit(buf[0]))
-		return __write_ports_addfd(buf, net);
+		return __write_ports_addfd(buf, net, file->f_cred);
 
 	if (isalpha(buf[0]))
-		return __write_ports_addxprt(buf, net);
+		return __write_ports_addxprt(buf, net, file->f_cred);
 
 	return -EINVAL;
 }
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 6bae2554b2b2..d200c8680259 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -73,7 +73,7 @@ extern const struct seq_operations nfs_exports_op;
 /*
  * Function prototypes.
  */
-int		nfsd_svc(int nrservs, struct net *net);
+int		nfsd_svc(int nrservs, struct net *net, const struct cred *cred);
 int		nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp);
 
 int		nfsd_nrthreads(struct net *);
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 16fd157e7651..c98d4e2bc619 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -289,7 +289,7 @@ int nfsd_nrthreads(struct net *net)
 	return rv;
 }
 
-static int nfsd_init_socks(struct net *net)
+static int nfsd_init_socks(struct net *net, const struct cred *cred)
 {
 	int error;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
@@ -298,12 +298,12 @@ static int nfsd_init_socks(struct net *net)
 		return 0;
 
 	error = svc_create_xprt(nn->nfsd_serv, "udp", net, PF_INET, NFS_PORT,
-					SVC_SOCK_DEFAULTS);
+					SVC_SOCK_DEFAULTS, cred);
 	if (error < 0)
 		return error;
 
 	error = svc_create_xprt(nn->nfsd_serv, "tcp", net, PF_INET, NFS_PORT,
-					SVC_SOCK_DEFAULTS);
+					SVC_SOCK_DEFAULTS, cred);
 	if (error < 0)
 		return error;
 
@@ -354,7 +354,7 @@ static bool nfsd_needs_lockd(struct nfsd_net *nn)
 	return nfsd_vers(nn, 2, NFSD_TEST) || nfsd_vers(nn, 3, NFSD_TEST);
 }
 
-static int nfsd_startup_net(int nrservs, struct net *net)
+static int nfsd_startup_net(int nrservs, struct net *net, const struct cred *cred)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	int ret;
@@ -365,7 +365,7 @@ static int nfsd_startup_net(int nrservs, struct net *net)
 	ret = nfsd_startup_generic(nrservs);
 	if (ret)
 		return ret;
-	ret = nfsd_init_socks(net);
+	ret = nfsd_init_socks(net, cred);
 	if (ret)
 		goto out_socks;
 
@@ -703,7 +703,7 @@ int nfsd_set_nrthreads(int n, int *nthreads, struct net *net)
  * this is the first time nrservs is nonzero.
  */
 int
-nfsd_svc(int nrservs, struct net *net)
+nfsd_svc(int nrservs, struct net *net, const struct cred *cred)
 {
 	int	error;
 	bool	nfsd_up_before;
@@ -725,7 +725,7 @@ nfsd_svc(int nrservs, struct net *net)
 
 	nfsd_up_before = nn->nfsd_net_up;
 
-	error = nfsd_startup_net(nrservs, net);
+	error = nfsd_startup_net(nrservs, net, cred);
 	if (error)
 		goto out_destroy;
 	error = nn->nfsd_serv->sv_ops->svo_setup(nn->nfsd_serv,
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index b3f9577e17d6..ea6f46be9cb7 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -86,6 +86,7 @@ struct svc_xprt {
 	struct list_head	xpt_users;	/* callbacks on free */
 
 	struct net		*xpt_net;
+	const struct cred	*xpt_cred;
 	struct rpc_xprt		*xpt_bc_xprt;	/* NFSv4.1 backchannel */
 	struct rpc_xprt_switch	*xpt_bc_xps;	/* NFSv4.1 backchannel */
 };
@@ -119,7 +120,8 @@ void	svc_unreg_xprt_class(struct svc_xprt_class *);
 void	svc_xprt_init(struct net *, struct svc_xprt_class *, struct svc_xprt *,
 		      struct svc_serv *);
 int	svc_create_xprt(struct svc_serv *, const char *, struct net *,
-			const int, const unsigned short, int);
+			const int, const unsigned short, int,
+			const struct cred *);
 void	svc_xprt_do_enqueue(struct svc_xprt *xprt);
 void	svc_xprt_enqueue(struct svc_xprt *xprt);
 void	svc_xprt_put(struct svc_xprt *xprt);
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 119718a922f2..771baadaee9d 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -59,7 +59,8 @@ void		svc_drop(struct svc_rqst *);
 void		svc_sock_update_bufs(struct svc_serv *serv);
 bool		svc_alien_sock(struct net *net, int fd);
 int		svc_addsock(struct svc_serv *serv, const int fd,
-					char *name_return, const size_t len);
+					char *name_return, const size_t len,
+					const struct cred *cred);
 void		svc_init_xprt_sock(void);
 void		svc_cleanup_xprt_sock(void);
 struct svc_xprt *svc_sock_create(struct svc_serv *serv, int prot);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 61530b1b7754..b76ee83d4d43 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -136,6 +136,7 @@ static void svc_xprt_free(struct kref *kref)
 	struct module *owner = xprt->xpt_class->xcl_owner;
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
 		svcauth_unix_info_release(xprt);
+	put_cred(xprt->xpt_cred);
 	put_net(xprt->xpt_net);
 	/* See comment on corresponding get in xs_setup_bc_tcp(): */
 	if (xprt->xpt_bc_xprt)
@@ -252,7 +253,8 @@ void svc_add_new_perm_xprt(struct svc_serv *serv, struct svc_xprt *new)
 
 static int _svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
 			    struct net *net, const int family,
-			    const unsigned short port, int flags)
+			    const unsigned short port, int flags,
+			    const struct cred *cred)
 {
 	struct svc_xprt_class *xcl;
 
@@ -273,6 +275,7 @@ static int _svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
 			module_put(xcl->xcl_owner);
 			return PTR_ERR(newxprt);
 		}
+		newxprt->xpt_cred = get_cred(cred);
 		svc_add_new_perm_xprt(serv, newxprt);
 		newport = svc_xprt_local_port(newxprt);
 		return newport;
@@ -286,15 +289,16 @@ static int _svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
 
 int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
 		    struct net *net, const int family,
-		    const unsigned short port, int flags)
+		    const unsigned short port, int flags,
+		    const struct cred *cred)
 {
 	int err;
 
 	dprintk("svc: creating transport %s[%d]\n", xprt_name, port);
-	err = _svc_create_xprt(serv, xprt_name, net, family, port, flags);
+	err = _svc_create_xprt(serv, xprt_name, net, family, port, flags, cred);
 	if (err == -EPROTONOSUPPORT) {
 		request_module("svc%s", xprt_name);
-		err = _svc_create_xprt(serv, xprt_name, net, family, port, flags);
+		err = _svc_create_xprt(serv, xprt_name, net, family, port, flags, cred);
 	}
 	if (err < 0)
 		dprintk("svc: transport %s not found, err %d\n",
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 43590a968b73..540fde2804d0 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1332,13 +1332,14 @@ EXPORT_SYMBOL_GPL(svc_alien_sock);
  * @fd: file descriptor of the new listener
  * @name_return: pointer to buffer to fill in with name of listener
  * @len: size of the buffer
+ * @cred: credential
  *
  * Fills in socket name and returns positive length of name if successful.
  * Name is terminated with '\n'.  On error, returns a negative errno
  * value.
  */
 int svc_addsock(struct svc_serv *serv, const int fd, char *name_return,
-		const size_t len)
+		const size_t len, const struct cred *cred)
 {
 	int err = 0;
 	struct socket *so = sockfd_lookup(fd, &err);
@@ -1371,6 +1372,7 @@ int svc_addsock(struct svc_serv *serv, const int fd, char *name_return,
 	salen = kernel_getsockname(svsk->sk_sock, sin);
 	if (salen >= 0)
 		svc_xprt_set_local(&svsk->sk_xprt, sin, salen);
+	svsk->sk_xprt.xpt_cred = get_cred(cred);
 	svc_add_new_perm_xprt(serv, &svsk->sk_xprt);
 	return svc_one_sock_name(svsk, name_return, len);
 out:
-- 
2.20.1

