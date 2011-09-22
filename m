Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15150 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751741Ab1IVMqw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 08:46:52 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NFS4: Revert commit to make the automount code ignore
 LOOKUP_FOLLOW
To: miklos@szeredi.hu, raven@themaw.net, viro@ZenIV.linux.org.uk
Cc: dhowells@redhat.com, jlayton@redhat.com, gregkh@suse.de,
        torvalds@linux-foundation.org, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
Date: Thu, 22 Sep 2011 13:46:08 +0100
Message-ID: <20110922124608.7739.27750.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Revert the following change:

	commit 0ec26fd0698285b31248e34bf1abb022c00f23d6
	Author: Miklos Szeredi <mszeredi@suse.cz>
	Date:   Mon Sep 5 18:06:26 2011 +0200
	Subject: vfs: automount should ignore LOOKUP_FOLLOW

which makes stat(), getxattr(), etc. behave as lstat(), lgetxattr(), etc. with
respect to automounting: it prevents them from triggering terminal automounts.

The problem with this is that this breaks nfs_follow_remote_path() used by NFS4
to find the root object to mount for the mount() syscall.

This can be tested by the following procedure:

 (1) Export a directory from an NFS4 server that has something mounted upon it
     and that isn't "/" - say, for example, "/scratch".  It must have a
     different FSID from "/".

 (2) Mount this on the client.

	mount sirius:/scratch /mnt

 (3) List the contents of the client's mountpoint:

	ls /mnt

 (4) Examine /proc/fs/nfsfs/volumes.  You should see one entry (assuming
     nothing else is NFS mounted) :

	NV SERVER   PORT DEV     FSID              FSC
	v4 200108b001940000021125fffe84efad  801 0:34    1:0               no

     which corresponds to the filesystem mounted on /scratch on the server.

     If, however, you see two entries:

	NV SERVER   PORT DEV     FSID              FSC
	v4 200108b001940000021125fffe84efad  801 0:33    0:0               no
	v4 200108b001940000021125fffe84efad  801 0:34    1:0               no

     then it went wrong.

When it goes wrong, what happens is that nfs_follow_remote_path() walks from
the rootfh to the remote directory (/scratch) using vfs_path_lookup().  It
passes LOOKUP_FOLLOW to vfs_path_lookup() to tell it to transit terminal
symlinks and terminal automounts.  Unfortunately, with the aforementioned
commit, LOOKUP_FOLLOW now expressly does not follow terminal automounts.

There are some alternatives:

 (1) Fix up userspace to expect stat(), getxattr(), etc. to expect these to
     cause path-terminal automounting.  libacl and coreutils (ls) have been
     fixed up upstream already but there are other things such as GUI
     filemanagers.

 (2) Passing LOOKUP_DIRECTORY from nfs_follow_remote_path() to
     vfs_path_lookup() might work as presumably the mount root will be a
     directory.

 (3) Add a new flag, say LOOKUP_AUTOMOUNT, to force automounting.  This could
     be extended to userspace.

 (4) Add a new flag, say LOOKUP_GETTING_ATTRS, to indicate that we're doing a
     stat() or a getxattr() and suppress automounting on that basis.

Reported-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namei.c |   33 ++++++++++++++++++---------------
 1 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index f478836..c64b81d 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -727,22 +727,25 @@ static int follow_automount(struct path *path, unsigned flags,
 	if ((flags & LOOKUP_NO_AUTOMOUNT) && !(flags & LOOKUP_PARENT))
 		return -EISDIR; /* we actually want to stop here */
 
-	/* We don't want to mount if someone's just doing a stat -
-	 * unless they're stat'ing a directory and appended a '/' to
-	 * the name.
-	 *
-	 * We do, however, want to mount if someone wants to open or
-	 * create a file of any type under the mountpoint, wants to
-	 * traverse through the mountpoint or wants to open the
-	 * mounted directory.  Also, autofs may mark negative dentries
-	 * as being automount points.  These will need the attentions
-	 * of the daemon to instantiate them before they can be used.
+	/*
+	 * We don't want to mount if someone's just doing a stat and they've
+	 * set AT_SYMLINK_NOFOLLOW - unless they're stat'ing a directory and
+	 * appended a '/' to the name.
 	 */
-	if (!(flags & (LOOKUP_PARENT | LOOKUP_DIRECTORY |
-		     LOOKUP_OPEN | LOOKUP_CREATE)) &&
-	    path->dentry->d_inode)
-		return -EISDIR;
-
+	if (!(flags & LOOKUP_FOLLOW)) {
+		/* We do, however, want to mount if someone wants to open or
+		 * create a file of any type under the mountpoint, wants to
+		 * traverse through the mountpoint or wants to open the mounted
+		 * directory.
+		 * Also, autofs may mark negative dentries as being automount
+		 * points.  These will need the attentions of the daemon to
+		 * instantiate them before they can be used.
+		 */
+		if (!(flags & (LOOKUP_PARENT | LOOKUP_DIRECTORY |
+			     LOOKUP_OPEN | LOOKUP_CREATE)) &&
+		    path->dentry->d_inode)
+			return -EISDIR;
+	}
 	current->total_link_count++;
 	if (current->total_link_count >= 40)
 		return -ELOOP;

