Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33310 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113Ab2HSAwX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Aug 2012 20:52:23 -0400
From: Sasha Levin <levinsasha928@gmail.com>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
        rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com,
        aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org,
        josh@joshtriplett.org, eric.dumazet@gmail.com,
        mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
        teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
        fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
        ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
        linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com,
        Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 06/16] tracepoint: use new hashtable implementation
Date: Sun, 19 Aug 2012 02:52:20 +0200
Message-Id: <1345337550-24304-8-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
References: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Switch tracepoints to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the tracepoints.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 kernel/tracepoint.c |   27 +++++++++++----------------
 1 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/kernel/tracepoint.c b/kernel/tracepoint.c
index d96ba22..854df92 100644
--- a/kernel/tracepoint.c
+++ b/kernel/tracepoint.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/sched.h>
 #include <linux/static_key.h>
+#include <linux/hashtable.h>
 
 extern struct tracepoint * const __start___tracepoints_ptrs[];
 extern struct tracepoint * const __stop___tracepoints_ptrs[];
@@ -49,8 +50,7 @@ static LIST_HEAD(tracepoint_module_list);
  * Protected by tracepoints_mutex.
  */
 #define TRACEPOINT_HASH_BITS 6
-#define TRACEPOINT_TABLE_SIZE (1 << TRACEPOINT_HASH_BITS)
-static struct hlist_head tracepoint_table[TRACEPOINT_TABLE_SIZE];
+static DEFINE_HASHTABLE(tracepoint_table, TRACEPOINT_HASH_BITS);
 
 /*
  * Note about RCU :
@@ -191,16 +191,15 @@ tracepoint_entry_remove_probe(struct tracepoint_entry *entry,
  */
 static struct tracepoint_entry *get_tracepoint(const char *name)
 {
-	struct hlist_head *head;
 	struct hlist_node *node;
 	struct tracepoint_entry *e;
 	u32 hash = jhash(name, strlen(name), 0);
 
-	head = &tracepoint_table[hash & (TRACEPOINT_TABLE_SIZE - 1)];
-	hlist_for_each_entry(e, node, head, hlist) {
+	hash_for_each_possible(tracepoint_table, e, node, hlist, hash) {
 		if (!strcmp(name, e->name))
 			return e;
 	}
+
 	return NULL;
 }
 
@@ -210,19 +209,13 @@ static struct tracepoint_entry *get_tracepoint(const char *name)
  */
 static struct tracepoint_entry *add_tracepoint(const char *name)
 {
-	struct hlist_head *head;
-	struct hlist_node *node;
 	struct tracepoint_entry *e;
 	size_t name_len = strlen(name) + 1;
 	u32 hash = jhash(name, name_len-1, 0);
 
-	head = &tracepoint_table[hash & (TRACEPOINT_TABLE_SIZE - 1)];
-	hlist_for_each_entry(e, node, head, hlist) {
-		if (!strcmp(name, e->name)) {
-			printk(KERN_NOTICE
-				"tracepoint %s busy\n", name);
-			return ERR_PTR(-EEXIST);	/* Already there */
-		}
+	if (get_tracepoint(name)) {
+		printk(KERN_NOTICE "tracepoint %s busy\n", name);
+		return ERR_PTR(-EEXIST);	/* Already there */
 	}
 	/*
 	 * Using kmalloc here to allocate a variable length element. Could
@@ -234,7 +227,7 @@ static struct tracepoint_entry *add_tracepoint(const char *name)
 	memcpy(&e->name[0], name, name_len);
 	e->funcs = NULL;
 	e->refcount = 0;
-	hlist_add_head(&e->hlist, head);
+	hash_add(tracepoint_table, &e->hlist, hash);
 	return e;
 }
 
@@ -244,7 +237,7 @@ static struct tracepoint_entry *add_tracepoint(const char *name)
  */
 static inline void remove_tracepoint(struct tracepoint_entry *e)
 {
-	hlist_del(&e->hlist);
+	hash_del(&e->hlist);
 	kfree(e);
 }
 
@@ -722,6 +715,8 @@ struct notifier_block tracepoint_module_nb = {
 
 static int init_tracepoints(void)
 {
+	hash_init(tracepoint_table);
+
 	return register_module_notifier(&tracepoint_module_nb);
 }
 __initcall(init_tracepoints);
-- 
1.7.8.6

