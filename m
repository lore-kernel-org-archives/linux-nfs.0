From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 54 of 54] nfsd4: eliminate unnecessary remove_lease
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-0001AJ-LS@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8XsK-0002BF-Mx
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:24 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8XsJ-0005HG-VF
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:24 -0800
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


Get rid of remove_lease, use setlease() with F_UNLCK

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/locks.c          |   20 +-------------------
 ./fs/nfsd/nfs4state.c |    3 +--
 ./include/linux/fs.h  |    1 -
 3 files changed, 2 insertions(+), 22 deletions(-)

diff ./fs/locks.c~current~ ./fs/locks.c
--- ./fs/locks.c~current~	2005-03-07 15:18:41.000000000 +1100
+++ ./fs/locks.c	2005-03-07 15:22:24.000000000 +1100
@@ -406,7 +406,7 @@ static void lease_release_private_callba
 	fl->fl_file->f_owner.signum = 0;
 }
 
-static int lease_mylease_callback(struct file_lock *fl, struct file_lock *try)
+int lease_mylease_callback(struct file_lock *fl, struct file_lock *try)
 {
 	return fl->fl_file == try->fl_file;
 }
@@ -1099,24 +1099,6 @@ static void time_out_leases(struct inode
 	}
 }
 
- /**
-*	remove_lease - let time_out_leases remove the lease.
-*	@@file_lock: the lease to remove
-*/
-void remove_lease(struct file_lock *fl)
-{
-	lock_kernel();
-	if (!fl || !IS_LEASE(fl))
-		goto out;
-	fl->fl_type = F_UNLCK | F_INPROGRESS;
-	fl->fl_break_time = jiffies - 10;
-	time_out_leases(fl->fl_file->f_dentry->d_inode);
-out:
-	unlock_kernel();
-}
-
-EXPORT_SYMBOL(remove_lease);
-
 /**
  *	__break_lease	-	revoke all outstanding leases on file
  *	@inode: the inode of the file to return

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 15:12:02.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 15:22:24.000000000 +1100
@@ -194,7 +194,7 @@ nfs4_close_delegation(struct nfs4_delega
 	dp->dl_vfs_file = NULL;
 	/* The following nfsd_close may not actually close the file,
 	 * but we want to remove the lease in any case. */
-	remove_lease(dp->dl_flock);
+	setlease(filp, F_UNLCK, &dp->dl_flock);
 	nfsd_close(filp);
 	vfsclose++;
 }
@@ -1438,7 +1438,6 @@ struct lock_manager_operations nfsd_leas
 };
 
 
-
 /*
  * nfsd4_process_open1()
  * 	lookup stateowner.

diff ./include/linux/fs.h~current~ ./include/linux/fs.h
--- ./include/linux/fs.h~current~	2005-03-07 15:19:16.000000000 +1100
+++ ./include/linux/fs.h	2005-03-07 15:22:24.000000000 +1100
@@ -723,7 +723,6 @@ extern int __break_lease(struct inode *i
 extern void lease_get_mtime(struct inode *, struct timespec *time);
 extern int setlease(struct file *, long, struct file_lock **);
 extern int lease_modify(struct file_lock **, int);
-extern void remove_lease(struct file_lock *);
 extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
 extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
 extern void steal_locks(fl_owner_t from);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
