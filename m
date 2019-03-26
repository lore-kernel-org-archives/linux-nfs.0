Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0689FC4360F
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:06:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C74142087E
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:06:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731824AbfCZWGc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Mar 2019 18:06:32 -0400
Received: from mx1.redhat.com ([209.132.183.28]:46744 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731770AbfCZWGb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Mar 2019 18:06:31 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 024A8308FBA9;
        Tue, 26 Mar 2019 22:06:31 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-200.rdu2.redhat.com [10.10.122.200])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AD39160CC0;
        Tue, 26 Mar 2019 22:06:30 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 0F59720798; Tue, 26 Mar 2019 18:06:30 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org, jlayton@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH RFC v3 1/5] nfsd: make nfs4_client_reclaim use an xdr_netobj instead of a fixed char array
Date:   Tue, 26 Mar 2019 18:06:26 -0400
Message-Id: <20190326220630.2911-2-smayhew@redhat.com>
In-Reply-To: <20190326220630.2911-1-smayhew@redhat.com>
References: <20190326220630.2911-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Tue, 26 Mar 2019 22:06:31 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This will allow the reclaim_str_hashtbl to store either the recovery
directory names used by the legacy client tracking code or the full
client strings used by the nfsdcld client tracking code.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/nfs4recover.c | 109 +++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfs4state.c   |  30 ++++++------
 fs/nfsd/state.h       |   8 ++--
 3 files changed, 110 insertions(+), 37 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 5188f9f70c78..2243b909b407 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -169,13 +169,34 @@ legacy_recdir_name_error(struct nfs4_client *clp, int error)
 	}
 }
 
+static void
+__nfsd4_create_reclaim_record_grace(struct nfs4_client *clp,
+		const char *dname, int len, struct nfsd_net *nn)
+{
+	struct xdr_netobj name;
+	struct nfs4_client_reclaim *crp;
+
+	name.data = kmemdup(dname, len, GFP_KERNEL);
+	if (!name.data) {
+		dprintk("%s: failed to allocate memory for name.data!\n",
+			__func__);
+		return;
+	}
+	name.len = len;
+	crp = nfs4_client_to_reclaim(name, nn);
+	if (!crp) {
+		kfree(name.data);
+		return;
+	}
+	crp->cr_clp = clp;
+}
+
 static void
 nfsd4_create_clid_dir(struct nfs4_client *clp)
 {
 	const struct cred *original_cred;
 	char dname[HEXDIR_LEN];
 	struct dentry *dir, *dentry;
-	struct nfs4_client_reclaim *crp;
 	int status;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
@@ -221,11 +242,9 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 out_unlock:
 	inode_unlock(d_inode(dir));
 	if (status == 0) {
-		if (nn->in_grace) {
-			crp = nfs4_client_to_reclaim(dname, nn);
-			if (crp)
-				crp->cr_clp = clp;
-		}
+		if (nn->in_grace)
+			__nfsd4_create_reclaim_record_grace(clp, dname,
+					HEXDIR_LEN, nn);
 		vfs_fsync(nn->rec_file, 0);
 	} else {
 		printk(KERN_ERR "NFSD: failed to write recovery record"
@@ -345,11 +364,30 @@ nfsd4_unlink_clid_dir(char *name, int namlen, struct nfsd_net *nn)
 	return status;
 }
 
+static void
+__nfsd4_remove_reclaim_record_grace(const char *dname, int len,
+		struct nfsd_net *nn)
+{
+	struct xdr_netobj name;
+	struct nfs4_client_reclaim *crp;
+
+	name.data = kmemdup(dname, len, GFP_KERNEL);
+	if (!name.data) {
+		dprintk("%s: failed to allocate memory for name.data!\n",
+			__func__);
+		return;
+	}
+	name.len = len;
+	crp = nfsd4_find_reclaim_client(name, nn);
+	kfree(name.data);
+	if (crp)
+		nfs4_remove_reclaim_record(crp, nn);
+}
+
 static void
 nfsd4_remove_clid_dir(struct nfs4_client *clp)
 {
 	const struct cred *original_cred;
-	struct nfs4_client_reclaim *crp;
 	char dname[HEXDIR_LEN];
 	int status;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
@@ -374,12 +412,9 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 	nfs4_reset_creds(original_cred);
 	if (status == 0) {
 		vfs_fsync(nn->rec_file, 0);
-		if (nn->in_grace) {
-			/* remove reclaim record */
-			crp = nfsd4_find_reclaim_client(dname, nn);
-			if (crp)
-				nfs4_remove_reclaim_record(crp, nn);
-		}
+		if (nn->in_grace)
+			__nfsd4_remove_reclaim_record_grace(dname,
+					HEXDIR_LEN, nn);
 	}
 out_drop_write:
 	mnt_drop_write_file(nn->rec_file);
@@ -393,14 +428,31 @@ static int
 purge_old(struct dentry *parent, struct dentry *child, struct nfsd_net *nn)
 {
 	int status;
+	struct xdr_netobj name;
 
-	if (nfs4_has_reclaimed_state(child->d_name.name, nn))
+	if (child->d_name.len != HEXDIR_LEN - 1) {
+		printk("%s: illegal name %pd in recovery directory\n",
+				__func__, child);
+		/* Keep trying; maybe the others are OK: */
 		return 0;
+	}
+	name.data = kmemdup_nul(child->d_name.name, child->d_name.len, GFP_KERNEL);
+	if (!name.data) {
+		dprintk("%s: failed to allocate memory for name.data!\n",
+			__func__);
+		goto out;
+	}
+	name.len = HEXDIR_LEN;
+	if (nfs4_has_reclaimed_state(name, nn))
+		goto out_free;
 
 	status = vfs_rmdir(d_inode(parent), child);
 	if (status)
 		printk("failed to remove client recovery directory %pd\n",
 				child);
+out_free:
+	kfree(name.data);
+out:
 	/* Keep trying, success or failure: */
 	return 0;
 }
@@ -430,13 +482,24 @@ nfsd4_recdir_purge_old(struct nfsd_net *nn)
 static int
 load_recdir(struct dentry *parent, struct dentry *child, struct nfsd_net *nn)
 {
+	struct xdr_netobj name;
+
 	if (child->d_name.len != HEXDIR_LEN - 1) {
-		printk("nfsd4: illegal name %pd in recovery directory\n",
-				child);
+		printk("%s: illegal name %pd in recovery directory\n",
+				__func__, child);
 		/* Keep trying; maybe the others are OK: */
 		return 0;
 	}
-	nfs4_client_to_reclaim(child->d_name.name, nn);
+	name.data = kmemdup_nul(child->d_name.name, child->d_name.len, GFP_KERNEL);
+	if (!name.data) {
+		dprintk("%s: failed to allocate memory for name.data!\n",
+			__func__);
+		goto out;
+	}
+	name.len = HEXDIR_LEN;
+	if (!nfs4_client_to_reclaim(name, nn))
+		kfree(name.data);
+out:
 	return 0;
 }
 
@@ -616,6 +679,7 @@ nfsd4_check_legacy_client(struct nfs4_client *clp)
 	char dname[HEXDIR_LEN];
 	struct nfs4_client_reclaim *crp;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	struct xdr_netobj name;
 
 	/* did we already find that this client is stable? */
 	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
@@ -628,13 +692,22 @@ nfsd4_check_legacy_client(struct nfs4_client *clp)
 	}
 
 	/* look for it in the reclaim hashtable otherwise */
-	crp = nfsd4_find_reclaim_client(dname, nn);
+	name.data = kmemdup(dname, HEXDIR_LEN, GFP_KERNEL);
+	if (!name.data) {
+		dprintk("%s: failed to allocate memory for name.data!\n",
+			__func__);
+		goto out_enoent;
+	}
+	name.len = HEXDIR_LEN;
+	crp = nfsd4_find_reclaim_client(name, nn);
+	kfree(name.data);
 	if (crp) {
 		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
 		crp->cr_clp = clp;
 		return 0;
 	}
 
+out_enoent:
 	return -ENOENT;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6a45fb00c5fc..898f1c8c66ca 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1058,9 +1058,9 @@ static unsigned int clientid_hashval(u32 id)
 	return id & CLIENT_HASH_MASK;
 }
 
-static unsigned int clientstr_hashval(const char *name)
+static unsigned int clientstr_hashval(struct xdr_netobj name)
 {
-	return opaque_hashval(name, 8) & CLIENT_HASH_MASK;
+	return opaque_hashval(name.data, 8) & CLIENT_HASH_MASK;
 }
 
 /*
@@ -2039,11 +2039,6 @@ compare_blob(const struct xdr_netobj *o1, const struct xdr_netobj *o2)
 	return memcmp(o1->data, o2->data, o1->len);
 }
 
-static int same_name(const char *n1, const char *n2)
-{
-	return 0 == memcmp(n1, n2, HEXDIR_LEN);
-}
-
 static int
 same_verf(nfs4_verifier *v1, nfs4_verifier *v2)
 {
@@ -6449,7 +6444,7 @@ alloc_reclaim(void)
 }
 
 bool
-nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn)
+nfs4_has_reclaimed_state(struct xdr_netobj name, struct nfsd_net *nn)
 {
 	struct nfs4_client_reclaim *crp;
 
@@ -6459,20 +6454,24 @@ nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn)
 
 /*
  * failure => all reset bets are off, nfserr_no_grace...
+ *
+ * The caller is responsible for freeing name.data if NULL is returned (it
+ * will be freed in nfs4_remove_reclaim_record in the normal case).
  */
 struct nfs4_client_reclaim *
-nfs4_client_to_reclaim(const char *name, struct nfsd_net *nn)
+nfs4_client_to_reclaim(struct xdr_netobj name, struct nfsd_net *nn)
 {
 	unsigned int strhashval;
 	struct nfs4_client_reclaim *crp;
 
-	dprintk("NFSD nfs4_client_to_reclaim NAME: %.*s\n", HEXDIR_LEN, name);
+	dprintk("NFSD nfs4_client_to_reclaim NAME: %.*s\n", name.len, name.data);
 	crp = alloc_reclaim();
 	if (crp) {
 		strhashval = clientstr_hashval(name);
 		INIT_LIST_HEAD(&crp->cr_strhash);
 		list_add(&crp->cr_strhash, &nn->reclaim_str_hashtbl[strhashval]);
-		memcpy(crp->cr_recdir, name, HEXDIR_LEN);
+		crp->cr_name.data = name.data;
+		crp->cr_name.len = name.len;
 		crp->cr_clp = NULL;
 		nn->reclaim_str_hashtbl_size++;
 	}
@@ -6483,6 +6482,7 @@ void
 nfs4_remove_reclaim_record(struct nfs4_client_reclaim *crp, struct nfsd_net *nn)
 {
 	list_del(&crp->cr_strhash);
+	kfree(crp->cr_name.data);
 	kfree(crp);
 	nn->reclaim_str_hashtbl_size--;
 }
@@ -6506,16 +6506,16 @@ nfs4_release_reclaim(struct nfsd_net *nn)
 /*
  * called from OPEN, CLAIM_PREVIOUS with a new clientid. */
 struct nfs4_client_reclaim *
-nfsd4_find_reclaim_client(const char *recdir, struct nfsd_net *nn)
+nfsd4_find_reclaim_client(struct xdr_netobj name, struct nfsd_net *nn)
 {
 	unsigned int strhashval;
 	struct nfs4_client_reclaim *crp = NULL;
 
-	dprintk("NFSD: nfs4_find_reclaim_client for recdir %s\n", recdir);
+	dprintk("NFSD: nfs4_find_reclaim_client for name %.*s\n", name.len, name.data);
 
-	strhashval = clientstr_hashval(recdir);
+	strhashval = clientstr_hashval(name);
 	list_for_each_entry(crp, &nn->reclaim_str_hashtbl[strhashval], cr_strhash) {
-		if (same_name(crp->cr_recdir, recdir)) {
+		if (compare_blob(&crp->cr_name, &name) == 0) {
 			return crp;
 		}
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 396c76755b03..3e5b7dd604bd 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -367,7 +367,7 @@ struct nfs4_client {
 struct nfs4_client_reclaim {
 	struct list_head	cr_strhash;	/* hash by cr_name */
 	struct nfs4_client	*cr_clp;	/* pointer to associated clp */
-	char			cr_recdir[HEXDIR_LEN]; /* recover dir */
+	struct xdr_netobj	cr_name;	/* recovery dir name */
 };
 
 /* A reasonable value for REPLAY_ISIZE was estimated as follows:  
@@ -619,7 +619,7 @@ void nfs4_put_stid(struct nfs4_stid *s);
 void nfs4_inc_and_copy_stateid(stateid_t *dst, struct nfs4_stid *stid);
 void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *, struct nfsd_net *);
 extern void nfs4_release_reclaim(struct nfsd_net *);
-extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
+extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(struct xdr_netobj name,
 							struct nfsd_net *nn);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid,
 		struct nfsd4_compound_state *cstate, struct nfsd_net *nn);
@@ -634,9 +634,9 @@ extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfsd4_shutdown_copy(struct nfs4_client *clp);
 extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
-extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
+extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(struct xdr_netobj name,
 							struct nfsd_net *nn);
-extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
+extern bool nfs4_has_reclaimed_state(struct xdr_netobj name, struct nfsd_net *nn);
 
 struct nfs4_file *find_file(struct knfsd_fh *fh);
 void put_nfs4_file(struct nfs4_file *fi);
-- 
2.17.2

