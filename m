From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd ] Fix d_find_alias brokenness
Date: Fri, 12 Nov 2004 10:57:16 +1100
Message-ID: <E1CSOoW-0006Mv-OF@notabene.cse.unsw.edu.au>
References: <20041112105449.24459.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CSOmG-0001IH-HK
	for nfs@lists.sourceforge.net; Thu, 11 Nov 2004 15:54:56 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CSOmF-0003jT-Ma
	for nfs@lists.sourceforge.net; Thu, 11 Nov 2004 15:54:56 -0800
To: Andrew Morton <akpm@osdl.org>
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

Hi Andrew,
 it wold be great if this could get into 2.6.10 as it fixed a very noticable 
problem with knfsd.

Thanks,
NeilBrown

### Comments for Changeset
A recent change to d_alloc_anon was a little broken, and needs 
a small change to d_find_alias to fix it.

Without this, a dcache flush on the server can cause stale file handles on the client.

Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/dcache.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff ./fs/dcache.c~current~ ./fs/dcache.c
--- ./fs/dcache.c~current~	2004-11-11 09:55:18.000000000 +1100
+++ ./fs/dcache.c	2004-11-11 09:55:18.000000000 +1100
@@ -279,14 +279,18 @@ struct dentry * dget_locked(struct dentr
 /**
  * d_find_alias - grab a hashed alias of inode
  * @inode: inode in question
+ * @want_discon:  flag, used by d_splice_alias, to request 
+ *          that only a DISCONNECTED alias be returned.
  *
- * If inode has a hashed alias - acquire the reference to alias and
- * return it. Otherwise return NULL. Notice that if inode is a directory
- * there can be only one alias and it can be unhashed only if it has
- * no children.
+ * If inode has a hashed alias, or is a directory and has any alias,
+ * acquire the reference to alias and return it. Otherwise return NULL.
+ * Notice that if inode is a directory there can be only one alias and
+ * it can be unhashed only if it has no children, or if it is the root 
+ * of a filesystem.
  *
  * If the inode has a DCACHE_DISCONNECTED alias, then prefer
- * any other hashed alias over that one.
+ * any other hashed alias over that one unless @want_discon is set,
+ * in which case only return a DCACHE_DISCONNECTED alias.
  */
 
 static struct dentry * __d_find_alias(struct inode *inode, int want_discon)
@@ -301,7 +305,7 @@ static struct dentry * __d_find_alias(st
 		next = tmp->next;
 		prefetch(next);
 		alias = list_entry(tmp, struct dentry, d_alias);
- 		if (!d_unhashed(alias)) {
+ 		if (S_ISDIR(inode->i_mode) || !d_unhashed(alias)) {
 			if (alias->d_flags & DCACHE_DISCONNECTED)
 				discon_alias = alias;
 			else if (!want_discon) {


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
