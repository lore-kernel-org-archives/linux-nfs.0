Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38773 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751661AbeD3EcU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Apr 2018 00:32:20 -0400
From: NeilBrown <neilb@suse.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 30 Apr 2018 14:31:30 +1000
Subject: [PATCH 3/4] rculist: add list_for_each_entry_from_rcu()
Cc: linux-nfs@vger.kernel.org, Lai Jiangshan <jiangshanlai@gmail.com>,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        linux-kernel@vger.kernel.org
Message-ID: <152506269061.7246.13075216914692813995.stgit@noble>
In-Reply-To: <152506256513.7246.13171564155614823841.stgit@noble>
References: <152506256513.7246.13171564155614823841.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

list_for_each_entry_from_rcu() is an RCU version of
list_for_each_entry_from().  It walks a linked list under rcu
protection, from a given start point.

It is similar to list_for_each_entry_continue_rcu() but starts *at*
the given position rather than *after* it.

Naturally, the start point must be known to be in the list.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/rculist.h |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 127f534fec94..36df6ccbc874 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -403,6 +403,19 @@ static inline void list_splice_tail_init_rcu(struct list_head *list,
 	     &pos->member != (head);	\
 	     pos = list_entry_rcu(pos->member.next, typeof(*pos), member))
 
+/**
+ * list_for_each_entry_from_rcu - iterate over a list from current point
+ * @pos:	the type * to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the list_node within the struct.
+ *
+ * Iterate over the tail of a list starting from a given position,
+ * which must have been in the list when the RCU read lock was taken.
+ */
+#define list_for_each_entry_from_rcu(pos, head, member)			\
+	for (; &(pos)->member != (head);					\
+		pos = list_entry_rcu(pos->member.next, typeof(*(pos)), member))
+
 /**
  * hlist_del_rcu - deletes entry from hash list without re-initialization
  * @n: the element to delete from the hash list.


