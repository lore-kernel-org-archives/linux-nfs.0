Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42752 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934042AbdBVWyn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Feb 2017 17:54:43 -0500
From: Jan Stancek <jstancek@redhat.com>
To: dhowells@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        jstancek@redhat.com, bcodding@redhat.com, asavkov@redhat.com
Subject: [PATCH 2/2] NFS: use user_key_payload_rcu() in RCU read-side section
Date: Wed, 22 Feb 2017 23:54:27 +0100
Message-Id: <fbf3e64103887605323fca60a9049b26b691a391.1487802542.git.jstancek@redhat.com>
In-Reply-To: <cover.1487802542.git.jstancek@redhat.com>
References: <cover.1487802542.git.jstancek@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use RCU read-side accessor for key payload, as calling
user_key_payload() without semaphore held leads to
following warning:

  ===============================
  [ INFO: suspicious RCU usage. ]
  4.10.0 #1 Tainted: G        W
  -------------------------------
  ./include/keys/user-type.h:53 suspicious rcu_dereference_protected() usage!
  other info that might help us debug this:
  rcu_scheduler_active = 2, debug_locks = 0
  1 lock held by mount.nfs/5987:
    #0:  (rcu_read_lock){......}, at: [<d000000002527abc>] nfs_idmap_get_key+0x15c/0x420 [nfsv4]
  stack backtrace:
  CPU: 1 PID: 5987 Comm: mount.nfs Tainted: G        W       4.10.0 #1
  Call Trace:
    dump_stack+0xe8/0x154 (unreliable)
    lockdep_rcu_suspicious+0x140/0x190
    nfs_idmap_get_key+0x380/0x420 [nfsv4]
    nfs_map_name_to_uid+0x2a0/0x3b0 [nfsv4]
    decode_getfattr_attrs+0xfac/0x16b0 [nfsv4]
    decode_getfattr_generic.constprop.106+0xbc/0x150 [nfsv4]
    nfs4_xdr_dec_lookup_root+0xac/0xb0 [nfsv4]
    rpcauth_unwrap_resp+0xe8/0x140 [sunrpc]
    call_decode+0x29c/0x910 [sunrpc]
    __rpc_execute+0x140/0x8f0 [sunrpc]
    rpc_run_task+0x170/0x200 [sunrpc]
    nfs4_call_sync_sequence+0x68/0xa0 [nfsv4]
    _nfs4_lookup_root.isra.44+0xd0/0xf0 [nfsv4]
    nfs4_lookup_root+0xe0/0x350 [nfsv4]
    nfs4_lookup_root_sec+0x70/0xa0 [nfsv4]
    nfs4_find_root_sec+0xc4/0x100 [nfsv4]
    nfs4_proc_get_rootfh+0x5c/0xf0 [nfsv4]
    nfs4_get_rootfh+0x6c/0x190 [nfsv4]
    nfs4_server_common_setup+0xc4/0x260 [nfsv4]
    nfs4_create_server+0x278/0x3c0 [nfsv4]
    nfs4_remote_mount+0x50/0xb0 [nfsv4]
    mount_fs+0x74/0x210
    vfs_kern_mount+0x78/0x220
    nfs_do_root_mount+0xb0/0x140 [nfsv4]
    nfs4_try_mount+0x60/0x100 [nfsv4]
    nfs_fs_mount+0x5ec/0xda0 [nfs]
    mount_fs+0x74/0x210
    vfs_kern_mount+0x78/0x220
    do_mount+0x254/0xf70
    SyS_mount+0x94/0x100
    system_call+0x38/0xe0

Signed-off-by: Jan Stancek <jstancek@redhat.com>
---
 fs/nfs/nfs4idmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index c444285bb1b1..835c163f61af 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -316,7 +316,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 	if (ret < 0)
 		goto out_up;
 
-	payload = user_key_payload(rkey);
+	payload = user_key_payload_rcu(rkey);
 	if (IS_ERR_OR_NULL(payload)) {
 		ret = PTR_ERR(payload);
 		goto out_up;
-- 
1.8.3.1

