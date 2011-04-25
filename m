Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37557 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758696Ab1DYSno (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 14:43:44 -0400
Received: by mail-iw0-f174.google.com with SMTP id 34so2050043iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2011 11:43:44 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/15] SUNRPC: Address a lockdep splat in sunrpc.ko
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2011 14:43:41 -0400
Message-ID: <20110425184341.5669.98002.stgit@matisse.1015granger.net>
In-Reply-To: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
References: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

===================================================
[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
/home/cel/src/linux/nfs-2.6/net/sunrpc/clnt.c:552 invoked rcu_dereference_check() without protection!

 other info that might help us debug this:


 rcu_scheduler_active = 1, debug_locks = 0
 no locks held by mount.nfs/2567.

 stack backtrace:
 Pid: 2567, comm: mount.nfs Not tainted 2.6.39-rc4-00046-gbf405aa #3
 Call Trace:
 [<ffffffff8107c45b>] lockdep_rcu_dereference+0xaa/0xb2
 [<ffffffffa028e384>] rpc_free_client+0x11c/0x136 [sunrpc]
 [<ffffffffa028e42b>] rpc_release_client+0x8d/0x91 [sunrpc]
 [<ffffffffa028e84e>] rpc_shutdown_client+0x117/0x126 [sunrpc]
 [<ffffffffa0304fa8>] nfs_free_server+0x6d/0xc1 [nfs]
 [<ffffffffa030fa70>] nfs4_kill_super+0x4c/0x6f [nfs]
 [<ffffffff81123941>] deactivate_locked_super+0x26/0x4b
 [<ffffffff81124396>] deactivate_super+0x45/0x4b
 [<ffffffff8113ae79>] mntput_no_expire+0x105/0x10e
 [<ffffffff8113aea8>] mntput+0x26/0x28
 [<ffffffff8113b09d>] release_mounts+0x61/0x73
 [<ffffffff8113b110>] put_mnt_ns+0x61/0x71
 [<ffffffffa030f82f>] nfs_follow_remote_path+0x1cd/0x252 [nfs]
 [<ffffffffa030f9dc>] nfs4_try_mount+0x77/0xbf [nfs]
 [<ffffffffa0310c4c>] nfs_fs_mount+0x4a6/0x6fe [nfs]
 [<ffffffff81123b58>] mount_fs+0x70/0x157
 [<ffffffff810f2202>] ?  __alloc_percpu+0x10/0x12
 [<ffffffff8113a546>] vfs_kern_mount+0x65/0xa0
 [<ffffffff8113aef7>] do_kern_mount+0x4d/0xdd
 [<ffffffff8113bd32>] do_mount+0x6bd/0x720
 [<ffffffff8113be1d>] sys_mount+0x88/0xc2
 [<ffffffff814974c2>] system_call_fastpath+0x16/0x1b

Commit cf8bebc9 "SUNRPC: Use RCU to dereference the rpc_client cl_xprt
structure" seems to have introduced this.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2d4f8c5..0541a35 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -549,7 +549,9 @@ out_free:
 	rpc_free_iostats(clnt->cl_metrics);
 	kfree(clnt->cl_principal);
 	clnt->cl_metrics = NULL;
+	rcu_read_lock();
 	xprt_put(rcu_dereference(clnt->cl_xprt));
+	rcu_read_unlock();
 	rpciod_down();
 	kfree(clnt);
 }

