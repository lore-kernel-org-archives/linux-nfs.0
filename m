From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 42 of 54] nfsd4: fix cb-race
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-00019X-2V@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrq-00027x-VJ
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:54 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrp-0007tU-Hv
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:54 -0800
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



We weren't taking the reference count in the delegation recall thread until
we'd already started the new delegation thread (and possibly returned from the
break_lease callback).  That's too late.

Also document some assumptions.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 13:29:30.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 13:29:58.000000000 +1100
@@ -1345,7 +1345,6 @@ do_recall(void *__dp)
 
 	daemonize("nfsv4-recall");
 
-	atomic_inc(&dp->dl_count);
 	nfsd4_cb_recall(dp);
 	return 0;
 }
@@ -1354,8 +1353,9 @@ do_recall(void *__dp)
  * Spawn a thread to perform a recall on the delegation represented
  * by the lease (file_lock)
  *
- * Called from break_lease() with lock_kernel() held,
- *
+ * Called from break_lease() with lock_kernel() held.
+ * Note: we assume break_lease will only call this *once* for any given
+ * lease.
  */
 static
 void nfsd_break_deleg_cb(struct file_lock *fl)
@@ -1367,7 +1367,13 @@ void nfsd_break_deleg_cb(struct file_loc
 	if (!dp)
 		return;
 
-	/* schedule delegation for recall */
+	/* We're assuming the state code never drops its reference
+	 * without first removing the lease.  Since we're in this lease
+	 * callback (and since the lease code is serialized by the kernel
+	 * lock) we know the server hasn't removed the lease yet, we know
+	 * it's safe to take a reference: */
+	atomic_inc(&dp->dl_count);
+
 	spin_lock(&recall_lock);
 	atomic_set(&dp->dl_state, NFS4_RECALL_IN_PROGRESS);
 	list_add_tail(&dp->dl_recall_lru, &del_recall_lru);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
