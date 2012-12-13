Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35649 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755130Ab2LMBNw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2012 20:13:52 -0500
Date: Thu, 13 Dec 2012 12:13:41 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: NULL dereference from nfs_destroy_server, with possible fix.
Message-ID: <20121213121341.59a17609@notabene.brown>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91192944F@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121213110528.0a04e399@notabene.brown>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91192944F@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/yTu/oVW+kulstocuSr4ihe3"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/yTu/oVW+kulstocuSr4ihe3
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 13 Dec 2012 01:05:15 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Thu, 2012-12-13 at 11:05 +1100, NeilBrown wrote:
> > Hi,
> >=20
> > I recently managed to get the following stack trace, though I haven't b=
een
> > able to reproduce it.
> >=20
> > Dec 12 17:17:04 hp kernel: [22684.894434] BUG: unable to handle kernel =
NULL pointer dereference at 0000000000000310
> > Dec 12 17:17:04 hp kernel: [22684.894490] IP: [<ffffffff813248f9>] nlmc=
lnt_done+0x9/0x30
> > Dec 12 17:17:04 hp kernel: [22684.894529] PGD 13cc5a067 PUD 13ca0a067 P=
MD 0=20
> > Dec 12 17:17:04 hp kernel: [22684.894593] Oops: 0000 [#1] PREEMPT SMP D=
EBUG_PAGEALLOC
> > Dec 12 17:17:04 hp kernel: [22684.894660] Modules linked in:
> > Dec 12 17:17:04 hp kernel: [22684.894691] CPU 0=20
> > Dec 12 17:17:04 hp kernel: [22684.894708] Pid: 6874, comm: ls Not taint=
ed 3.7.0-rc1+ #323 HP ProLiant ML310 G3
> > Dec 12 17:17:04 hp kernel: [22684.894745] RIP: 0010:[<ffffffff813248f9>=
]  [<ffffffff813248f9>] nlmclnt_done+0x9/0x30
> > Dec 12 17:17:04 hp kernel: [22684.894783] RSP: 0018:ffff880139d59958  E=
FLAGS: 00010292
> > Dec 12 17:17:04 hp kernel: [22684.894804] RAX: 0000000000000000 RBX: ff=
ff88013760e7f0 RCX: 0000000000000000
> > Dec 12 17:17:04 hp kernel: [22684.894829] RDX: 0000000000000046 RSI: 00=
00000000000001 RDI: 0000000000000000
> > Dec 12 17:17:04 hp kernel: [22684.894852] RBP: ffff880139d59968 R08: 00=
00000000000000 R09: 0000000000000000
> > Dec 12 17:17:04 hp kernel: [22684.894878] R10: 0000000000000001 R11: 00=
00000000000000 R12: dead000000200200
> > Dec 12 17:17:04 hp kernel: [22684.894900] R13: ffff88013bdfaed0 R14: de=
ad000000200200 R15: ffff880139fde7f0
> > Dec 12 17:17:04 hp kernel: [22684.894924] FS:  00007f279bbf57c0(0000) G=
S:ffff880147c00000(0000) knlGS:0000000000000000
> > Dec 12 17:17:04 hp kernel: [22684.894947] CS:  0010 DS: 0000 ES: 0000 C=
R0: 000000008005003b
> > Dec 12 17:17:04 hp kernel: [22684.894968] CR2: 0000000000000310 CR3: 00=
00000137ea1000 CR4: 00000000000007f0
> > Dec 12 17:17:04 hp kernel: [22684.894995] DR0: 0000000000000000 DR1: 00=
00000000000000 DR2: 0000000000000000
> > Dec 12 17:17:04 hp kernel: [22684.895017] DR3: 0000000000000000 DR6: 00=
000000ffff0ff0 DR7: 0000000000000400
> > Dec 12 17:17:04 hp kernel: [22684.895039] Process ls (pid: 6874, thread=
info ffff880139d58000, task ffff88013bbdc050)
> > Dec 12 17:17:04 hp kernel: [22684.895061] Stack:
> > Dec 12 17:17:04 hp kernel: [22684.895079]  ffff880139d59978 ffff8801376=
0e7f0 ffff880139d59978 ffffffff812c41ff
> > Dec 12 17:17:04 hp kernel: [22684.895148]  ffff880139d599b8 ffffffff812=
c4eab ffffffff812c4d9b ffff88013760e7f0
> > Dec 12 17:17:04 hp kernel: [22684.895220]  ffff88013760e7f0 fffffffffff=
fff8c ffff88013e3a7ef0 00000000ffffff8c
> > Dec 12 17:17:04 hp kernel: [22684.895287] Call Trace:
> > Dec 12 17:17:04 hp kernel: [22684.895312]  [<ffffffff812c41ff>] nfs_des=
troy_server+0x1f/0x30
> > Dec 12 17:17:04 hp kernel: [22684.895337]  [<ffffffff812c4eab>] nfs_fre=
e_server+0x13b/0x200
> > Dec 12 17:17:04 hp kernel: [22684.895362]  [<ffffffff812c4d9b>] ? nfs_f=
ree_server+0x2b/0x200
> > Dec 12 17:17:04 hp kernel: [22684.895386]  [<ffffffff812c511b>] nfs_clo=
ne_server+0x1ab/0x250
> > Dec 12 17:17:04 hp kernel: [22684.895411]  [<ffffffff812dc498>] nfs3_cl=
one_server+0x18/0x50
> > Dec 12 17:17:04 hp kernel: [22684.895437]  [<ffffffff812ce202>] nfs_xde=
v_mount+0x82/0x120
> > Dec 12 17:17:04 hp kernel: [22684.895462]  [<ffffffff812ce300>] ? nfs_s=
et_super+0x60/0x60
> > Dec 12 17:17:04 hp kernel: [22684.895486]  [<ffffffff812cdd60>] ? nfs_s=
et_sb_security+0x10/0x10
> > Dec 12 17:17:04 hp kernel: [22684.895512]  [<ffffffff8116a3bb>] mount_f=
s+0x1b/0xd0
> > Dec 12 17:17:04 hp kernel: [22684.895545]  [<ffffffff811843bf>] vfs_ker=
n_mount+0x6f/0x110
> > Dec 12 17:17:04 hp kernel: [22684.895569]  [<ffffffff812d8f62>] nfs_do_=
submount+0xa2/0x150
> > Dec 12 17:17:04 hp kernel: [22684.895593]  [<ffffffff812d908e>] nfs_sub=
mount+0x7e/0xa0
> > Dec 12 17:17:04 hp kernel: [22684.895617]  [<ffffffff812d917c>] nfs_d_a=
utomount+0xcc/0x1c0
> > Dec 12 17:17:04 hp kernel: [22684.895643]  [<ffffffff811706c0>] follow_=
managed+0x150/0x310
> > Dec 12 17:17:04 hp kernel: [22684.895668]  [<ffffffff811710e1>] lookup_=
fast+0x1c1/0x310
> > Dec 12 17:17:04 hp kernel: [22684.895693]  [<ffffffff811744ac>] do_last=
.isra.57+0x17c/0xc50
> > Dec 12 17:17:04 hp kernel: [22684.895717]  [<ffffffff811718a3>] ? inode=
_permission+0x13/0x50
> > Dec 12 17:17:04 hp kernel: [22684.895741]  [<ffffffff81171d6d>] ? link_=
path_walk+0x22d/0x8f0
> > Dec 12 17:17:04 hp kernel: [22684.895766]  [<ffffffff81175033>] path_op=
enat.isra.58+0xb3/0x4c0
> > Dec 12 17:17:04 hp kernel: [22684.895791]  [<ffffffff811716db>] ? getna=
me_flags+0x2b/0x110
> > Dec 12 17:17:04 hp kernel: [22684.895816]  [<ffffffff8118285f>] ? __all=
oc_fd+0x2f/0x130
> > Dec 12 17:17:04 hp kernel: [22684.895842]  [<ffffffff8117579c>] do_filp=
_open+0x3c/0x90
> > Dec 12 17:17:04 hp kernel: [22684.895866]  [<ffffffff81182909>] ? __all=
oc_fd+0xd9/0x130
> > Dec 12 17:17:04 hp kernel: [22684.895891]  [<ffffffff8116614f>] do_sys_=
open+0xef/0x1d0
> >=20
> >=20
> > The problem is that nfs_destroy_server is calling nlmclnt_done(NULL).
> > This can happen if nfs_clone_server() is called on a v2/v3 mount but ge=
ts an
> > error between
> >=20
> > 	server->destroy =3D source->destroy;
> >=20
> > (which sets server->destroy to nfs_destroy_dever without setting
> > server->nlm_host) and
> >=20
> > 	error =3D nfs_start_lockd(server);
> >=20
> > (which sets both server->destroy and server->nlm_host).
> >=20
> > If this happens then nfs_free_server() calls ->destroy() which crashes =
as
> > shown.
> >=20
> > Maybe this patch?
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > index 8b39a42..b6603bb 100644
> > --- a/fs/nfs/client.c
> > +++ b/fs/nfs/client.c
> > @@ -617,7 +617,8 @@ static void nfs_destroy_server(struct nfs_server *s=
erver)
> >  {
> >  	if (!(server->flags & NFS_MOUNT_LOCAL_FLOCK) ||
> >  			!(server->flags & NFS_MOUNT_LOCAL_FCNTL))
> > -		nlmclnt_done(server->nlm_host);
> > +		if (server->nlm_host)
> > +			nlmclnt_done(server->nlm_host);
> >  }
>=20
> Hmm... Do we need all those tests of server->flags above if we can just
> check server->nlm_host for a NULL value?
>=20

No, you are right.   nlm_host will only be non-NULL if the one of the flags
is set, so the test is pointless.

NeilBrown


diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8b39a42..5e8d24d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -615,8 +615,7 @@ EXPORT_SYMBOL_GPL(nfs_create_rpc_client);
  */
 static void nfs_destroy_server(struct nfs_server *server)
 {
-	if (!(server->flags & NFS_MOUNT_LOCAL_FLOCK) ||
-			!(server->flags & NFS_MOUNT_LOCAL_FCNTL))
+	if (server->nlm_host)
 		nlmclnt_done(server->nlm_host);
 }
=20

--Sig_/yTu/oVW+kulstocuSr4ihe3
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUMkrxTnsnt1WYoG5AQJaNw//emXw/7MH0ChPcGnybKwt3ZDSsKjNu/5X
ucGVovCuzbVZDPj6uzJcNeWXGt7AAsRcIgPyCZ22k1bq42GdRKlsc9HiGhETLxRR
4NpbcPCedkmVZiJG7IxiFMOuQwM1F9ruYdemRX/qPMGUl/TcGAdBa1WeB8123OTu
lRLRjccY14Tlo95wW0/M96t58zPDQvetas5rUdfEtNT7L+0jK4sLOoq5fZgtCnwY
lVpvs4Ur36bEiRniIftd2oRKkLcXbRXE8bkFyyXx2FEvr4LF5tC+vdJOqeO/yogv
bp4x0AiBlouPDV6OjY0Uu9hUi43Yexm+rIseI4pa2D/54kLCKDZVnY7utuWH92a5
gHb3S9JfmUtrViSAuy0BjbL2eN1FRAkxkaoRYe2CZiBgupAUNDpnNWIwnnfLoT6H
I2wl5aAE8fxjt+thJmf2WfTfuqcR4QCjbehmkJgfsm/U8NeN6yNP3//YGQ86I7mx
oHfFJZnZiDacEgJBnNmDi5+GdowXGuRsysEQ+Yd5gKFJxV26LOYLKrg20U+I8HvN
J4/TE4svq8XBkwrs/M7bhkFDKyhaN3vEMKRZ4Nbg2046AF74aXl4n6T+gVxUxBZY
yxw1PceKrS6d4WzoLQNw97Pp2MJd1Xva6F2iWnjb/P95WvWUo9xNEmpgKeQds85W
v23PXvkUUZM=
=IEOE
-----END PGP SIGNATURE-----

--Sig_/yTu/oVW+kulstocuSr4ihe3--
