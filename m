From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: corruption over NFS with 2.6 client, locking, truncating and
 appending...
Date: Mon, 04 Apr 2005 22:13:36 -0400
Message-ID: <1112667216.11740.4.camel@lade.trondhjem.org>
References: <16977.57630.766727.608029@cse.unsw.edu.au>
	 <1112664792.11910.12.camel@lade.trondhjem.org>
	 <16977.60501.153237.389021@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-FmFn4pPrVZ49icBtvVsp"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DIdZh-0005lr-JO
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 19:13:53 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DIdZg-0000eS-KB
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 19:13:53 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16977.60501.153237.389021@cse.unsw.edu.au>
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


--=-FmFn4pPrVZ49icBtvVsp
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

ty den 05.04.2005 Klokka 11:39 (+1000) skreiv Neil Brown:

> Your explanation would explain that value of 'off' being wrong as I
> found with the lockf locking in 2.4. 
> However as the file was open for O_APPEND, there would be an implicit
> seek to the end on every write.  Is this implicit seek expected to do
> the right thing or would it need fixing too?

The writes should indeed end up being correctly positioned w.r.t. the
end of the file (but may write the wrong offset - which is what you
claimed to see). The problem will be the case of the ftruncate()s which
will end up using stale offsets obtained from the call to lseek(). You
may therefore end up extending the file instead of truncating it.

Could you please test out the following patch? It should apply to 2.4.x
too if you substitute generic_file_llseek() for the references to
remote_llseek().

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-FmFn4pPrVZ49icBtvVsp
Content-Disposition: inline; filename=linux-2.6.12-37-file_add_lseek.dif
Content-Type: text/plain; name=linux-2.6.12-37-file_add_lseek.dif; charset=UTF-8
Content-Transfer-Encoding: 7bit

NFS: Ensure that we revalidate the cached file length for llseek(SEEK_END)

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/file.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletion(-)

Index: linux-2.6.12-rc2/fs/nfs/file.c
===================================================================
--- linux-2.6.12-rc2.orig/fs/nfs/file.c
+++ linux-2.6.12-rc2/fs/nfs/file.c
@@ -37,6 +37,7 @@
 
 static int nfs_file_open(struct inode *, struct file *);
 static int nfs_file_release(struct inode *, struct file *);
+static loff_t nfs_file_llseek(struct file *file, loff_t offset, int origin);
 static int  nfs_file_mmap(struct file *, struct vm_area_struct *);
 static ssize_t nfs_file_sendfile(struct file *, loff_t *, size_t, read_actor_t, void *);
 static ssize_t nfs_file_read(struct kiocb *, char __user *, size_t, loff_t);
@@ -48,7 +49,7 @@ static int nfs_lock(struct file *filp, i
 static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl);
 
 struct file_operations nfs_file_operations = {
-	.llseek		= remote_llseek,
+	.llseek		= nfs_file_llseek,
 	.read		= do_sync_read,
 	.write		= do_sync_write,
 	.aio_read		= nfs_file_read,
@@ -126,6 +127,18 @@ nfs_file_release(struct inode *inode, st
 	return NFS_PROTO(inode)->file_release(inode, filp);
 }
 
+static loff_t
+nfs_file_llseek(struct file *file, loff_t offset, int origin)
+{
+	/* origin == SEEK_END => we must revalidate the cached file length */
+	if (origin == 2) {
+		int retval = nfs_revalidate_inode(file->f_dentry->d_inode);
+		if (retval < 0)
+			return (loff_t)retval;
+	}
+	return remote_llseek(file, offset, origin);
+}
+
 /*
  * Flush all dirty pages, and check for write errors.
  *

--=-FmFn4pPrVZ49icBtvVsp--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
