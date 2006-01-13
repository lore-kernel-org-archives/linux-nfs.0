From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 024 of 26] nfsd4_truncate() bogus return value
Date: Fri, 13 Jan 2006 12:01:06 +1100
Message-ID: <1060113010106.23216@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJZ-0002aO-49
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:13 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJY-00053T-Gz
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:13 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.17] == smtp-dist-02.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:09 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:07 +1100
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


From: Al Viro <viro@zeniv.linux.org.uk>
Date: 1135492779 -0500

-EINVAL (in host order, no less) is not a good thing to return to client.
nfsd4_truncate() returns it in one case and its callers expect nfs_....
from it.  AFAICS, it should be nfserr_inval

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-01-13 11:51:09.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-01-13 11:51:10.000000000 +1100
@@ -1600,7 +1600,7 @@ nfsd4_truncate(struct svc_rqst *rqstp, s
 	if (!open->op_truncate)
 		return 0;
 	if (!(open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
-		return -EINVAL;
+		return nfserr_inval;
 	return nfsd_setattr(rqstp, fh, &iattr, 0, (time_t)0);
 }
 


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
