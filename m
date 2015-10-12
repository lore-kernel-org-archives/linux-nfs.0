Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33532 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbbJLWBN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Oct 2015 18:01:13 -0400
Received: by iodv82 with SMTP id v82so2418935iod.0
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2015 15:01:12 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 12 Oct 2015 18:01:12 -0400
Message-ID: <CAN-5tyEDNYzdDs=_NJf9=U7NBg0d2ddm4Wa0Tw0jaP9sa61dCQ@mail.gmail.com>
Subject: [PATCH 1/1] Adding issync field to delegreturn_exit tracepoint
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It'll be nice to know when we return delegations synchronously or not.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c  |  5 ++++-
 fs/nfs/nfs4trace.h | 12 ++++++++----
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f93b9cd..858c780 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5283,6 +5283,7 @@ struct nfs4_delegreturndata {
     struct inode *inode;
     bool roc;
     u32 roc_barrier;
+    int issync;
 };

 static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
@@ -5292,7 +5293,8 @@ static void nfs4_delegreturn_done(struct
rpc_task *task, void *calldata)
     if (!nfs4_sequence_done(task, &data->res.seq_res))
         return;

-    trace_nfs4_delegreturn_exit(&data->args, &data->res, task->tk_status);
+    trace_nfs4_delegreturn_exit(&data->args, &data->res, task->tk_status,
+                    data->issync);
     switch (task->tk_status) {
     case 0:
         renew_lease(data->res.server, data->timestamp);
@@ -5387,6 +5389,7 @@ static int _nfs4_proc_delegreturn(struct inode
*inode, struct rpc_cred *cred, co
     data->inode = nfs_igrab_and_active(inode);
     if (data->inode)
         data->roc = nfs4_roc(inode);
+    data->issync = issync;

     task_setup_data.callback_data = data;
     msg.rpc_argp = &data->args;
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 671cf68..be67e87 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -612,29 +612,33 @@ TRACE_EVENT(nfs4_delegreturn_exit,
         TP_PROTO(
             const struct nfs4_delegreturnargs *args,
             const struct nfs4_delegreturnres *res,
-            int error
+            int error,
+            int issync
         ),

-        TP_ARGS(args, res, error),
+        TP_ARGS(args, res, error, issync),

         TP_STRUCT__entry(
             __field(dev_t, dev)
             __field(u32, fhandle)
             __field(int, error)
+            __field(int, issync)
         ),

         TP_fast_assign(
             __entry->dev = res->server->s_dev;
             __entry->fhandle = nfs_fhandle_hash(args->fhandle);
             __entry->error = error;
+            __entry->issync = issync;
         ),

         TP_printk(
-            "error=%d (%s) dev=%02x:%02x fhandle=0x%08x",
+            "error=%d (%s) dev=%02x:%02x fhandle=0x%08x issync=%d",
             __entry->error,
             show_nfsv4_errors(__entry->error),
             MAJOR(__entry->dev), MINOR(__entry->dev),
-            __entry->fhandle
+            __entry->fhandle,
+            __entry->issync
         )
 );

-- 
1.8.3.1
