From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 12 - NFSv4: fix type checking in fh_verify()
Date: Thu, 22 Aug 2002 10:34:45 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfvx-000516-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  "Kendrick M. Smith" <kmsmith@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfwK-0008S3-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:35:09 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <kmsmith@umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:35:00 +1000
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

Change the type checking in fh_verify().  This fixes a bug which
I reported on the mailing list a few days ago, and also adds a
new error code nfserr_symlink (v4 only).  This is returned whenever
an operation which is illegal for symlinks is attempted on a symlink,
and takes precedence over ERR_NOTDIR or ERR_INVAL.



 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

--- ./fs/nfsd/nfsfh.c	2002/08/21 23:22:13	1.1
+++ ./fs/nfsd/nfsfh.c	2002/08/21 23:22:16	1.2
@@ -234,11 +234,23 @@ fh_verify(struct svc_rqst *rqstp, struct
 
 	/* Type can be negative when creating hardlinks - not to a dir */
 	if (type > 0 && (inode->i_mode & S_IFMT) != type) {
-		error = (type == S_IFDIR)? nfserr_notdir : nfserr_isdir;
+		if (rqstp->rq_vers == 4 && (inode->i_mode & S_IFMT) == S_IFLNK)
+			error = nfserr_symlink;
+		else if (type == S_IFDIR)
+			error = nfserr_notdir;
+		else if ((inode->i_mode & S_IFMT) == S_IFDIR)
+			error = nfserr_isdir;
+		else
+			error = nfserr_inval;
 		goto out;
 	}
 	if (type < 0 && (inode->i_mode & S_IFMT) == -type) {
-		error = (type == -S_IFDIR)? nfserr_notdir : nfserr_isdir;
+		if (rqstp->rq_vers == 4 && (inode->i_mode & S_IFMT) == S_IFLNK)
+			error = nfserr_symlink;
+		else if (type == -S_IFDIR)
+			error = nfserr_isdir;
+		else
+			error = nfserr_notdir;
 		goto out;
 	}
 


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
