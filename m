Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:56277 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757867AbaFSOwv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:51 -0400
Received: by mail-qa0-f50.google.com with SMTP id m5so2075838qaj.9
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:51 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 079/104] nfsd: fix misleading comment
Date: Thu, 19 Jun 2014 10:50:25 -0400
Message-Id: <1403189450-18729-80-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...the client_lock now protects this.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cfb090b9bb21..bff26c3d306f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2346,7 +2346,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	cs_slot->sl_seqid++;
 	cr_ses->seqid = cs_slot->sl_seqid;
 
-	/* cache solo and embedded create sessions under the state lock */
+	/* cache solo and embedded create sessions under the client_lock */
 	nfsd4_cache_create_session(cr_ses, cs_slot, status);
 	spin_unlock(&nn->client_lock);
 	/* init connection and backchannel */
-- 
1.9.3

