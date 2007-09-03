From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re:
	=?iso-8859-1?q?slowness_due_to_splitting_into_pages_in=09nf?=
	=?iso-8859-1?q?s3svc=5Fdecode=5Fwriteargs_=28=29?=
Date: Mon, 3 Sep 2007 22:02:37 +0200
Message-ID: <200709032202.37927.bernd-schubert@gmx.de>
References: <200708312003.30446.bernd-schubert@gmx.de>
	<20070831184515.GC11165@fieldses.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_dhG3GLiDpwqeFDg"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, okir@suse.de,
	"Brian J. Murrell" <brian@interlinx.bc.ca>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ISI8G-0003wO-50
	for nfs@lists.sourceforge.net; Mon, 03 Sep 2007 13:02:48 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1ISI8I-000204-VY
	for nfs@lists.sourceforge.net; Mon, 03 Sep 2007 13:02:52 -0700
In-Reply-To: <20070831184515.GC11165@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--Boundary-00=_dhG3GLiDpwqeFDg
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 31 August 2007, J. Bruce Fields wrote:
>
> Hm.  Any chance this is the same problem?:
>
> 	http://marc.info/?l=linux-nfs&m=112289652218095&w=2
>

I have slightly modified Olafs patch, now the last page is saved and restored. 
Well there's a problem with it, if there's more than one thread, files over 
nfs become corrupted, if there's only one thread everything is fine. So far I 
have no idea whats going on.

In principal we could do the same in do_readv_writev(), the iov vector there 
should hopefully only belong to one thread. 

Anyway, using this patch, the nfs-write speed on lustre is about 200 MB/s.


Cheers,
Bernd

--Boundary-00=_dhG3GLiDpwqeFDg
Content-Type: text/x-diff; charset="iso-8859-1"; name="nfs_align.patch_racy"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="nfs_align.patch_racy"

Index: linux-2.6.20.3/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.20.3.orig/fs/nfsd/vfs.c	2007-09-03 14:41:54.000000000 +0200
+++ linux-2.6.20.3/fs/nfsd/vfs.c	2007-09-03 17:41:36.000000000 +0200
@@ -900,6 +900,48 @@
 	mutex_unlock(&dentry->d_inode->i_mutex);
 }
 
+/*
+ * Helper function to page-align the write payload.
+ */
+static int
+nfsd_page_align_payload(struct kvec *vec, int vlen)
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
+			* aligned with the end of the page, then
+			* pull up the missing chunk from the previous
+			* page */
+		memmove(this_page + chunk0, this_page, chunk1);
+		memcpy(this_page, prev_page + chunk1, chunk0);
+		vec[i].iov_len = PAGE_CACHE_SIZE;
+		this_page = prev_page;
+	}
+
+	return 1;
+}
+
+
+
 static __be32
 nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 				loff_t offset, struct kvec *vec, int vlen,
@@ -912,6 +954,8 @@
 	__be32			err = 0;
 	int			host_err;
 	int			stable = *stablep;
+	char 			*tmp_page; /* used for page alignement */
+	int			did_align = 0;
 
 #ifdef MSNFS
 	err = nfserr_perm;
@@ -944,6 +988,26 @@
 	if (stable && !EX_WGATHER(exp))
 		file->f_flags |= O_SYNC;
 
+	/* save the last vector element, besides file data it may have
+	 * nfsv4 data, which will be overwritten by the alignement hack */
+	tmp_page = (char *) __get_free_page(GFP_KERNEL);
+	if (tmp_page
+	&& (offset < inode->i_size)
+	&& vec->iov_len != PAGE_CACHE_SIZE) {
+		memcpy(tmp_page, vec[vlen - 1].iov_base, PAGE_SIZE);
+
+		/* Hack: if we're rewriting the file, make sure
+		* we align the iovec properly to avoid costly
+		* read-modify-write operations on the block devices.
+		* This hack can go away once we have generic_file_writev.
+		*/
+
+		if (nfsd_page_align_payload(vec, vlen)) {
+			did_align = 1;
+			vec++, vlen--;
+		}
+	}
+
 	/* Write the data. */
 	oldfs = get_fs(); set_fs(KERNEL_DS);
 	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
@@ -953,6 +1017,12 @@
 		fsnotify_modify(file->f_path.dentry);
 	}
 
+	/* restore the last vector element */
+	if (did_align) {
+		memcpy(vec[vlen - 1].iov_base, tmp_page, PAGE_SIZE);
+		free_page((unsigned long) tmp_page);
+	}
+
 	/* clear setuid/setgid flag after write */
 	if (host_err >= 0 && (inode->i_mode & (S_ISUID | S_ISGID)))
 		kill_suid(dentry);

--Boundary-00=_dhG3GLiDpwqeFDg
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--Boundary-00=_dhG3GLiDpwqeFDg
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--Boundary-00=_dhG3GLiDpwqeFDg--
