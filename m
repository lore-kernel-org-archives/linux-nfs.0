From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] allow arbitrary alignment of NFS read/write requests
Date: Mon, 6 Jan 2003 22:29:10 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0301062220260.27667-100000@climax.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from climax.citi.umich.edu ([141.211.133.71] ident=[KJ5+SDa5GpD7G1mKkFgcczNqxre/vLAZ])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VkQd-0004i2-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Jan 2003 19:29:24 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

hi trond-

this patch adds a new field called wb_base to the nfs_page struct. this
separates the concept of file page offset from buffer page offset,
allowing NFS to specify read and write requests into buffers at offsets
that are independent of the file page offset.  it is a prequisite for
direct I/O in NFS, and it touches areas of the NFS client that are seeing
a lot of changes these days, so i'm sending it now.

i've run this on 2.5.47-2.5.54 with no problems noted with NFSv2 and v3.

this patch applies against 2.5.54.

 fs/nfs/nfs3proc.c        |    4 ++--
 fs/nfs/nfs4proc.c        |    4 ++--
 fs/nfs/pagelist.c        |    5 +++--
 fs/nfs/proc.c            |    4 ++--
 fs/nfs/read.c            |    2 +-
 fs/nfs/write.c           |    3 ++-
 include/linux/nfs_page.h |    3 ++-
 7 files changed, 14 insertions(+), 11 deletions(-)

diff -Naurp 00-stock/fs/nfs/nfs3proc.c 01-wb_base/fs/nfs/nfs3proc.c
--- 00-stock/fs/nfs/nfs3proc.c	Wed Jan  1 22:22:00 2003
+++ 01-wb_base/fs/nfs/nfs3proc.c	Thu Jan  2 12:27:55 2003
@@ -731,7 +731,7 @@ nfs3_proc_read_setup(struct nfs_read_dat
 	req = nfs_list_entry(data->pages.next);
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req);
-	data->args.pgbase = req->wb_offset;
+	data->args.pgbase = req->wb_base;
 	data->args.pages  = data->pagevec;
 	data->args.count  = count;
 	data->res.fattr   = &data->fattr;
@@ -788,7 +788,7 @@ nfs3_proc_write_setup(struct nfs_write_d
 	req = nfs_list_entry(data->pages.next);
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req);
-	data->args.pgbase = req->wb_offset;
+	data->args.pgbase = req->wb_base;
 	data->args.count  = count;
 	data->args.stable = stable;
 	data->args.pages  = data->pagevec;
diff -Naurp 00-stock/fs/nfs/nfs4proc.c 01-wb_base/fs/nfs/nfs4proc.c
--- 00-stock/fs/nfs/nfs4proc.c	Wed Jan  1 22:22:41 2003
+++ 01-wb_base/fs/nfs/nfs4proc.c	Thu Jan  2 12:27:55 2003
@@ -1372,7 +1372,7 @@ nfs4_proc_read_setup(struct nfs_read_dat
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req);
-	data->args.pgbase = req->wb_offset;
+	data->args.pgbase = req->wb_base;
 	data->args.pages  = data->pagevec;
 	data->args.count  = count;
 	data->res.fattr   = &data->fattr;
@@ -1445,7 +1445,7 @@ nfs4_proc_write_setup(struct nfs_write_d
 
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req);
-	data->args.pgbase = req->wb_offset;
+	data->args.pgbase = req->wb_base;
 	data->args.count  = count;
 	data->args.stable = stable;
 	data->args.pages  = data->pagevec;
diff -Naurp 00-stock/fs/nfs/pagelist.c 01-wb_base/fs/nfs/pagelist.c
--- 00-stock/fs/nfs/pagelist.c	Wed Jan  1 22:23:05 2003
+++ 01-wb_base/fs/nfs/pagelist.c	Thu Jan  2 12:27:55 2003
@@ -91,6 +91,7 @@ nfs_create_request(struct rpc_cred *cred
 	req->wb_index	= page->index;
 	page_cache_get(page);
 	req->wb_offset  = offset;
+	req->wb_base	= offset;
 	req->wb_bytes   = count;
 
 	if (cred)
@@ -278,13 +279,13 @@ nfs_coalesce_requests(struct list_head *
 			if (req->wb_index != (prev->wb_index + 1))
 				break;
 
-			if (req->wb_offset != 0)
+			if (req->wb_base != 0)
 				break;
 		}
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, dst);
 		npages++;
-		if (req->wb_offset + req->wb_bytes != PAGE_CACHE_SIZE)
+		if (req->wb_base + req->wb_bytes != PAGE_CACHE_SIZE)
 			break;
 		if (npages >= nmax)
 			break;
diff -Naurp 00-stock/fs/nfs/proc.c 01-wb_base/fs/nfs/proc.c
--- 00-stock/fs/nfs/proc.c	Wed Jan  1 22:23:08 2003
+++ 01-wb_base/fs/nfs/proc.c	Thu Jan  2 12:27:56 2003
@@ -564,7 +564,7 @@ nfs_proc_read_setup(struct nfs_read_data
 	req = nfs_list_entry(data->pages.next);
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req);
-	data->args.pgbase = req->wb_offset;
+	data->args.pgbase = req->wb_base;
 	data->args.pages  = data->pagevec;
 	data->args.count  = count;
 	data->res.fattr   = &data->fattr;
@@ -612,7 +612,7 @@ nfs_proc_write_setup(struct nfs_write_da
 	req = nfs_list_entry(data->pages.next);
 	data->args.fh     = NFS_FH(inode);
 	data->args.offset = req_offset(req);
-	data->args.pgbase = req->wb_offset;
+	data->args.pgbase = req->wb_base;
 	data->args.count  = count;
 	data->args.stable = NFS_FILE_SYNC;
 	data->args.pages  = data->pagevec;
diff -Naurp 00-stock/fs/nfs/read.c 01-wb_base/fs/nfs/read.c
--- 00-stock/fs/nfs/read.c	Wed Jan  1 22:20:49 2003
+++ 01-wb_base/fs/nfs/read.c	Thu Jan  2 12:27:56 2003
@@ -267,7 +267,7 @@ nfs_readpage_result(struct rpc_task *tas
 		if (task->tk_status >= 0) {
 			if (count < PAGE_CACHE_SIZE) {
 				memclear_highpage_flush(page,
-							req->wb_offset + count,
+							req->wb_base + count,
 							req->wb_bytes - count);
 
 				if (data->res.eof ||
diff -Naurp 00-stock/fs/nfs/write.c 01-wb_base/fs/nfs/write.c
--- 00-stock/fs/nfs/write.c	Wed Jan  1 22:22:39 2003
+++ 01-wb_base/fs/nfs/write.c	Thu Jan  2 12:27:56 2003
@@ -568,6 +568,7 @@ nfs_update_request(struct file* file, st
 	/* Okay, the request matches. Update the region */
 	if (offset < req->wb_offset) {
 		req->wb_offset = offset;
+		req->wb_base = offset;
 		req->wb_bytes = rqend - req->wb_offset;
 	}
 
@@ -700,7 +701,7 @@ nfs_updatepage(struct file *file, struct
 	 * Call the strategy routine so it can send out a bunch
 	 * of requests.
 	 */
-	if (req->wb_offset == 0 && req->wb_bytes == PAGE_CACHE_SIZE) {
+	if (req->wb_base == 0 && req->wb_bytes == PAGE_CACHE_SIZE) {
 		SetPageUptodate(page);
 		nfs_unlock_request(req);
 		nfs_strategy(inode);
diff -Naurp 00-stock/include/linux/nfs_page.h 01-wb_base/include/linux/nfs_page.h
--- 00-stock/include/linux/nfs_page.h	Wed Jan  1 22:21:07 2003
+++ 01-wb_base/include/linux/nfs_page.h	Thu Jan  2 12:27:56 2003
@@ -31,7 +31,8 @@ struct nfs_page {
 	struct page		*wb_page;	/* page to read in/write out */
 	wait_queue_head_t	wb_wait;	/* wait queue */
 	unsigned long		wb_index;	/* Offset within mapping */
-	unsigned int		wb_offset,	/* Offset within page */
+	unsigned int		wb_offset,	/* Offset within file page */
+				wb_base,	/* offset within buffer page */
 				wb_bytes,	/* Length of request */
 				wb_count;	/* reference count */
 	unsigned long		wb_flags;



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
