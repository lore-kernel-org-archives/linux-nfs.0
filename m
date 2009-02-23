From: "Sachin S. Prabhu" <sprabhu@redhat.com>
Subject: [PATCH] Inconsistent setattr behaviour
Date: Mon, 23 Feb 2009 16:22:03 +0000
Message-ID: <49A2CD2B.50607@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090200040203010700090200"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54962 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758AbZBWQWG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Feb 2009 11:22:06 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n1NGM4gt027743
	for <linux-nfs@vger.kernel.org>; Mon, 23 Feb 2009 11:22:04 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n1NGM4fB012462
	for <linux-nfs@vger.kernel.org>; Mon, 23 Feb 2009 11:22:04 -0500
Received: from localhost.localdomain (splp.fab.redhat.com [10.33.0.53])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n1NGM362006575
	for <linux-nfs@vger.kernel.org>; Mon, 23 Feb 2009 11:22:04 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090200040203010700090200
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

There is an inconsistency seen in the behaviour of nfs compared to other local
filesystems on linux when changing owner or group of a directory. If the
directory has SUID/SGID flags set, on changing owner or group on the directory,
the flags are stripped off on nfs. These flags are maintained on other
filesystems such as ext3.

To reproduce on a nfs share or local filesystem, run the following commands
mkdir test; chmod +s+g test; chown user1 test; ls -ld test

On the nfs share, the flags are stripped and the output seen is
drwxr-xr-x 2 user1 root 4096 Feb 23  2009 test

On other local filesystems(ex: ext3), the flags are not stripped and the output
seen is
drwsr-sr-x 2 user1 root 4096 Feb 23 13:57 test

chown_common() called from sys_chown() will only strip the flags if the inode is
not a directory.
static int chown_common(struct dentry * dentry, uid_t user, gid_t group)
{
..
        if (!S_ISDIR(inode->i_mode))
                newattrs.ia_valid |=
                        ATTR_KILL_SUID | ATTR_KILL_SGID | ATTR_KILL_PRIV;
..
}

See: http://www.opengroup.org/onlinepubs/7990989775/xsh/chown.html

"If the path argument refers to a regular file, the set-user-ID (S_ISUID) and
set-group-ID (S_ISGID) bits of the file mode are cleared upon successful return
from chown(), unless the call is made by a process with appropriate privileges,
in which case it is implementation-dependent whether these bits are altered. If
chown() is successfully invoked on a file that is not a regular file, these
bits may be cleared. These bits are defined in <sys/stat.h>."

The behaviour as it stands does not appear to violate POSIX.  However the
actions performed are inconsistent when comparing ext3 and nfs.

Sachin Prabhu

--------------090200040203010700090200
Content-Type: text/plain;
 name="do_not_strip_sguid_for_directories.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="do_not_strip_sguid_for_directories.patch"

Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
Acked-by: Jeff Layton <jlayton@redhat.com>
--- linux-2.6.29-rc2/fs/nfsd/vfs.c.orig	2009-02-23 06:45:20.000000000 -0500
+++ linux-2.6.29-rc2/fs/nfsd/vfs.c	2009-02-23 11:10:10.000000000 -0500
@@ -366,8 +366,9 @@
 	}
 
 	/* Revoke setuid/setgid on chown */
-	if (((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid) ||
-	    ((iap->ia_valid & ATTR_GID) && iap->ia_gid != inode->i_gid)) {
+	if (!S_ISDIR(inode->i_mode) &&
+	    (((iap->ia_valid & ATTR_UID) && iap->ia_uid != inode->i_uid) ||
+	     ((iap->ia_valid & ATTR_GID) && iap->ia_gid != inode->i_gid))) {
 		iap->ia_valid |= ATTR_KILL_PRIV;
 		if (iap->ia_valid & ATTR_MODE) {
 			/* we're setting mode too, just clear the s*id bits */

--------------090200040203010700090200--
