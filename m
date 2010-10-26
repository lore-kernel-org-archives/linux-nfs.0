Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:57445 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab0JZP6v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Oct 2010 11:58:51 -0400
Received: by pxi15 with SMTP id 15so770937pxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Oct 2010 08:58:51 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] nfs(5): Document remount behavior
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 Oct 2010 11:58:47 -0400
Message-ID: <20101026155847.19184.44036.stgit@matisse.1015granger.net>
In-Reply-To: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
References: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

It appears that, for a long while, NFS "remount" mounts have
completely wiped the existing mount options in /etc/mtab for a given
mount point.  This is a problem for umount.nfs, since it reads its
options out of /etc/mtab to find out how to do the unmount.

The mount(8) command provides the NFS mount subcommand with the mount
options to perform the remount.  There are four cases to consider:

  1. Both the device and mount directory are specified on the
     command line, and the target mount point is in /etc/fstab

  2. Only one of the device and mount directory is specified on
     the command line, and the target mount point is in
     /etc/fstab

  3. Both the device and mount directory are specified on the
     command line, and the target mount point is not in /etc/fstab

  4. Only one of the device and mount directory is specified on
     the command line, and the target mount point is not in
     /etc/fstab

Currently only case 4 works correctly.  In that case, mount(8)
provides the correct set of mount options to the mount.nfs
subcommand and it can update /etc/mtab correctly.

Cases 1 and 3 replace all mount options in /etc/mtab with the options
provided on the command line during a remount.  Case 2 replaces the
mount options in /etc/mtab with a mix of options from /etc/fstab and
/etc/mtab.

Cases 1 and 3 are historical behavior.  Basically this is a formal
interface to allow administrators to replace the mount options in
/etc/mtab completely, instead of merging in new ones.  The present
patch documents that behavior in nfs(5), and provides best practice
for remounting NFS mount points.

There are near-term plans to address case 2 by fixing mount(8)
(provided by utils-linux-ng in most distributions).

This is a partial fix for:

  https://bugzilla.linux-nfs.org/show_bug.cgi?id=188

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   92 ++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 76 insertions(+), 16 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 1b86768..a357000 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1523,32 +1523,92 @@ of Access Control Lists that are semantically richer than POSIX ACLs.
 NFS version 4 ACLs are not fully compatible with POSIX ACLs; as such,
 some translation between the two is required
 in an environment that mixes POSIX ACLs and NFS version 4.
-.SH FILES
-.TP 1.5i
-.I /etc/fstab
-file system table
-.SH BUGS
-The generic
-.B remount
-option is not fully supported.
-Generic options, such as
-.BR rw " and " ro
-can be modified using the
-.B remount
-option,
-but NFS-specific options are not all supported.
+.SH "THE REMOUNT OPTION"
+Generic mount options such as
+.BR rw " and " sync
+can be modified on NFS mount points using the
+.BR remount
+option.
+See
+.BR mount (8)
+for more information on generic mount options.
+.P
+With few exceptions, NFS-specific options
+are not able to be modified during a remount.
 The underlying transport or NFS version
 cannot be changed by a remount, for example.
+.P
 Performing a remount on an NFS file system mounted with the
 .B noac
 option may have unintended consequences.
 The
 .B noac
-option is a mixture of a generic option,
+option is a combination of the generic option
 .BR sync ,
-and an NFS-specific option
+and the NFS-specific option
 .BR actimeo=0 .
+.SS "Unmounting after a remount"
+For NFS versions 2 and 3, the NFS umount subcommand
+depends on
+.I /etc/mtab
+to contain the mount options needed to send an UMNT request
+to the server.
+The NFS mount subcommand stores these mount options in
+.I /etc/mtab
+after a successful mount operation is complete.
+A remount can alter these stored mount options, however.
 .P
+When it comes to what is written back to
+.I /etc/mtab
+during a remount, the
+.BR mount (8)
+command has two different modes of operation.
+One mode
+.I merges
+the command line mount options with the mount
+options already in
+.IR /etc/mtab ,
+and the other
+.I replaces
+the mount options in
+.I /etc/mtab
+with the command line mount options.
+.P
+To
+.I replace
+the mount options that are in
+.IR /etc/mtab ,
+specify both the server hostname and export path, and the
+local mount directory during a remount.
+To
+.I merge
+the mount options on the command line with
+the options already in
+.IR /etc/mtab ,
+specify either the local mount directory, or the server
+hostname and export pathname, but not both.  For example,
+.P
+.NF
+.TA 2.5i
+	mount -o remount,ro /mnt
+.FI
+.P
+merges the mount option
+.B ro
+with the mount options already in
+.I /etc/mtab
+for the NFS server mounted at /mnt.
+Merging is almost always the desired outcome, as it preserves the
+ability of the client to contact the server when it comes time
+to send an UMNT request.
+.SH FILES
+.TP 1.5i
+.I /etc/fstab
+file system table
+.TP 1.5i
+.I /etc/mtab
+table of mounted file systems
+.SH BUGS
 Before 2.4.7, the Linux NFS client did not support NFS over TCP.
 .P
 Before 2.4.20, the Linux NFS client used a heuristic

