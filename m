Return-Path: <SRS0=AtwM=YK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65D18ECE597
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Oct 2019 17:38:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4105221835
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Oct 2019 17:38:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XEMba55B"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2503068AbfJQRiC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Oct 2019 13:38:02 -0400
Received: from mail-qk1-f196.google.com ([209.85.222.196]:41630 "EHLO
        mail-qk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2503066AbfJQRiB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2019 13:38:01 -0400
Received: by mail-qk1-f196.google.com with SMTP id p10so2644712qkg.8
        for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2019 10:38:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=KzDd/kJUTTdo9b021DqcVeh+HNqCV73bsFYcXsRARMs=;
        b=XEMba55BuJu9UP9MZ+IfCVR1exBQAtiuZJReVEy5NurmLn4gZuX1pltEKMRcBOwNGj
         s8EQevCagnyxKfrxOa66xF9vVeaSNX4dGeuxzqxTFTwDC3P9aXVEUh0Cm2m1E73sq+jG
         WaYeVmVrhh42iHiVTp0m0QnRhLYnXZoZu6JLVSIUV878y8NexZjvOQFHPZLNwI1WbvdX
         1P4YYlSTyS5ZmgUjjOAZBoMoNP2ufCtE80YQRNOuDxdmNi/6+b7+45+eH216vJfL/HVC
         VNgYYueWebW3gH6hLBvE1Glui34SdDe9dgCvwlT2M/LLjGSTg2N45GpM+MxtTFgBO1uv
         T8uw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=KzDd/kJUTTdo9b021DqcVeh+HNqCV73bsFYcXsRARMs=;
        b=WImhTUEGcuj8hbKCQLGBW5nDhQlttoiW49KjHoEUSwhgFz1ane+DgkR7g4kLde1k4z
         sf5+ZShBPj8EvCbDhZwIWx+nA94xM6njxixkda+4Dx9GanUdlsUWeVrlCmWwLghTcqUm
         t+OTwckZu+CjY048LRxPXdDCGaTyj3VZgPnmqy3f/UkUeqVngrPHHApCCP8gYFxrR6p/
         ku3vDCakwSuam4W+DZKXARS58CS0NWbhsZO+97a/n3orFNGGs3142tDv+wZmBExovMaQ
         E+XW49boX+rkWy8YjfCNq21JxZWAEKCqnAUWoWfXhe0l1UMN7T8aVFsIw7tlvUby3CFw
         F44Q==
X-Gm-Message-State: APjAAAXQkREdCM0PEWQW39loGt38pOZO+3QvtjHAzwgACB4iNEtU0Pcd
        KmyZtI1y7uRXNWDZS7qQV7gjKsc=
X-Google-Smtp-Source: APXvYqwW9lnITBJdZ8T/alis1aUWOcp4/t+HkR6BqKk2PEAEXhWu5nC94Lo+IkYJsFrNZZL5BnSz6Q==
X-Received: by 2002:a37:68e:: with SMTP id 136mr4404009qkg.211.1571333879699;
        Thu, 17 Oct 2019 10:37:59 -0700 (PDT)
Received: from localhost.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id l185sm1768610qkd.20.2019.10.17.10.37.57
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 17 Oct 2019 10:37:58 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFS: Use non-atomic bit ops when initialising struct nfs_client_initdata
Date:   Thu, 17 Oct 2019 13:35:44 -0400
Message-Id: <20191017173548.105111-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We don't need atomic bit ops when initialising a local structure on the
stack.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs3client.c | 2 +-
 fs/nfs/nfs4client.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index 148ceb74d27c..178dc102442f 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -106,7 +106,7 @@ struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 		cl_init.nconnect = mds_clp->cl_nconnect;
 
 	if (mds_srv->flags & NFS_MOUNT_NORESVPORT)
-		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
+		__set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
 
 	/* Use the MDS nfs_client cl_ipaddr. */
 	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index da6204025a2d..ebc960dd89ff 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -882,11 +882,11 @@ static int nfs4_set_client(struct nfs_server *server,
 	if (minorversion > 0 && proto == XPRT_TRANSPORT_TCP)
 		cl_init.nconnect = nconnect;
 	if (server->flags & NFS_MOUNT_NORESVPORT)
-		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
+		__set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
 	if (server->options & NFS_OPTION_MIGRATION)
-		set_bit(NFS_CS_MIGRATION, &cl_init.init_flags);
+		__set_bit(NFS_CS_MIGRATION, &cl_init.init_flags);
 	if (test_bit(NFS_MIG_TSM_POSSIBLE, &server->mig_status))
-		set_bit(NFS_CS_TSM_POSSIBLE, &cl_init.init_flags);
+		__set_bit(NFS_CS_TSM_POSSIBLE, &cl_init.init_flags);
 	server->port = rpc_get_port(addr);
 
 	/* Allocate or find a client reference we can use */
-- 
2.21.0

