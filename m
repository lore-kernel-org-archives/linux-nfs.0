From: NeilBrown <neilb@suse.de>
Subject: [PATCH 006 of 8] knfsd: exportfs: move acceptable check into
	find_acceptable_alias
Date: Tue, 15 May 2007 17:16:43 +1000
Message-ID: <1070515071643.16331@suse.de>
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
	id 1HnrH9-00043S-56
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 00:17:02 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HnrHB-0001Tl-8s
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 00:16:54 -0700
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

All callers of find_acceptable_alias check if the current dentry
is acceptable before looking for other acceptable aliases using
find_acceptable_alias.  Move the check into find_acceptable_alias
to make the code a little more dense and add a comment to
find_acceptable_alias that documents its intent.


Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/exportfs/expfs.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff .prev/fs/exportfs/expfs.c ./fs/exportfs/expfs.c
--- .prev/fs/exportfs/expfs.c	2007-05-14 11:15:37.000000000 +1000
+++ ./fs/exportfs/expfs.c	2007-05-14 11:15:46.000000000 +1000
@@ -37,6 +37,9 @@ static int exportfs_get_name(struct dent
 		return get_name(dir, name, child);
 }
 
+/*
+ * Check if the dentry or any of it's aliases is acceptable.
+ */
 static struct dentry *
 find_acceptable_alias(struct dentry *result,
 		int (*acceptable)(void *context, struct dentry *dentry),
@@ -44,6 +47,9 @@ find_acceptable_alias(struct dentry *res
 {
 	struct dentry *dentry, *toput = NULL;
 
+	if (acceptable(context, result))
+		return result;
+
 	spin_lock(&dcache_lock);
 	list_for_each_entry(dentry, &result->d_inode->i_dentry, d_alias) {
 		dget_locked(dentry);
@@ -126,9 +132,6 @@ find_exported_dentry(struct super_block 
 
 		target_dir = dget(result);
 	} else {
-		if (acceptable(context, result))
-			return result;
-
 		alias = find_acceptable_alias(result, acceptable, context);
 		if (alias)
 			return alias;
@@ -289,9 +292,6 @@ find_exported_dentry(struct super_block 
 		}
 	}
 	dput(target_dir);
-	/* now result is properly connected, it is our best bet */
-	if (acceptable(context, result))
-		return result;
 
 	alias = find_acceptable_alias(result, acceptable, context);
 	if (alias)

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
