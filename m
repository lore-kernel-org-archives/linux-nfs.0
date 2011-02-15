Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:36216 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201Ab1BOO7F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 09:59:05 -0500
Received: by gwj20 with SMTP id 20so103086gwj.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 Feb 2011 06:59:04 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: don't queue synchronous NFSv4 close rpc_release to nfsiod
Date: Tue, 15 Feb 2011 09:58:59 -0500
Message-Id: <1297781939-1400-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

I recently had some of our QA people report some connectathon test
failures in RHEL5 (2.6.18-based kernel). For some odd reason (maybe
scheduling differences that make the race more likely?) the problem
occurs more frequently on s390.

The problem generally manifests itself on NFSv4 as a race where an rmdir
fails because a silly-renamed file in the directory wasn't deleted in
time. Looking at traces, what you usually see is the failing rmdir
attempt that fails with the sillydelete of the file that prevented it
very soon afterward.

Silly deletes are handled via dentry_iput and in the case of a close on
NFSv4, the last dentry reference is often held by the CLOSE RPC task.
nfs4_do_close does the close as an async RPC task that it conditionally
waits on depending on whether the close is synchronous or not.

It also sets the workqueue for the task to nfsiod_workqueue. When
tk_workqueue is set, the rpc_release operation is queued to that
workqueue. rpc_release is where the dentry reference held by the task is
put. The caller has no way to wait for that to complete, so the close(2)
syscall can easily return before the rpc_release call is ever done. In
some cases, that rpc_release is delayed for a long enough to prevent a
subsequent rmdir of the containing directory.

I believe this is a bug, or at least not ideal behavior. We should try
not to have the close(2) call return in this situation until the
sillydelete is done.

I've been able to reproduce this more reliably by adding a 100ms sleep
at the top of nfs4_free_closedata. I've not seen it "in the wild" on
mainline kernels, but it seems quite possible when a machine is heavily
loaded.

This patch fixes this by not setting tk_workqueue in nfs4_do_close when
the wait flag is set. This makes the final rpc_put_task a synchronous
operation and should prevent close(2) from returning before the
dentry_iput is done.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 78936a8..4cabfea 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1988,11 +1988,14 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, i
 		.rpc_client = server->client,
 		.rpc_message = &msg,
 		.callback_ops = &nfs4_close_ops,
-		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
 	int status = -ENOMEM;
 
+	/* rpc_release must be synchronous too if "wait" is set */
+	if (!wait)
+		task_setup_data.workqueue = nfsiod_workqueue;
+
 	calldata = kzalloc(sizeof(*calldata), gfp_mask);
 	if (calldata == NULL)
 		goto out;
-- 
1.7.4

