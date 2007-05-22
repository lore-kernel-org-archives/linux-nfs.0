From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/4] NFS: Clean ups in fs/nfs/direct.c
Date: Tue, 22 May 2007 10:29:13 -0400
Message-ID: <20070522142913.22559.83001.stgit@heimdal.trondhjem.org>
References: <20070522142908.22559.91696.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqVMT-00048w-PQ
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 07:29:21 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqVMV-0006eO-HB
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 07:29:20 -0700
In-Reply-To: <20070522142908.22559.91696.stgit@heimdal.trondhjem.org>
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

From: Chuck Lever <chuck.lever@oracle.com>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 6c588ec..49e4823 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -750,10 +750,8 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 		(unsigned long) count, (long long) pos);
 
 	if (nr_segs != 1)
-		return -EINVAL;
-
-	if (count < 0)
 		goto out;
+
 	retval = -EFAULT;
 	if (!access_ok(VERIFY_WRITE, buf, count))
 		goto out;
@@ -801,7 +799,7 @@ out:
 ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos)
 {
-	ssize_t retval;
+	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
 	/* XXX: temporary */
@@ -814,7 +812,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 		(unsigned long) count, (long long) pos);
 
 	if (nr_segs != 1)
-		return -EINVAL;
+		goto out;
 
 	retval = generic_write_checks(file, &pos, &count, 0);
 	if (retval)

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
