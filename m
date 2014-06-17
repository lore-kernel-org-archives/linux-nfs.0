Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:59551 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861AbaFQLoX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 07:44:23 -0400
Received: by mail-qc0-f179.google.com with SMTP id x3so8493526qcv.38
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jun 2014 04:44:23 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v2 1/4] nfsd: add __force to opaque verifier field casts
Date: Tue, 17 Jun 2014 07:44:11 -0400
Message-Id: <1403005454-7319-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403005454-7319-1-git-send-email-jlayton@primarydata.com>
References: <1403005454-7319-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sparse complains that we're stuffing non-byte-swapped values into
__be32's here. Since they're supposed to be opaque, it doesn't matter
much. Just add __force to make sparse happy.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4proc.c  | 8 ++++++--
 fs/nfsd/nfs4state.c | 8 ++++++--
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6851b003f2a4..8904c9cbcb89 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -581,8 +581,12 @@ static void gen_boot_verifier(nfs4_verifier *verifier, struct net *net)
 	__be32 verf[2];
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	verf[0] = (__be32)nn->nfssvc_boot.tv_sec;
-	verf[1] = (__be32)nn->nfssvc_boot.tv_usec;
+	/*
+	 * This is opaque to client, so no need to byte-swap. Use
+	 * __force to keep sparse happy
+	 */
+	verf[0] = (__force __be32)nn->nfssvc_boot.tv_sec;
+	verf[1] = (__force __be32)nn->nfssvc_boot.tv_usec;
 	memcpy(verifier->data, verf, sizeof(verifier->data));
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c0d45cec9958..0fea1da3dd24 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1345,8 +1345,12 @@ static void gen_confirm(struct nfs4_client *clp)
 	__be32 verf[2];
 	static u32 i;
 
-	verf[0] = (__be32)get_seconds();
-	verf[1] = (__be32)i++;
+	/*
+	 * This is opaque to client, so no need to byte-swap. Use
+	 * __force to keep sparse happy
+	 */
+	verf[0] = (__force __be32)get_seconds();
+	verf[1] = (__force __be32)i++;
 	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));
 }
 
-- 
1.9.3

