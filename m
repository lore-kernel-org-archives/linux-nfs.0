From: Chip Salzenberg <chip@pobox.com>
Subject: [PATCH] 2.6.3-bk9: nfsd module needs locks_remove_posix()
Date: Fri, 27 Feb 2004 12:18:19 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040227171819.GA23518@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: nfs@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

2.6.3-bk9 is missing an export, patch below.

Also, does this new nfsd make the comments on locks_remove_posix()
obsolete, or maybe incomplete?  I couldn't tell.

--- x/fs/locks.c.old	2004-02-17 22:59:31.000000000 -0500
+++ x/fs/locks.c	2004-02-27 12:16:59.000000000 -0500
@@ -1700,4 +1700,6 @@
 }
 
+EXPORT_SYMBOL(locks_remove_posix);
+
 /*
  * This function is called on the last close of an open file.

-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K
