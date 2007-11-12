From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] NFS: Introduce iovec I/O helpers to
	fs/nfs/direct.c
Date: Mon, 12 Nov 2007 12:16:47 -0500
Message-ID: <20071112171647.3053.70179.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ircun-0006t2-Qx
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 09:17:38 -0800
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ircut-0001Iw-6g
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 09:17:43 -0800
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

Add helpers that iterate over multi-segment iovecs.  These will
be used to support multi-segment scatter/gather direct I/O in a
later patch.

Signed-off-by: Chuck Lever <cel@netapp.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/direct.c |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index afcab00..e30d928 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -355,6 +355,41 @@ static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq, unsigned lo
 	return result < 0 ? (ssize_t) result : -EFAULT;
 }
 
+static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
+					      const struct iovec *iov,
+					      unsigned long nr_segs,
+					      loff_t pos)
+{
+	ssize_t result = -EINVAL;
+	size_t requested_bytes = 0;
+	unsigned long seg;
+
+	get_dreq(dreq);
+
+	for (seg = 0; seg < nr_segs; seg++) {
+		const struct iovec *vec = &iov[seg];
+		result = nfs_direct_read_schedule(dreq,
+					(unsigned long)vec->iov_base,
+						  vec->iov_len, pos);
+		if (result < 0)
+			break;
+		requested_bytes += result;
+		if ((size_t)result < vec->iov_len)
+			break;
+		pos += vec->iov_len;
+	}
+
+	if (put_dreq(dreq))
+		nfs_direct_complete(dreq);
+
+	if (requested_bytes != 0)
+		return 0;
+
+	if (result < 0)
+		return result;
+	return -EIO;
+}
+
 static ssize_t nfs_direct_read(struct kiocb *iocb, unsigned long user_addr, size_t count, loff_t pos)
 {
 	ssize_t result = 0;
@@ -697,6 +732,42 @@ static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq, unsigned l
 	return result < 0 ? (ssize_t) result : -EFAULT;
 }
 
+static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
+					       const struct iovec *iov,
+					       unsigned long nr_segs,
+					       loff_t pos, int sync)
+{
+	ssize_t result = 0;
+	size_t requested_bytes = 0;
+	unsigned long seg;
+
+	get_dreq(dreq);
+
+	for (seg = 0; seg < nr_segs; seg++) {
+		const struct iovec *vec = &iov[seg];
+		result = nfs_direct_write_schedule(dreq,
+					(unsigned long)vec->iov_base,
+						   vec->iov_len,
+						   pos, sync);
+		if (result < 0)
+			break;
+		requested_bytes += result;
+		if ((size_t)result < vec->iov_len)
+			break;
+		pos += vec->iov_len;
+	}
+
+	if (put_dreq(dreq))
+		nfs_direct_write_complete(dreq, dreq->inode);
+
+	if (requested_bytes != 0)
+		return 0;
+
+	if (result < 0)
+		return result;
+	return -EIO;
+}
+
 static ssize_t nfs_direct_write(struct kiocb *iocb, unsigned long user_addr, size_t count, loff_t pos)
 {
 	ssize_t result = 0;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
