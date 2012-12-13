Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:33925 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754276Ab2LMAFm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2012 19:05:42 -0500
Date: Thu, 13 Dec 2012 11:05:28 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: NULL dereference from nfs_destroy_server, with possible fix.
Message-ID: <20121213110528.0a04e399@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/tlOtvhRqkCAhKtNR_0eCzuk"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/tlOtvhRqkCAhKtNR_0eCzuk
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi,

I recently managed to get the following stack trace, though I haven't been
able to reproduce it.

Dec 12 17:17:04 hp kernel: [22684.894434] BUG: unable to handle kernel NULL=
 pointer dereference at 0000000000000310
Dec 12 17:17:04 hp kernel: [22684.894490] IP: [<ffffffff813248f9>] nlmclnt_=
done+0x9/0x30
Dec 12 17:17:04 hp kernel: [22684.894529] PGD 13cc5a067 PUD 13ca0a067 PMD 0=
=20
Dec 12 17:17:04 hp kernel: [22684.894593] Oops: 0000 [#1] PREEMPT SMP DEBUG=
_PAGEALLOC
Dec 12 17:17:04 hp kernel: [22684.894660] Modules linked in:
Dec 12 17:17:04 hp kernel: [22684.894691] CPU 0=20
Dec 12 17:17:04 hp kernel: [22684.894708] Pid: 6874, comm: ls Not tainted 3=
.7.0-rc1+ #323 HP ProLiant ML310 G3
Dec 12 17:17:04 hp kernel: [22684.894745] RIP: 0010:[<ffffffff813248f9>]  [=
<ffffffff813248f9>] nlmclnt_done+0x9/0x30
Dec 12 17:17:04 hp kernel: [22684.894783] RSP: 0018:ffff880139d59958  EFLAG=
S: 00010292
Dec 12 17:17:04 hp kernel: [22684.894804] RAX: 0000000000000000 RBX: ffff88=
013760e7f0 RCX: 0000000000000000
Dec 12 17:17:04 hp kernel: [22684.894829] RDX: 0000000000000046 RSI: 000000=
0000000001 RDI: 0000000000000000
Dec 12 17:17:04 hp kernel: [22684.894852] RBP: ffff880139d59968 R08: 000000=
0000000000 R09: 0000000000000000
Dec 12 17:17:04 hp kernel: [22684.894878] R10: 0000000000000001 R11: 000000=
0000000000 R12: dead000000200200
Dec 12 17:17:04 hp kernel: [22684.894900] R13: ffff88013bdfaed0 R14: dead00=
0000200200 R15: ffff880139fde7f0
Dec 12 17:17:04 hp kernel: [22684.894924] FS:  00007f279bbf57c0(0000) GS:ff=
ff880147c00000(0000) knlGS:0000000000000000
Dec 12 17:17:04 hp kernel: [22684.894947] CS:  0010 DS: 0000 ES: 0000 CR0: =
000000008005003b
Dec 12 17:17:04 hp kernel: [22684.894968] CR2: 0000000000000310 CR3: 000000=
0137ea1000 CR4: 00000000000007f0
Dec 12 17:17:04 hp kernel: [22684.894995] DR0: 0000000000000000 DR1: 000000=
0000000000 DR2: 0000000000000000
Dec 12 17:17:04 hp kernel: [22684.895017] DR3: 0000000000000000 DR6: 000000=
00ffff0ff0 DR7: 0000000000000400
Dec 12 17:17:04 hp kernel: [22684.895039] Process ls (pid: 6874, threadinfo=
 ffff880139d58000, task ffff88013bbdc050)
Dec 12 17:17:04 hp kernel: [22684.895061] Stack:
Dec 12 17:17:04 hp kernel: [22684.895079]  ffff880139d59978 ffff88013760e7f=
0 ffff880139d59978 ffffffff812c41ff
Dec 12 17:17:04 hp kernel: [22684.895148]  ffff880139d599b8 ffffffff812c4ea=
b ffffffff812c4d9b ffff88013760e7f0
Dec 12 17:17:04 hp kernel: [22684.895220]  ffff88013760e7f0 ffffffffffffff8=
c ffff88013e3a7ef0 00000000ffffff8c
Dec 12 17:17:04 hp kernel: [22684.895287] Call Trace:
Dec 12 17:17:04 hp kernel: [22684.895312]  [<ffffffff812c41ff>] nfs_destroy=
_server+0x1f/0x30
Dec 12 17:17:04 hp kernel: [22684.895337]  [<ffffffff812c4eab>] nfs_free_se=
rver+0x13b/0x200
Dec 12 17:17:04 hp kernel: [22684.895362]  [<ffffffff812c4d9b>] ? nfs_free_=
server+0x2b/0x200
Dec 12 17:17:04 hp kernel: [22684.895386]  [<ffffffff812c511b>] nfs_clone_s=
erver+0x1ab/0x250
Dec 12 17:17:04 hp kernel: [22684.895411]  [<ffffffff812dc498>] nfs3_clone_=
server+0x18/0x50
Dec 12 17:17:04 hp kernel: [22684.895437]  [<ffffffff812ce202>] nfs_xdev_mo=
unt+0x82/0x120
Dec 12 17:17:04 hp kernel: [22684.895462]  [<ffffffff812ce300>] ? nfs_set_s=
uper+0x60/0x60
Dec 12 17:17:04 hp kernel: [22684.895486]  [<ffffffff812cdd60>] ? nfs_set_s=
b_security+0x10/0x10
Dec 12 17:17:04 hp kernel: [22684.895512]  [<ffffffff8116a3bb>] mount_fs+0x=
1b/0xd0
Dec 12 17:17:04 hp kernel: [22684.895545]  [<ffffffff811843bf>] vfs_kern_mo=
unt+0x6f/0x110
Dec 12 17:17:04 hp kernel: [22684.895569]  [<ffffffff812d8f62>] nfs_do_subm=
ount+0xa2/0x150
Dec 12 17:17:04 hp kernel: [22684.895593]  [<ffffffff812d908e>] nfs_submoun=
t+0x7e/0xa0
Dec 12 17:17:04 hp kernel: [22684.895617]  [<ffffffff812d917c>] nfs_d_autom=
ount+0xcc/0x1c0
Dec 12 17:17:04 hp kernel: [22684.895643]  [<ffffffff811706c0>] follow_mana=
ged+0x150/0x310
Dec 12 17:17:04 hp kernel: [22684.895668]  [<ffffffff811710e1>] lookup_fast=
+0x1c1/0x310
Dec 12 17:17:04 hp kernel: [22684.895693]  [<ffffffff811744ac>] do_last.isr=
a.57+0x17c/0xc50
Dec 12 17:17:04 hp kernel: [22684.895717]  [<ffffffff811718a3>] ? inode_per=
mission+0x13/0x50
Dec 12 17:17:04 hp kernel: [22684.895741]  [<ffffffff81171d6d>] ? link_path=
_walk+0x22d/0x8f0
Dec 12 17:17:04 hp kernel: [22684.895766]  [<ffffffff81175033>] path_openat=
.isra.58+0xb3/0x4c0
Dec 12 17:17:04 hp kernel: [22684.895791]  [<ffffffff811716db>] ? getname_f=
lags+0x2b/0x110
Dec 12 17:17:04 hp kernel: [22684.895816]  [<ffffffff8118285f>] ? __alloc_f=
d+0x2f/0x130
Dec 12 17:17:04 hp kernel: [22684.895842]  [<ffffffff8117579c>] do_filp_ope=
n+0x3c/0x90
Dec 12 17:17:04 hp kernel: [22684.895866]  [<ffffffff81182909>] ? __alloc_f=
d+0xd9/0x130
Dec 12 17:17:04 hp kernel: [22684.895891]  [<ffffffff8116614f>] do_sys_open=
+0xef/0x1d0


The problem is that nfs_destroy_server is calling nlmclnt_done(NULL).
This can happen if nfs_clone_server() is called on a v2/v3 mount but gets an
error between

	server->destroy =3D source->destroy;

(which sets server->destroy to nfs_destroy_dever without setting
server->nlm_host) and

	error =3D nfs_start_lockd(server);

(which sets both server->destroy and server->nlm_host).

If this happens then nfs_free_server() calls ->destroy() which crashes as
shown.

Maybe this patch?

Signed-off-by: NeilBrown <neilb@suse.de>
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8b39a42..b6603bb 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -617,7 +617,8 @@ static void nfs_destroy_server(struct nfs_server *serve=
r)
 {
 	if (!(server->flags & NFS_MOUNT_LOCAL_FLOCK) ||
 			!(server->flags & NFS_MOUNT_LOCAL_FCNTL))
-		nlmclnt_done(server->nlm_host);
+		if (server->nlm_host)
+			nlmclnt_done(server->nlm_host);
 }
=20
 /*


Thanks,
NeilBrown

--Sig_/tlOtvhRqkCAhKtNR_0eCzuk
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUMkbyDnsnt1WYoG5AQL5oRAAs0JnEVKws685POI7cI71MSFlZDmdM7Yl
pUr3d72YkeMU9qUxU6s1v8fRQCd/Hq3v1f3/KJkHofC9fipgspSNRV8xBg2oZMiJ
ahiqkqJVC/T4EUA9bNzWRf2rEx+6ucY59DF0vmXmitV53Z9WSpLSWl8rbMGhISvL
SPlBAGaSGl9vyNmF8nJvqemF4gNScPvKweeOC5VpEAuWEnPj5AL/iVmA7QcS/+nF
UlD2OVgeTHxjp+ghsIVKTpjlKycWgY21VSlU+KaLBMlfhCqIt2gEebzrUNZPoa1x
n6p73B6oURSnNW4QPFblnB36Xlb1OmB2vHDqG05SrcYJCfRJLnybcy7erh7wQNid
Ve7J2SO6gsG/iT3ZZRS71SjbGzHJt8f/rKAyR0/vc/MzSf+JJMMJwLAjGoZnTzf8
OITah2cYBGOAy2sT5VNcZNxPOk7Rq8tqUSKhygHYf+P9fSCCETxaiHdTaZ8Rbs22
WcUvkvQBsW17sm3Io88G5j4Oe+31Od97WWsTxFjw8W0q1JLrwDKs0AmROdMiY+qt
UtkykkXOtplXeeCoRCLlOgtjw2nXK+zlPr8qQxOUP/FIj5UBzM3gTg03VNbOZDr1
A62HW1JN010OK2MP+OaLUIzH6hecMQnQRv9V32uZHdP77AyJ/ORKIo/d8DWWmVWK
cGRRdHSGwZY=
=8V3u
-----END PGP SIGNATURE-----

--Sig_/tlOtvhRqkCAhKtNR_0eCzuk--
