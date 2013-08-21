Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail4.gandi.net ([217.70.183.210]:46140 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779Ab3HUNbY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 09:31:24 -0400
Received: from localhost (mfiltercorp1-d.gandi.net [217.70.183.155])
	by mail4.gandi.net (Postfix) with ESMTP id AF63F120AC3
	for <linux-nfs@vger.kernel.org>; Wed, 21 Aug 2013 15:23:18 +0200 (CEST)
Date: Wed, 21 Aug 2013 15:23:15 +0200
From: William Dauchy <william@gandi.net>
To: linux-nfs@vger.kernel.org
Cc: ahmed@gandi.net
Subject: nfsv4 3.10.x bug
Message-ID: <20130821132315.GA16170@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KsGdsel6WgEHnImy"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

While testing a 3.10.x kernel I went through a bug which I'm not able to
reproduce easily. For that reason I don't have any tcpdump trace.
I also can't debug it with slub_debug since it makes everything really
slow.
I suspect a race/double free issue but I don't have any clue at the
moment. Any hint?

invalid opcode: 0000 [#1] PREEMPT SMP=20
CPU: 1 PID: 28156 Comm: mysqld Not tainted 3.10.5 #1
task: ffff88028a2b1770 ti: ffff88028a2b1bf8 task.ti: ffff88028a2b1bf8
RIP: 0010:[<ffffffff810f5524>]  [<ffffffff810f5524>] kfree+0x1a4/0x1b0
RSP: 0018:ffff8804a8811cf8  EFLAGS: 00010246
RAX: 1700000000000000 RBX: ffff88055f49ce40 RCX: 0000000000000001
RDX: 000077ff80000000 RSI: ffff880b3cabe180 RDI: ffff88055f49ce40
RBP: ffff88040ffda400 R08: 00000000ffffff02 R09: 00000000ffffff01
R10: 00000000ffffff02 R11: 0000000000000001 R12: ffffea00157d2700
R13: ffff880b3cabe108 R14: ffff880b3cabe180 R15: 00000000000000d0
FS:  0000039cfeadb700(0000) GS:ffff880627c20000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000036bcf3b4c1c CR3: 000000000151f000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
 ffff8804a8811d60 ffffffff8150f76f ffff880b3cabe108 ffff88055f49ce40
 ffff88040ffda400 ffff88040ffda440 ffff880b3cabe108 ffff880b3cabe180
 00000000000000d0 ffffffff811a4f67 ffff880368971600 ffff880414093800
Call Trace:
 [<ffffffff8150f76f>] ? __wait_on_bit+0x7f/0xa0
 [<ffffffff811a4f67>] ? nfs4_put_open_state+0xd7/0x100
 [<ffffffff81195b4a>] ? nfs4_free_closedata+0x2a/0x60
 [<ffffffff814de388>] ? rpc_free_task+0x38/0xa0
 [<ffffffff8119b558>] ? nfs4_do_close+0x1a8/0x220
 [<ffffffff8117f0fc>] ? __put_nfs_open_context+0xcc/0x140
 [<ffffffff8117fb34>] ? nfs_release+0x94/0xc0
 [<ffffffff8110beb9>] ? __fput+0xb9/0x260
 [<ffffffff8105d5f8>] ? task_work_run+0xb8/0xe0
 [<ffffffff8151396e>] ? int_signal+0x12/0x17
Code: 68 4c 89 e7 48 8b 5c 24 18 48 8b 6c 24 20 4c 8b 64 24 28 4c 8b 6c 24 =
30 4c 8b 74 24 38 4c 8b 7c 24 40 48 83 c4 48 e9 9c 62 fc ff <0f> 0b 66 2e 0=
f 1f 84 00 00 00 00 00 41 57 48 89 fa 41 b8 20 00=20
RIP  [<ffffffff810f5524>] kfree+0x1a4/0x1b0
 RSP <ffff8804a8811cf8>
---[ end trace 7e89e16c67707d35 ]---
Oops: 0000 [#2] PREEMPT SMP=20
CPU: 1 PID: 14357 Comm: php5-fpm Tainted: G      D      3.10.5 #1
Hardware name: Dell       C6100           /0D61XP, BIOS 1.65 10/26/2011
task: ffff8802da747530 ti: ffff8802da7479b8 task.ti: ffff8802da7479b8
RIP: 0010:[<ffffffff810f45ad>]  [<ffffffff810f45ad>] kmem_cache_alloc+0x8d/=
0x1b0
RSP: 0018:ffff8805662a5b78  EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffff880627c2f880 RCX: 0000000047e66881
RDX: 0000000047e66801 RSI: 00000000000000d0 RDI: ffff880627803800
RBP: 0000000000007391 R08: 000000000000f880 R09: 0000000000000002
R10: 0000000000001389 R11: ffff88041ab8e9c0 R12: ffff8802da7479b8
R13: ffff880627803800 R14: 00000000000000d0 R15: ffffffff8117f807
FS:  0000032b9c4b0720(0000) GS:ffff880627c20000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000007391 CR3: 000000000151f000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
ffff8804bc8d2910 ffffea000689ac00 0000138800001388 ffff88032d065900
ffff88041aa4d8c0 ffff88061d92b180 000000000000001e ffff88041ab8e9c0
0000000000008441 ffffffff8117f807 ffff88032d065900 ffff8804bc8d27d8
Call Trace:
[<ffffffff8117f807>] ? alloc_nfs_open_context+0x47/0x140
[<ffffffff811a72b1>] ? nfs4_file_open+0x81/0x200
[<ffffffff811a7230>] ? nfs4_file_fsync+0xb0/0xb0
[<ffffffff8110850a>] ? do_dentry_open+0x1ea/0x290
[<ffffffff81109658>] ? finish_open+0x28/0x40
[<ffffffff81119085>] ? do_last.isra.45+0x765/0xef0
[<ffffffff81116ffd>] ? link_path_walk+0x24d/0x980
[<ffffffff811198d3>] ? path_openat.isra.46+0xc3/0x540
[<ffffffff81069ec2>] ? finish_task_switch+0x52/0xe0
[<ffffffff81072c80>] ? hrtick_update+0x70/0x70
[<ffffffff81119d94>] ? do_filp_open+0x44/0xb0
[<ffffffff811294e0>] ? __alloc_fd+0xc0/0x110
[<ffffffff81109ab3>] ? do_sys_open+0xf3/0x1e0
[<ffffffff8151375e>] ? system_call_fastpath+0x18/0x1d
Code: 01 00 00 48 8b 2b 48 8b 43 10 48 85 ed 0f 84 d5 00 00 00 48 85 c0 0f =
84 cc 00 00 00 49 63 45 20 48 8d 8a 80 00 00 00 4d 8b 45 00 <48> 8b 5c 05 0=
0 48 89 e8 65 49 0f c7 08 0f 94 c0 84 c0 74 9a 49=20
RIP  [<ffffffff810f45ad>] kmem_cache_alloc+0x8d/0x1b0
RSP <ffff8805662a5b78>
CR2: 0000000000007391
---[ end trace 7e89e16c67707d36 ]---


Thanks,
--=20
William

--KsGdsel6WgEHnImy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlIUv0MACgkQ1I6eqOUidQEmNQCeO9NF7GAU2erGG1Wrk1wtzJhB
hn4An0iLaHUH9zSxIMMspEOa1w3x/0Ew
=AX09
-----END PGP SIGNATURE-----

--KsGdsel6WgEHnImy--
