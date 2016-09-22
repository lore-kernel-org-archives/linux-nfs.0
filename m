Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36009 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964779AbcIVRjh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:39:37 -0400
Received: by mail-it0-f67.google.com with SMTP id n143so5336167ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:39:32 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 05/31] NFSv4.1: Don't check delegations that are already marked as revoked
Date: Thu, 22 Sep 2016 13:38:55 -0400
Message-Id: <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the delegation has been marked as revoked, we don't have to test
it, because we should already have called FREE_STATEID on it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6b700c59eede..a026156434ae 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2423,6 +2423,11 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
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

