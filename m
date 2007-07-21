From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][23/37] Clean up duplicate includes in
	include/linux/nfs_fs.h
Date: Sat, 21 Jul 2007 17:03:28 +0200
Message-ID: <200707211703.28932.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jesper Juhl <jesper.juhl@gmail.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Rick Sladkey <jrs@world.std.com>, nfs@lists.sourceforge.net,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ICGVM-00075X-1i
	for nfs@lists.sourceforge.net; Sat, 21 Jul 2007 08:04:24 -0700
Received: from ug-out-1314.google.com ([66.249.92.171])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ICGVO-0004yk-J2
	for nfs@lists.sourceforge.net; Sat, 21 Jul 2007 08:04:27 -0700
Received: by ug-out-1314.google.com with SMTP id m2so1069717uge
	for <nfs@lists.sourceforge.net>; Sat, 21 Jul 2007 08:04:26 -0700 (PDT)
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

Hi,

This patch cleans up duplicate includes in
	include/linux/nfs_fs.h


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 9ba4aec..badc051 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -47,10 +47,8 @@
 #include <linux/nfs3.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_xdr.h>
-
 #include <linux/nfs_fs_sb.h>
 
-#include <linux/rwsem.h>
 #include <linux/mempool.h>
 
 /*

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
