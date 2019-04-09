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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 364A5C282CE
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 15:48:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E644B2084C
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 15:48:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W/qBWWRt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726372AbfDIPsg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 11:48:36 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:38842 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726574AbfDIPsg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 11:48:36 -0400
Received: by mail-io1-f67.google.com with SMTP id v4so14719783ioj.5
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 08:48:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=wWWxJ4jWGaHAKtexcT8s1pSLYiP0Ars2VNF767X0/tY=;
        b=W/qBWWRtwrr2SgKstdeL+Kc9FRzOr43fjnFVf/AKszEL1rZO70twu29Id2Oju0KWe+
         XEmgYO3BDyyTe/3WLSlz9vEnRmU2IFsDeRyLD5d48NF8yD6ydkiHc/z7dAWYxNpUbcfZ
         /sRHgdqCibiFW1g+nu3NHoaN8V6GrQgjo5pZ0h284z45KFdNb/5OFtBumyOlGw167gNK
         Ui7lG83hZTlo3xRngBufHcXOjvl65oLcKFpDIXdvrBnOeMP+XFzpu20r+82kl3SjzPVz
         PHIeWjhCsG1Uhc3+gOlCDrAquYhIIUkBMvV8e1a3yCKrOK0J2WXCD8dHy6QXIM7VJnOQ
         6uiQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=wWWxJ4jWGaHAKtexcT8s1pSLYiP0Ars2VNF767X0/tY=;
        b=mSo54NpkhdqQbtXcpjgd1uEDeCKD7zSQ9DS7ADlH1uQZg3IoH0Rla0kWKBW8Wd1XU4
         ztRf0LY4ZBJw+dECerZzm+9M0BASnhzAfP1SAgK33dwZzyncFXc3/yYGK62UaPQ3oklL
         x6//DhFqphuQ96mbSKO+gpTB7exkuYpTzA+3niX2BBHR6wVv7sTx+NfFCINh0k8zRULh
         gld9Xg0yHpXr8xwHOpbpIQsyr8dyKqqgSaRvSKhKnFsROIcjs0/uwdnZ4YzAAbTilnf/
         M4+3IlWxxuK9G5kjYViBElhE3UVqI8bkhXzrfOrX3/3yS9A/CSAzZn3Y+xGz/aE4ndgb
         8yHQ==
X-Gm-Message-State: APjAAAWqUeV29XvQEjgvsrPd3Vkm6I+BwtVTV+5j/k6R6Vk8hiGS6oDc
        DvRBjU5orh7F9gynyksKEQ==
X-Google-Smtp-Source: APXvYqwuQBjtnEsprjCZQ4yqENLLgsmCup3cjDqTijHNgg7H8Psp9dUc4gOyz0JPijBzJO1x4EI7Cg==
X-Received: by 2002:a6b:fd0b:: with SMTP id c11mr24572288ioi.4.1554824914624;
        Tue, 09 Apr 2019 08:48:34 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id 62sm7026910itx.41.2019.04.09.08.48.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 08:48:33 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 6/6] nfsd: Allow containers to set supported nfs versions
Date:   Tue,  9 Apr 2019 11:46:19 -0400
Message-Id: <20190409154619.33615-7-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409154619.33615-6-trond.myklebust@hammerspace.com>
References: <20190409154619.33615-1-trond.myklebust@hammerspace.com>
 <20190409154619.33615-2-trond.myklebust@hammerspace.com>
 <20190409154619.33615-3-trond.myklebust@hammerspace.com>
 <20190409154619.33615-4-trond.myklebust@hammerspace.com>
 <20190409154619.33615-5-trond.myklebust@hammerspace.com>
 <20190409154619.33615-6-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Support use of the --nfs-version/--no-nfs-version arguments to rpc.nfsd
in containers.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/netns.h    |   8 ++
 fs/nfsd/nfs4proc.c |   3 +-
 fs/nfsd/nfsctl.c   |  25 +++---
 fs/nfsd/nfsd.h     |   8 +-
 fs/nfsd/nfssvc.c   | 214 +++++++++++++++++++++++++++++++++++----------
 5 files changed, 197 insertions(+), 61 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 32cb8c027483..68c0162751eb 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -131,10 +131,18 @@ struct nfsd_net {
 	u32		s2s_cp_cl_id;
 	struct idr	s2s_cp_stateids;
 	spinlock_t	s2s_cp_lock;
+
+	/*
+	 * Version information
+	 */
+	bool *nfsd_versions;
+	bool *nfsd4_minorversions;
 };
 
 /* Simple check to find out if a given net was properly initialized */
 #define nfsd_netns_ready(nn) ((nn)->sessionid_hashtbl)
 
+extern void nfsd_netns_free_versions(struct nfsd_net *nn);
+
 extern unsigned int nfsd_net_id;
 #endif /* __NFSD_NETNS_H__ */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0cfd257ffdaf..b0ad72d701b1 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1926,6 +1926,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 	struct nfsd4_compound_state *cstate = &resp->cstate;
 	struct svc_fh *current_fh = &cstate->current_fh;
 	struct svc_fh *save_fh = &cstate->save_fh;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 	__be32		status;
 
 	svcxdr_init_encode(rqstp, resp);
@@ -1948,7 +1949,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 	 * According to RFC3010, this takes precedence over all other errors.
 	 */
 	status = nfserr_minor_vers_mismatch;
-	if (nfsd_minorversion(args->minorversion, NFSD_TEST) <= 0)
+	if (nfsd_minorversion(nn, args->minorversion, NFSD_TEST) <= 0)
 		goto out;
 	status = nfserr_resource;
 	if (args->opcnt > NFSD_MAX_OPS_PER_COMPOUND)
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f2feb2d11bae..2dc5a73cc464 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -537,14 +537,14 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 }
 
 static ssize_t
-nfsd_print_version_support(char *buf, int remaining, const char *sep,
-		unsigned vers, int minor)
+nfsd_print_version_support(struct nfsd_net *nn, char *buf, int remaining,
+		const char *sep, unsigned vers, int minor)
 {
 	const char *format = minor < 0 ? "%s%c%u" : "%s%c%u.%u";
-	bool supported = !!nfsd_vers(vers, NFSD_TEST);
+	bool supported = !!nfsd_vers(nn, vers, NFSD_TEST);
 
 	if (vers == 4 && minor >= 0 &&
-	    !nfsd_minorversion(minor, NFSD_TEST))
+	    !nfsd_minorversion(nn, minor, NFSD_TEST))
 		supported = false;
 	if (minor == 0 && supported)
 		/*
@@ -599,20 +599,20 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 			switch(num) {
 			case 2:
 			case 3:
-				nfsd_vers(num, cmd);
+				nfsd_vers(nn, num, cmd);
 				break;
 			case 4:
 				if (*minorp == '.') {
-					if (nfsd_minorversion(minor, cmd) < 0)
+					if (nfsd_minorversion(nn, minor, cmd) < 0)
 						return -EINVAL;
-				} else if ((cmd == NFSD_SET) != nfsd_vers(num, NFSD_TEST)) {
+				} else if ((cmd == NFSD_SET) != nfsd_vers(nn, num, NFSD_TEST)) {
 					/*
 					 * Either we have +4 and no minors are enabled,
 					 * or we have -4 and at least one minor is enabled.
 					 * In either case, propagate 'cmd' to all minors.
 					 */
 					minor = 0;
-					while (nfsd_minorversion(minor, cmd) >= 0)
+					while (nfsd_minorversion(nn, minor, cmd) >= 0)
 						minor++;
 				}
 				break;
@@ -624,7 +624,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 		/* If all get turned off, turn them back on, as
 		 * having no versions is BAD
 		 */
-		nfsd_reset_versions();
+		nfsd_reset_versions(nn);
 	}
 
 	/* Now write current state into reply buffer */
@@ -633,12 +633,12 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 	remaining = SIMPLE_TRANSACTION_LIMIT;
 	for (num=2 ; num <= 4 ; num++) {
 		int minor;
-		if (!nfsd_vers(num, NFSD_AVAIL))
+		if (!nfsd_vers(nn, num, NFSD_AVAIL))
 			continue;
 
 		minor = -1;
 		do {
-			len = nfsd_print_version_support(buf, remaining,
+			len = nfsd_print_version_support(nn, buf, remaining,
 					sep, num, minor);
 			if (len >= remaining)
 				goto out;
@@ -1239,6 +1239,8 @@ static __net_init int nfsd_init_net(struct net *net)
 	retval = nfsd_idmap_init(net);
 	if (retval)
 		goto out_idmap_error;
+	nn->nfsd_versions = NULL;
+	nn->nfsd4_minorversions = NULL;
 	nn->nfsd4_lease = 90;	/* default lease time */
 	nn->nfsd4_grace = 90;
 	nn->somebody_reclaimed = false;
@@ -1260,6 +1262,7 @@ static __net_exit void nfsd_exit_net(struct net *net)
 {
 	nfsd_idmap_shutdown(net);
 	nfsd_export_shutdown(net);
+	nfsd_netns_free_versions(net_generic(net, nfsd_net_id));
 }
 
 static struct pernet_operations nfsd_net_ops = {
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 066899929863..6bae2554b2b2 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -98,10 +98,12 @@ extern const struct svc_version nfsd_acl_version3;
 #endif
 #endif
 
+struct nfsd_net;
+
 enum vers_op {NFSD_SET, NFSD_CLEAR, NFSD_TEST, NFSD_AVAIL };
-int nfsd_vers(int vers, enum vers_op change);
-int nfsd_minorversion(u32 minorversion, enum vers_op change);
-void nfsd_reset_versions(void);
+int nfsd_vers(struct nfsd_net *nn, int vers, enum vers_op change);
+int nfsd_minorversion(struct nfsd_net *nn, u32 minorversion, enum vers_op change);
+void nfsd_reset_versions(struct nfsd_net *nn);
 int nfsd_create_serv(struct net *net);
 
 extern int nfsd_max_blksize;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 378edcfe9701..520757774614 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -38,12 +38,18 @@ static int			nfsd_acl_rpcbind_set(struct net *,
 						     u32, int,
 						     unsigned short,
 						     unsigned short);
+static __be32			nfsd_acl_init_request(struct svc_rqst *,
+						const struct svc_program *,
+						struct svc_process_info *);
 #endif
 static int			nfsd_rpcbind_set(struct net *,
 						 const struct svc_program *,
 						 u32, int,
 						 unsigned short,
 						 unsigned short);
+static __be32			nfsd_init_request(struct svc_rqst *,
+						const struct svc_program *,
+						struct svc_process_info *);
 
 /*
  * nfsd_mutex protects nn->nfsd_serv -- both the pointer itself and the members
@@ -98,7 +104,7 @@ static struct svc_program	nfsd_acl_program = {
 	.pg_class		= "nfsd",
 	.pg_stats		= &nfsd_acl_svcstats,
 	.pg_authenticate	= &svc_set_client,
-	.pg_init_request	= svc_generic_init_request,
+	.pg_init_request	= nfsd_acl_init_request,
 	.pg_rpcbind_set		= nfsd_acl_rpcbind_set,
 };
 
@@ -119,7 +125,6 @@ static const struct svc_version *nfsd_version[] = {
 
 #define NFSD_MINVERS    	2
 #define NFSD_NRVERS		ARRAY_SIZE(nfsd_version)
-static const struct svc_version *nfsd_versions[NFSD_NRVERS];
 
 struct svc_program		nfsd_program = {
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
@@ -127,78 +132,136 @@ struct svc_program		nfsd_program = {
 #endif
 	.pg_prog		= NFS_PROGRAM,		/* program number */
 	.pg_nvers		= NFSD_NRVERS,		/* nr of entries in nfsd_version */
-	.pg_vers		= nfsd_versions,	/* version table */
+	.pg_vers		= nfsd_version,		/* version table */
 	.pg_name		= "nfsd",		/* program name */
 	.pg_class		= "nfsd",		/* authentication class */
 	.pg_stats		= &nfsd_svcstats,	/* version table */
 	.pg_authenticate	= &svc_set_client,	/* export authentication */
-	.pg_init_request	= svc_generic_init_request,
+	.pg_init_request	= nfsd_init_request,
 	.pg_rpcbind_set		= nfsd_rpcbind_set,
 };
 
-static bool nfsd_supported_minorversions[NFSD_SUPPORTED_MINOR_VERSION + 1] = {
-	[0] = 1,
-	[1] = 1,
-	[2] = 1,
-};
+static bool
+nfsd_support_version(int vers)
+{
+	if (vers >= NFSD_MINVERS && vers < NFSD_NRVERS)
+		return nfsd_version[vers] != NULL;
+	return false;
+}
+
+static bool *
+nfsd_alloc_versions(void)
+{
+	bool *vers = kmalloc_array(NFSD_NRVERS, sizeof(bool), GFP_KERNEL);
+	unsigned i;
+
+	if (vers) {
+		/* All compiled versions are enabled by default */
+		for (i = 0; i < NFSD_NRVERS; i++)
+			vers[i] = nfsd_support_version(i);
+	}
+	return vers;
+}
+
+static bool *
+nfsd_alloc_minorversions(void)
+{
+	bool *vers = kmalloc_array(NFSD_SUPPORTED_MINOR_VERSION + 1,
+			sizeof(bool), GFP_KERNEL);
+	unsigned i;
 
-int nfsd_vers(int vers, enum vers_op change)
+	if (vers) {
+		/* All minor versions are enabled by default */
+		for (i = 0; i <= NFSD_SUPPORTED_MINOR_VERSION; i++)
+			vers[i] = nfsd_support_version(4);
+	}
+	return vers;
+}
+
+void
+nfsd_netns_free_versions(struct nfsd_net *nn)
+{
+	kfree(nn->nfsd_versions);
+	kfree(nn->nfsd4_minorversions);
+	nn->nfsd_versions = NULL;
+	nn->nfsd4_minorversions = NULL;
+}
+
+static void
+nfsd_netns_init_versions(struct nfsd_net *nn)
+{
+	if (!nn->nfsd_versions) {
+		nn->nfsd_versions = nfsd_alloc_versions();
+		nn->nfsd4_minorversions = nfsd_alloc_minorversions();
+		if (!nn->nfsd_versions || !nn->nfsd4_minorversions)
+			nfsd_netns_free_versions(nn);
+	}
+}
+
+int nfsd_vers(struct nfsd_net *nn, int vers, enum vers_op change)
 {
 	if (vers < NFSD_MINVERS || vers >= NFSD_NRVERS)
 		return 0;
 	switch(change) {
 	case NFSD_SET:
-		nfsd_versions[vers] = nfsd_version[vers];
-#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
-		if (vers < NFSD_ACL_NRVERS)
-			nfsd_acl_versions[vers] = nfsd_acl_version[vers];
-#endif
+		if (nn->nfsd_versions)
+			nn->nfsd_versions[vers] = nfsd_support_version(vers);
 		break;
 	case NFSD_CLEAR:
-		nfsd_versions[vers] = NULL;
-#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
-		if (vers < NFSD_ACL_NRVERS)
-			nfsd_acl_versions[vers] = NULL;
-#endif
+		nfsd_netns_init_versions(nn);
+		if (nn->nfsd_versions)
+			nn->nfsd_versions[vers] = false;
 		break;
 	case NFSD_TEST:
-		return nfsd_versions[vers] != NULL;
+		if (nn->nfsd_versions)
+			return nn->nfsd_versions[vers];
+		/* Fallthrough */
 	case NFSD_AVAIL:
-		return nfsd_version[vers] != NULL;
+		return nfsd_support_version(vers);
 	}
 	return 0;
 }
 
 static void
-nfsd_adjust_nfsd_versions4(void)
+nfsd_adjust_nfsd_versions4(struct nfsd_net *nn)
 {
 	unsigned i;
 
 	for (i = 0; i <= NFSD_SUPPORTED_MINOR_VERSION; i++) {
-		if (nfsd_supported_minorversions[i])
+		if (nn->nfsd4_minorversions[i])
 			return;
 	}
-	nfsd_vers(4, NFSD_CLEAR);
+	nfsd_vers(nn, 4, NFSD_CLEAR);
 }
 
-int nfsd_minorversion(u32 minorversion, enum vers_op change)
+int nfsd_minorversion(struct nfsd_net *nn, u32 minorversion, enum vers_op change)
 {
 	if (minorversion > NFSD_SUPPORTED_MINOR_VERSION &&
 	    change != NFSD_AVAIL)
 		return -1;
+
 	switch(change) {
 	case NFSD_SET:
-		nfsd_supported_minorversions[minorversion] = true;
-		nfsd_vers(4, NFSD_SET);
+		if (nn->nfsd4_minorversions) {
+			nfsd_vers(nn, 4, NFSD_SET);
+			nn->nfsd4_minorversions[minorversion] =
+				nfsd_vers(nn, 4, NFSD_TEST);
+		}
 		break;
 	case NFSD_CLEAR:
-		nfsd_supported_minorversions[minorversion] = false;
-		nfsd_adjust_nfsd_versions4();
+		nfsd_netns_init_versions(nn);
+		if (nn->nfsd4_minorversions) {
+			nn->nfsd4_minorversions[minorversion] = false;
+			nfsd_adjust_nfsd_versions4(nn);
+		}
 		break;
 	case NFSD_TEST:
-		return nfsd_supported_minorversions[minorversion];
+		if (nn->nfsd4_minorversions)
+			return nn->nfsd4_minorversions[minorversion];
+		return nfsd_vers(nn, 4, NFSD_TEST);
 	case NFSD_AVAIL:
-		return minorversion <= NFSD_SUPPORTED_MINOR_VERSION;
+		return minorversion <= NFSD_SUPPORTED_MINOR_VERSION &&
+			nfsd_vers(nn, 4, NFSD_AVAIL);
 	}
 	return 0;
 }
@@ -280,13 +343,9 @@ static void nfsd_shutdown_generic(void)
 	nfsd_racache_shutdown();
 }
 
-static bool nfsd_needs_lockd(void)
+static bool nfsd_needs_lockd(struct nfsd_net *nn)
 {
-#if defined(CONFIG_NFSD_V3)
-	return (nfsd_versions[2] != NULL) || (nfsd_versions[3] != NULL);
-#else
-	return (nfsd_versions[2] != NULL);
-#endif
+	return nfsd_vers(nn, 2, NFSD_TEST) || nfsd_vers(nn, 3, NFSD_TEST);
 }
 
 static int nfsd_startup_net(int nrservs, struct net *net)
@@ -304,7 +363,7 @@ static int nfsd_startup_net(int nrservs, struct net *net)
 	if (ret)
 		goto out_socks;
 
-	if (nfsd_needs_lockd() && !nn->lockd_up) {
+	if (nfsd_needs_lockd(nn) && !nn->lockd_up) {
 		ret = lockd_up(net);
 		if (ret)
 			goto out_socks;
@@ -437,20 +496,20 @@ static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
 	nfsd_export_flush(net);
 }
 
-void nfsd_reset_versions(void)
+void nfsd_reset_versions(struct nfsd_net *nn)
 {
 	int i;
 
 	for (i = 0; i < NFSD_NRVERS; i++)
-		if (nfsd_vers(i, NFSD_TEST))
+		if (nfsd_vers(nn, i, NFSD_TEST))
 			return;
 
 	for (i = 0; i < NFSD_NRVERS; i++)
 		if (i != 4)
-			nfsd_vers(i, NFSD_SET);
+			nfsd_vers(nn, i, NFSD_SET);
 		else {
 			int minor = 0;
-			while (nfsd_minorversion(minor, NFSD_SET) >= 0)
+			while (nfsd_minorversion(nn, minor, NFSD_SET) >= 0)
 				minor++;
 		}
 }
@@ -518,7 +577,7 @@ int nfsd_create_serv(struct net *net)
 	}
 	if (nfsd_max_blksize == 0)
 		nfsd_max_blksize = nfsd_get_default_max_blksize();
-	nfsd_reset_versions();
+	nfsd_reset_versions(nn);
 	nn->nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
 						&nfsd_thread_sv_ops);
 	if (nn->nfsd_serv == NULL)
@@ -697,11 +756,44 @@ nfsd_acl_rpcbind_set(struct net *net, const struct svc_program *progp,
 		     unsigned short port)
 {
 	if (!nfsd_support_acl_version(version) ||
-	    !nfsd_vers(version, NFSD_TEST))
+	    !nfsd_vers(net_generic(net, nfsd_net_id), version, NFSD_TEST))
 		return 0;
 	return svc_generic_rpcbind_set(net, progp, version, family,
 			proto, port);
 }
+
+static __be32
+nfsd_acl_init_request(struct svc_rqst *rqstp,
+		      const struct svc_program *progp,
+		      struct svc_process_info *ret)
+{
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	int i;
+
+	if (likely(nfsd_support_acl_version(rqstp->rq_vers) &&
+	    nfsd_vers(nn, rqstp->rq_vers, NFSD_TEST)))
+		return svc_generic_init_request(rqstp, progp, ret);
+
+	ret->mismatch.lovers = NFSD_ACL_NRVERS;
+	for (i = NFSD_ACL_MINVERS; i < NFSD_ACL_NRVERS; i++) {
+		if (nfsd_support_acl_version(rqstp->rq_vers) &&
+		    nfsd_vers(nn, i, NFSD_TEST)) {
+			ret->mismatch.lovers = i;
+			break;
+		}
+	}
+	if (ret->mismatch.lovers == NFSD_ACL_NRVERS)
+		return rpc_prog_unavail;
+	ret->mismatch.hivers = NFSD_ACL_MINVERS;
+	for (i = NFSD_ACL_NRVERS - 1; i >= NFSD_ACL_MINVERS; i--) {
+		if (nfsd_support_acl_version(rqstp->rq_vers) &&
+		    nfsd_vers(nn, i, NFSD_TEST)) {
+			ret->mismatch.hivers = i;
+			break;
+		}
+	}
+	return rpc_prog_mismatch;
+}
 #endif
 
 static int
@@ -709,12 +801,42 @@ nfsd_rpcbind_set(struct net *net, const struct svc_program *progp,
 		 u32 version, int family, unsigned short proto,
 		 unsigned short port)
 {
-	if (!nfsd_vers(version, NFSD_TEST))
+	if (!nfsd_vers(net_generic(net, nfsd_net_id), version, NFSD_TEST))
 		return 0;
 	return svc_generic_rpcbind_set(net, progp, version, family,
 			proto, port);
 }
 
+static __be32
+nfsd_init_request(struct svc_rqst *rqstp,
+		  const struct svc_program *progp,
+		  struct svc_process_info *ret)
+{
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	int i;
+
+	if (likely(nfsd_vers(nn, rqstp->rq_vers, NFSD_TEST)))
+		return svc_generic_init_request(rqstp, progp, ret);
+
+	ret->mismatch.lovers = NFSD_NRVERS;
+	for (i = NFSD_MINVERS; i < NFSD_NRVERS; i++) {
+		if (nfsd_vers(nn, i, NFSD_TEST)) {
+			ret->mismatch.lovers = i;
+			break;
+		}
+	}
+	if (ret->mismatch.lovers == NFSD_NRVERS)
+		return rpc_prog_unavail;
+	ret->mismatch.hivers = NFSD_MINVERS;
+	for (i = NFSD_NRVERS - 1; i >= NFSD_MINVERS; i--) {
+		if (nfsd_vers(nn, i, NFSD_TEST)) {
+			ret->mismatch.hivers = i;
+			break;
+		}
+	}
+	return rpc_prog_mismatch;
+}
+
 /*
  * This is the NFS server kernel thread
  */
-- 
2.20.1

