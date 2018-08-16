Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34350 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728737AbeHPSUS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Aug 2018 14:20:18 -0400
Date: Thu, 16 Aug 2018 11:21:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] lock maintainers won't be much help with fcntl issues
Message-ID: <20180816152110.GP7906@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Most of the stuff in fcntl.c has nothing to do with locks.  The stuff
that does have anything to do with locks is pretty trivial glue code
that calls into locks.c for the real work.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 MAINTAINERS | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9d5eeff51b5f..a5dca2be8513 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5541,9 +5541,6 @@ M:	Jeff Layton <jlayton@kernel.org>
 M:	"J. Bruce Fields" <bfields@fieldses.org>
 L:	linux-fsdevel@vger.kernel.org
 S:	Maintained
-F:	include/linux/fcntl.h
-F:	include/uapi/linux/fcntl.h
-F:	fs/fcntl.c
 F:	fs/locks.c
 
 FILESYSTEMS (VFS and infrastructure)
-- 
2.17.1
