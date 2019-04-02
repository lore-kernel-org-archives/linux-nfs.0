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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96431C10F00
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:17:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5F42720700
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 23:17:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eNmkDTq2"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725842AbfDBXRD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 19:17:03 -0400
Received: from mail-pg1-f193.google.com ([209.85.215.193]:41710 "EHLO
        mail-pg1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726399AbfDBXRD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 19:17:03 -0400
Received: by mail-pg1-f193.google.com with SMTP id f6so7287531pgs.8
        for <linux-nfs@vger.kernel.org>; Tue, 02 Apr 2019 16:17:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ZsZTwSGjfqNWtVKhB7lapL16uStdlb0VYK2Di+qmqRo=;
        b=eNmkDTq2NTQOQ3VxFCd0IJb+Hm3SqlTvM5kVlYTE0XyQHSWzJPZ++z+tqsMvdAP2w8
         6BXmkKCvRbcRR8Xdi15KEPI6LxyKf1j8wanLmDRtDFr+ixim4a4U3QPhDEnYAInJXVze
         U/4hjBwp/D4tJVP1GRd7WnB646wecyg30rKJ/1wY9DzYIJyLFtRW9WTzogzIJXMnnwNg
         GFzxOCje2ZUJnZvU/yAQ3iONO/1MhiujZDnMSDZNUm+R05c/oofJRXHYndsz4nTjlGmu
         UZpqwkAFbI4g1CSdBMgF8qiEQMfYdFe1aMBM9pkF5/RKSbbaqtSDZjks02HRhFM/SAJ6
         LD5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ZsZTwSGjfqNWtVKhB7lapL16uStdlb0VYK2Di+qmqRo=;
        b=QvZc/sw8+p4aJVfGjQBHteHyOeWUmft7oSBwb2Iy44JFeBjgjS3MJfY88LhrCSYj/T
         pf4BAVD/7DIapRgUT2pmdWPf+mezjJQQSu5YyCmaJ2maYRtQEagR2wMKJ/B2Catg87OW
         BIjr23RrOVKT0JDi3FyMHEeqx5hFHsPhWfDp4zJQym3taxqFCjP3QV986bltHQIW6yZG
         olVDtV9UFEF5lPaIBi3LsPktSiUoyroNs2gyCTMbGZ3CMohJ2cxKJHO5M44rBQwgO6zn
         sElZqSPxvGwMWzAR93QcIk8cVXnuzhBkKIWsZhbNzcbP+4AEEzsusM6sHFCaWf9ehlD7
         h5qw==
X-Gm-Message-State: APjAAAVMmSVH4o4PVGGrdnEh9F1GjkHhRqfIUPHHLACMdqxKK5pE8ky1
        ufa0WDnJCN9lnBqjlLQf8So/+Xc=
X-Google-Smtp-Source: APXvYqyEYt0rmdqtMRcG91HWY0YJfsrxBWXPytmC2AZn5fm+H5Nj2rvc2ii8hgj43Wf5+7d+pjZTlQ==
X-Received: by 2002:a62:ee13:: with SMTP id e19mr71389200pfi.224.1554247022640;
        Tue, 02 Apr 2019 16:17:02 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id k17sm18160799pfk.166.2019.04.02.16.17.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 16:17:02 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] nfsd: Add custom rpcbind callbacks for knfsd
Date:   Tue,  2 Apr 2019 16:14:47 -0700
Message-Id: <20190402231448.27743-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190402231448.27743-5-trond.myklebust@hammerspace.com>
References: <20190402231448.27743-1-trond.myklebust@hammerspace.com>
 <20190402231448.27743-2-trond.myklebust@hammerspace.com>
 <20190402231448.27743-3-trond.myklebust@hammerspace.com>
 <20190402231448.27743-4-trond.myklebust@hammerspace.com>
 <20190402231448.27743-5-trond.myklebust@hammerspace.com>
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
 fs/nfsd/nfssvc.c | 44 ++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 42 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 6a52400c85e0..c6649464bc4b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -32,6 +32,16 @@
 
 extern struct svc_program	nfsd_program;
 static int			nfsd(void *vrqstp);
+static int			nfsd_acl_rpcbind_set(struct net *,
+						     const struct svc_program *,
+						     u32, int,
+						     unsigned short,
+						     unsigned short);
+static int			nfsd_rpcbind_set(struct net *,
+						 const struct svc_program *,
+						 u32, int,
+						 unsigned short,
+						 unsigned short);
 
 /*
  * nfsd_mutex protects nn->nfsd_serv -- both the pointer itself and the members
@@ -87,7 +97,7 @@ static struct svc_program	nfsd_acl_program = {
 	.pg_stats		= &nfsd_acl_svcstats,
 	.pg_authenticate	= &svc_set_client,
 	.pg_init_request	= svc_generic_init_request,
-	.pg_rpcbind_set		= svc_generic_rpcbind_set,
+	.pg_rpcbind_set		= nfsd_acl_rpcbind_set,
 };
 
 static struct svc_stat	nfsd_acl_svcstats = {
@@ -121,7 +131,7 @@ struct svc_program		nfsd_program = {
 	.pg_stats		= &nfsd_svcstats,	/* version table */
 	.pg_authenticate	= &svc_set_client,	/* export authentication */
 	.pg_init_request	= svc_generic_init_request,
-	.pg_rpcbind_set		= svc_generic_rpcbind_set,
+	.pg_rpcbind_set		= nfsd_rpcbind_set,
 };
 
 static bool nfsd_supported_minorversions[NFSD_SUPPORTED_MINOR_VERSION + 1] = {
@@ -130,6 +140,14 @@ static bool nfsd_supported_minorversions[NFSD_SUPPORTED_MINOR_VERSION + 1] = {
 	[2] = 1,
 };
 
+static bool
+nfsd_support_acl_version(int vers)
+{
+	if (vers >= NFSD_ACL_MINVERS && vers < NFSD_ACL_NRVERS)
+		return nfsd_acl_version[vers] != NULL;
+	return false;
+}
+
 int nfsd_vers(int vers, enum vers_op change)
 {
 	if (vers < NFSD_MINVERS || vers >= NFSD_NRVERS)
@@ -670,6 +688,28 @@ nfsd_svc(int nrservs, struct net *net)
 	return error;
 }
 
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

