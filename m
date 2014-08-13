Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44822 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753907AbaHMVSk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2014 17:18:40 -0400
Date: Thu, 14 Aug 2014 07:18:27 +1000
From: NeilBrown <neilb@suse.de>
To: Ben Greear <greearb@candelatech.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Killing process in D state on mount to dead NFS server.
Message-ID: <20140814071827.702b68e4@notabene.brown>
In-Reply-To: <53EB876A.4090705@candelatech.com>
References: <53DA8443.407@candelatech.com>
	<20140801064217.01852788@notabene.brown>
	<53DAB307.2000206@candelatech.com>
	<53EB876A.4090705@candelatech.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/5XrpQ2ioACF_FIuLiz.Wena"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/5XrpQ2ioACF_FIuLiz.Wena
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 13 Aug 2014 08:42:34 -0700 Ben Greear <greearb@candelatech.com> wro=
te:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> Hello!
>=20
> Did you get a chance to look at the stacks below?

Yes I did, and I replied on Date: Fri, 1 Aug 2014 07:50:53 +1000

The problem is that "fsync" and related functions are not killable.
I think it is generally agreed that this is a bug, and that a fix would
probably be accepted.
I started working on one the other day but haven't got very hard yet (lots =
of
other things to work on).

NeilBrown

>=20
> Thanks,
> Ben
>=20
>=20
> On 07/31/2014 02:20 PM, Ben Greear wrote:
> > On 07/31/2014 01:42 PM, NeilBrown wrote:
> >> On Thu, 31 Jul 2014 11:00:35 -0700 Ben Greear <greearb@candelatech.com=
> wrote:
> >=20
> >>> So, this has been asked all over the interweb for years and years, bu=
t the best answer I can find is to reboot the system or create a fake NFS s=
erver=20
> >>> somewhere with the same IP as the gone-away NFS server.
> >>>=20
> >>> The problem is:
> >>>=20
> >>> I have some mounts to an NFS server that no longer exists (crashed/po=
wered down).
> >>>=20
> >>> I have some processes stuck trying to write to files open on these mo=
unts.
> >>>=20
> >>> I want to kill the process and unmount.
> >>>=20
> >>> umount -l will make the mount go a way, sort of.  But process is stil=
l hung. umount -f complains: umount2:  Device or resource busy umount.nfs:
> >>> /mnt/foo: device is busy
> >>>=20
> >>> kill -9 does not work on process.
> >=20
> >> Kill -1 should work (since about 2.6.25 or so).
> >=20
> > That is -[ONE], right?  Assuming so, it did not work for me.
> >=20
> > Kernel is 3.14.4+, with some of extra patches, but probably nothing tha=
t influences this particular behaviour.
> >=20
> > [root@lf1005-14010010 ~]# cat /proc/3805/stack [<ffffffff811371ba>] sle=
ep_on_page+0x9/0xd [<ffffffff8113738e>] wait_on_page_bit+0x71/0x78=20
> > [<ffffffff8113769a>] filemap_fdatawait_range+0xa2/0x16d [<ffffffff81137=
80e>] filemap_write_and_wait_range+0x3b/0x77 [<ffffffffa0f04734>]
> > nfs_file_fsync+0x37/0x83 [nfs] [<ffffffff811a8d32>] vfs_fsync_range+0x1=
9/0x1b [<ffffffff811a8d4b>] vfs_fsync+0x17/0x19 [<ffffffffa0f05305>]
> > nfs_file_flush+0x6b/0x6f [nfs] [<ffffffff81183e46>] filp_close+0x3f/0x7=
1 [<ffffffff8119c8ae>] __close_fd+0x80/0x98 [<ffffffff81183de5>]
> > SyS_close+0x1c/0x3e [<ffffffff815c55f9>] system_call_fastpath+0x16/0x1b=
 [<ffffffffffffffff>] 0xffffffffffffffff [root@lf1005-14010010 ~]# kill -1 =
3805=20
> > [root@lf1005-14010010 ~]# cat /proc/3805/stack [<ffffffff811371ba>] sle=
ep_on_page+0x9/0xd [<ffffffff8113738e>] wait_on_page_bit+0x71/0x78=20
> > [<ffffffff8113769a>] filemap_fdatawait_range+0xa2/0x16d [<ffffffff81137=
80e>] filemap_write_and_wait_range+0x3b/0x77 [<ffffffffa0f04734>]
> > nfs_file_fsync+0x37/0x83 [nfs] [<ffffffff811a8d32>] vfs_fsync_range+0x1=
9/0x1b [<ffffffff811a8d4b>] vfs_fsync+0x17/0x19 [<ffffffffa0f05305>]
> > nfs_file_flush+0x6b/0x6f [nfs] [<ffffffff81183e46>] filp_close+0x3f/0x7=
1 [<ffffffff8119c8ae>] __close_fd+0x80/0x98 [<ffffffff81183de5>]
> > SyS_close+0x1c/0x3e [<ffffffff815c55f9>] system_call_fastpath+0x16/0x1b=
 [<ffffffffffffffff>] 0xffffffffffffffff
> >=20
> > Thanks, Ben
> >=20
> >> If it doesn't please report the kernel version and cat /proc/$PID/stack
> >=20
> >> for some processes that cannot be killed.
> >=20
> >> NeilBrown
> >=20
> >>>=20
> >>>=20
> >>> Aside from bringing a fake NFS server back up on the same IP, is ther=
e any other way to get these mounts unmounted and the processes killed with=
out=20
> >>> rebooting?
> >>>=20
> >>> Thanks, Ben
> >>>=20
> >=20
> >=20
> >=20
> > -- To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in the body of a message to majordomo@vger.kernel.org More majordomo info =
at
> > http://vger.kernel.org/majordomo-info.html
> >=20
>=20
> - --=20
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>=20
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.13 (GNU/Linux)
> Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/
>=20
> iQEcBAEBAgAGBQJT64dqAAoJELbHqkYeJT4OHC0IAIRB2A8v5msRhXrdd+ybvkwD
> NcOSYOhSsxCHIS5BR5CNLg89zipRuocVCbdLRdtbse8nspMq8PAiQJt3YOkGwzos
> ifcsgxouMUKfmLcFHtJ0maIkWMPIrttPvHJuw67gt7LbHLPsFjlrdrKPv6aGa95m
> 7mCkY/bRniiJYCxrCqixzQpuWfIyVal6FPGtmpydTVh6lq0y05vDEVB8lP5xGyes
> w+I/vJkGf9ddTIDasYJbLwUXECbN3makJxmHNAZf4slQMB5FNNnpeTOqL17u62cY
> F/do8m/zxzztibTZqjKHIhHGDw/huTyQWfRsQ0AA9Exu8/RZKhJlL2EeYlFJWJQ=3D
> =3DhNGY
> -----END PGP SIGNATURE-----
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/5XrpQ2ioACF_FIuLiz.Wena
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU+vWIznsnt1WYoG5AQL+4xAAhXJke4QTSJ2dB6LUks4UG9WTxJMGEydZ
k45sC+E+A3aykQTnQKaSPERJEvPeFMRkQmNFdXWMcc2+gcK+mQi+lKz2XOCcz9Ji
cJ2z1+/fi9VtW858cL8KkDHckEMJcSZrUCMRPQPwOyCidoQHYjqGKpLXH8bzTj/z
PMQpnM6d/FVCQDjztcuSN9B/n9HP0a63BEZi8jElN6h/2tLoaW9pn3jD2x04PhvX
Yr8yCzqXMxoJXKgjOIooH1FoMQ/LhOyWwonbhZSE8iGSUt3FwuHLBWLZPJJyczRR
b0pB/6gXV+rzh4WuPTm6dxyatAEf/LBODlZgcy9Ea8vgkx6bc1zDufaNK5gJ53r3
xwd8D2dZqw0E02MNAfMJvHj5f4WRkQ6QpqkbvIks1vXA2nkMYhh3/HCwSbxDPdXK
cxX9/bFI1Md41z/Mv9j5lnw1/Hms/Fo7z4GrpksrGGhu4LHvR1pjQLfuyjnqVx1r
JGkqBqpRPuxFeVSOhXrifP+Z/zYGYRU7aCGzQcli+qN+tDYqdI+2/YvlevUBb/SG
BQiOft9hARHaB3PtteaCBPcL3dj5sgdnhd8mAaQ57wQy9f7JJSsubCOTDc0pgzsr
npwTBRuE/SuKh8K1xRSC5V07OsdZSGbyXWWA05QaryARg/y/Vzdl/FyShvWzgOdG
QBgjq6AY0WQ=
=DFxk
-----END PGP SIGNATURE-----

--Sig_/5XrpQ2ioACF_FIuLiz.Wena--
