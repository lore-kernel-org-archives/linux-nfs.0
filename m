From: David Jeffery <david_jeffery@adaptec.com>
Subject: Re: linux 2.4.18-5 nfs/rpc problem
Date: 10 Oct 2003 13:12:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1065805973.874.41.camel@blackmagic>
References: <6FF58CD33A029D458692432F07B85AB713FB9D@newmail>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-LJb8oNovj1HIvgt8eHuT"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A80nM-0006tw-00
	for <nfs@lists.sourceforge.net>; Fri, 10 Oct 2003 10:11:16 -0700
Received: from magic-mail.adaptec.com ([216.52.22.10] helo=magic.adaptec.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A80nJ-000372-WC
	for nfs@lists.sourceforge.net; Fri, 10 Oct 2003 10:11:14 -0700
To: "Guzovsky, Eduard" <Edg@CROSSBEAMSYS.COM>
In-Reply-To: <6FF58CD33A029D458692432F07B85AB713FB9D@newmail>
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


--=-LJb8oNovj1HIvgt8eHuT
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Eduard,

I have also seen this problem with both Red Hat and stock kernels.  I've
got some patches That I'm testing to try and fix the problem for me, but
it takes a while for my setup to reproduce the problem.  How easy is it
for you to trigger?

I've attached two patches for 2.4.22 that I'm currently testing.  The
first (nfsiput.patch) is to fix the deadlocked processes you see by
moving the iput() call to happen after the waited on request is
unlocked.

But that simple fix is incomplete.  It creates another problem that
generates a BUG() in iput() as now instead of deadlocking, nfs can
continue on and end up calling iput() on a cleared inode.  The second
patch (nfsigrab.patch) checks for a failure when calling igrab() and
aborts an async write and instead converts it to a sync write which I
believe should fix the problem.  But, I haven't triggered it yet so this
patch is effectively untested.

If someone who knows nfs/vfs better could sanity check what I'm doing,
it would be appreciated.

David Jeffery

--=-LJb8oNovj1HIvgt8eHuT
Content-Disposition: attachment; filename=nfsiput.patch
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; name=nfsiput.patch; charset=ANSI_X3.4-1968

--- write.c.orig	Thu Sep 25 07:33:34 2003
+++ write.c	Fri Sep 26 07:09:32 2003
@@ -318,14 +318,15 @@
 /*
  * Insert a write request into an inode
  */
-static inline void
+static inline int
 nfs_inode_remove_request(struct nfs_page *req)
 {
 	struct inode *inode;
+	int need_iput =3D 0;
 	spin_lock(&nfs_wreq_lock);
 	if (list_empty(&req->wb_hash)) {
 		spin_unlock(&nfs_wreq_lock);
-		return;
+		return 0;
 	}
 	if (!NFS_WBACK_BUSY(req))
 		printk(KERN_ERR "NFS: unlocked request attempted unhashed!\n");
@@ -335,13 +336,12 @@
 	inode->u.nfs_i.npages--;
 	if ((inode->u.nfs_i.npages =3D=3D 0) !=3D list_empty(&inode->u.nfs_i.writ=
eback))
 		printk(KERN_ERR "NFS: desynchronized value of nfs_i.npages.\n");
-	if (list_empty(&inode->u.nfs_i.writeback)) {
-		spin_unlock(&nfs_wreq_lock);
-		iput(inode);
-	} else
-		spin_unlock(&nfs_wreq_lock);
+	if (list_empty(&inode->u.nfs_i.writeback))
+		need_iput =3D 1;
+	spin_unlock(&nfs_wreq_lock);
 	nfs_clear_request(req);
 	nfs_release_request(req);
+	return need_iput;
 }
=20
 /*
@@ -1049,6 +1049,7 @@
 	 */
 	nfs_write_attributes(inode, resp->fattr);
 	while (!list_empty(&data->pages)) {
+		int need_iput =3D 0;
 		req =3D nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
 		page =3D req->wb_page;
@@ -1064,14 +1065,14 @@
 			SetPageError(page);
 			if (req->wb_file)
 				req->wb_file->f_error =3D task->tk_status;
-			nfs_inode_remove_request(req);
+			need_iput =3D nfs_inode_remove_request(req);
 			dprintk(", error =3D %d\n", task->tk_status);
 			goto next;
 		}
=20
 #ifdef CONFIG_NFS_V3
 		if (argp->stable !=3D NFS_UNSTABLE || resp->verf->committed =3D=3D NFS_F=
ILE_SYNC) {
-			nfs_inode_remove_request(req);
+			need_iput =3D nfs_inode_remove_request(req);
 			dprintk(" OK\n");
 			goto next;
 		}
@@ -1080,10 +1081,12 @@
 		nfs_mark_request_commit(req);
 		dprintk(" marked for commit\n");
 #else
-		nfs_inode_remove_request(req);
+		need_iput =3D nfs_inode_remove_request(req);
 #endif
 	next:
 		nfs_unlock_request(req);
+		if(need_iput)
+			iput(inode);
 	}
 }
=20
@@ -1203,6 +1206,7 @@
=20
 	nfs_write_attributes(inode, resp->fattr);
 	while (!list_empty(&data->pages)) {
+		int need_iput =3D 0;
 		req =3D nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
=20
@@ -1214,7 +1218,7 @@
 		if (task->tk_status < 0) {
 			if (req->wb_file)
 				req->wb_file->f_error =3D task->tk_status;
-			nfs_inode_remove_request(req);
+			need_iput =3D nfs_inode_remove_request(req);
 			dprintk(", error =3D %d\n", task->tk_status);
 			goto next;
 		}
@@ -1223,7 +1227,7 @@
 		 * returned by the server against all stored verfs. */
 		if (!memcmp(req->wb_verf.verifier, data->verf.verifier, sizeof(data->ver=
f.verifier))) {
 			/* We have a match */
-			nfs_inode_remove_request(req);
+			need_iput =3D nfs_inode_remove_request(req);
 			dprintk(" OK\n");
 			goto next;
 		}
@@ -1232,6 +1236,8 @@
 		nfs_mark_request_dirty(req);
 	next:
 		nfs_unlock_request(req);
+		if(need_iput)
+			iput(inode);
 	}
 }
 #endif

--=-LJb8oNovj1HIvgt8eHuT
Content-Disposition: attachment; filename=nfsigrab.patch
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; name=nfsigrab.patch; charset=ANSI_X3.4-1968

--- linux-2.4.22/fs/nfs/write.c.fix4.notfinished	Tue Oct  7 08:15:56 2003
+++ linux-2.4.22/fs/nfs/write.c	Tue Oct  7 09:14:16 2003
@@ -248,6 +248,12 @@
 		err =3D nfs_writepage_async(NULL, inode, page, 0, offset);
 		if (err >=3D 0)
 			err =3D 0;
+		else if(err =3D=3D -EDEADLK){
+			printk(KERN_WARNING "NFS DEBUG: EDEADLK returned, doing nfs_writepage_s=
ync\n");
+			err =3D nfs_writepage_sync(NULL, inode, page, 0, offset);
+			if (err =3D=3D offset)
+				err =3D 0;
+		}
 	} else {
 		err =3D nfs_writepage_sync(NULL, inode, page, 0, offset);=20
 		if (err =3D=3D offset)
@@ -292,19 +298,22 @@
  *	 & co. for the 'write append' case. For 2.5 we may want to consider
  *	 some form of hashing so as to perform well on random writes.
  */
-static inline void
+static inline int
 nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 {
 	struct list_head *pos, *head;
 	unsigned long pg_idx =3D page_index(req->wb_page);
=20
 	if (!list_empty(&req->wb_hash))
-		return;
+		return 0;
 	if (!NFS_WBACK_BUSY(req))
 		printk(KERN_ERR "NFS: unlocked request attempted hashed!\n");
 	head =3D &inode->u.nfs_i.writeback;
 	if (list_empty(head))
-		igrab(inode);
+		if(!igrab(inode)){
+			printk(KERN_WARNING "NFS DEBUG: igrab failed!  Aborting async writepage=
.\n");
+			return -EDEADLK;
+		}
 	list_for_each_prev(pos, head) {
 		struct nfs_page *entry =3D nfs_inode_wb_entry(pos);
 		if (page_index(entry->wb_page) < pg_idx)
@@ -313,6 +322,7 @@
 	inode->u.nfs_i.npages++;
 	list_add(&req->wb_hash, pos);
 	req->wb_count++;
+	return 0;
 }
=20
 /*
@@ -659,9 +669,15 @@
 		}
=20
 		if (new) {
+			int error;
 			nfs_lock_request_dontget(new);
-			nfs_inode_add_request(inode, new);
+			error =3D nfs_inode_add_request(inode, new);
 			spin_unlock(&nfs_wreq_lock);
+			if(error < 0){
+				nfs_unlock_request(new);
+				nfs_release_request(new);
+				return ERR_PTR(error);
+			}
 			nfs_mark_request_dirty(new);
 			return new;
 		}

--=-LJb8oNovj1HIvgt8eHuT--



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
