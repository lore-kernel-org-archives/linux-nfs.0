From: Art Haas <ahaas@airmail.net>
Subject: [PATCH] Fix C99 initializers in fs/nfs/nfs4proc.c
Date: Wed, 23 Apr 2003 10:17:42 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030423151742.GA5681@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@transmeta.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org, Kendrick Smith <kmsmith@umich.edu>,
	Andy Adamson <andros@umich.edu>, nfs@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

Hi.

Here's a small patch that fixes missing '=' characters from the
initializers. The patch is against the current BK.

Art Haas

===== fs/nfs/nfs4proc.c 1.20 vs edited =====
--- 1.20/fs/nfs/nfs4proc.c	Mon Apr  7 17:47:19 2003
+++ edited/fs/nfs/nfs4proc.c	Wed Apr 23 10:11:43 2003
@@ -572,10 +572,10 @@
 	u32                     f_bmres[2];
 	u32                     d_bmres[2];
 	struct nfs_fattr        d_attr = {
-		.valid          0,
+		.valid          = 0,
 	};
 	struct nfs_fattr        f_attr = {
-		.valid          0,
+		.valid          = 0,
 	};
 	struct nfs4_getattr     f_getattr = {
 		.gt_bmval       = nfs4_fattr_bitmap,
-- 
To announce that there must be no criticism of the President, or that we
are to stand by the President, right or wrong, is not only unpatriotic
and servile, but is morally treasonable to the American public.
 -- Theodore Roosevelt, Kansas City Star, 1918
