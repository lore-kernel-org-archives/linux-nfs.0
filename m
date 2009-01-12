From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd4: split lockstateid/openstateid release logic
Date: Mon, 12 Jan 2009 11:20:15 -0500
Message-ID: <20090112162014.GB24322@fieldses.org>
References: <1231717949-31908-1-git-send-email-bfields@citi.umich.edu> <1231717949-31908-2-git-send-email-bfields@citi.umich.edu> <496B04D5.1030809@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:51802 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752649AbZALQUS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2009 11:20:18 -0500
In-Reply-To: <496B04D5.1030809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 12, 2009 at 10:52:37AM +0200, Benny Halevy wrote:
> static void unhash_generic_stateid(struct nfs4_stateid *stp)
> {
> 	list_del(&stp->st_hash);
> 	list_del(&stp->st_perfile);
> 	list_del(&stp->st_perstateowner);
> }
> 
> static void free_generic_stateid(struct nfs4_stateid *stp)
> {
> 	put_nfs4_file(stp->st_file);
> 	kmem_cache_free(stateid_slab, stp);
> }
> 
> static void release_open_stateid(struct nfs4_stateid *stp)
> {
> 	struct file *filp = stp->st_vfs_file;
> 
> 	release_stateid_lockowners(stp);
> 	unhash_generic_stateid(stp);
> 	nfsd_close(filep);
> 	free_generic_stateid(stp);
> }

Thanks, makes sense to me; so:

--b.

commit cef099ecffe597a4c1c4cb6073190e87433ced61
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Sun Jan 11 14:27:17 2009 -0500

    nfsd4: split lockstateid/openstateid release logic
    
    The flags here attempt to make the code more general, but I find it
    actually just adds confusion.
    
    I think it's clearer to separate the logic for the open and lock cases
    entirely.  And eventually we may want to separate the stateowner and
    stateid types as well, as many of the fields aren't shared between the
    lock and open cases.
    
    Also move to eliminate forward references.
    
    Start with the stateid's.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Reviewed-by: Benny Halevy <bhalevy@panasas.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 88db7d3..bccc28d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -119,7 +119,6 @@ opaque_hashval(const void *ptr, int nbytes)
 
 /* forward declarations */
 static void release_stateowner(struct nfs4_stateowner *sop);
-static void release_stateid(struct nfs4_stateid *stp, int flags);
 
 /*
  * Delegation state
@@ -311,6 +310,34 @@ static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head client_lru;
 static struct list_head close_lru;
 
+static void unhash_generic_stateid(struct nfs4_stateid *stp)
+{
+	list_del(&stp->st_hash);
+	list_del(&stp->st_perfile);
+	list_del(&stp->st_perstateowner);
+}
+
+static void free_generic_stateid(struct nfs4_stateid *stp)
+{
+	put_nfs4_file(stp->st_file);
+	kmem_cache_free(stateid_slab, stp);
+}
+
+static void release_lock_stateid(struct nfs4_stateid *stp)
+{
+	unhash_generic_stateid(stp);
+	locks_remove_posix(stp->st_vfs_file, (fl_owner_t)stp->st_stateowner);
+	free_generic_stateid(stp);
+}
+
+static void release_open_stateid(struct nfs4_stateid *stp)
+{
+	unhash_generic_stateid(stp);
+	release_stateid_lockowners(stp);
+	nfsd_close(stp->st_vfs_file);
+	free_generic_stateid(stp);
+}
+
 static inline void
 renew_client(struct nfs4_client *clp)
 {
@@ -1065,9 +1092,9 @@ unhash_stateowner(struct nfs4_stateowner *sop)
 		stp = list_entry(sop->so_stateids.next,
 			struct nfs4_stateid, st_perstateowner);
 		if (sop->so_is_open_owner)
-			release_stateid(stp, OPEN_STATE);
+			release_open_stateid(stp);
 		else
-			release_stateid(stp, LOCK_STATE);
+			release_lock_stateid(stp);
 	}
 }
 
@@ -1106,24 +1133,6 @@ init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *
 }
 
 static void
-release_stateid(struct nfs4_stateid *stp, int flags)
-{
-	struct file *filp = stp->st_vfs_file;
-
-	list_del(&stp->st_hash);
-	list_del(&stp->st_perfile);
-	list_del(&stp->st_perstateowner);
-	if (flags & OPEN_STATE) {
-		release_stateid_lockowners(stp);
-		stp->st_vfs_file = NULL;
-		nfsd_close(filp);
-	} else if (flags & LOCK_STATE)
-		locks_remove_posix(filp, (fl_owner_t) stp->st_stateowner);
-	put_nfs4_file(stp->st_file);
-	kmem_cache_free(stateid_slab, stp);
-}
-
-static void
 move_to_close_lru(struct nfs4_stateowner *sop)
 {
 	dprintk("NFSD: move_to_close_lru nfs4_stateowner %p\n", sop);
@@ -1764,7 +1773,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		init_stateid(stp, fp, open);
 		status = nfsd4_truncate(rqstp, current_fh, open);
 		if (status) {
-			release_stateid(stp, OPEN_STATE);
+			release_open_stateid(stp);
 			goto out;
 		}
 	}
@@ -2373,7 +2382,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	memcpy(&close->cl_stateid, &stp->st_stateid, sizeof(stateid_t));
 
 	/* release_stateid() calls nfsd_close() if needed */
-	release_stateid(stp, OPEN_STATE);
+	release_open_stateid(stp);
 
 	/* place unused nfs4_stateowners on so_close_lru list to be
 	 * released by the laundromat service after the lease period
