From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 30/38: SERVER: overflow check in nfsd_commit()
Date: Tue, 13 Aug 2002 19:09:12 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131908540.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ekmo-0007Dm-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 16:09:14 -0700
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


Sanity check COMMIT arguments by ensuring that (start)+(length) < 2^64.
The check is done in a way which is free of signedness pathologies in
all cases.

This change was inspired by pynfs, Peter Astrand's regression testsuite
for NFSv4 servers.  The change is necessary for all of the COMMIT tests
to pass.  However, it's a little open to debate whether the change is
really needed.  I'm curious to hear the opinions of other developers.


--- old/fs/nfsd/vfs.c	Tue Jul 30 23:24:21 2002
+++ new/fs/nfsd/vfs.c	Mon Jul 29 11:50:09 2002
@@ -756,6 +756,9 @@ nfsd_commit(struct svc_rqst *rqstp, stru
 	struct file	file;
 	int		err;

+	if ((u64)count > ~(u64)offset)
+		return nfserr_inval;
+
 	if ((err = nfsd_open(rqstp, fhp, S_IFREG, MAY_WRITE, &file)) != 0)
 		return err;
 	if (EX_ISSYNC(fhp->fh_export)) {



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
