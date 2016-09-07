Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33792 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935248AbcIGSB4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Sep 2016 14:01:56 -0400
Received: by mail-it0-f65.google.com with SMTP id e124so2160672ith.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Sep 2016 11:01:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/7] NFSv4.1: Don't check delegations that are already marked as revoked
Date: Wed,  7 Sep 2016 14:01:21 -0400
Message-Id: <1473271287-43478-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473271287-43478-1-git-send-email-trond.myklebust@primarydata.com>
References: <1473271287-43478-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the delegation has been marked as revoked, we don't have to test
it, because we should already have called FREE_STATEID on it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 25a2af707233..2728ef288a0f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2420,6 +2420,11 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 		rcu_read_unlock();
 		return;
 	}
+	if (test_bit(NFS_DELEGATION_REVOKED, &delegation->flags)) {
+		rcu_read_unlock();
+		nfs_finish_clear_delegation_stateid(state);
+		return;
+	}
 
 	nfs4_stateid_copy(&stateid, &delegation->stateid);
 	cred = get_rpccred(delegation->cred);
-- 
2.7.4

