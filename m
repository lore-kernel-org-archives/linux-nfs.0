Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f173.google.com ([209.85.212.173]:40353 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902Ab3EKCoV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:21 -0400
Received: by mail-wi0-f173.google.com with SMTP id ey16so1203012wid.12
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:20 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id x13sm1398510wib.3.2013.05.10.19.44.18
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:19 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 28/38] pnfsd: layout state: introduce ls_client backpointer
Date: Sat, 11 May 2013 05:44:15 +0300
Message-Id: <1368240255-737-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And enlist the layout state on the client cl_lo_states list.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 16 +++++++++++++++-
 fs/nfsd/nfs4state.c |  1 +
 fs/nfsd/pnfsd.h     |  2 ++
 fs/nfsd/state.h     |  1 +
 4 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index b147427..50b5208 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -131,11 +131,14 @@ struct sbid_tracker {
 		return new;
 	kref_init(&new->ls_ref);
 	nfsd4_init_stid(&new->ls_stid, clp, NFS4_LAYOUT_STID);
+	INIT_LIST_HEAD(&new->ls_perclnt);
 	INIT_LIST_HEAD(&new->ls_perfile);
+	new->ls_client = clp;
 	get_nfs4_file(fp);	/* released on destroy_layout_state */
 	new->ls_file = fp;
 	new->ls_roc = false;
 	spin_lock(&layout_lock);
+	list_add(&new->ls_perclnt, &clp->cl_lo_states);
 	list_add(&new->ls_perfile, &fp->fi_lo_states);
 	spin_unlock(&layout_lock);
 	return new;
@@ -147,6 +150,17 @@ struct sbid_tracker {
 	kref_get(&ls->ls_ref);
 }
 
+/*
+ * Note: always called under the layout_lock
+ */
+static void
+unhash_layout_state(struct nfs4_layout_state *ls)
+{
+	ASSERT_LAYOUT_LOCKED();
+	list_del_init(&ls->ls_perclnt);
+	list_del_init(&ls->ls_perfile);
+}
+
 static void
 destroy_layout_state(struct kref *kref)
 {
@@ -156,7 +170,7 @@ struct sbid_tracker {
 	nfsd4_unhash_stid(&ls->ls_stid);
 	if (!list_empty(&ls->ls_perfile)) {
 		spin_lock(&layout_lock);
-		list_del(&ls->ls_perfile);
+		unhash_layout_state(ls);
 		spin_unlock(&layout_lock);
 	}
 	put_nfs4_file(ls->ls_file);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 12eed1d..4f40327 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1322,6 +1322,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	INIT_LIST_HEAD(&clp->cl_delegations);
 #if defined(CONFIG_PNFSD)
 	INIT_LIST_HEAD(&clp->cl_layouts);
+	INIT_LIST_HEAD(&clp->cl_lo_states);
 	INIT_LIST_HEAD(&clp->cl_layoutrecalls);
 #endif /* CONFIG_PNFSD */
 	INIT_LIST_HEAD(&clp->cl_lru);
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 6301c51..454ef23 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -44,6 +44,8 @@
 struct nfs4_layout_state {
 	struct nfs4_stid	ls_stid; /* must be first field */
 	struct kref		ls_ref;
+	struct list_head	ls_perclnt;
+	struct nfs4_client	*ls_client;
 	struct list_head	ls_perfile;
 	struct nfs4_file	*ls_file;
 	bool			ls_roc;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c185025..e026e0d 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -283,6 +283,7 @@ struct nfs4_client {
 	struct net		*net;
 #if defined(CONFIG_PNFSD)
 	struct list_head	cl_layouts;	/* outstanding layouts */
+	struct list_head	cl_lo_states;	/* outstanding layout states */
 	struct list_head	cl_layoutrecalls; /* outstanding layoutrecall
 						     callbacks */
 #endif /* CONFIG_PNFSD */
-- 
1.7.11.7

