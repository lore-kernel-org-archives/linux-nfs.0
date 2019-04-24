Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F3FAC282CE
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4CB3420811
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:49:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vfjUKByE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730678AbfDXVtD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 17:49:03 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:37567 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730434AbfDXVtD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 17:49:03 -0400
Received: by mail-it1-f196.google.com with SMTP id u65so8862857itc.2
        for <linux-nfs@vger.kernel.org>; Wed, 24 Apr 2019 14:49:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=R63oqmCe/PAVwiH1GBW3mRb97Dqey6ZDltfdJjAD2iE=;
        b=vfjUKByEL5ryIKkoFjHVsjIHe6UbyiuAnB25VPTuG+eJxnd+r2rTLivC43Njnw9/EC
         nJTsAKyawXgyuEG9Hm9QnJ2GDao73uKVbf0JcaRFdI+yC6guzK/eFRqIgc6qD8odUqbE
         29kwuj0969tRtxLh+7Wzh3UUw8nkcEZjnsSy45zilGvlqqWi114RMsZKX011kgXLQkuP
         dUOfpVqXcxsW/19saEZRFjLrnSsdMyUHKpvonynOmEri1YkjMGWTAZkbVxG+oFnU20uu
         d47G5QxBy2Va/bVdNDsaaKZYcrxYH8sbv35qWoiQNf0YuEv+mKg2hcd5otKII4dUHpOh
         vsMQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=R63oqmCe/PAVwiH1GBW3mRb97Dqey6ZDltfdJjAD2iE=;
        b=kihpNKhn3GhPMi/BGUraEUbRcT9hZ5nG9PC1+PX8ahEmIQDK55D7dL6kEMTG25XHY3
         n62HJrn2qZ+QxEOQrH9nTE3cXRDgr4SBo+Q16RYeZRGFDWD1McDu24BNfL9LPzNy+ieU
         kidESrCVg1HVDG008ipBEBY/XmOU+L5viB6NcbrMvAhrlrBWsQegsQJ6n06qHI+CKkeL
         HR9xoIBP/v2S5G6Qpv/Muy3sWvA7LQYDDuw3oYfv8NeruOHRM99rVjjyBIGpTVIfHA3c
         ITBjXpnpPQMUzH+0BxapRCuy4Wy7GlXTLLdLzu7HiN+ocBIEcOsbiOTOSsaBFx6f/JJz
         CUBw==
X-Gm-Message-State: APjAAAUIERb1xs0q757ogCri2ZskC7nYw2+ungPXqh5o8gRD3rRocPm1
        cvWPO+BhD851ItcpgTTyyEosYgA=
X-Google-Smtp-Source: APXvYqwnfxRw2U4/Pvuppn0jekDcytuxDWmBvZp81/flJfg4Jh5M8k4DKRQXQe0zTU8FsPf0dGVDFA==
X-Received: by 2002:a24:7d04:: with SMTP id b4mr1078174itc.73.1556142542240;
        Wed, 24 Apr 2019 14:49:02 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id x10sm9838282ita.4.2019.04.24.14.49.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 14:49:01 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/9] NFS: Store the credential of the mount process in the nfs_server
Date:   Wed, 24 Apr 2019 17:46:43 -0400
Message-Id: <20190424214650.4658-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190424214650.4658-2-trond.myklebust@hammerspace.com>
References: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
 <20190424214650.4658-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Store the credential of the mount process so that we can determine
information such as the user namespace.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/client.c           | 8 +++++++-
 fs/nfs/internal.h         | 1 +
 fs/nfs/nfs3client.c       | 1 +
 fs/nfs/nfs4client.c       | 6 ++++++
 include/linux/nfs_fs_sb.h | 3 +++
 5 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 3ce44d5088a2..d1c003dd7e43 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -500,7 +500,7 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 		.program	= &nfs_program,
 		.version	= clp->rpc_ops->version,
 		.authflavor	= flavor,
-		.cred		= current_cred(),
+		.cred		= cl_init->cred,
 	};
 
 	if (test_bit(NFS_CS_DISCRTRY, &clp->cl_flags))
@@ -653,6 +653,7 @@ static int nfs_init_server(struct nfs_server *server,
 		.proto = data->nfs_server.protocol,
 		.net = data->net,
 		.timeparms = &timeparms,
+		.cred = server->cred,
 	};
 	struct nfs_client *clp;
 	int error;
@@ -921,6 +922,7 @@ void nfs_free_server(struct nfs_server *server)
 	ida_destroy(&server->lockowner_id);
 	ida_destroy(&server->openowner_id);
 	nfs_free_iostats(server->io_stats);
+	put_cred(server->cred);
 	kfree(server);
 	nfs_release_automount_timer();
 }
@@ -941,6 +943,8 @@ struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
+	server->cred = get_cred(current_cred());
+
 	error = -ENOMEM;
 	fattr = nfs_alloc_fattr();
 	if (fattr == NULL)
@@ -1007,6 +1011,8 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
+	server->cred = get_cred(source->cred);
+
 	error = -ENOMEM;
 	fattr_fsinfo = nfs_alloc_fattr();
 	if (fattr_fsinfo == NULL)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c7cf23ae6597..22af82091421 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -84,6 +84,7 @@ struct nfs_client_initdata {
 	u32 minorversion;
 	struct net *net;
 	const struct rpc_timeout *timeparms;
+	const struct cred *cred;
 };
 
 /*
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index 7879f2a0fcfd..1afdb0f7473f 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -91,6 +91,7 @@ struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 		.proto = ds_proto,
 		.net = mds_clp->cl_net,
 		.timeparms = &ds_timeout,
+		.cred = mds_srv->cred,
 	};
 	struct nfs_client *clp;
 	char buf[INET6_ADDRSTRLEN + 1];
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 1339ede979af..3ce246346f02 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -870,6 +870,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		.minorversion = minorversion,
 		.net = net,
 		.timeparms = timeparms,
+		.cred = server->cred,
 	};
 	struct nfs_client *clp;
 
@@ -931,6 +932,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 		.minorversion = minor_version,
 		.net = mds_clp->cl_net,
 		.timeparms = &ds_timeout,
+		.cred = mds_srv->cred,
 	};
 	char buf[INET6_ADDRSTRLEN + 1];
 
@@ -1107,6 +1109,8 @@ struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
+	server->cred = get_cred(current_cred());
+
 	auth_probe = mount_info->parsed->auth_info.flavor_len < 1;
 
 	/* set up the general RPC client */
@@ -1143,6 +1147,8 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	parent_server = NFS_SB(data->sb);
 	parent_client = parent_server->nfs_client;
 
+	server->cred = get_cred(parent_server->cred);
+
 	/* Initialise the client representation from the parent server */
 	nfs_server_copy_userdata(server, parent_server);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index c827d31298cc..add00f12a340 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -231,6 +231,9 @@ struct nfs_server {
 
 	/* XDR related information */
 	unsigned int		read_hdrsize;
+
+	/* User namespace info */
+	const struct cred	*cred;
 };
 
 /* Server capabilities */
-- 
2.21.0

