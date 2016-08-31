Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35624 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758117AbcHaCMS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2016 22:12:18 -0400
Received: by mail-it0-f67.google.com with SMTP id f128so4119829ith.2
        for <linux-nfs@vger.kernel.org>; Tue, 30 Aug 2016 19:12:18 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 7/7] NFSv4.1: Don't recheck delegations that have already been checked
Date: Tue, 30 Aug 2016 22:11:44 -0400
Message-Id: <1472609504-69094-8-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472609504-69094-7-git-send-email-trond.myklebust@primarydata.com>
References: <1472609504-69094-1-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-2-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-3-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-4-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-5-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-6-git-send-email-trond.myklebust@primarydata.com>
 <1472609504-69094-7-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure we don't spam the server with test_stateid() calls for
delegations that have already been checked.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 412f1daf1515..9c8c7400b048 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2456,6 +2456,11 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 		return;
 	}
 
+	if (!test_and_clear_bit(NFS_DELEGATION_TEST_EXPIRED, &delegation->flags)) {
+		rcu_read_unlock();
+		return;
+	}
+
 	cred = get_rpccred(delegation->cred);
 	rcu_read_unlock();
 	status = nfs41_test_and_free_expired_stateid(server, &stateid, cred);
-- 
2.7.4

