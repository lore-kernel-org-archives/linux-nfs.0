Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E216BC4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:17:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9CAA220700
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:17:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W8N/EjHq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726486AbfDBXRG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:17:06 -0400
Received: from mail-pg1-f194.google.com ([209.85.215.194]:37886 "EHLO
        mail-pg1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726399AbfDBXRF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:17:05 -0400
Received: by mail-pg1-f194.google.com with SMTP id e6so2937385pgc.4
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:17:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=EwME1HX/xg/GHRa73D3KSQ5sRLqRhdU5jlZ5LXKMsV8=;
        b=W8N/EjHqKEasQ29W0DdXCAyJw9Ncg7QtRlGnm3FcNg+TzJhqUlRpwVONHSTzfP62Ef
         ujyLW+KZuFZ1O/8sA8DCH57VoTna3tyaidBz9Ofa38ZZEK/3I+hC8nl+s6Kx9f+/jlKc
         8vapR+qj2E6OceQkReADvB60Q2i7VvHCjPZ3UqziH+ax+4+WS+F7JNoHDkP2ynmkuk86
         eI5ltzn3JQcOxex01MUfMNdWW7FsXlnLzfJInHJ7UaaGR/OIcUZXDN9psjJkCTh7qhSI
         3pRRtzhXZhvygHnxG76p08WWOfrmglIgaDIJoK7MBtoRC3Bt635NUoNIvH478uGHM2tc
         3f5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=EwME1HX/xg/GHRa73D3KSQ5sRLqRhdU5jlZ5LXKMsV8=;
        b=OwNtMbjBvjSCgvzb9L/z2OmWRJetp5Km4+x9sOCKXfTyVGvkY3JKpVO2AGsMSAsoDB
         bdL+BWwWmi0R5X0S+FisuEIvnsKbyr1W8Co4okDBhJ+7J/IAN5n1VuPoPC8kS3tZDtrW
         XzdxbuUI4CADX3Oi+enyvXZ9rUk+fsTyn87GcPGs4BqeWeHQKwSHtKyit9+RF9jl+Jnb
         0ehNfif074DZsJd6f1agXBrpMtgwq2g+tV70gxq8D/OCF6hwJ/+aqaxqLnPQRC8JNm8E
         XFAu/Op5RgpGqtFWd0Fh1IXv2T3Fzsk6QtCv4uBOuWt9sEtc889ajBfzi0A/AVKqtI9K
         h/Rw==
X-Gm-Message-State: APjAAAXAiDL9NIEbrmvl3fnXRCCiO3lhKa7xX9OppcP6Zdun7incKIok
        xyXwkr7imHQ34Mgn6QOHtDuUWWk=
X-Google-Smtp-Source: APXvYqzCr0qB6h7ddGP1Ptc9BQzGwMoXGJjbKnREXR359/NFvHWqWT5ye04M9AGZGTxcQU9iez4R6g==
X-Received: by 2002:a63:7152:: with SMTP id b18mr61046781pgn.186.1554247023946;
        Tue, 02 Apr 2019 16:17:03 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id k17sm18160799pfk.166.2019.04.02.16.17.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:17:02 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] nfsd: Allow containers to set supported nfs versions
Date:   Tue,  2 Apr 2019 16:14:48 -0700
Message-Id: <20190402231448.27743-7-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190402231448.27743-6-trond.myklebust@hammerspace.com>
References: <20190402231448.27743-1-trond.myklebust@hammerspace.com>
 <20190402231448.27743-2-trond.myklebust@hammerspace.com>
 <20190402231448.27743-3-trond.myklebust@hammerspace.com>
 <20190402231448.27743-4-trond.myklebust@hammerspace.com>
 <20190402231448.27743-5-trond.myklebust@hammerspace.com>
 <20190402231448.27743-6-trond.myklebust@hammerspace.com>
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
 fs/nfsd/nfssvc.c   | 216 +++++++++++++++++++++++++++++++++++----------
 5 files changed, 198 insertions(+), 62 deletions(-)

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
index c6649464bc4b..16fd157e7651 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -42,6 +42,12 @@ static int			nfsd_rpcbind_set(struct net *,
 						 u32, int,
 						 unsigned short,
 						 unsigned short);
+static __be32			nfsd_acl_init_request(struct svc_rqst *,
+						const struct svc_program *,
+						struct svc_process_info *);
+static __be32			nfsd_init_request(struct svc_rqst *,
+						const struct svc_program *,
+						struct svc_process_info *);
 
 /*
  * nfsd_mutex protects nn->nfsd_serv -- both the pointer itself and the members
@@ -96,7 +102,7 @@ static struct svc_program	nfsd_acl_program = {
 	.pg_class		= "nfsd",
 	.pg_stats		= &nfsd_acl_svcstats,
 	.pg_authenticate	= &svc_set_client,
-	.pg_init_request	= svc_generic_init_request,
+	.pg_init_request	= nfsd_acl_init_request,
 	.pg_rpcbind_set		= nfsd_acl_rpcbind_set,
 };
 
@@ -117,7 +123,6 @@ static const struct svc_version *nfsd_version[] = {
 
 #define NFSD_MINVERS    	2
 #define NFSD_NRVERS		ARRAY_SIZE(nfsd_version)
-static const struct svc_version *nfsd_versions[NFSD_NRVERS];
 
 struct svc_program		nfsd_program = {
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
@@ -125,21 +130,15 @@ struct svc_program		nfsd_program = {
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
-
 static bool
 nfsd_support_acl_version(int vers)
 {
@@ -148,63 +147,127 @@ nfsd_support_acl_version(int vers)
 	return false;
 }
 
-int nfsd_vers(int vers, enum vers_op change)
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
+
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
@@ -286,13 +349,9 @@ static void nfsd_shutdown_generic(void)
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
@@ -310,7 +369,7 @@ static int nfsd_startup_net(int nrservs, struct net *net)
 	if (ret)
 		goto out_socks;
 
-	if (nfsd_needs_lockd() && !nn->lockd_up) {
+	if (nfsd_needs_lockd(nn) && !nn->lockd_up) {
 		ret = lockd_up(net);
 		if (ret)
 			goto out_socks;
@@ -443,20 +502,20 @@ static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
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
@@ -524,7 +583,7 @@ int nfsd_create_serv(struct net *net)
 	}
 	if (nfsd_max_blksize == 0)
 		nfsd_max_blksize = nfsd_get_default_max_blksize();
-	nfsd_reset_versions();
+	nfsd_reset_versions(nn);
 	nn->nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
 						&nfsd_thread_sv_ops);
 	if (nn->nfsd_serv == NULL)
@@ -694,7 +753,7 @@ nfsd_acl_rpcbind_set(struct net *net, const struct svc_program *progp,
 		     unsigned short port)
 {
 	if (!nfsd_support_acl_version(version) ||
-	    !nfsd_vers(version, NFSD_TEST))
+	    !nfsd_vers(net_generic(net, nfsd_net_id), version, NFSD_TEST))
 		return 0;
 	return svc_generic_rpcbind_set(net, progp, version, family,
 			proto, port);
@@ -705,12 +764,75 @@ nfsd_rpcbind_set(struct net *net, const struct svc_program *progp,
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
+
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

