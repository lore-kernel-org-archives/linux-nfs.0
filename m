From: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
Subject: nfsd page allocation failure
Date: Sat, 21 Apr 2007 12:02:01 +0200
Message-ID: <200704211202.05125.ulrich.gemkow@ikr.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0830891773=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HfCQj-0007SW-1g
	for nfs@lists.sourceforge.net; Sat, 21 Apr 2007 03:02:57 -0700
Received: from wall.ikr.uni-stuttgart.de ([129.69.170.1])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HfCQl-0003sj-0b
	for nfs@lists.sourceforge.net; Sat, 21 Apr 2007 03:02:59 -0700
Received: from netsrv1.ikr.uni-stuttgart.de (netsrv1-c [10.11.12.12])
	by wall.ikr.uni-stuttgart.de (Postfix) with ESMTP id 873E356CC2
	for <nfs@lists.sourceforge.net>; Sat, 21 Apr 2007 12:02:05 +0200 (CEST)
Received: from ikr.uni-stuttgart.de (pc150 [10.21.21.150])
	by netsrv1.ikr.uni-stuttgart.de (Postfix) with SMTP id 3FFA5BC07E
	for <nfs@lists.sourceforge.net>; Sat, 21 Apr 2007 12:02:05 +0200 (CEST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0830891773==
Content-Type: multipart/signed; boundary="nextPart5744188.Yp8vSsvj4D";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart5744188.Yp8vSsvj4D
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,

since updating from linux 2.6.17 to 2.6.20 we have nfs problems with
our file server. After some time nfsd has problems with memory alloc
(dmesg see below) and after some more time the server hangs (probably
because of out-of-memory).

I am posting this problem to this list because I am not able to
device whether this is a nfsd problem, a memory leak in the kernel
in another subsystem or something else. The server has lots of
memory (output of /proc/meminfo also attached). Up to now only
nfsd was affected, other daemons had no problem.

If more info is required I can provide this but we have to revert
to linux 2.6.17 now for stability.

Thanks for any hint and greetings

Ulrich

part of dmesg output=20
=2D-------------------

nfsd: page allocation failure. order:1, mode:0x20
 [<c013d2f9>] __alloc_pages+0x2cc/0x2e8
 [<c015237c>] cache_alloc_refill+0x2cb/0x4fa
 [<c015260a>] __kmalloc+0x5f/0x61
 [<c037d104>] __alloc_skb+0x47/0xf6
 [<c03ac73d>] tcp_collapse+0x19f/0x370
 [<c03aca16>] tcp_prune_queue+0x108/0x2e7
 [<c03ad403>] tcp_data_queue+0x80e/0xbb0
 [<c0390030>] __nf_conntrack_find+0x19/0x118
 [<c03933ae>] tcp_packet+0x0/0xba2
 [<c039104b>] nf_conntrack_in+0x236/0x4b3
 [<c03e3900>] _read_lock_bh+0x8/0x17
 [<c03c9ce5>] ipt_do_table+0x1e3/0x306
 [<c03aee49>] tcp_rcv_established+0x399/0x6f0
 [<c03b4ada>] tcp_v4_do_rcv+0xa1/0x2db
 [<c038edd0>] nf_iterate+0x60/0x84
 [<c03b6a49>] tcp_v4_rcv+0x74c/0x767
 [<c038eefa>] nf_hook_slow+0x4d/0xbd
 [<c039c4b4>] ip_local_deliver+0xd0/0x1ec
 [<c039bcdb>] ip_local_deliver_finish+0x0/0x14c
 [<c039c1b0>] ip_rcv+0x29a/0x4ce
 [<c039ba80>] ip_rcv_finish+0x0/0x25b
 [<c03d12cc>] packet_rcv_spkt+0xd7/0x14b
 [<c0381108>] netif_receive_skb+0x167/0x1e5
 [<c0382869>] process_backlog+0x7d/0x106
 [<c038295b>] net_rx_action+0x69/0x107
 [<c0121985>] __do_softirq+0x71/0xd6
 [<c0121a21>] do_softirq+0x37/0x39
 [<c01052fb>] do_IRQ+0x45/0x7a
 [<c010367f>] common_interrupt+0x23/0x28
 [<c01387e0>] unlock_page+0x8/0x23
 [<c0139e2a>] generic_file_buffered_write+0x388/0x6ab
 [<c013a427>] __generic_file_aio_write_nolock+0x2da/0x5d2
 [<c0165b33>] ifind_fast+0x2c/0x6d
 [<c03e2d88>] __mutex_lock_slowpath+0x52/0x81
 [<c013a774>] generic_file_aio_write+0x55/0xc5
 [<c01ccfb5>] find_exported_dentry+0x68/0x4d0
 [<c0190154>] ext3_file_write+0x24/0x96
 [<c0190130>] ext3_file_write+0x0/0x96
 [<c0154cf4>] do_sync_readv_writev+0xcb/0x107
 [<c03a155a>] ip_output+0x133/0x269
 [<c012e734>] autoremove_wake_function+0x0/0x37
 [<c03df780>] sunrpc_cache_lookup+0x50/0x124
 [<c0154b5f>] rw_copy_check_uvector+0x4d/0xe7
 [<c0155417>] do_readv_writev+0x9e/0x179
 [<c0190130>] ext3_file_write+0x0/0x96
 [<c0129442>] set_current_groups+0x22e/0x238
 [<c01a1328>] start_this_handle+0x7b/0x3bb
 [<c015552e>] vfs_writev+0x3c/0x50
 [<c01d0e9d>] nfsd_vfs_write+0xb0/0x306
 [<c0153bd9>] dentry_open+0x2b/0x5c
 [<c01d1516>] nfsd_open+0x105/0x174
 [<c01d17fa>] nfsd_write+0xf1/0xf5
 [<c01d8193>] nfsd3_proc_write+0x108/0x130
 [<c01cd657>] nfsd_dispatch+0x82/0x1b9
 [<c03d8ed1>] svc_process+0x3b8/0x717
 [<c03db956>] svc_recv+0x222/0x40c
 [<c01cdc4d>] nfsd+0x16a/0x27d
 [<c01cdae3>] nfsd+0x0/0x27d
 [<c01038bf>] kernel_thread_helper+0x7/0x18
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd=
:   0
CPU    1: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd=
:   0
Normal per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd: 127   Cold: hi:   62, btch:  15 usd=
:   3
CPU    1: Hot: hi:  186, btch:  31 usd: 161   Cold: hi:   62, btch:  15 usd=
:  47
HighMem per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:  26   Cold: hi:   62, btch:  15 usd=
:  14
CPU    1: Hot: hi:  186, btch:  31 usd:  22   Cold: hi:   62, btch:  15 usd=
:  11
Active:54070 inactive:85111 dirty:8655 writeback:0 unstable:0 free:768231 s=
lab:90908 mapped:1675 pagetables:137
DMA free:3532kB min:68kB low:84kB high:100kB active:0kB inactive:4kB presen=
t:16256kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 873 3921
Normal free:9264kB min:3744kB low:4680kB high:5616kB active:173672kB inacti=
ve:299932kB present:894080kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 24383
HighMem free:3060368kB min:512kB low:3780kB high:7052kB active:42608kB inac=
tive:40252kB present:3121092kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 23*4kB 0*8kB 1*16kB 1*32kB 1*64kB 0*128kB 1*256kB 0*512kB 1*1024kB 1*2=
048kB 0*4096kB =3D 3532kB
Normal: 2122*4kB 9*8kB 0*16kB 0*32kB 1*64kB 1*128kB 0*256kB 1*512kB 0*1024k=
B 0*2048kB 0*4096kB =3D 9264kB
HighMem: 0*4kB 2810*8kB 3356*16kB 2542*32kB 1763*64kB 1163*128kB 669*256kB =
386*512kB 227*1024kB 122*2048kB 437*4096kB =3D 3060368kB
Swap cache: add 0, delete 0, find 0/0, race 0+0
=46ree swap  =3D 4194296kB
Total swap =3D 4194296kB
=46ree swap:       4194296kB
1015792 pages of RAM
786416 pages of HIGHMEM
9331 reserved pages
135428 pages shared
0 pages swap cached
8655 pages dirty
0 pages writeback
1675 pages mapped
90767 pages slab
137 pages pagetables

/proc/meminfo
=2D------------

MemTotal:      4025844 kB
MemFree:         97940 kB
Buffers:        264352 kB
Cached:        3312288 kB
SwapCached:          0 kB
Active:         430160 kB
Inactive:      3159912 kB
HighTotal:     3145664 kB
HighFree:         9264 kB
LowTotal:       880180 kB
LowFree:         88676 kB
SwapTotal:     4194296 kB
SwapFree:      4194296 kB
Dirty:             252 kB
Writeback:           0 kB
AnonPages:       11076 kB
Mapped:           7956 kB
Slab:           305072 kB
SReclaimable:   275968 kB
SUnreclaim:      29104 kB
PageTables:        656 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   6207216 kB
Committed_AS:    59340 kB
VmallocTotal:   118776 kB
VmallocUsed:      2776 kB
VmallocChunk:   115568 kB

=2D-=20
|-----------------------------------------------------------------------
| Ulrich Gemkow
| University of Stuttgart
| Institute of Communication Networks and Computer Engineering (IKR)
|-----------------------------------------------------------------------

--nextPart5744188.Yp8vSsvj4D
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQBGKeEa7bxSwnjsAMgRAmbKAKCRA4fJ7+6s3Xehar7rDieFP/3RdACg4jWa
1jfsJ7+4AoFKLRXtW/uBRxI=
=IcWQ
-----END PGP SIGNATURE-----

--nextPart5744188.Yp8vSsvj4D--


--===============0830891773==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0830891773==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0830891773==--
