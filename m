Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:42034 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751918AbdEDVGD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 May 2017 17:06:03 -0400
Date: Thu, 4 May 2017 17:05:51 -0400
From: Dave Jones <davej@codemonkey.org.uk>
To: linux-nfs@vger.kernel.org
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Subject: NFS oops in encode_nfs4_verifier
Message-ID: <20170504210551.7havpdi7bxbzotcw@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Running v4.11-8118-g4ac4d584886a, I see this during boot on one of my
test machines during boot as it tries to mount two nfs mounts.

initcall init_nfs_v4+0x0/0x33 [nfsv4] returned 0 after 28480 usecs
calling  init_kerberos_module+0x0/0x1000 [rpcsec_gss_krb5] @ 721
initcall init_kerberos_module+0x0/0x1000 [rpcsec_gss_krb5] returned 0 after 61 usecs
NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO
NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO
Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
CPU: 1 PID: 121 Comm: kworker/1:2 Not tainted 4.11.0-think+ #7 
Workqueue: rpciod rpc_async_schedule [sunrpc]
task: ffff8804fd8c0040 task.stack: ffffc9000036c000
RIP: 0010:memcpy_erms+0x6/0x10
RSP: 0018:ffffc9000036faf8 EFLAGS: 00010282
RAX: ffff8804efc8c308 RBX: 0000000000000008 RCX: 0000000000000008
RDX: 0000000000000008 RSI: ffffc90000e2b940 RDI: ffff8804efc8c308
RBP: ffffc9000036fb20 R08: ffff8804ef1fbc28 R09: 0000000000000001
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000002 R14: ffff8804efc8c308 R15: ffff8804efc8c2f8
FS:  0000000000000000(0000) GS:ffff880507a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffc90000e2b940 CR3: 00000004faf74000 CR4: 00000000001406e0
Call Trace:
 ? xdr_encode_opaque_fixed+0x37/0x70 [sunrpc]
 ? encode_exchange_id+0x220/0x220 [nfsv4]
 encode_nfs4_verifier+0x2c/0x40 [nfsv4]
 encode_exchange_id+0x53/0x220 [nfsv4]
 ? init_object+0x69/0xa0
 ? mark_held_locks+0x76/0xa0
 ? xdr_reserve_space+0x1c/0x140 [sunrpc]
 ? encode_exchange_id+0x220/0x220 [nfsv4]
 nfs4_xdr_enc_exchange_id+0x7e/0xb0 [nfsv4]
 rpcauth_wrap_req+0xa7/0xe0 [sunrpc]
 call_transmit+0x1a5/0x2b0 [sunrpc]
 ? call_decode+0x810/0x810 [sunrpc]
 ? call_decode+0x810/0x810 [sunrpc]
 __rpc_execute+0xb4/0x5d0 [sunrpc]
 ? process_one_work+0x1c2/0x6c0
 rpc_async_schedule+0x12/0x20 [sunrpc]
 process_one_work+0x24d/0x6c0
 worker_thread+0x4e/0x3b0
 kthread+0x117/0x150
 ? process_one_work+0x6c0/0x6c0
 ? kthread_create_on_node+0x70/0x70
 ret_from_fork+0x2e/0x40
Code: 90 90 90 90 90 eb 1e 0f 1f 00 48 89 f8 48 89 d1 48 c1 e9 03 83 e2 07 f3 48 a5 89 d1 f3 a4 c3 66 0f 1f 44 00 00 48 89 f8 48 89 d1 <f3> a4 c3 0f 1f 80 00 00 00 00 48 89 f8 48 83 fa 20 72 7e 40 38 
RIP: memcpy_erms+0x6/0x10 RSP: ffffc9000036faf8
CR2: ffffc90000e2b940

