Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34645 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754255AbcIISEv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2016 14:04:51 -0400
Received: by mail-oi0-f65.google.com with SMTP id a144so3250371oii.1
        for <linux-nfs@vger.kernel.org>; Fri, 09 Sep 2016 11:04:51 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v3 08/12] NFSv4.1: Don't recheck delegations that have already been checked
Date: Fri,  9 Sep 2016 14:04:09 -0400
Message-Id: <1473444253-12433-9-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473444253-12433-8-git-send-email-trond.myklebust@primarydata.com>
References: <1473444253-12433-1-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-2-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-3-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-4-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-5-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-6-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-7-git-send-email-trond.myklebust@primarydata.com>
 <1473444253-12433-8-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure we don't spam the server with test_stateid() calls for
delegations that have already been checked.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 74dd9157539a..6cae73a08ba0 100644
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

