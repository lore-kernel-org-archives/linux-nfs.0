From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull client fixes for 2.6.25-rc1
Date: Fri, 15 Feb 2008 14:53:32 -0500
Message-ID: <1203105213.16315.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57512 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752751AbYBOTxp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2008 14:53:45 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "hotfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git hotfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/compat.c        |    3 ---
 fs/nfs/callback.c  |   18 ++++++++++++------
 fs/nfs/dir.c       |    8 +++-----
 fs/nfs/nfs4state.c |    4 ++--
 fs/nfs/super.c     |    4 ++++
 5 files changed, 21 insertions(+), 16 deletions(-)

commit 8d042218b075de3cdbe066198515b3521553746e
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Wed Feb 13 16:47:06 2008 -0500

    NFS: add missing spkm3 strings to mount option parser
    
    This patch adds previous missing spkm3 string values that are needed
    to parse mount options in the kernel.

commit 25606656b19a38bbece914c4c67101f674908f49
Author: Jeff Layton <jlayton@redhat.com>
Date:   Tue Feb 12 06:49:01 2008 -0500

    NFS: remove error field from nfs_readdir_descriptor_t
    
    The error field in nfs_readdir_descriptor_t is never used outside of the
    function in which it is set. Remove the field and change the place that
    does use it to use an existing local variable.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 497799e7c0ac7e82164a510ebf8beed7b3635e34
Author: Dan Muntz <dmuntz@netapp.com>
Date:   Wed Feb 13 13:09:35 2008 -0800

    NFS: missing spaces in KERN_WARNING
    
    The warning message for a v4 server returning various bad sequence-ids is
    missing spaces.
    
    Signed-off-by: Dan Muntz <dmuntz@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4267c9561d9c3bb2abf45abed9c75a1c892d7d15
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Feb 13 14:55:17 2008 -0500

    NFS: Allow text-based mounts via compat_sys_mount
    
    The compat_sys_mount() system call throws EINVAL for text-based NFSv4
    mounts.
    
    The text-based mount interface assumes that any mount option blob that
    doesn't set the version field to "1" is a C string (ie not a legacy
    mount request).  The compat_sys_mount() call treats blobs that don't
    set the version field to "1" as an error.  We just relax the check in
    compat_sys_mount() a bit to allow C strings to be passed down to the NFSv4
    client.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8e60029f403781b8a63b7ffdb7dc1faff6ca651e
Author: Jeff Layton <jlayton@redhat.com>
Date:   Mon Feb 11 10:00:20 2008 -0500

    NFS: fix reference counting for NFSv4 callback thread
    
    The reference counting for the NFSv4 callback thread stays artificially
    high. When this thread comes down, it doesn't properly tear down the
    svc_serv, causing a memory leak. In my testing on an older kernel on
    x86_64, memory would leak out of the 8k kmalloc slab. So, we're leaking
    at least a page of memory every time the thread comes down.
    
    svc_create() creates the svc_serv with a sv_nrthreads count of 1, and
    then svc_create_thread() increments that count. Whenever the callback
    thread is started it has a sv_nrthreads count of 2. When coming down, it
    calls svc_exit_thread() which decrements that count and if it hits 0, it
    tears everything down. That never happens here since the count is always
    at 2 when the thread exits.
    
    The problem is that nfs_callback_up() should be calling svc_destroy() on
    the svc_serv on both success and failure. This is how lockd_up_proto()
    handles the reference counting, and doing that here fixes the leak.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/compat.c b/fs/compat.c
index 43ca016..2ce4456 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -702,9 +702,6 @@ static int do_nfs4_super_data_conv(void *raw_data)
 		real->flags = raw->flags;
 		real->version = raw->version;
 	}
-	else {
-		return -EINVAL;
-	}
 
 	return 0;
 }
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index bd185a5..ecc06c6 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -105,7 +105,7 @@ static void nfs_callback_svc(struct svc_rqst *rqstp)
  */
 int nfs_callback_up(void)
 {
-	struct svc_serv *serv;
+	struct svc_serv *serv = NULL;
 	int ret = 0;
 
 	lock_kernel();
@@ -122,24 +122,30 @@ int nfs_callback_up(void)
 	ret = svc_create_xprt(serv, "tcp", nfs_callback_set_tcpport,
 			      SVC_SOCK_ANONYMOUS);
 	if (ret <= 0)
-		goto out_destroy;
+		goto out_err;
 	nfs_callback_tcpport = ret;
 	dprintk("Callback port = 0x%x\n", nfs_callback_tcpport);
 
 	ret = svc_create_thread(nfs_callback_svc, serv);
 	if (ret < 0)
-		goto out_destroy;
+		goto out_err;
 	nfs_callback_info.serv = serv;
 	wait_for_completion(&nfs_callback_info.started);
 out:
+	/*
+	 * svc_create creates the svc_serv with sv_nrthreads == 1, and then
+	 * svc_create_thread increments that. So we need to call svc_destroy
+	 * on both success and failure so that the refcount is 1 when the
+	 * thread exits.
+	 */
+	if (serv)
+		svc_destroy(serv);
 	mutex_unlock(&nfs_callback_mutex);
 	unlock_kernel();
 	return ret;
-out_destroy:
+out_err:
 	dprintk("Couldn't create callback socket or server thread; err = %d\n",
 		ret);
-	svc_destroy(serv);
-out_err:
 	nfs_callback_info.users--;
 	goto out;
 }
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 476cb0f..ae04892 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -154,7 +154,6 @@ typedef struct {
 	struct nfs_entry *entry;
 	decode_dirent_t	decode;
 	int		plus;
-	int		error;
 	unsigned long	timestamp;
 	int		timestamp_valid;
 } nfs_readdir_descriptor_t;
@@ -213,7 +212,6 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
 	return 0;
  error:
 	unlock_page(page);
-	desc->error = error;
 	return -EIO;
 }
 
@@ -483,13 +481,13 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
 		goto out;
 	}
 	timestamp = jiffies;
-	desc->error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, *desc->dir_cookie,
-						page,
+	status = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred,
+						*desc->dir_cookie, page,
 						NFS_SERVER(inode)->dtsize,
 						desc->plus);
 	desc->page = page;
 	desc->ptr = kmap(page);		/* matching kunmap in nfs_do_filldir */
-	if (desc->error >= 0) {
+	if (status >= 0) {
 		desc->timestamp = timestamp;
 		desc->timestamp_valid = 1;
 		if ((status = dir_decode(desc)) == 0)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index f9c7432..6233eb5 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -682,8 +682,8 @@ static void nfs_increment_seqid(int status, struct nfs_seqid *seqid)
 			if (seqid->sequence->flags & NFS_SEQID_CONFIRMED)
 				return;
 			printk(KERN_WARNING "NFS: v4 server returned a bad"
-					"sequence-id error on an"
-					"unconfirmed sequence %p!\n",
+					" sequence-id error on an"
+					" unconfirmed sequence %p!\n",
 					seqid->sequence);
 		case -NFS4ERR_STALE_CLIENTID:
 		case -NFS4ERR_STALE_STATEID:
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7f4505f..1fb3818 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -190,6 +190,10 @@ static match_table_t nfs_secflavor_tokens = {
 	{ Opt_sec_lkeyi, "lkeyi" },
 	{ Opt_sec_lkeyp, "lkeyp" },
 
+	{ Opt_sec_spkm, "spkm3" },
+	{ Opt_sec_spkmi, "spkm3i" },
+	{ Opt_sec_spkmp, "spkm3p" },
+
 	{ Opt_sec_err, NULL }
 };
 
