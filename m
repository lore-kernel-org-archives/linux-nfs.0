From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd threads locked, 2.6.7 & ia64
Date: Sun, 27 Jun 2004 18:48:23 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040628014822.GV10560@polop.usc.edu>
References: <20040627051129.GS10560@polop.usc.edu> <20040627193314.GE3491@fieldses.org> <20040628004602.GU10560@polop.usc.edu> <16607.28296.98868.364827@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="je0mZywpqEo4t1RU"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BelFv-0001a1-PJ
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 18:48:23 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BelFv-0001cL-C0
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 18:48:23 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i5S1mNHx006653
	for <nfs@lists.sourceforge.net>; Sun, 27 Jun 2004 18:48:23 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i5S1mNrX006651
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 18:48:23 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <16607.28296.98868.364827@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--je0mZywpqEo4t1RU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 28, 2004 at 11:04:08AM +1000, Neil Brown alleged:
> On Sunday June 27, garrick@usc.edu wrote:
> > On Sun, Jun 27, 2004 at 03:33:14PM -0400, J. Bruce Fields alleged:
> > >=20
> > > Does Sysrq-T give you any idea where they're stuck?
> >=20
> > I won't know until I get into the machine room tomorrow.  Any info I ca=
n give
> > you from a remote shell?
> >=20
>=20
> # echo t > /proc/sysrq-trigger
> # dmesg

Learn something new every day :)

As you may remember, I have a pair of these ia64 machines.  The one with the
stuck threads is currently only serving 1 xfs filesystem.  The other machine
currently has 8 ext3 filesystems.

Below is 3 different traces of nfsd, all 512 threads seem to follow one of
those 3 patterns.


nfsd          D a000000100560810     0  2462      1          2406  2404 (L-=
TLB)

Call Trace:
 [<a000000100561a00>] schedule+0xd20/0x12a0
                                sp=3De0000000059cfaa0 bsp=3De0000000059c9290
 [<a000000100560810>] __down+0x210/0x320
                                sp=3De0000000059cfab0 bsp=3De0000000059c9230
 [<a000000200723ef0>] linvfs_writev+0x290/0x320 [xfs]
                                sp=3De0000000059cfae0 bsp=3De0000000059c91d8
 [<a000000100126110>] do_readv_writev+0x330/0x500
                                sp=3De0000000059cfc10 bsp=3De0000000059c9170
 [<a0000002003e8be0>] nfsd_write+0x1c0/0x7e0 [nfsd]
                                sp=3De0000000059cfc90 bsp=3De0000000059c90f8
 [<a0000002003fc360>] nfsd3_proc_write+0x180/0x260 [nfsd]
                                sp=3De0000000059cfdf0 bsp=3De0000000059c90a8
 [<a0000002003df030>] nfsd_dispatch+0x290/0x540 [nfsd]
                                sp=3De0000000059cfdf0 bsp=3De0000000059c9058
 [<a00000020039bde0>] svc_process+0x10a0/0x1380 [sunrpc]
                                sp=3De0000000059cfdf0 bsp=3De0000000059c8fe8
 [<a0000002003de8e0>] nfsd+0x500/0x9c0 [nfsd]
                                sp=3De0000000059cfe00 bsp=3De0000000059c8ee8
 [<a00000010001b380>] kernel_thread_helper+0xe0/0x100
                                sp=3De0000000059cfe30 bsp=3De0000000059c8ec0
 [<a000000100009080>] start_kernel_thread+0x20/0x40
                                sp=3De0000000059cfe30 bsp=3De0000000059c8ec0

nfsd          D a000000100560810     0  2400      1          2458  2455 (L-=
TLB)

Call Trace:
 [<a000000100561a00>] schedule+0xd20/0x12a0
                                sp=3De00000003e13fcb0 bsp=3De00000003e1391b8
 [<a000000100560810>] __down+0x210/0x320
                                sp=3De00000003e13fcc0 bsp=3De00000003e139158
 [<a0000002003e7cc0>] nfsd_sync+0x240/0x280 [nfsd]
                                sp=3De00000003e13fcf0 bsp=3De00000003e139118
 [<a0000002003e9360>] nfsd_commit+0x160/0x180 [nfsd]
                                sp=3De00000003e13fcf0 bsp=3De00000003e1390e8
 [<a0000002003fe720>] nfsd3_proc_commit+0x180/0x220 [nfsd]
                                sp=3De00000003e13fdf0 bsp=3De00000003e1390a8
 [<a0000002003df030>] nfsd_dispatch+0x290/0x540 [nfsd]
                                sp=3De00000003e13fdf0 bsp=3De00000003e139058
 [<a00000020039bde0>] svc_process+0x10a0/0x1380 [sunrpc]
                                sp=3De00000003e13fdf0 bsp=3De00000003e138fe8
 [<a0000002003de8e0>] nfsd+0x500/0x9c0 [nfsd]
                                sp=3De00000003e13fe00 bsp=3De00000003e138ee8
 [<a00000010001b380>] kernel_thread_helper+0xe0/0x100
                                sp=3De00000003e13fe30 bsp=3De00000003e138ec0
 [<a000000100009080>] start_kernel_thread+0x20/0x40
                                sp=3De00000003e13fe30 bsp=3De00000003e138ec0


nfsd          D a000000100562bd0     0  2455      1          2400  2399 (L-=
TLB)

Call Trace:
 [<a000000100561a00>] schedule+0xd20/0x12a0
                                sp=3De000000005aa76c0 bsp=3De000000005aa18b0
 [<a000000100562bd0>] io_schedule+0x70/0xa0
                                sp=3De000000005aa76d0 bsp=3De000000005aa1898
 [<a0000001000dbf00>] __lock_page+0x260/0x2e0
                                sp=3De000000005aa76d0 bsp=3De000000005aa1860
 [<a000000100178730>] mpage_writepages+0x290/0x700
                                sp=3De000000005aa7750 bsp=3De000000005aa1780
 [<a0000001000e8c00>] do_writepages+0xe0/0x100
                                sp=3De000000005aa7800 bsp=3De000000005aa1758
 [<a0000001000daf00>] __filemap_fdatawrite+0x160/0x180
                                sp=3De000000005aa7800 bsp=3De000000005aa1738
 [<a00000020072eb60>] xfs_flush_inode+0x40/0x60 [xfs]
                                sp=3De000000005aa7880 bsp=3De000000005aa1718
 [<a0000002006da680>] xfs_flush_space+0x1c0/0x200 [xfs]
                                sp=3De000000005aa7880 bsp=3De000000005aa16f0
 [<a0000002006db2a0>] xfs_iomap_write_delay+0x560/0x760 [xfs]
                                sp=3De000000005aa7880 bsp=3De000000005aa1618
 [<a0000002006da110>] xfs_iomap+0x450/0x800 [xfs]
                                sp=3De000000005aa7930 bsp=3De000000005aa15a0
 [<a00000020072e060>] xfs_bmap+0x40/0x60 [xfs]
                                sp=3De000000005aa7970 bsp=3De000000005aa1558
 [<a00000020071c160>] linvfs_get_block_core+0xe0/0x5c0 [xfs]
                                sp=3De000000005aa7970 bsp=3De000000005aa14f0
 [<a00000010012e790>] __block_prepare_write+0x5f0/0xa60
                                sp=3De000000005aa79b0 bsp=3De000000005aa1468
 [<a00000010012fc80>] block_prepare_write+0x40/0xa0
                                sp=3De000000005aa79e0 bsp=3De000000005aa1438
 [<a00000020071d1d0>] linvfs_prepare_write+0x90/0xc0 [xfs]
                                sp=3De000000005aa79e0 bsp=3De000000005aa1400
 [<a0000001000dfbf0>] generic_file_aio_write_nolock+0x810/0x12e0
                                sp=3De000000005aa79e0 bsp=3De000000005aa1308
 [<a00000020072d540>] xfs_write+0x3e0/0xda0 [xfs]
                                sp=3De000000005aa7ab0 bsp=3De000000005aa1230
 [<a000000200723e10>] linvfs_writev+0x1b0/0x320 [xfs]
                                sp=3De000000005aa7ae0 bsp=3De000000005aa11d8
 [<a000000100126110>] do_readv_writev+0x330/0x500
                                sp=3De000000005aa7c10 bsp=3De000000005aa1170
 [<a0000002003e8be0>] nfsd_write+0x1c0/0x7e0 [nfsd]
                                sp=3De000000005aa7c90 bsp=3De000000005aa10f8
 [<a0000002003fc360>] nfsd3_proc_write+0x180/0x260 [nfsd]
                                sp=3De000000005aa7df0 bsp=3De000000005aa10a8
 [<a0000002003df030>] nfsd_dispatch+0x290/0x540 [nfsd]
                                sp=3De000000005aa7df0 bsp=3De000000005aa1058
 [<a00000020039bde0>] svc_process+0x10a0/0x1380 [sunrpc]
                                sp=3De000000005aa7df0 bsp=3De000000005aa0fe8
 [<a0000002003de8e0>] nfsd+0x500/0x9c0 [nfsd]
                                sp=3De000000005aa7e00 bsp=3De000000005aa0ee8
 [<a00000010001b380>] kernel_thread_helper+0xe0/0x100
                                sp=3De000000005aa7e30 bsp=3De000000005aa0ec0
 [<a000000100009080>] start_kernel_thread+0x20/0x40
                                sp=3De000000005aa7e30 bsp=3De000000005aa0ec0

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--je0mZywpqEo4t1RU
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFA33jm0SBUxJbm9HMRAv9sAJ4nFO7aRJg+JE2+Qi0FIn5G0GQ2IwCgqDKm
210AFTJ85pm9l7eB9sPDpaA=
=WzJd
-----END PGP SIGNATURE-----

--je0mZywpqEo4t1RU--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
