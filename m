From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 24/38: SERVER: return err_nofilehandle if missing fh
 in fh_verify()
Date: Wed, 14 Aug 2002 16:48:15 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141647520.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f53x-0006qV-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:48:17 -0700
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

--- old/fs/nfsd/nfsfh.c	Sun Aug 11 22:53:39 2002
+++ new/fs/nfsd/nfsfh.c	Sun Aug 11 22:54:13 2002
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
