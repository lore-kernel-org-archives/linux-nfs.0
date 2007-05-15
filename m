From: NeilBrown <neilb@suse.de>
Subject: [PATCH 007 of 8] knfsd: exportfs: add find_disconnected_root
	helper
Date: Tue, 15 May 2007 17:16:50 +1000
Message-ID: <1070515071650.16345@suse.de>
References: <20070515170405.15621.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>,
	Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnrHF-00043X-D5
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 00:17:02 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HnrHH-0001UW-I5
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 00:17:00 -0700
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


From: Christoph Hellwig <hch@infradead.org>

Break the loop that finds the root of a disconnected subtree
into a helper of its own to make reading easier and
document the intent.


Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/exportfs/expfs.c |   39 +++++++++++++++++++++++----------------
 1 file changed, 23 insertions(+), 16 deletions(-)

diff .prev/fs/exportfs/expfs.c ./fs/exportfs/expfs.c
--- .prev/fs/exportfs/expfs.c	2007-05-14 11:15:46.000000000 +1000
+++ ./fs/exportfs/expfs.c	2007-05-14 11:15:51.000000000 +1000
@@ -70,6 +70,27 @@ find_acceptable_alias(struct dentry *res
 	return NULL;
 }
 
+/*
+ * Find root of a disconnected subtree and return a reference to it.
+ */
+static struct dentry *
+find_disconnected_root(struct dentry *dentry)
+{
+	dget(dentry);
+	spin_lock(&dentry->d_lock);
+	while (!IS_ROOT(dentry) &&
+	       (dentry->d_parent->d_flags & DCACHE_DISCONNECTED)) {
+		struct dentry *parent = dentry->d_parent;
+		dget(parent);
+		spin_unlock(&dentry->d_lock);
+		dput(dentry);
+		dentry = parent;
+		spin_lock(&dentry->d_lock);
+	}
+	spin_unlock(&dentry->d_lock);
+	return dentry;
+}
+
 /**
  * find_exported_dentry - helper routine to implement export_operations->decode_fh
  * @sb:		The &super_block identifying the filesystem
@@ -164,23 +185,9 @@ find_exported_dentry(struct super_block 
 	 * the noprogress counter.  If we go through the loop 10 times (2 is
 	 * probably enough) without getting anywhere, we just give up
 	 */
-	noprogress= 0;
+	noprogress = 0;
 	while (target_dir->d_flags & DCACHE_DISCONNECTED && noprogress++ < 10) {
-		struct dentry *pd = target_dir;
-
-		dget(pd);
-		spin_lock(&pd->d_lock);
-		while (!IS_ROOT(pd) &&
-				(pd->d_parent->d_flags&DCACHE_DISCONNECTED)) {
-			struct dentry *parent = pd->d_parent;
-
-			dget(parent);
-			spin_unlock(&pd->d_lock);
-			dput(pd);
-			pd = parent;
-			spin_lock(&pd->d_lock);
-		}
-		spin_unlock(&pd->d_lock);
+		struct dentry *pd = find_disconnected_root(target_dir);
 
 		if (!IS_ROOT(pd)) {
 			/* must have found a connected parent - great */

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
