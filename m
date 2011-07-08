Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23224 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753100Ab1GHUqC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jul 2011 16:46:02 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 1/2] NFSD: Clean up fault injection file creation
Date: Fri,  8 Jul 2011 16:45:58 -0400
Message-Id: <1310157959-11429-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1310157959-11429-1-git-send-email-bjschuma@netapp.com>
References: <1310157959-11429-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

I think it is easier to specify an action and an item (such as "forget" and
"clients") once, rather than having to state them multiple times for the same
macro.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>

---
 fs/nfsd/fault_inject.c |   39 ++++++++++++++++++++++-----------------
 1 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 3dd1c32..7f5ac83 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -12,26 +12,28 @@
 static void nfsd_forget_everything(void);
 
 struct nfsd_fault_inject_op {
-	char *name;
-	char *text;
+	char *action;
+	char *item;
+	char *file;
 	int file_data;
 	void (*func)(void);
 };
 
-#define INJECTION_OP(op_name, op_text, op_func) \
-{				\
-	.name = op_name,	\
-	.text = op_text,	\
-	.func = op_func,	\
+#define INJECTION_OP(op_action, op_item, op_func) \
+{					\
+	.action = op_action,		\
+	.item = op_item,		\
+	.file = op_action"_"op_item,	\
+	.func = op_func,		\
 }
 
 static struct nfsd_fault_inject_op inject_ops[] = {
-	INJECTION_OP("forget_clients",     "forget all clients",     nfsd_forget_all_clients),
-	INJECTION_OP("forget_locks",       "forget all locks",       nfsd_forget_all_locks),
-	INJECTION_OP("forget_open_owners", "forget all open owners", nfsd_forget_all_open_owners),
-	INJECTION_OP("forget_delegations", "forget all delegations", nfsd_forget_all_delegations),
-	INJECTION_OP("forget_everything",  "forget everything",      nfsd_forget_everything),
-	INJECTION_OP("recall_delegations", "recall all delegations", nfsd_recall_all_delegations),
+	INJECTION_OP("forget", "clients",     nfsd_forget_all_clients),
+	INJECTION_OP("forget", "locks",       nfsd_forget_all_locks),
+	INJECTION_OP("forget", "open_owners", nfsd_forget_all_open_owners),
+	INJECTION_OP("forget", "delegations", nfsd_forget_all_delegations),
+	INJECTION_OP("forget", "everything",  nfsd_forget_everything),
+	INJECTION_OP("recall", "delegations", nfsd_recall_all_delegations),
 };
 
 static long int NUM_INJECT_OPS = sizeof(inject_ops) / sizeof(struct nfsd_fault_inject_op);
@@ -48,10 +50,13 @@ static void nfsd_forget_everything(void)
 static int nfsd_inject_set(void *data, u64 val)
 {
 	int i;
+	struct nfsd_fault_inject_op *op;
 	for (i = 0; i < NUM_INJECT_OPS; i++) {
-		if (&inject_ops[i].file_data == data) {
-			printk(KERN_INFO "%s %s Server will %s", __FILE__, __func__, inject_ops[i].text);
-			inject_ops[i].func();
+		op = &inject_ops[i];
+		if (&op->file_data == data) {
+			printk(KERN_INFO "%s %s Server will %s all %s", __FILE__,
+				__func__, op->action, op->item);
+			op->func();
 		}
 	}
 	return 0;
@@ -83,7 +88,7 @@ nfsd_fault_inject_init(void)
 
 	for (i = 0; i < NUM_INJECT_OPS; i++) {
 		op = &inject_ops[i];
-		debugfs_create_file(op->name, mode, debug_dir, &op->file_data, &fops_nfsd);
+		debugfs_create_file(op->file, mode, debug_dir, &op->file_data, &fops_nfsd);
 	}
 	return 0;
 fail:
-- 
1.7.6

