From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 5 of 18] nfsd4: reference count stateowners
Date: Fri, 24 Sep 2004 14:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1CAi6f-0000k8-BK@notabene.cse.unsw.edu.au>
References: <20040924145130.2689.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAi7D-000895-1b
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:27 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CAi7B-0006BU-6u
	for nfs@lists.sourceforge.net; Thu, 23 Sep 2004 21:55:26 -0700
To: Andrew Morton <akpm@osdl.org>
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



Reference-counting the nfsd4 stateowner structs will let us fix a race and
simplify some of the xdr code a bit, and may also help us make the nfsd4
locking a little more fine-grained in the future.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |   26 +++++++++++++-------------
 ./include/linux/nfsd/state.h |   16 ++++++++++++++++
 2 files changed, 29 insertions(+), 13 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-24 14:47:14.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-24 14:48:38.000000000 +1000
@@ -833,6 +833,16 @@ release_all_files(void)
 	}
 }
 
+/* should use a slab cache */
+void
+nfs4_free_stateowner(struct kref *kref) {
+	struct nfs4_stateowner *sop =
+		container_of(kref, struct nfs4_stateowner, so_ref);
+	kfree(sop->so_owner.data);
+	kfree(sop);
+	free_sowner++;
+}
+
 static inline struct nfs4_stateowner *
 alloc_stateowner(struct xdr_netobj *owner)
 {
@@ -842,6 +852,7 @@ alloc_stateowner(struct xdr_netobj *owne
 		if ((sop->so_owner.data = kmalloc(owner->len, GFP_KERNEL))) {
 			memcpy(sop->so_owner.data, owner->data, owner->len);
 			sop->so_owner.len = owner->len;
+			kref_init(&sop->so_ref);
 			return sop;
 		} 
 		kfree(sop);
@@ -849,17 +860,6 @@ alloc_stateowner(struct xdr_netobj *owne
 	return NULL;
 }
 
-/* should use a slab cache */
-static void
-free_stateowner(struct nfs4_stateowner *sop) {
-	if (sop) {
-		kfree(sop->so_owner.data);
-		kfree(sop);
-		sop = NULL;
-		free_sowner++;
-	}
-}
-
 static struct nfs4_stateowner *
 alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_open *open) {
 	struct nfs4_stateowner *sop;
@@ -932,7 +932,7 @@ release_stateowner(struct nfs4_stateowne
 {
 	unhash_stateowner(sop);
 	list_del(&sop->so_close_lru);
-	free_stateowner(sop);
+	nfs4_put_stateowner(sop);
 }
 
 static inline void
@@ -1460,7 +1460,7 @@ nfs4_laundromat(void)
 		dprintk("NFSD: purging unused open stateowner (so_id %d)\n",
 			sop->so_id);
 		list_del(&sop->so_close_lru);
-		free_stateowner(sop);
+		nfs4_put_stateowner(sop);
 	}
 	if (clientid_val < NFSD_LAUNDROMAT_MINTIMEOUT)
 		clientid_val = NFSD_LAUNDROMAT_MINTIMEOUT;

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-09-24 14:47:14.000000000 +1000
+++ ./include/linux/nfsd/state.h	2004-09-24 14:48:38.000000000 +1000
@@ -38,6 +38,7 @@
 #define _NFSD4_STATE_H
 
 #include <linux/list.h>
+#include <linux/kref.h>
 #include <linux/sunrpc/clnt.h>
 
 #define NFS4_OPAQUE_LIMIT 1024
@@ -168,6 +169,7 @@ struct nfs4_replay {
 *         reaped by laundramat thread after lease period.
 */
 struct nfs4_stateowner {
+	struct kref		so_ref;
 	struct list_head        so_idhash;   /* hash by so_id */
 	struct list_head        so_strhash;   /* hash by op_name */
 	struct list_head        so_perclient; /* nfs4_client->cl_perclient */
@@ -248,4 +250,18 @@ extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
 extern int nfs4_in_grace(void);
 extern int nfs4_check_open_reclaim(clientid_t *clid);
+extern void nfs4_free_stateowner(struct kref *kref);
+
+static inline void
+nfs4_put_stateowner(struct nfs4_stateowner *so)
+{
+	kref_put(&so->so_ref, nfs4_free_stateowner);
+}
+
+static inline void
+nfs4_get_stateowner(struct nfs4_stateowner *so)
+{
+	kref_get(&so->so_ref);
+}
+
 #endif   /* NFSD4_STATE_H */


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
