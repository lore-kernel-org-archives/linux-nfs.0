Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:9745 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756013Ab2KZURO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:14 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 25/28] NFSv4.1: Cleanup move session slot management to fs/nfs/nfs4session.c
Date: Mon, 26 Nov 2012 15:16:42 -0500
Message-Id: <1353961005-63874-26-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-25-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-11-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-15-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-16-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-17-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-18-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-19-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-20-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-21-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-22-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-23-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-24-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-25-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.1 session management is getting complex enough to deserve
a separate file.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/Makefile            |   2 +-
 fs/nfs/callback_proc.c     |   1 +
 fs/nfs/internal.h          |   2 -
 fs/nfs/nfs4_fs.h           |  11 --
 fs/nfs/nfs4client.c        |   1 +
 fs/nfs/nfs4filelayoutdev.c |   1 +
 fs/nfs/nfs4proc.c          | 415 +-----------------------------------------
 fs/nfs/nfs4session.c       | 436 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4session.h       |  35 ++++
 9 files changed, 477 insertions(+), 427 deletions(-)
 create mode 100644 fs/nfs/nfs4session.c
 create mode 100644 fs/nfs/nfs4session.h

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index b7db608..cce2c05 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -24,7 +24,7 @@ nfsv4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o
 	  delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
 	  nfs4namespace.o nfs4getroot.o nfs4client.o
 nfsv4-$(CONFIG_SYSCTL)	+= nfs4sysctl.o
-nfsv4-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
+nfsv4-$(CONFIG_NFS_V4_1)	+= nfs4session.o pnfs.o pnfs_dev.o
 
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f99faad..c89b26b 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -14,6 +14,7 @@
 #include "delegation.h"
 #include "internal.h"
 #include "pnfs.h"
+#include "nfs4session.h"
 
 #ifdef NFS_DEBUG
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 05521ca..8965a99 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -276,8 +276,6 @@ extern const u32 nfs41_maxwrite_overhead;
 extern struct rpc_procinfo nfs4_procedures[];
 #endif
 
-extern int nfs4_init_ds_session(struct nfs_client *, unsigned long);
-
 /* proc.c */
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
 extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 2f6a9f9..cd3e309 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -249,19 +249,13 @@ extern int nfs4_setup_sequence(const struct nfs_server *server,
 extern int nfs41_setup_sequence(struct nfs4_session *session,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		struct rpc_task *task);
-extern void nfs4_destroy_session(struct nfs4_session *session);
-extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
 extern int nfs4_proc_create_session(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_destroy_session(struct nfs4_session *, struct rpc_cred *);
-extern int nfs4_init_session(struct nfs_server *server);
 extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 		struct nfs_fsinfo *fsinfo);
 extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
 				  bool sync);
 
-extern void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
-		u32 target_highest_slotid);
-
 static inline bool
 is_ds_only_client(struct nfs_client *clp)
 {
@@ -287,11 +281,6 @@ static inline int nfs4_setup_sequence(const struct nfs_server *server,
 	return 0;
 }
 
-static inline int nfs4_init_session(struct nfs_server *server)
-{
-	return 0;
-}
-
 static inline bool
 is_ds_only_client(struct nfs_client *clp)
 {
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 72717e6..acc3472 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -12,6 +12,7 @@
 #include "internal.h"
 #include "callback.h"
 #include "delegation.h"
+#include "nfs4session.h"
 #include "pnfs.h"
 #include "netns.h"
 
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 93e2530..b720064 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -33,6 +33,7 @@
 #include <linux/module.h>
 
 #include "internal.h"
+#include "nfs4session.h"
 #include "nfs4filelayout.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS_LD
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ff7daa0..ae6954c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -52,7 +52,6 @@
 #include <linux/mount.h>
 #include <linux/module.h>
 #include <linux/nfs_idmap.h>
-#include <linux/sunrpc/bc_xprt.h>
 #include <linux/xattr.h>
 #include <linux/utsname.h>
 #include <linux/freezer.h>
@@ -64,6 +63,8 @@
 #include "callback.h"
 #include "pnfs.h"
 #include "netns.h"
+#include "nfs4session.h"
+
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
@@ -378,64 +379,6 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 
 #if defined(CONFIG_NFS_V4_1)
 
-/*
- * nfs4_shrink_slot_table - free retired slots from the slot table
- */
-static void nfs4_shrink_slot_table(struct nfs4_slot_table  *tbl, u32 newsize)
-{
-	struct nfs4_slot **p;
-	if (newsize >= tbl->max_slots)
-		return;
-
-	p = &tbl->slots;
-	while (newsize--)
-		p = &(*p)->next;
-	while (*p) {
-		struct nfs4_slot *slot = *p;
-
-		*p = slot->next;
-		kfree(slot);
-		tbl->max_slots--;
-	}
-}
-
-/*
- * nfs4_free_slot - free a slot and efficiently update slot table.
- *
- * freeing a slot is trivially done by clearing its respective bit
- * in the bitmap.
- * If the freed slotid equals highest_used_slotid we want to update it
- * so that the server would be able to size down the slot table if needed,
- * otherwise we know that the highest_used_slotid is still in use.
- * When updating highest_used_slotid there may be "holes" in the bitmap
- * so we need to scan down from highest_used_slotid to 0 looking for the now
- * highest slotid in use.
- * If none found, highest_used_slotid is set to NFS4_NO_SLOT.
- *
- * Must be called while holding tbl->slot_tbl_lock
- */
-static void
-nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
-{
-	u32 slotid = slot->slot_nr;
-
-	/* clear used bit in bitmap */
-	__clear_bit(slotid, tbl->used_slots);
-
-	/* update highest_used_slotid when it is freed */
-	if (slotid == tbl->highest_used_slotid) {
-		u32 new_max = find_last_bit(tbl->used_slots, slotid);
-		if (new_max < slotid)
-			tbl->highest_used_slotid = new_max;
-		else {
-			tbl->highest_used_slotid = NFS4_NO_SLOT;
-			nfs4_session_drain_complete(tbl->session, tbl);
-		}
-	}
-	dprintk("%s: slotid %u highest_used_slotid %d\n", __func__,
-		slotid, tbl->highest_used_slotid);
-}
-
 bool nfs4_set_task_privileged(struct rpc_task *task, void *dummy)
 {
 	rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
@@ -466,56 +409,6 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	res->sr_slot = NULL;
 }
 
-/* Update the client's idea of target_highest_slotid */
-static void nfs41_set_target_slotid_locked(struct nfs4_slot_table *tbl,
-		u32 target_highest_slotid)
-{
-	unsigned int max_slotid, i;
-
-	if (tbl->target_highest_slotid == target_highest_slotid)
-		return;
-	tbl->target_highest_slotid = target_highest_slotid;
-	tbl->generation++;
-
-	max_slotid = min(NFS4_MAX_SLOT_TABLE - 1, tbl->target_highest_slotid);
-	for (i = tbl->max_slotid + 1; i <= max_slotid; i++)
-		rpc_wake_up_next(&tbl->slot_tbl_waitq);
-	tbl->max_slotid = max_slotid;
-}
-
-void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
-		u32 target_highest_slotid)
-{
-	spin_lock(&tbl->slot_tbl_lock);
-	nfs41_set_target_slotid_locked(tbl, target_highest_slotid);
-	spin_unlock(&tbl->slot_tbl_lock);
-}
-
-static void nfs41_set_server_slotid_locked(struct nfs4_slot_table *tbl,
-		u32 highest_slotid)
-{
-	if (tbl->server_highest_slotid == highest_slotid)
-		return;
-	if (tbl->highest_used_slotid > highest_slotid)
-		return;
-	/* Deallocate slots */
-	nfs4_shrink_slot_table(tbl, highest_slotid + 1);
-	tbl->server_highest_slotid = highest_slotid;
-}
-
-static void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
-		struct nfs4_slot *slot,
-		struct nfs4_sequence_res *res)
-{
-	spin_lock(&tbl->slot_tbl_lock);
-	if (tbl->generation != slot->generation)
-		goto out;
-	nfs41_set_server_slotid_locked(tbl, res->sr_highest_slotid);
-	nfs41_set_target_slotid_locked(tbl, res->sr_target_highest_slotid);
-out:
-	spin_unlock(&tbl->slot_tbl_lock);
-}
-
 static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 {
 	struct nfs4_session *session;
@@ -586,79 +479,6 @@ static int nfs4_sequence_done(struct rpc_task *task,
 	return nfs41_sequence_done(task, res);
 }
 
-static struct nfs4_slot *nfs4_new_slot(struct nfs4_slot_table  *tbl,
-		u32 slotid, u32 seq_init, gfp_t gfp_mask)
-{
-	struct nfs4_slot *slot;
-
-	slot = kzalloc(sizeof(*slot), gfp_mask);
-	if (slot) {
-		slot->table = tbl;
-		slot->slot_nr = slotid;
-		slot->seq_nr = seq_init;
-	}
-	return slot;
-}
-
-static struct nfs4_slot *nfs4_find_or_create_slot(struct nfs4_slot_table  *tbl,
-		u32 slotid, u32 seq_init, gfp_t gfp_mask)
-{
-	struct nfs4_slot **p, *slot;
-
-	p = &tbl->slots;
-	for (;;) {
-		if (*p == NULL) {
-			*p = nfs4_new_slot(tbl, tbl->max_slots,
-					seq_init, gfp_mask);
-			if (*p == NULL)
-				break;
-			tbl->max_slots++;
-		}
-		slot = *p;
-		if (slot->slot_nr == slotid)
-			return slot;
-		p = &slot->next;
-	}
-	return ERR_PTR(-ENOMEM);
-}
-
-/*
- * nfs4_alloc_slot - efficiently look for a free slot
- *
- * nfs4_alloc_slot looks for an unset bit in the used_slots bitmap.
- * If found, we mark the slot as used, update the highest_used_slotid,
- * and respectively set up the sequence operation args.
- *
- * Note: must be called with under the slot_tbl_lock.
- */
-static struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl)
-{
-	struct nfs4_slot *ret = ERR_PTR(-EBUSY);
-	u32 slotid;
-
-	dprintk("--> %s used_slots=%04lx highest_used=%u max_slots=%u\n",
-		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
-		tbl->max_slotid + 1);
-	slotid = find_first_zero_bit(tbl->used_slots, tbl->max_slotid + 1);
-	if (slotid > tbl->max_slotid)
-		goto out;
-	ret = nfs4_find_or_create_slot(tbl, slotid, 1, GFP_NOWAIT);
-	if (IS_ERR(ret))
-		goto out;
-	__set_bit(slotid, tbl->used_slots);
-	if (slotid > tbl->highest_used_slotid ||
-			tbl->highest_used_slotid == NFS4_NO_SLOT)
-		tbl->highest_used_slotid = slotid;
-	ret->renewal_time = jiffies;
-	ret->generation = tbl->generation;
-
-out:
-	dprintk("<-- %s used_slots=%04lx highest_used=%d slotid=%d \n",
-		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
-		!IS_ERR(ret) ? ret->slot_nr : -1);
-	return ret;
-}
-
 static void nfs41_init_sequence(struct nfs4_sequence_args *args,
 		struct nfs4_sequence_res *res, int cache_reply)
 {
@@ -5717,143 +5537,6 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	return status;
 }
 
-static int nfs4_grow_slot_table(struct nfs4_slot_table *tbl,
-		 u32 max_reqs, u32 ivalue)
-{
-	if (max_reqs <= tbl->max_slots)
-		return 0;
-	if (!IS_ERR(nfs4_find_or_create_slot(tbl, max_reqs - 1, ivalue, GFP_NOFS)))
-		return 0;
-	return -ENOMEM;
-}
-
-static void nfs4_reset_slot_table(struct nfs4_slot_table *tbl,
-		u32 server_highest_slotid,
-		u32 ivalue)
-{
-	struct nfs4_slot **p;
-
-	nfs4_shrink_slot_table(tbl, server_highest_slotid + 1);
-	p = &tbl->slots;
-	while (*p) {
-		(*p)->seq_nr = ivalue;
-		p = &(*p)->next;
-	}
-	tbl->highest_used_slotid = NFS4_NO_SLOT;
-	tbl->target_highest_slotid = server_highest_slotid;
-	tbl->server_highest_slotid = server_highest_slotid;
-	tbl->max_slotid = server_highest_slotid;
-}
-
-/*
- * (re)Initialise a slot table
- */
-static int nfs4_realloc_slot_table(struct nfs4_slot_table *tbl,
-		u32 max_reqs, u32 ivalue)
-{
-	int ret;
-
-	dprintk("--> %s: max_reqs=%u, tbl->max_slots %d\n", __func__,
-		max_reqs, tbl->max_slots);
-
-	if (max_reqs > NFS4_MAX_SLOT_TABLE)
-		max_reqs = NFS4_MAX_SLOT_TABLE;
-
-	ret = nfs4_grow_slot_table(tbl, max_reqs, ivalue);
-	if (ret)
-		goto out;
-
-	spin_lock(&tbl->slot_tbl_lock);
-	nfs4_reset_slot_table(tbl, max_reqs - 1, ivalue);
-	spin_unlock(&tbl->slot_tbl_lock);
-
-	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
-		tbl, tbl->slots, tbl->max_slots);
-out:
-	dprintk("<-- %s: return %d\n", __func__, ret);
-	return ret;
-}
-
-/* Destroy the slot table */
-static void nfs4_destroy_slot_tables(struct nfs4_session *session)
-{
-	nfs4_shrink_slot_table(&session->fc_slot_table, 0);
-	nfs4_shrink_slot_table(&session->bc_slot_table, 0);
-}
-
-/*
- * Initialize or reset the forechannel and backchannel tables
- */
-static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
-{
-	struct nfs4_slot_table *tbl;
-	int status;
-
-	dprintk("--> %s\n", __func__);
-	/* Fore channel */
-	tbl = &ses->fc_slot_table;
-	tbl->session = ses;
-	status = nfs4_realloc_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
-	if (status) /* -ENOMEM */
-		return status;
-	/* Back channel */
-	tbl = &ses->bc_slot_table;
-	tbl->session = ses;
-	status = nfs4_realloc_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
-	if (status && tbl->slots == NULL)
-		/* Fore and back channel share a connection so get
-		 * both slot tables or neither */
-		nfs4_destroy_slot_tables(ses);
-	return status;
-}
-
-struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
-{
-	struct nfs4_session *session;
-	struct nfs4_slot_table *tbl;
-
-	session = kzalloc(sizeof(struct nfs4_session), GFP_NOFS);
-	if (!session)
-		return NULL;
-
-	tbl = &session->fc_slot_table;
-	tbl->highest_used_slotid = NFS4_NO_SLOT;
-	spin_lock_init(&tbl->slot_tbl_lock);
-	rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq, "ForeChannel Slot table");
-	init_completion(&tbl->complete);
-
-	tbl = &session->bc_slot_table;
-	tbl->highest_used_slotid = NFS4_NO_SLOT;
-	spin_lock_init(&tbl->slot_tbl_lock);
-	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel Slot table");
-	init_completion(&tbl->complete);
-
-	session->session_state = 1<<NFS4_SESSION_INITING;
-
-	session->clp = clp;
-	return session;
-}
-
-void nfs4_destroy_session(struct nfs4_session *session)
-{
-	struct rpc_xprt *xprt;
-	struct rpc_cred *cred;
-
-	cred = nfs4_get_exchange_id_cred(session->clp);
-	nfs4_proc_destroy_session(session, cred);
-	if (cred)
-		put_rpccred(cred);
-
-	rcu_read_lock();
-	xprt = rcu_dereference(session->clp->cl_rpcclient->cl_xprt);
-	rcu_read_unlock();
-	dprintk("%s Destroy backchannel for xprt %p\n",
-		__func__, xprt);
-	xprt_destroy_backchannel(xprt, NFS41_BC_MIN_CALLBACKS);
-	nfs4_destroy_slot_tables(session);
-	kfree(session);
-}
-
 /*
  * Initialize the values to be used by the client in CREATE_SESSION
  * If nfs4_init_session set the fore channel request and response sizes,
@@ -6048,100 +5731,6 @@ int nfs4_proc_destroy_session(struct nfs4_session *session,
 }
 
 /*
- * With sessions, the client is not marked ready until after a
- * successful EXCHANGE_ID and CREATE_SESSION.
- *
- * Map errors cl_cons_state errors to EPROTONOSUPPORT to indicate
- * other versions of NFS can be tried.
- */
-static int nfs41_check_session_ready(struct nfs_client *clp)
-{
-	int ret;
-	
-	if (clp->cl_cons_state == NFS_CS_SESSION_INITING) {
-		ret = nfs4_client_recover_expired_lease(clp);
-		if (ret)
-			return ret;
-	}
-	if (clp->cl_cons_state < NFS_CS_READY)
-		return -EPROTONOSUPPORT;
-	smp_rmb();
-	return 0;
-}
-
-int nfs4_init_session(struct nfs_server *server)
-{
-	struct nfs_client *clp = server->nfs_client;
-	struct nfs4_session *session;
-	unsigned int target_max_rqst_sz = NFS_MAX_FILE_IO_SIZE;
-	unsigned int target_max_resp_sz = NFS_MAX_FILE_IO_SIZE;
-
-	if (!nfs4_has_session(clp))
-		return 0;
-
-	if (server->rsize != 0)
-		target_max_resp_sz = server->rsize;
-	target_max_resp_sz += nfs41_maxread_overhead;
-
-	if (server->wsize != 0)
-		target_max_rqst_sz = server->wsize;
-	target_max_rqst_sz += nfs41_maxwrite_overhead;
-
-	session = clp->cl_session;
-	spin_lock(&clp->cl_lock);
-	if (test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state)) {
-		/* Initialise targets and channel attributes */
-		session->fc_target_max_rqst_sz = target_max_rqst_sz;
-		session->fc_attrs.max_rqst_sz = target_max_rqst_sz;
-		session->fc_target_max_resp_sz = target_max_resp_sz;
-		session->fc_attrs.max_resp_sz = target_max_resp_sz;
-	} else {
-		/* Just adjust the targets */
-		if (target_max_rqst_sz > session->fc_target_max_rqst_sz) {
-			session->fc_target_max_rqst_sz = target_max_rqst_sz;
-			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
-		}
-		if (target_max_resp_sz > session->fc_target_max_resp_sz) {
-			session->fc_target_max_resp_sz = target_max_resp_sz;
-			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
-		}
-	}
-	spin_unlock(&clp->cl_lock);
-
-	if (test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state))
-		nfs4_schedule_lease_recovery(clp);
-
-	return nfs41_check_session_ready(clp);
-}
-
-int nfs4_init_ds_session(struct nfs_client *clp, unsigned long lease_time)
-{
-	struct nfs4_session *session = clp->cl_session;
-	int ret;
-
-	spin_lock(&clp->cl_lock);
-	if (test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state)) {
-		/*
-		 * Do not set NFS_CS_CHECK_LEASE_TIME instead set the
-		 * DS lease to be equal to the MDS lease.
-		 */
-		clp->cl_lease_time = lease_time;
-		clp->cl_last_renewal = jiffies;
-	}
-	spin_unlock(&clp->cl_lock);
-
-	ret = nfs41_check_session_ready(clp);
-	if (ret)
-		return ret;
-	/* Test for the DS role */
-	if (!is_ds_client(clp))
-		return -ENODEV;
-	return 0;
-}
-EXPORT_SYMBOL_GPL(nfs4_init_ds_session);
-
-
-/*
  * Renew the cl_session lease.
  */
 struct nfs4_sequence_data {
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
new file mode 100644
index 0000000..7011702
--- /dev/null
+++ b/fs/nfs/nfs4session.c
@@ -0,0 +1,436 @@
+/*
+ * fs/nfs/nfs4session.c
+ *
+ * Copyright (c) 2012 Trond Myklebust <Trond.Myklebust@netapp.com>
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/string.h>
+#include <linux/printk.h>
+#include <linux/slab.h>
+#include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/bc_xprt.h>
+#include <linux/nfs.h>
+#include <linux/nfs4.h>
+#include <linux/nfs_fs.h>
+#include <linux/module.h>
+
+#include "nfs4_fs.h"
+#include "internal.h"
+#include "nfs4session.h"
+#include "callback.h"
+
+#define NFSDBG_FACILITY		NFSDBG_STATE
+
+/*
+ * nfs4_shrink_slot_table - free retired slots from the slot table
+ */
+static void nfs4_shrink_slot_table(struct nfs4_slot_table  *tbl, u32 newsize)
+{
+	struct nfs4_slot **p;
+	if (newsize >= tbl->max_slots)
+		return;
+
+	p = &tbl->slots;
+	while (newsize--)
+		p = &(*p)->next;
+	while (*p) {
+		struct nfs4_slot *slot = *p;
+
+		*p = slot->next;
+		kfree(slot);
+		tbl->max_slots--;
+	}
+}
+
+/*
+ * nfs4_free_slot - free a slot and efficiently update slot table.
+ *
+ * freeing a slot is trivially done by clearing its respective bit
+ * in the bitmap.
+ * If the freed slotid equals highest_used_slotid we want to update it
+ * so that the server would be able to size down the slot table if needed,
+ * otherwise we know that the highest_used_slotid is still in use.
+ * When updating highest_used_slotid there may be "holes" in the bitmap
+ * so we need to scan down from highest_used_slotid to 0 looking for the now
+ * highest slotid in use.
+ * If none found, highest_used_slotid is set to NFS4_NO_SLOT.
+ *
+ * Must be called while holding tbl->slot_tbl_lock
+ */
+void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
+{
+	u32 slotid = slot->slot_nr;
+
+	/* clear used bit in bitmap */
+	__clear_bit(slotid, tbl->used_slots);
+
+	/* update highest_used_slotid when it is freed */
+	if (slotid == tbl->highest_used_slotid) {
+		u32 new_max = find_last_bit(tbl->used_slots, slotid);
+		if (new_max < slotid)
+			tbl->highest_used_slotid = new_max;
+		else {
+			tbl->highest_used_slotid = NFS4_NO_SLOT;
+			nfs4_session_drain_complete(tbl->session, tbl);
+		}
+	}
+	dprintk("%s: slotid %u highest_used_slotid %d\n", __func__,
+		slotid, tbl->highest_used_slotid);
+}
+
+static struct nfs4_slot *nfs4_new_slot(struct nfs4_slot_table  *tbl,
+		u32 slotid, u32 seq_init, gfp_t gfp_mask)
+{
+	struct nfs4_slot *slot;
+
+	slot = kzalloc(sizeof(*slot), gfp_mask);
+	if (slot) {
+		slot->table = tbl;
+		slot->slot_nr = slotid;
+		slot->seq_nr = seq_init;
+	}
+	return slot;
+}
+
+static struct nfs4_slot *nfs4_find_or_create_slot(struct nfs4_slot_table  *tbl,
+		u32 slotid, u32 seq_init, gfp_t gfp_mask)
+{
+	struct nfs4_slot **p, *slot;
+
+	p = &tbl->slots;
+	for (;;) {
+		if (*p == NULL) {
+			*p = nfs4_new_slot(tbl, tbl->max_slots,
+					seq_init, gfp_mask);
+			if (*p == NULL)
+				break;
+			tbl->max_slots++;
+		}
+		slot = *p;
+		if (slot->slot_nr == slotid)
+			return slot;
+		p = &slot->next;
+	}
+	return ERR_PTR(-ENOMEM);
+}
+
+/*
+ * nfs4_alloc_slot - efficiently look for a free slot
+ *
+ * nfs4_alloc_slot looks for an unset bit in the used_slots bitmap.
+ * If found, we mark the slot as used, update the highest_used_slotid,
+ * and respectively set up the sequence operation args.
+ *
+ * Note: must be called with under the slot_tbl_lock.
+ */
+struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl)
+{
+	struct nfs4_slot *ret = ERR_PTR(-EBUSY);
+	u32 slotid;
+
+	dprintk("--> %s used_slots=%04lx highest_used=%u max_slots=%u\n",
+		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
+		tbl->max_slotid + 1);
+	slotid = find_first_zero_bit(tbl->used_slots, tbl->max_slotid + 1);
+	if (slotid > tbl->max_slotid)
+		goto out;
+	ret = nfs4_find_or_create_slot(tbl, slotid, 1, GFP_NOWAIT);
+	if (IS_ERR(ret))
+		goto out;
+	__set_bit(slotid, tbl->used_slots);
+	if (slotid > tbl->highest_used_slotid ||
+			tbl->highest_used_slotid == NFS4_NO_SLOT)
+		tbl->highest_used_slotid = slotid;
+	ret->renewal_time = jiffies;
+	ret->generation = tbl->generation;
+
+out:
+	dprintk("<-- %s used_slots=%04lx highest_used=%d slotid=%d \n",
+		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
+		!IS_ERR(ret) ? ret->slot_nr : -1);
+	return ret;
+}
+
+static int nfs4_grow_slot_table(struct nfs4_slot_table *tbl,
+		 u32 max_reqs, u32 ivalue)
+{
+	if (max_reqs <= tbl->max_slots)
+		return 0;
+	if (!IS_ERR(nfs4_find_or_create_slot(tbl, max_reqs - 1, ivalue, GFP_NOFS)))
+		return 0;
+	return -ENOMEM;
+}
+
+static void nfs4_reset_slot_table(struct nfs4_slot_table *tbl,
+		u32 server_highest_slotid,
+		u32 ivalue)
+{
+	struct nfs4_slot **p;
+
+	nfs4_shrink_slot_table(tbl, server_highest_slotid + 1);
+	p = &tbl->slots;
+	while (*p) {
+		(*p)->seq_nr = ivalue;
+		p = &(*p)->next;
+	}
+	tbl->highest_used_slotid = NFS4_NO_SLOT;
+	tbl->target_highest_slotid = server_highest_slotid;
+	tbl->server_highest_slotid = server_highest_slotid;
+	tbl->max_slotid = server_highest_slotid;
+}
+
+/*
+ * (re)Initialise a slot table
+ */
+static int nfs4_realloc_slot_table(struct nfs4_slot_table *tbl,
+		u32 max_reqs, u32 ivalue)
+{
+	int ret;
+
+	dprintk("--> %s: max_reqs=%u, tbl->max_slots %d\n", __func__,
+		max_reqs, tbl->max_slots);
+
+	if (max_reqs > NFS4_MAX_SLOT_TABLE)
+		max_reqs = NFS4_MAX_SLOT_TABLE;
+
+	ret = nfs4_grow_slot_table(tbl, max_reqs, ivalue);
+	if (ret)
+		goto out;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	nfs4_reset_slot_table(tbl, max_reqs - 1, ivalue);
+	spin_unlock(&tbl->slot_tbl_lock);
+
+	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
+		tbl, tbl->slots, tbl->max_slots);
+out:
+	dprintk("<-- %s: return %d\n", __func__, ret);
+	return ret;
+}
+
+/* Destroy the slot table */
+static void nfs4_destroy_slot_tables(struct nfs4_session *session)
+{
+	nfs4_shrink_slot_table(&session->fc_slot_table, 0);
+	nfs4_shrink_slot_table(&session->bc_slot_table, 0);
+}
+
+/* Update the client's idea of target_highest_slotid */
+static void nfs41_set_target_slotid_locked(struct nfs4_slot_table *tbl,
+		u32 target_highest_slotid)
+{
+	unsigned int max_slotid, i;
+
+	if (tbl->target_highest_slotid == target_highest_slotid)
+		return;
+	tbl->target_highest_slotid = target_highest_slotid;
+	tbl->generation++;
+
+	max_slotid = min(NFS4_MAX_SLOT_TABLE - 1, tbl->target_highest_slotid);
+	for (i = tbl->max_slotid + 1; i <= max_slotid; i++)
+		rpc_wake_up_next(&tbl->slot_tbl_waitq);
+	tbl->max_slotid = max_slotid;
+}
+
+void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
+		u32 target_highest_slotid)
+{
+	spin_lock(&tbl->slot_tbl_lock);
+	nfs41_set_target_slotid_locked(tbl, target_highest_slotid);
+	spin_unlock(&tbl->slot_tbl_lock);
+}
+
+static void nfs41_set_server_slotid_locked(struct nfs4_slot_table *tbl,
+		u32 highest_slotid)
+{
+	if (tbl->server_highest_slotid == highest_slotid)
+		return;
+	if (tbl->highest_used_slotid > highest_slotid)
+		return;
+	/* Deallocate slots */
+	nfs4_shrink_slot_table(tbl, highest_slotid + 1);
+	tbl->server_highest_slotid = highest_slotid;
+}
+
+void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
+		struct nfs4_slot *slot,
+		struct nfs4_sequence_res *res)
+{
+	spin_lock(&tbl->slot_tbl_lock);
+	if (tbl->generation != slot->generation)
+		goto out;
+	nfs41_set_server_slotid_locked(tbl, res->sr_highest_slotid);
+	nfs41_set_target_slotid_locked(tbl, res->sr_target_highest_slotid);
+out:
+	spin_unlock(&tbl->slot_tbl_lock);
+}
+
+/*
+ * Initialize or reset the forechannel and backchannel tables
+ */
+int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
+{
+	struct nfs4_slot_table *tbl;
+	int status;
+
+	dprintk("--> %s\n", __func__);
+	/* Fore channel */
+	tbl = &ses->fc_slot_table;
+	tbl->session = ses;
+	status = nfs4_realloc_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
+	if (status) /* -ENOMEM */
+		return status;
+	/* Back channel */
+	tbl = &ses->bc_slot_table;
+	tbl->session = ses;
+	status = nfs4_realloc_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
+	if (status && tbl->slots == NULL)
+		/* Fore and back channel share a connection so get
+		 * both slot tables or neither */
+		nfs4_destroy_slot_tables(ses);
+	return status;
+}
+
+struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
+{
+	struct nfs4_session *session;
+	struct nfs4_slot_table *tbl;
+
+	session = kzalloc(sizeof(struct nfs4_session), GFP_NOFS);
+	if (!session)
+		return NULL;
+
+	tbl = &session->fc_slot_table;
+	tbl->highest_used_slotid = NFS4_NO_SLOT;
+	spin_lock_init(&tbl->slot_tbl_lock);
+	rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq, "ForeChannel Slot table");
+	init_completion(&tbl->complete);
+
+	tbl = &session->bc_slot_table;
+	tbl->highest_used_slotid = NFS4_NO_SLOT;
+	spin_lock_init(&tbl->slot_tbl_lock);
+	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel Slot table");
+	init_completion(&tbl->complete);
+
+	session->session_state = 1<<NFS4_SESSION_INITING;
+
+	session->clp = clp;
+	return session;
+}
+
+void nfs4_destroy_session(struct nfs4_session *session)
+{
+	struct rpc_xprt *xprt;
+	struct rpc_cred *cred;
+
+	cred = nfs4_get_exchange_id_cred(session->clp);
+	nfs4_proc_destroy_session(session, cred);
+	if (cred)
+		put_rpccred(cred);
+
+	rcu_read_lock();
+	xprt = rcu_dereference(session->clp->cl_rpcclient->cl_xprt);
+	rcu_read_unlock();
+	dprintk("%s Destroy backchannel for xprt %p\n",
+		__func__, xprt);
+	xprt_destroy_backchannel(xprt, NFS41_BC_MIN_CALLBACKS);
+	nfs4_destroy_slot_tables(session);
+	kfree(session);
+}
+
+/*
+ * With sessions, the client is not marked ready until after a
+ * successful EXCHANGE_ID and CREATE_SESSION.
+ *
+ * Map errors cl_cons_state errors to EPROTONOSUPPORT to indicate
+ * other versions of NFS can be tried.
+ */
+static int nfs41_check_session_ready(struct nfs_client *clp)
+{
+	int ret;
+	
+	if (clp->cl_cons_state == NFS_CS_SESSION_INITING) {
+		ret = nfs4_client_recover_expired_lease(clp);
+		if (ret)
+			return ret;
+	}
+	if (clp->cl_cons_state < NFS_CS_READY)
+		return -EPROTONOSUPPORT;
+	smp_rmb();
+	return 0;
+}
+
+int nfs4_init_session(struct nfs_server *server)
+{
+	struct nfs_client *clp = server->nfs_client;
+	struct nfs4_session *session;
+	unsigned int target_max_rqst_sz = NFS_MAX_FILE_IO_SIZE;
+	unsigned int target_max_resp_sz = NFS_MAX_FILE_IO_SIZE;
+
+	if (!nfs4_has_session(clp))
+		return 0;
+
+	if (server->rsize != 0)
+		target_max_resp_sz = server->rsize;
+	target_max_resp_sz += nfs41_maxread_overhead;
+
+	if (server->wsize != 0)
+		target_max_rqst_sz = server->wsize;
+	target_max_rqst_sz += nfs41_maxwrite_overhead;
+
+	session = clp->cl_session;
+	spin_lock(&clp->cl_lock);
+	if (test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state)) {
+		/* Initialise targets and channel attributes */
+		session->fc_target_max_rqst_sz = target_max_rqst_sz;
+		session->fc_attrs.max_rqst_sz = target_max_rqst_sz;
+		session->fc_target_max_resp_sz = target_max_resp_sz;
+		session->fc_attrs.max_resp_sz = target_max_resp_sz;
+	} else {
+		/* Just adjust the targets */
+		if (target_max_rqst_sz > session->fc_target_max_rqst_sz) {
+			session->fc_target_max_rqst_sz = target_max_rqst_sz;
+			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
+		}
+		if (target_max_resp_sz > session->fc_target_max_resp_sz) {
+			session->fc_target_max_resp_sz = target_max_resp_sz;
+			set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
+		}
+	}
+	spin_unlock(&clp->cl_lock);
+
+	if (test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state))
+		nfs4_schedule_lease_recovery(clp);
+
+	return nfs41_check_session_ready(clp);
+}
+
+int nfs4_init_ds_session(struct nfs_client *clp, unsigned long lease_time)
+{
+	struct nfs4_session *session = clp->cl_session;
+	int ret;
+
+	spin_lock(&clp->cl_lock);
+	if (test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state)) {
+		/*
+		 * Do not set NFS_CS_CHECK_LEASE_TIME instead set the
+		 * DS lease to be equal to the MDS lease.
+		 */
+		clp->cl_lease_time = lease_time;
+		clp->cl_last_renewal = jiffies;
+	}
+	spin_unlock(&clp->cl_lock);
+
+	ret = nfs41_check_session_ready(clp);
+	if (ret)
+		return ret;
+	/* Test for the DS role */
+	if (!is_ds_client(clp))
+		return -ENODEV;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nfs4_init_ds_session);
+
+
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
new file mode 100644
index 0000000..cb47b1e
--- /dev/null
+++ b/fs/nfs/nfs4session.h
@@ -0,0 +1,35 @@
+/*
+ * fs/nfs/nfs4session.h
+ *
+ * Copyright (c) 2012 Trond Myklebust <Trond.Myklebust@netapp.com>
+ *
+ */
+#ifndef __LINUX_FS_NFS_NFS4SESSION_H
+#define __LINUX_FS_NFS_NFS4SESSION_H
+
+#if defined(CONFIG_NFS_V4_1)
+extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
+extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
+
+extern void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
+		u32 target_highest_slotid);
+extern void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
+		struct nfs4_slot *slot,
+		struct nfs4_sequence_res *res);
+
+extern int nfs4_setup_session_slot_tables(struct nfs4_session *ses);
+
+extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
+extern void nfs4_destroy_session(struct nfs4_session *session);
+extern int nfs4_init_session(struct nfs_server *server);
+extern int nfs4_init_ds_session(struct nfs_client *, unsigned long);
+
+#else /* defined(CONFIG_NFS_V4_1) */
+
+static inline int nfs4_init_session(struct nfs_server *server)
+{
+	return 0;
+}
+
+#endif /* defined(CONFIG_NFS_V4_1) */
+#endif /* __LINUX_FS_NFS_NFS4SESSION_H */
-- 
1.7.11.7

