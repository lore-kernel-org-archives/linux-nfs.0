From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Subject: [PATCH] NFS: fix /proc/sys oops after module removal
Date: Thu, 16 Aug 2007 12:00:42 +0900
Message-ID: <200708160300.AA00236@paprika.lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: moriai.satoshi@lab.ntt.co.jp, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILVcY-0005Z1-8a
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 20:02:11 -0700
Received: from tama55.ecl.ntt.co.jp ([129.60.39.103])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILVca-0006UQ-VZ
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 20:02:06 -0700
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

NFS client made without CONFIG_NFS_V4 option does not call
nfs_unregister_sysctl() when the module is unloaded, and
causes kernel oopses.  For instance, the oopses will occur
when accessing /proc/sys.

This fixes the problem.

Note that register_nfs_fs() requires no change in this regard.
It looks similar at the first glance, but written properly.

Signed-off-by: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
---
 fs/nfs/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b2a851c..e784310 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -345,8 +345,8 @@ void __exit unregister_nfs_fs(void)
 	unregister_shrinker(&acl_shrinker);
 #ifdef CONFIG_NFS_V4
 	unregister_filesystem(&nfs4_fs_type);
-	nfs_unregister_sysctl();
 #endif
+	nfs_unregister_sysctl();
 	unregister_filesystem(&nfs_fs_type);
 }
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
