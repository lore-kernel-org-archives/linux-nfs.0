From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/4] Documentation: update in-tree fs docs for new
	function
Date: Mon, 27 Aug 2007 13:27:44 -0400
Message-ID: <200708271727.l7RHRi42007270@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-cifs-client@lists.samba.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPiNK-0002nm-Be
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 10:27:42 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IPiNO-0005xN-HU
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 10:27:46 -0700
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

This updates the VFS docs under the Documentation/ directory to describe
the new killattr inode operation.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 Documentation/filesystems/Locking |    2 ++
 Documentation/filesystems/vfs.txt |    6 ++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index fe26cc9..ac377aa 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -51,6 +51,7 @@ ata *);
 	ssize_t (*getxattr) (struct dentry *, const char *, void *, size_t);
 	ssize_t (*listxattr) (struct dentry *, char *, size_t);
 	int (*removexattr) (struct dentry *, const char *);
+	void (*killattr) (struct dentry *, struct iattr *);
 
 locking rules:
 	all may block, none have BKL
@@ -74,6 +75,7 @@ setxattr:	yes
 getxattr:	no
 listxattr:	no
 removexattr:	yes
+killattr:	yes
 	Additionally, ->rmdir(), ->unlink() and ->rename() have ->i_mutex on
 victim.
 	cross-directory ->rename() has (per-superblock) ->s_vfs_rename_sem.
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 05a7b83..ca3a403 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -348,6 +348,7 @@ struct inode_operations {
 	ssize_t (*listxattr) (struct dentry *, char *, size_t);
 	int (*removexattr) (struct dentry *, const char *);
 	void (*truncate_range)(struct inode *, loff_t, loff_t);
+	void (*killattr)(struct dentry *, struct iattr *);
 };
 
 Again, all methods are called without any locks being held, unless
@@ -447,6 +448,11 @@ otherwise noted.
   truncate_range: a method provided by the underlying filesystem to truncate a
   	range of blocks , i.e. punch a hole somewhere in a file.
 
+  killattr: called by the VFS when a setuid/setgid inode is modified. This 
+	allows a filesystem to override the standard behavior and handle
+	the ATTR_KILL_SUID and ATTR_KILL_SGID bits in its own way. Should
+	only be defined if the standard method for clearing setuid/setgid
+	bits is not adequate for your filesystem.
 
 The Address Space Object
 ========================
-- 
1.5.2.1


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
