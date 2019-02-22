Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 790C3C10F00
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:59:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 486FB2075C
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:59:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eTaVm1Np"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726278AbfBVV71 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 16:59:27 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:51266 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726019AbfBVV71 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 16:59:27 -0500
Received: by mail-it1-f195.google.com with SMTP id e24so5198230itl.1
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 13:59:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=aIyIGu4ERhN//EmGKkvvhxCX02bNotYS23nfuZugKxI=;
        b=eTaVm1NpJz0RSlIpy7SbTEP+6eRo0cUtPVZm0oGJwnTsawfeOgvcfUsDbrhUslCcms
         5Uuszjm+LHp4Ce4Er7VWx4V3QgbuzUVKXAeLDmFKjbZoHOrsTqwvENMoBRD9mhn3YM3S
         ibv5nW01SVEp3oOBgLkqGmOcRpjT+1cHRhfPqNnbfNTzs19Z3hnofeLG2PGnqZoGVtK5
         vBnanjBZ7KSdCZxlTPlvJuM+b7wiWnj68ZoW0tbjdiWZnAQh9H/EvXq7vFzhYpwUkFF3
         0yWi1V0r+JMLmhLRXEPC0GKlCe+pyDg/hwrIuByf496lcwG6np3ztZH3CRDWVawPu9ja
         yhtg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=aIyIGu4ERhN//EmGKkvvhxCX02bNotYS23nfuZugKxI=;
        b=DAO859wvEpa4jYKtvdADey440LDtuuPr99jIVo+bfArAOSeQ44sk02VCbCOpWpfDEe
         StO/6XocIxBkn2KB/MEmGr+cszKSrlpSGNnOO0om7nmKajRAv798tBLosrBpnBlzIm/q
         UOInol3O4a8qXpacBLqf85R7JE30JFiKh0jytgfdBpQZvYnVO6zxcyjELlrvwPpqwrmj
         J3YtrxJz56XBCnhch5DwSLXOuz4JUsq1Gr+PWISKSWwOG9sLyO+wb3P0OGTq3hNOw4dH
         k9u+b1YN1qSxaMngVk6wK+JNOFZq4C9Onk+hfB8xwtrzeSk53t2s3bzhs49h4zk8ON+l
         0eKQ==
X-Gm-Message-State: AHQUAuY/d7fvMmC6Hhdhezo+QKn+0hAvKNosTszgYntqdfJvfLg+/0Pc
        cDJIMWi4sdzNCaQf8SktBOs=
X-Google-Smtp-Source: AHgI3IZChmphYpitPF7ml5XTvtBl+/lS3SlG/gtdmRJ+aESQoL7sqlpUsd0l+QfqlQ5ZhkS9HeyI+w==
X-Received: by 2002:a24:6c46:: with SMTP id w67mr3446060itb.13.1550872766185;
        Fri, 22 Feb 2019 13:59:26 -0800 (PST)
Received: from gouda.nowheycreamery.com.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.gmail.com with ESMTPSA id f13sm998171iol.82.2019.02.22.13.59.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 13:59:25 -0800 (PST)
From:   schumaker.anna@gmail.com
X-Google-Original-From: Anna.Schumaker@Netapp.com
To:     Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Cc:     Anna.Schumaker@Netapp.com
Subject: [PATCH 6/6] NFS: Add a mount option for READ_PLUS
Date:   Fri, 22 Feb 2019 16:59:18 -0500
Message-Id: <20190222215918.20647-7-Anna.Schumaker@Netapp.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190222215918.20647-1-Anna.Schumaker@Netapp.com>
References: <20190222215918.20647-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

There are some workloads where READ_PLUS might end up hurting
performance, so let's be nice to users and provide a way to disable this
operation similar to how READDIR_PLUS can be disabled.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4client.c       |  3 +++
 fs/nfs/super.c            | 21 +++++++++++++++++++++
 include/linux/nfs4.h      |  4 ++--
 include/linux/nfs_fs_sb.h |  1 +
 4 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 2548405da1f7..2bb603d1a80f 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -998,6 +998,9 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 	server->caps |= server->nfs_client->cl_mvops->init_caps;
 	if (server->flags & NFS_MOUNT_NORDIRPLUS)
 			server->caps &= ~NFS_CAP_READDIRPLUS;
+	if (server->options & NFS_OPTION_NO_READ_PLUS)
+		server->caps &= ~NFS_CAP_READ_PLUS;
+
 	/*
 	 * Don't use NFS uid/gid mapping if we're using AUTH_SYS or lower
 	 * authentication.
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0570391eaa16..5b8701fca5b9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -90,6 +90,7 @@ enum {
 	Opt_resvport, Opt_noresvport,
 	Opt_fscache, Opt_nofscache,
 	Opt_migration, Opt_nomigration,
+	Opt_readplus, Opt_noreadplus,
 
 	/* Mount options that take integer arguments */
 	Opt_port,
@@ -151,6 +152,8 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_nofscache, "nofsc" },
 	{ Opt_migration, "migration" },
 	{ Opt_nomigration, "nomigration" },
+	{ Opt_readplus, "readplus" },
+	{ Opt_noreadplus, "noreadplus" },
 
 	{ Opt_port, "port=%s" },
 	{ Opt_rsize, "rsize=%s" },
@@ -690,6 +693,11 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	if (nfss->options & NFS_OPTION_MIGRATION)
 		seq_printf(m, ",migration");
 
+	if (nfss->options & NFS_OPTION_NO_READ_PLUS)
+		seq_printf(m,",noreadplus");
+	else
+		seq_printf(m,",readplus");
+
 	if (nfss->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG) {
 		if (nfss->flags & NFS_MOUNT_LOOKUP_CACHE_NONE)
 			seq_printf(m, ",lookupcache=none");
@@ -1324,6 +1332,12 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_nomigration:
 			mnt->options &= ~NFS_OPTION_MIGRATION;
 			break;
+		case Opt_readplus:
+			mnt->options &= ~NFS_OPTION_NO_READ_PLUS;
+			break;
+		case Opt_noreadplus:
+			mnt->options |= NFS_OPTION_NO_READ_PLUS;
+			break;
 
 		/*
 		 * options that take numeric values
@@ -1626,6 +1640,9 @@ static int nfs_parse_mount_options(char *raw,
 	if (mnt->options & NFS_OPTION_MIGRATION &&
 	    (mnt->version != 4 || mnt->minorversion != 0))
 		goto out_migration_misuse;
+	if (mnt->options & NFS_OPTION_NO_READ_PLUS &&
+	    (mnt->version != 4 || mnt->minorversion < 2))
+		goto out_noreadplus_misuse;
 
 	/*
 	 * verify that any proto=/mountproto= options match the address
@@ -1668,6 +1685,10 @@ static int nfs_parse_mount_options(char *raw,
 	printk(KERN_INFO
 		"NFS: 'migration' not supported for this NFS version\n");
 	return 0;
+out_noreadplus_misuse:
+	printk(KERN_INFO
+		"NFS: 'noreadplus' not supported for this NFS version\n");
+	return 0;
 out_nomem:
 	printk(KERN_INFO "NFS: not enough memory to parse option\n");
 	return 0;
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index db465ad6659b..2fd3cf2061c2 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -535,10 +535,10 @@ enum {
 	NFSPROC4_CLNT_LAYOUTSTATS,
 	NFSPROC4_CLNT_CLONE,
 	NFSPROC4_CLNT_COPY,
-	NFSPROC4_CLNT_OFFLOAD_CANCEL,
-	NFSPROC4_CLNT_READ_PLUS,
 
 	NFSPROC4_CLNT_LOOKUPP,
+	NFSPROC4_CLNT_OFFLOAD_CANCEL,
+	NFSPROC4_CLNT_READ_PLUS,
 };
 
 /* nfs41 types */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index e431c2a7affd..c95be09b84f1 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -157,6 +157,7 @@ struct nfs_server {
 	unsigned int		clone_blksize;	/* granularity of a CLONE operation */
 #define NFS_OPTION_FSCACHE	0x00000001	/* - local caching enabled */
 #define NFS_OPTION_MIGRATION	0x00000002	/* - NFSv4 migration enabled */
+#define NFS_OPTION_NO_READ_PLUS	0x00000004	/* - NFSv4.2 READ_PLUS enabled */
 
 	struct nfs_fsid		fsid;
 	__u64			maxfilesize;	/* maximum file size */
-- 
2.20.1

