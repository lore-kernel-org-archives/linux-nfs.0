From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 12 - NFSv4: return err_nofilehandle if missing fh in fh_verify()
Date: Thu, 22 Aug 2002 10:34:47 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfvz-00051G-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  "Kendrick M. Smith" <kmsmith@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfwO-0008Vq-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:35:12 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <kmsmith@umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:35:04 +1000
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

Return nfserr_nofilehandle (v4 only) in fh_verify() if the filehandle
has not been set.



 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c |    2 ++
 1 files changed, 2 insertions(+)

--- ./fs/nfsd/nfsfh.c	2002/08/21 23:22:36	1.3
+++ ./fs/nfsd/nfsfh.c	2002/08/21 23:23:09	1.4
@@ -109,6 +109,8 @@ fh_verify(struct svc_rqst *rqstp, struct
 		error = nfserr_stale;
 		if (rqstp->rq_vers > 2)
 			error = nfserr_badhandle;
+		if (rqstp->rq_vers == 4 && fh->fh_size == 0)
+			return nfserr_nofilehandle;
 
 		if (fh->fh_version == 1) {
 			datap = fh->fh_auth;


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
