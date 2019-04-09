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
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0D84C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 15:48:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 791A92084C
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 15:48:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X/Y/16bn"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726572AbfDIPsd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 11:48:33 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:51399 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726372AbfDIPsd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 11:48:33 -0400
Received: by mail-it1-f194.google.com with SMTP id s3so5714414itk.1
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 08:48:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Yf+dz/ytyjO5LdYApXPPCMv9F7Z5mZneai/UPzYLQbU=;
        b=X/Y/16bnmQTUT+/jyeySymn9/2UeYrar8apC63zRqJMJ6A1eGBWclTS/EpkEOTdhyo
         9fv+sqhOMKK6UO+yFaHjtSAe9ui0QSNAwz7LLxvl5AC0UR2YWvOHKJ/LyaaCYbGbq1vQ
         lWmuAVf1pMz0LXaCVqojqDQSzximnSeZQLbMRW4kQaahGv8sn//I3qJEquro3mo+lYFE
         poSsZfo3R+gdJn4dZySh8JlkK2O0kqlTk2yJb1JVOysNFfrnytKjpP0Z1rLbdRNYU1ZJ
         Vh+vKMd1iDT1SpM973DhVMJRDFP305lQ83KuhQl69MvueFsOhNCJutw7L33jXoM2ubrB
         FWhg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Yf+dz/ytyjO5LdYApXPPCMv9F7Z5mZneai/UPzYLQbU=;
        b=lwXVDHUqxY7dyS3HHUdiui1ftxbLCUUelqQzXC+ll73ak5gDEG+K15whwDhv1z/0U0
         cFw3cGlJ3HiOZYyZpPRmFM5mDjmOmd2wbg5B1MWA2vbwxDitV+mG88eMTahpJ6nu4/n2
         zwvksGFeLrze/K3wHoGU4yrKPnBrzWLLMqkDxz2dCvOo+jF32VXfJ4fSKSmFrwVyQqC7
         5r9oEkVM1Xz01QFM9+COfSMCnitLOU83w0lXuMMGoIUpvpy25i2HYkReHhtE4e8VOqDM
         Ar3pOg7dv2a/1mfAb5E8O25uGQLNqTXtaZN31f4cCQMC4XAhIftVgUX0RWsbllb0sq5D
         tO3w==
X-Gm-Message-State: APjAAAUIEoVp39l/shN+XDM9XkHAy6WLVh2vyy1PIkhCI8WDturaABux
        SIVH5KVn5VJEUHglascv8dnNEbE=
X-Google-Smtp-Source: APXvYqxYx8Z5HjSqDABXUt8epvg9fZS8RNgAGUofWpqxCfTkzcUX5TafvXkO86kLBMjJnx8eaI9N7Q==
X-Received: by 2002:a24:298b:: with SMTP id p133mr26539360itp.81.1554824912254;
        Tue, 09 Apr 2019 08:48:32 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id 62sm7026910itx.41.2019.04.09.08.48.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 08:48:31 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/6] SUNRPC: Allow further customisation of RPC program registration
Date:   Tue,  9 Apr 2019 11:46:17 -0400
Message-Id: <20190409154619.33615-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409154619.33615-4-trond.myklebust@hammerspace.com>
References: <20190409154619.33615-1-trond.myklebust@hammerspace.com>
 <20190409154619.33615-2-trond.myklebust@hammerspace.com>
 <20190409154619.33615-3-trond.myklebust@hammerspace.com>
 <20190409154619.33615-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add a callback to allow customisation of the rpcbind registration.
When clients have the ability to turn on and off version support,
we want to allow them to also prevent registration of those
versions with the rpc portmapper.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/lockd/svc.c             |  1 +
 fs/nfs/callback.c          |  1 +
 fs/nfsd/nfssvc.c           |  3 +-
 include/linux/sunrpc/svc.h | 15 +++++++
 net/sunrpc/svc.c           | 85 ++++++++++++++++++++++++--------------
 5 files changed, 73 insertions(+), 32 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 75415b21efda..96bb74c919f9 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -809,4 +809,5 @@ static struct svc_program	nlmsvc_program = {
 	.pg_stats		= &nlmsvc_stats,	/* stats table */
 	.pg_authenticate	= &lockd_authenticate,	/* export authentication */
 	.pg_init_request	= svc_generic_init_request,
+	.pg_rpcbind_set		= svc_generic_rpcbind_set,
 };
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index a9510374bad7..15c9575e0e7a 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -458,4 +458,5 @@ static struct svc_program nfs4_callback_program = {
 	.pg_stats = &nfs4_callback_stats,
 	.pg_authenticate = nfs_callback_authenticate,
 	.pg_init_request = svc_generic_init_request,
+	.pg_rpcbind_set	= svc_generic_rpcbind_set,
 };
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index e26762e84798..6a52400c85e0 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -87,6 +87,7 @@ static struct svc_program	nfsd_acl_program = {
 	.pg_stats		= &nfsd_acl_svcstats,
 	.pg_authenticate	= &svc_set_client,
 	.pg_init_request	= svc_generic_init_request,
+	.pg_rpcbind_set		= svc_generic_rpcbind_set,
 };
 
 static struct svc_stat	nfsd_acl_svcstats = {
@@ -120,7 +121,7 @@ struct svc_program		nfsd_program = {
 	.pg_stats		= &nfsd_svcstats,	/* version table */
 	.pg_authenticate	= &svc_set_client,	/* export authentication */
 	.pg_init_request	= svc_generic_init_request,
-
+	.pg_rpcbind_set		= svc_generic_rpcbind_set,
 };
 
 static bool nfsd_supported_minorversions[NFSD_SUPPORTED_MINOR_VERSION + 1] = {
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index f43d5765acff..1afe38eb33f7 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -410,6 +410,11 @@ struct svc_program {
 	__be32			(*pg_init_request)(struct svc_rqst *,
 						   const struct svc_program *,
 						   struct svc_process_info *);
+	int			(*pg_rpcbind_set)(struct net *net,
+						  const struct svc_program *,
+						  u32 version, int family,
+						  unsigned short proto,
+						  unsigned short port);
 };
 
 /*
@@ -522,6 +527,16 @@ __be32		   svc_return_autherr(struct svc_rqst *rqstp, __be32 auth_err);
 __be32		   svc_generic_init_request(struct svc_rqst *rqstp,
 					    const struct svc_program *progp,
 					    struct svc_process_info *procinfo);
+int		   svc_generic_rpcbind_set(struct net *net,
+					   const struct svc_program *progp,
+					   u32 version, int family,
+					   unsigned short proto,
+					   unsigned short port);
+int		   svc_rpcbind_set_version(struct net *net,
+					   const struct svc_program *progp,
+					   u32 version, int family,
+					   unsigned short proto,
+					   unsigned short port);
 
 #define	RPC_MAX_ADDRBUFLEN	(63U)
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 791c8076793f..2be827820247 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -993,6 +993,58 @@ static int __svc_register(struct net *net, const char *progname,
 	return error;
 }
 
+int svc_rpcbind_set_version(struct net *net,
+			    const struct svc_program *progp,
+			    u32 version, int family,
+			    unsigned short proto,
+			    unsigned short port)
+{
+	dprintk("svc: svc_register(%sv%d, %s, %u, %u)\n",
+		progp->pg_name, version,
+		proto == IPPROTO_UDP?  "udp" : "tcp",
+		port, family);
+
+	return __svc_register(net, progp->pg_name, progp->pg_prog,
+				version, family, proto, port);
+
+}
+EXPORT_SYMBOL_GPL(svc_rpcbind_set_version);
+
+int svc_generic_rpcbind_set(struct net *net,
+			    const struct svc_program *progp,
+			    u32 version, int family,
+			    unsigned short proto,
+			    unsigned short port)
+{
+	const struct svc_version *vers = progp->pg_vers[version];
+	int error;
+
+	if (vers == NULL)
+		return 0;
+
+	if (vers->vs_hidden) {
+		dprintk("svc: svc_register(%sv%d, %s, %u, %u)"
+			" (but not telling portmap)\n",
+			progp->pg_name, version,
+			proto == IPPROTO_UDP?  "udp" : "tcp",
+			port, family);
+		return 0;
+	}
+
+	/*
+	 * Don't register a UDP port if we need congestion
+	 * control.
+	 */
+	if (vers->vs_need_cong_ctrl && proto == IPPROTO_UDP)
+		return 0;
+
+	error = svc_rpcbind_set_version(net, progp, version,
+					family, proto, port);
+
+	return (vers->vs_rpcb_optnl) ? 0 : error;
+}
+EXPORT_SYMBOL_GPL(svc_generic_rpcbind_set);
+
 /**
  * svc_register - register an RPC service with the local portmapper
  * @serv: svc_serv struct for the service to register
@@ -1008,7 +1060,6 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 		 const unsigned short port)
 {
 	struct svc_program	*progp;
-	const struct svc_version *vers;
 	unsigned int		i;
 	int			error = 0;
 
@@ -1018,37 +1069,9 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 
 	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
 		for (i = 0; i < progp->pg_nvers; i++) {
-			vers = progp->pg_vers[i];
-			if (vers == NULL)
-				continue;
-
-			dprintk("svc: svc_register(%sv%d, %s, %u, %u)%s\n",
-					progp->pg_name,
-					i,
-					proto == IPPROTO_UDP?  "udp" : "tcp",
-					port,
-					family,
-					vers->vs_hidden ?
-					" (but not telling portmap)" : "");
-
-			if (vers->vs_hidden)
-				continue;
-
-			/*
-			 * Don't register a UDP port if we need congestion
-			 * control.
-			 */
-			if (vers->vs_need_cong_ctrl && proto == IPPROTO_UDP)
-				continue;
-
-			error = __svc_register(net, progp->pg_name, progp->pg_prog,
-						i, family, proto, port);
-
-			if (vers->vs_rpcb_optnl) {
-				error = 0;
-				continue;
-			}
 
+			error = progp->pg_rpcbind_set(net, progp, i,
+					family, proto, port);
 			if (error < 0) {
 				printk(KERN_WARNING "svc: failed to register "
 					"%sv%u RPC service (errno %d).\n",
-- 
2.20.1

