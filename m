Return-Path: <SRS0=VKO3=OY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9A3FC43612
	for <linux-nfs@archiver.kernel.org>; Sat, 15 Dec 2018 07:15:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AEE4D21721
	for <linux-nfs@archiver.kernel.org>; Sat, 15 Dec 2018 07:15:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ttCFOX6w"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729245AbeLOHO5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 15 Dec 2018 02:14:57 -0500
Received: from mail-pg1-f196.google.com ([209.85.215.196]:44581 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728675AbeLOHO4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Dec 2018 02:14:56 -0500
Received: by mail-pg1-f196.google.com with SMTP id t13so3702123pgr.11;
        Fri, 14 Dec 2018 23:14:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=7WhZFtyQPupUrhseVxS4U/IqOGv8mntZLgJcYp7oNsk=;
        b=ttCFOX6wwWoUKn29kfFk/YFShXgy//Ic7+dIRBDzVfiylXFRoK7q6WoVeKuyJKvdMB
         Hg5rB7j/xzg4EXrRzghwAfdDSD85HySQMiE1offC+wBX9bFaHMwlLTZiGaNIRBvB3bTv
         LDTg0NgP/Cvc7qMskJGB9MXN3owdcQ++ei4cXECO23BR/fTT93IiOwY/mQYA2QD8axaY
         ScqUBirgNMF5w8KsE+L2yRaJ0Uzl6usCiysGBEpA2hjYJal1fNunxFp1Fz8lkCbNfli3
         YSSXNglZTLi6WMBUedc78xYO0wxYEmHUoSUVjU/LFDRn/hpFGRErn5t4fD2eFulMPa5K
         MBFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=7WhZFtyQPupUrhseVxS4U/IqOGv8mntZLgJcYp7oNsk=;
        b=BG1CqqQ5HBNSRD52nL+BxO4yHbTKEMnuFsHgIUqkOHuNn20pftOX3PQodzuyejsWZn
         LgtQRNjelHlDrH1uqst1vgEsPhskpmqI5lh5UkFm6yiSD/ACH7QT4A1t3zIYfYzRI/HF
         JhzJOIW3yXkMUSGn2weea5j1oTuzpXXsRlkxZ67hVn4S8ea2xb5MbAZj4/aJyX+FrebH
         kZI3vV6Je9ZpVHJCLPKqV0PEoAOve4t5kpTqPNvqBOWpEv2OcG45INZUzOLkDyz47UMO
         9DA2Wj7lhFChLYSWZ3bsXXADOEaVGAdVldLWRVJzWU9XKfElwkY5EkirefvQYrUHxSep
         E/NQ==
X-Gm-Message-State: AA+aEWaFH4aNAV3gPuKFCp5cmiMKvE4WsIydr+eX98bGBLxFPut5dgwV
        4UBA4pvVri2nZ6w22A8iTCCl+z/Ppbg=
X-Google-Smtp-Source: AFSGD/Utr4KGtV8Lc3OOVFpRN6U14NuBB03Mb//0nJeTjhP2+QvsQZzph2Hb178BvjAogeSvKBo/3w==
X-Received: by 2002:a63:e915:: with SMTP id i21mr5111316pgh.409.1544858094929;
        Fri, 14 Dec 2018 23:14:54 -0800 (PST)
Received: from localhost (68.168.130.77.16clouds.com. [68.168.130.77])
        by smtp.gmail.com with ESMTPSA id y5sm9212549pge.49.2018.12.14.23.14.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 14 Dec 2018 23:14:53 -0800 (PST)
From:   Yangtao Li <tiny.windzz@gmail.com>
To:     bfields@fieldses.org, jlayton@kernel.org,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        davem@davemloft.net
Cc:     linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Yangtao Li <tiny.windzz@gmail.com>
Subject: [PATCH] sunrpc: convert to DEFINE_SHOW_ATTRIBUTE
Date:   Sat, 15 Dec 2018 02:14:51 -0500
Message-Id: <20181215071451.25752-1-tiny.windzz@gmail.com>
X-Mailer: git-send-email 2.17.0
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Use DEFINE_SHOW_ATTRIBUTE macro to simplify the code.

Signed-off-by: Yangtao Li <tiny.windzz@gmail.com>
---
 net/sunrpc/rpc_pipe.c | 19 +++----------------
 net/sunrpc/stats.c    | 14 +-------------
 2 files changed, 4 insertions(+), 29 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 4fda18d47e2c..69663681bf9d 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1266,7 +1266,7 @@ static const struct rpc_pipe_ops gssd_dummy_pipe_ops = {
  * that this file will be there and have a certain format.
  */
 static int
-rpc_show_dummy_info(struct seq_file *m, void *v)
+rpc_dummy_info_show(struct seq_file *m, void *v)
 {
 	seq_printf(m, "RPC server: %s\n", utsname()->nodename);
 	seq_printf(m, "service: foo (1) version 0\n");
@@ -1275,25 +1275,12 @@ rpc_show_dummy_info(struct seq_file *m, void *v)
 	seq_printf(m, "port: 0\n");
 	return 0;
 }
-
-static int
-rpc_dummy_info_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, rpc_show_dummy_info, NULL);
-}
-
-static const struct file_operations rpc_dummy_info_operations = {
-	.owner		= THIS_MODULE,
-	.open		= rpc_dummy_info_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= single_release,
-};
+DEFINE_SHOW_ATTRIBUTE(rpc_dummy_info);
 
 static const struct rpc_filelist gssd_dummy_info_file[] = {
 	[0] = {
 		.name = "info",
-		.i_fop = &rpc_dummy_info_operations,
+		.i_fop = &rpc_dummy_info_fops,
 		.mode = S_IFREG | 0400,
 	},
 };
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 71166b393732..d064fcec0b2e 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -62,19 +62,7 @@ static int rpc_proc_show(struct seq_file *seq, void *v) {
 	}
 	return 0;
 }
-
-static int rpc_proc_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, rpc_proc_show, PDE_DATA(inode));
-}
-
-static const struct file_operations rpc_proc_fops = {
-	.owner = THIS_MODULE,
-	.open = rpc_proc_open,
-	.read  = seq_read,
-	.llseek = seq_lseek,
-	.release = single_release,
-};
+DEFINE_SHOW_ATTRIBUTE(rpc_proc);
 
 /*
  * Get RPC server stats
-- 
2.17.0

