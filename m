From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [PATCH - Trivial] Documentation - NFSv3 & v4 can't both be "the
 newer version"
Date: Sun, 13 Jun 2004 20:04:38 +0200 (CEST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.56.0406131928370.5930@jjulnx.backbone.dif.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265236AbUFMSFe@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <nfs.lists.sourceforge.net>


In the kernel help for NFSv3 & NFSv4 client support both are listed as
"the newer version ... of the NFS protocol". Obviously both can't be the
newer version at the same time, so here's a patch to correct the text in
such a way that only v4 is listed as the newer version.
Patch is against 2.6.7-rc3 - please consider including it.


--- linux-2.6.7-rc3/fs/Kconfig-orig	2004-06-13 19:26:13.000000000 +0200
+++ linux-2.6.7-rc3/fs/Kconfig	2004-06-13 19:28:32.000000000 +0200
@@ -1363,8 +1363,8 @@ config NFS_V3
 	bool "Provide NFSv3 client support"
 	depends on NFS_FS
 	help
-	  Say Y here if you want your NFS client to be able to speak the newer
-	  version 3 of the NFS protocol.
+	  Say Y here if you want your NFS client to be able to speak version
+	  3 of the NFS protocol.

 	  If unsure, say Y.


--
Jesper Juhl <juhl-lkml@dif.dk>
