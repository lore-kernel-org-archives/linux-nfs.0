From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS: Stop sillyname renames and unmounts from
	racing
Date: Thu, 08 Nov 2007 04:05:04 -0500
Message-ID: <4732D140.5030205@RedHat.com>
References: <472C56E5.1040901@RedHat.com>
	<20071105210636.2fc72e14.akpm@linux-foundation.org>
	<20071106051532.GA5397@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Alexander Viro <aviro@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iq3Op-0000QB-RG
	for nfs@lists.sourceforge.net; Thu, 08 Nov 2007 01:10:08 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iq3Ov-0004vO-7P
	for nfs@lists.sourceforge.net; Thu, 08 Nov 2007 01:10:13 -0800
In-Reply-To: <20071106051532.GA5397@devserv.devel.redhat.com>
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

Alexander Viro wrote:
> On Mon, Nov 05, 2007 at 09:06:36PM -0800, Andrew Morton wrote:
>>> Any objections to exporting the inode_lock spin lock?
>>> If so, how should modules _safely_ access the s_inode list?
> 
>> That's going to make hch unhappy.
> 
> That's going to make me just as unhappy, especially since it's pointless;
> instead of the entire sorry mess we should just bump sb->s_active to pin
> the superblock down (we know that it's active at that point, so it's just
> an atomic_inc(); no games with locking, etc., are needed) and call
> deactivate_super() on the way out.  And deactivate_super() is exported
> already.

Even though Al suggestion did indeed fix the race and was incredibility 
simple (adding two lines of code), it turns out calling deactivate_super()
from the rpciod kernel daemon is not good, since it can cause deadlocks 
with other async tasks.

Following a suggestion from Trond, I decided to go back to the original idea 
of using put_super, but keeping all the changes inside the NFS client code.

So the following patch adds an active/deactive mechanism to the 
nfs_server structure (very similar to the s_active/deactivate_super()
mechanism) that any async opt (in this case silly renames) can use
to stop unmount for occurring before they are finished. 

This means there is no need to expose any spin locks, no need for an
O(n2) search and all the changes are contained inside the 
NFS client code. 

steved.

[Note: I did make the proposed corrections to my email client, so 
hopefully space-stuffing will be fixed. ]

Author: Steve Dickson <steved@redhat.com>

    Added an active/deactive mechanism to the nfs_server structure
    allowing async operations to hold off umount until the
    operations are done.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 70587f3..2ecf726 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -593,6 +593,10 @@ static int nfs_init_server(struct nfs_server *server,
 	server->namelen  = data->namlen;
 	/* Create a client RPC handle for the NFSv3 ACL management interface */
 	nfs_init_server_aclclient(server);
+
+	init_waitqueue_head(&server->active_wq);
+	atomic_set(&server->active, 0);
+
 	dprintk("<-- nfs_init_server() = 0 [new %p]\n", clp);
 	return 0;
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index fa517ae..e07ac96 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -202,6 +202,7 @@ static int nfs_get_sb(struct file_system_type *, int, const char *, void *, stru
 static int nfs_xdev_get_sb(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static void nfs_kill_super(struct super_block *);
+static void nfs_put_super(struct super_block *);
 
 static struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -223,6 +224,7 @@ static const struct super_operations nfs_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
 	.write_inode	= nfs_write_inode,
+	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs_clear_inode,
 	.umount_begin	= nfs_umount_begin,
@@ -1767,6 +1769,17 @@ static void nfs4_kill_super(struct super_block *sb)
 	nfs_free_server(server);
 }
 
+static void nfs_put_super(struct super_block *sb)
+{
+	struct nfs_server *server = NFS_SB(sb);
+	/*
+	 * Make sure there are no outstanding ops to this server.
+	 * If so, wait for them to finish before allowing the
+	 * unmount to continue.
+	 */
+	wait_event(server->active_wq, atomic_read(&server->active) == 0);
+}
+
 /*
  * Clone an NFS4 server record on xdev traversal (FSID-change)
  */
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 233ad38..cf12a24 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -29,6 +29,7 @@ struct nfs_unlinkdata {
 static void
 nfs_free_unlinkdata(struct nfs_unlinkdata *data)
 {
+	nfs_sb_deactive(NFS_SERVER(data->dir));
 	iput(data->dir);
 	put_rpccred(data->cred);
 	kfree(data->args.name.name);
@@ -151,6 +152,7 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 		nfs_dec_sillycount(dir);
 		return 0;
 	}
+	nfs_sb_active(NFS_SERVER(dir));
 	data->args.fh = NFS_FH(dir);
 	nfs_fattr_init(&data->res.dir_attr);
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 0cac49b..6ef3af8 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -4,6 +4,8 @@
 #include <linux/list.h>
 #include <linux/backing-dev.h>
 
+#include <asm/atomic.h>
+
 struct nfs_iostats;
 
 /*
@@ -110,8 +112,23 @@ struct nfs_server {
 						   filesystem */
 #endif
 	void (*destroy)(struct nfs_server *);
+
+	atomic_t active; /* Keep trace of any activity to this server */
+	wait_queue_head_t active_wq;  /* Wait for any activity to stop  */
 };
 
+static inline void 
+nfs_sb_active(struct nfs_server *server)
+{
+	atomic_inc(&server->active);
+}
+static inline void 
+nfs_sb_deactive(struct nfs_server *server)
+{
+	if (atomic_dec_and_test(&server->active))
+		wake_up(&server->active_wq);
+}
+
 /* Server capabilities */
 #define NFS_CAP_READDIRPLUS	(1U << 0)
 #define NFS_CAP_HARDLINKS	(1U << 1)





 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
