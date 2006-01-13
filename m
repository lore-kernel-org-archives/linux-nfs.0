From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 021 of 26] nfsd4: Fix bug in rdattr_error return
Date: Fri, 13 Jan 2006 12:01:04 +1100
Message-ID: <1060113010104.23180@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJY-0002aM-Qj
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:12 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJX-0006pR-86
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:12 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.16] == smtp-dist-01.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:08 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:05 +1100
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


Fix bug in rdattr_error return which causes correct error code
to be overwritten by nfserr_toosmall.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2006-01-13 11:51:05.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2006-01-13 11:51:09.000000000 +1100
@@ -1764,10 +1764,11 @@ nfsd4_encode_dirent(struct readdir_cd *c
 		 */
 		if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR))
 			goto fail;
-		nfserr = nfserr_toosmall;
 		p = nfsd4_encode_rdattr_error(p, buflen, nfserr);
-		if (p == NULL)
+		if (p == NULL) {
+			nfserr = nfserr_toosmall;
 			goto fail;
+		}
 	}
 	cd->buflen -= (p - cd->buffer);
 	cd->buffer = p;


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
