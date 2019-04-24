Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24CF7C282CE
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DE09F20811
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KD7KIjgK"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731109AbfDXVtL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 17:49:11 -0400
Received: from mail-io1-f41.google.com ([209.85.166.41]:43707 "EHLO
        mail-io1-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730607AbfDXVtL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 17:49:11 -0400
Received: by mail-io1-f41.google.com with SMTP id v9so1390444iol.10
        for <linux-nfs@vger.kernel.org>; Wed, 24 Apr 2019 14:49:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=lX/TddBYpzd546zGGBEhQGpUOn6/HkIV+QCsNLEBm0E=;
        b=KD7KIjgKA38VuEsradnwnVkNq/Ipwf4AVkjv2SaKNHYCCHQHAORnz7iiuRK+7DY4Q6
         DUNxNyozImiPyLVBwTgAVFsnczt21x+Reje9MGaqWIdhA88Wz26HbnGeghwX79xbEqM+
         W8d7/fdC7hDCDjesMfh8+0GuHjgZ47VorIXqPpkwm9MaoHV+ybYRG0xmEXWdeIFLoRAD
         xujKwPVSUJg/sUdd2wQemffBd6gZ/m7IQ2Fb0xX1XLkET5Q62M0+4PB0Yz+/W18kpDK8
         mZ1Hefi2FeiK8kCIvbaYTM9lUT3ZqenAQ1JdWE05om3j8pmEffjYguBOLvKF79J0xag/
         vqvA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=lX/TddBYpzd546zGGBEhQGpUOn6/HkIV+QCsNLEBm0E=;
        b=SbZgUroarrJ8MaR7WaPeFtL9vbFXDdafgrLkzIvBdufmv/CBWeLRDkUN1mUxi9412l
         uXo1iax6sXqKn7XsCygckzXx68svel91RRP2ZKiS6931SnfHJZWqxuYPkrMzfQUm0qkQ
         vo6ZZX01nvvNdGun8CBT8AXp2ji1wH8Dg2DZgrfFfAFUgVHGgFmBXQ9G643q6twow8gJ
         +XfXWnHyGxBwt2iU3YiFUS8k3EoEH99wExjbpYeV7C/NaikLnQcZPd+FdYLUXMJqi6qR
         xuOJWOGDGnsXbX5Q5w5GcV/Zn/8+8g9iOV2TgCxo4IwANP+rO1aw7jAUvtoFCyv//dEp
         ww2g==
X-Gm-Message-State: APjAAAV5LurKNblOqrOwhdtxwxmnPOyQBxFLl70M4ZdAJQCtwpGMRIGR
        sBDCDYvaA2Q6lkS6Wl1uQMR01pg=
X-Google-Smtp-Source: APXvYqzaECpvViMFOQ+RWtryq26STs0aIZUfb4P0zbvpRfyFfHjuklvsNPo1MJQPieFA7/QaVbdQkA==
X-Received: by 2002:a5d:88ca:: with SMTP id i10mr22374216iol.261.1556142549198;
        Wed, 24 Apr 2019 14:49:09 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id x10sm9838282ita.4.2019.04.24.14.49.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 14:49:08 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 9/9] lockd: Store the lockd client credential in struct nlm_host
Date:   Wed, 24 Apr 2019 17:46:50 -0400
Message-Id: <20190424214650.4658-10-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190424214650.4658-9-trond.myklebust@hammerspace.com>
References: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
 <20190424214650.4658-2-trond.myklebust@hammerspace.com>
 <20190424214650.4658-3-trond.myklebust@hammerspace.com>
 <20190424214650.4658-4-trond.myklebust@hammerspace.com>
 <20190424214650.4658-5-trond.myklebust@hammerspace.com>
 <20190424214650.4658-6-trond.myklebust@hammerspace.com>
 <20190424214650.4658-7-trond.myklebust@hammerspace.com>
 <20190424214650.4658-8-trond.myklebust@hammerspace.com>
 <20190424214650.4658-9-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When we create a new lockd client, we want to be able to pass the
correct credential of the process that created the struct nlm_host.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/lockd/clntlock.c         |  2 +-
 fs/lockd/host.c             | 11 +++++++++--
 include/linux/lockd/bind.h  |  1 +
 include/linux/lockd/lockd.h |  4 +++-
 4 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index c2a128678e6e..70f520b41a19 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -63,7 +63,7 @@ struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
 	host = nlmclnt_lookup_host(nlm_init->address, nlm_init->addrlen,
 				   nlm_init->protocol, nlm_version,
 				   nlm_init->hostname, nlm_init->noresvport,
-				   nlm_init->net);
+				   nlm_init->net, nlm_init->cred);
 	if (host == NULL)
 		goto out_nohost;
 	if (host->h_rpcclnt == NULL && nlm_bind_host(host) == NULL)
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index d46081123f7c..7d46fafdbbe5 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -60,6 +60,7 @@ struct nlm_lookup_host_info {
 	const size_t		hostname_len;	/* it's length */
 	const int		noresvport;	/* use non-priv port */
 	struct net		*net;		/* network namespace to bind */
+	const struct cred	*cred;
 };
 
 /*
@@ -162,6 +163,7 @@ static struct nlm_host *nlm_alloc_host(struct nlm_lookup_host_info *ni,
 	host->h_nsmhandle  = nsm;
 	host->h_addrbuf    = nsm->sm_addrbuf;
 	host->net	   = ni->net;
+	host->h_cred	   = get_cred(ni->cred),
 	strlcpy(host->nodename, utsname()->nodename, sizeof(host->nodename));
 
 out:
@@ -188,6 +190,7 @@ static void nlm_destroy_host_locked(struct nlm_host *host)
 	clnt = host->h_rpcclnt;
 	if (clnt != NULL)
 		rpc_shutdown_client(clnt);
+	put_cred(host->h_cred);
 	kfree(host);
 
 	ln->nrhosts--;
@@ -202,6 +205,8 @@ static void nlm_destroy_host_locked(struct nlm_host *host)
  * @version: NLM protocol version
  * @hostname: '\0'-terminated hostname of server
  * @noresvport: 1 if non-privileged port should be used
+ * @net: pointer to net namespace
+ * @cred: pointer to cred
  *
  * Returns an nlm_host structure that matches the passed-in
  * [server address, transport protocol, NLM version, server hostname].
@@ -214,7 +219,8 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 				     const u32 version,
 				     const char *hostname,
 				     int noresvport,
-				     struct net *net)
+				     struct net *net,
+				     const struct cred *cred)
 {
 	struct nlm_lookup_host_info ni = {
 		.server		= 0,
@@ -226,6 +232,7 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 		.hostname_len	= strlen(hostname),
 		.noresvport	= noresvport,
 		.net		= net,
+		.cred		= cred,
 	};
 	struct hlist_head *chain;
 	struct nlm_host	*host;
@@ -458,7 +465,7 @@ nlm_bind_host(struct nlm_host *host)
 			.authflavor	= RPC_AUTH_UNIX,
 			.flags		= (RPC_CLNT_CREATE_NOPING |
 					   RPC_CLNT_CREATE_AUTOBIND),
-			.cred		= current_cred(),
+			.cred		= host->h_cred,
 		};
 
 		/*
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 053a4ef3d431..8c0cf1059443 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -46,6 +46,7 @@ struct nlmclnt_initdata {
 	int			noresvport;
 	struct net		*net;
 	const struct nlmclnt_operations	*nlmclnt_ops;
+	const struct cred	*cred;
 };
 
 /*
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index b065ef406770..c9b422dde542 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -70,6 +70,7 @@ struct nlm_host {
 	struct nsm_handle	*h_nsmhandle;	/* NSM status handle */
 	char			*h_addrbuf;	/* address eyecatcher */
 	struct net		*net;		/* host net */
+	const struct cred	*h_cred;
 	char			nodename[UNX_MAXNODENAME + 1];
 	const struct nlmclnt_operations	*h_nlmclnt_ops;	/* Callback ops for NLM users */
 };
@@ -229,7 +230,8 @@ struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
 					const u32 version,
 					const char *hostname,
 					int noresvport,
-					struct net *net);
+					struct net *net,
+					const struct cred *cred);
 void		  nlmclnt_release_host(struct nlm_host *);
 struct nlm_host  *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 					const char *hostname,
-- 
2.21.0

