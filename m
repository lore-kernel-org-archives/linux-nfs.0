From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] bug in NFSv2 end-of-file read handling
Date: Thu, 7 Nov 2002 17:45:54 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0211071743550.18237-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dexter.citi.umich.edu ([141.211.133.33])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189vPZ-0001ei-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Nov 2002 14:46:05 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

NFSv2 doesn't pass connectathon 2002, at least on some Linux kernels.  
Trond deemed the following modification necessary in all kernels to
address the problem.  a similar patch will go to Marcelo for 2.4.21.


diff -ruN 06-setattr/fs/nfs/nfs2xdr.c 07-readeof/fs/nfs/nfs2xdr.c
--- 06-setattr/fs/nfs/nfs2xdr.c	Mon Nov  4 17:30:22 2002
+++ 07-readeof/fs/nfs/nfs2xdr.c	Thu Nov  7 17:33:01 2002
@@ -233,7 +233,6 @@
 static int
 nfs_xdr_readres(struct rpc_rqst *req, u32 *p, struct nfs_readres *res)
 {
-	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
 	struct iovec *iov = req->rq_rvec;
 	int	status, count, recvd, hdrlen;
 
@@ -243,11 +242,6 @@
 
 	count = ntohl(*p++);
 	res->eof = 0;
-	if (rcvbuf->page_len) {
-		u32 end = page_offset(rcvbuf->pages[0]) + rcvbuf->page_base + count;
-		if (end >= res->fattr->size)
-			res->eof = 1;
-	}
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
 		printk(KERN_WARNING "NFS: READ reply header overflowed:"
@@ -263,7 +257,6 @@
 		printk(KERN_WARNING "NFS: server cheating in read reply: "
 			"count %d > recvd %d\n", count, recvd);
 		count = recvd;
-		res->eof = 0;
 	}
 
 	dprintk("RPC:      readres OK count %d\n", count);
diff -ruN 06-setattr/fs/nfs/read.c 07-readeof/fs/nfs/read.c
--- 06-setattr/fs/nfs/read.c	Mon Nov  4 17:30:03 2002
+++ 07-readeof/fs/nfs/read.c	Thu Nov  7 17:33:01 2002
@@ -355,11 +355,12 @@
 {
 	struct nfs_read_data	*data = (struct nfs_read_data *) task->tk_calldata;
 	struct inode		*inode = data->inode;
+	struct nfs_fattr	*fattr = &data->fattr;
 
 	dprintk("NFS: %4d nfs_readpage_result, (status %d)\n",
 		task->tk_pid, task->tk_status);
 
-	nfs_refresh_inode(inode, &data->fattr);
+	nfs_refresh_inode(inode, fattr);
 	while (!list_empty(&data->pages)) {
 		struct nfs_page *req = nfs_list_entry(data->pages.next);
 		struct page *page = req->wb_page;
@@ -368,13 +369,20 @@
 		if (task->tk_status >= 0) {
 			if (count < PAGE_CACHE_SIZE) {
 				char *p = kmap(page);
-				memset(p + count, 0, PAGE_CACHE_SIZE - count);
+
+				if (count < req->wb_bytes)
+					memset(p + req->wb_offset + count, 0,
+							req->wb_bytes - count);
 				kunmap(page);
-				count = 0;
-				if (eof)
+
+				if (eof ||
+				    ((fattr->valid & NFS_ATTR_FATTR) &&
+				     ((req_offset(req) + req->wb_offset + count) >= fattr->size)))
 					SetPageUptodate(page);
 				else
-					SetPageError(page);
+					if (count < req->wb_bytes)
+						SetPageError(page);
+				count = 0;
 			} else {
 				count -= PAGE_CACHE_SIZE;
 				SetPageUptodate(page);



-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
