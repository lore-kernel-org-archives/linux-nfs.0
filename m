Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:53413 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755498AbaF3Pz3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:55:29 -0400
Received: by mail-qa0-f51.google.com with SMTP id j7so6519822qaq.24
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:55:28 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 114/114] nfsd: add some comments to the nfsd4 object definitions
Date: Mon, 30 Jun 2014 11:55:01 -0400
Message-Id: <1404143701-24740-16-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add some comments that describe what each of these objects is, and how
they related to one another.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/netns.h |  8 +++++
 fs/nfsd/state.h | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 92 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 831abbdc6c52..4daa485a4a1d 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -34,6 +34,14 @@
 struct cld_net;
 struct nfsd4_client_tracking_ops;
 
+/*
+ * Represents a nfsd "container". With respect to nfsv4 state tracking, the
+ * fields of interest are the *_id_hashtbls and the *_name_tree. These track
+ * the nfs4_client objects by either short or long form clientid.
+ *
+ * Each nfsd_net runs a nfs4_laundromat workqueue job every lease period to
+ * clean up expired clients and delegations within the container.
+ */
 struct nfsd_net {
 	struct cld_net *cld_net;
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c39ff5e1509f..806225fcda11 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -72,6 +72,11 @@ struct nfsd4_callback {
 	bool cb_done;
 };
 
+/*
+ * A core object that represents a "common" stateid. These are generally
+ * embedded within the different (more specific) stateid objects and contain
+ * fields that are of general use to any stateid.
+ */
 struct nfs4_stid {
 	atomic_t sc_count;
 #define NFS4_OPEN_STID 1
@@ -90,6 +95,18 @@ struct nfs4_stid {
 	void (*sc_free)(struct nfs4_stid *);
 };
 
+/*
+ * Represents a delegation stateid. The nfs4_client holds references to these
+ * and they are put when it is being destroyed or when the delegation is
+ * returned by the client.
+ *
+ * If the server attempts to recall a delegation and the client doesn't do so
+ * before a timeout, the server may also revoke the delegation. In that case,
+ * the object will either be destroyed (v4.0) or moved to a per-client list of
+ * revoked delegations (v4.1+).
+ *
+ * This object is a superset of the nfs4_stid.
+ */
 struct nfs4_delegation {
 	struct nfs4_stid	dl_stid; /* must be first field */
 	struct list_head	dl_perfile;
@@ -197,6 +214,11 @@ struct nfsd4_conn {
 	unsigned char cn_flags;
 };
 
+/*
+ * Representation of a v4.1+ session. These are refcounted in a similar fashion
+ * to the nfs4_client. References are only taken when the server is actively
+ * working on the object (primarily during the processing of compounds).
+ */
 struct nfsd4_session {
 	atomic_t		se_ref;
 	struct list_head	se_hash;	/* hash by sessionid */
@@ -226,13 +248,30 @@ struct nfsd4_sessionid {
 
 /*
  * struct nfs4_client - one per client.  Clientids live here.
- * 	o Each nfs4_client is hashed by clientid.
  *
- * 	o Each nfs4_clients is also hashed by name 
- * 	  (the opaque quantity initially sent by the client to identify itself).
+ * The initial object created by an NFS client using SETCLIENTID (for NFSv4.0)
+ * or EXCHANGE_ID (for NFSv4.1+). These objects are refcounted and timestamped.
+ * Each nfsd_net_ns object contains a set of these and they are tracked via
+ * short and long form clientid. They are hashed and searched for under the
+ * per-nfsd_net client_lock spinlock.
+ *
+ * References to it are only held during the processing of compounds, and in
+ * certain other operations. In their "resting state" they have a refcount of
+ * 0. If they are not renewed within a lease period, they become eligible for
+ * destruction by the laundromat.
+ *
+ * These objects can also be destroyed prematurely by the fault injection code,
+ * or if the client sends certain forms of SETCLIENTID or EXCHANGE_ID updates.
+ * Care is taken *not* to do this however when the objects have an elevated
+ * refcount.
+ *
+ * o Each nfs4_client is hashed by clientid
+ *
+ * o Each nfs4_clients is also hashed by name (the opaque quantity initially
+ *   sent by the client to identify itself).
  * 	  
- *	o cl_perclient list is used to ensure no dangling stateowner references
- *	  when we expire the nfs4_client
+ * o cl_perclient list is used to ensure no dangling stateowner references
+ *   when we expire the nfs4_client
  */
 struct nfs4_client {
 	struct list_head	cl_idhash; 	/* hash by cl_clientid.id */
@@ -335,6 +374,12 @@ struct nfs4_replay {
 	char			rp_ibuf[NFSD4_REPLAY_ISIZE];
 };
 
+/*
+ * A core object that represents either an open or lock owner. The object and
+ * lock owner objects have one of these embedded within them. Refcounts and
+ * other fields common to both owner types are contained within these
+ * structures.
+ */
 struct nfs4_stateowner {
 	struct list_head        so_strhash;   /* hash by op_name */
 	struct list_head        so_stateids;
@@ -351,6 +396,12 @@ struct nfs4_stateowner {
 	void (*so_unhash)(struct nfs4_stateowner *);
 };
 
+/*
+ * When a file is opened, the client provides an open state owner opaque string
+ * that indicates the "owner" of that open. These objects are refcounted.
+ * References to it are held by each open state associated with it. This object
+ * is a superset of the nfs4_stateowner struct.
+ */
 struct nfs4_openowner {
 	struct nfs4_stateowner	oo_owner; /* must be first field */
 	struct list_head        oo_perclient;
@@ -368,6 +419,12 @@ struct nfs4_openowner {
 	unsigned char		oo_flags;
 };
 
+/*
+ * Represents a generic "lockowner". Similar to an openowner. References to it
+ * are held by the lock stateids that are created on its behalf. This object is
+ * a superset of the nfs4_stateowner struct (or would be if it needed any extra
+ * fields).
+ */
 struct nfs4_lockowner {
 	struct nfs4_stateowner	lo_owner; /* must be first element */
 };
@@ -382,7 +439,14 @@ static inline struct nfs4_lockowner * lockowner(struct nfs4_stateowner *so)
 	return container_of(so, struct nfs4_lockowner, lo_owner);
 }
 
-/* nfs4_file: a file opened by some number of (open) nfs4_stateowners. */
+/*
+ * nfs4_file: a file opened by some number of (open) nfs4_stateowners.
+ *
+ * These objects are global. nfsd only keeps one instance of a nfs4_file per
+ * inode (though it may keep multiple file descriptors open per inode). These
+ * are tracked in the file_hashtbl which is protected by the state_lock
+ * spinlock.
+ */
 struct nfs4_file {
 	atomic_t		fi_ref;
 	spinlock_t		fi_lock;
@@ -407,7 +471,20 @@ struct nfs4_file {
 	bool			fi_had_conflict;
 };
 
-/* "ol" stands for "Open or Lock".  Better suggestions welcome. */
+/*
+ * A generic struct representing either a open or lock stateid. The nfs4_client
+ * holds a reference to each of these objects, and they in turn hold a
+ * reference to their respective stateowners. The client's reference is
+ * released in response to a close or unlock (depending on whether it's an open
+ * or lock stateid) or when the client is being destroyed.
+ *
+ * In the case of v4.0 open stateids, these objects are preserved for a little
+ * while after close in order to handle CLOSE replays. Those are eventually
+ * reclaimed via a LRU scheme by the laundromat.
+ *
+ * This object is a superset of the nfs4_stid. "ol" stands for "Open or Lock".
+ * Better suggestions welcome.
+ */
 struct nfs4_ol_stateid {
 	struct nfs4_stid    st_stid; /* must be first field */
 	struct list_head              st_perfile;
-- 
1.9.3

