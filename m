Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36529 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516AbbDXLEw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:04:52 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 01/45] vfs: Minor documentation fix
Date: Fri, 24 Apr 2015 13:03:58 +0200
Message-Id: <69034f0a599970bcf25845d36f4cefcfb97255bc.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The check_acl inode operation and the IPERM_FLAG_RCU are long gone.
Document what get_acl does instead.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 Documentation/filesystems/porting | 8 ++++----
 Documentation/filesystems/vfs.txt | 3 +++
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
index fa2db08..d6f9ab4 100644
--- a/Documentation/filesystems/porting
+++ b/Documentation/filesystems/porting
@@ -379,10 +379,10 @@ may now be called in rcu-walk mode (nd->flags & LOOKUP_RCU). -ECHILD should be
 returned if the filesystem cannot handle rcu-walk. See
 Documentation/filesystems/vfs.txt for more details.
 
-	permission and check_acl are inode permission checks that are called
-on many or all directory inodes on the way down a path walk (to check for
-exec permission). These must now be rcu-walk aware (flags & IPERM_FLAG_RCU).
-See Documentation/filesystems/vfs.txt for more details.
+	permission is an inode permission check that is called on many or all
+directory inodes on the way down a path walk (to check for exec permission). It
+must now be rcu-walk aware (mask & MAY_NOT_BLOCK).  See
+Documentation/filesystems/vfs.txt for more details.
  
 --
 [mandatory]
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 966b228..700cdf6 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -457,6 +457,9 @@ otherwise noted.
 	If a situation is encountered that rcu-walk cannot handle, return
 	-ECHILD and it will be called again in ref-walk mode.
 
+  get_acl: called by the VFS to get the posix acl of an inode. Called during
+	permission checks. The returned acl is cached in the inode.
+
   setattr: called by the VFS to set attributes for a file. This method
   	is called by chmod(2) and related system calls.
 
-- 
2.1.0

