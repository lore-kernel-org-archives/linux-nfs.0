From: Olivier Galibert <galibert@pobox.com>
Subject: Re: Make NFS userspace and server directories cookies independant [patch, fc3, 2.6.10-1.766_FC3]
Date: Tue, 22 Mar 2005 01:02:10 +0100
Message-ID: <20050322000210.GA4681@dspnet.fr.eu.org>
References: <20050321162142.GB46055@dspnet.fr.eu.org> <1111427218.10508.27.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "Hack inc." <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDWqh-00067c-6p
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 16:02:19 -0800
Received: from [213.186.44.138] (helo=dspnet.fr.eu.org ident=postfix)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDWqf-0006zp-5N
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 16:02:19 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1111427218.10508.27.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, Mar 21, 2005 at 12:46:58PM -0500, Trond Myklebust wrote:
> m=E5 den 21.03.2005 Klokka 17:21 (+0100) skreiv Olivier Galibert:
>=20
> > Patch is against a fedora core 3 2.6.10, it requires minor
> > modifications (context change, not contents) in the nfs_do_filldir pa=
r
> > of the dir.c change to account for the dirent addition to apply to
> > 2.6.11.  I can update it if useful.
> >=20
>=20
> If you could please update it for 2.6.12-rc1, then I'll be able to queu=
e
> it up for testing and possible inclusion in 2.6.13.

Here we go.  Forgot to add I removed a useless parameter "page" from
find_direct.  It's in desc->page in any case.

  OG.

Signed-off-by: Olivier Galibert <galibert@pobox.com>

 fs/nfs/dir.c           |  114 ++++++++++++++++++++++++++++++++++++++----=
-------
 fs/nfs/inode.c         |    2=20
 include/linux/nfs_fs.h |    3 +
 3 files changed, 95 insertions(+), 24 deletions(-)

--- linux-2.6.12-rc1-orig/fs/nfs/dir.c	2005-03-22 00:12:17.000000000 +010=
0
+++ linux-2.6.12-rc1/fs/nfs/dir.c	2005-03-22 00:44:23.000000000 +0100
@@ -116,7 +116,9 @@ typedef struct {
 	struct page	*page;
 	unsigned long	page_index;
 	u32		*ptr;
-	u64		target;
+	u64		target_cookie;
+	int		target_index;
+	int		current_index;
 	struct nfs_entry *entry;
 	decode_dirent_t	decode;
 	int		plus;
@@ -202,14 +204,14 @@ void dir_page_release(nfs_readdir_descri
=20
 /*
  * Given a pointer to a buffer that has already been filled by a call
- * to readdir, find the next entry.
+ * to readdir, find the next entry with cookie 'desc->target_cookie'.
  *
  * If the end of the buffer has been reached, return -EAGAIN, if not,
  * return the offset within the buffer of the next entry to be
  * read.
  */
 static inline
-int find_dirent(nfs_readdir_descriptor_t *desc, struct page *page)
+int find_dirent(nfs_readdir_descriptor_t *desc)
 {
 	struct nfs_entry *entry =3D desc->entry;
 	int		loop_count =3D 0,
@@ -217,7 +219,7 @@ int find_dirent(nfs_readdir_descriptor_t
=20
 	while((status =3D dir_decode(desc)) =3D=3D 0) {
 		dfprintk(VFS, "NFS: found cookie %Lu\n", (long long)entry->cookie);
-		if (entry->prev_cookie =3D=3D desc->target)
+		if (entry->prev_cookie =3D=3D desc->target_cookie)
 			break;
 		if (loop_count++ > 200) {
 			loop_count =3D 0;
@@ -229,8 +231,44 @@ int find_dirent(nfs_readdir_descriptor_t
 }
=20
 /*
- * Find the given page, and call find_dirent() in order to try to
- * return the next entry.
+ * Given a pointer to a buffer that has already been filled by a call
+ * to readdir, find the entry at offset 'desc->target_index'.
+ *
+ * If the end of the buffer has been reached, return -EAGAIN, if not,
+ * return the offset within the buffer of the next entry to be
+ * read.
+ */
+static inline
+int find_dirent_index(nfs_readdir_descriptor_t *desc)
+{
+	struct nfs_entry *entry =3D desc->entry;
+	int		loop_count =3D 0,
+			status;
+
+	for(;;) {
+		status =3D dir_decode(desc);
+		if (status)
+			break;
+
+		dfprintk(VFS, "NFS: found cookie %Lu at index %d\n", (long long)entry-=
>cookie, desc->current_index);
+
+		if (desc->target_index =3D=3D desc->current_index) {
+			desc->target_cookie =3D entry->cookie;
+			break;
+		}
+		desc->current_index++;
+		if (loop_count++ > 200) {
+			loop_count =3D 0;
+			schedule();
+		}
+	}
+	dfprintk(VFS, "NFS: find_dirent_index() returns %d\n", status);
+	return status;
+}
+
+/*
+ * Find the given page, and call find_dirent() or find_dirent_index in
+ * order to try to return the next entry.
  */
 static inline
 int find_dirent_page(nfs_readdir_descriptor_t *desc)
@@ -253,7 +291,10 @@ int find_dirent_page(nfs_readdir_descrip
 	/* NOTE: Someone else may have changed the READDIRPLUS flag */
 	desc->page =3D page;
 	desc->ptr =3D kmap(page);		/* matching kunmap in nfs_do_filldir */
-	status =3D find_dirent(desc, page);
+	if (desc->target_cookie)
+		status =3D find_dirent(desc);
+	else
+		status =3D find_dirent_index(desc);
 	if (status < 0)
 		dir_page_release(desc);
  out:
@@ -268,7 +309,8 @@ int find_dirent_page(nfs_readdir_descrip
  * Recurse through the page cache pages, and return a
  * filled nfs_entry structure of the next directory entry if possible.
  *
- * The target for the search is 'desc->target'.
+ * The target for the search is 'desc->target_cookie' if non-0,
+ * 'desc->target_index' otherwise
  */
 static inline
 int readdir_search_pagecache(nfs_readdir_descriptor_t *desc)
@@ -276,7 +318,19 @@ int readdir_search_pagecache(nfs_readdir
 	int		loop_count =3D 0;
 	int		res;
=20
-	dfprintk(VFS, "NFS: readdir_search_pagecache() searching for cookie %Lu=
\n", (long long)desc->target);
+	if (desc->target_cookie)
+		dfprintk(VFS, "NFS: readdir_search_pagecache() searching for cookie %L=
u\n", (long long)desc->target_cookie);
+	else
+		dfprintk(VFS, "NFS: readdir_search_pagecache() searching for cookie nu=
mber %d\n", desc->target_index);
+
+	/* Always search-by-index from the beginning of the cache */
+	if (!(desc->target_cookie)) {
+		desc->page_index =3D 0;
+		desc->entry->cookie =3D desc->entry->prev_cookie =3D 0;
+		desc->entry->eof =3D 0;
+		desc->current_index =3D 0;
+	}
+
 	for (;;) {
 		res =3D find_dirent_page(desc);
 		if (res !=3D -EAGAIN)
@@ -309,11 +363,12 @@ int nfs_do_filldir(nfs_readdir_descripto
 	struct file	*file =3D desc->file;
 	struct nfs_entry *entry =3D desc->entry;
 	struct dentry	*dentry =3D NULL;
+	struct nfs_open_context *ctx =3D file->private_data;
 	unsigned long	fileid;
 	int		loop_count =3D 0,
 			res;
=20
-	dfprintk(VFS, "NFS: nfs_do_filldir() filling starting @ cookie %Lu\n", =
(long long)desc->target);
+	dfprintk(VFS, "NFS: nfs_do_filldir() filling starting @ cookie %Lu\n", =
(long long)entry->cookie);
=20
 	for(;;) {
 		unsigned d_type =3D DT_UNKNOWN;
@@ -333,10 +388,10 @@ int nfs_do_filldir(nfs_readdir_descripto
 		}
=20
 		res =3D filldir(dirent, entry->name, entry->len,=20
-			      entry->prev_cookie, fileid, d_type);
+			      file->f_pos, fileid, d_type);
 		if (res < 0)
 			break;
-		file->f_pos =3D desc->target =3D entry->cookie;
+		file->f_pos++;
 		if (dir_decode(desc) !=3D 0) {
 			desc->page_index ++;
 			break;
@@ -346,10 +401,13 @@ int nfs_do_filldir(nfs_readdir_descripto
 			schedule();
 		}
 	}
+	ctx->dir_pos        =3D file->f_pos;
+	ctx->dir_cookie     =3D entry->cookie;
+	desc->target_cookie =3D entry->cookie;
 	dir_page_release(desc);
 	if (dentry !=3D NULL)
 		dput(dentry);
-	dfprintk(VFS, "NFS: nfs_do_filldir() filling ended @ cookie %Lu; return=
ing =3D %d\n", (long long)desc->target, res);
+	dfprintk(VFS, "NFS: nfs_do_filldir() filling ended @ cookie %Lu; return=
ing =3D %d\n", (long long)ctx->dir_cookie, res);
 	return res;
 }
=20
@@ -375,14 +433,14 @@ int uncached_readdir(nfs_readdir_descrip
 	struct page	*page =3D NULL;
 	int		status;
=20
-	dfprintk(VFS, "NFS: uncached_readdir() searching for cookie %Lu\n", (lo=
ng long)desc->target);
+	dfprintk(VFS, "NFS: uncached_readdir() searching for cookie %Lu\n", (lo=
ng long)desc->target_cookie);
=20
 	page =3D alloc_page(GFP_HIGHUSER);
 	if (!page) {
 		status =3D -ENOMEM;
 		goto out;
 	}
-	desc->error =3D NFS_PROTO(inode)->readdir(file->f_dentry, cred, desc->t=
arget,
+	desc->error =3D NFS_PROTO(inode)->readdir(file->f_dentry, cred, desc->t=
arget_cookie,
 						page,
 						NFS_SERVER(inode)->dtsize,
 						desc->plus);
@@ -391,7 +449,7 @@ int uncached_readdir(nfs_readdir_descrip
 	desc->ptr =3D kmap(page);		/* matching kunmap in nfs_do_filldir */
 	if (desc->error >=3D 0) {
 		if ((status =3D dir_decode(desc)) =3D=3D 0)
-			desc->entry->prev_cookie =3D desc->target;
+			desc->entry->prev_cookie =3D desc->target_cookie;
 	} else
 		status =3D -EIO;
 	if (status < 0)
@@ -412,13 +470,15 @@ int uncached_readdir(nfs_readdir_descrip
 	goto out;
 }
=20
-/* The file offset position is now represented as a true offset into the
- * page cache as is the case in most of the other filesystems.
+/* The file offset position represents the dirent entry number.  A
+   last cookie cache takes care of the common case of reading the
+   whole directory.
  */
 static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldi=
r)
 {
 	struct dentry	*dentry =3D filp->f_dentry;
 	struct inode	*inode =3D dentry->d_inode;
+	struct nfs_open_context *ctx =3D filp->private_data;
 	nfs_readdir_descriptor_t my_desc,
 			*desc =3D &my_desc;
 	struct nfs_entry my_entry;
@@ -435,17 +495,22 @@ static int nfs_readdir(struct file *filp
 	}
=20
 	/*
-	 * filp->f_pos points to the file offset in the page cache.
-	 * but if the cache has meanwhile been zapped, we need to
-	 * read from the last dirent to revalidate f_pos
-	 * itself.
+	 * filp->f_pos points to the dirent entry number.
+	 * ctx->dir_pos has the number of the cached cookie.  We have
+	 * to either find the entry with the appropriate number or
+	 * revalidate the cookie.
 	 */
 	memset(desc, 0, sizeof(*desc));
=20
 	desc->file =3D filp;
-	desc->target =3D filp->f_pos;
 	desc->decode =3D NFS_PROTO(inode)->decode_dirent;
 	desc->plus =3D NFS_USE_READDIRPLUS(inode);
+	desc->target_index =3D filp->f_pos;
+
+	if (filp->f_pos =3D=3D ctx->dir_pos)
+		desc->target_cookie =3D ctx->dir_cookie;
+	else
+		desc->target_cookie =3D 0;
=20
 	my_entry.cookie =3D my_entry.prev_cookie =3D 0;
 	my_entry.eof =3D 0;
@@ -455,9 +520,10 @@ static int nfs_readdir(struct file *filp
=20
 	while(!desc->entry->eof) {
 		res =3D readdir_search_pagecache(desc);
+
 		if (res =3D=3D -EBADCOOKIE) {
 			/* This means either end of directory */
-			if (desc->entry->cookie !=3D desc->target) {
+			if (desc->target_cookie && desc->entry->cookie !=3D desc->target_cook=
ie) {
 				/* Or that the server has 'lost' a cookie */
 				res =3D uncached_readdir(desc, dirent, filldir);
 				if (res >=3D 0)
--- linux-2.6.12-rc1-orig/fs/nfs/inode.c	2005-03-22 00:12:17.000000000 +0=
100
+++ linux-2.6.12-rc1/fs/nfs/inode.c	2005-03-22 00:42:20.000000000 +0100
@@ -851,6 +851,8 @@ struct nfs_open_context *alloc_nfs_open_
 		ctx->state =3D NULL;
 		ctx->lockowner =3D current->files;
 		ctx->error =3D 0;
+		ctx->dir_pos =3D 0;
+		ctx->dir_cookie =3D 0;
 		init_waitqueue_head(&ctx->waitq);
 	}
 	return ctx;
--- linux-2.6.12-rc1-orig/include/linux/nfs_fs.h	2005-03-22 00:12:17.0000=
00000 +0100
+++ linux-2.6.12-rc1/include/linux/nfs_fs.h	2005-03-22 00:42:20.000000000=
 +0100
@@ -97,6 +97,9 @@ struct nfs_open_context {
=20
 	struct list_head list;
 	wait_queue_head_t waitq;
+
+	int dir_pos;		/* Directory cookie cache */
+	__u64 dir_cookie;
 };
=20
 /*


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
