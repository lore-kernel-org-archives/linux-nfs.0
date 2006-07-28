From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 2] knfsd: Make ext3 reject filehandles
	referring to invalid inode numbers
Date: Fri, 28 Jul 2006 10:31:30 +1000
Message-ID: <1060728003130.15224@suse.de>
References: <20060728102713.15132.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6GH1-0005Vd-8C
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 17:32:15 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6GH0-0000x7-L2
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 17:32:15 -0700
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


Inodes earlier than the 'first' inode (e.g. journal,
resize) should be rejected early - except the root inode.
Also inode numbers that are too big should be rejected early.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/ext3/super.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff .prev/fs/ext3/super.c ./fs/ext3/super.c
--- .prev/fs/ext3/super.c	2006-07-28 10:18:55.000000000 +1000
+++ ./fs/ext3/super.c	2006-07-28 10:25:20.000000000 +1000
@@ -554,6 +554,48 @@ static int ext3_show_options(struct seq_
 	return 0;
 }
 
+
+static struct dentry *ext3_get_dentry(struct super_block *sb, void *vobjp)
+{
+	__u32 *objp = vobjp;
+	unsigned long ino = objp[0];
+	__u32 generation = objp[1];
+	struct inode *inode;
+	struct dentry *result;
+
+	if (ino != EXT3_ROOT_INO && ino < EXT3_FIRST_INO(sb))
+		return ERR_PTR(-ESTALE);
+	if (ino > le32_to_cpu(EXT3_SB(sb)->s_es->s_inodes_count))
+		return ERR_PTR(-ESTALE);
+
+	/* iget isn't really right if the inode is currently unallocated!!
+	 *
+	 * ext3_read_inode will return a bad_inode if the inode had been deleted.
+	 * so we should be safe.
+	 *
+	 * Currently we don't know the generation for parent directory, so
+	 * a generation of 0 means "accept any"
+	 */
+	inode = iget(sb, ino);
+	if (inode == NULL)
+		return ERR_PTR(-ENOMEM);
+	if (is_bad_inode(inode)
+	    || (generation && inode->i_generation != generation)
+		) {
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
 #ifdef CONFIG_QUOTA
 #define QTYPE2NAME(t) ((t)==USRQUOTA?"user":"group")
 #define QTYPE2MOPT(on, t) ((t)==USRQUOTA?((on)##USRJQUOTA):((on)##GRPJQUOTA))
@@ -622,6 +664,7 @@ static struct super_operations ext3_sops
 
 static struct export_operations ext3_export_ops = {
 	.get_parent = ext3_get_parent,
+	.get_dentry = ext3_get_dentry,
 };
 
 enum {

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
