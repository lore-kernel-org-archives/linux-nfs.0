From: David Jeffery <david_jeffery@adaptec.com>
Subject: RE: nfs client process/rpciod deadlock
Date: 26 Sep 2003 13:02:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1064595745.624.248.camel@blackmagic>
References: <482A3FA0050D21419C269D13989C6113D06D2D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-zDAuHYI1ioEwtQrLR6BQ"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A3BgC-0007xh-00
	for <nfs@lists.sourceforge.net>; Sat, 27 Sep 2003 02:47:56 -0700
Received: from magic-mail.adaptec.com ([216.52.22.10] helo=magic.adaptec.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A3BgB-0003w5-4A
	for nfs@lists.sourceforge.net; Sat, 27 Sep 2003 02:47:55 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113D06D2D@lavender-fe.eng.netapp.com>
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


--=-zDAuHYI1ioEwtQrLR6BQ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2003-09-25 at 12:24, Lever, Charles wrote:
> these processes are not deadlocked; they are merely waiting
> for I/O to complete.  there may be a deadlock elsewhere, or
> they may be waiting for a reply that never arrived.
> 
> what are your NFS mount options?  output from "nfsstat"?
> as an experiment, if you use the "soft" mount option, does
> the problem go away?
> 

I should have included more information.  *sigh*.  Never hurry bug
reports.

The mount options are:"defaults,wsize=8192,rsize=8192,intr". The hung
processes may "go away" with soft mount, but only because little
would get done with all the IO errors.  I periodically get these
messages in the logs:

nfs: server rtp-buildnfs not responding, still trying
nfs: server rtp-buildnfs OK

The network tends to get hit hard at night while these jobs are running
so latency spikes and some dropped packets happen.  The still trying and
the OK messages always match up.

I left out what I now thing are some important parts of the sysrq-T
output.  While rpciod and a few others are getting stuck in D state,
many others keep waiting in S state in nfs_wait_on_request().  This
includes kupdated.

kupdated      S F33D5EC0  4088     6  1             7     5 (L-TLB)
Call Trace:
[nfs_wait_on_request+156/320]
[nfs_wait_on_requests+92/160]
[nfs_sync_file+72/144]
[nfs_writepage+53/208]
[filemap_fdatasync+117/176]
[nfs_writepage+0/208]
[sync_unlocked_inodes+147/384]
[schedule_timeout+132/160]
[process_timeout+0/80]
[sync_old_buffers+8/64]
[kupdate+228/256]

The others are getting to nfs_sync_file() by calling nfs_flush_file()
when trying to close a file.

I have a theory (and a patch!) as to what is going on.  But, I'm not
expert on the linux NFS or VFS code so feel free to try and tear my
theory apart.

My theory is that there is a nasty race with nfs_writepage_async(),
nfs_sync_file(), and a inode no longer referenced by the dcache.  The
first write for a page comes through and follows the writepage_async
path.  The inode refcount gets bumped up 1.  The page gets re-dirtied
and then all other inode refcounts other than the nfs_writepage_async go
away.  The system then tries to write the redirtied page.  This second
write locks the page and then waits for the previous write request in
nfs_sync_file()  -> nfs_wait_on_request(). The first write then
completes and calls iput() in nfs_inode_remove_request() which drops the
refcount on the inode to 0.  iput() then finds its way to
truncate_inode_pages() where it waits on the locked page from the second
write.  But nfs_sync_file() will never return and drop the lock as
nfs_inode_remove_request() called iput() before the nfs request (which
nfs_sync_file() is waiting on) was unlocked.  So the first write needs
the page unlocked to complete the iput() call, but the second write
can't unlock the page until the first request unlocks its nfs request.

My patch moves the iput() to after the request is unlocked in
nfs_writeback_done() or nfs_commit_done().  It hasn't been properly
tested yet so we'll see how it goes.

 Now, a normalsys_write() would have a filp which would hold the dentry
and inode counts from dropping to 0 during the nfs_sync_file().  But a
mmapped write can be delayed until after the references to the inode do
to filp and dentry references are dropped, correct?  I've never seen it
with some tests I ran, but they never used mmapped writes and I believe
the nightly workload does use mmapped writes in places.

This has become a rather long email and I hope my theory made some
sense.  If not, its still been an educational experience trying to learn
the NFS/VFS code in a couple of days.

David Jeffery


--=-zDAuHYI1ioEwtQrLR6BQ
Content-Disposition: attachment; filename=nfsfix.patch
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; name=nfsfix.patch; charset=ANSI_X3.4-1968

--- linux-2.4.22/fs/nfs/write.c.orig	Thu Sep 25 07:33:34 2003
+++ linux-2.4.22/fs/nfs/write.c	Fri Sep 26 07:09:32 2003
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

--=-zDAuHYI1ioEwtQrLR6BQ--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
