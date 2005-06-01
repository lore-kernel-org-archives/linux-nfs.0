From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 015 of 28] nfsd4: grace period end
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006iR-VV@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3P-0005xA-Hj
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:15 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3N-0002RF-58
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:15 -0700
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


For the purposes of reboot recovery, we want to do some work during the
transition period at the end of the grace period.  Some of that work must be
guaranteed to have a certain relationship with the end of the grace period, so
we want to control the transition there.

Our approach is to modify the in_grace() checks to consult a global variable
instead of checking the time directly, to schedule the first run of the
laundromat thread at the end of the grace period, and to set the global
end-of-grace-period there.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:02.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:02.000000000 +1000
@@ -55,7 +55,7 @@
 static time_t lease_time = 90;     /* default lease time */
 static time_t user_lease_time = 90;
 time_t boot_time;
-static time_t grace_end = 0;
+static int in_grace = 1;
 static u32 current_clientid = 1;
 static u32 current_ownerid = 1;
 static u32 current_fileid = 1;
@@ -1908,6 +1908,13 @@ out:
 	return status;
 }
 
+static void
+end_grace(void)
+{
+	dprintk("NFSD: end of grace period\n");
+	in_grace = 0;
+}
+
 time_t
 nfs4_laundromat(void)
 {
@@ -1922,6 +1929,8 @@ nfs4_laundromat(void)
 	nfs4_lock_state();
 
 	dprintk("NFSD: laundromat service - starting\n");
+	if (in_grace)
+		end_grace();
 	list_for_each_safe(pos, next, &client_lru) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
@@ -3223,10 +3232,10 @@ __nfs4_state_start(void)
 	boot_time = get_seconds();
 	grace_time = max(user_lease_time, lease_time);
 	lease_time = user_lease_time;
+	in_grace = 1;
 	printk("NFSD: starting %ld-second grace period\n", grace_time);
-	grace_end = boot_time + grace_time;
 	laundry_wq = create_singlethread_workqueue("nfsd4");
-	queue_delayed_work(laundry_wq, &laundromat_work, NFSD_LEASE_TIME*HZ);
+	queue_delayed_work(laundry_wq, &laundromat_work, grace_time*HZ);
 }
 
 int
@@ -3247,14 +3256,7 @@ nfs4_state_start(void)
 int
 nfs4_in_grace(void)
 {
-	return get_seconds() < grace_end;
-}
-
-void
-set_no_grace(void)
-{
-	printk("NFSD: ERROR in reboot recovery.  State reclaims will fail.\n");
-	grace_end = get_seconds();
+	return in_grace;
 }
 
 time_t


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
