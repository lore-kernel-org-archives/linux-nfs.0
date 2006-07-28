From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 2] knfsd: Have ext2 reject file handles with
	bad inode numbers early.
Date: Fri, 28 Jul 2006 10:31:25 +1000
Message-ID: <1060728003125.15210@suse.de>
References: <20060728102713.15132.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6GGx-0005VT-5L
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 17:32:11 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6GGw-0000u3-Lz
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 17:32:11 -0700
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


This prevents bad inode numbers from triggering errors in
ext2_get_inode.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/ext2/super.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff .prev/fs/ext2/super.c ./fs/ext2/super.c
--- .prev/fs/ext2/super.c	2006-07-28 10:12:55.000000000 +1000
+++ ./fs/ext2/super.c	2006-07-28 10:17:58.000000000 +1000
@@ -251,6 +251,46 @@ static struct super_operations ext2_sops
 #endif
 };
 
+static struct dentry *ext2_get_dentry(struct super_block *sb, void *vobjp)
+{
+	__u32 *objp = vobjp;
+	unsigned long ino = objp[0];
+	__u32 generation = objp[1];
+	struct inode *inode;
+	struct dentry *result;
+
+	if (ino != EXT2_ROOT_INO && ino < EXT2_FIRST_INO(sb))
+		return ERR_PTR(-ESTALE);
+	if (ino > le32_to_cpu(EXT2_SB(sb)->s_es->s_inodes_count))
+		return ERR_PTR(-ESTALE);
+
+	/* iget isn't really right if the inode is currently unallocated!!
+	 * ext2_read_inode currently does appropriate checks, but
+	 * it might be "neater" to call ext2_get_inode first and check
+	 * if the inode is valid.....
+	 */
+	inode = iget(sb, ino);
+	if (inode == NULL)
+		return ERR_PTR(-ENOMEM);
+	if (is_bad_inode(inode)
+	    || (generation && inode->i_generation != generation)
+		) {
+		/* we didn't find the right inode.. */
+		iput(inode);
+		return ERR_PTR(-ESTALE);
+	}
+	/* now to find a dentry.
+	 * If possible, get a well-connected one
+	 */
+	result = d_alloc_anon(inode);
+	if (!result) {
+		iput(inode);
+		return ERR_PTR(-ENOMEM);
+	}
+	return result;
+}
+
+
 /* Yes, most of these are left as NULL!!
  * A NULL value implies the default, which works with ext2-like file
  * systems, but can be improved upon.
@@ -258,6 +298,7 @@ static struct super_operations ext2_sops
  */
 static struct export_operations ext2_export_ops = {
 	.get_parent = ext2_get_parent,
+	.get_dentry = ext2_get_dentry,
 };
 
 static unsigned long get_sb_block(void **data)

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
