Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35265 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754186AbcIOQq0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 12:46:26 -0400
Received: by mail-it0-f66.google.com with SMTP id e20so4992350itc.2
        for <linux-nfs@vger.kernel.org>; Thu, 15 Sep 2016 09:46:25 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v4 18/20] NFSv4: Pass the stateid to the exception handler in nfs4_read/write_done_cb
Date: Thu, 15 Sep 2016 12:45:58 -0400
Message-Id: <1473957960-10001-19-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473957960-10001-18-git-send-email-trond.myklebust@primarydata.com>
References: <1473957960-10001-1-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-2-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-3-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-4-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-5-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-6-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-7-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-8-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-9-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-10-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-11-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-12-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-13-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-14-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-15-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-16-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-17-git-send-email-trond.myklebust@primarydata.com>
 <1473957960-10001-18-git-send-email-trond.myklebust@primarydata.com>
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
index e2ab6f665dba..82449e578608 100644
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

