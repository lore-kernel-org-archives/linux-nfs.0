Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753552Ab3JKQRS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Oct 2013 12:17:18 -0400
Subject: [PATCH] KEYS: Fix a race between negating a key and reading the
 error set
To: jmorris@namei.org
From: David Howells <dhowells@redhat.com>
Cc: Scott Mayhew <smayhew@redhat.com>, keyrings@linux-nfs.org,
        Dave Wysochanski <dwysocha@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
Date: Fri, 11 Oct 2013 17:16:59 +0100
Message-ID: <20131011161659.15534.27955.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

key_reject_and_link() marking a key as negative and setting the error with
which it was negated races with keyring searches and other things that read
that error.

The fix is to switch the order in which the assignments are done in
key_reject_and_link() and to use memory barriers.

Kudos to Dave Wysochanski <dwysocha@redhat.com> and Scott Mayhew
<smayhew@redhat.com> for tracking this down.

This may be the cause of:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000070
IP: [<ffffffff81219011>] wait_for_key_construction+0x31/0x80
PGD c6b2c3067 PUD c59879067 PMD 0
Oops: 0000 [#1] SMP
last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
CPU 0
Modules linked in: ...

Pid: 13359, comm: amqzxma0 Not tainted 2.6.32-358.20.1.el6.x86_64 #1 IBM System x3650 M3 -[7945PSJ]-/00J6159
RIP: 0010:[<ffffffff81219011>] wait_for_key_construction+0x31/0x80
RSP: 0018:ffff880c6ab33758  EFLAGS: 00010246
RAX: ffffffff81219080 RBX: 0000000000000000 RCX: 0000000000000002
RDX: ffffffff81219060 RSI: 0000000000000000 RDI: 0000000000000000
RBP: ffff880c6ab33768 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffff880adfcbce40
R13: ffffffffa03afb84 R14: ffff880adfcbce40 R15: ffff880adfcbce43
FS:  00007f29b8042700(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000070 CR3: 0000000c613dc000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process amqzxma0 (pid: 13359, threadinfo ffff880c6ab32000, task ffff880c610deae0)
Stack:
 ffff880adfcbce40 0000000000000000 ffff880c6ab337b8 ffffffff81219695
<d> 0000000000000000 ffff880a000000d0 ffff880c6ab337a8 000000000000000f
<d> ffffffffa03afb93 000000000000000f ffff88186c7882c0 0000000000000014
Call Trace:
 [<ffffffff81219695>] request_key+0x65/0xa0
 [<ffffffffa03a0885>] nfs_idmap_request_key+0xc5/0x170 [nfs]
 [<ffffffffa03a0eb4>] nfs_idmap_lookup_id+0x34/0x80 [nfs]
 [<ffffffffa03a1255>] nfs_map_group_to_gid+0x75/0xa0 [nfs]
 [<ffffffffa039a9ad>] decode_getfattr_attrs+0xbdd/0xfb0 [nfs]
 [<ffffffff81057310>] ? __dequeue_entity+0x30/0x50
 [<ffffffff8100988e>] ? __switch_to+0x26e/0x320
 [<ffffffffa039ae03>] decode_getfattr+0x83/0xe0 [nfs]
 [<ffffffffa039b610>] ? nfs4_xdr_dec_getattr+0x0/0xa0 [nfs]
 [<ffffffffa039b69f>] nfs4_xdr_dec_getattr+0x8f/0xa0 [nfs]
 [<ffffffffa02dada4>] rpcauth_unwrap_resp+0x84/0xb0 [sunrpc]
 [<ffffffffa039b610>] ? nfs4_xdr_dec_getattr+0x0/0xa0 [nfs]
 [<ffffffffa02cf923>] call_decode+0x1b3/0x800 [sunrpc]
 [<ffffffff81096de0>] ? wake_bit_function+0x0/0x50
 [<ffffffffa02cf770>] ? call_decode+0x0/0x800 [sunrpc]
 [<ffffffffa02d99a7>] __rpc_execute+0x77/0x350 [sunrpc]
 [<ffffffff81096c67>] ? bit_waitqueue+0x17/0xd0
 [<ffffffffa02d9ce1>] rpc_execute+0x61/0xa0 [sunrpc]
 [<ffffffffa02d03a5>] rpc_run_task+0x75/0x90 [sunrpc]
 [<ffffffffa02d04c2>] rpc_call_sync+0x42/0x70 [sunrpc]
 [<ffffffffa038ff80>] _nfs4_call_sync+0x30/0x40 [nfs]
 [<ffffffffa038836c>] _nfs4_proc_getattr+0xac/0xc0 [nfs]
 [<ffffffff810aac87>] ? futex_wait+0x227/0x380
 [<ffffffffa038b856>] nfs4_proc_getattr+0x56/0x80 [nfs]
 [<ffffffffa0371403>] __nfs_revalidate_inode+0xe3/0x220 [nfs]
 [<ffffffffa037158e>] nfs_revalidate_mapping+0x4e/0x170 [nfs]
 [<ffffffffa036f147>] nfs_file_read+0x77/0x130 [nfs]
 [<ffffffff811811aa>] do_sync_read+0xfa/0x140
 [<ffffffff81096da0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8100bb8e>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff8100b9ce>] ? common_interrupt+0xe/0x13
 [<ffffffff81228ffb>] ? selinux_file_permission+0xfb/0x150
 [<ffffffff8121bed6>] ? security_file_permission+0x16/0x20
 [<ffffffff81181a95>] vfs_read+0xb5/0x1a0
 [<ffffffff81181bd1>] sys_read+0x51/0x90
 [<ffffffff810dc685>] ? __audit_syscall_exit+0x265/0x290
 [<ffffffff8100b072>] system_call_fastpath+0x16/0x1b

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Dave Wysochanski <dwysocha@redhat.com>
cc: Scott Mayhew <smayhew@redhat.com>
---

 security/keys/key.c         |    3 ++-
 security/keys/keyring.c     |    7 +++++--
 security/keys/request_key.c |    4 +++-
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/security/keys/key.c b/security/keys/key.c
index 8fb7c7b..eaa9f34 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -557,9 +557,10 @@ int key_reject_and_link(struct key *key,
 	if (!test_bit(KEY_FLAG_INSTANTIATED, &key->flags)) {
 		/* mark the key as being negatively instantiated */
 		atomic_inc(&key->user->nikeys);
+		key->type_data.reject_error = -error;
+		smp_wmb();
 		set_bit(KEY_FLAG_NEGATIVE, &key->flags);
 		set_bit(KEY_FLAG_INSTANTIATED, &key->flags);
-		key->type_data.reject_error = -error;
 		now = current_kernel_time();
 		key->expiry = now.tv_sec + timeout;
 		key_schedule_gc(key->expiry + key_gc_delay);
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 6ece7f2..d4cf442 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -371,9 +371,11 @@ key_ref_t keyring_search_aux(key_ref_t keyring_ref,
 			goto error_2;
 		if (key->expiry && now.tv_sec >= key->expiry)
 			goto error_2;
-		key_ref = ERR_PTR(key->type_data.reject_error);
-		if (kflags & (1 << KEY_FLAG_NEGATIVE))
+		if (kflags & (1 << KEY_FLAG_NEGATIVE)) {
+			smp_rmb();
+			key_ref = ERR_PTR(key->type_data.reject_error);
 			goto error_2;
+		}
 		goto found;
 	}
 
@@ -432,6 +434,7 @@ descend:
 
 		/* we set a different error code if we pass a negative key */
 		if (kflags & (1 << KEY_FLAG_NEGATIVE)) {
+			smp_rmb();
 			err = key->type_data.reject_error;
 			continue;
 		}
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index c411f9b..dc6f3be 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -592,8 +592,10 @@ int wait_for_key_construction(struct key *key, bool intr)
 			  intr ? TASK_INTERRUPTIBLE : TASK_UNINTERRUPTIBLE);
 	if (ret < 0)
 		return ret;
-	if (test_bit(KEY_FLAG_NEGATIVE, &key->flags))
+	if (test_bit(KEY_FLAG_NEGATIVE, &key->flags)) {
+		smp_rmb();
 		return key->type_data.reject_error;
+	}
 	return key_validate(key);
 }
 EXPORT_SYMBOL(wait_for_key_construction);

