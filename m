From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 8 of 12 - NFSv4: overflow check in nfsd_commit()
Date: Thu, 22 Aug 2002 10:35:01 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfwC-00051Y-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  "Kendrick M. Smith" <kmsmith@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfwa-0000L6-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:35:24 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <kmsmith@umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:35:16 +1000
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

Sanity check COMMIT arguments by ensuring that (start)+(length) < 2^64.
The check is done in a way which is free of signedness pathologies in
all cases.

This change was inspired by pynfs, Peter Astrand's regression testsuite
for NFSv4 servers.  The change is necessary for all of the COMMIT tests
to pass.  However, it's a little open to debate whether the change is
really needed.  I'm curious to hear the opinions of other developers.


 ----------- Diffstat output ------------
 ./fs/nfsd/vfs.c |    3 +++
 1 files changed, 3 insertions(+)

--- ./fs/nfsd/vfs.c	2002/08/21 23:22:36	1.2
+++ ./fs/nfsd/vfs.c	2002/08/21 23:24:08	1.3
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
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
