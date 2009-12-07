From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 17/35] pnfsd: process the layout stateid
Date: Mon,  7 Dec 2009 11:33:33 +0200
Message-ID: <1260178413-15261-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@umich.edu>,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>,
	Boaz Harrosh <bharrosh@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@umich.edu>

Common function for LAYOUTGET and LAYOUTRETURN layout stateid processing.

The 'first open, delegation, or lock stateid' presented by the client is
looked up for verification.

Both initial and non-initial parallel LAYOUTGET operations and parallel
LAYOUTRETURN operations are supported.

Note: layout stateid seqid checking is more lax than that specified in
draft-ietf-nfsv4-minorversion1-22 for Connectathon.

Take a reference count whenever the pointer to the layout state
is kept, in particular when the layout structure is listed on the
state's ls_layouts.  On dequeue_layout the layout state if being put
and its reference count will drop to zero if the list empties
unless someone's holding a reference transiently within the scope
of teh calling function, in which case the layout state is dereferenced
before the function exits.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: nfs4_process_layout_stateid print result stateid conditionally]
[pnfsd: use STATEID_FMT and STATEID_VAL for printing stateids]
[pnfsd: debug print layout stateid before putting the layout_state]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: fix layout state reference count]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[used nfs4_check_stateid in nfs4_process_layout_stateid]
[Moved pnfsd code from nfs4state.c to nfs4pnfsd.c]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: use a spinlock for layout state]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Move pnfsd code out of nfs4state.c/h]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[moved defs back into state.h]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c |  151 +++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c |   10 ++--
 fs/nfsd/state.h     |    3 +
 3 files changed, 158 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index b02daad..a72fe19 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -128,6 +128,155 @@ put_layout_state(struct nfs4_layout_state *ls)
 	kref_put(&ls->ls_ref, destroy_layout_state);
 }
 
+/*
+ * Search the fp->fi_layout_state list for a layout state with the clientid.
+ * If not found, then this is a 'first open/delegation/lock stateid' from
+ * the client for this file.
+ * Called under the layout_lock.
+ */
+static struct nfs4_layout_state *
+find_get_layout_state(struct nfs4_client *clp, struct nfs4_file *fp)
+{
+	struct nfs4_layout_state *ls;
+
+	list_for_each_entry(ls, &fp->fi_layout_states, ls_perfile) {
+		if (ls->ls_client == clp) {
+			dprintk("pNFS %s: before GET ls %p ls_ref %d\n",
+				__func__, ls,
+				atomic_read(&ls->ls_ref.refcount));
+			get_layout_state(ls);
+			return ls;
+		}
+	}
+	return NULL;
+}
+
+static int
+verify_stateid(struct nfs4_file *fp, stateid_t *stateid)
+{
+	struct nfs4_stateid *local = NULL;
+	struct nfs4_delegation *temp = NULL;
+
+	/* check if open or lock stateid */
+	local = find_stateid(stateid, RD_STATE);
+	if (local)
+		return 0;
+	temp = find_delegation_stateid(fp->fi_inode, stateid);
+	if (temp)
+		return 0;
+	return nfserr_bad_stateid;
+}
+
+/*
+ * nfs4_preocess_layout_stateid ()
+ *
+ * We have looked up the nfs4_file corresponding to the current_fh, and
+ * confirmed the clientid. Pull the few tests from nfs4_preprocess_stateid_op()
+ * that make sense with a layout stateid.
+ *
+ * Called with the state_lock held
+ * Returns zero and stateid is updated, or error.
+ *
+ * Note: the struct nfs4_layout_state pointer is only set by layoutget.
+ */
+static __be32
+nfs4_process_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
+			    stateid_t *stateid, struct nfs4_layout_state **lsp)
+{
+	struct nfs4_layout_state *ls = NULL;
+	__be32 status = 0;
+
+	dprintk("--> %s clp %p fp %p \n", __func__, clp, fp);
+
+	dprintk("%s: operation stateid=" STATEID_FMT "\n", __func__,
+		STATEID_VAL(stateid));
+
+	status = nfs4_check_stateid(stateid);
+	if (status)
+		goto out;
+
+	/* Is this the first use of this layout ? */
+	spin_lock(&layout_lock);
+	ls = find_get_layout_state(clp, fp);
+	spin_unlock(&layout_lock);
+	if (!ls) {
+		/* Only alloc layout state on layoutget (which sets lsp). */
+		if (!lsp) {
+			dprintk("%s ERROR: Not layoutget & no layout stateid\n",
+				__func__);
+			status = nfserr_bad_stateid;
+			goto out;
+		}
+		dprintk("%s Initial stateid for layout: file %p client %p\n",
+			__func__, fp, clp);
+
+		/* verify input stateid */
+		status = verify_stateid(fp, stateid);
+		if (status < 0) {
+			dprintk("%s ERROR: invalid open/deleg/lock stateid\n",
+				__func__);
+			goto out;
+		}
+		ls = alloc_init_layout_state(clp, fp, stateid);
+		if (!ls) {
+			dprintk("%s pNFS ERROR: no memory for layout state\n",
+				__func__);
+			status = nfserr_resource;
+			goto out;
+		}
+	} else {
+		dprintk("%s Not initial stateid. Layout state %p file %p\n",
+			__func__, ls, fp);
+
+		/* BAD STATEID */
+		status = nfserr_bad_stateid;
+		if (memcmp(&ls->ls_stateid.si_opaque, &stateid->si_opaque,
+			sizeof(stateid_opaque_t)) != 0) {
+
+			/* if a LAYOUTGET operation and stateid is a valid
+			 * open/deleg/lock stateid, accept it as a parallel
+			 * initial layout stateid
+			 */
+			if (lsp && ((verify_stateid(fp, stateid)) == 0)) {
+				dprintk("%s parallel initial layout state\n",
+					__func__);
+				goto update;
+			}
+
+			dprintk("%s ERROR bad opaque in stateid 1\n", __func__);
+			goto out_put;
+		}
+
+		/* stateid is a valid layout stateid for this file. */
+		if (stateid->si_generation > ls->ls_stateid.si_generation) {
+			dprintk("%s bad stateid 1\n", __func__);
+			goto out_put;
+		}
+update:
+		update_stateid(&ls->ls_stateid);
+		dprintk("%s Updated ls_stateid to %d on layoutstate %p\n",
+			__func__, ls->ls_stateid.si_generation, ls);
+	}
+	status = 0;
+	/* Set the stateid to be encoded */
+	memcpy(stateid, &ls->ls_stateid, sizeof(stateid_t));
+
+	/* Return the layout state if requested */
+	if (lsp) {
+		get_layout_state(ls);
+		*lsp = ls;
+	}
+	dprintk("%s: layout stateid=" STATEID_FMT "\n", __func__,
+		STATEID_VAL(&ls->ls_stateid));
+out_put:
+	dprintk("%s PUT LO STATE:\n", __func__);
+	put_layout_state(ls);
+out:
+	dprintk("<-- %s status %d\n", __func__, htonl(status));
+
+	return status;
+}
+
 static inline struct nfs4_layout *
 alloc_layout(void)
 {
@@ -352,6 +501,8 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
 	/* Can't merge, so let's initialize this new layout */
 	init_layout(ls, lp, fp, clp, lgp->lg_fhp, &res.lg_seg);
 out:
+	if (ls)
+		put_layout_state(ls);
 	if (fp)
 		put_nfs4_file(fp);
 	nfs4_unlock_state();
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3e30f91..1731b35 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -61,8 +61,6 @@ static u64 current_sessionid = 1;
 #define ONE_STATEID(stateid)  (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
 
 /* forward declarations */
-static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
-static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
 static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
 static void nfs4_set_recdir(char *recdir);
 
@@ -2704,7 +2702,7 @@ nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stateid *stp)
 	return fhp->fh_dentry->d_inode != stp->st_vfs_file->f_path.dentry->d_inode;
 }
 
-static int
+int
 STALE_STATEID(stateid_t *stateid)
 {
 	if (time_after((unsigned long)boot_time,
@@ -2716,7 +2714,7 @@ STALE_STATEID(stateid_t *stateid)
 	return 0;
 }
 
-static __be32
+__be32
 nfs4_check_stateid(stateid_t *stateid)
 {
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
@@ -3265,7 +3263,7 @@ static struct list_head lock_ownerid_hashtbl[LOCK_HASH_SIZE];
 static struct list_head	lock_ownerstr_hashtbl[LOCK_HASH_SIZE];
 static struct list_head lockstateid_hashtbl[STATEID_HASH_SIZE];
 
-static struct nfs4_stateid *
+struct nfs4_stateid *
 find_stateid(stateid_t *stid, int flags)
 {
 	struct nfs4_stateid *local;
@@ -3294,7 +3292,7 @@ find_stateid(stateid_t *stid, int flags)
 	return NULL;
 }
 
-static struct nfs4_delegation *
+struct nfs4_delegation *
 find_delegation_stateid(struct inode *ino, stateid_t *stid)
 {
 	struct nfs4_file *fp;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 23d62f4..cde091a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -416,6 +416,9 @@ extern struct nfs4_file *find_alloc_file(struct inode *, struct svc_fh *);
 extern void put_nfs4_file(struct nfs4_file *);
 extern void get_nfs4_file(struct nfs4_file *);
 extern struct nfs4_client *find_confirmed_client(clientid_t *);
+extern struct nfs4_stateid *find_stateid(stateid_t *, int flags);
+extern struct nfs4_delegation *find_delegation_stateid(struct inode *, stateid_t *);
+extern __be32 nfs4_check_stateid(stateid_t *);
 
 #if defined(CONFIG_PNFSD)
 extern int nfsd4_init_pnfs_slabs(void);
-- 
1.6.5.1

