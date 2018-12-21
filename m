Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FROM,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3252C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 15:59:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B376A2186A
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 15:59:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jnV8w7Go"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732949AbeLUP7k (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Dec 2018 10:59:40 -0500
Received: from mail-pf1-f195.google.com ([209.85.210.195]:39819 "EHLO
        mail-pf1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725790AbeLUP7k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Dec 2018 10:59:40 -0500
Received: by mail-pf1-f195.google.com with SMTP id r136so2788381pfc.6;
        Fri, 21 Dec 2018 07:59:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=b4QMVIFnu/wPy9wSuVjCTg+3yl01InF46U8GU3EgkT4=;
        b=jnV8w7GoCozMs092ZGWlfN4MQLvnXokT1dO57ujCuVu8i86E+67jcOs/kHZZxiu/J3
         OlFs0Y+ApFUfvDuUhd56RqNoxQtT7KLDlTtA6s0ZbaTPasWDUcQ/YuBrGK0uzXVTbVi1
         Hq/zenI1896wqpEGWJSg0lzilUv+W2xJtZqG5WntZ2X9sRdxuky2r9ma46YEwlpybE/O
         aPwOtwPERV0AiQL+BCvB4ey/IRq+jTpFDGOVhSIjwmUvMCJhcgZ+VM3Db33jIEOfPKmH
         RCJrsKoLtHfs5Vv+U7SRVdTIXm/APDZA+3bGZEhAD3XBSE7WH8QYR6nfdrevcFICBEei
         GUBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=b4QMVIFnu/wPy9wSuVjCTg+3yl01InF46U8GU3EgkT4=;
        b=murPejmkHBfWktvcV8yQc2lXLb+TsKoxFXeqE0iVxd/7yxoFNHcSpTVGZst1r8TDQI
         EkEtyxg9xGDmHLGqATZ87ZblYVAbr3BDaOfPSn1Dnd0pjtRGoGACuJgZ9UFDQ9vesMsn
         AzVlZAyxm3iyO6aquHN32aw+qip3E0VEi2fzmOHNlZALBX4M/rRpoYx8CN7biNlpkDlD
         O2JMQFytobRpvotw4DQi/AzV985QITu6gS3WDpbO0Uguf8KmOsIjRVpb31txTK7CCcNR
         0gwHmYorez4HYhbmorf42E0wyJMtC+IzfIrLYJQP4NfQf2fexA+Cg6DjwiTH+cDjw9Ky
         ZQEA==
X-Gm-Message-State: AJcUukfdSKuLz6ZZnZd8yMLN/vHQCXyWmmPTKJFwBtxM5To+5W01wuQX
        uHMgh+zL9RqxkEdf82/bl8g=
X-Google-Smtp-Source: ALg8bN6qn1Vhr8KKvu1q61brkc7Lb/qBZ+3HoAZafQKeFiL+81AVPzx0Y3jScRaN3uj1Lg9y8005hw==
X-Received: by 2002:a65:6148:: with SMTP id o8mr2887188pgv.451.1545407979918;
        Fri, 21 Dec 2018 07:59:39 -0800 (PST)
Received: from localhost (68.168.130.77.16clouds.com. [68.168.130.77])
        by smtp.gmail.com with ESMTPSA id n186sm33204531pfn.137.2018.12.21.07.59.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Dec 2018 07:59:39 -0800 (PST)
From:   Yangtao Li <tiny.windzz@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, jlayton@kernel.org, davem@davemloft.net
Cc:     linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Yangtao Li <tiny.windzz@gmail.com>
Subject: [RESNED] sunrpc: convert to DEFINE_SHOW_ATTRIBUTE
Date:   Fri, 21 Dec 2018 10:59:36 -0500
Message-Id: <20181221155936.32638-1-tiny.windzz@gmail.com>
X-Mailer: git-send-email 2.17.0
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Use DEFINE_SHOW_ATTRIBUTE macro to simplify the code.

Signed-off-by: Yangtao Li <tiny.windzz@gmail.com>
---
 net/sunrpc/rpc_pipe.c | 19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

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
-- 
2.17.0

