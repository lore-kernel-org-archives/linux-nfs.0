From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/15] NFSv4.1: Clean up nfs4_setup_sequence
Date: Mon, 14 Jun 2010 17:51:26 -0400
Message-ID: <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53421 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756675Ab0FNVvn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:43 -0400
In-Reply-To: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Firstly, there is little point in first zeroing out the entire struct
nfs4_sequence_res, and then initialising all fields save one. Just
initialise the last field to zero...

Secondly, nfs41_setup_sequence() has only 2 possible return values: 0, or
-EAGAIN, so there is no 'terminate rpc task' case.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bb70ff7..a7a2032 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -480,7 +480,6 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	if (res->sr_slotid != NFS4_MAX_SLOT_TABLE)
 		return 0;
 
-	memset(res, 0, sizeof(*res));
 	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
 	tbl = &session->fc_slot_table;
 
@@ -525,6 +524,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	res->sr_session = session;
 	res->sr_slotid = slotid;
 	res->sr_renewal_time = jiffies;
+	res->sr_status_flags = 0;
 	/*
 	 * sr_status is only set in decode_sequence, and so will remain
 	 * set to 1 if an rpc level failure occurs.
@@ -548,11 +548,6 @@ int nfs4_setup_sequence(struct nfs_client *clp,
 		goto out;
 	ret = nfs41_setup_sequence(clp->cl_session, args, res, cache_reply,
 				   task);
-	if (ret && ret != -EAGAIN) {
-		/* terminate rpc task */
-		task->tk_status = ret;
-		task->tk_action = NULL;
-	}
 out:
 	dprintk("<-- %s status=%d\n", __func__, ret);
 	return ret;
-- 
1.7.0.1

