Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35481 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757368AbaEIVk5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 May 2014 17:40:57 -0400
Date: Fri, 9 May 2014 17:40:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFSD: Don't clear SUID/SGID after root writing data
Message-ID: <20140509214056.GC497@fieldses.org>
References: <534AA92B.8010805@gmail.com>
 <20140418130220.GF18612@fieldses.org>
 <53512DE5.7050907@gmail.com>
 <5351501B.1010507@gmail.com>
 <20140508161256.GC20976@fieldses.org>
 <536C89D7.6090902@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <536C89D7.6090902@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 09, 2014 at 03:55:03PM +0800, Kinglong Mee wrote:
> On 5/9/2014 00:12, J. Bruce Fields wrote:
> > I'd like to apply this if only to remove the redundant code.
> > 
> > I'd like to understand, though, whether this is something that caused an
> > actual practical problem for someone, or if you just happened to notice
> > the inconsistency between nfs and ext4 behavior?
> 
> I test it with ext2,ext3,btrfs,xfs.
> Test result is same as ext4.
> So, we needs remove the redundant killing of suid/sgid.

Understood that this would make the behavior consistent with
filesystems.  But, you don't know of any cases of the current behavior
is actually causing a problem for anyone?

Anyway, I intend to apply with a slightly longer changelog, as below.

--b.

commit 0dcee85226291950adde74338a2972ac7f3c9410
Author: Kinglong Mee <kinglongmee@gmail.com>
Date:   Sat Apr 19 00:17:31 2014 +0800

    NFSD: Don't clear SUID/SGID after root writing data
    
    We're clearing the SUID/SGID bits on write by hand in nfsd_vfs_write,
    even though the subsequent vfs_writev() call will end up doing this for
    us (through file system write methods eventually calling
    file_remove_suid(), e.g., from __generic_file_aio_write).
    
    So, remove the redundant nfsd code.
    
    The only change in behavior is when the write is by root, in which case
    we previously cleared SUID/SGID, but will now leave it alone.  The new
    behavior is the behavior of every filesystem we've checked.
    
    It seems better to be consistent with local filesystem behavior.  And
    the security advantage seems limited as root could always restore these
    bits by hand if it wanted.
    
    SUID/SGID is not cleared after writing data with (root, local ext4),
       File: ‘test’
       Size: 0               Blocks: 0          IO Block: 4096   regular
    empty file
    Device: 803h/2051d      Inode: 1200137     Links: 1
    Access: (4777/-rwsrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
    Context: unconfined_u:object_r:admin_home_t:s0
    Access: 2014-04-18 21:36:31.016029014 +0800
    Modify: 2014-04-18 21:36:31.016029014 +0800
    Change: 2014-04-18 21:36:31.026030285 +0800
      Birth: -
       File: ‘test’
       Size: 5               Blocks: 8          IO Block: 4096   regular file
    Device: 803h/2051d      Inode: 1200137     Links: 1
    Access: (4777/-rwsrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
    Context: unconfined_u:object_r:admin_home_t:s0
    Access: 2014-04-18 21:36:31.016029014 +0800
    Modify: 2014-04-18 21:36:31.040032065 +0800
    Change: 2014-04-18 21:36:31.040032065 +0800
      Birth: -
    
    With no_root_squash, (root, remote ext4), SUID/SGID are cleared,
       File: ‘test’
       Size: 0               Blocks: 0          IO Block: 262144 regular
    empty file
    Device: 24h/36d Inode: 786439      Links: 1
    Access: (4777/-rwsrwxrwx)  Uid: ( 1000/    test)   Gid: ( 1000/    test)
    Context: system_u:object_r:nfs_t:s0
    Access: 2014-04-18 21:45:32.155805097 +0800
    Modify: 2014-04-18 21:45:32.155805097 +0800
    Change: 2014-04-18 21:45:32.168806749 +0800
      Birth: -
       File: ‘test’
       Size: 5               Blocks: 8          IO Block: 262144 regular file
    Device: 24h/36d Inode: 786439      Links: 1
    Access: (0777/-rwxrwxrwx)  Uid: ( 1000/    test)   Gid: ( 1000/    test)
    Context: system_u:object_r:nfs_t:s0
    Access: 2014-04-18 21:45:32.155805097 +0800
    Modify: 2014-04-18 21:45:32.184808783 +0800
    Change: 2014-04-18 21:45:32.184808783 +0800
      Birth: -
    
    Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 16f0673..6aaa305 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -857,20 +857,6 @@ nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	return err;
 }
 
-static void kill_suid(struct dentry *dentry)
-{
-	struct iattr	ia;
-	ia.ia_valid = ATTR_KILL_SUID | ATTR_KILL_SGID | ATTR_KILL_PRIV;
-
-	mutex_lock(&dentry->d_inode->i_mutex);
-	/*
-	 * Note we call this on write, so notify_change will not
-	 * encounter any conflicting delegations:
-	 */
-	notify_change(dentry, &ia, NULL);
-	mutex_unlock(&dentry->d_inode->i_mutex);
-}
-
 /*
  * Gathered writes: If another process is currently writing to the file,
  * there's a high chance this is another nfsd (triggered by a bulk write
@@ -942,10 +928,6 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	nfsdstats.io_write += host_err;
 	fsnotify_modify(file);
 
-	/* clear setuid/setgid flag after write */
-	if (inode->i_mode & (S_ISUID | S_ISGID))
-		kill_suid(dentry);
-
 	if (stable) {
 		if (use_wgather)
 			host_err = wait_for_concurrent_writes(file);
