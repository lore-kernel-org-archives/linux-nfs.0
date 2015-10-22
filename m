Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:34232 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965478AbbJVSkA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Oct 2015 14:40:00 -0400
Received: by qgem9 with SMTP id m9so64694537qge.1
        for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2015 11:39:59 -0700 (PDT)
Date: Thu, 22 Oct 2015 14:39:45 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: William Dauchy <william@gandi.net>
Cc: linux-fsdevel@vger.kernel.org,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Jeff Layton <jeff.layton@primarydata.com>
Subject: Re: locks_get_lock_context null deref
Message-ID: <20151022143945.42856f45@synchrony.poochiereds.net>
In-Reply-To: <20151022173243.GD3258@gandi.net>
References: <20151019163332.GI10696@gandi.net>
	<20151019174014.GJ10696@gandi.net>
	<20151022173243.GD3258@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/rpnWF_mMiQ1X8eMdmJLkKTE"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/rpnWF_mMiQ1X8eMdmJLkKTE
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 22 Oct 2015 19:32:43 +0200
William Dauchy <william@gandi.net> wrote:

> Hi Jeff,
>=20
> After a few days of testing, I was unable to reproduce the null deref
> mentionned in this thread.
> Do you think we can ask for a backport in stable@ for v4.1?
>=20
> bcd7f78 locks: have flock_lock_file take an inode pointer instead of a fi=
lp
> 29d01b2 locks: new helpers - flock_lock_inode_wait and posix_lock_inode_w=
ait
> ee296d7 locks: inline posix_lock_file_wait and flock_lock_file_wait
> 83bfff2 nfs4: have do_vfs_lock take an inode pointer
>=20

Yes, I think those four patches should go into v4.1-stable. Do you need me
to do anything to make that happen?

Thanks,
Jeff

> On Oct19 19:40, William Dauchy wrote:
> > On Oct19 18:33, William Dauchy wrote:
> > > I am getting the following null deref on locks_get_lock_context using=
 a v4.1.x
> > > (x86_64) while using the nfs client v4.0.
> > >=20
> > > Any hint to help debug that issue?
> > >=20
> > >=20
> > > BUG: unable to handle kernel NULL pointer dereference at 000000000000=
01c8
> > > IP: [<ffffffff811d0cf3>] locks_get_lock_context+0x3/0xc0
> > > PGD 0=20
> > > Oops: 0000 [#1] SMP=20
> > > CPU: 1 PID: 1773 Comm: kworker/1:1H Not tainted 4.1.11-rc1 #1
> > > Workqueue: rpciod ffffffff8164fff0
> > > task: ffff8810374deba0 ti: ffff8810374df150 task.ti: ffff8810374df150
> > > RIP: 0010:[<ffffffff811d0cf3>]  [<ffffffff811d0cf3>] locks_get_lock_c=
ontext+0x3/0xc0
> > > RSP: 0000:ffff881036007bb0  EFLAGS: 00010246
> > > RAX: ffff881036007c30 RBX: ffff881001981880 RCX: 0000000000000002
> > > RDX: 00000000000006ed RSI: 0000000000000002 RDI: 0000000000000000
> > > RBP: ffff881036007c08 R08: 0000000000000000 R09: 0000000000000001
> > > R10: 0000000000000000 R11: ffff88101db69948 R12: ffff8810019818d8
> > > R13: ffff881036007bc8 R14: ffff880e225d81c0 R15: ffff881edfd2b400
> > > FS:  0000000000000000(0000) GS:ffff88103fc20000(0000) knlGS:000000000=
0000000
> > > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > CR2: 00000000000001c8 CR3: 000000000169b000 CR4: 00000000000606f0
> > > Stack:
> > >  ffffffff811d2710 ffff881036007bc8 ffffffff819f1af1 ffff881036007bc8
> > >  ffff881036007bc8 ffff881036007c08 ffff881001981880 ffff8810019818d8
> > >  ffff881036007c48 ffff880e225d81c0 ffff881edfd2b400 ffff881036007c88
> > > Call Trace:
> > >  [<ffffffff811d2710>] ? flock_lock_file+0x30/0x270
> > >  [<ffffffff811d3ad1>] flock_lock_file_wait+0x41/0xf0
> > >  [<ffffffff8168be66>] ? _raw_spin_unlock+0x26/0x40
> > >  [<ffffffff81268de9>] do_vfs_lock+0x19/0x40
> > >  [<ffffffff812695cc>] nfs4_locku_done+0x5c/0xf0
> > >  [<ffffffff8164f3f4>] rpc_exit_task+0x34/0xb0
> > >  [<ffffffff8164fcd9>] __rpc_execute+0x79/0x390
> > >  [<ffffffff81650000>] rpc_async_schedule+0x10/0x20
> > >  [<ffffffff81086095>] process_one_work+0x1a5/0x450
> > >  [<ffffffff81086024>] ? process_one_work+0x134/0x450
> > >  [<ffffffff8108638b>] worker_thread+0x4b/0x4a0
> > >  [<ffffffff81086340>] ? process_one_work+0x450/0x450
> > >  [<ffffffff81086340>] ? process_one_work+0x450/0x450
> > >  [<ffffffff8108d777>] kthread+0xf7/0x110
> > >  [<ffffffff8108d680>] ? __kthread_parkme+0xa0/0xa0
> > >  [<ffffffff8168ce3e>] ret_from_fork+0x3e/0x70
> > >  [<ffffffff8108d680>] ? __kthread_parkme+0xa0/0xa0
> > > Code: 48 b8 00 00 00 00 00 00 00 80 55 48 89 e5 48 09 c1 ff d1 5d 85 =
c0 0f 95 c0 0f b6 c0 eb b9 66 2e 0f 1f 84 00 00 00 00 00 83 fe 02 <48> 8b 8=
7 c8 01 00 00 0f 84 a0 00 00 00 48 85 c0 0f 85 97 00 00=20
> > > RIP  [<ffffffff811d0cf3>] locks_get_lock_context+0x3/0xc0
> > >  RSP <ffff881036007bb0>
> > > CR2: 00000000000001c8
> > > ---[ end trace 2da9686dda1b5574 ]---
> >=20
> > As mentioned in another thread by Jeff, I applied the following commits:
> >=20
> > bcd7f78 locks: have flock_lock_file take an inode pointer instead of a =
filp
> > 29d01b2 locks: new helpers - flock_lock_inode_wait and posix_lock_inode=
_wait
> > ee296d7 locks: inline posix_lock_file_wait and flock_lock_file_wait
> > 83bfff2 nfs4: have do_vfs_lock take an inode pointer
> >=20
> > I will see if I get the same issue again.
>=20


--=20
Jeff Layton <jlayton@poochiereds.net>

--Sig_/rpnWF_mMiQ1X8eMdmJLkKTE
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWKS1yAAoJEAAOaEEZVoIVYsgP/RPjqnlwZiYSANe9+yv1hpC+
2Up+q+eOFg3v4PyxLRPct4kWwo4vFxsM61ic7fgth1ttPQKgaxDGY9y4R+vDEBR7
l5Vq+dC1Ai3yBLrTHiK7MLOtfvfckfxyKb681smCER7q4pgbfzkN0CoBPbvNLSxt
7ZS0yY5zjvuN6Bp1jo+Oa7WOPntMrnd5QvQQshmScMmmg62t+qHmSAqHftw9XpPh
uzjaVFDOMWYkAr9b/WnkNl6w7QmWJrD9LNvXdhxpKenkRtKkubKUPXqHVNTYeQoI
hlp+ooAw2vWQ40IC9+WWLwZ3rXW2dy8B/YLh/eJ0jKF6Gqd55NRs4pllYsHmrhfC
zNgj8STuMSCDbNwj08ZFRcPNiRFpDbtIJ7Z027dX2M4Ve94dEWR8xB38Nx2MFk+M
QJh2Muflc+6hT4eSzALftdaIyZbS/3vT97h3R3/WTWYk17qUIW7+q6ncffaXHqz6
qE/XGdcLHOQl1Nskbq6eH4R+xXmav+Ci4wPc2TCKiUHuQ0fvWRlGzPxCXC6AHZar
Ew6kH2o+5qY9OEFEeGL9Gz7hbGFGqXQ8f2lPb6wbi2Yl+5bZo3aP6l3m7YIy6rep
yRm4E3xpZn92NTWxAxbwUSSUBm/nQIPRETpfvPQZ993aJTv5aMGkcFGRUdDEjGgQ
agk1CNscaZvXv57G0IX/
=YuWX
-----END PGP SIGNATURE-----

--Sig_/rpnWF_mMiQ1X8eMdmJLkKTE--
