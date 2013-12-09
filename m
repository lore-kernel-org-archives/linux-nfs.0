Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f173.google.com ([209.85.215.173]:52344 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761328Ab3LIRFt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Dec 2013 12:05:49 -0500
Received: by mail-ea0-f173.google.com with SMTP id o10so1709241eaj.32
        for <linux-nfs@vger.kernel.org>; Mon, 09 Dec 2013 09:05:47 -0800 (PST)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH] nfsd4: fix printk format string in nfsd4_open
Date: Mon,  9 Dec 2013 19:05:43 +0200
Message-Id: <1386608743-23718-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0a964f1..8624bee 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -361,7 +361,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	dprintk("NFSD: nfsd4_open filename %.*s op_openowner %p\n",
+	dprintk("NFSD: nfsd4_open filename %*s op_openowner %p\n",
 		(int)open->op_fname.len, open->op_fname.data,
 		open->op_openowner);
 
-- 
1.8.3.1

