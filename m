From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 24/25] NFS: copy symlinks into page cache before
	sending NFS SYMLINK request
Date: Wed, 09 Aug 2006 10:59:49 -0400
Message-ID: <20060809145948.3914.15634.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcT-0000ok-5K
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:18 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcT-0005l4-7t
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:17 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Currently the NFS client does not cache symlinks it creates.  They get
cached only when the NFS client reads them back from the server.

Copy the symlink into the page cache before sending it.

Test plan:
Connectathon, all NFS versions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c |   86 ++++++++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 68 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ff4e852..815ec2b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -30,6 +30,7 @@ #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
+#include <linux/pagevec.h>
 #include <linux/namei.h>
 
 #include "nfs4_fs.h"
@@ -1437,39 +1438,88 @@ static int nfs_unlink(struct inode *dir,
 	return error;
 }
 
-static int
-nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
+/*
+ * To create a symbolic link, most file systems instantiate a new inode,
+ * add a page to it containing the path, then write it out to the disk
+ * using prepare_write/commit_write.
+ *
+ * Unfortunately the NFS client can't create the in-core inode first
+ * because it needs a file handle to create an in-core inode (see
+ * fs/nfs/inode.c:nfs_fhget).  We only have a file handle *after* the
+ * symlink request has completed on the server.
+ *
+ * So instead we allocate a raw page, copy the symname into it, then do
+ * the SYMLINK request with the page as the buffer.  If it succeeds, we
+ * now have a new file handle and can instantiate an in-core NFS inode
+ * and move the raw page into its mapping.
+ */
+static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 {
+	struct pagevec lru_pvec;
+	struct page *page;
+	char *kaddr;
 	struct iattr attr;
-	struct qstr qsymname;
+	unsigned int pathlen = strlen(symname);
+	struct qstr qsymname = {
+		.name	= symname,
+		.len	= pathlen,
+	};
 	int error;
 
 	dfprintk(VFS, "NFS: symlink(%s/%ld, %s, %s)\n", dir->i_sb->s_id,
 		dir->i_ino, dentry->d_name.name, symname);
 
-#ifdef NFS_PARANOIA
-if (dentry->d_inode)
-printk("nfs_proc_symlink: %s/%s not negative!\n",
-dentry->d_parent->d_name.name, dentry->d_name.name);
-#endif
-	/*
-	 * Fill in the sattr for the call.
- 	 * Note: SunOS 4.1.2 crashes if the mode isn't initialized!
-	 */
-	attr.ia_valid = ATTR_MODE;
-	attr.ia_mode = S_IFLNK | S_IRWXUGO;
+	if (pathlen > PAGE_SIZE)
+		return -ENAMETOOLONG;
 
-	qsymname.name = symname;
-	qsymname.len  = strlen(symname);
+	attr.ia_mode = S_IFLNK | S_IRWXUGO;
+	attr.ia_valid = ATTR_MODE;
 
 	lock_kernel();
+
+	page = alloc_page(GFP_KERNEL);
+	if (!page) {
+		unlock_kernel();
+		return -ENOMEM;
+	}
+
+	kaddr = kmap_atomic(page, KM_USER0);
+	memcpy(kaddr, symname, pathlen);
+	if (pathlen < PAGE_SIZE)
+		memset(kaddr + pathlen, 0, PAGE_SIZE - pathlen);
+	kunmap_atomic(kaddr, KM_USER0);
+
+	/* XXX: eventually this will pass in {page, pathlen},
+	 *	instead of qsymname; need XDR changes for that */
 	nfs_begin_data_update(dir);
 	error = NFS_PROTO(dir)->symlink(dir, dentry, &qsymname, &attr);
 	nfs_end_data_update(dir);
-	if (!error)
+	if (error != 0) {
+		dfprintk(VFS, "NFS: symlink(%s/%ld, %s, %s) error %d\n",
+			dir->i_sb->s_id, dir->i_ino,
+			dentry->d_name.name, symname, error);
 		d_drop(dentry);
+		__free_page(page);
+		unlock_kernel();
+		return error;
+	}
+
+	/*
+	 * No big deal if we can't add this page to the page cache here.
+	 * READLINK will get the missing page from the server if needed.
+	 */
+	pagevec_init(&lru_pvec, 0);
+	if (!add_to_page_cache(page, dentry->d_inode->i_mapping, 0,
+							GFP_KERNEL)) {
+		if (!pagevec_add(&lru_pvec, page))
+			__pagevec_lru_add(&lru_pvec);
+		SetPageUptodate(page);
+		unlock_page(page);
+	} else
+		__free_page(page);
+
 	unlock_kernel();
-	return error;
+	return 0;
 }
 
 static int 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
