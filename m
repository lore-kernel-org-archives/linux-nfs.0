Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:47900 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314AbaF3PzY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:55:24 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so7367546qcy.29
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:55:24 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 111/114] nfsd: remove nfs4_lock_state: nfs4_laundromat
Date: Mon, 30 Jun 2014 11:54:58 -0400
Message-Id: <1404143701-24740-13-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 740f4ea47d48..5d3c4679d48d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4115,8 +4115,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 	time_t cutoff = get_seconds() - nn->nfsd4_lease;
 	time_t t, new_timeo = nn->nfsd4_lease;
 
-	nfs4_lock_state();
-
 	dprintk("NFSD: laundromat service - starting\n");
 	nfsd4_end_grace(nn);
 	INIT_LIST_HEAD(&reaplist);
@@ -4184,7 +4182,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 	spin_unlock(&nn->client_lock);
 
 	new_timeo = max_t(time_t, new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
-	nfs4_unlock_state();
 	return new_timeo;
 }
 
-- 
1.9.3

