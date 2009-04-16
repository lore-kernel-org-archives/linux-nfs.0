From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [tree] latest kill-the-BKL tree, v12
Date: Thu, 16 Apr 2009 10:51:53 +0200
Message-ID: <20090416085153.GC9813@elte.hu>
References: <1239680065-25013-1-git-send-email-fweisbec@gmail.com> <20090414045109.GA26908@orion> <20090414090146.GH27003@elte.hu> <a4423d670904151558r4252c7eamd115793fb36a9163@mail.gmail.com> <20090415230736.GA22710@elte.hu> <20090415233533.GA5962@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Alexander Beregalov <a.beregalov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Alessio Igor Bogani <abogani@texware.it>,
	Jeff Mahoney <jeffm@suse.com>,
	ReiserFS Development List <reiserfs-devel@vger.kernel.org>,
	Chris Mason <chris.mason@oracle.com>
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090415233533.GA5962@nowhere>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Frederic Weisbecker <fweisbec@gmail.com> wrote:

> On Thu, Apr 16, 2009 at 01:07:36AM +0200, Ingo Molnar wrote:
> >=20
> > * Alexander Beregalov <a.beregalov@gmail.com> wrote:
> >=20
> > > 2009/4/14 Ingo Molnar <mingo@elte.hu>:
> > > >
> > > > * Alexander Beregalov <a.beregalov@gmail.com> wrote:
> > > >
> > > >> On Tue, Apr 14, 2009 at 05:34:22AM +0200, Frederic Weisbecker =
wrote:
> > > >> > Ingo,
> > > >> >
> > > >> > This small patchset fixes some deadlocks I've faced after tr=
ying
> > > >> > some pressures with dbench on a reiserfs partition.
> > > >> >
> > > >> > There is still some work pending such as adding some checks =
to ensure we
> > > >> > _always_ release the lock before sleeping, as you suggested.
> > > >> > Also I have to fix a lockdep warning reported by Alessio Igo=
r Bogani.
> > > >> > And also some optimizations....
> > > >> >
> > > >> > Thanks,
> > > >> > Frederic.
> > > >> >
> > > >> > Frederic Weisbecker (3):
> > > >> > =A0 kill-the-BKL/reiserfs: provide a tool to lock only once =
the write lock
> > > >> > =A0 kill-the-BKL/reiserfs: lock only once in reiserfs_trunca=
te_file
> > > >> > =A0 kill-the-BKL/reiserfs: only acquire the write lock once =
in
> > > >> > =A0 =A0 reiserfs_dirty_inode
> > > >> >
> > > >> > =A0fs/reiserfs/inode.c =A0 =A0 =A0 =A0 | =A0 10 +++++++---
> > > >> > =A0fs/reiserfs/lock.c =A0 =A0 =A0 =A0 =A0| =A0 26 ++++++++++=
++++++++++++++++
> > > >> > =A0fs/reiserfs/super.c =A0 =A0 =A0 =A0 | =A0 15 +++++++++---=
---
> > > >> > =A0include/linux/reiserfs_fs.h | =A0 =A02 ++
> > > >> > =A04 files changed, 44 insertions(+), 9 deletions(-)
> > > >> >
> > > >>
> > > >> Hi
> > > >>
> > > >> The same test - dbench on reiserfs on loop on sparc64.
> > > >>
> > > >> [ INFO: possible circular locking dependency detected ]
> > > >> 2.6.30-rc1-00457-gb21597d-dirty #2
> > > >
> > > > I'm wondering ... your version hash suggests you used vanilla
> > > > upstream as a base for your test. There's a string of other fix=
es
> > > > from Frederic in tip:core/kill-the-BKL branch, have you picked =
them
> > > > all up when you did your testing?
> > > >
> > > > The most coherent way to test this would be to pick up the late=
st
> > > > core/kill-the-BKL git tree from:
> > > >
> > > > =A0 git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6=
-tip.git core/kill-the-BKL
> > > >
> > >=20
> > > I did not know about this branch, now I am testing it and there i=
s=20
> > > no more problem with that testcase (dbench).
> > >=20
> > > I will continue testing.
> >=20
> > thanks for testing it! It seems reiserfs with Frederic's changes=20
> > appears to be more stable now on your system.
>=20
>=20
>=20
>=20
> Yeah, thanks a lot for this testing!
>=20
>=20
> =20
> > I saw your NFS circular locking kill-the-BKL problem report on LKML=
=20
> > - also attached below.
> >=20
> > Hopefully someone on the Cc: list with NFS experience can point out=
=20
> > the BKL assumption that is causing this.
> >=20
> > 	Ingo
> >=20
> > ----- Forwarded message from Alexander Beregalov <a.beregalov@gmail=
=2Ecom> -----
> >=20
> > Date: Wed, 15 Apr 2009 22:08:01 +0400
> > From: Alexander Beregalov <a.beregalov@gmail.com>
> > To: linux-kernel <linux-kernel@vger.kernel.org>,
> > 	Ingo Molnar <mingo@elte.hu>, linux-nfs@vger.kernel.org
> > Subject: [core/kill-the-BKL] nfs3: possible circular locking depend=
ency
> >=20
> > Hi
> >=20
> > I have pulled core/kill-the-BKL on top of 2.6.30-rc2.
> >=20
> > device: '0:18': device_add
> >=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> > [ INFO: possible circular locking dependency detected ]
> > 2.6.30-rc2-00057-g30aa902-dirty #5
> > -------------------------------------------------------
> > mount.nfs/1740 is trying to acquire lock:
> >  (kernel_mutex){+.+.+.}, at: [<00000000006f32dc>] lock_kernel+0x28/=
0x3c
> >=20
> > but task is already holding lock:
> >  (&type->s_umount_key#24/1){+.+.+.}, at: [<00000000004b88a0>] sget+=
0x228/0x36c
> >=20
> > which lock already depends on the new lock.
> >=20
> >=20
> > the existing dependency chain (in reverse order) is:
> >=20
> > -> #1 (&type->s_umount_key#24/1){+.+.+.}:
> >        [<00000000004776d0>] lock_acquire+0x5c/0x74
> >        [<0000000000469f5c>] down_write_nested+0x38/0x50
> >        [<00000000004b88a0>] sget+0x228/0x36c
> >        [<00000000005688fc>] nfs_get_sb+0x80c/0xa7c
> >        [<00000000004b7ec8>] vfs_kern_mount+0x44/0xa4
> >        [<00000000004b7f84>] do_kern_mount+0x30/0xcc
> >        [<00000000004cf300>] do_mount+0x7c8/0x80c
> >        [<00000000004ed2a4>] compat_sys_mount+0x224/0x274
> >        [<0000000000406154>] linux_sparc_syscall32+0x34/0x40
> >=20
> > -> #0 (kernel_mutex){+.+.+.}:
> >        [<00000000004776d0>] lock_acquire+0x5c/0x74
> >        [<00000000006f0ebc>] mutex_lock_nested+0x48/0x380
> >        [<00000000006f32dc>] lock_kernel+0x28/0x3c
> >        [<00000000006d20ec>] rpc_wait_bit_killable+0x64/0x8c
> >        [<00000000006f0620>] __wait_on_bit+0x64/0xc0
> >        [<00000000006f06e4>] out_of_line_wait_on_bit+0x68/0x7c
> >        [<00000000006d2938>] __rpc_execute+0x150/0x2b4
> >        [<00000000006d2ac0>] rpc_execute+0x24/0x34
> >        [<00000000006cc338>] rpc_run_task+0x64/0x74
> >        [<00000000006cc474>] rpc_call_sync+0x58/0x7c
> >        [<00000000005717b0>] nfs3_rpc_wrapper+0x24/0xa0
> >        [<0000000000572024>] do_proc_get_root+0x6c/0x10c
> >        [<00000000005720dc>] nfs3_proc_get_root+0x18/0x5c
> >        [<000000000056401c>] nfs_get_root+0x34/0x17c
> >        [<0000000000568adc>] nfs_get_sb+0x9ec/0xa7c
> >        [<00000000004b7ec8>] vfs_kern_mount+0x44/0xa4
> >        [<00000000004b7f84>] do_kern_mount+0x30/0xcc
> >        [<00000000004cf300>] do_mount+0x7c8/0x80c
> >        [<00000000004ed2a4>] compat_sys_mount+0x224/0x274
> >        [<0000000000406154>] linux_sparc_syscall32+0x34/0x40
>=20
>=20
>=20
>=20
> This is still the dependency between bkl and s_umount_key that has=20
> been reported recently. I wonder if this is not a problem in the=20
> fs layer. I should investigate on it.

The problem seem to be that this NFS call context:

-> #0 (kernel_mutex){+.+.+.}:
       [<00000000004776d0>] lock_acquire+0x5c/0x74
       [<00000000006f0ebc>] mutex_lock_nested+0x48/0x380
       [<00000000006f32dc>] lock_kernel+0x28/0x3c
       [<00000000006d20ec>] rpc_wait_bit_killable+0x64/0x8c
       [<00000000006f0620>] __wait_on_bit+0x64/0xc0
       [<00000000006f06e4>] out_of_line_wait_on_bit+0x68/0x7c
       [<00000000006d2938>] __rpc_execute+0x150/0x2b4
       [<00000000006d2ac0>] rpc_execute+0x24/0x34
       [<00000000006cc338>] rpc_run_task+0x64/0x74
       [<00000000006cc474>] rpc_call_sync+0x58/0x7c
       [<00000000005717b0>] nfs3_rpc_wrapper+0x24/0xa0
       [<0000000000572024>] do_proc_get_root+0x6c/0x10c
       [<00000000005720dc>] nfs3_proc_get_root+0x18/0x5c
       [<000000000056401c>] nfs_get_root+0x34/0x17c
       [<0000000000568adc>] nfs_get_sb+0x9ec/0xa7c
       [<00000000004b7ec8>] vfs_kern_mount+0x44/0xa4
       [<00000000004b7f84>] do_kern_mount+0x30/0xcc
       [<00000000004cf300>] do_mount+0x7c8/0x80c
       [<00000000004ed2a4>] compat_sys_mount+0x224/0x274
       [<0000000000406154>] linux_sparc_syscall32+0x34/0x40

Can be called with the BKL held - and then it schedule()s with the=20
BKL held, creating dependencies. I did the quick hack below (a year=20
ago! :-) but indeed that's probably wrong: we just drop and then=20
re-acquire the BKL at a very low level - inverting the dependency=20
chain.

It's not a problem of the NFS code, it's the probem of=20
vfs_kern_mount taking the BKL.

Maybe it would be better if nfs_get_sb() dropped the BKL (knowing=20
that it's called with the BKL held) - since it does not rely on the=20
BKL? Not rpc_wait_bit_killable().

	Ingo

-------------->
=46rom 352e0d25def53e6b36234e4dc2083ca7f5d712a9 Mon Sep 17 00:00:00 200=
1
=46rom: Ingo Molnar <mingo@elte.hu>
Date: Wed, 14 May 2008 17:31:41 +0200
Subject: [PATCH] remove the BKL: restructure NFS code

the naked schedule() in rpc_wait_bit_killable() caused the BKL to
be auto-dropped in the past.

avoid the immediate hang in such code. Note that this still leaves
some other locking dependencies to be sorted out in the NFS code.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 net/sunrpc/sched.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 6eab9bf..e12e571 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -224,9 +224,15 @@ EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
=20
 static int rpc_wait_bit_killable(void *word)
 {
+	int bkl =3D kernel_locked();
+
 	if (fatal_signal_pending(current))
 		return -ERESTARTSYS;
+	if (bkl)
+		unlock_kernel();
 	schedule();
+	if (bkl)
+		lock_kernel();
 	return 0;
 }
=20
