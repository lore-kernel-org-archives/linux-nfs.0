From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] NFS: Support multiple segment iovecs in the NFS
	direct	I/O path
Date: Mon, 12 Nov 2007 12:16:52 -0500
Message-ID: <20071112171652.3053.30415.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ircuf-0006sv-9R
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 09:17:29 -0800
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ircuk-0005Em-Nb
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 09:17:35 -0800
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

Allow applications to perform asynchronous scatter-gather direct I/O
to NFS files.

Signed-off-by: Chuck Lever <cel@netapp.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/direct.c |   67 +++++++++++++++++++------------------------------------
 1 files changed, 23 insertions(+), 44 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e30d928..88d5d1c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -272,8 +272,6 @@ static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq, unsigned lo
 	int result;
 	ssize_t started = 0;
 
-	get_dreq(dreq);
-
 	do {
 		struct nfs_read_data *data;
 		size_t bytes;
@@ -347,11 +345,8 @@ static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq, unsigned lo
 		count -= bytes;
 	} while (count != 0);
 
-	if (put_dreq(dreq))
-		nfs_direct_complete(dreq);
-
 	if (started)
-		return 0;
+		return started;
 	return result < 0 ? (ssize_t) result : -EFAULT;
 }
 
@@ -390,7 +385,8 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	return -EIO;
 }
 
-static ssize_t nfs_direct_read(struct kiocb *iocb, unsigned long user_addr, size_t count, loff_t pos)
+static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
+			       unsigned long nr_segs, loff_t pos)
 {
 	ssize_t result = 0;
 	sigset_t oldset;
@@ -407,9 +403,8 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, unsigned long user_addr, size
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	nfs_add_stats(inode, NFSIOS_DIRECTREADBYTES, count);
 	rpc_clnt_sigmask(clnt, &oldset);
-	result = nfs_direct_read_schedule(dreq, user_addr, count, pos);
+	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 	rpc_clnt_sigunmask(clnt, &oldset);
@@ -645,8 +640,6 @@ static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq, unsigned l
 	int result;
 	ssize_t started = 0;
 
-	get_dreq(dreq);
-
 	do {
 		struct nfs_write_data *data;
 		size_t bytes;
@@ -724,11 +717,8 @@ static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq, unsigned l
 		count -= bytes;
 	} while (count != 0);
 
-	if (put_dreq(dreq))
-		nfs_direct_write_complete(dreq, inode);
-
 	if (started)
-		return 0;
+		return started;
 	return result < 0 ? (ssize_t) result : -EFAULT;
 }
 
@@ -768,7 +758,9 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	return -EIO;
 }
 
-static ssize_t nfs_direct_write(struct kiocb *iocb, unsigned long user_addr, size_t count, loff_t pos)
+static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
+				unsigned long nr_segs, loff_t pos,
+				size_t count)
 {
 	ssize_t result = 0;
 	sigset_t oldset;
@@ -791,10 +783,8 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, unsigned long user_addr, siz
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	nfs_add_stats(inode, NFSIOS_DIRECTWRITTENBYTES, count);
-
 	rpc_clnt_sigmask(clnt, &oldset);
-	result = nfs_direct_write_schedule(dreq, user_addr, count, pos, sync);
+	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, sync);
 	if (!result)
 		result = nfs_direct_wait(dreq);
 	rpc_clnt_sigunmask(clnt, &oldset);
@@ -830,21 +820,16 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
-	/* XXX: temporary */
-	const char __user *buf = iov[0].iov_base;
-	size_t count = iov[0].iov_len;
+	size_t count;
+
+	count = iov_length(iov, nr_segs);
+	nfs_add_stats(mapping->host, NFSIOS_DIRECTREADBYTES, count);
 
-	dprintk("nfs: direct read(%s/%s, %lu@%Ld)\n",
+	dprintk("nfs: direct read(%s/%s, %zd@%Ld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
-		(unsigned long) count, (long long) pos);
+		count, (long long) pos);
 
-	if (nr_segs != 1)
-		goto out;
-
-	retval = -EFAULT;
-	if (!access_ok(VERIFY_WRITE, buf, count))
-		goto out;
 	retval = 0;
 	if (!count)
 		goto out;
@@ -853,7 +838,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	if (retval)
 		goto out;
 
-	retval = nfs_direct_read(iocb, (unsigned long) buf, count, pos);
+	retval = nfs_direct_read(iocb, iov, nr_segs, pos);
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;
 
@@ -892,17 +877,15 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	ssize_t retval = -EINVAL;
 	struct file *file = iocb->ki_filp;
 	struct address_space *mapping = file->f_mapping;
-	/* XXX: temporary */
-	const char __user *buf = iov[0].iov_base;
-	size_t count = iov[0].iov_len;
+	size_t count;
 
-	dprintk("nfs: direct write(%s/%s, %lu@%Ld)\n",
+	count = iov_length(iov, nr_segs);
+	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
+
+	dfprintk(VFS, "nfs: direct write(%s/%s, %zd@%Ld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
-		(unsigned long) count, (long long) pos);
-
-	if (nr_segs != 1)
-		goto out;
+		count, (long long) pos);
 
 	retval = generic_write_checks(file, &pos, &count, 0);
 	if (retval)
@@ -915,15 +898,11 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!count)
 		goto out;
 
-	retval = -EFAULT;
-	if (!access_ok(VERIFY_READ, buf, count))
-		goto out;
-
 	retval = nfs_sync_mapping(mapping);
 	if (retval)
 		goto out;
 
-	retval = nfs_direct_write(iocb, (unsigned long) buf, count, pos);
+	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count);
 
 	if (retval > 0)
 		iocb->ki_pos = pos + retval;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
