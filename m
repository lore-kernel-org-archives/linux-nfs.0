From: Terry Loftin <terry.loftin@hp.com>
Subject: [PATCH 1/1] nfs: Panic when commit fails
Date: Tue, 20 Oct 2009 11:44:40 -0600
Message-ID: <4ADDF708.6020901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: SteveD@redhat.com, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:32566 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbZJTRos (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2009 13:44:48 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Actually pass the NFS_FILE_SYNC option to the server to avoid a
Panic in nfs_direct_write_complete() when a commit fails.

At the end of an nfs write, if the nfs commit fails, all the writes
will be rescheduled.  They are supposed to be rescheduled as NFS_FILE_SYNC
writes, but the rpc_task structure is not completely intialized and so
the option is not passed.  When the rescheduled writes complete, the
return indicates that they are NFS_UNSTABLE and we try to do another
commit.  This leads to a Panic because the commit data structure pointer
was set to null in the initial (failed) commit attempt.

Signed-off-by: Terry Loftin <terry.loftin@hp.com>
---

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e4e089a..1af78ff 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -457,6 +457,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(inode),
+		.rpc_message = &msg,
 		.callback_ops = &nfs_write_direct_ops,
 		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
