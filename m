Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34127 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933455AbcJaBSG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Oct 2016 21:18:06 -0400
Received: by mail-qt0-f193.google.com with SMTP id l20so725183qta.1
        for <linux-nfs@vger.kernel.org>; Sun, 30 Oct 2016 18:18:06 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Subject: [PATCH] NFSv41: fix NULL dereference in nfs40_setup_sequence
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
From: Vitaliy Gusev <gusev.vitaliy@gmail.com>
Date: Mon, 31 Oct 2016 04:18:01 +0300
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Message-Id: <0A7143CE-0592-444D-BA53-9CBB33E4373F@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

During some tests I=E2=80=99ve seen nfs-client crashes. It was just =
reading file via NFSv4.1 protocol.=20

The panic message is below,  fixing patch is attached.

=E2=80=94=E2=80=94=E2=80=94
"BUG: unable to handle kernel NULL pointer dereference at =
0000000000000090
"IP: [<ffffffffb049eefc>] _raw_spin_lock+0xc/0x30
PGD 2a1c067 PUD 29e5067 PMD 0
Oops: 0002 [#1] SMP
CPU: 1 PID: 3573 Comm: kworker/1:0 Not tainted 4.8.0-26-generic =
#28-Ubuntu
Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop =
Reference Platform, BIOS 6.00 07/02/2015
Workqueue: rpciod rpc_async_schedule [sunrpc]
task: ffffa017cb534740 task.stack: ffffa01782b44000
RIP: 0010:[<ffffffffb049eefc>]  [<ffffffffb049eefc>] =
_raw_spin_lock+0xc/0x30N^
RSP: 0018:ffffa01782b47d48  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffa017c735d208 RCX: ffffa01783816c00
RDX: 0000000000000001 RSI: ffffa017c735d1e0 RDI: 0000000000000090
RBP: ffffa01782b47d78 R08: ffffa017cec58a00 R09: 0000000000000000
R10: 0000000000000000 R11: 000000b4098ed036 R12: ffffa01783816c00
R13: 0000000000000000 R14: 0000000000000090 R15: ffffa017c735d1e0
FS:  0000000000000000(0000) GS:ffffa017cec40000(0000) =
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000090 CR3: 0000000002a0c000 CR4: 00000000001406e0
Stack:
ffffffffc0836208 ffffa01783816c00 ffffffffc04c9070 ffffffffc04c9070
0000000000000000 ffffa01783816c40 ffffa01782b47d88 ffffffffc08362d0
ffffa01782b47d98 ffffffffc04c9089 ffffa01782b47e00 ffffffffc04cb6fd

Call Trace:
[<ffffffffc0836208>] ? nfs40_setup_sequence+0x48/0xe0 [nfsv4]
[<ffffffffc08362d0>] nfs4_open_confirm_prepare+0x30/0x40 [nfsv4]
[<ffffffffc04c9089>] rpc_prepare_task+0x19/0x20 [sunrpc]
[<ffffffffc04cb6fd>] __rpc_execute+0x8d/0x420 [sunrpc]
[<ffffffffc04cbaa2>] rpc_async_schedule+0x12/0x20 [sunrpc]
[<ffffffffafc9d61c>] process_one_work+0x1fc/0x4b0
[<ffffffffafc9d91b>] worker_thread+0x4b/0x500
[<ffffffffafca3c18>] kthread+0xd8/0xf0
[<ffffffffb049f29f>] ret_from_fork+0x1f/0x40
[<ffffffffafca3b40>] ? kthread_create_on_node+0x1e0/0x1e0
Code: 00 01 00 00 f0 0f c1 37 81 c6 00 01 00 00 40 84 f6 75 01 c3 55 48 =
89 e5 e8 e2 19 83 ff 5d c3 0f 1f 44 00 00 31 c0 ba 01 00 00 00 <f0> 0f =
b1 17 85 c0 75 01 c3 55 89 c6 48 89 e5 e8 c0 01 83 ff 66=20
"RIP  [<ffffffffb049eefc>] _raw_spin_lock+0xc/0x30

=E2=80=94=E2=80=94=E2=80=94

=46rom 1b5e4636c696a169f46b474de519f1d4d4f06277 Mon Sep 17 00:00:00 2001
From: Vitaliy Gusev <gusev.vitaliy@gmail.com>
Date: Mon, 31 Oct 2016 03:11:50 +0300
Subject: [PATCH] NFSv4.1: fix NULL dereference in nfs40_setup_sequence

If OPEN4 reply has set OPEN4_RESULT_CONFIRM flag in rflags, nfs4.1 =
client
calls pure NFSv4.0 function that shouldn't be used and this flags should
be ignored.

Signed-off-by: Vitaliy Gusev <gusev.vitaliy@gmail.com>
---
 fs/nfs/nfs4proc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a9dec32..054ce67 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2023,6 +2023,9 @@ static int _nfs4_proc_open_confirm(struct =
nfs4_opendata *data)
 	};
 	int status;
=20
+	if (server->nfs_client->cl_mvops->minor_version !=3D 0)
+		return 0;
+
 	nfs4_init_sequence(&data->c_arg.seq_args, &data->c_res.seq_res, =
1);
 	kref_get(&data->kref);
 	data->rpc_done =3D 0;
--=20
2.6.4





