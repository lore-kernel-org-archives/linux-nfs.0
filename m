Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbbJANRf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Oct 2015 09:17:35 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix a nograce recovery hang
Date: Thu,  1 Oct 2015 09:17:33 -0400
Message-Id: <3f289465f9fe9aef49605e1418e6a22c6f3d6118.1443705317.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 5cae02f42793130e1387f4ec09c4d07056ce9fa5 an OPEN_CONFIRM should
have a privileged sequence in the recovery case to allow nograce recovery to
proceed for NFSv4.0.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f93b9cd..784a649 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1863,6 +1863,8 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 	data->rpc_done = 0;
 	data->rpc_status = 0;
 	data->timestamp = jiffies;
+	if (data->is_recover)
+		nfs4_set_sequence_privileged(&data->c_arg.seq_args);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-- 
1.7.1

