From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 8] knfsd: Close a race-opportunity in
	d_splice_alias
Date: Fri, 29 Sep 2006 13:08:58 +1000
Message-ID: <1060929030858.24062@suse.de>
References: <20060929130518.23919.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GT8kM-0007tM-Rg
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 20:09:06 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GT8kL-0005C9-UW
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 20:09:07 -0700
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


There is a possible race in d_splice_alias.
Though __d_find_alias(inode, 1) will only return a dentry
with DCACHE_DISCONNECTED set, it is possible for it to get cleared
before the BUG_ON, and it is is not possible to lock against that.

There are a couple of problems here.
Firstly, the code doesn't match the comment.  The comment describes
a 'disconnected' dentry as being IS_ROOT as well as DCACHE_DISCONNECTED,
however there is not testing of IS_ROOT anythere.

A dentry is marked DCACHE_DISCONNECTED when allocated with
d_alloc_anon, and remains DCACHE_DISCONNECTED while a path is built up
towards the root.  So a dentry can have a valid name and a valid
parent and even grandparent, but will still be DCACHE_DISCONNECTED
until a path to the root is created.  Once the path to the root is
complete, everything in the path gets DCACHE_DISCONNECTED cleared.  So
the fact that DCACHE_DISCONNECTED isn't enough to say that a dentry is
free to be spliced in with a given name.  This can only be allowed if
the dentry does not yet have a name, so the IS_ROOT test is needed too.

However even adding that test to __d_find_alias isn't enough.  As
d_splice_alias drops dcache_lock before calling d_move to perform the
splice, it could race with another thread calling d_splice_alias to
splice the inode in with a different name in a different part of the
tree (in the case where a file has hard links).  So that splicing code
is only really safe for directories (as we know that directories only
have one link).  For directories, the caller of d_splice_alias will be
holding i_mutex on the (unique) parent so there is no room for a race.

A consequence of this is that a non-directory will never benefit from
being spliced into a pre-exisiting dentry, but that isn't a problem.
It is perfectly OK for a non-directory to have multiple dentries, some
anonymous, some not.  And the comment for d_splice_alias says that it
only happens for directories anyway.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/dcache.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff .prev/fs/dcache.c ./fs/dcache.c
--- .prev/fs/dcache.c	2006-09-29 12:57:26.000000000 +1000
+++ ./fs/dcache.c	2006-09-29 12:57:34.000000000 +1000
@@ -291,9 +291,9 @@ struct dentry * dget_locked(struct dentr
  * it can be unhashed only if it has no children, or if it is the root
  * of a filesystem.
  *
- * If the inode has a DCACHE_DISCONNECTED alias, then prefer
+ * If the inode has an IS_ROOT, DCACHE_DISCONNECTED alias, then prefer
  * any other hashed alias over that one unless @want_discon is set,
- * in which case only return a DCACHE_DISCONNECTED alias.
+ * in which case only return an IS_ROOT, DCACHE_DISCONNECTED alias.
  */
 
 static struct dentry * __d_find_alias(struct inode *inode, int want_discon)
@@ -309,7 +309,8 @@ static struct dentry * __d_find_alias(st
 		prefetch(next);
 		alias = list_entry(tmp, struct dentry, d_alias);
  		if (S_ISDIR(inode->i_mode) || !d_unhashed(alias)) {
-			if (alias->d_flags & DCACHE_DISCONNECTED)
+			if (IS_ROOT(alias) &&
+			    (alias->d_flags & DCACHE_DISCONNECTED))
 				discon_alias = alias;
 			else if (!want_discon) {
 				__dget_locked(alias);
@@ -1134,7 +1135,7 @@ struct dentry *d_splice_alias(struct ino
 {
 	struct dentry *new = NULL;
 
-	if (inode) {
+	if (inode && S_ISDIR(inode->i_mode)) {
 		spin_lock(&dcache_lock);
 		new = __d_find_alias(inode, 1);
 		if (new) {

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
