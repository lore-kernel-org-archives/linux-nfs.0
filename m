From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 7 - Correct some error codes reutrned in nfsfh.c
Date: Tue, 17 Dec 2002 12:59:27 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18O715-0000pC-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18O71O-0003np-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 17:59:46 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.239] == wireless-239.wireless.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 17 Dec 2002 12:59:36 +1100
To: Marcelo Tosatti <marcelo@conectiva.com.br>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



These error spotted by  "Kendrick M. Smith" <kmsmith@umich.edu>

They aren't very significant as a well-behaved client is
unlikely to make a request that would result in these errors.



 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2002-12-16 16:30:07.000000000 +1100
+++ ./fs/nfsd/nfsfh.c	2002-12-17 09:50:09.000000000 +1100
@@ -678,11 +678,16 @@ fh_verify(struct svc_rqst *rqstp, struct
 
 	/* Type can be negative to e.g. exclude directories from linking */
 	if (type > 0 && (inode->i_mode & S_IFMT) != type) {
-		error = (type == S_IFDIR)? nfserr_notdir : nfserr_isdir;
+		if (type == S_IFDIR)
+			error = nfserr_notdir;
+		else if ((inode->i_mode & S_IFMT) == S_IFDIR)
+			error = nfserr_isdir;
+		else
+			error = nfserr_inval;
 		goto out;
 	}
 	if (type < 0 && (inode->i_mode & S_IFMT) == -type) {
-		error = (type == -S_IFDIR)? nfserr_notdir : nfserr_isdir;
+		error = (type == -S_IFDIR)? nfserr_isdir : nfserr_notdir;
 		goto out;
 	}
 


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
