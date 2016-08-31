Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35599 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757620AbcHaCMO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2016 22:12:14 -0400
Received: by mail-it0-f68.google.com with SMTP id f128so4119528ith.2
        for <linux-nfs@vger.kernel.org>; Tue, 30 Aug 2016 19:12:13 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/7] NFSv4.1: Don't check delegations that are already marked as revoked
Date: Tue, 30 Aug 2016 22:11:38 -0400
Message-Id: <1472609504-69094-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472609504-69094-1-git-send-email-trond.myklebust@primarydata.com>
References: <1472609504-69094-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the delegation has been marked as revoked, we don't have to test
it, because we should already have called FREE_STATEID on it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e924907cccef..255800b12fad 100644
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

