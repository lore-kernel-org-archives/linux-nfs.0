Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61376 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755997Ab3DWS6I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 14:58:08 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] NFSv4.1: Use the more efficient open_noattr call for open-by-filehandle
Date: Tue, 23 Apr 2013 14:58:01 -0400
Message-Id: <1366743483-59247-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1366743483-59247-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1366743483-59247-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we're doing open-by-filehandle in NFSv4.1, we shouldn't need to
do the cache consistency revalidation on the directory. It is
therefore more efficient to just use open_noattr, which returns the
file attributes, but not the directory attributes.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c131449..a411a53 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1549,9 +1549,13 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 	}
 	/* Update client id. */
 	data->o_arg.clientid = clp->cl_clientid;
-	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS) {
-		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
+	switch (data->o_arg.claim) {
+	case NFS4_OPEN_CLAIM_PREVIOUS:
+	case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
+	case NFS4_OPEN_CLAIM_DELEG_PREV_FH:
 		data->o_arg.open_bitmap = &nfs4_open_noattr_bitmap[0];
+	case NFS4_OPEN_CLAIM_FH:
+		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
 		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
 	}
 	data->timestamp = jiffies;
-- 
1.8.1.4

