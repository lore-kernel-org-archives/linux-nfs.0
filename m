From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 24/38: SERVER: change ->rq_vers==3 to ->rq_vers>2
Date: Tue, 13 Aug 2002 19:06:15 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131905510.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ekjx-0003p0-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 16:06:17 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
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

--- old/fs/nfsd/nfsfh.c	Tue Jul 30 22:12:36 2002
+++ new/fs/nfsd/nfsfh.c	Mon Jul 29 12:39:43 2002
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
--- old/fs/nfsd/vfs.c	Tue Jul 30 22:12:36 2002
+++ new/fs/nfsd/vfs.c	Mon Jul 29 12:39:43 2002
@@ -1401,7 +1401,7 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 	eof = !cd.eob;

 	if (cd.offset) {
-		if (rqstp->rq_vers == 3)
+		if (rqstp->rq_vers > 2)
 			(void)xdr_encode_hyper(cd.offset, file.f_pos);
 		else
 			*cd.offset = htonl(file.f_pos);



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
