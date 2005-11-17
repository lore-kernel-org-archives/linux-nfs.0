From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] spinlock recursion on inode number mismatches
Date: Thu, 17 Nov 2005 17:07:15 -0500
Message-ID: <437CFF13.50606@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030302050207000704010309"
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

This is a multi-part message in MIME format.
--------------030302050207000704010309
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

When compiling over NFS using a 2.6.14 kernel, the following
spinlock recursion BUG popped:

nfs_update_inode: inode number mismatch
expected (0:16/0x1dee71a), got (0:16/0x100000000000000)
nfs_update_inode: inode number mismatch
expected (0:16/0x1dee71a), got (0:16/0x1dee719)
nfs_update_inode: inode number mismatch
expected (0:16/0x1dee71a), got (0:16/0x0)
nfs_update_inode: inode number mismatch
expected (0:16/0x1dee71a), got (0:16/0x1dee719)
BUG: spinlock recursion on CPU#0, bhc/22635 (Not tainted)
  lock: db7294e8, .magic: dead4ead, .owner: bhc/22635, .owner_cpu: 0
  [<c01f53b3>] spin_bug+0xa3/0xd7
  [<c01f551e>] _raw_spin_lock+0x68/0x6a
  [<f8db1151>] nfs_zap_caches+0x1a/0xaa [nfs]
  [<f8db2445>] nfs_update_inode+0x9f/0x618 [nfs]
  [<c033be8c>] _spin_unlock_irq+0x5/0x7
  [<f8db236b>] nfs_post_op_update_inode+0x2c/0x67 [nfs]
  [<f8dba716>] nfs3_proc_remove+0x9e/0xd7 [nfs]
  [<f8daed5a>] nfs_safe_remove+0x68/0xc4 [nfs]
  [<f8daee5e>] nfs_unlink+0xa8/0x10e [nfs]
  [<c017c8df>] vfs_unlink+0x19f/0x1a6
  [<c017c9a3>] sys_unlink+0xbd/0x13e
  [<c033cee2>] do_page_fault+0x262/0x650
  [<c016cb1d>] do_sync_read+0x0/0x116
  [<c01040a5>] syscall_call+0x7/0xb
Kernel panic - not syncing: bad locking
  [<c01250a8>] panic+0x45/0x1c5
  [<c01f53e7>] __spin_lock_debug+0x0/0xcf
  [<c01f551e>] _raw_spin_lock+0x68/0x6a
  [<f8db1151>] nfs_zap_caches+0x1a/0xaa [nfs]
  [<f8db2445>] nfs_update_inode+0x9f/0x618 [nfs]
  [<c033be8c>] _spin_unlock_irq+0x5/0x7
  [<f8db236b>] nfs_post_op_update_inode+0x2c/0x67 [nfs]
  [<f8dba716>] nfs3_proc_remove+0x9e/0xd7 [nfs]
  [<f8daed5a>] nfs_safe_remove+0x68/0xc4 [nfs]
  [<f8daee5e>] nfs_unlink+0xa8/0x10e [nfs]
  [<c017c8df>] vfs_unlink+0x19f/0x1a6
  [<c017c9a3>] sys_unlink+0xbd/0x13e
  [<c033cee2>] do_page_fault+0x262/0x650
  [<c016cb1d>] do_sync_read+0x0/0x116
  [<c01040a5>] syscall_call+0x7/0xb

The attached patch solve the problem by the problem by moving
the call to nfs_invalidate_inode() out of nfs_invalidate_inode().

Commments?

steved.



--------------030302050207000704010309
Content-Type: text/x-patch;
 name="linux-2.6.14-nfs-spinlock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.14-nfs-spinlock.patch"

The following patch stop a spinlock recursion BUG() from
popping by moving the call to nfs_invalidate_inode()
out of nfs_update_inode(). The nfs_invalidate_inode() is now
down only when nfs_update_inode() returns -ESTALE.

Signed-off-by: Steve Dickson <steved@redhat.com>

----------------------------------------------
--- linux-2.6.14/fs/nfs/inode.c.orig	2005-11-16 12:04:36.464685000 -0500
+++ linux-2.6.14/fs/nfs/inode.c	2005-11-16 14:23:45.790210000 -0500
@@ -1129,6 +1129,8 @@ __nfs_revalidate_inode(struct nfs_server
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) refresh failed, error=%d\n",
 			 inode->i_sb->s_id,
 			 (long long)NFS_FILEID(inode), status);
+		if (status == -ESTALE)
+			nfs_invalidate_inode(inode);
 		goto out;
 	}
 	cache_validity = nfsi->cache_validity;
@@ -1355,6 +1357,8 @@ int nfs_refresh_inode(struct inode *inod
 		status = nfs_check_inode_attributes(inode, fattr);
 
 	spin_unlock(&inode->i_lock);
+	if (status == -ESTALE)
+		nfs_invalidate_inode(inode);
 	return status;
 }
 
@@ -1382,6 +1386,8 @@ int nfs_post_op_update_inode(struct inod
 	nfsi->cache_change_attribute = jiffies;
 out:
 	spin_unlock(&inode->i_lock);
+	if (status == -ESTALE)
+		nfs_invalidate_inode(inode);
 	return status;
 }
 
@@ -1528,12 +1534,6 @@ static int nfs_update_inode(struct inode
 	printk(KERN_DEBUG "%s: inode %ld mode changed, %07o to %07o\n",
 			__FUNCTION__, inode->i_ino, inode->i_mode, fattr->mode);
 #endif
-	/*
-	 * No need to worry about unhashing the dentry, as the
-	 * lookup validation will know that the inode is bad.
-	 * (But we fall through to invalidate the caches.)
-	 */
-	nfs_invalidate_inode(inode);
  out_err:
 	set_bit(NFS_INO_STALE, &NFS_FLAGS(inode));
 	return -ESTALE;

--------------030302050207000704010309--


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
