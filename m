Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gateway34.websitewelcome.com ([192.185.148.204]:25214 "EHLO
        gateway34.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726145AbeHAEbw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 00:31:52 -0400
Received: from cm14.websitewelcome.com (cm14.websitewelcome.com [100.42.49.7])
        by gateway34.websitewelcome.com (Postfix) with ESMTP id 0A5DA135D21
        for <linux-nfs@vger.kernel.org>; Tue, 31 Jul 2018 21:24:29 -0500 (CDT)
Date: Tue, 31 Jul 2018 21:24:10 -0500
From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] nfsd: Mark expected switch fall-through
Message-ID: <20180801022410.GA21621@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Warning level 2 was used: -Wimplicit-fallthrough=2

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 fs/nfsd/nfs4callback.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 2a979aa9..5dd56e9 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1078,6 +1078,7 @@ static bool nfsd4_cb_sequence_done(struct rpc_task *task, struct nfsd4_callback
 		break;
 	case -ESERVERFAULT:
 		++session->se_cb_seq_nr;
+		/* Fall through */
 	case 1:
 	case -NFS4ERR_BADSESSION:
 		nfsd4_mark_cb_fault(cb->cb_clp, cb->cb_seq_status);
-- 
2.7.4

