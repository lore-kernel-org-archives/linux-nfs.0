From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Support for cached lookups via readdirplus [6/6]
Date: Sun, 28 Jul 2002 17:26:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15684.3384.221358.537571@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Ypwk-0005RI-00
	for <nfs@lists.sourceforge.net>; Sun, 28 Jul 2002 08:27:02 -0700
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


Add support for the glibc 'd_type' field in cases where we have the
READDIRPLUS file attribute information available to us in
nfs_do_filldir().

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.29-rdplus5/fs/nfs/dir.c linux-2.5.29-rdplus6/fs/nfs/dir.c
--- linux-2.5.29-rdplus5/fs/nfs/dir.c	Sat Jul 27 19:15:41 2002
+++ linux-2.5.29-rdplus6/fs/nfs/dir.c	Sat Jul 27 19:15:33 2002
@@ -249,6 +249,24 @@
 	return res;
 }
 
+static unsigned int nfs_type2dtype[] = {
+	DT_UNKNOWN,
+	DT_REG,
+	DT_DIR,
+	DT_BLK,
+	DT_CHR,
+	DT_LNK,
+	DT_SOCK,
+	DT_UNKNOWN,
+	DT_FIFO
+};
+
+static inline
+unsigned int nfs_type_to_d_type(enum nfs_ftype type)
+{
+	return nfs_type2dtype[type];
+}
+
 /*
  * Once we've found the start of the dirent within a page: fill 'er up...
  */
@@ -265,11 +283,17 @@
 	dfprintk(VFS, "NFS: nfs_do_filldir() filling starting @ cookie %Lu\n", (long long)desc->target);
 
 	for(;;) {
+		unsigned d_type = DT_UNKNOWN;
 		/* Note: entry->prev_cookie contains the cookie for
 		 *	 retrieving the current dirent on the server */
 		fileid = nfs_fileid_to_ino_t(entry->ino);
+
+		/* Use readdirplus info */
+		if (desc->plus && (entry->fattr->valid & NFS_ATTR_FATTR))
+			d_type = nfs_type_to_d_type(entry->fattr->type);
+
 		res = filldir(dirent, entry->name, entry->len, 
-			      entry->prev_cookie, fileid, DT_UNKNOWN);
+			      entry->prev_cookie, fileid, d_type);
 		if (res < 0)
 			break;
 		file->f_pos = desc->target = entry->cookie;


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
