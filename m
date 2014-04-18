Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:62452 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbaDRSpM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:12 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so1902016iec.4
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:11 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 04/70] NFSd: Remove 'inline' designation for free_client()
Date: Fri, 18 Apr 2014 14:43:58 -0400
Message-Id: <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is large, it is used in more than one place, and it is not performance
critical. Let gcc figure out whether it should be inlined...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 32b699bebb9c..841495aa9170 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1093,7 +1093,7 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 	return clp;
 }
 
-static inline void
+static void
 free_client(struct nfs4_client *clp)
 {
 	struct nfsd_net __maybe_unused *nn = net_generic(clp->net, nfsd_net_id);
-- 
1.9.0

