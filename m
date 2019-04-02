Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A59DC4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:17:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D1EC920700
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:17:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mrNOOc1/"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726477AbfDBXRD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:17:03 -0400
Received: from mail-pf1-f193.google.com ([209.85.210.193]:44618 "EHLO
        mail-pf1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725842AbfDBXRD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:17:03 -0400
Received: by mail-pf1-f193.google.com with SMTP id y13so7119420pfm.11
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:17:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=T1HF9AURg3N1u8IMlovMfyRnL3l/EJHfvBboMTS/0cQ=;
        b=mrNOOc1/2WIrVpEqh9XIwc6n8gU/Ei75Y4+1DKqdnmN1LpnGK8WGtA4hrjNnCSgLn7
         6sIurbSh8jGA/jW6G3ULjLKHFflJHEYIGkTJZb9zeQzj00ODywvj9w/KSj0MhQ5ujBz/
         LO1j+PrD8X8yhdjj6IGbGBZS6QHdLoAK/1DR9jF0kj2iZmaDVaiwA3ZHJ/f0fDm7js12
         AQkatoP+sXyjb6TxnRd0f5mGFCCgts4f+6a0Y1HKCrPmU8qOttiRu5peu/GOib6jVQ/j
         XwRf+duKenbKC+A/52FiRcRLgTK4pH9FKGDKDKaxZbisKwGJyIzfqS8xkpr+6Z5v36BL
         9Hqg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=T1HF9AURg3N1u8IMlovMfyRnL3l/EJHfvBboMTS/0cQ=;
        b=ex4Rk0rK34H/gTqYONH2+vCNhFyc/abUlTKP0T0J6ZzQ4Lazudj8tFNXfw2c8En8sw
         BnqZGgDZLbgecWSwnXx1EYq/hqKzZjZnq0lEi8Ez0prPsAwI22OihNrOG5HBWXMPdYab
         YBnKWJwLTKVinTr/hagLKhxXavXkSUsrt/8fQUOWDH5d1APbr23MGuLlU/d3kbU0ZGaB
         uW+jIofj1YbbGSab7wJ52w2Q1v2hUXLDOsAx21fq/y+Ay655gRZYGOh2P+9rJtqU4pQ8
         KvQlBYaIytlPVuFOQeUZjElPEbPG1/Uco8VKuhNXrLlz/smJQGoqAF+i3GBiJN/S9WAp
         djcQ==
X-Gm-Message-State: APjAAAWSrZD25XawDoWaUU0P/vYUfJ8o0F8SHUXKu4sugH7eIIy1pa9a
        0+c15qlEMcBOAr8ETRrB7rwwKwo=
X-Google-Smtp-Source: APXvYqyJuml4nptRRvwXVnfSwCJNS5jgGA1XGqsS0ssazkuxPmEGjLrsUuWMyZEJ4VBT7tmxFSAyow==
X-Received: by 2002:a62:5206:: with SMTP id g6mr55480342pfb.227.1554247021777;
        Tue, 02 Apr 2019 16:17:01 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id k17sm18160799pfk.166.2019.04.02.16.17.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:17:00 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] SUNRPC: Allow further customisation of RPC program registration
Date:   Tue,  2 Apr 2019 16:14:46 -0700
Message-Id: <20190402231448.27743-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190402231448.27743-4-trond.myklebust@hammerspace.com>
References: <20190402231448.27743-1-trond.myklebust@hammerspace.com>
 <20190402231448.27743-2-trond.myklebust@hammerspace.com>
 <20190402231448.27743-3-trond.myklebust@hammerspace.com>
 <20190402231448.27743-4-trond.myklebust@hammerspace.com>
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
index eb6c7cef40de..d74604d3e1cf 100644
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

