Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33408 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756504AbcIQFNz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:55 -0400
Received: by mail-io0-f194.google.com with SMTP id r145so2386821ior.0
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 20/25] NFSv4: Pass the stateid to the exception handler in nfs4_read/write_done_cb
Date: Sat, 17 Sep 2016 01:13:28 -0400
Message-Id: <1474089213-104014-21-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-20-git-send-email-trond.myklebust@primarydata.com>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-2-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-3-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-4-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-5-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-6-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-7-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-8-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-9-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-10-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-11-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-12-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-13-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-14-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-15-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-16-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-17-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-18-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-19-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-20-git-send-email-trond.myklebust@primarydata.com>
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

