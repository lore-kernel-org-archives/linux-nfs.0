Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.icteam.com ([80.76.69.28]:40752 "EHLO smtp02.icteam.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313AbbDQKfb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Apr 2015 06:35:31 -0400
From: Giuseppe Cantavenera <giuseppe.cantavenera.ext@nokia.com>
To: linux-nfs@vger.kernel.org
Cc: alexander.sverdlin@nokia.com, bfields@fieldses.org,
        Giuseppe Cantavenera <giuseppe.cantavenera.ext@nokia.com>,
        Lorenzo Restelli <lorenzo.restelli.ext@nokia.com>
Subject: [PATCH] nfsd: fix: prevent BUG_ON registering rpc_pipefs_event for notifications only after nfsd_net_id is valid
Date: Fri, 17 Apr 2015 12:25:31 +0200
Message-Id: <1429266331-2408-1-git-send-email-giuseppe.cantavenera.ext@nokia.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd triggered a BUG_ON in net_generic(...) when rpc_pipefs_event(...)
in fs/nfsd/nfs4recover.c was called before assigning ntfsd_net_id.
The following was observed on a MIPS 32-core processor:
kernel: Call Trace:
kernel: [<ffffffffc00bc5e4>] rpc_pipefs_event+0x7c/0x158 [nfsd]
kernel: [<ffffffff8017a2a0>] notifier_call_chain+0x70/0xb8
kernel: [<ffffffff8017a4e4>] __blocking_notifier_call_chain+0x4c/0x70
kernel: [<ffffffff8053aff8>] rpc_fill_super+0xf8/0x1a0
kernel: [<ffffffff8022204c>] mount_ns+0xb4/0xf0
kernel: [<ffffffff80222b48>] mount_fs+0x50/0x1f8
kernel: [<ffffffff8023dc00>] vfs_kern_mount+0x58/0xf0
kernel: [<ffffffff802404ac>] do_mount+0x27c/0xa28
kernel: [<ffffffff80240cf0>] SyS_mount+0x98/0xe8
kernel: [<ffffffff80135d24>] handle_sys64+0x44/0x68
kernel:
kernel:
        Code: 0040f809  00000000  2e020001 <00020336> 3c12c00d  3c02801a  de100000  6442eb98  0040f809
kernel: ---[ end trace 7471374335809536 ]---

Fixed this behaviour by calling register_pernet_subsys(&nfsd_net_ops) before
registering rpc_pipefs_event(...) with the notifier chain.

Signed-off-by: Giuseppe Cantavenera <giuseppe.cantavenera.ext@nokia.com>
Signed-off-by: Lorenzo Restelli <lorenzo.restelli.ext@nokia.com>
---
 fs/nfsd/nfsctl.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f34d9de..3ee92a4 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1170,15 +1170,15 @@ static int __init init_nfsd(void)
 	int retval;
 	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
 
-	retval = register_cld_notifier();
-	if (retval)
-		return retval;
 	retval = register_pernet_subsys(&nfsd_net_ops);
 	if (retval < 0)
-		goto out_unregister_notifier;
-	retval = nfsd4_init_slabs();
+		return retval;
+	retval = register_cld_notifier();
 	if (retval)
 		goto out_unregister_pernet;
+	retval = nfsd4_init_slabs();
+	if (retval)
+		goto out_unregister_notifier;
 	nfs4_state_init();
 	retval = nfsd_fault_inject_init(); /* nfsd fault injection controls */
 	if (retval)
@@ -1206,10 +1206,10 @@ out_free_stat:
 	nfsd_fault_inject_cleanup();
 out_free_slabs:
 	nfsd4_free_slabs();
-out_unregister_pernet:
-	unregister_pernet_subsys(&nfsd_net_ops);
 out_unregister_notifier:
 	unregister_cld_notifier();
+out_unregister_pernet:
+	unregister_pernet_subsys(&nfsd_net_ops);
 	return retval;
 }
 
@@ -1223,8 +1223,8 @@ static void __exit exit_nfsd(void)
 	nfsd4_free_slabs();
 	nfsd_fault_inject_cleanup();
 	unregister_filesystem(&nfsd_fs_type);
-	unregister_pernet_subsys(&nfsd_net_ops);
 	unregister_cld_notifier();
+	unregister_pernet_subsys(&nfsd_net_ops);
 }
 
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
-- 
1.9.1

