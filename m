From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: atimes not updated over NFS
Date: Mon, 28 Jan 2008 21:59:40 -0500
Message-ID: <20080129025940.GI16785@fieldses.org>
References: <1199920996.7638.3.camel@heimdal.trondhjem.org> <20080109235153.GI9212@aym.net2.nerim.net> <20080114083435.GA24215@janus> <1200325393.7470.6.camel@heimdal.trondhjem.org> <20080114175122.GB2768@janus> <20080121190638.GL17468@fieldses.org> <1200943865.25562.56.camel@heimdal.trondhjem.org> <20080121210230.GA22046@janus> <20080121210925.GQ17468@fieldses.org> <20080122171717.GD24697@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>, linux-nfs@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56715 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752801AbYA2C7r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 21:59:47 -0500
In-Reply-To: <20080122171717.GD24697@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 22, 2008 at 12:17:17PM -0500, bfields wrote:
> On Mon, Jan 21, 2008 at 04:09:25PM -0500, bfields wrote:
> > On Mon, Jan 21, 2008 at 10:02:30PM +0100, Frank van Maarseveen wrote:
> > > 2.6.22.10:
> > > 	t
> > > 	t + 2
> > > 	t + 2
> > > 
> > > (same behavior)
> > > 
> > > 2.6.23.12:
> > > 	t
> > > 	t
> > > 	t
> > > 
> > > definately not good. "cat" on the server updates atime again.
> > 
> > Yes, that looks like a server bug, and this:...
> > 
> > > 
> > > 
> > > Trying a different combination of kernels:
> > > 
> > > server 2.6.23.12, client 2.6.22.10:
> > > 	t
> > > 	t
> > > 	t
> > > 
> > > server 2.6.22.10, client 2.6.23.12:
> > > 	t
> > > 	t + 2
> > > 	t + 2
> > 
> > ...confirms that since the results appear to depend only on the server
> > version, not on the client version.
> 
> And I can confirm this here on 2.6.24-rc8 (+ a few patches).
> Unfortunately, I don't have any suggestion better right now than
> bisecting....

It looks like this happened in the switch from sendfile to sparse.
Jens, any advice?  What happened was nfsd reads stopped updating the
atime after the following commit.

--b.

commit f0930fffa99e7fe0a0c4b6c7d9a244dc88288c27
Author: Jens Axboe <jens.axboe@oracle.com>
Date:   Fri Jun 1 11:51:43 2007 +0200

    sendfile: convert nfs to using splice_read()
    
    Acked-by: Trond Myklebust <trond.myklebust@fys.uio.no>
    Signed-off-by: Jens Axboe <jens.axboe@oracle.com>

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 9eb8eb4..8689b73 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -41,7 +41,9 @@ static int nfs_file_open(struct inode *, struct file *);
 static int nfs_file_release(struct inode *, struct file *);
 static loff_t nfs_file_llseek(struct file *file, loff_t offset, int origin);
 static int  nfs_file_mmap(struct file *, struct vm_area_struct *);
-static ssize_t nfs_file_sendfile(struct file *, loff_t *, size_t, read_actor_t, void *);
+static ssize_t nfs_file_splice_read(struct file *filp, loff_t *ppos,
+					struct pipe_inode_info *pipe,
+					size_t count, unsigned int flags);
 static ssize_t nfs_file_read(struct kiocb *, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos);
 static ssize_t nfs_file_write(struct kiocb *, const struct iovec *iov,
@@ -65,7 +67,7 @@ const struct file_operations nfs_file_operations = {
 	.fsync		= nfs_fsync,
 	.lock		= nfs_lock,
 	.flock		= nfs_flock,
-	.sendfile	= nfs_file_sendfile,
+	.splice_read	= nfs_file_splice_read,
 	.check_flags	= nfs_check_flags,
 };
 
@@ -224,20 +226,21 @@ nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
 }
 
 static ssize_t
-nfs_file_sendfile(struct file *filp, loff_t *ppos, size_t count,
-		read_actor_t actor, void *target)
+nfs_file_splice_read(struct file *filp, loff_t *ppos,
+		     struct pipe_inode_info *pipe, size_t count,
+		     unsigned int flags)
 {
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
 	ssize_t res;
 
-	dfprintk(VFS, "nfs: sendfile(%s/%s, %lu@%Lu)\n",
+	dfprintk(VFS, "nfs: splice_read(%s/%s, %lu@%Lu)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
 		(unsigned long) count, (unsigned long long) *ppos);
 
 	res = nfs_revalidate_mapping(inode, filp->f_mapping);
 	if (!res)
-		res = generic_file_sendfile(filp, ppos, count, actor, target);
+		res = generic_file_splice_read(filp, ppos, pipe, count, flags);
 	return res;
 }
 
