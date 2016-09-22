Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34871 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965367AbcIVRj5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:39:57 -0400
Received: by mail-io0-f195.google.com with SMTP id 92so206482iom.2
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:39:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 21/31] NFSv4: Pass the stateid to the exception handler in nfs4_read/write_done_cb
Date: Thu, 22 Sep 2016 13:39:11 -0400
Message-Id: <1474565961-21303-22-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-21-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-15-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-16-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-17-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-18-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-19-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-20-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-21-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The actual stateid used in the READ or WRITE can represent a delegation,
a lock or a stateid, so it is useful to pass it as an argument to the
exception handler when an expired/revoked response is received from the
server. It also ensures that we don't re-label the state as needing
recovery if that has already occurred.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 35 +++++++++++++++++++++++++----------
 1 file changed, 25 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e5b35e57a8ff..1ddfb300addf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4523,11 +4523,18 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_pgio_header *hdr)
 	struct nfs_server *server = NFS_SERVER(hdr->inode);
 
 	trace_nfs4_read(hdr, task->tk_status);
-	if (nfs4_async_handle_error(task, server,
-				    hdr->args.context->state,
-				    NULL) == -EAGAIN) {
-		rpc_restart_call_prepare(task);
-		return -EAGAIN;
+	if (task->tk_status < 0) {
+		struct nfs4_exception exception = {
+			.inode = hdr->inode,
+			.state = hdr->args.context->state,
+			.stateid = &hdr->args.stateid,
+		};
+		task->tk_status = nfs4_async_handle_exception(task,
+				server, task->tk_status, &exception);
+		if (exception.retry) {
+			rpc_restart_call_prepare(task);
+			return -EAGAIN;
+		}
 	}
 
 	__nfs4_read_done_cb(hdr);
@@ -4596,11 +4603,19 @@ static int nfs4_write_done_cb(struct rpc_task *task,
 	struct inode *inode = hdr->inode;
 
 	trace_nfs4_write(hdr, task->tk_status);
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode),
-				    hdr->args.context->state,
-				    NULL) == -EAGAIN) {
-		rpc_restart_call_prepare(task);
-		return -EAGAIN;
+	if (task->tk_status < 0) {
+		struct nfs4_exception exception = {
+			.inode = hdr->inode,
+			.state = hdr->args.context->state,
+			.stateid = &hdr->args.stateid,
+		};
+		task->tk_status = nfs4_async_handle_exception(task,
+				NFS_SERVER(inode), task->tk_status,
+				&exception);
+		if (exception.retry) {
+			rpc_restart_call_prepare(task);
+			return -EAGAIN;
+		}
 	}
 	if (task->tk_status >= 0) {
 		renew_lease(NFS_SERVER(inode), hdr->timestamp);
-- 
2.7.4

