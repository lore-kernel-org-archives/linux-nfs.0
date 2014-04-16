Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38780 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752428AbaDPESK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2014 00:18:10 -0400
From: NeilBrown <neilb@suse.de>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 16 Apr 2014 14:03:36 +1000
Subject: [PATCH 03/19] lockdep: improve scenario messages for RECLAIM_FS
 errors.
cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: xfs@oss.sgi.com
Message-ID: <20140416040336.10604.19304.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lockdep can check for locking problems involving reclaim using
the same infrastructure as used for interrupts.

However a number of the messages still refer to interrupts even
if it was actually a reclaim-related problem.

So determine where the problem was caused by reclaim or irq and adjust
messages accordingly.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 kernel/locking/lockdep.c |   43 ++++++++++++++++++++++++++++++++-----------
 1 file changed, 32 insertions(+), 11 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index e05b82e92373..33d2ac7519dc 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -1423,7 +1423,8 @@ static void
 print_irq_lock_scenario(struct lock_list *safe_entry,
 			struct lock_list *unsafe_entry,
 			struct lock_class *prev_class,
-			struct lock_class *next_class)
+			struct lock_class *next_class,
+			int reclaim)
 {
 	struct lock_class *safe_class = safe_entry->class;
 	struct lock_class *unsafe_class = unsafe_entry->class;
@@ -1455,20 +1456,27 @@ print_irq_lock_scenario(struct lock_list *safe_entry,
 		printk("\n\n");
 	}
 
-	printk(" Possible interrupt unsafe locking scenario:\n\n");
+	if (reclaim)
+		printk(" Possible reclaim unsafe locking scenario:\n\n");
+	else
+		printk(" Possible interrupt unsafe locking scenario:\n\n");
 	printk("       CPU0                    CPU1\n");
 	printk("       ----                    ----\n");
 	printk("  lock(");
 	__print_lock_name(unsafe_class);
 	printk(");\n");
-	printk("                               local_irq_disable();\n");
+	if (!reclaim)
+		printk("                               local_irq_disable();\n");
 	printk("                               lock(");
 	__print_lock_name(safe_class);
 	printk(");\n");
 	printk("                               lock(");
 	__print_lock_name(middle_class);
 	printk(");\n");
-	printk("  <Interrupt>\n");
+	if (reclaim)
+		printk("  <Memory allocation/reclaim>\n");
+	else
+		printk("  <Interrupt>\n");
 	printk("    lock(");
 	__print_lock_name(safe_class);
 	printk(");\n");
@@ -1487,6 +1495,8 @@ print_bad_irq_dependency(struct task_struct *curr,
 			 enum lock_usage_bit bit2,
 			 const char *irqclass)
 {
+	int reclaim = strncmp(irqclass, "RECLAIM", 7) == 0;
+
 	if (!debug_locks_off_graph_unlock() || debug_locks_silent)
 		return 0;
 
@@ -1528,7 +1538,7 @@ print_bad_irq_dependency(struct task_struct *curr,
 
 	printk("\nother info that might help us debug this:\n\n");
 	print_irq_lock_scenario(backwards_entry, forwards_entry,
-				hlock_class(prev), hlock_class(next));
+				hlock_class(prev), hlock_class(next), reclaim);
 
 	lockdep_print_held_locks(curr);
 
@@ -2200,7 +2210,7 @@ static void check_chain_key(struct task_struct *curr)
 }
 
 static void
-print_usage_bug_scenario(struct held_lock *lock)
+print_usage_bug_scenario(struct held_lock *lock, enum lock_usage_bit new_bit)
 {
 	struct lock_class *class = hlock_class(lock);
 
@@ -2210,7 +2220,11 @@ print_usage_bug_scenario(struct held_lock *lock)
 	printk("  lock(");
 	__print_lock_name(class);
 	printk(");\n");
-	printk("  <Interrupt>\n");
+	if (new_bit == LOCK_USED_IN_RECLAIM_FS ||
+	    new_bit == LOCK_USED_IN_RECLAIM_FS_READ)
+		printk("  <Memory allocation/reclaim>\n");
+	else
+		printk("  <Interrupt>\n");
 	printk("    lock(");
 	__print_lock_name(class);
 	printk(");\n");
@@ -2246,7 +2260,7 @@ print_usage_bug(struct task_struct *curr, struct held_lock *this,
 
 	print_irqtrace_events(curr);
 	printk("\nother info that might help us debug this:\n");
-	print_usage_bug_scenario(this);
+	print_usage_bug_scenario(this, new_bit);
 
 	lockdep_print_held_locks(curr);
 
@@ -2285,13 +2299,17 @@ print_irq_inversion_bug(struct task_struct *curr,
 	struct lock_list *entry = other;
 	struct lock_list *middle = NULL;
 	int depth;
+	int reclaim = strncmp(irqclass, "RECLAIM", 7) == 0;
 
 	if (!debug_locks_off_graph_unlock() || debug_locks_silent)
 		return 0;
 
 	printk("\n");
 	printk("=========================================================\n");
-	printk("[ INFO: possible irq lock inversion dependency detected ]\n");
+	if (reclaim)
+		printk("[ INFO: possible memory reclaim lock inversion dependency detected ]\n");
+	else
+		printk("[ INFO: possible irq lock inversion dependency detected ]\n");
 	print_kernel_ident();
 	printk("---------------------------------------------------------\n");
 	printk("%s/%d just changed the state of lock:\n",
@@ -2302,6 +2320,9 @@ print_irq_inversion_bug(struct task_struct *curr,
 	else
 		printk("but this lock was taken by another, %s-safe lock in the past:\n", irqclass);
 	print_lock_name(other->class);
+	if (reclaim)
+		printk("\n\nand memory reclaim could create inverse lock ordering between them.\n\n");
+	else
 	printk("\n\nand interrupts could create inverse lock ordering between them.\n\n");
 
 	printk("\nother info that might help us debug this:\n");
@@ -2319,10 +2340,10 @@ print_irq_inversion_bug(struct task_struct *curr,
 	} while (entry && entry != root && (depth >= 0));
 	if (forwards)
 		print_irq_lock_scenario(root, other,
-			middle ? middle->class : root->class, other->class);
+			middle ? middle->class : root->class, other->class, reclaim);
 	else
 		print_irq_lock_scenario(other, root,
-			middle ? middle->class : other->class, root->class);
+			middle ? middle->class : other->class, root->class, reclaim);
 
 	lockdep_print_held_locks(curr);
 


