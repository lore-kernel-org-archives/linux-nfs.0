From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] simplify req_offset function in NFS client
Date: Mon, 18 Nov 2002 16:52:35 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0211181650420.1518-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dexter.citi.umich.edu ([141.211.133.33] ident=[zgQLi1TNbxIYNTrYOwujlgoDKzVzFF4B])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Dtp0-0002vF-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 13:52:47 -0800
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

everywhere the NFS client uses the req_offset() function today, it adds
req->wb_offset to the result.  so this patch simply makes " +
req->wb_offset" a part of the req_offset() function.

against 2.5.48.


diff -ruN 01-kmap_atomic/fs/nfs/nfs3proc.c 02-req_offset/fs/nfs/nfs3proc.c
--- 01-kmap_atomic/fs/nfs/nfs3proc.c	Sun Nov 17 23:29:45 2002
+++ 02-req_offset/fs/nfs/nfs3proc.c	Mon Nov 18 11:46:05 2002
@@ -708,7 +708,7 @@
 	
 	req = nfs_list_entry(data->pages.next);
 	data->u.v3.args.fh     = NFS_FH(inode);
-	data->u.v3.args.offset = req_offset(req) + req->wb_offset;
+	data->u.v3.args.offset = req_offset(req);
 	data->u.v3.args.pgbase = req->wb_offset;
 	data->u.v3.args.pages  = data->pagevec;
 	data->u.v3.args.count  = count;
@@ -764,7 +764,7 @@
 	
 	req = nfs_list_entry(data->pages.next);
 	data->u.v3.args.fh     = NFS_FH(inode);
-	data->u.v3.args.offset = req_offset(req) + req->wb_offset;
+	data->u.v3.args.offset = req_offset(req);
 	data->u.v3.args.pgbase = req->wb_offset;
 	data->u.v3.args.count  = count;
 	data->u.v3.args.stable = stable;
diff -ruN 01-kmap_atomic/fs/nfs/nfs4proc.c 02-req_offset/fs/nfs/nfs4proc.c
--- 01-kmap_atomic/fs/nfs/nfs4proc.c	Mon Nov 18 11:43:24 2002
+++ 02-req_offset/fs/nfs/nfs4proc.c	Mon Nov 18 11:46:05 2002
@@ -1379,7 +1379,7 @@
 
 	nfs4_setup_compound(cp, data->u.v4.ops, NFS_SERVER(inode), "read [async]");
 	nfs4_setup_putfh(cp, NFS_FH(inode));
-	nfs4_setup_read(cp, req_offset(req) + req->wb_offset,
+	nfs4_setup_read(cp, req_offset(req),
 			count, data->pagevec, req->wb_offset,
 			&data->u.v4.res_eof,
 			&data->u.v4.res_count);
@@ -1432,7 +1432,7 @@
 
 	nfs4_setup_compound(cp, data->u.v4.ops, NFS_SERVER(inode), "write [async]");
 	nfs4_setup_putfh(cp, NFS_FH(inode));
-	nfs4_setup_write(cp, req_offset(req) + req->wb_offset,
+	nfs4_setup_write(cp, req_offset(req),
 			 count, stable, data->pagevec, req->wb_offset,
 			 &data->u.v4.res_count, &data->verf);
 
diff -ruN 01-kmap_atomic/fs/nfs/proc.c 02-req_offset/fs/nfs/proc.c
--- 01-kmap_atomic/fs/nfs/proc.c	Sun Nov 17 23:29:56 2002
+++ 02-req_offset/fs/nfs/proc.c	Mon Nov 18 11:46:05 2002
@@ -543,7 +543,7 @@
 	
 	req = nfs_list_entry(data->pages.next);
 	data->u.v3.args.fh     = NFS_FH(inode);
-	data->u.v3.args.offset = req_offset(req) + req->wb_offset;
+	data->u.v3.args.offset = req_offset(req);
 	data->u.v3.args.pgbase = req->wb_offset;
 	data->u.v3.args.pages  = data->pagevec;
 	data->u.v3.args.count  = count;
@@ -589,7 +589,7 @@
 	
 	req = nfs_list_entry(data->pages.next);
 	data->u.v3.args.fh     = NFS_FH(inode);
-	data->u.v3.args.offset = req_offset(req) + req->wb_offset;
+	data->u.v3.args.offset = req_offset(req);
 	data->u.v3.args.pgbase = req->wb_offset;
 	data->u.v3.args.count  = count;
 	data->u.v3.args.stable = NFS_FILE_SYNC;
diff -ruN 01-kmap_atomic/fs/nfs/read.c 02-req_offset/fs/nfs/read.c
--- 01-kmap_atomic/fs/nfs/read.c	Mon Nov 18 11:43:25 2002
+++ 02-req_offset/fs/nfs/read.c	Mon Nov 18 11:46:05 2002
@@ -178,7 +178,7 @@
 			inode->i_sb->s_id,
 			(long long)NFS_FILEID(inode),
 			count,
-			(unsigned long long)req_offset(req) + req->wb_offset);
+			(unsigned long long)req_offset(req));
 }
 
 static void
@@ -274,7 +274,7 @@
 
 				if (eof ||
 				    ((fattr->valid & NFS_ATTR_FATTR) &&
-				     ((req_offset(req) + req->wb_offset + count) >= fattr->size)))
+				     ((req_offset(req) + count) >= fattr->size)))
 					SetPageUptodate(page);
 				else
 					if (count < req->wb_bytes)
@@ -292,7 +292,7 @@
                         req->wb_inode->i_sb->s_id,
                         (long long)NFS_FILEID(req->wb_inode),
                         req->wb_bytes,
-                        (long long)(req_offset(req) + req->wb_offset));
+                        (long long)req_offset(req));
 		nfs_clear_request(req);
 		nfs_release_request(req);
 		nfs_unlock_request(req);
diff -ruN 01-kmap_atomic/fs/nfs/write.c 02-req_offset/fs/nfs/write.c
--- 01-kmap_atomic/fs/nfs/write.c	Sun Nov 17 23:29:51 2002
+++ 02-req_offset/fs/nfs/write.c	Mon Nov 18 11:46:05 2002
@@ -768,7 +768,7 @@
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),
 		count,
-		(unsigned long long)req_offset(req) + req->wb_offset);
+		(unsigned long long)req_offset(req));
 }
 
 /*
@@ -902,7 +902,7 @@
 			req->wb_inode->i_sb->s_id,
 			(long long)NFS_FILEID(req->wb_inode),
 			req->wb_bytes,
-			(long long)(req_offset(req) + req->wb_offset));
+			(long long)req_offset(req));
 
 		if (task->tk_status < 0) {
 			ClearPageUptodate(page);
@@ -958,8 +958,8 @@
 	 * Determine the offset range of requests in the COMMIT call.
 	 * We rely on the fact that data->pages is an ordered list...
 	 */
-	start = req_offset(first) + first->wb_offset;
-	end = req_offset(last) + (last->wb_offset + last->wb_bytes);
+	start = req_offset(first);
+	end = req_offset(last) + last->wb_bytes;
 	len = end - start;
 	/* If 'len' is not a 32-bit quantity, pass '0' in the COMMIT call */
 	if (end >= inode->i_size || len < 0 || len > (~((u32)0) >> 1))
@@ -1031,7 +1031,7 @@
 			req->wb_inode->i_sb->s_id,
 			(long long)NFS_FILEID(req->wb_inode),
 			req->wb_bytes,
-			(long long)(req_offset(req) + req->wb_offset));
+			(long long)req_offset(req));
 		if (task->tk_status < 0) {
 			if (req->wb_file)
 				req->wb_file->f_error = task->tk_status;
diff -ruN 01-kmap_atomic/include/linux/nfs_fs.h 02-req_offset/include/linux/nfs_fs.h
--- 01-kmap_atomic/include/linux/nfs_fs.h	Sun Nov 17 23:29:31 2002
+++ 02-req_offset/include/linux/nfs_fs.h	Mon Nov 18 11:46:05 2002
@@ -222,7 +222,7 @@
 static inline
 loff_t req_offset(struct nfs_page *req)
 {
-	return ((loff_t)req->wb_index) << PAGE_CACHE_SHIFT;
+	return (((loff_t)req->wb_index) << PAGE_CACHE_SHIFT) + req->wb_offset;
 }
 
 /*



-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
