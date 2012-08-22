Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:43131 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754827Ab2HVC1w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Aug 2012 22:27:52 -0400
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
Subject: [PATCH v3 10/17] dlm: use new hashtable implementation
Date: Wed, 22 Aug 2012 04:27:05 +0200
Message-Id: <1345602432-27673-11-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Switch dlm to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the dlm.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 fs/dlm/lowcomms.c |   47 +++++++++++++----------------------------------
 1 files changed, 13 insertions(+), 34 deletions(-)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 331ea4f..9f21774 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -55,6 +55,7 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/user.h>
 #include <net/ipv6.h>
+#include <linux/hashtable.h>
 
 #include "dlm_internal.h"
 #include "lowcomms.h"
@@ -62,7 +63,7 @@
 #include "config.h"
 
 #define NEEDED_RMEM (4*1024*1024)
-#define CONN_HASH_SIZE 32
+#define CONN_HASH_BITS 5
 
 /* Number of messages to send before rescheduling */
 #define MAX_SEND_MSG_COUNT 25
@@ -158,34 +159,21 @@ static int dlm_allow_conn;
 static struct workqueue_struct *recv_workqueue;
 static struct workqueue_struct *send_workqueue;
 
-static struct hlist_head connection_hash[CONN_HASH_SIZE];
+static struct hlist_head connection_hash[CONN_HASH_BITS];
 static DEFINE_MUTEX(connections_lock);
 static struct kmem_cache *con_cache;
 
 static void process_recv_sockets(struct work_struct *work);
 static void process_send_sockets(struct work_struct *work);
 
-
-/* This is deliberately very simple because most clusters have simple
-   sequential nodeids, so we should be able to go straight to a connection
-   struct in the array */
-static inline int nodeid_hash(int nodeid)
-{
-	return nodeid & (CONN_HASH_SIZE-1);
-}
-
 static struct connection *__find_con(int nodeid)
 {
-	int r;
 	struct hlist_node *h;
 	struct connection *con;
 
-	r = nodeid_hash(nodeid);
-
-	hlist_for_each_entry(con, h, &connection_hash[r], list) {
+	hash_for_each_possible(connection_hash, con, h, list, nodeid)
 		if (con->nodeid == nodeid)
 			return con;
-	}
 	return NULL;
 }
 
@@ -196,7 +184,6 @@ static struct connection *__find_con(int nodeid)
 static struct connection *__nodeid2con(int nodeid, gfp_t alloc)
 {
 	struct connection *con = NULL;
-	int r;
 
 	con = __find_con(nodeid);
 	if (con || !alloc)
@@ -206,8 +193,7 @@ static struct connection *__nodeid2con(int nodeid, gfp_t alloc)
 	if (!con)
 		return NULL;
 
-	r = nodeid_hash(nodeid);
-	hlist_add_head(&con->list, &connection_hash[r]);
+	hash_add(connection_hash, &con->list, nodeid);
 
 	con->nodeid = nodeid;
 	mutex_init(&con->sock_mutex);
@@ -235,11 +221,8 @@ static void foreach_conn(void (*conn_func)(struct connection *c))
 	struct hlist_node *h, *n;
 	struct connection *con;
 
-	for (i = 0; i < CONN_HASH_SIZE; i++) {
-		hlist_for_each_entry_safe(con, h, n, &connection_hash[i], list){
-			conn_func(con);
-		}
-	}
+	hash_for_each_safe(connection_hash, i, h, n, con, list)
+		conn_func(con);
 }
 
 static struct connection *nodeid2con(int nodeid, gfp_t allocation)
@@ -262,12 +245,10 @@ static struct connection *assoc2con(int assoc_id)
 
 	mutex_lock(&connections_lock);
 
-	for (i = 0 ; i < CONN_HASH_SIZE; i++) {
-		hlist_for_each_entry(con, h, &connection_hash[i], list) {
-			if (con->sctp_assoc == assoc_id) {
-				mutex_unlock(&connections_lock);
-				return con;
-			}
+	hash_for_each(connection_hash, i, h, con, list) {
+		if (con->sctp_assoc == assoc_id) {
+			mutex_unlock(&connections_lock);
+			return con;
 		}
 	}
 	mutex_unlock(&connections_lock);
@@ -1638,7 +1619,7 @@ static void free_conn(struct connection *con)
 	close_connection(con, true);
 	if (con->othercon)
 		kmem_cache_free(con_cache, con->othercon);
-	hlist_del(&con->list);
+	hash_del(&con->list);
 	kmem_cache_free(con_cache, con);
 }
 
@@ -1667,10 +1648,8 @@ int dlm_lowcomms_start(void)
 {
 	int error = -EINVAL;
 	struct connection *con;
-	int i;
 
-	for (i = 0; i < CONN_HASH_SIZE; i++)
-		INIT_HLIST_HEAD(&connection_hash[i]);
+	hash_init(connection_hash);
 
 	init_local();
 	if (!dlm_local_count) {
-- 
1.7.8.6

