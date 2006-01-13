From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 016 of 26] nfsd4: no replays on unconfirmed owners
Date: Fri, 13 Jan 2006 12:01:01 +1100
Message-ID: <1060113010101.23120@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJa-0002as-IW
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:14 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJW-00050d-Hk
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:14 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.16] == smtp-dist-01.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:04 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:01 +1100
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


We shouldn't check for replays until after checking whether the open owner
is confirmed.  Clients are allowed to reuse openowners without bumping the
seqid.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-01-13 11:51:06.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-01-13 11:51:08.000000000 +1100
@@ -1465,8 +1465,16 @@ nfsd4_process_open1(struct nfsd4_open *o
 	sop = find_openstateowner_str(strhashval, open);
 	if (sop) {
 		open->op_stateowner = sop;
-		/* check for replay */
-		if (open->op_seqid == sop->so_seqid - 1){
+		if (!sop->so_confirmed) {
+			/* Replace any unconfirmed stateowner without
+			 * even checking for replays */
+			clp = sop->so_client;
+			release_stateowner(sop);
+		} else if (open->op_seqid == sop->so_seqid) {
+			/* normal case */
+			goto renew;
+		} else if (open->op_seqid == sop->so_seqid - 1) {
+			/* replay */
 			if (sop->so_replay.rp_buflen)
 				return NFSERR_REPLAY_ME;
 			else {
@@ -1480,19 +1488,9 @@ nfsd4_process_open1(struct nfsd4_open *o
 					" replay with no replay cache\n");
 				goto renew;
 			}
-		} else if (sop->so_confirmed) {
-			if (open->op_seqid == sop->so_seqid)
-				goto renew;
+		} else {
 			status = nfserr_bad_seqid;
 			goto out;
-		} else {
-			/* If we get here, we received an OPEN for an
-			 * unconfirmed nfs4_stateowner. Since the seqid's are
-			 * different, purge the existing nfs4_stateowner, and
-			 * instantiate a new one.
-			 */
-			clp = sop->so_client;
-			release_stateowner(sop);
 		}
 	} else {
 		/* nfs4_stateowner not found.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
