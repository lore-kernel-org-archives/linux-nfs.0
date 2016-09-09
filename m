Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:33711 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752196AbcIISEn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2016 14:04:43 -0400
Received: by mail-oi0-f67.google.com with SMTP id y2so7217973oie.0
        for <linux-nfs@vger.kernel.org>; Fri, 09 Sep 2016 11:04:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v3 02/12] NFSv4.1: Don't check delegations that are already marked as revoked
Date: Fri,  9 Sep 2016 14:04:03 -0400
Message-Id: <1473444253-12433-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473444253-12433-2-git-send-email-trond.myklebust@primarydata.com>
References: <1473444253-12433-1-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the delegation has been marked as revoked, we don't have to test
it, because we should already have called FREE_STATEID on it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bd33777f03c4..254ab545c391 100644
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

