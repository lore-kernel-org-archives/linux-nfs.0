From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 017 of 19] nfsd4: clean up nfs4_preprocess_seqid_op
Date: Mon, 04 Jul 2005 11:01:44 +1000
Message-ID: <E1DpFLE-0007H6-EU@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFMA-0001lc-EG
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:42 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DpFM9-0006NA-MT
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:42 -0700
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


As long as we're here, do some miscellaneous cleanup.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   58 +++++++++++++++++++-------------------------------
 1 files changed, 23 insertions(+), 35 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-07-04 10:57:53.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-07-04 10:57:53.000000000 +1000
@@ -2165,7 +2165,6 @@ out:
 static int
 nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *stateid, int flags, struct nfs4_stateowner **sopp, struct nfs4_stateid **stpp, clientid_t *lockclid)
 {
-	int status;
 	struct nfs4_stateid *stp;
 	struct nfs4_stateowner *sop;
 
@@ -2173,19 +2172,17 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 			"stateid = (%08x/%08x/%08x/%08x)\n", seqid,
 		stateid->si_boot, stateid->si_stateownerid, stateid->si_fileid,
 		stateid->si_generation);
-			        
+
 	*stpp = NULL;
 	*sopp = NULL;
 
-	status = nfserr_bad_stateid;
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid)) {
 		printk("NFSD: preprocess_seqid_op: magic stateid!\n");
-		goto out;
+		return nfserr_bad_stateid;
 	}
 
-	status = nfserr_stale_stateid;
 	if (STALE_STATEID(stateid))
-		goto out;
+		return nfserr_stale_stateid;
 	/*
 	* We return BAD_STATEID if filehandle doesn't match stateid, 
 	* the confirmed flag is incorrecly set, or the generation 
@@ -2204,8 +2201,6 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 		goto check_replay;
 	}
 
-	status = nfserr_bad_stateid;
-
 	/* for new lock stateowners:
 	 * check that the lock->v.new.open_stateid
 	 * refers to an open stateowner
@@ -2218,14 +2213,14 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 		struct nfs4_client *clp = sop->so_client;
 
 		if (!sop->so_is_open_owner)
-			goto out;
+			return nfserr_bad_stateid;
 		if (!cmp_clid(&clp->cl_clientid, lockclid))
-			goto out;
+			return nfserr_bad_stateid;
 	}
 
 	if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp)) {
 		printk("NFSD: preprocess_seqid_op: fh-stateid mismatch!\n");
-		goto out;
+		return nfserr_bad_stateid;
 	}
 
 	*stpp = stp;
@@ -2239,45 +2234,38 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 	if (seqid != sop->so_seqid)
 		goto check_replay;
 
-	if (sop->so_confirmed) {
-		if (flags & CONFIRM) {
-			printk("NFSD: preprocess_seqid_op: expected unconfirmed stateowner!\n");
-			goto out;
-		}
-	}
-	else {
-		if (!(flags & CONFIRM)) {
-			printk("NFSD: preprocess_seqid_op: stateowner not confirmed yet!\n");
-			goto out;
-		}
+	if (sop->so_confirmed && flags & CONFIRM) {
+		printk("NFSD: preprocess_seqid_op: expected"
+				" unconfirmed stateowner!\n");
+		return nfserr_bad_stateid;
+	}
+	if (!sop->so_confirmed && !(flags & CONFIRM)) {
+		printk("NFSD: preprocess_seqid_op: stateowner not"
+				" confirmed yet!\n");
+		return nfserr_bad_stateid;
 	}
 	if (stateid->si_generation > stp->st_stateid.si_generation) {
 		printk("NFSD: preprocess_seqid_op: future stateid?!\n");
-		goto out;
+		return nfserr_bad_stateid;
 	}
 
-	status = nfserr_old_stateid;
 	if (stateid->si_generation < stp->st_stateid.si_generation) {
 		printk("NFSD: preprocess_seqid_op: old stateid!\n");
-		goto out;
+		return nfserr_old_stateid;
 	}
 	renew_client(sop->so_client);
-	status = nfs_ok;
+	return nfs_ok;
 
-out:
-	return status;
 check_replay:
 	if (seqid == sop->so_seqid - 1) {
 		printk("NFSD: preprocess_seqid_op: retransmission?\n");
 		/* indicate replay to calling function */
-		status = NFSERR_REPLAY_ME;
-	} else  {
-		printk("NFSD: preprocess_seqid_op: bad seqid (expected %d, got %d\n", sop->so_seqid, seqid);
-
-		*sopp = NULL;
-		status = nfserr_bad_seqid;
+		return NFSERR_REPLAY_ME;
 	}
-	goto out;
+	printk("NFSD: preprocess_seqid_op: bad seqid (expected %d, got %d)\n",
+			sop->so_seqid, seqid);
+	*sopp = NULL;
+	return nfserr_bad_seqid;
 }
 
 int


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
