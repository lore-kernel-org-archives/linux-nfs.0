Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52978 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751023AbbEGWmi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 18:42:38 -0400
Date: Fri, 8 May 2015 08:42:30 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150508084230.716439d5@notabene.brown>
In-Reply-To: <20150507153116.GI27106@fieldses.org>
References: <553E2784.6020906@gmail.com>
	<20150429125728.69ddfc6c@notabene.brown>
	<20150429191934.GA23980@fieldses.org>
	<20150430075225.21a71056@notabene.brown>
	<20150430213602.GB9509@fieldses.org>
	<20150501115326.51f5613a@notabene.brown>
	<20150504220130.GB16827@fieldses.org>
	<5548CBA3.9080608@gmail.com>
	<20150505141801.GB27106@fieldses.org>
	<20150505155203.GD27106@fieldses.org>
	<20150507153116.GI27106@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/ktdFD05XGQq=qoBsYEEE4=Q"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ktdFD05XGQq=qoBsYEEE4=Q
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 7 May 2015 11:31:16 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, May 05, 2015 at 11:52:03AM -0400, J. Bruce Fields wrote:
> > On Tue, May 05, 2015 at 10:18:01AM -0400, J. Bruce Fields wrote:
> > > On Tue, May 05, 2015 at 09:54:43PM +0800, Kinglong Mee wrote:
> > > > On 5/5/2015 6:01 AM, J. Bruce Fields wrote:
> > > > > + * Unlike lookup_one_len, it should be called without the parent
> > > > > + * i_mutex held, and will take the i_mutex itself if necessary.
> > > > > + */
> > > > > +struct dentry *lookup_one_len_unlocked(const char *name,
> > > > > +				       struct dentry *base, int len)
> > > > > +{
> > > > > +	struct qstr this;
> > > > > +	unsigned int c;
> > > > > +	int err;
> > > > > +	struct dentry *ret;
> > > > > +
> > > > > +	WARN_ON_ONCE(!mutex_is_locked(&base->d_inode->i_mutex));
> > > >=20
> > > > Remove this line.
> > >=20
> > > Whoops, thanks.
> > >=20
> > > > > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > > > > index a30e79900086..cc7995762190 100644
> > > > > --- a/fs/nfsd/vfs.c
> > > > > +++ b/fs/nfsd/vfs.c
> > > > > @@ -217,6 +217,13 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, s=
truct svc_fh *fhp,
> > > > >  		host_err =3D PTR_ERR(dentry);
> > > > >  		if (IS_ERR(dentry))
> > > > >  			goto out_nfserr;
> > > > > +		if (!S_ISREG(d_inode(dentry)->i_mode)) {
> > > >=20
> > > > Got a crash here tested by pynfs,
> > >=20
> > > OK, I guess I just forgot to take into account negative dentries.
> > > Testing that now with (!(d_inode(dentry) && S_ISREG(..))).
> >=20
> > And I also forgot nfs3xdr.c.
>=20
> But, this doesn't look good.
>=20
> OK, to be fair I'm not sure whether this was already happening before this
> patch.

None of the stacks show any code that we changed, so I'm guessing it is a
separate issues as you hint at.

If I didn't have a list as long as my arm of things I really should be doin=
g,
I'd go diving into the XFS code ....

NeilBrown

>=20
> --b.
>=20
> [57287.226846] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [57287.227499] [ INFO: possible circular locking dependency detected ]
> [57287.228009] 4.1.0-rc2-22946-g6c942d3 #174 Not tainted
> [57287.228009] -------------------------------------------------------
> [57287.228009] updatedb/19312 is trying to acquire lock:
> [57287.228009]  (&mm->mmap_sem){++++++}, at: [<ffffffff811980bf>] might_f=
ault+0x5f/0xb0
> [57287.228009]=20
> but task is already holding lock:
> [57287.228009]  (&xfs_dir_ilock_class){++++..}, at: [<ffffffff81400c1a>] =
xfs_ilock+0x10a/0x2e0
> [57287.228009]=20
> which lock already depends on the new lock.
>=20
> [57287.228009]=20
> the existing dependency chain (in reverse order) is:
> [57287.228009]=20
> -> #2 (&xfs_dir_ilock_class){++++..}:
> [57287.228009]        [<ffffffff810cf1c2>] __lock_acquire+0x15f2/0x1920
> [57287.228009]        [<ffffffff810cfe40>] lock_acquire+0xc0/0x280
> [57287.228009]        [<ffffffff810c8e0d>] down_read_nested+0x4d/0x70
> [57287.228009]        [<ffffffff81400c1a>] xfs_ilock+0x10a/0x2e0
> [57287.228009]        [<ffffffff81400e68>] xfs_ilock_attr_map_shared+0x38=
/0x50
> [57287.228009]        [<ffffffff8139b9e1>] xfs_attr_get+0xc1/0x180
> [57287.228009]        [<ffffffff8140ff87>] xfs_xattr_get+0x37/0x50
> [57287.228009]        [<ffffffff811e866f>] generic_getxattr+0x4f/0x70
> [57287.228009]        [<ffffffff816535d2>] inode_doinit_with_dentry+0x152=
/0x670
> [57287.228009]        [<ffffffff81657f8b>] sb_finish_set_opts+0xdb/0x260
> [57287.228009]        [<ffffffff81658604>] selinux_set_mnt_opts+0x2c4/0x6=
00
> [57287.228009]        [<ffffffff816589ff>] superblock_doinit+0xbf/0xd0
> [57287.228009]        [<ffffffff81658a6d>] selinux_sb_kern_mount+0x3d/0xa0
> [57287.228009]        [<ffffffff8164efa6>] security_sb_kern_mount+0x16/0x=
20
> [57287.228009]        [<ffffffff811c29dd>] mount_fs+0x7d/0x190
> [57287.228009]        [<ffffffff811e2258>] vfs_kern_mount+0x68/0x160
> [57287.228009]        [<ffffffff811e58b4>] do_mount+0x204/0xc60
> [57287.228009]        [<ffffffff811e660f>] SyS_mount+0x6f/0xb0
> [57287.228009]        [<ffffffff81b6b697>] system_call_fastpath+0x12/0x6f
> [57287.228009]=20
> -> #1 (&isec->lock){+.+.+.}:
> [57287.228009]        [<ffffffff810cf1c2>] __lock_acquire+0x15f2/0x1920
> [57287.228009]        [<ffffffff810cfe40>] lock_acquire+0xc0/0x280
> [57287.228009]        [<ffffffff81b675f3>] mutex_lock_nested+0x63/0x400
> [57287.228009]        [<ffffffff81653525>] inode_doinit_with_dentry+0xa5/=
0x670
> [57287.228009]        [<ffffffff81653b0c>] selinux_d_instantiate+0x1c/0x20
> [57287.228009]        [<ffffffff8164eb2b>] security_d_instantiate+0x1b/0x=
30
> [57287.228009]        [<ffffffff811d9ce4>] d_instantiate+0x54/0x80
> [57287.228009]        [<ffffffff811894fe>] __shmem_file_setup+0xce/0x250
> [57287.228009]        [<ffffffff8118c5f8>] shmem_zero_setup+0x28/0x70
> [57287.228009]        [<ffffffff811a1818>] mmap_region+0x5c8/0x5e0
> [57287.228009]        [<ffffffff811a1ba3>] do_mmap_pgoff+0x373/0x420
> [57287.228009]        [<ffffffff8118cb00>] vm_mmap_pgoff+0x90/0xc0
> [57287.228009]        [<ffffffff811a0000>] SyS_mmap_pgoff+0x1b0/0x240
> [57287.228009]        [<ffffffff81008c92>] SyS_mmap+0x22/0x30
> [57287.228009]        [<ffffffff81b6b697>] system_call_fastpath+0x12/0x6f
> [57287.228009]=20
> -> #0 (&mm->mmap_sem){++++++}:
> [57287.228009]        [<ffffffff810ccafb>] check_prev_add+0x51b/0x860
> [57287.228009]        [<ffffffff810cf1c2>] __lock_acquire+0x15f2/0x1920
> [57287.228009]        [<ffffffff810cfe40>] lock_acquire+0xc0/0x280
> [57287.228009]        [<ffffffff811980ec>] might_fault+0x8c/0xb0
> [57287.228009]        [<ffffffff811d3ff2>] filldir+0x92/0x120
> [57287.228009]        [<ffffffff813ec51a>] xfs_dir2_sf_getdents.isra.10+0=
x1ba/0x220
> [57287.228009]        [<ffffffff813ed0de>] xfs_readdir+0x15e/0x300
> [57287.228009]        [<ffffffff813f116b>] xfs_file_readdir+0x2b/0x30
> [57287.228009]        [<ffffffff811d3dca>] iterate_dir+0x9a/0x140
> [57287.228009]        [<ffffffff811d42b1>] SyS_getdents+0x81/0x100
> [57287.228009]        [<ffffffff81b6b697>] system_call_fastpath+0x12/0x6f
> [57287.228009]=20
> other info that might help us debug this:
>=20
> [57287.228009] Chain exists of:
>   &mm->mmap_sem --> &isec->lock --> &xfs_dir_ilock_class
>=20
> [57287.228009]  Possible unsafe locking scenario:
>=20
> [57287.228009]        CPU0                    CPU1
> [57287.228009]        ----                    ----
> [57287.228009]   lock(&xfs_dir_ilock_class);
> [57287.228009]                                lock(&isec->lock);
> [57287.228009]                                lock(&xfs_dir_ilock_class);
> [57287.228009]   lock(&mm->mmap_sem);
> [57287.228009]=20
>  *** DEADLOCK ***
>=20
> [57287.228009] 2 locks held by updatedb/19312:
> [57287.228009]  #0:  (&type->i_mutex_dir_key#5){+.+.+.}, at: [<ffffffff81=
1d3d91>] iterate_dir+0x61/0x140
> [57287.228009]  #1:  (&xfs_dir_ilock_class){++++..}, at: [<ffffffff81400c=
1a>] xfs_ilock+0x10a/0x2e0
> [57287.228009]=20
> stack backtrace:
> [57287.228009] CPU: 0 PID: 19312 Comm: updatedb Not tainted 4.1.0-rc2-229=
46-g6c942d3 #174
> [57287.228009] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S 1.7.5-20140709_153950- 04/01/2014
> [57287.228009]  ffffffff82c61ed0 ffff880060d0faa8 ffffffff81b61a1a 000000=
0080000001
> [57287.228009]  ffffffff82c345d0 ffff880060d0faf8 ffffffff810cb843 000000=
0000000000
> [57287.228009]  ffff880060d0fb28 0000000000000000 0000000000000001 000000=
0000000000
> [57287.228009] Call Trace:
> [57287.228009]  [<ffffffff81b61a1a>] dump_stack+0x4f/0x7b
> [57287.228009]  [<ffffffff810cb843>] print_circular_bug+0x203/0x310
> [57287.228009]  [<ffffffff810ccafb>] check_prev_add+0x51b/0x860
> [57287.228009]  [<ffffffff810ce018>] ? __lock_acquire+0x448/0x1920
> [57287.228009]  [<ffffffff810cf1c2>] __lock_acquire+0x15f2/0x1920
> [57287.228009]  [<ffffffff810cfe40>] lock_acquire+0xc0/0x280
> [57287.228009]  [<ffffffff811980bf>] ? might_fault+0x5f/0xb0
> [57287.228009]  [<ffffffff811980ec>] might_fault+0x8c/0xb0
> [57287.228009]  [<ffffffff811980bf>] ? might_fault+0x5f/0xb0
> [57287.228009]  [<ffffffff811d3ff2>] filldir+0x92/0x120
> [57287.228009]  [<ffffffff81400e24>] ? xfs_ilock_data_map_shared+0x34/0x40
> [57287.228009]  [<ffffffff813ec51a>] xfs_dir2_sf_getdents.isra.10+0x1ba/0=
x220
> [57287.228009]  [<ffffffff81400c1a>] ? xfs_ilock+0x10a/0x2e0
> [57287.228009]  [<ffffffff813ed0de>] xfs_readdir+0x15e/0x300
> [57287.228009]  [<ffffffff810cd6b5>] ? mark_held_locks+0x75/0xa0
> [57287.228009]  [<ffffffff81b6800a>] ? mutex_lock_killable_nested+0x27a/0=
x4e0
> [57287.228009]  [<ffffffff813f116b>] xfs_file_readdir+0x2b/0x30
> [57287.228009]  [<ffffffff811d3dca>] iterate_dir+0x9a/0x140
> [57287.228009]  [<ffffffff811dfceb>] ? __fget_light+0x7b/0xa0
> [57287.228009]  [<ffffffff811d42b1>] SyS_getdents+0x81/0x100
> [57287.228009]  [<ffffffff811d3f60>] ? fillonedir+0xf0/0xf0
> [57287.228009]  [<ffffffff81b6b697>] system_call_fastpath+0x12/0x6f
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/ktdFD05XGQq=qoBsYEEE4=Q
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVUvqVjnsnt1WYoG5AQIc7Q//dduxM6mdCWz10LfVG2sB+KOpuHUa+AIk
PXarzr1ctna/XM8uUy7vjzbIrbTfN7Braw8wRiOr9JiB1ctnymfc3b+1C9cJnYTg
wPbMBo1DSefjABB/PwHmWyr+FbvMIg2l5JNUPz/m07oouuhNENcuAumc8hs1Q7dt
mDEXShB/ckjMZesOEPDjC3SHvxDRBT9EuH3BKyuypvC+BQgD7MJ2mNImX32B2/mb
N2dxhNM3saaD4WzEUzAEyfW5FpaPZeEkWAPBYhxJVEwmrX3TA/et2t5+6Ahw9HUN
RR/c/Zk0deyncIOEmWSV7lDh/p/ZhqVmnN9OK7lSqdZ7krQEjdTRlMDZDBlLnsXI
q++J5509tk+exxOhJHON0nNjcn28xNKZaH2r3iuStH1+2Wkl6/5n6ds3SHj0n+Yr
wfSHxExv0qmHy1hk4kYSKKVdQmnP/fWLtBMIeDsZVJO6kQ1J13N2Ka0n3/EwvS3A
osZAXNCJ7hpRB5u0daCQYJrwz1ajMS1Eo5eiJdWcrtNVsye6qb0qdK/WqwOsSJxl
bN2vGfljFZ05cbu6lEyjvMr06HQu2Y02Z3tF9HIocaGEiifHcQETL4KVnW8Fj/Sn
4pCaIYdCeffsmEeY3fElNUoDWrEnkCrvSnx9Tp8J0fDRrds/ZEMZvme91kMJ+aoq
Jk8ohK1/Vxk=
=eA+S
-----END PGP SIGNATURE-----

--Sig_/ktdFD05XGQq=qoBsYEEE4=Q--
