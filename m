Return-Path: <SRS0=MwxH=TQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C9BDC04E87
	for <linux-nfs@archiver.kernel.org>; Thu, 16 May 2019 01:48:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2A02D20873
	for <linux-nfs@archiver.kernel.org>; Thu, 16 May 2019 01:48:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727014AbfEPBqh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 15 May 2019 21:46:37 -0400
Received: from fieldses.org ([173.255.197.46]:33114 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727007AbfEPBWY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 May 2019 21:22:24 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 7D32242A6; Wed, 15 May 2019 21:20:23 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/12] nfsd: copy client's address including port number to cl_addr
Date:   Wed, 15 May 2019 21:20:14 -0400
Message-Id: <1557969619-17157-10-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1557969619-17157-1-git-send-email-bfields@redhat.com>
References: <1557969619-17157-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

rpc_copy_addr() copies only the IP address and misses any port numbers.
It seems potentially useful to keep the port number around too.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 928705fc8ff5..c665ce9af773 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2252,7 +2252,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	clp->cl_time = get_seconds();
 	clear_bit(0, &clp->cl_cb_slot_busy);
 	copy_verf(clp, verf);
-	rpc_copy_addr((struct sockaddr *) &clp->cl_addr, sa);
+	memcpy(&clp->cl_addr, sa, sizeof(struct sockaddr_storage));
 	clp->cl_cb_session = NULL;
 	clp->net = net;
 	clp->cl_nfsd_dentry = nfsd_client_mkdir(nn, &clp->cl_nfsdfs,
-- 
2.21.0

