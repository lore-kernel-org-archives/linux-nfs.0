Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:52222 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab1A0QtU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jan 2011 11:49:20 -0500
Message-ID: <4D41A20B.106@panasas.com>
Date: Thu, 27 Jan 2011 18:49:15 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: Fwd: [PATCH] layout-sim: layout recall callback (forgetful client)
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

[Fixing typo in list address]

-------- Original Message --------
Subject: [PATCH] layout-sim: layout recall callback (forgetful client)
Date: Thu, 27 Jan 2011 17:06:06 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.com,	nfsv4@ietf.org
CC: Benny Halevy <bhalevy@panasas.com>

Simulate cb_layoutrecall with the forget client model.
The client responds with NFS4ERR_DELAY if there are any calls it needs
to wait for before processing the callback, or if there I/Os in flight
(simulated randomally).  When the layout can be returned, the client
deleted it locally and replies synchronously with NFS4ERR_NOMATCHING_LAYOUT
instead of sending layout return.

The server sends only one CB_LAYOUT_RECALL at a time and does not process
any LAYOUTGETs while waiting on it, replying with NFS4ERR_RECALLCONFLICT.
LAYOUTRETURN stateid sequencing is enforced so that only those sent after
the client processed the layout recall callback are accepted.
The layout recall "process" is completed either on NFS4ERR_RECALLCONFLICT
or on a matching LAYOUTRETURN.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 client.c |   37 ++++++++++++++++++++++--
 layout.c |   21 +++++++++----
 layout.h |   18 +++++++++++-
 server.c |   93 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 150 insertions(+), 19 deletions(-)

diff --git a/client.c b/client.c
index 61163b5..182db7b 100644
--- a/client.c
+++ b/client.c
@@ -171,6 +171,8 @@ _reprocess_queue(void)
 	struct msg *m;
 
 	list_for_each_entry (m, &cl_queued.list, list) {
+		if (m->type == CB_LAYOUT_RECALL)
+			continue;
 		if (is_next(&m->stateid, &cl_layout.stateid) ||
 		    (m->type == LAYOUTRETURN &&
 		     m->stateid.type == OPEN_STATEID &&
@@ -227,6 +229,36 @@ out_free:
 }
 
 static void
+cl_recv_cb_layout_recall(struct msg *m)
+{
+	if ((m->stateid.type == OPEN_STATEID &&
+	     cl_layout.stateid.type != OPEN_STATEID) ||
+	    (m->stateid.seq > cl_layout.stateid.seq + 1)) {
+		dprintk(1, "%s: m=%p seq=%llu cl_layout.seq=%llu: waiting\n",
+			__func__, m,
+			llu(m->stateid.seq), llu(cl_layout.stateid.seq));
+		m->status = NFS4ERR_DELAY;
+		goto out;
+	}
+
+	BUG_ON(m->stateid.seq <= cl_layout.stateid.seq);
+	if (mynrand(10) < 3) {
+		dprintk(1, "%s: m=%p: simulating delay\n", __func__, m);
+		m->status = NFS4ERR_DELAY;
+		goto out;
+	}
+
+	/* forgetful model */
+	layout_delete(&cl_layout, &m->range);
+	cl_layout.stateid = m->stateid;
+	m->status = NFS4ERR_NOMATCHING_LAYOUT;
+
+out:
+	dprintk(1, "%s: m=%p status=%d\n", __func__, m, m->status);
+	enqueue(&srv_msg_queue, m);
+}
+
+static void
 _cl_recv_msg(struct msg *m)
 {
 	switch (m->type) {
@@ -236,10 +268,9 @@ _cl_recv_msg(struct msg *m)
 	case LAYOUTRETURN:
 		cl_recv_layoutreturn(m);
 		break;
-#if 0
-	case CB_LAYOUTRECALL:
+	case CB_LAYOUT_RECALL:
+		cl_recv_cb_layout_recall(m);
 		break;
-#endif
 	default:
 		BUG_ON(true);
 	}
diff --git a/layout.c b/layout.c
index 94870f0..c5ad99a 100644
--- a/layout.c
+++ b/layout.c
@@ -65,7 +65,7 @@ last_byte_offset(u64 start, u64 len)
  *                  |----------------|
  */
 static inline int
-lo_seg_overlapping(struct layout_range *l1, struct layout_range *l2)
+lo_seg_overlapping(const struct layout_range *l1, const struct layout_range *l2)
 {
 	u64 start1 = l1->offset;
 	u64 last1 = last_byte_offset(start1, l1->length);
@@ -82,13 +82,15 @@ lo_seg_overlapping(struct layout_range *l1, struct layout_range *l2)
 }
 
 bool
-layout_delete(struct layout *lo, struct layout_range *range)
+_lookup_layout(const char *func, struct layout *lo,
+	       const struct layout_range *range,
+	       bool do_delete)
 {
 	bool found = false;
 	struct layout_item *pos, *next;
 
 	dprintk(1, "%s: %s: offset=%llu length=%llu iomode=%d roc=%d\n",
-		__func__, lo->desc,
+		func, lo->desc,
 		llu(range->offset), llu(range->length),
 		range->iomode, range->roc);
 
@@ -98,9 +100,12 @@ layout_delete(struct layout *lo, struct layout_range *range)
 		    (!range->roc || pos->range.roc) &&
 		    lo_seg_overlapping(&pos->range, range)) {
 			dprintk(1, "%s: found l=%p\n", __func__, pos);
-			list_del(&pos->list);
-			myfree(pos);
 			found = true;
+			if (do_delete) {
+				list_del(&pos->list);
+				myfree(pos);
+			} else
+				break;
 		}
 	}
 
@@ -113,8 +118,10 @@ layout_verify(struct layout *server, struct layout *client)
 	bool ok = true, found;
 	struct layout_item *cl, *sl;
 
-	if ((client->stateid.type != server->stateid.type) ||
-	    (client->stateid.seq != server->stateid.seq)) {
+	if (((client->stateid.type != server->stateid.type) ||
+	     (client->stateid.seq != server->stateid.seq)) &&
+	    (!server->layout_recall_msg ||
+	     client->stateid.seq >= server->stateid.seq)) {
 		dprintk(0, "%s: cl stateid=%d:%llu srv stateid=%d:%llu\n",
 			__func__,
 			client->stateid.type, llu(client->stateid.seq),
diff --git a/layout.h b/layout.h
index bafad13..895b145 100644
--- a/layout.h
+++ b/layout.h
@@ -43,15 +43,31 @@ struct stateid {
 		    type resets to OPEN_STATEID */
 };
 
+struct msg;
+
 struct layout {
 	struct stateid stateid;
 	struct list_head segs;
 	char *desc;
+	struct msg *layout_recall_msg;
 };
 
 void layout_init(struct layout *, char *desc);
 void layout_insert(struct layout *, struct layout_range *);
-bool layout_delete(struct layout *, struct layout_range *);
+bool _lookup_layout(const char *func, struct layout *,
+		    const struct layout_range *,
+		    bool do_delete);
+
+static inline bool has_layout(struct layout *lo, const struct layout_range *range)
+{
+	return _lookup_layout(__func__, lo, range, false);
+}
+
+static inline bool layout_delete(struct layout *lo, const struct layout_range *range)
+{
+	return _lookup_layout(__func__, lo, range, true);
+}
+
 bool layout_verify(struct layout *server, struct layout *client);
 
 enum msg_type {
diff --git a/server.c b/server.c
index 1bc9978..19bb85a 100644
--- a/server.c
+++ b/server.c
@@ -5,6 +5,7 @@
  * See "COPYING" for more information
  */
 
+#include "alloc.h"
 #include "client.h"
 #include "debug.h"
 #include "layout.h"
@@ -63,10 +64,13 @@ verify_stateid(struct msg *m)
 		    srv_layout.stateid.seq > 100) {
 			/* FIXME: use an actual limit on parallelism */
 			return m->status = NFS4ERR_OLD_STATEID;
-		} else if (m->stateid.type == LAYOUT_STATEID &&
-		           m->stateid.seq > srv_layout.stateid.seq)
-			return m->status = NFS4ERR_BAD_STATEID;
-		/* TODO: CB_LAYOUTRECALL case */
+		} else if (m->stateid.type == LAYOUT_STATEID) {
+			if (srv_layout.layout_recall_msg &&
+		            m->stateid.seq < srv_layout.layout_recall_msg->stateid.seq)
+				return m->status = NFS4ERR_OLD_STATEID;
+			else if (m->stateid.seq > srv_layout.stateid.seq)
+				return m->status = NFS4ERR_BAD_STATEID;
+		}
 		break;
 	default:
 		BUG_ON(true);
@@ -77,8 +81,13 @@ verify_stateid(struct msg *m)
 static void
 srv_recv_layoutget(struct msg *m)
 {
+	if (srv_layout.layout_recall_msg) {
+		m->status = NFS4ERR_RECALLCONFLICT;
+		goto out;
+	}
+
 	if (verify_stateid(m))
-		return;
+		goto out;
 
 	/* randomize layoutget response */
 	m->range.length = BLOCK_SIZE + mynrand(MAX_LO_MSG_LENGTH - BLOCK_SIZE);
@@ -87,22 +96,54 @@ srv_recv_layoutget(struct msg *m)
 		m->range.iomode = IOMODE_RW;
 	srv_set_stateid(m);
 	m->status = NFS4_OK;
-	dump_msg(m);
 	layout_insert(&srv_layout, &m->range);
+out:
+	dump_msg(m);
 }
 
 static void
 srv_recv_layoutreturn(struct msg *m)
 {
+	struct msg *lrm;
+
 	if (verify_stateid(m))
 		return;
 
 	layout_delete(&srv_layout, &m->range);
 	srv_set_stateid(m);
 	m->status = NFS4_OK;
+	lrm = srv_layout.layout_recall_msg;
+	if (lrm && m->range.iomode == lrm->range.iomode &&
+	    m->range.offset == lrm->range.offset &&
+	    m->range.length && lrm->range.length) {
+		srv_layout.layout_recall_msg = NULL;
+		myfree(lrm);
+	}
 	dump_msg(m);
 }
 
+static void
+srv_recv_cb_layout_recall(struct msg *m)
+{
+	BUG_ON(m != srv_layout.layout_recall_msg);
+	dump_msg(m);
+	switch (m->status) {
+	case NFS4_OK:
+	case NFS4ERR_DELAY:
+		dprintk(1, "%s: m=%p: layout_recall resent\n",
+			__func__, srv_layout.layout_recall_msg);
+		enqueue(&cl_msg_queue, srv_layout.layout_recall_msg);
+		break;
+	case NFS4ERR_NOMATCHING_LAYOUT:
+		layout_delete(&cl_layout, &m->range);
+		srv_layout.layout_recall_msg = NULL;
+		myfree(m);
+		break;
+	default:
+		BUG_ON(true);
+	}
+}
+
 void
 srv_recv_msg(void)
 {
@@ -121,15 +162,51 @@ srv_recv_msg(void)
 	case LAYOUTRETURN:
 		srv_recv_layoutreturn(m);
 		break;
+	case CB_LAYOUT_RECALL:
+		srv_recv_cb_layout_recall(m);
+		return;
 	default:
 		BUG_ON(true);
 	}
 	enqueue(&cl_msg_queue, m);
 }
 
+static void
+srv_recall_layout(void)
+{
+	struct msg *m;
+
+	if (srv_layout.layout_recall_msg) {
+		dprintk(1, "%s: m=%p layout_recall already in progress: status=%d\n",
+			__func__,
+			srv_layout.layout_recall_msg,
+			srv_layout.layout_recall_msg->status);
+		return;
+	}
+
+	dprintk(1, "%s\n", __func__);
+	m = myzalloc(sizeof(*m));
+	m->type = CB_LAYOUT_RECALL;
+	m->range.offset = mynrand(MAX_LO_MSG_OFFSET) & ~BLOCK_MASK;
+	m->range.length = BLOCK_SIZE + mynrand(MAX_LO_MSG_LENGTH - BLOCK_SIZE);
+	m->range.iomode = IOMODE_READ + mynrand(3);
+	/* bump server stateid.seq */
+	srv_layout.stateid.seq++;
+	m->stateid =  srv_layout.stateid;
+	m->status = -1;
+	srv_layout.layout_recall_msg = m;
+	dump_msg(m);
+
+	enqueue(&cl_msg_queue, m);
+}
+
+struct rand_event srv_events[] = {
+	{ 75, srv_recv_msg },
+	{ 25, srv_recall_layout },
+};
+
 void
 srv_draw_event(void)
 {
-	srv_recv_msg();
+	rand_call(srv_events);
 }
-
-- 
1.7.3.4

