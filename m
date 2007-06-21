From: NeilBrown <neilb@suse.de>
Subject: [PATCH 007 of 8] knfsd: nfsd4: vary maximum delegation limit
	based on RAM size
Date: Thu, 21 Jun 2007 14:31:12 +1000
Message-ID: <1070621043112.1144@suse.de>
References: <20070621142604.727.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1EKH-0005sI-V2
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:31:22 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I1EKJ-0002JO-Bp
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:31:24 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: "J. Bruce Fields" <bfields@fieldses.org>


Our original NFSv4 delegation policy was to give out a read delegation
on any open when it was possible to.

Since the lifetime of a delegation isn't limited to that of an open, a
client may quite reasonably hang on to a delegation as long as it has
the inode cached.  This becomes an obvious problem the first time a
client's inode cache approaches the size of the server's total memory.

Our first quick solution was to add a hard-coded limit.  This patch
makes a mild incremental improvement by varying that limit according to
the server's total memory size, allowing at most 4 delegations per
megabyte of RAM.

My quick back-of-the-envelope calculation finds that in the worst case
(where every delegation is for a different inode), a delegation could
take about 1.5K, which would make the worst case usage about 6% of
memory.  The new limit works out to be about the same as the old on a
1-gig server.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c       |   15 ++++++++++++++-
 ./include/linux/nfsd/nfsd.h |    1 +
 2 files changed, 15 insertions(+), 1 deletion(-)

diff .prev/fs/nfsd/nfs4state.c ./fs/nfsd/nfs4state.c
--- .prev/fs/nfsd/nfs4state.c	2007-06-21 14:09:23.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2007-06-21 14:14:47.000000000 +1000
@@ -150,6 +150,7 @@ get_nfs4_file(struct nfs4_file *fi)
 }
 
 static int num_delegations;
+unsigned int max_delegations = 0;
 
 /*
  * Open owner state (share locks)
@@ -193,7 +194,7 @@ alloc_init_deleg(struct nfs4_client *clp
 	struct nfs4_callback *cb = &stp->st_stateowner->so_client->cl_callback;
 
 	dprintk("NFSD alloc_init_deleg\n");
-	if (num_delegations > STATEID_HASH_SIZE * 4)
+	if (num_delegations > max_delegations)
 		return NULL;
 	dp = kmem_cache_alloc(deleg_slab, GFP_KERNEL);
 	if (dp == NULL)
@@ -3198,6 +3199,17 @@ get_nfs4_grace_period(void)
 	return max(user_lease_time, lease_time) * HZ;
 }
 
+static void
+set_max_delegations()
+{
+	struct sysinfo sys;
+
+	si_meminfo(&sys);
+	sys.totalram *= sys.mem_unit;
+	sys.totalram >>= (18 - PAGE_SHIFT);
+	max_delegations = (unsigned int) sys.totalram;
+}
+
 /* initialization to perform when the nfsd service is started: */
 
 static void
@@ -3213,6 +3225,7 @@ __nfs4_state_start(void)
 	       grace_time/HZ);
 	laundry_wq = create_singlethread_workqueue("nfsd4");
 	queue_delayed_work(laundry_wq, &laundromat_work, grace_time);
+	set_max_delegations();
 }
 
 int

diff .prev/include/linux/nfsd/nfsd.h ./include/linux/nfsd/nfsd.h
--- .prev/include/linux/nfsd/nfsd.h	2007-06-21 14:13:57.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2007-06-21 14:14:47.000000000 +1000
@@ -148,6 +148,7 @@ extern int nfsd_max_blksize;
  * NFSv4 State
  */
 #ifdef CONFIG_NFSD_V4
+extern unsigned int max_delegations;
 void nfs4_state_init(void);
 int nfs4_state_start(void);
 void nfs4_state_shutdown(void);

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
