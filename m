From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 22/38: SERVER: type checking in fh_verify()
Date: Wed, 14 Aug 2002 16:47:14 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141646370.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f52y-0005zc-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:47:16 -0700
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


Change the type checking in fh_verify().  This fixes a bug which
I reported on the mailing list a few days ago, and also adds a
new error code nfserr_symlink (v4 only).  This is returned whenever
an operation which is illegal for symlinks is attempted on a symlink,
and takes precedence over ERR_NOTDIR or ERR_INVAL.

--- old/fs/nfsd/nfsfh.c	Thu Aug  1 16:16:19 2002
+++ new/fs/nfsd/nfsfh.c	Sun Aug 11 22:52:47 2002
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
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
