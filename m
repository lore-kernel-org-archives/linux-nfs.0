Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:43330 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750995AbbJSQdg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Oct 2015 12:33:36 -0400
Date: Mon, 19 Oct 2015 18:33:32 +0200
From: William Dauchy <william@gandi.net>
To: linux-fsdevel@vger.kernel.org
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Jeff Layton <jeff.layton@primarydata.com>
Subject: locks_get_lock_context null deref
Message-ID: <20151019163332.GI10696@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WHz+neNWvhIGAO8A"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--WHz+neNWvhIGAO8A
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

I am getting the following null deref on locks_get_lock_context using a v4.=
1.x
(x86_64) while using the nfs client v4.0.

Any hint to help debug that issue?


BUG: unable to handle kernel NULL pointer dereference at 00000000000001c8
IP: [<ffffffff811d0cf3>] locks_get_lock_context+0x3/0xc0
PGD 0=20
Oops: 0000 [#1] SMP=20
CPU: 1 PID: 1773 Comm: kworker/1:1H Not tainted 4.1.11-rc1 #1
Workqueue: rpciod ffffffff8164fff0
task: ffff8810374deba0 ti: ffff8810374df150 task.ti: ffff8810374df150
RIP: 0010:[<ffffffff811d0cf3>]  [<ffffffff811d0cf3>] locks_get_lock_context=
+0x3/0xc0
RSP: 0000:ffff881036007bb0  EFLAGS: 00010246
RAX: ffff881036007c30 RBX: ffff881001981880 RCX: 0000000000000002
RDX: 00000000000006ed RSI: 0000000000000002 RDI: 0000000000000000
RBP: ffff881036007c08 R08: 0000000000000000 R09: 0000000000000001
R10: 0000000000000000 R11: ffff88101db69948 R12: ffff8810019818d8
R13: ffff881036007bc8 R14: ffff880e225d81c0 R15: ffff881edfd2b400
FS:  0000000000000000(0000) GS:ffff88103fc20000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000000001c8 CR3: 000000000169b000 CR4: 00000000000606f0
Stack:
 ffffffff811d2710 ffff881036007bc8 ffffffff819f1af1 ffff881036007bc8
 ffff881036007bc8 ffff881036007c08 ffff881001981880 ffff8810019818d8
 ffff881036007c48 ffff880e225d81c0 ffff881edfd2b400 ffff881036007c88
Call Trace:
 [<ffffffff811d2710>] ? flock_lock_file+0x30/0x270
 [<ffffffff811d3ad1>] flock_lock_file_wait+0x41/0xf0
 [<ffffffff8168be66>] ? _raw_spin_unlock+0x26/0x40
 [<ffffffff81268de9>] do_vfs_lock+0x19/0x40
 [<ffffffff812695cc>] nfs4_locku_done+0x5c/0xf0
 [<ffffffff8164f3f4>] rpc_exit_task+0x34/0xb0
 [<ffffffff8164fcd9>] __rpc_execute+0x79/0x390
 [<ffffffff81650000>] rpc_async_schedule+0x10/0x20
 [<ffffffff81086095>] process_one_work+0x1a5/0x450
 [<ffffffff81086024>] ? process_one_work+0x134/0x450
 [<ffffffff8108638b>] worker_thread+0x4b/0x4a0
 [<ffffffff81086340>] ? process_one_work+0x450/0x450
 [<ffffffff81086340>] ? process_one_work+0x450/0x450
 [<ffffffff8108d777>] kthread+0xf7/0x110
 [<ffffffff8108d680>] ? __kthread_parkme+0xa0/0xa0
 [<ffffffff8168ce3e>] ret_from_fork+0x3e/0x70
 [<ffffffff8108d680>] ? __kthread_parkme+0xa0/0xa0
Code: 48 b8 00 00 00 00 00 00 00 80 55 48 89 e5 48 09 c1 ff d1 5d 85 c0 0f =
95 c0 0f b6 c0 eb b9 66 2e 0f 1f 84 00 00 00 00 00 83 fe 02 <48> 8b 87 c8 0=
1 00 00 0f 84 a0 00 00 00 48 85 c0 0f 85 97 00 00=20
RIP  [<ffffffff811d0cf3>] locks_get_lock_context+0x3/0xc0
 RSP <ffff881036007bb0>
CR2: 00000000000001c8
---[ end trace 2da9686dda1b5574 ]---


Thanks,
--=20
William

--WHz+neNWvhIGAO8A
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlYlG1wACgkQ1I6eqOUidQEc+gCgieFWA0CtyPubu7xod2Qo7SaW
RNkAnAmr91b82iw2+gA1JnzbcHnAyvtB
=Y7lE
-----END PGP SIGNATURE-----

--WHz+neNWvhIGAO8A--
