From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 12 - NFSv4: change ->rq_vers==3 to ->rq_vers>2
Date: Thu, 22 Aug 2002 10:34:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfvy-00051B-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  "Kendrick M. Smith" <kmsmith@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfwN-0008Ui-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:35:11 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <kmsmith@umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:35:02 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


### Comments for ChangeSet

From:	"Kendrick M. Smith" <kmsmith@umich.edu>

In a few places on the server, I had to change code that looked like:

   if (rqstp->rq_vers == 3)
       /* NFSv3 behavior */
   else
       /* NFSv2 behavior */

to:

   if (rqstp->rq_vers > 2)
       /* NFSv3 behavior */
   else
       /* NFSv2 behavior */

so that we would get the NFSv3 behavior, not the NFSv2 behavior,
in NFSv4.  This patch collects all changes of this type.



 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c |    4 ++--
 ./fs/nfsd/vfs.c   |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

--- ./fs/nfsd/nfsfh.c	2002/08/21 23:22:16	1.2
+++ ./fs/nfsd/nfsfh.c	2002/08/21 23:22:36	1.3
@@ -107,7 +107,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 		int fsid = 0;
 
 		error = nfserr_stale;
-		if (rqstp->rq_vers == 3)
+		if (rqstp->rq_vers > 2)
 			error = nfserr_badhandle;
 
 		if (fh->fh_version == 1) {
@@ -171,7 +171,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 		 * Look up the dentry using the NFS file handle.
 		 */
 		error = nfserr_stale;
-		if (rqstp->rq_vers == 3)
+		if (rqstp->rq_vers > 2)
 			error = nfserr_badhandle;
 
 		if (fh->fh_version != 1) {
--- ./fs/nfsd/vfs.c	2002/08/21 23:22:32	1.1
+++ ./fs/nfsd/vfs.c	2002/08/21 23:22:36	1.2
@@ -1401,7 +1401,7 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 	eof = !cd.eob;
 
 	if (cd.offset) {
-		if (rqstp->rq_vers == 3)
+		if (rqstp->rq_vers > 2)
 			(void)xdr_encode_hyper(cd.offset, file.f_pos);
 		else
 			*cd.offset = htonl(file.f_pos);


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
