From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Support for cached lookups via readdirplus [1/6]
Date: Sun, 28 Jul 2002 17:25:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40086.9790734307$1027870059@news.gmane.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17YpvA-0005K0-00
	for <nfs@lists.sourceforge.net>; Sun, 28 Jul 2002 08:25:25 -0700
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



Cleanup for the readdirplus code. Make struct nfs_entry take pointers
to the filehandle and file attributes.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.29-noac/fs/nfs/dir.c linux-2.5.29-rdplus1/fs/nfs/dir.c
--- linux-2.5.29-noac/fs/nfs/dir.c	Fri Jul 26 23:15:42 2002
+++ linux-2.5.29-rdplus1/fs/nfs/dir.c	Sat Jul 27 18:10:53 2002
@@ -333,7 +333,8 @@
 	/* Reset read descriptor so it searches the page cache from
 	 * the start upon the next call to readdir_search_pagecache() */
 	desc->page_index = 0;
-	memset(desc->entry, 0, sizeof(*desc->entry));
+	desc->entry->cookie = desc->entry->prev_cookie = 0;
+	desc->entry->eof = 0;
  out:
 	dfprintk(VFS, "NFS: uncached_readdir() returns %d\n", status);
 	return status;
@@ -352,6 +353,8 @@
 	nfs_readdir_descriptor_t my_desc,
 			*desc = &my_desc;
 	struct nfs_entry my_entry;
+	struct nfs_fh	 fh;
+	struct nfs_fattr fattr;
 	long		res;
 
 	lock_kernel();
@@ -369,13 +372,17 @@
 	 * itself.
 	 */
 	memset(desc, 0, sizeof(*desc));
-	memset(&my_entry, 0, sizeof(my_entry));
 
 	desc->file = filp;
 	desc->target = filp->f_pos;
-	desc->entry = &my_entry;
 	desc->decode = NFS_PROTO(inode)->decode_dirent;
 
+	my_entry.cookie = my_entry.prev_cookie = 0;
+	my_entry.eof = 0;
+	my_entry.fh = &fh;
+	my_entry.fattr = &fattr;
+	desc->entry = &my_entry;
+
 	while(!desc->entry->eof) {
 		res = readdir_search_pagecache(desc);
 		if (res == -EBADCOOKIE) {
diff -u --recursive --new-file linux-2.5.29-noac/fs/nfs/nfs3xdr.c linux-2.5.29-rdplus1/fs/nfs/nfs3xdr.c
--- linux-2.5.29-noac/fs/nfs/nfs3xdr.c	Tue Jul 16 13:43:08 2002
+++ linux-2.5.29-rdplus1/fs/nfs/nfs3xdr.c	Sat Jul 27 17:56:10 2002
@@ -603,21 +603,19 @@
 	p = xdr_decode_hyper(p, &entry->cookie);
 
 	if (plus) {
-		p = xdr_decode_post_op_attr(p, &entry->fattr);
+		entry->fattr->valid = 0;
+		p = xdr_decode_post_op_attr(p, entry->fattr);
 		/* In fact, a post_op_fh3: */
 		if (*p++) {
-			p = xdr_decode_fhandle(p, &entry->fh);
+			p = xdr_decode_fhandle(p, entry->fh);
 			/* Ugh -- server reply was truncated */
 			if (p == NULL) {
 				dprintk("NFS: FH truncated\n");
 				*entry = old;
 				return ERR_PTR(-EAGAIN);
 			}
-		} else {
-			/* If we don't get a file handle, the attrs
-			 * aren't worth a lot. */
-			entry->fattr.valid = 0;
-		}
+		} else
+			memset((u8*)(entry->fh), 0, sizeof(*entry->fh));
 	}
 
 	entry->eof = !p[0] && p[1];
diff -u --recursive --new-file linux-2.5.29-noac/include/linux/nfs_xdr.h linux-2.5.29-rdplus1/include/linux/nfs_xdr.h
--- linux-2.5.29-noac/include/linux/nfs_xdr.h	Fri Jul 26 16:35:23 2002
+++ linux-2.5.29-rdplus1/include/linux/nfs_xdr.h	Sat Jul 27 17:56:10 2002
@@ -109,8 +109,8 @@
 	const char *		name;
 	unsigned int		len;
 	int			eof;
-	struct nfs_fh		fh;
-	struct nfs_fattr	fattr;
+	struct nfs_fh *		fh;
+	struct nfs_fattr *	fattr;
 };
 
 /*



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
