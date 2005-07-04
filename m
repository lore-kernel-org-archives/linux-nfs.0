From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 007 of 19] nfsd4: ERR_GRACE should bump seqid on lock
Date: Mon, 04 Jul 2005 11:01:43 +1000
Message-ID: <E1DpFLD-0007GS-Md@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFMB-0001lm-4W
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:43 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DpFM9-0007MA-Lj
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:43 -0700
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


A GRACE or NOGRACE response to a lock request should also bump the sequence id.
So we delay the handling of grace period errors till after we've found the
relevant owner.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-07-04 10:57:52.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-07-04 10:57:52.000000000 +1000
@@ -2706,11 +2706,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		(long long) lock->lk_offset,
 		(long long) lock->lk_length);
 
-	if (nfs4_in_grace() && !lock->lk_reclaim)
-		return nfserr_grace;
-	if (!nfs4_in_grace() && lock->lk_reclaim)
-		return nfserr_no_grace;
-
 	if (check_lock_length(lock->lk_offset, lock->lk_length))
 		 return nfserr_inval;
 
@@ -2785,6 +2780,13 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		goto out;
 	}
 
+	status = nfserr_grace;
+	if (nfs4_in_grace() && !lock->lk_reclaim)
+		goto out;
+	status = nfserr_no_grace;
+	if (!nfs4_in_grace() && lock->lk_reclaim)
+		goto out;
+
 	locks_init_lock(&file_lock);
 	switch (lock->lk_type) {
 		case NFS4_READ_LT:


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
