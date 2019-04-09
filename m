Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBA12C282CE
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 16:15:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9F77A21473
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 16:15:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NKBaJwm5"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726570AbfDIQPz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 12:15:55 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:42948 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726515AbfDIQPy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 12:15:54 -0400
Received: by mail-io1-f65.google.com with SMTP id c4so14786337ioh.9
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 09:15:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ivpBSLoDOFOrgVV/dJW5L/pN3weHFcG8YFXsm5dSNqk=;
        b=NKBaJwm5FNTJTFb6wGmvGuoDIfCXbXxFIRXrv17gIeKWXtxeKSsLGkLWp8gZiE14qC
         WHMQ7n345e3w/v6P17At4cgzYk6Xd7OR8b/w69KnqRSbYIT4CzYfeLuC4JJ+facUrKuY
         CtdmAIuRVCfFCTq/jlgSE9Lx+S57IwHyk/n7DzANbxv+Fk+Y/GcdCFWXAihhbk8zS1YN
         J4lDStuXRMRQrP8ra0WyoA8L+SiJmiPpC7efkDjXphVIRPtOwE/5LgpKra2JWDl6e9m/
         y48yX/1V8bTujUgpF+IM5B/FGYI+3yr4zF0YBWE1sbK/B1dJSk7Q6Lu0+Nt+gcsnij3f
         3U4A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ivpBSLoDOFOrgVV/dJW5L/pN3weHFcG8YFXsm5dSNqk=;
        b=miS0Pxgh+j86N288+1nL0BDnjm6gUJLRS3byKUqaJiW5PvYc96O8Bi25bzSCBlV191
         kQMZjZ1vyBZDy/frPswTeLJWhaTeBj+hMrHaTHcmCRblLyqDR877hhBipLOx7LhUlP6J
         NL2IdKCZBEh1HX9d1ZLnibQEtHhPSjm+IUgHZa9ruARnl5p5M1Y7o0FiwKNv0LV4JaDv
         smZ7o5jcQZLCIkYL4PaRlknJ7IiBBU2A9obiRGWvM4g/FFIH3n1RgDnR4t1YhikSBQkp
         OSsq/zemHaT96AgE0ZI8OSARDH7NpqfaOFXdKkQ4RI1MfiYE1HI+bCvl9C5srDbOvlQG
         xT9Q==
X-Gm-Message-State: APjAAAUvm6bvjYu5CqcPqSsx6XPjhsekF++I1a416FhKAvq+QToVxU4R
        /jxeqEdcbfAjh+cYy4+Ok84g+/k=
X-Google-Smtp-Source: APXvYqyonPInRxbAMGQl2hwLQwS/48+nL2yvk8JmSyXJ1spifByiYwVKYRs1Boi9uh0ZxldkZOgtnw==
X-Received: by 2002:a5d:85d5:: with SMTP id e21mr2348037ios.27.1554826553335;
        Tue, 09 Apr 2019 09:15:53 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id d133sm7402425ita.5.2019.04.09.09.15.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 09:15:52 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/6] lockd: Pass the user cred from knfsd when starting the lockd server
Date:   Tue,  9 Apr 2019 12:13:39 -0400
Message-Id: <20190409161342.34338-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409161342.34338-3-trond.myklebust@hammerspace.com>
References: <20190409161342.34338-1-trond.myklebust@hammerspace.com>
 <20190409161342.34338-2-trond.myklebust@hammerspace.com>
 <20190409161342.34338-3-trond.myklebust@hammerspace.com>
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
index 32e4d8a334e3..18d94ea984ba 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -364,7 +364,7 @@ static int nfsd_startup_net(int nrservs, struct net *net, const struct cred *cre
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

