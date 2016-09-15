Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33330 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751861AbcIOQqP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 12:46:15 -0400
Received: by mail-it0-f66.google.com with SMTP id x192so5063656itb.0
        for <linux-nfs@vger.kernel.org>; Thu, 15 Sep 2016 09:46:14 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v4 08/20] NFSv4.1: Don't recheck delegations that have already been checked
Date: Thu, 15 Sep 2016 12:45:48 -0400
Message-Id: <1473957960-10001-9-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473957960-10001-8-git-send-email-trond.myklebust@primarydata.com>
References: <1473957960-10001-1-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-2-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-3-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-4-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-5-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-6-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-7-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-8-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure we don't spam the server with test_stateid() calls for
delegations that have already been checked.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3552f3a4ceb0..97a614370604 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2459,6 +2459,11 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
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

