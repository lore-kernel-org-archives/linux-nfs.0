From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 11 of 11 - exporting_doc_typos.patch
Date: Fri, 28 May 2004 14:37:31 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BTZ7b-0008Ev-AP@notabene.cse.unsw.edu.au>
References: <20040528143518.31534.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkYj-0006ka-Jb
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:02:25 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkYi-00039c-Qv
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:02:25 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb) (ident-user Debian-exim)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 28 May 2004 14:37:31 +1000
To: Andrew Morton <akpm@osdl.org>
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


Fix minor typos.



From: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

 ----------- Diffstat output ------------
 ./Documentation/filesystems/Exporting |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff ./Documentation/filesystems/Exporting~current~ ./Documentation/filesystems/Exporting
--- ./Documentation/filesystems/Exporting~current~	2004-05-28 14:27:26.000000000 +1000
+++ ./Documentation/filesystems/Exporting	2004-05-28 14:29:38.000000000 +1000
@@ -32,7 +32,7 @@ tree.  This means that if any filesystem
 all of the ancestors of that filesystem object are also in the dcache.
 As normal access is by filename this prefix is created naturally and
 maintained easily (by each object maintaining a reference count on
-it's parent).
+its parent).
 
 However when objects are included into the dcache by interpreting a
 filehandle fragment, there is no automatic creation of a path prefix
@@ -44,15 +44,15 @@ the dcache that are not needed for norma
 2/ The dcache must be prepared for a newly found (via ->lookup) directory
    to already have a (non-connected) dentry, and must be able to move
    that dentry into place (based on the parent and name in the
-   ->lookup).   This is particuarly needed for directories as
+   ->lookup).   This is particularly needed for directories as
    it is a dcache invariant that directories only have one dentry.
 
 To implement these features, the dcache has:
 
-a/ A dentry flag  DCACHE_DISCONNECTED which is set on
-   and dentry that might not be part of the proper prefix.
+a/ A dentry flag DCACHE_DISCONNECTED which is set on
+   any dentry that might not be part of the proper prefix.
    This is set when anonymous dentries are created, and cleared when a
-   dentry is noticed to be a child on a dentry which is in the proper
+   dentry is noticed to be a child of a dentry which is in the proper
    prefix. 
 
 b/ A per-superblock list "s_anon" of dentries which are the roots of
@@ -123,9 +123,9 @@ filesystem:
   get_name.  When given a parent dentry and a child dentry, this
     should find a name in the directory identified by the parent
     dentry, which leads to the object identified by the child dentry.
-    If no get_name function is supplied, a default implementation
-    which used vfs_readdir to find potential names, and matches inode
-    numbers to find the correct match.
+    If no get_name function is supplied, a default implementation is
+    provided which uses vfs_readdir to find potential names, and
+    matches inode numbers to find the correct match.
 
   get_parent.  When given a dentry for a directory, this should return 
     a dentry for the parent.  Quite possibly the parent dentry will
@@ -135,7 +135,7 @@ filesystem:
     ->lookup("..") is *not* used as a default as it can leave ".."
     entries in the dcache which are too messy to work with.
 
-  get_dentry.  When given a opaque datum, this should find the
+  get_dentry.  When given an opaque datum, this should find the
     implied object and create a dentry for it (possibly with
     d_alloc_anon). 
     The opaque datum is whatever is passed down by the decode_fh
@@ -143,7 +143,7 @@ filesystem:
     fragment.
     decode_fh passes two datums through find_exported_dentry.  One that 
     should be used to identify the target object, and one that can be
-    used to identify the objects parent, should that be necessary.
+    used to identify the object's parent, should that be necessary.
     The default get_dentry function assumes that the datum contains an
     inode number and a generation number, and it attempts to get the
     inode using "iget" and check it's validity by matching the
@@ -164,8 +164,8 @@ filehandle assuming the format used by t
 passed them to find_exported_dentry.
 
 
-A filehandle fragment consists of an array of 1 or more 4byte words.
-Together with a one byte "type".
+A filehandle fragment consists of an array of 1 or more 4byte words,
+together with a one byte "type".
 The decode_fh routine should not depend on the stated size that is
 passed to it.  This size may be larger than the original filehandle
 generated by encode_fh, in which case it will have been padded with


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
