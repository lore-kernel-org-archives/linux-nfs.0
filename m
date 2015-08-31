Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35578 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631AbbHaJII (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Aug 2015 05:08:08 -0400
Received: by pacdd16 with SMTP id dd16so133078613pac.2
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2015 02:08:08 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] NFSv4.1/pnfs: Handle LAYOUTGET return values correctly
Date: Mon, 31 Aug 2015 02:08:04 -0700
Message-Id: <1441012085-4071-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1441012085-4071-1-git-send-email-trond.myklebust@primarydata.com>
References: <1441012085-4071-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to RFC5661 section 18.43.3, if the server cannot satisfy
the loga_minlength argument to LAYOUTGET, there are 2 cases:
1) If loga_minlength == 0, it returns NFS4ERR_LAYOUTTRYLATER
2) If loga_minlength != 0, it returns NFS4ERR_BADLAYOUT

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 366b81c185f6..51c7164abd1a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7781,10 +7781,19 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 	case 0:
 		goto out;
 	/*
+	 * NFS4ERR_BADLAYOUT means the MDS cannot return a layout of
+	 * length lgp->args.minlength != 0 (see RFC5661 section 18.43.3).
+	 */
+	case -NFS4ERR_BADLAYOUT:
+		goto out_overflow;
+	/*
 	 * NFS4ERR_LAYOUTTRYLATER is a conflict with another client
-	 * (or clients) writing to the same RAID stripe
+	 * (or clients) writing to the same RAID stripe except when
+	 * the minlength argument is 0 (see RFC5661 section 18.43.3).
 	 */
 	case -NFS4ERR_LAYOUTTRYLATER:
+		if (lgp->args.minlength == 0)
+			goto out_overflow;
 	/*
 	 * NFS4ERR_RECALLCONFLICT is when conflict with self (must recall
 	 * existing layout before getting a new one).
@@ -7840,6 +7849,10 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 		rpc_restart_call_prepare(task);
 out:
 	dprintk("<-- %s\n", __func__);
+	return;
+out_overflow:
+	task->tk_status = -EOVERFLOW;
+	goto out;
 }
 
 static size_t max_response_pages(struct nfs_server *server)
-- 
2.4.3

