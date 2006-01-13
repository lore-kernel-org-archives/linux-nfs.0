From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 019 of 26] nfsd4: don't create on open that fails due to ERR_GRACE
Date: Fri, 13 Jan 2006 12:01:02 +1100
Message-ID: <1060113010102.23156@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJe-0002bC-5w
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:18 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJY-00053f-Mz
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:18 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.18] == smtp-dist-03.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:08 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:04 +1100
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


In an earlier patch (commit b648330a1d741d5df8a5076b2a0a2519c69c8f41) I
noted that a too-early grace-period check was preventing us from bumping
the sequence id on open.  Unfortunately in that patch I stupidly moved the
grace-period check back too far, so now an open for create can succesfully
create the file while still returning ERR_GRACE.

The correct place for that check is after we've set the open_owner and
handled any replays, but before we actually start mucking with the filesystem.

Thanks to Avishay Traeger for reporting the bug.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c  |    8 ++++++++
 ./fs/nfsd/nfs4state.c |    6 ------
 2 files changed, 8 insertions(+), 6 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2006-01-13 11:51:08.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2006-01-13 11:51:09.000000000 +1100
@@ -192,6 +192,14 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	}
 	if (status)
 		goto out;
+
+	/* Openowner is now set, so sequence id will get bumped.  Now we need
+	 * these checks before we do any creates: */
+	if (nfs4_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
+		return nfserr_grace;
+	if (!nfs4_in_grace() && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
+		return nfserr_no_grace;
+
 	switch (open->op_claim_type) {
 		case NFS4_OPEN_CLAIM_DELEGATE_CUR:
 			status = nfserr_inval;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-01-13 11:51:09.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-01-13 11:51:09.000000000 +1100
@@ -1732,12 +1732,6 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	struct nfs4_delegation *dp = NULL;
 	int status;
 
-	if (nfs4_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
-		return nfserr_grace;
-
-	if (!nfs4_in_grace() && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
-		return nfserr_no_grace;
-
 	status = nfserr_inval;
 	if (!TEST_ACCESS(open->op_share_access) || !TEST_DENY(open->op_share_deny))
 		goto out;


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
