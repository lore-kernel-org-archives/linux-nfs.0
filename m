Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47082 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756122Ab1KIS7C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Nov 2011 13:59:02 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 7/7] NFSv4.1: cleanup comment and debug printk
Date: Wed,  9 Nov 2011 13:58:26 -0500
Message-Id: <1320865106-1791-7-git-send-email-andros@netapp.com>
In-Reply-To: <1320865106-1791-1-git-send-email-andros@netapp.com>
References: <1320865106-1791-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9ec3a13..fe9ad43 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -726,13 +726,10 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 	spin_lock(&tbl->slot_tbl_lock);
 	if (test_bit(NFS4_SESSION_DRAINING, &session->session_state) &&
 	    !rpc_task_has_priority(task, RPC_PRIORITY_PRIVILEGED)) {
-		/*
-		 * The state manager will wait until the slot table is empty.
-		 * Schedule the reset thread
-		 */
+		/* The state manager will wait until the slot table is empty */
 		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
 		spin_unlock(&tbl->slot_tbl_lock);
-		dprintk("%s Schedule Session Reset\n", __func__);
+		dprintk("%s session is draining\n", __func__);
 		return -EAGAIN;
 	}
 
-- 
1.7.6.4

