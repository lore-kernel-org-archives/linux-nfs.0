Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22096 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255Ab2JOVcF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:32:05 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/13] NFSv4: Remove the BUG_ON() from nfs4_get_lease_time_prepare()...
Date: Mon, 15 Oct 2012 17:30:57 -0400
Message-Id: <1350336667-18770-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1350336667-18770-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-3-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An EAGAIN return value would be unexpected, but there is no reason to
BUG...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 68b21d8..16190b4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5571,8 +5571,8 @@ static void nfs4_get_lease_time_prepare(struct rpc_task *task,
 				   &data->args->la_seq_args,
 				   &data->res->lr_seq_res, task);
 
-	BUG_ON(ret == -EAGAIN);
-	rpc_call_start(task);
+	if (ret != -EAGAIN)
+		rpc_call_start(task);
 	dprintk("<-- %s\n", __func__);
 }
 
-- 
1.7.11.7

