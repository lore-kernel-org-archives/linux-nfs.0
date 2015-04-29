Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55648 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031315AbbD2C5g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2015 22:57:36 -0400
Date: Wed, 29 Apr 2015 12:57:28 +1000
From: NeilBrown <neilb@suse.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150429125728.69ddfc6c@notabene.brown>
In-Reply-To: <553E2784.6020906@gmail.com>
References: <553663B7.7030506@gmail.com>
	<20150421215417.GE13782@fieldses.org>
	<553781E2.1000900@gmail.com>
	<20150422150703.GA1247@fieldses.org>
	<20150423094431.1a8aa68b@notabene.brown>
	<5538EB18.7080802@gmail.com>
	<20150424130045.6bbdb2f9@notabene.brown>
	<553E2784.6020906@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/tDfW/GmMwgufJ3Poys0q6L8"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/tDfW/GmMwgufJ3Poys0q6L8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 27 Apr 2015 20:11:48 +0800 Kinglong Mee <kinglongmee@gmail.com> wro=
te:

> On 4/24/2015 11:00 AM, NeilBrown wrote:
> > On Thu, 23 Apr 2015 20:52:40 +0800 Kinglong Mee <kinglongmee@gmail.com>=
 wrote:
> >=20
> >> On 4/23/2015 7:44 AM, NeilBrown wrote:
> >>> On Wed, 22 Apr 2015 11:07:03 -0400 "J. Bruce Fields" <bfields@fieldse=
s.org>
> >>> wrote:
> >>>>> Reference of dentry/mnt is like a cache, avoids re-finding of them,
> >>>>> it is necessary to store them in svc_export.
> >>>>>
> >>>>> Neil points out another way of 'fs_pin', I will check that.
> >>>>
> >>>> Yes, that'd be interesting.  On a very quick look--I don't understand
> >>>> what it's meant to do at all.  But if it does provide a way to get a
> >>>> callback on umount, that'd certainly be interesting....
> >>>
> >>> Yeah, on a quick look it isn't really obvious at all.
> >>>
> >>> But I didn't read the code.  I read
> >>>  https://lwn.net/Articles/636730/
> >>>
> >>> which says:
> >>>
> >>>     In its place is a mechanism by which an object can be added to a =
vfsmount
> >>>     structure (which represents a mounted filesystem); that object su=
pports=20
> >>>     only one method: kill(). These "pin" objects hang around until th=
e final
> >>>     reference to the vfsmount goes away, at which point each one's ki=
ll() function
> >>>     is called. It thus is a clean mechanism for performing cleanup wh=
en a filesystem
> >>>     goes away.
> >>>
> >>> This is used to close "BSD process accounting" files on umount, and s=
ound
> >>> like the perfect interface for flushing things from the sunrpc cache =
on
> >>> umount.
> >>
> >> I have review those codes in fs/fs_pin.c and kernel/acct.c.
> >> 'fs_pin' is used to fix the race between file->f_path.mnt for acct
> >> and umount, file->f_path.mnt just holds the reference of vfsmount
> >> but not keep busy, umount will check the reference and return busy.
> >>
> >> The logical is same as sunrpc cache for exports.
> >>
> >> Before commit 3064c3563b ("death to mnt_pinned"), acct uses a hack
> >> method, acct get a pin to vfsmount and then put the reference,
> >> so umount finds no other reference and callback those pins in vfsmount,
> >> at last umount success.
> >>
> >> After that commit, besides pin to original vfsmount and put the refere=
nce
> >> of the original vfsmount, acct clone the vfsmount storing in file->f_p=
ath.mnt.
> >>
> >> The different between those two methods is the value of file->f_path.m=
nt,
> >> the first one, it contains the original vfsmnt without reference,
> >> the second one, contains a cloned vfsmnt with reference.
> >>
> >> I have test the first method, pins to vfsmount for all exports cache,
> >> nfsd can work but sometimes will delay or hang at rpc.mountd's calling
> >> of name_to_handle_at, I can't find the reason.
> >=20
> > A kernel stack trace of exactly where it is hanging would help a lot.
>=20
> Witch adding fs_pin to exports, it seems there is a mutex race between
> nfsd and rpc.mountd for locking parent inode.
>=20
> Apr 27 19:57:03 ntest kernel: rpc.mountd      D ffff88006ac5fc28     0  1=
152      1 0x00000000
> Apr 27 19:57:03 ntest kernel: ffff88006ac5fc28 ffff880068c38970 ffff88006=
8c3de60 ffff88006ac5fc08
> Apr 27 19:57:03 ntest kernel: ffff88006ac60000 ffff880035ecf694 ffff88006=
8c3de60 00000000ffffffff
> Apr 27 19:57:03 ntest kernel: ffff880035ecf698 ffff88006ac5fc48 ffffffff8=
177ffd7 0000000000000000
> Apr 27 19:57:03 ntest kernel: Call Trace:
> Apr 27 19:57:03 ntest kernel: [<ffffffff8177ffd7>] schedule+0x37/0x90
> Apr 27 19:57:03 ntest kernel: [<ffffffff8178031e>] schedule_preempt_disab=
led+0xe/0x10
> Apr 27 19:57:03 ntest kernel: [<ffffffff81781e92>] __mutex_lock_slowpath+=
0xb2/0x120
> Apr 27 19:57:03 ntest kernel: [<ffffffff81781f23>] mutex_lock+0x23/0x40
> Apr 27 19:57:03 ntest kernel: [<ffffffff81230714>] lookup_slow+0x34/0xc0
> Apr 27 19:57:03 ntest kernel: [<ffffffff812358ee>] path_lookupat+0x89e/0x=
c60
> Apr 27 19:57:03 ntest kernel: [<ffffffff81205192>] ? kmem_cache_alloc+0x1=
e2/0x260
> Apr 27 19:57:03 ntest kernel: [<ffffffff812367a6>] ? getname_flags+0x56/0=
x200
> Apr 27 19:57:03 ntest kernel: [<ffffffff81235cd7>] filename_lookup+0x27/0=
xc0
> Apr 27 19:57:03 ntest kernel: [<ffffffff81237b53>] user_path_at_empty+0x6=
3/0xd0
> Apr 27 19:57:03 ntest kernel: [<ffffffff8121d722>] ? put_object+0x32/0x60
> Apr 27 19:57:03 ntest kernel: [<ffffffff8121d94d>] ? delete_object_full+0=
x2d/0x40
> Apr 27 19:57:03 ntest kernel: [<ffffffff8123e273>] ? dput+0x33/0x230
> Apr 27 19:57:03 ntest kernel: [<ffffffff81237bd1>] user_path_at+0x11/0x20
> Apr 27 19:57:03 ntest kernel: [<ffffffff81286489>] SyS_name_to_handle_at+=
0x59/0x200
> Apr 27 19:57:03 ntest kernel: [<ffffffff81783f6e>] system_call_fastpath+0=
x12/0x71
> Apr 27 19:57:03 ntest kernel: nfsd            S ffff88006e92b708     0  1=
170      2 0x00000000
> Apr 27 19:57:03 ntest kernel: ffff88006e92b708 ffffffff81c12480 ffff88006=
acbcb80 ffff88006e92b758
> Apr 27 19:57:03 ntest kernel: ffff88006e92c000 ffffffff82290040 ffff88006=
e92b758 ffffffff82290040
> Apr 27 19:57:03 ntest kernel: 00000000fffffff5 ffff88006e92b728 ffffffff8=
177ffd7 0000000100043a09
> Apr 27 19:57:03 ntest kernel: Call Trace:
> Apr 27 19:57:03 ntest kernel: [<ffffffff8177ffd7>] schedule+0x37/0x90
> Apr 27 19:57:03 ntest kernel: [<ffffffff81782e97>] schedule_timeout+0x117=
/0x230
> Apr 27 19:57:03 ntest kernel: [<ffffffff8110b240>] ? internal_add_timer+0=
xb0/0xb0
> Apr 27 19:57:03 ntest kernel: [<ffffffff81780ff3>] wait_for_completion_in=
terruptible_timeout+0xf3/0x150
> Apr 27 19:57:03 ntest kernel: [<ffffffff810cb090>] ? wake_up_state+0x20/0=
x20
> Apr 27 19:57:03 ntest kernel: [<ffffffffa01350cc>] cache_wait_req.isra.10=
+0x9c/0x110 [sunrpc]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa0134760>] ? sunrpc_init_cache_de=
tail+0xc0/0xc0 [sunrpc]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa0135c54>] cache_check+0x1d4/0x38=
0 [sunrpc]
> Apr 27 19:57:03 ntest kernel: [<ffffffff8133248c>] ? inode_doinit_with_de=
ntry+0x48c/0x6a0
> Apr 27 19:57:03 ntest kernel: [<ffffffffa045e132>] exp_get_by_name+0x82/0=
xb0 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffff81776d0a>] ? kmemleak_free+0x3a/0=
xa0
> Apr 27 19:57:03 ntest kernel: [<ffffffff81332210>] ? inode_doinit_with_de=
ntry+0x210/0x6a0
> Apr 27 19:57:03 ntest kernel: [<ffffffff813326bc>] ? selinux_d_instantiat=
e+0x1c/0x20
> Apr 27 19:57:03 ntest kernel: [<ffffffff8123def7>] ? _d_rehash+0x37/0x40
> Apr 27 19:57:03 ntest kernel: [<ffffffff8123f776>] ? d_splice_alias+0xa6/=
0x2d0
> Apr 27 19:57:03 ntest kernel: [<ffffffff812be90b>] ? ext4_lookup+0xdb/0x1=
60
> Apr 27 19:57:03 ntest kernel: [<ffffffffa0460114>] rqst_exp_get_by_name+0=
x64/0x140 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa045a8f6>] nfsd_cross_mnt+0x76/0x=
1b0 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa0475300>] nfsd4_encode_dirent+0x=
160/0x3d0 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa04751a0>] ? nfsd4_encode_getattr=
+0x40/0x40 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa045c631>] nfsd_readdir+0x1c1/0x2=
a0 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa045a1e0>] ? nfsd_direct_splice_a=
ctor+0x20/0x20 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa046bd70>] nfsd4_encode_readdir+0=
x120/0x220 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa047573d>] nfsd4_encode_operation=
+0x7d/0x190 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa046a51d>] nfsd4_proc_compound+0x=
24d/0x6f0 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa0455f83>] nfsd_dispatch+0xc3/0x2=
20 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa012a01b>] svc_process_common+0x4=
3b/0x690 [sunrpc]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa012b133>] svc_process+0x103/0x1b=
0 [sunrpc]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa045596f>] nfsd+0xff/0x170 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffffa0455870>] ? nfsd_destroy+0x80/0x=
80 [nfsd]
> Apr 27 19:57:03 ntest kernel: [<ffffffff810bd378>] kthread+0xd8/0xf0
> Apr 27 19:57:03 ntest kernel: [<ffffffff810bd2a0>] ? kthread_worker_fn+0x=
180/0x180
> Apr 27 19:57:03 ntest kernel: [<ffffffff81784362>] ret_from_fork+0x42/0x70
> Apr 27 19:57:03 ntest kernel: [<ffffffff810bd2a0>] ? kthread_worker_fn+0x=
180/0x180
>=20

Hmm... That looks bad.  I wonder why we haven't hit the deadlock before.

nfsd gets a LOOKUP request for $DIR/name which is a mountpoint, or a READDIR
request for $DIR which contains 'name' which is a mountpoint.

nfsd_lookup_dentry of nfsd_buffered_readdir lock i_mutex on $DIR, then do
the mountpoint check.  If the mounted filesystem is not exported, but the $=
DIR
filesystem has 'crossmnt', an upcall to mountd asks for export information.
When mountd try to do a lookup on the name, it works fine if lookup_fast fi=
nds
the child, but it deadlocks on the parent's i_mutex if it has to go to
lookup_slow.

It should only go to lookup_slow() if:
  - the child isn't in cache .. but as it is mounted on, it must be
  - d_revalidate returns 0

This probably means that $DIR is on an NFS filesystem and it failed the
revalidation for some reason....

Kinglong: can you reproduce this easily?  If so can you enable nfs debuggin=
g=20
and collect the output?
I want to confirm that the dfprintk in nfs_lookup_revalidate is saying that
the name is invalid.

In any case, holding a mutex while waiting for an upcall is probably a bad
idea.  We should try to find a way to work around that...
Any ideas Bruce ?-)

NeilBrown



--Sig_/tDfW/GmMwgufJ3Poys0q6L8
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVUBImDnsnt1WYoG5AQJhExAArH5a7qs+UjAdfGzzba+cPX6rTGuR/pxa
aKyP3CV1oNnprytctMuZB9yeceQNK9sSIZ2N0SsIzEIUUxxrnUraFO3NFuSj/2u1
4hRo92tE7HS0hH5EBdqOtQM5b0Ff7dDu1C95B1r4dTRRyRaVlbV0A7uB5h32RwTa
x+DTDbYdc7hxHm1QLElq0Z8XWtSfKoQ+6h6HtzC6MZXg2CT1ik6+7blFbVFPWlDn
XT1Cx1w0DOXhZTVeZc1I6/+M9PjflpykxVRSFQYNyjfQPwVEZ/j98YZzmO31wdD/
fqwACYhnvcA6f+tQeexsuVkDhZTA/9kopQCJqBQURHL/IEvpjwTyU7tUP0rsiyhW
Lv5gH1tW3naPnSVbPtOzvA0eWdkw4xTBKLpfUn6tzUl0bq7lViffOE9dDL4D/srr
IgouY9TNr+uQPqIOu0xVrNkFzgyhL0ydYhtaLslubt7W+Ettn8DJR04afNx58qmH
HD8/hyoskYqoClKrM1m+hSUHSnElSAMfMdhUBpBlASAbEwZZkYQG7qlvNVRvSej5
EbwCdBZ/4R+JnR7nhNYejgIWkTeH83Xb58CeNOj/5FI8boxW9J0sW31EP0evQkZk
vyT8dDy18S+zEWZQf4ykndMxA0SnTatpQfKxGQTDkFVsTbb6NocF/EkqsRqiUguz
4WLhdjNRwZM=
=nVKG
-----END PGP SIGNATURE-----

--Sig_/tDfW/GmMwgufJ3Poys0q6L8--
