From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 11 of 23] Add the delegation release and free functions
Date: Fri, 17 Dec 2004 16:23:56 +1100
Message-ID: <E1CfAaq-0002e4-9X@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAb4-00058l-HU
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:10 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAb1-0004Aq-EZ
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:10 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   63 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 63 insertions(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 12:03:23.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 12:04:09.000000000 +1100
@@ -82,6 +82,8 @@ u32 free_delegation= 0;
 /* forward declarations */
 struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
+static void release_delegation(struct nfs4_delegation *dp);
+static void release_stateid_lockowner(struct nfs4_stateid *open_stp);
 
 /* Locking:
  *
@@ -166,6 +168,67 @@ alloc_init_deleg(struct nfs4_client *clp
 	return dp;
 }
 
+/*
+ * Free the delegation structure.
+ * Called with the recall_lock held.
+ */
+static void
+nfs4_free_delegation(struct nfs4_delegation *dp)
+{
+	dprintk("NFSD: nfs4_free_delegation freeing dp %p\n",dp);
+	list_del(&dp->dl_recall_lru);
+	kfree(dp);
+	free_delegation++;
+}
+
+/* release_delegation:
+ *
+ * Remove the associated file_lock first, then remove the delegation.
+ * lease_modify() is called to remove the FS_LEASE file_lock from
+ * the i_flock list, eventually calling nfsd's lock_manager
+ * fl_release_callback.
+ *
+ * call either:
+ *   nfsd_close : if last close, locks_remove_flock calls lease_modify.
+ *                otherwise, recalled state set to NFS4_RECALL_COMPLETE
+ *                so that it will be reaped by the laundromat service.
+ * or
+ *   remove_lease (calls time_out_lease which calls lease_modify).
+ *   and nfs4_free_delegation.
+ *
+ * Called with nfs_lock_state() held.
+ * Called with the recall_lock held.
+ */
+
+static void
+release_delegation(struct nfs4_delegation *dp)
+{
+	/* delayed nfsd_close */
+	if (dp->dl_stp) {
+		struct file *filp = dp->dl_stp->st_vfs_file;
+
+		dprintk("NFSD: release_delegation CLOSE\n");
+		release_stateid_lockowner(dp->dl_stp);
+		kfree(dp->dl_stp);
+		dp->dl_stp = NULL;
+		atomic_set(&dp->dl_state, NFS4_RECALL_COMPLETE);
+		nfsd_close(filp);
+		vfsclose++;
+	} else {
+		dprintk("NFSD: release_delegation remove lease dl_flock %p\n",
+			dp->dl_flock);
+		remove_lease(dp->dl_flock);
+		list_del_init(&dp->dl_del_perfile);
+		list_del_init(&dp->dl_del_perclnt);
+		/* dl_count > 0 => outstanding recall rpc */
+		dprintk("NFSD: release_delegation free deleg dl_count %d\n",
+			           atomic_read(&dp->dl_count));
+		if ((atomic_read(&dp->dl_state) == NFS4_REAP_DELEG)
+		     || atomic_dec_and_test(&dp->dl_count))
+			nfs4_free_delegation(dp);
+	}
+}
+
 /* 
  * SETCLIENTID state 
  */


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
