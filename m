From: Olaf Kirch <okir@suse.de>
Subject: Re: nfsd: rewrite performance problem
Date: Wed, 27 Jul 2005 12:21:22 +0200
Message-ID: <20050727102122.GE10892@suse.de>
References: <20050720130623.GA12537@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dxj2a-0003n5-7f
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 03:21:32 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dxj2Z-0002x8-IZ
	for nfs@lists.sourceforge.net; Wed, 27 Jul 2005 03:21:32 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id D1DF1F074
	for <nfs@lists.sourceforge.net>; Wed, 27 Jul 2005 12:21:22 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20050720130623.GA12537@suse.de>
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


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jul 20, 2005 at 03:06:23PM +0200, Olaf Kirch wrote:
> we've just been investigating a performance problem at a customer of ours.
> On a machine of 4G RAM, they were running N iozone threads on one 1G file
> each. For 3 threads, where the working set fits into RAM, the rewrite
> numbers are reasonably, but when using 4 threads, rewrite performance is
> horrible.
[...]
> Chris Mason and I looked into this, and we believe we've nailed down
> the problem, which is the use of writev in nfsd_write. nfsd receives
> the WRITE request from the client, broken up into page sized chunks.
> The default implementation of writev will simply call file->op->write
> for each of the fragments it's given, but the first fragment is
> PAGE_SIZE minus the RPC header and write_args. So we end up writing
> less than a full block, causing the block to be read first. All
> subsequent pages in the iovec are non block aligned either, so the
> same happens for these as well.

The customer has confirmed that this is indeed what's causing the
problem. Here's a patch to make nfsd_write page align the payload when
it sees a rewrite. I'm currently testing this patch (and I will also
do some performance testing to see if we get a general performance if
I page align all writes).

Any comments?

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=nfsd-rewrite-align

Subject: NFS: Fix rewrite performance

This patch fixes a performance issue with rewrite. Most of the time,
the iovecs passed to nfsd_vfs_write are unaligned. As the default writev
implementation will just call write() on each chunk in the iovec, this
will cause partial blocks to be dirtied, triggering a read-modify-write
cycle for each block.

The short-term fix is to make sure nfsd aligns the data properly.
The long term fix would be to make the VFS smarter about writev requests.

Signed-off-by: Olaf Kirch <okir@suse.de>

Index: linux-2.6.12.new/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.12.new.orig/fs/nfsd/vfs.c
+++ linux-2.6.12.new/fs/nfsd/vfs.c
@@ -874,6 +874,46 @@ out:
 	return err;
 }
 
+/*
+ * Helper function to page-align the write payload.
+ */
+static inline int
+nfsd_page_align_payload(struct iovec *vec, int vlen)
+{
+	unsigned char *this_page, *prev_page;
+	int i, chunk0, chunk1;
+
+	/* The following checks are just paranoia */
+	if (vlen < 2)
+		return 0;
+
+	if (vec[0].iov_len + vec[vlen-1].iov_len != PAGE_CACHE_SIZE)
+		return 0;
+	for (i = 1; i < vlen - 1; ++i) {
+		if (vec[i].iov_len != PAGE_CACHE_SIZE)
+			return 0;
+	}
+
+	chunk0 = vec[0].iov_len;
+	chunk1 = PAGE_CACHE_SIZE - chunk0;
+
+	this_page = (unsigned char *) vec[vlen-1].iov_base;
+	for (i = vlen-1; i; --i) {
+		prev_page = (unsigned char *) vec[i-1].iov_base;
+
+		/* Push trailing partial page so it's
+		 * aligned with the end of the page, then
+		 * pull up the missing chunk from the previous
+		 * page */
+		memmove(this_page + chunk0, this_page, chunk1);
+		memcpy(this_page, prev_page + chunk1, chunk0);
+		vec[i].iov_len = PAGE_CACHE_SIZE;
+		this_page = prev_page;
+	}
+
+	return 1;
+}
+
 static inline int
 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 				loff_t offset, struct kvec *vec, int vlen,
@@ -917,6 +957,17 @@ nfsd_vfs_write(struct svc_rqst *rqstp, s
 	if (stable && !EX_WGATHER(exp))
 		file->f_flags |= O_SYNC;
 
+	/* Hack: if we're rewriting the file, make sure
+	 * we align the iovec properly to avoid costly
+	 * read-modify-write operations on the block devices.
+	 * This hack can go away once we have generic_file_writev.
+	 */
+	if ((offset < inode->i_size)
+	 && (cnt % PAGE_CACHE_SIZE) == 0
+	 && vec->iov_len != PAGE_CACHE_SIZE
+	 && nfsd_page_align_payload(vec, vlen))
+		vec++, vlen--;
+
 	/* Write the data. */
 	oldfs = get_fs(); set_fs(KERNEL_DS);
 	err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);

--LQksG6bCIzRHxTLp--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
