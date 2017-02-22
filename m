Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38556 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752397AbdBVMq6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Feb 2017 07:46:58 -0500
Date: Wed, 22 Feb 2017 13:46:54 +0100
From: Jan Stancek <jstancek@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: dhowells@redhat.com, jstancek@redhat.com,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Subject: [bug] suspicious RCU usage nfs_idmap_get_key
Message-ID: <20170222124653.GA11726@dustball.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm running into following warning with 4.10 reliably (on ppc64le)
when I mount NFS volume (exported by RHEL6 system):

# mount rhel6-nfs:/export/home /mnt/rhel6-nfs
# mount
rhel6-nfs:/export/home on /mnt/rhel6-nfs type nfs4 (rw,relatime,vers=4.0,rsize=1048576,
wsize=1048576,namlen=255,hard,proto=tcp6,port=0,timeo=600,retrans=2,sec=sys,
clientaddr=REDACTED,local_lock=none,addr=REDACTED)

[   37.198383] FS-Cache: Loaded
[   37.411783] FS-Cache: Netfs 'nfs' registered for caching
[   37.444264] Key type dns_resolver registered
[   37.701588] NFS: Registering the id_resolver key type
[   37.701669] Key type id_resolver registered
[   37.701692] Key type id_legacy registered
[   38.046889] ===============================
[   38.046912] [ INFO: suspicious RCU usage. ]
[   38.046936] 4.10.0 #1 Tainted: G        W
[   38.046965] -------------------------------
[   38.046988] ./include/keys/user-type.h:53 suspicious rcu_dereference_protected() usage!
[   38.047030] other info that might help us debug this:
[   38.047074] rcu_scheduler_active = 2, debug_locks = 0
[   38.047111] 1 lock held by mount.nfs/5987:
[   38.047133]  #0:  (rcu_read_lock){......}, at: [<d000000002527abc>] nfs_idmap_get_key+0x15c/0x420 [nfsv4]
[   38.047203] stack backtrace:
[   38.047233] CPU: 1 PID: 5987 Comm: mount.nfs Tainted: G        W       4.10.0 #1
[   38.047276] Call Trace:
[   38.047295] [c0000000fef3ac80] [c000000000a18a08] dump_stack+0xe8/0x154 (unreliable)
[   38.047340] [c0000000fef3acc0] [c000000000159f80] lockdep_rcu_suspicious+0x140/0x190
[   38.047392] [c0000000fef3ad40] [d000000002527ce0] nfs_idmap_get_key+0x380/0x420 [nfsv4]
[   38.047444] [c0000000fef3adb0] [d0000000025287e0] nfs_map_name_to_uid+0x2a0/0x3b0 [nfsv4]
[   38.047496] [c0000000fef3ae30] [d00000000251897c] decode_getfattr_attrs+0xfac/0x16b0 [nfsv4]
[   38.047554] [c0000000fef3af30] [d00000000251913c] decode_getfattr_generic.constprop.106+0xbc/0x150 [nfsv4]
[   38.047612] [c0000000fef3afe0] [d000000002519b3c] nfs4_xdr_dec_lookup_root+0xac/0xb0 [nfsv4]
[   38.047674] [c0000000fef3b040] [d00000000656d928] rpcauth_unwrap_resp+0xe8/0x140 [sunrpc]
[   38.047725] [c0000000fef3b120] [d0000000065549ac] call_decode+0x29c/0x910 [sunrpc]
[   38.047777] [c0000000fef3b1c0] [d00000000656a370] __rpc_execute+0x140/0x8f0 [sunrpc]
[   38.047828] [c0000000fef3b2d0] [d000000006553420] rpc_run_task+0x170/0x200 [sunrpc]
[   38.047878] [c0000000fef3b330] [d0000000024f0cf8] nfs4_call_sync_sequence+0x68/0xa0 [nfsv4]
[   38.047928] [c0000000fef3b3c0] [d0000000024ff190] _nfs4_lookup_root.isra.44+0xd0/0xf0 [nfsv4]
[   38.047986] [c0000000fef3b490] [d000000002502390] nfs4_lookup_root+0xe0/0x350 [nfsv4]
[   38.048037] [c0000000fef3b550] [d000000002502670] nfs4_lookup_root_sec+0x70/0xa0 [nfsv4]
[   38.048087] [c0000000fef3b5a0] [d000000002502764] nfs4_find_root_sec+0xc4/0x100 [nfsv4]
[   38.048137] [c0000000fef3b5f0] [d000000002508b7c] nfs4_proc_get_rootfh+0x5c/0xf0 [nfsv4]
[   38.048189] [c0000000fef3b630] [d00000000252fe0c] nfs4_get_rootfh+0x6c/0x190 [nfsv4]
[   38.048241] [c0000000fef3b720] [d0000000025306a4] nfs4_server_common_setup+0xc4/0x260 [nfsv4]
[   38.048299] [c0000000fef3b7b0] [d000000002532bd8] nfs4_create_server+0x278/0x3c0 [nfsv4]
[   38.048352] [c0000000fef3b870] [d000000002522010] nfs4_remote_mount+0x50/0xb0 [nfsv4]
[   38.048397] [c0000000fef3b8b0] [c000000000377924] mount_fs+0x74/0x210
[   38.048435] [c0000000fef3b960] [c0000000003a2f68] vfs_kern_mount+0x78/0x220
[   38.048480] [c0000000fef3b9e0] [d000000002521e90] nfs_do_root_mount+0xb0/0x140 [nfsv4]
[   38.048531] [c0000000fef3ba70] [d000000002522540] nfs4_try_mount+0x60/0x100 [nfsv4]
[   38.048583] [c0000000fef3bb00] [d00000000532adfc] nfs_fs_mount+0x5ec/0xda0 [nfs]
[   38.048627] [c0000000fef3bbd0] [c000000000377924] mount_fs+0x74/0x210
[   38.048665] [c0000000fef3bc80] [c0000000003a2f68] vfs_kern_mount+0x78/0x220
[   38.048702] [c0000000fef3bd00] [c0000000003a8a34] do_mount+0x254/0xf70
[   38.048739] [c0000000fef3bde0] [c0000000003a9b74] SyS_mount+0x94/0x100
[   38.048777] [c0000000fef3be30] [c00000000000b390] system_call+0x38/0xe0

nfs_idmap_get_key
 user_key_payload
  rcu_dereference_key
   rcu_dereference_protected

rcu_dereference_protected comment says:
 * This function is only for update-side use.  Using this function
 * when protected only by rcu_read_lock() will result in infrequent
 * but very ugly failures.

Patch below makes it go away for me, but I'm not sure it's the correct way.

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index c444285bb1b1..a67d1c04ba40 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -309,7 +309,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
                goto out;
        }

-       rcu_read_lock();
+       down_read(&rkey->sem);
        rkey->perm |= KEY_USR_VIEW;

        ret = key_validate(rkey);
@@ -329,7 +329,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
                ret = -EINVAL;

 out_up:
-       rcu_read_unlock();
+       up_read(&rkey->sem);
        key_put(rkey);
 out:
        return ret;

Regards,
Jan
