From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: atimes not updated over NFS
Date: Mon, 28 Jan 2008 23:14:11 -0500
Message-ID: <20080129041411.GC1190@fieldses.org>
References: <20080109235153.GI9212@aym.net2.nerim.net> <20080114083435.GA24215@janus> <1200325393.7470.6.camel@heimdal.trondhjem.org> <20080114175122.GB2768@janus> <20080121190638.GL17468@fieldses.org> <1200943865.25562.56.camel@heimdal.trondhjem.org> <20080121210230.GA22046@janus> <20080121210925.GQ17468@fieldses.org> <20080122171717.GD24697@fieldses.org> <20080129025940.GI16785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>, linux-nfs@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50794 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736AbYA2EOS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 23:14:18 -0500
In-Reply-To: <20080129025940.GI16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 09:59:40PM -0500, bfields wrote:
> On Tue, Jan 22, 2008 at 12:17:17PM -0500, bfields wrote:
> > On Mon, Jan 21, 2008 at 04:09:25PM -0500, bfields wrote:
> > > On Mon, Jan 21, 2008 at 10:02:30PM +0100, Frank van Maarseveen wrote:
> > > > 2.6.22.10:
> > > > 	t
> > > > 	t + 2
> > > > 	t + 2
> > > > 
> > > > (same behavior)
> > > > 
> > > > 2.6.23.12:
> > > > 	t
> > > > 	t
> > > > 	t
> > > > 
> > > > definately not good. "cat" on the server updates atime again.
> > > 
> > > Yes, that looks like a server bug, and this:...
> > > 
> > > > 
> > > > 
> > > > Trying a different combination of kernels:
> > > > 
> > > > server 2.6.23.12, client 2.6.22.10:
> > > > 	t
> > > > 	t
> > > > 	t
> > > > 
> > > > server 2.6.22.10, client 2.6.23.12:
> > > > 	t
> > > > 	t + 2
> > > > 	t + 2
> > > 
> > > ...confirms that since the results appear to depend only on the server
> > > version, not on the client version.
> > 
> > And I can confirm this here on 2.6.24-rc8 (+ a few patches).
> > Unfortunately, I don't have any suggestion better right now than
> > bisecting....
> 
> It looks like this happened in the switch from sendfile to sparse.
							     ^^^^^^
							err, splice

> Jens, any advice?  What happened was nfsd reads stopped updating the
> atime after the following commit.

Erm, sorry, wrong commit--it's the following one that touches nfsd,
below.

--b.

commit cf8208d0eabd1d5d2625ec02a175a294c3f30d36
Author: Jens Axboe <jens.axboe@oracle.com>
Date:   Tue Jun 12 21:22:14 2007 +0200

    sendfile: convert nfsd to splice_direct_to_actor()
    
    Signed-off-by: Jens Axboe <jens.axboe@oracle.com>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7e6aa24..15471a9 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -23,7 +23,7 @@
 #include <linux/file.h>
 #include <linux/mount.h>
 #include <linux/major.h>
-#include <linux/ext2_fs.h>
+#include <linux/pipe_fs_i.h>
 #include <linux/proc_fs.h>
 #include <linux/stat.h>
 #include <linux/fcntl.h>
@@ -801,26 +801,32 @@ found:
 }
 
 /*
- * Grab and keep cached pages assosiated with a file in the svc_rqst
- * so that they can be passed to the netowork sendmsg/sendpage routines
- * directrly. They will be released after the sending has completed.
+ * Grab and keep cached pages associated with a file in the svc_rqst
+ * so that they can be passed to the network sendmsg/sendpage routines
+ * directly. They will be released after the sending has completed.
  */
 static int
-nfsd_read_actor(read_descriptor_t *desc, struct page *page, unsigned long offset , unsigned long size)
+nfsd_splice_actor(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
+		  struct splice_desc *sd)
 {
-	unsigned long count = desc->count;
-	struct svc_rqst *rqstp = desc->arg.data;
+	struct svc_rqst *rqstp = sd->u.data;
 	struct page **pp = rqstp->rq_respages + rqstp->rq_resused;
+	struct page *page = buf->page;
+	size_t size;
+	int ret;
+
+	ret = buf->ops->pin(pipe, buf);
+	if (unlikely(ret))
+		return ret;
 
-	if (size > count)
-		size = count;
+	size = sd->len;
 
 	if (rqstp->rq_res.page_len == 0) {
 		get_page(page);
 		put_page(*pp);
 		*pp = page;
 		rqstp->rq_resused++;
-		rqstp->rq_res.page_base = offset;
+		rqstp->rq_res.page_base = buf->offset;
 		rqstp->rq_res.page_len = size;
 	} else if (page != pp[-1]) {
 		get_page(page);
@@ -832,11 +838,15 @@ nfsd_read_actor(read_descriptor_t *desc, struct page *page, unsigned long offset
 	} else
 		rqstp->rq_res.page_len += size;
 
-	desc->count = count - size;
-	desc->written += size;
 	return size;
 }
 
+static int nfsd_direct_splice_actor(struct pipe_inode_info *pipe,
+				    struct splice_desc *sd)
+{
+	return __splice_from_pipe(pipe, sd, nfsd_splice_actor);
+}
+
 static __be32
 nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
               loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
@@ -861,10 +871,15 @@ nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	if (ra && ra->p_set)
 		file->f_ra = ra->p_ra;
 
-	if (file->f_op->sendfile && rqstp->rq_sendfile_ok) {
-		rqstp->rq_resused = 1;
-		host_err = file->f_op->sendfile(file, &offset, *count,
-						 nfsd_read_actor, rqstp);
+	if (file->f_op->splice_read && rqstp->rq_splice_ok) {
+		struct splice_desc sd = {
+			.len		= 0,
+			.total_len	= *count,
+			.pos		= offset,
+			.u.data		= rqstp,
+		};
+
+		host_err = splice_direct_to_actor(file, &sd, nfsd_direct_splice_actor);
 	} else {
 		oldfs = get_fs();
 		set_fs(KERNEL_DS);
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 4a7ae8a..129d50f 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -253,7 +253,7 @@ struct svc_rqst {
 						 * determine what device number
 						 * to report (real or virtual)
 						 */
-	int			rq_sendfile_ok; /* turned off in gss privacy
+	int			rq_splice_ok;   /* turned off in gss privacy
 						 * to prevent encrypting page
 						 * cache pages */
 	wait_queue_head_t	rq_wait;	/* synchronization */
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 099a983..c094583 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -853,7 +853,7 @@ unwrap_priv_data(struct svc_rqst *rqstp, struct xdr_buf *buf, u32 seq, struct gs
 	u32 priv_len, maj_stat;
 	int pad, saved_len, remaining_len, offset;
 
-	rqstp->rq_sendfile_ok = 0;
+	rqstp->rq_splice_ok = 0;
 
 	priv_len = svc_getnl(&buf->head[0]);
 	if (rqstp->rq_deferred) {
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index e673ef9..55ea6df 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -814,7 +814,7 @@ svc_process(struct svc_rqst *rqstp)
 	rqstp->rq_res.tail[0].iov_base = NULL;
 	rqstp->rq_res.tail[0].iov_len = 0;
 	/* Will be turned off only in gss privacy case: */
-	rqstp->rq_sendfile_ok = 1;
+	rqstp->rq_splice_ok = 1;
 	/* tcp needs a space for the record length... */
 	if (rqstp->rq_prot == IPPROTO_TCP)
 		svc_putnl(resv, 0);
