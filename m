From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] NFS: Clean up new multi-segment direct I/O changes
Date: Mon, 12 Nov 2007 12:17:03 -0500
Message-ID: <20071112171703.3053.4101.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ircw0-00070c-0I
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 09:18:53 -0800
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ircw5-0001T6-NE
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 09:18:57 -0800
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

Simplify calling sequence of nfs_direct_{read,write}_schedule(), and
rename them to reflect their new role.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/direct.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 4d726e9..5e8d82f 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -263,10 +263,14 @@ static const struct rpc_call_ops nfs_read_direct_ops = {
  * handled automatically by nfs_direct_read_result().  Otherwise, if
  * no requests have been sent, just return an error.
  */
-static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq, unsigned long user_addr, size_t count, loff_t pos)
+static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
+						const struct iovec *iov,
+						loff_t pos)
 {
 	struct nfs_open_context *ctx = dreq->ctx;
 	struct inode *inode = ctx->path.dentry->d_inode;
+	unsigned long user_addr = (unsigned long)iov->iov_base;
+	size_t count = iov->iov_len;
 	size_t rsize = NFS_SERVER(inode)->rsize;
 	unsigned int pgbase;
 	int result;
@@ -363,9 +367,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
-		result = nfs_direct_read_schedule(dreq,
-					(unsigned long)vec->iov_base,
-						  vec->iov_len, pos);
+		result = nfs_direct_read_schedule_segment(dreq, vec, pos);
 		if (result < 0)
 			break;
 		requested_bytes += result;
@@ -631,10 +633,14 @@ static const struct rpc_call_ops nfs_write_direct_ops = {
  * handled automatically by nfs_direct_write_result().  Otherwise, if
  * no requests have been sent, just return an error.
  */
-static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq, unsigned long user_addr, size_t count, loff_t pos, int sync)
+static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
+						 const struct iovec *iov,
+						 loff_t pos, int sync)
 {
 	struct nfs_open_context *ctx = dreq->ctx;
 	struct inode *inode = ctx->path.dentry->d_inode;
+	unsigned long user_addr = (unsigned long)iov->iov_base;
+	size_t count = iov->iov_len;
 	size_t wsize = NFS_SERVER(inode)->wsize;
 	unsigned int pgbase;
 	int result;
@@ -735,10 +741,8 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
-		result = nfs_direct_write_schedule(dreq,
-					(unsigned long)vec->iov_base,
-						   vec->iov_len,
-						   pos, sync);
+		result = nfs_direct_write_schedule_segment(dreq, vec,
+							   pos, sync);
 		if (result < 0)
 			break;
 		requested_bytes += result;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
