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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BDB1C282CE
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 15:48:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D26D02084C
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 15:48:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Yav4QpfX"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726607AbfDIPsf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 11:48:35 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:54105 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726372AbfDIPse (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2019 11:48:34 -0400
Received: by mail-it1-f195.google.com with SMTP id y204so5687973itf.3
        for <linux-nfs@vger.kernel.org>; Tue, 09 Apr 2019 08:48:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=dVVmNCs9Jgu1MljT5DMO0AN2UrT9HIqyFnrCEIt3kQo=;
        b=Yav4QpfXZaMdGtnbGarxPfItnIJBb/dzmtO19jvWYVN67eQ+W6t4AAkiDaQCuVeMwG
         91td5Kwp1yl1PC5gDEE5sHxs8hfTSBowh5zYbfhenTysv8KqAEWSC/5mezc92lEr0CZD
         c+cVY1vH9AH3/sj9rhwh4c72fN1tz0P+44wug2Om/fRWFX3+RJxTurvIW03ACIZFA4dh
         QwcnxM5KsXqiuPYPanaUSx2h9Vx1I+6qFrRSj79p0L9FfhJyWB+3NNxi0/eEhbvPVk1m
         aZ6ARcyulXlkA2Jn8zRXpzE/PhRgw0T8jktutuqlU5HsnoGgqTxvypetoxNrigmBdvUH
         SbsA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=dVVmNCs9Jgu1MljT5DMO0AN2UrT9HIqyFnrCEIt3kQo=;
        b=VJh5l/KbOVW5bz6SjC1XEpQPRuuDE4CBRZ4JMHpe6yP50W1QWf28u0Mdj6H/92l1Fh
         Yr4HJLTCdONeTf2u8A4bDvhUoqIQrZqBdFMFhZU5c9QMPAyDKwVWdfiAJ0sn2NprLpFD
         EfXYRgHi8sMtut8OqYHmoXEP98KldnPB4NIDDZt0ByA82B/Ebte1UeTUzGT3S26xsZEN
         KrxYk00XMPqGKmMgDHblWpSD8KtuprXlY7PwBWiEeas5O136JbsBTdoU079zraBQtwn3
         jue/vAzhZ99N/41bn0Qx5F3fyyd9rSW37toYhuGu/Xo6x0S3yrxlAIj71kaUzRV4akJ/
         7KtQ==
X-Gm-Message-State: APjAAAVDrKEkAUY0rKOsz7mkVIzIJS1exh8/NaYx7+mBHD3zmmeloT+L
        TIac5g/025hYxzwEprWo5dZbZ1c=
X-Google-Smtp-Source: APXvYqxKwvcAuYSaTagF9xe1Lukw9oLbT7alJoVIBzec1CY3384+WmZfWbv4297uQMgasnGUv9o9WA==
X-Received: by 2002:a02:c643:: with SMTP id k3mr26880931jan.19.1554824913430;
        Tue, 09 Apr 2019 08:48:33 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id 62sm7026910itx.41.2019.04.09.08.48.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 08:48:32 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/6] nfsd: Add custom rpcbind callbacks for knfsd
Date:   Tue,  9 Apr 2019 11:46:18 -0400
Message-Id: <20190409154619.33615-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409154619.33615-5-trond.myklebust@hammerspace.com>
References: <20190409154619.33615-1-trond.myklebust@hammerspace.com>
 <20190409154619.33615-2-trond.myklebust@hammerspace.com>
 <20190409154619.33615-3-trond.myklebust@hammerspace.com>
 <20190409154619.33615-4-trond.myklebust@hammerspace.com>
 <20190409154619.33615-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add custom rpcbind callbacks in preparation for the knfsd
per-container version feature.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/nfssvc.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 46 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 6a52400c85e0..378edcfe9701 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -32,6 +32,18 @@
 
 extern struct svc_program	nfsd_program;
 static int			nfsd(void *vrqstp);
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+static int			nfsd_acl_rpcbind_set(struct net *,
+						     const struct svc_program *,
+						     u32, int,
+						     unsigned short,
+						     unsigned short);
+#endif
+static int			nfsd_rpcbind_set(struct net *,
+						 const struct svc_program *,
+						 u32, int,
+						 unsigned short,
+						 unsigned short);
 
 /*
  * nfsd_mutex protects nn->nfsd_serv -- both the pointer itself and the members
@@ -87,7 +99,7 @@ static struct svc_program	nfsd_acl_program = {
 	.pg_stats		= &nfsd_acl_svcstats,
 	.pg_authenticate	= &svc_set_client,
 	.pg_init_request	= svc_generic_init_request,
-	.pg_rpcbind_set		= svc_generic_rpcbind_set,
+	.pg_rpcbind_set		= nfsd_acl_rpcbind_set,
 };
 
 static struct svc_stat	nfsd_acl_svcstats = {
@@ -121,7 +133,7 @@ struct svc_program		nfsd_program = {
 	.pg_stats		= &nfsd_svcstats,	/* version table */
 	.pg_authenticate	= &svc_set_client,	/* export authentication */
 	.pg_init_request	= svc_generic_init_request,
-	.pg_rpcbind_set		= svc_generic_rpcbind_set,
+	.pg_rpcbind_set		= nfsd_rpcbind_set,
 };
 
 static bool nfsd_supported_minorversions[NFSD_SUPPORTED_MINOR_VERSION + 1] = {
@@ -670,6 +682,38 @@ nfsd_svc(int nrservs, struct net *net)
 	return error;
 }
 
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+static bool
+nfsd_support_acl_version(int vers)
+{
+	if (vers >= NFSD_ACL_MINVERS && vers < NFSD_ACL_NRVERS)
+		return nfsd_acl_version[vers] != NULL;
+	return false;
+}
+
+static int
+nfsd_acl_rpcbind_set(struct net *net, const struct svc_program *progp,
+		     u32 version, int family, unsigned short proto,
+		     unsigned short port)
+{
+	if (!nfsd_support_acl_version(version) ||
+	    !nfsd_vers(version, NFSD_TEST))
+		return 0;
+	return svc_generic_rpcbind_set(net, progp, version, family,
+			proto, port);
+}
+#endif
+
+static int
+nfsd_rpcbind_set(struct net *net, const struct svc_program *progp,
+		 u32 version, int family, unsigned short proto,
+		 unsigned short port)
+{
+	if (!nfsd_vers(version, NFSD_TEST))
+		return 0;
+	return svc_generic_rpcbind_set(net, progp, version, family,
+			proto, port);
+}
 
 /*
  * This is the NFS server kernel thread
-- 
2.20.1

