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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02B68C10F00
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:46:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BE818207E0
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:46:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Z4FKqUGm"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726615AbfDBXqV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:46:21 -0400
Received: from mail-pf1-f194.google.com ([209.85.210.194]:45487 "EHLO
        mail-pf1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726582AbfDBXqV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:46:21 -0400
Received: by mail-pf1-f194.google.com with SMTP id e24so7145556pfi.12
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:46:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=8jPMJ22vWsSyNHhFdVSoAdLEOz8K5llBo4KfLDPQA2g=;
        b=Z4FKqUGmyjYC+6+rys9kUZ03bRy6WHbdK54g5h3tQdWTDUvSd5w32HxlWgdLTv0u3o
         E9JAGZPuqcP6kGnYfP5cKBg8+EvcmHUX9t10kFbBH7VUZJ8GdYdaUE2UlgkL3HUN1e3Q
         PCD24KI+YFM3BcRp5V7fgHMlOt2xieVHXZcjkwmFYTh8P0ZBrLVDp0PRcmoujduGAiyy
         i8XulmvFwlx6i/ALWh2BKL4y+odHWRMR2lIL1b+koPjklvURMiq0wGFu1K2MVVPQORLK
         ncU8OMVRrH4iXXOmmfxSSaOlF1NEaISPcEA6zef+imkWa9rvTVEKsF0Jks+1aNH0Yej7
         N9dA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=8jPMJ22vWsSyNHhFdVSoAdLEOz8K5llBo4KfLDPQA2g=;
        b=ufvgAHMJLmg+DYO8r+leafBM6io1hQa6We4eII+r64BpwqJnFeUkkUm18ptCtWpLDi
         Xgr3xzxEaKuP68kASIG2sdxqL/5zRG0FrHnzpAW0PCt0xptOHiOJ3n82s1Wge80IMQU+
         q1s7HTA/wDLygtMGLp1vzYVVsTCIOxCicFlzr9pI/aOI0pNL7HJ4XGyVT0E31bZBRWFI
         mqdSMy6jNNXgc9oEWECyBx1Q9glge/6E1+p955hova2vXp/V5twZIee91CE+S2Mn1nf9
         r6Q0FUoAdKoaPFFNd3UpmvEoJ9lGxzxP8zb0rxGuKzvu/clKFzxZa2pErDRMMoqc3Tl2
         3u1A==
X-Gm-Message-State: APjAAAWvc6uOUd6qoCAw44d6QgJ03rvLMNFqvytDlQEvEh8QNCqOv6Fp
        yX8nZ4oYZEBg/UDwY31JSv7ktq8=
X-Google-Smtp-Source: APXvYqyBTIsJhQt68PiDUC2ziLs9+sp6pjfNtucTPu6ZAT1O370z+2d87zDKV5nhYIKdlTmTKKEkbg==
X-Received: by 2002:a63:243:: with SMTP id 64mr31115522pgc.214.1554248780462;
        Tue, 02 Apr 2019 16:46:20 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id y12sm38011643pgq.64.2019.04.02.16.46.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:46:19 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] lockd: Pass the user cred from knfsd when starting the lockd server
Date:   Tue,  2 Apr 2019 16:44:08 -0700
Message-Id: <20190402234411.28204-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190402234411.28204-2-trond.myklebust@hammerspace.com>
References: <20190402234411.28204-1-trond.myklebust@hammerspace.com>
 <20190402234411.28204-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When starting up a new knfsd server, pass the user cred to the
supporting lockd server.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/lockd/clntlock.c        |  4 ++--
 fs/lockd/svc.c             | 28 ++++++++++++++++------------
 fs/nfs/client.c            |  1 +
 fs/nfsd/nfssvc.c           |  2 +-
 include/linux/lockd/bind.h |  3 ++-
 5 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index c2a128678e6e..d61b72b693cf 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -56,7 +56,7 @@ struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
 	u32 nlm_version = (nlm_init->nfs_version == 2) ? 1 : 4;
 	int status;
 
-	status = lockd_up(nlm_init->net);
+	status = lockd_up(nlm_init->net, nlm_init->cred);
 	if (status < 0)
 		return ERR_PTR(status);
 
@@ -241,7 +241,7 @@ reclaimer(void *ptr)
 	allow_signal(SIGKILL);
 
 	down_write(&host->h_rwsem);
-	lockd_up(net);	/* note: this cannot fail as lockd is already running */
+	lockd_up(net, NULL);	/* note: this cannot fail as lockd is already running */
 
 	dprintk("lockd: reclaiming locks for host %s\n", host->h_name);
 
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 82aa0f35e43d..3056f3a0c270 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -188,9 +188,9 @@ lockd(void *vrqstp)
 
 static int create_lockd_listener(struct svc_serv *serv, const char *name,
 				 struct net *net, const int family,
-				 const unsigned short port)
+				 const unsigned short port,
+				 const struct cred *cred)
 {
-	const struct cred *cred = current_cred();
 	struct svc_xprt *xprt;
 
 	xprt = svc_find_xprt(serv, name, net, family, 0);
@@ -202,15 +202,17 @@ static int create_lockd_listener(struct svc_serv *serv, const char *name,
 }
 
 static int create_lockd_family(struct svc_serv *serv, struct net *net,
-			       const int family)
+			       const int family, const struct cred *cred)
 {
 	int err;
 
-	err = create_lockd_listener(serv, "udp", net, family, nlm_udpport);
+	err = create_lockd_listener(serv, "udp", net, family, nlm_udpport,
+			cred);
 	if (err < 0)
 		return err;
 
-	return create_lockd_listener(serv, "tcp", net, family, nlm_tcpport);
+	return create_lockd_listener(serv, "tcp", net, family, nlm_tcpport,
+			cred);
 }
 
 /*
@@ -223,16 +225,17 @@ static int create_lockd_family(struct svc_serv *serv, struct net *net,
  * Returns zero if all listeners are available; otherwise a
  * negative errno value is returned.
  */
-static int make_socks(struct svc_serv *serv, struct net *net)
+static int make_socks(struct svc_serv *serv, struct net *net,
+		const struct cred *cred)
 {
 	static int warned;
 	int err;
 
-	err = create_lockd_family(serv, net, PF_INET);
+	err = create_lockd_family(serv, net, PF_INET, cred);
 	if (err < 0)
 		goto out_err;
 
-	err = create_lockd_family(serv, net, PF_INET6);
+	err = create_lockd_family(serv, net, PF_INET6, cred);
 	if (err < 0 && err != -EAFNOSUPPORT)
 		goto out_err;
 
@@ -247,7 +250,8 @@ static int make_socks(struct svc_serv *serv, struct net *net)
 	return err;
 }
 
-static int lockd_up_net(struct svc_serv *serv, struct net *net)
+static int lockd_up_net(struct svc_serv *serv, struct net *net,
+		const struct cred *cred)
 {
 	struct lockd_net *ln = net_generic(net, lockd_net_id);
 	int error;
@@ -259,7 +263,7 @@ static int lockd_up_net(struct svc_serv *serv, struct net *net)
 	if (error)
 		goto err_bind;
 
-	error = make_socks(serv, net);
+	error = make_socks(serv, net, cred);
 	if (error < 0)
 		goto err_bind;
 	set_grace_period(net);
@@ -462,7 +466,7 @@ static struct svc_serv *lockd_create_svc(void)
 /*
  * Bring up the lockd process if it's not already up.
  */
-int lockd_up(struct net *net)
+int lockd_up(struct net *net, const struct cred *cred)
 {
 	struct svc_serv *serv;
 	int error;
@@ -475,7 +479,7 @@ int lockd_up(struct net *net)
 		goto err_create;
 	}
 
-	error = lockd_up_net(serv, net);
+	error = lockd_up_net(serv, net, cred);
 	if (error < 0) {
 		lockd_unregister_notifiers();
 		goto err_put;
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 90d71fda65ce..92d07d99829d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -552,6 +552,7 @@ static int nfs_start_lockd(struct nfs_server *server)
 					1 : 0,
 		.net		= clp->cl_net,
 		.nlmclnt_ops 	= clp->cl_nfs_mod->rpc_ops->nlmclnt_ops,
+		.cred		= current_cred(),
 	};
 
 	if (nlm_init.nfs_version > 3)
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index c98d4e2bc619..2a05dfe7c111 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -370,7 +370,7 @@ static int nfsd_startup_net(int nrservs, struct net *net, const struct cred *cre
 		goto out_socks;
 
 	if (nfsd_needs_lockd(nn) && !nn->lockd_up) {
-		ret = lockd_up(net);
+		ret = lockd_up(net, cred);
 		if (ret)
 			goto out_socks;
 		nn->lockd_up = 1;
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 053a4ef3d431..0520c0cd73f4 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -46,6 +46,7 @@ struct nlmclnt_initdata {
 	int			noresvport;
 	struct net		*net;
 	const struct nlmclnt_operations	*nlmclnt_ops;
+	const struct cred	*cred;
 };
 
 /*
@@ -75,7 +76,7 @@ struct nlmclnt_operations {
 };
 
 extern int	nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl, void *data);
-extern int	lockd_up(struct net *net);
+extern int	lockd_up(struct net *net, const struct cred *cred);
 extern void	lockd_down(struct net *net);
 
 #endif /* LINUX_LOCKD_BIND_H */
-- 
2.20.1

