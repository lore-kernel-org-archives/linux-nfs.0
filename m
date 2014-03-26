Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755491AbaCZPul (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Mar 2014 11:50:41 -0400
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSv4: Memory not being freed on memory allocation failure
Date: Wed, 26 Mar 2014 11:50:36 -0400
Message-Id: <1395849036-6907-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_run_open_task() puts a ref count on the nfs4_opendata
data pointer, then tries to allocate the task pointer.
If that task allocation fails nfs4_run_open_task() returns
leaving the ref count on the data pointer.

That extra ref count stops the data pointer from being
freed in _nfs4_do_open() as expected.

This patch reverse the order of the task allocation and
ref count. The task is allocated before the ref count
is done, allowing the allocation to fail (and return)
without the ref count.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/nfs4proc.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2da6a69..a5a61ec 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1846,6 +1846,13 @@ static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
 	};
 	int status;
 
+	/*
+	 * Allocate the task before kref-ing the data
+	 */
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+
 	nfs4_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1);
 	kref_get(&data->kref);
 	data->rpc_done = 0;
@@ -1856,16 +1863,13 @@ static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
 		nfs4_set_sequence_privileged(&o_arg->seq_args);
 		data->is_recover = 1;
 	}
-	task = rpc_run_task(&task_setup_data);
-        if (IS_ERR(task))
-                return PTR_ERR(task);
-        status = nfs4_wait_for_completion_rpc_task(task);
-        if (status != 0) {
-                data->cancelled = 1;
-                smp_wmb();
-        } else
-                status = data->rpc_status;
-        rpc_put_task(task);
+	status = nfs4_wait_for_completion_rpc_task(task);
+	if (status != 0) {
+		data->cancelled = 1;
+		smp_wmb();
+	} else
+		status = data->rpc_status;
+	rpc_put_task(task);
 
 	return status;
 }
-- 
1.8.3.1

