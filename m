From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 25/38: SERVER: return err_nofilehandle if missing fh in
 fh_verify()
Date: Tue, 13 Aug 2002 19:06:40 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131906180.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ekkN-0003xB-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 16:06:43 -0700
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


Return nfserr_nofilehandle (v4 only) in fh_verify() if the filehandle
has not been set.

--- old/fs/nfsd/nfsfh.c	Tue Jul 30 22:20:35 2002
+++ new/fs/nfsd/nfsfh.c	Mon Jul 29 12:39:43 2002
@@ -109,6 +109,8 @@ fh_verify(struct svc_rqst *rqstp, struct
 		error = nfserr_stale;
 		if (rqstp->rq_vers > 2)
 			error = nfserr_badhandle;
+		if (rqstp->rq_vers == 4 && fh->fh_size == 0)
+			return nfserr_nofilehandle;

 		if (fh->fh_version == 1) {
 			datap = fh->fh_auth;



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
