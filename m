From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 8] knfsd: Add nfs-export support to tmpfs
Date: Fri, 29 Sep 2006 13:08:39 +1000
Message-ID: <1060929030839.24024@suse.de>
References: <20060929130518.23919.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GT8k3-0007oB-L8
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 20:08:47 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GT8k3-0001VC-Ft
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 20:08:48 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


We need to encode a decode the 'file' part of a handle.
We simply use the inode number and generation number to
construct the filehandle.
The generation number is the time when the file was created.
As inode numbers cycle through the full 32 bits before being
reused, there is no real chance of the same inum being allocated
to different files in the same second so this is suitably unique.
Using time-of-day rather than e.g. jiffies makes it less likely that
the same filehandle can be created after a reboot.

In order to be able to decode a filehandle we need to be able to
lookup by inum, which means that the inode needs to be added to the
inode hash table (tmpfs doesn't currently hash inodes as there is never
a need to lookup by inum).  To avoid overhead when not exporting,
we only hash an inode when it is first exported.  This requires a lock
to ensure it isn't hashed twice.

This code is separate from the patch posted in June06 from Atal
Shargorodsky which provided the same functionality, but does borrow
slightly from it.


From: "David M. Grimes" <dgrimes@navisite.com>
Cc: Atal Shargorodsky <atal@codefidence.com>
Cc: Gilad Ben-Yossef <gilad@codefidence.com>


Signed-off-by: David M. Grimes <dgrimes@navisite.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./mm/shmem.c |   67 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff .prev/mm/shmem.c ./mm/shmem.c
--- .prev/mm/shmem.c	2006-09-29 11:52:40.000000000 +1000
+++ ./mm/shmem.c	2006-09-29 11:52:44.000000000 +1000
@@ -1362,6 +1362,7 @@ shmem_get_inode(struct super_block *sb, 
 		inode->i_mapping->a_ops = &shmem_aops;
 		inode->i_mapping->backing_dev_info = &shmem_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_generation = get_seconds();
 		info = SHMEM_I(inode);
 		memset(info, 0, (char *)inode - (char *)info);
 		spin_lock_init(&info->lock);
@@ -1956,6 +1957,71 @@ static struct xattr_handler *shmem_xattr
 };
 #endif
 
+static struct dentry *shmem_get_parent(struct dentry *child)
+{
+	return ERR_PTR(-ESTALE);
+}
+
+static struct dentry *shmem_get_dentry(struct super_block *sb, void *vfh)
+{
+	struct dentry *de = NULL;
+	struct inode *inode;
+	__u32 *fh = vfh;
+
+	inode = ilookup(sb, (unsigned long)fh[0]);
+	if (inode) {
+		if (inode->i_generation == fh[1])
+			de = d_find_alias(inode);
+		iput(inode);
+	}
+
+	return de? de: ERR_PTR(-ESTALE);
+}
+
+static struct dentry *shmem_decode_fh(struct super_block *sb, __u32 *fh, int len, int type,
+				      int (*acceptable)(void *context, struct dentry *de),
+				      void *context)
+{
+	if (len < 2)
+		return ERR_PTR(-ESTALE);
+
+	return sb->s_export_op->find_exported_dentry(sb, fh, NULL, acceptable, context);
+}
+
+static int shmem_encode_fh(struct dentry *dentry, __u32 *fh, int *len, int connectable)
+{
+	struct inode *inode = dentry->d_inode;
+
+	if (*len < 2)
+		return 255;
+
+	if (hlist_unhashed(&inode->i_hash)) {
+		/* Unfortunately insert_inode_hash is not idempotent,
+		 * so as we hash inodes here rather than at creation
+		 * time, we need a lock to ensure we only try
+		 * to do it once
+		 */
+		static DEFINE_SPINLOCK(lock);
+		spin_lock(&lock);
+		if (hlist_unhashed(&inode->i_hash))
+			insert_inode_hash(inode);
+		spin_unlock(&lock);
+	}
+
+	fh[0] = inode->i_ino;
+	fh[1] = inode->i_generation;
+
+	*len = 2;
+	return 1;
+}
+
+static struct export_operations shmem_export_ops = {
+	.get_parent     = shmem_get_parent,
+	.get_dentry     = shmem_get_dentry,
+	.encode_fh      = shmem_encode_fh,
+	.decode_fh      = shmem_decode_fh,
+};
+
 static int shmem_parse_options(char *options, int *mode, uid_t *uid,
 	gid_t *gid, unsigned long *blocks, unsigned long *inodes,
 	int *policy, nodemask_t *policy_nodes)
@@ -2128,6 +2194,7 @@ static int shmem_fill_super(struct super
 					&inodes, &policy, &policy_nodes))
 			return -EINVAL;
 	}
+	sb->s_export_op = &shmem_export_ops;
 #else
 	sb->s_flags |= MS_NOUSER;
 #endif

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
