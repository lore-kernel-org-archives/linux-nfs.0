From: NeilBrown <neilb@suse.de>
Subject: [PATCH] knfsd: fix nfs4_open lock leak
Date: Mon, 6 Feb 2006 10:05:23 +1100
Message-ID: <1060205230523.27092@suse.de>
References: <20060206100452.27065.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F5swm-0006Bm-AG
	for nfs@lists.sourceforge.net; Sun, 05 Feb 2006 15:05:32 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F5swl-0003su-Lw
	for nfs@lists.sourceforge.net; Sun, 05 Feb 2006 15:05:32 -0800
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


From: "J. Bruce Fields" <bfields@fieldses.org>

I just noticed that my patch "don't create on open that fails due to
ERR_GRACE" (recently commited as
fb553c0f17444e090db951b96df4d2d71b4f4b6b) had an obvious problem that
causes a deadlock on reboot recovery.  Sending in this now since it
seems like a clear 2.6.16 candidate.--b.

We're returning with a lock held in some error cases.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2006-02-06 10:00:26.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2006-02-06 10:02:23.000000000 +1100
@@ -195,10 +195,12 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 
 	/* Openowner is now set, so sequence id will get bumped.  Now we need
 	 * these checks before we do any creates: */
+	status = nfserr_grace;
 	if (nfs4_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
-		return nfserr_grace;
+		goto out;
+	status =nfserr_no_grace;
 	if (!nfs4_in_grace() && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
-		return nfserr_no_grace;
+		goto out;
 
 	switch (open->op_claim_type) {
 		case NFS4_OPEN_CLAIM_DELEGATE_CUR:


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
