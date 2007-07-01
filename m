From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/21] NFS: Clean up nfs_size_to_loff_t()
Date: Sun, 01 Jul 2007 12:12:14 -0400
Message-ID: <20070701161213.2786.44819.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I523Y-0004RI-5M
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:13:48 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I523b-0004wg-I3
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:13:51 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Use the same file size limit that lockd uses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/nfs_fs.h |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index bf24151..3e8dd12 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -503,12 +503,10 @@ extern int  nfsroot_mount(struct sockaddr_in *, char *, struct nfs_fh *,
  * inline functions
  */
 
-static inline loff_t
-nfs_size_to_loff_t(__u64 size)
+static inline loff_t nfs_size_to_loff_t(__u64 size)
 {
-	loff_t maxsz = (((loff_t) ULONG_MAX) << PAGE_CACHE_SHIFT) + PAGE_CACHE_SIZE - 1;
-	if (size > maxsz)
-		return maxsz;
+	if (size > (__u64) OFFSET_MAX - 1)
+		return OFFSET_MAX - 1;
 	return (loff_t) size;
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
