Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50396 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753982Ab1CCGUu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 01:20:50 -0500
Date: Thu, 3 Mar 2011 01:20:49 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rick Koshi <nfs-bug-report@more-right-rudder.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Possible NFSv4 locking bug
Message-ID: <20110303062049.GF7724@fieldses.org>
References: <201102281527.p1SFRNst010559@hope.more-right-rudder.com>
 <20110301155308.GB20599@fieldses.org>
 <201103012231.p21MV68F018619@hope.more-right-rudder.com>
 <20110302191545.GA3981@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110302191545.GA3981@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 02, 2011 at 02:15:45PM -0500, J. Bruce Fields wrote:
> On Tue, Mar 01, 2011 at 05:31:06PM -0500, Rick Koshi wrote:
> > "J. Bruce Fields" writes:
> > > On Mon, Feb 28, 2011 at 10:27:23AM -0500, Rick Koshi wrote:
> > > > 
> > > > I've found that when I lock an NFS-mounted file on a client, the server
> > > > reserves an open file descriptor (as seen in /proc/sys/fs/file-nr).
> > > 
> > > So it looks like that's the total number of allocated struct file's
> > > across the system?
> > 
> > That sounds about right.  To be honest, I'm not 100% sure exactly
> > what that file reports.  But I do know that when it got that large,
> > I stopped being able to open new files as any non-root user.  Running
> > basic things like 'ls' gave me errors, as they were unable to open
> > shared libraries to run.
> > 
> > If you like, you can read the post I originally submitted
> > on serverfault.com, when I was trying to figure this out.
> > It documents a lot of what I tried:
> > 
> >    http://serverfault.com/questions/235059/vfs-file-max-limit-1231582-reached
> 
> Yeah, this is an nfsv4-specific bug, and I can reproduce it easily by
> e.g. running cthon -l in a loop on the client while monitoring file-nr
> on the server.  I see the problem, but there's more than one thing to
> fix there, so it needs more thought; I'll try to have a patch out by the
> end of the day.

Does this help?

I think this addresses the worst problem, but I'm still having trouble
unmounting an exported filesystem cleanly afterwards, so there's
probably another leak to track down.

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 54b60bf..4e97b3a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -316,64 +316,6 @@ static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head client_lru;
 static struct list_head close_lru;
 
-static void unhash_generic_stateid(struct nfs4_stateid *stp)
-{
-	list_del(&stp->st_hash);
-	list_del(&stp->st_perfile);
-	list_del(&stp->st_perstateowner);
-}
-
-static void free_generic_stateid(struct nfs4_stateid *stp)
-{
-	put_nfs4_file(stp->st_file);
-	kmem_cache_free(stateid_slab, stp);
-}
-
-static void release_lock_stateid(struct nfs4_stateid *stp)
-{
-	struct file *file;
-
-	unhash_generic_stateid(stp);
-	file = find_any_file(stp->st_file);
-	if (file)
-		locks_remove_posix(file, (fl_owner_t)stp->st_stateowner);
-	free_generic_stateid(stp);
-}
-
-static void unhash_lockowner(struct nfs4_stateowner *sop)
-{
-	struct nfs4_stateid *stp;
-
-	list_del(&sop->so_idhash);
-	list_del(&sop->so_strhash);
-	list_del(&sop->so_perstateid);
-	while (!list_empty(&sop->so_stateids)) {
-		stp = list_first_entry(&sop->so_stateids,
-				struct nfs4_stateid, st_perstateowner);
-		release_lock_stateid(stp);
-	}
-}
-
-static void release_lockowner(struct nfs4_stateowner *sop)
-{
-	unhash_lockowner(sop);
-	nfs4_put_stateowner(sop);
-}
-
-static void
-release_stateid_lockowners(struct nfs4_stateid *open_stp)
-{
-	struct nfs4_stateowner *lock_sop;
-
-	while (!list_empty(&open_stp->st_lockowners)) {
-		lock_sop = list_entry(open_stp->st_lockowners.next,
-				struct nfs4_stateowner, so_perstateid);
-		/* list_del(&open_stp->st_lockowners);  */
-		BUG_ON(lock_sop->so_is_open_owner);
-		release_lockowner(lock_sop);
-	}
-}
-
 /*
  * We store the NONE, READ, WRITE, and BOTH bits separately in the
  * st_{access,deny}_bmap field of the stateid, in order to track not
@@ -446,13 +388,71 @@ static int nfs4_access_bmap_to_omode(struct nfs4_stateid *stp)
 	return nfs4_access_to_omode(access);
 }
 
-static void release_open_stateid(struct nfs4_stateid *stp)
+static void unhash_generic_stateid(struct nfs4_stateid *stp)
+{
+	list_del(&stp->st_hash);
+	list_del(&stp->st_perfile);
+	list_del(&stp->st_perstateowner);
+}
+
+static void free_generic_stateid(struct nfs4_stateid *stp)
 {
 	int oflag = nfs4_access_bmap_to_omode(stp);
 
+	nfs4_file_put_access(stp->st_file, oflag);
+	put_nfs4_file(stp->st_file);
+	kmem_cache_free(stateid_slab, stp);
+}
+
+static void release_lock_stateid(struct nfs4_stateid *stp)
+{
+	struct file *file;
+
+	unhash_generic_stateid(stp);
+	file = find_any_file(stp->st_file);
+	if (file)
+		locks_remove_posix(file, (fl_owner_t)stp->st_stateowner);
+	free_generic_stateid(stp);
+}
+
+static void unhash_lockowner(struct nfs4_stateowner *sop)
+{
+	struct nfs4_stateid *stp;
+
+	list_del(&sop->so_idhash);
+	list_del(&sop->so_strhash);
+	list_del(&sop->so_perstateid);
+	while (!list_empty(&sop->so_stateids)) {
+		stp = list_first_entry(&sop->so_stateids,
+				struct nfs4_stateid, st_perstateowner);
+		release_lock_stateid(stp);
+	}
+}
+
+static void release_lockowner(struct nfs4_stateowner *sop)
+{
+	unhash_lockowner(sop);
+	nfs4_put_stateowner(sop);
+}
+
+static void
+release_stateid_lockowners(struct nfs4_stateid *open_stp)
+{
+	struct nfs4_stateowner *lock_sop;
+
+	while (!list_empty(&open_stp->st_lockowners)) {
+		lock_sop = list_entry(open_stp->st_lockowners.next,
+				struct nfs4_stateowner, so_perstateid);
+		/* list_del(&open_stp->st_lockowners);  */
+		BUG_ON(lock_sop->so_is_open_owner);
+		release_lockowner(lock_sop);
+	}
+}
+
+static void release_open_stateid(struct nfs4_stateid *stp)
+{
 	unhash_generic_stateid(stp);
 	release_stateid_lockowners(stp);
-	nfs4_file_put_access(stp->st_file, oflag);
 	free_generic_stateid(stp);
 }
 
@@ -3734,6 +3734,7 @@ alloc_init_lock_stateid(struct nfs4_stateowner *sop, struct nfs4_file *fp, struc
 	stp->st_stateid.si_stateownerid = sop->so_id;
 	stp->st_stateid.si_fileid = fp->fi_id;
 	stp->st_stateid.si_generation = 0;
+	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
 
@@ -3748,6 +3749,17 @@ check_lock_length(u64 offset, u64 length)
 	     LOFF_OVERFLOW(offset, length)));
 }
 
+static void get_lock_access(struct nfs4_stateid *lock_stp, u32 access)
+{
+	struct nfs4_file *fp = lock_stp->st_file;
+	int oflag = nfs4_access_to_omode(access);
+
+	if (test_bit(access, &lock_stp->st_access_bmap))
+		return;
+	nfs4_file_get_access(fp, oflag);
+	__set_bit(access, &lock_stp->st_access_bmap);
+}
+
 /*
  *  LOCK operation 
  */
@@ -3764,7 +3776,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file_lock conflock;
 	__be32 status = 0;
 	unsigned int strhashval;
-	unsigned int cmd;
 	int err;
 
 	dprintk("NFSD: nfsd4_lock: start=%Ld length=%Ld\n",
@@ -3846,22 +3857,18 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	switch (lock->lk_type) {
 		case NFS4_READ_LT:
 		case NFS4_READW_LT:
-			if (find_readable_file(lock_stp->st_file)) {
-				nfs4_get_vfs_file(rqstp, fp, &cstate->current_fh, NFS4_SHARE_ACCESS_READ);
-				filp = find_readable_file(lock_stp->st_file);
-			}
+			filp = find_readable_file(lock_stp->st_file);
+			if (filp)
+				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_READ);
 			file_lock.fl_type = F_RDLCK;
-			cmd = F_SETLK;
-		break;
+			break;
 		case NFS4_WRITE_LT:
 		case NFS4_WRITEW_LT:
-			if (find_writeable_file(lock_stp->st_file)) {
-				nfs4_get_vfs_file(rqstp, fp, &cstate->current_fh, NFS4_SHARE_ACCESS_WRITE);
-				filp = find_writeable_file(lock_stp->st_file);
-			}
+			filp = find_writeable_file(lock_stp->st_file);
+			if (filp)
+				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_WRITE);
 			file_lock.fl_type = F_WRLCK;
-			cmd = F_SETLK;
-		break;
+			break;
 		default:
 			status = nfserr_inval;
 		goto out;
@@ -3885,7 +3892,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	* Note: locks.c uses the BKL to protect the inode's lock list.
 	*/
 
-	err = vfs_lock_file(filp, cmd, &file_lock, &conflock);
+	err = vfs_lock_file(filp, F_SETLK, &file_lock, &conflock);
 	switch (-err) {
 	case 0: /* success! */
 		update_stateid(&lock_stp->st_stateid);
