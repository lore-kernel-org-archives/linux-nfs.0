Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:54249 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754747AbaG3M2d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:33 -0400
Received: by mail-qg0-f42.google.com with SMTP id j5so1308805qga.15
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:32 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 34/37] nfsd: remove nfs4_lock_state: nfs4_laundromat
Date: Wed, 30 Jul 2014 08:27:35 -0400
Message-Id: <1406723258-8512-35-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d98d33d0e304..7eea82e1d779 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4148,8 +4148,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 	time_t cutoff = get_seconds() - nn->nfsd4_lease;
 	time_t t, new_timeo = nn->nfsd4_lease;
 
-	nfs4_lock_state();
-
 	dprintk("NFSD: laundromat service - starting\n");
 	nfsd4_end_grace(nn);
 	INIT_LIST_HEAD(&reaplist);
@@ -4217,7 +4215,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 	spin_unlock(&nn->client_lock);
 
 	new_timeo = max_t(time_t, new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
-	nfs4_unlock_state();
 	return new_timeo;
 }
 
-- 
1.9.3

