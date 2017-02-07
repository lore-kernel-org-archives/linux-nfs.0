Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34927 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753522AbdBGLgE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 06:36:04 -0500
Received: by mail-wm0-f68.google.com with SMTP id u63so27743219wmu.2
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 03:36:03 -0800 (PST)
Date: Tue, 7 Feb 2017 12:35:54 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Linux NFS list <linux-nfs@vger.kernel.org>, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org, v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jan Kara <jack@suse.cz>, Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
Message-ID: <20170207113554.GA30656@veci.piliscsaba.szeredi.hu>
References: <20170205015145.GB13195@ZenIV.linux.org.uk>
 <CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
 <20170205210151.GD13195@ZenIV.linux.org.uk>
 <CAJfpeguzOgX9d+5XCNJcmXW5KkrGbnWB5aZSP1-0q3a6i6uk2w@mail.gmail.com>
 <20170205220445.GE13195@ZenIV.linux.org.uk>
 <20170206030532.GF13195@ZenIV.linux.org.uk>
 <CAJfpegv5ZGd2gzSbQvgk4uX5q06AijY+TNg2jdrPBSjbFoXMfg@mail.gmail.com>
 <20170206095706.GG13195@ZenIV.linux.org.uk>
 <CAJfpegv-ePQE9pNwZe6O+0LjJdq2aVk3bnhxeZ=y7P+iFq72XA@mail.gmail.com>
 <20170207071909.GI13195@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170207071909.GI13195@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 07, 2017 at 07:19:09AM +0000, Al Viro wrote:

> Speaking of refcounting - what's going on with fuse_file one?  My reading
> of that code is that you have 4 states of that thing:
> 	* new (just created, fallback request allocated, use fuse_file_free()
> to kill).  Refcount is 0.
> 	* intermediate - in fact it's already opened, but still not
> put into ->private_data.  Refcount is still 0.  Use fuse_sync_release() to kill.
> 	* live - normal refcounting (fuse_file_get()/fuse_file_put()).
> 	* shutdown - refcount has reached 0.  Can't happen until ->release()
> (obviously - ->private_data holds a counting reference), some pieces of
> fuse_sync_release() correspond to some stuff in fuse_release_common(), some -
> to final fuse_file_put().
> 
> To make it even more convoluted, cuse is using fuse_sync_release() and
> apparently relies upon no references being grabbed after fuse_do_open(),
> so that thing can be called with refcount 0 *or* refcount 1.

Indeed, ugly.  Following should clean that up somewhat.  The states remain what
they are but refcounting is at least consistent now.  This also fixes a missing
FR_FORCE in the sync case.
 
> Another thing: what guarantees that places in writepages-related paths
> where we store a reference into req->ff won't hit a request with already
> non-NULL ->ff?

Well, it is set before being sent (queued onto queued_writes or queued on the
fuse device), but not when queued as secondary request onto an already in-flight
one.  It looks okay to me.

Thanks,
Miklos

diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index 811fd8929a18..e816166ce42f 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -473,7 +473,7 @@ static int fuse_create_open(struct inode *dir, struct dentry *entry,
 	if (err) {
 		fuse_sync_release(ff, flags);
 	} else {
-		file->private_data = fuse_file_get(ff);
+		file->private_data = ff;
 		fuse_finish_open(inode, file);
 	}
 	return err;
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 2401c5dabb2a..94cc4ab01f9a 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -58,7 +58,7 @@ struct fuse_file *fuse_file_alloc(struct fuse_conn *fc)
 	}
 
 	INIT_LIST_HEAD(&ff->write_entry);
-	atomic_set(&ff->count, 0);
+	atomic_set(&ff->count, 1);
 	RB_CLEAR_NODE(&ff->polled_node);
 	init_waitqueue_head(&ff->poll_wait);
 
@@ -75,7 +75,7 @@ void fuse_file_free(struct fuse_file *ff)
 	kfree(ff);
 }
 
-struct fuse_file *fuse_file_get(struct fuse_file *ff)
+static struct fuse_file *fuse_file_get(struct fuse_file *ff)
 {
 	atomic_inc(&ff->count);
 	return ff;
@@ -100,6 +100,7 @@ static void fuse_file_put(struct fuse_file *ff, bool sync)
 			iput(req->misc.release.inode);
 			fuse_put_request(ff->fc, req);
 		} else if (sync) {
+			__set_bit(FR_FORCE, &req->flags);
 			__clear_bit(FR_BACKGROUND, &req->flags);
 			fuse_request_send(ff->fc, req);
 			iput(req->misc.release.inode);
@@ -146,7 +147,7 @@ int fuse_do_open(struct fuse_conn *fc, u64 nodeid, struct file *file,
 		ff->open_flags &= ~FOPEN_DIRECT_IO;
 
 	ff->nodeid = nodeid;
-	file->private_data = fuse_file_get(ff);
+	file->private_data = ff;
 
 	return 0;
 }
@@ -297,13 +298,9 @@ static int fuse_release(struct inode *inode, struct file *file)
 
 void fuse_sync_release(struct fuse_file *ff, int flags)
 {
-	WARN_ON(atomic_read(&ff->count) > 1);
+	WARN_ON(atomic_read(&ff->count) != 1);
 	fuse_prepare_release(ff, flags, FUSE_RELEASE);
-	__set_bit(FR_FORCE, &ff->reserved_req->flags);
-	__clear_bit(FR_BACKGROUND, &ff->reserved_req->flags);
-	fuse_request_send(ff->fc, ff->reserved_req);
-	fuse_put_request(ff->fc, ff->reserved_req);
-	kfree(ff);
+	fuse_file_put(ff, true);
 }
 EXPORT_SYMBOL_GPL(fuse_sync_release);
 
diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index 91307940c8ac..83f797271aef 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -732,7 +732,6 @@ void fuse_read_fill(struct fuse_req *req, struct file *file,
 int fuse_open_common(struct inode *inode, struct file *file, bool isdir);
 
 struct fuse_file *fuse_file_alloc(struct fuse_conn *fc);
-struct fuse_file *fuse_file_get(struct fuse_file *ff);
 void fuse_file_free(struct fuse_file *ff);
 void fuse_finish_open(struct inode *inode, struct file *file);
 
