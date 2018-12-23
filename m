Return-Path: <SRS0=dMO4=PA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B864C43387
	for <linux-nfs@archiver.kernel.org>; Sun, 23 Dec 2018 09:35:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 317CD218FD
	for <linux-nfs@archiver.kernel.org>; Sun, 23 Dec 2018 09:35:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727368AbeLWJet (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 23 Dec 2018 04:34:49 -0500
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:44311
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727336AbeLWJeE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Dec 2018 04:34:04 -0500
X-IronPort-AV: E=Sophos;i="5.56,386,1539640800"; 
   d="scan'208";a="289991780"
Received: from palace.lip6.fr ([132.227.105.202])
  by mail3-relais-sop.national.inria.fr with ESMTP/TLS/AES128-SHA256; 23 Dec 2018 10:33:55 +0100
From:   Julia Lawall <Julia.Lawall@lip6.fr>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     kernel-janitors@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 15/20] NFS: drop useless LIST_HEAD
Date:   Sun, 23 Dec 2018 09:57:10 +0100
Message-Id: <1545555435-24576-16-git-send-email-Julia.Lawall@lip6.fr>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <1545555435-24576-1-git-send-email-Julia.Lawall@lip6.fr>
References: <1545555435-24576-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Drop LIST_HEAD where the variable it declares has never
been used.

The semantic patch that fixes this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier x;
@@
- LIST_HEAD(x);
  ... when != x
// </smpl>

Fixes: 0e20162ed1e9 ("NFSv4.1 Use MDS auth flavor for data server connection")
Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
Successfully 0-day tested on 151 configurations.

 fs/nfs/nfs4client.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 2548405da1f7..735c1056a91c 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -145,7 +145,6 @@ static void
 nfs4_shutdown_ds_clients(struct nfs_client *clp)
 {
 	struct nfs4_ds_server *dss;
-	LIST_HEAD(shutdown_list);
 
 	while (!list_empty(&clp->cl_ds_clients)) {
 		dss = list_entry(clp->cl_ds_clients.next,

