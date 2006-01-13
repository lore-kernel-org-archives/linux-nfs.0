From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 018 of 26] nfsd4: simplify process-open1 logic
Date: Fri, 13 Jan 2006 12:01:02 +1100
Message-ID: <1060113010102.23144@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJX-0002a9-SX
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:11 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJV-0004zO-91
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:11 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.17] == smtp-dist-02.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:05 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:02 +1100
To: nfs@lists.sourceforge.net
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


nfsd4_process_open1 is very highly nested; flatten it out a bit.

Also, the preceding comment, which just outlines the logic, seems redundant.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   99 +++++++++++++++++---------------------------------
 1 file changed, 35 insertions(+), 64 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-01-13 11:51:08.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-01-13 11:51:09.000000000 +1100
@@ -1429,90 +1429,61 @@ static struct lock_manager_operations nf
 };
 
 
-/*
- * nfsd4_process_open1()
- * 	lookup stateowner.
- * 		found:
- * 			check confirmed 
- * 				confirmed:
- * 					check seqid
- * 				not confirmed:
- * 					delete owner
- * 					create new owner
- * 		notfound:
- * 			verify clientid
- * 			create new owner
- *
- * called with nfs4_lock_state() held.
- */
 int
 nfsd4_process_open1(struct nfsd4_open *open)
 {
-	int status;
 	clientid_t *clientid = &open->op_clientid;
 	struct nfs4_client *clp = NULL;
 	unsigned int strhashval;
 	struct nfs4_stateowner *sop = NULL;
 
-	status = nfserr_inval;
 	if (!check_name(open->op_owner))
-		goto out;
+		return nfserr_inval;
 
 	if (STALE_CLIENTID(&open->op_clientid))
 		return nfserr_stale_clientid;
 
 	strhashval = ownerstr_hashval(clientid->cl_id, open->op_owner);
 	sop = find_openstateowner_str(strhashval, open);
-	if (sop) {
-		open->op_stateowner = sop;
-		if (!sop->so_confirmed) {
-			/* Replace any unconfirmed stateowner without
-			 * even checking for replays */
-			clp = sop->so_client;
-			release_stateowner(sop);
-		} else if (open->op_seqid == sop->so_seqid) {
-			/* normal case */
-			goto renew;
-		} else if (open->op_seqid == sop->so_seqid - 1) {
-			/* replay */
-			if (sop->so_replay.rp_buflen)
-				return NFSERR_REPLAY_ME;
-			else {
-				/* The original OPEN failed so spectacularly
-				 * that we don't even have replay data saved!
-				 * Therefore, we have no choice but to continue
-				 * processing this OPEN; presumably, we'll
-				 * fail again for the same reason.
-				 */
-				dprintk("nfsd4_process_open1:"
-					" replay with no replay cache\n");
-				goto renew;
-			}
-		} else {
-			status = nfserr_bad_seqid;
-			goto out;
-		}
-	} else {
-		/* nfs4_stateowner not found.
-		 * Verify clientid and instantiate new nfs4_stateowner.
-		 * If verify fails this is presumably the result of the
-		 * client's lease expiring.
-		 */
-		status = nfserr_expired;
+	open->op_stateowner = sop;
+	if (!sop) {
+		/* Make sure the client's lease hasn't expired. */
 		clp = find_confirmed_client(clientid);
 		if (clp == NULL)
-			goto out;
+			return nfserr_expired;
+		goto renew;
 	}
-	status = nfserr_resource;
-	sop = alloc_init_open_stateowner(strhashval, clp, open);
-	if (sop == NULL)
-		goto out;
-	open->op_stateowner = sop;
+	if (!sop->so_confirmed) {
+		/* Replace unconfirmed owners without checking for replay. */
+		clp = sop->so_client;
+		release_stateowner(sop);
+		open->op_stateowner = NULL;
+		goto renew;
+	}
+	if (open->op_seqid == sop->so_seqid - 1) {
+		if (sop->so_replay.rp_buflen)
+			return NFSERR_REPLAY_ME;
+		/* The original OPEN failed so spectacularly
+		 * that we don't even have replay data saved!
+		 * Therefore, we have no choice but to continue
+		 * processing this OPEN; presumably, we'll
+		 * fail again for the same reason.
+		 */
+		dprintk("nfsd4_process_open1: replay with no replay cache\n");
+		goto renew;
+	}
+	if (open->op_seqid != sop->so_seqid)
+		return nfserr_bad_seqid;
 renew:
-	status = nfs_ok;
+	if (open->op_stateowner == NULL) {
+		sop = alloc_init_open_stateowner(strhashval, clp, open);
+		if (sop == NULL)
+			return nfserr_resource;
+		open->op_stateowner = sop;
+	}
+	list_del_init(&sop->so_close_lru);
 	renew_client(sop->so_client);
-out:
-	return status;
+	return nfs_ok;
 }
 
 static inline int


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
