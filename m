From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Set PG_uptodate in nfs_writepage_sync()
Date: Sun, 28 Jul 2002 17:24:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <31733.3028339364$1027870006@news.gmane.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Ypu4-00059K-00
	for <nfs@lists.sourceforge.net>; Sun, 28 Jul 2002 08:24:16 -0700
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


A patch by Charles Lever (Charles.Lever@netapp.com) that ensures the
PG_uptodate bit gets set if an entire page gets written by
nfs_writepage_sync().

diff -u --recursive --new-file linux-2.5.29/fs/nfs/write.c linux-2.5.29-noac/fs/nfs/write.c
--- linux-2.5.29/fs/nfs/write.c	Thu Jul  4 18:17:16 2002
+++ linux-2.5.29-noac/fs/nfs/write.c	Sat Jul 27 17:28:29 2002
@@ -808,8 +808,15 @@
 	 * If wsize is smaller than page size, update and write
 	 * page synchronously.
 	 */
-	if (NFS_SERVER(inode)->wsize < PAGE_CACHE_SIZE || IS_SYNC(inode))
-		return nfs_writepage_sync(file, inode, page, offset, count);
+	if (NFS_SERVER(inode)->wsize < PAGE_CACHE_SIZE || IS_SYNC(inode)) {
+		status = nfs_writepage_sync(file, inode, page, offset, count);
+		if (status > 0) {
+			if (offset == 0 && status == PAGE_CACHE_SIZE)
+				SetPageUptodate(page);
+			return 0;
+		}
+		return status;
+	}
 
 	/*
 	 * Try to find an NFS request corresponding to this page


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
