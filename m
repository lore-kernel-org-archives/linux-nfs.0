Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:50790 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbbDAIYV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2015 04:24:21 -0400
From: Christoph Hellwig <hch@lst.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
        Cyril Brulebois <kibi@debian.org>
Subject: [PATCH 2/2] mount.nfs.man, nfs.man: Update distinction between fstypes
Date: Wed,  1 Apr 2015 10:23:44 +0200
Message-Id: <1427876624-28066-2-git-send-email-hch@lst.de>
In-Reply-To: <1427876624-28066-1-git-send-email-hch@lst.de>
References: <1427876624-28066-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>

---
 utils/mount/mount.nfs.man | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/utils/mount/mount.nfs.man b/utils/mount/mount.nfs.man
index 1a4561b..15a82d5 100644
--- a/utils/mount/mount.nfs.man
+++ b/utils/mount/mount.nfs.man
@@ -15,16 +15,20 @@ is meant to be used by the
 .BR mount (8)
 command for mounting NFS shares. This subcommand, however, can also be used as a standalone command with limited functionality.
 
-.BR mount.nfs4 
-is used for mounting NFSv4 file system, while 
-.BR mount.nfs 
-is used to mount NFS file systems versions 3 or 2.
 .I remotetarget 
 is a server share usually in the form of 
 .BR servername:/path/to/share.
 .I dir 
 is the directory on which the file system is to be mounted.
 
+Under Linux 2.6.32 and later kernel versions,
+.BR mount.nfs
+can mount all NFS file system versions.  Under earlier Linux kernel versions,
+.BR mount.nfs4
+must be used for mounting NFSv4 file systems while
+.BR mount.nfs
+must be used for NFSv3 and v2.
+
 .SH OPTIONS
 .TP
 .BI "\-r"
-- 
1.9.1

