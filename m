Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35914 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752214AbdEXMJz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 May 2017 08:09:55 -0400
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: kernel test robot <xiaolong.ye@intel.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFSv4.0: Fix a lock leak in nfs40_walk_client_list
Date: Wed, 24 May 2017 08:09:52 -0400
Message-Id: <20170524120952.14011-1-trond.myklebust@primarydata.com>
In-Reply-To: <20170524023629.GK1795@yexl-desktop>
References: <20170524023629.GK1795@yexl-desktop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Xiaolong Ye's kernel test robot detected the following Oops:
[  299.158991] BUG: scheduling while atomic: mount.nfs/9387/0x00000002
[  299.169587] 2 locks held by mount.nfs/9387:
[  299.176165]  #0:  (nfs_clid_init_mutex){......}, at: [<ffffffff8130cc92>] nfs4_discover_server_trunking+0x47/0x1fc
[  299.201802]  #1:  (&(&nn->nfs_client_lock)->rlock){......}, at: [<ffffffff813125fa>] nfs40_walk_client_list+0x2e9/0x338
[  299.221979] CPU: 0 PID: 9387 Comm: mount.nfs Not tainted 4.11.0-rc7-00021-g14d1bbb #45
[  299.235584] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
[  299.251176] Call Trace:
[  299.255192]  dump_stack+0x61/0x7e
[  299.260416]  __schedule_bug+0x65/0x74
[  299.266208]  __schedule+0x5d/0x87c
[  299.271883]  schedule+0x89/0x9a
[  299.276937]  schedule_timeout+0x232/0x289
[  299.283223]  ? detach_if_pending+0x10b/0x10b
[  299.289935]  schedule_timeout_uninterruptible+0x2a/0x2c
[  299.298266]  ? put_rpccred+0x3e/0x115
[  299.304327]  ? schedule_timeout_uninterruptible+0x2a/0x2c
[  299.312851]  msleep+0x1e/0x22
[  299.317612]  nfs4_discover_server_trunking+0x102/0x1fc
[  299.325644]  nfs4_init_client+0x13f/0x194

It looks as if we recently added a spin_lock() leak to
nfs40_walk_client_list() when cleaning up the code.

Reported-by: kernel test robot <xiaolong.ye@intel.com>
Fixes: 14d1bbb0ca42 ("NFS: Create a common nfs4_match_client() function")
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4client.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 692a7a8bfc7a..66776f022111 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -582,7 +582,6 @@ int nfs40_walk_client_list(struct nfs_client *new,
 			 */
 			nfs4_schedule_path_down_recovery(pos);
 		default:
-			spin_lock(&nn->nfs_client_lock);
 			goto out;
 		}
 
-- 
2.9.4

