From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 005 of 28] nfsd4: create separate laundromat workqueue
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006hs-7v@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3H-0005vX-MX
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:07 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3G-0005MZ-MJ
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:07 -0700
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


We're running the laundromat work on the default kevent worker thread.  But the
laundromat takes the nfsv4 state semaphore, which is used for way too much
stuff, and the potential for deadlocks is high.  Better to have this on a
separate workqueue.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:20:59.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:20:59.000000000 +1000
@@ -1844,6 +1844,7 @@ out:
 	return status;
 }
 
+static struct workqueue_struct *laundry_wq;
 static struct work_struct laundromat_work;
 static void laundromat_main(void *);
 static DECLARE_WORK(laundromat_work, laundromat_main, NULL);
@@ -1951,7 +1952,7 @@ laundromat_main(void *not_used)
 
 	t = nfs4_laundromat();
 	dprintk("NFSD: laundromat_main - sleeping for %ld seconds\n", t);
-	schedule_delayed_work(&laundromat_work, t*HZ);
+	queue_delayed_work(laundry_wq, &laundromat_work, t*HZ);
 }
 
 /* search ownerid_hashtbl[] and close_lru for stateid owner
@@ -3211,7 +3212,8 @@ __nfs4_state_init(void)
 		printk("NFSD: starting %ld-second grace period\n", grace_time);
 	grace_end = boot_time + grace_time;
 	INIT_WORK(&laundromat_work,laundromat_main, NULL);
-	schedule_delayed_work(&laundromat_work, NFSD_LEASE_TIME*HZ);
+	laundry_wq = create_singlethread_workqueue("nfsd4");
+	queue_delayed_work(laundry_wq, &laundromat_work, NFSD_LEASE_TIME*HZ);
 }
 
 int
@@ -3287,7 +3289,8 @@ __nfs4_state_shutdown(void)
 	}
 
 	cancel_delayed_work(&laundromat_work);
-	flush_scheduled_work();
+	flush_workqueue(laundry_wq);
+	destroy_workqueue(laundry_wq);
 	nfs4_init = 0;
 }
 


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
