Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:46116 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965625Ab2J3Ssa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Oct 2012 14:48:30 -0400
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
Subject: [PATCH v8 16/16] tracing output: use new hashtable implementation
Date: Tue, 30 Oct 2012 14:46:12 -0400
Message-Id: <1351622772-16400-16-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Switch tracing to use the new hashtable implementation. This reduces the
amount of generic unrelated code in the tracing module.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 kernel/trace/trace_output.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 123b189..6af4879 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -8,15 +8,15 @@
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/ftrace.h>
+#include <linux/hashtable.h>
 
 #include "trace_output.h"
 
-/* must be a power of 2 */
-#define EVENT_HASHSIZE	128
+#define EVENT_HASH_BITS	7
 
 DECLARE_RWSEM(trace_event_mutex);
 
-static struct hlist_head event_hash[EVENT_HASHSIZE] __read_mostly;
+static DEFINE_HASHTABLE(event_hash, EVENT_HASH_BITS);
 
 static int next_event_type = __TRACE_LAST_TYPE + 1;
 
@@ -712,11 +712,8 @@ struct trace_event *ftrace_find_event(int type)
 {
 	struct trace_event *event;
 	struct hlist_node *n;
-	unsigned key;
 
-	key = type & (EVENT_HASHSIZE - 1);
-
-	hlist_for_each_entry(event, n, &event_hash[key], node) {
+	hash_for_each_possible(event_hash, event, n, node, type) {
 		if (event->type == type)
 			return event;
 	}
@@ -781,7 +778,6 @@ void trace_event_read_unlock(void)
  */
 int register_ftrace_event(struct trace_event *event)
 {
-	unsigned key;
 	int ret = 0;
 
 	down_write(&trace_event_mutex);
@@ -833,9 +829,7 @@ int register_ftrace_event(struct trace_event *event)
 	if (event->funcs->binary == NULL)
 		event->funcs->binary = trace_nop_print;
 
-	key = event->type & (EVENT_HASHSIZE - 1);
-
-	hlist_add_head(&event->node, &event_hash[key]);
+	hash_add(event_hash, &event->node, event->type);
 
 	ret = event->type;
  out:
@@ -850,7 +844,7 @@ EXPORT_SYMBOL_GPL(register_ftrace_event);
  */
 int __unregister_ftrace_event(struct trace_event *event)
 {
-	hlist_del(&event->node);
+	hash_del(&event->node);
 	list_del(&event->list);
 	return 0;
 }
-- 
1.7.12.4

