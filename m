From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: Kernel Oops
Date: Mon, 25 Apr 2005 10:47:57 -0700
Message-ID: <1114451277.4353.67.camel@seki.nac.uci.edu>
References: <111aefd05042509317c139b02@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-45r7VlLnFYjswbxUL9Jw"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQ7gw-0000cy-AI
	for nfs@lists.sourceforge.net; Mon, 25 Apr 2005 10:48:18 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DQ7gd-0005mS-Ht
	for nfs@lists.sourceforge.net; Mon, 25 Apr 2005 10:48:18 -0700
To: penney@msu.edu
In-Reply-To: <111aefd05042509317c139b02@mail.gmail.com>
Sender: nfs-admin@lists.sourceforge.net
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


--=-45r7VlLnFYjswbxUL9Jw
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable


IMO, it's worthwhile to iron out the NFS problem, but you'll likely find
that native rsync, rsync over ssh or rsync over rsh will be much faster
than rsync+NFS.  If you have to do rsync+NFS, you might want to use --
whole-file.

On Mon, 2005-04-25 at 12:31 -0400, Chris Penney wrote:
> I have a 2.6.11.5 NFS server that serves a directory /s that had light
> to moderate activity.  I had another file server mounted as /nicfs7
> and was doing a local rsync (moving some data) from /s/path to
> /nicfs7/path when (for some unknown reason) it hung.  I hit ctrl-c and
> then kill -9'ed the two remaining rsync processes.  I then unmounted
> /nicfs7 (which seemed ok right after).  I then saw what I pasted in
> below in messages.
>=20
> At this point NFS service seems ok; however, one of the nfsd threads
> is missing.  I specify to start 128 and only 127 are running.  Is a
> missing nfsd a problem?  It's no clear to me why an nfsd did in the
> first place either when I was using nfs client -> local disk.
>=20
>    Chris
>=20
>=20
>=20
> Apr 25 10:51:31 nicfs2 kernel: nfs_statfs: statfs error =3D 512
> Apr 25 10:53:18 nicfs2 kernel: VFS: Busy inodes after unmount.
> Self-destruct in 5 seconds.  Have a nice day...
> Apr 25 10:54:40 nicfs2 kernel: Unable to handle kernel paging request
> at virtual address 00200038
>  printing eip:
> c01786b0
> *pde =3D 00000000
> Oops: 0000 [#1]
> SMP
> Modules linked in: nls_utf8 af_packet usbhid nfsd exportfs ipv6
> ohci_hcd e1000 i2c_piix4 sworks_agp agpgart i2c_core evdev usbcore jfs
> dm_round_robin dm_multipath dm_mod ext3 jbd qla2300 qla2xxx
> scsi_transport_fc ips sd_mod scsi_mod
> CPU:    1
> EIP:    0060:[<c01786b0>]    Not tainted VLI
> EFLAGS: 00010202   (2.6.11.5)
> EIP is at clear_inode+0x70/0x150
> eax: f5759200   ebx: d8dca3bc   ecx: f5759200   edx: 00200034
> esi: d8dca4e8   edi: da2bd918   ebp: 00000005   esp: dff8bec8
> ds: 007b   es: 007b   ss: 0068
> Process kswapd0 (pid: 185, threadinfo=3Ddff8a000 task=3Ddffeea60)
> Stack: f5759200 d8dca3bc f5759200 c0179780 d8dca3bc da2bd910 c0179813 d8d=
ca3bc
>        c0176c06 00000000 00000080 00000000 dfffea20 c0177004 c014a5cc 000=
7b700
>        00000000 0007876d 00000001 00000000 000000d0 00000020 c0393780 000=
00002
> Call Trace:
>  [<c0179780>] generic_forget_inode+0xf0/0x110
>  [<c0179813>] iput+0x53/0x70
>  [<c0176c06>] prune_dcache+0x176/0x1a0
>  [<c0177004>] shrink_dcache_memory+0x14/0x40
>  [<c014a5cc>] shrink_slab+0x11c/0x170
>  [<c014b9bd>] balance_pgdat+0x24d/0x3a0
>  [<c014bbec>] kswapd+0xdc/0x140
>  [<c0134b60>] autoremove_wake_function+0x0/0x50
>  [<c0103f92>] ret_from_fork+0x6/0x14
>  [<c0134b60>] autoremove_wake_function+0x0/0x50
>  [<c014bb10>] kswapd+0x0/0x140
>  [<c0102345>] kernel_thread_helper+0x5/0x10
> Code: 01 00 00 a8 08 0f 85 83 00 00 00 f6 83 34 01 00 00 20 0f 85 a3
> 00 00 00 8b 83 a0 00 00 00 85 c0 89 c1 74 47 8b 50 28 85 d2 74 20 <8b>
> 52 04 85 d2 74 19 31 d2 8b b4 93 00 01 00 00 85 f6 0f 85 b1
> Apr 25 10:54:40 nicfs2 kernel:  <1>Unable to handle kernel paging
> request at virtual address 5d3e324d
>  printing eip:
> c01797dd
> *pde =3D 00000000
> Oops: 0000 [#2]
> SMP
> Modules linked in: nls_utf8 af_packet usbhid nfsd exportfs ipv6
> ohci_hcd e1000 i2c_piix4 sworks_agp agpgart i2c_core evdev usbcore jfs
> dm_round_robin dm_multipath dm_mod ext3 jbd qla2300 qla2xxx
> scsi_transport_fc ips sd_mod scsi_mod
> CPU:    0
> EIP:    0060:[<c01797dd>]    Not tainted VLI
> EFLAGS: 00010206   (2.6.11.5)
> EIP is at iput+0x1d/0x70
> eax: 5d3e3239   ebx: f134e1cc   ecx: c01b2ba0   edx: f134e1cc
> esi: e1e4276c   edi: e1e42774   ebp: 00000080   esp: f5c23cf0
> ds: 007b   es: 007b   ss: 0068
> Process nfsd (pid: 4052, threadinfo=3Df5c22000 task=3Df63d9020)
> Stack: f134e1cc c0176c06 00000000 00000080 00000000 dfffea20 c0177004 c01=
4a5cc
>        000f3c00 00000000 00078889 00000002 00000000 000001d2 00000040 000=
0000c
>        f5c23da8 c0395ca0 00000000 c014b6b4 00078888 00000000 000001d2 000=
00020
> Call Trace:
>  [<c0176c06>] prune_dcache+0x176/0x1a0
>  [<c0177004>] shrink_dcache_memory+0x14/0x40
>  [<c014a5cc>] shrink_slab+0x11c/0x170
>  [<c014b6b4>] try_to_free_pages+0xc4/0x180
>  [<c014461f>] __alloc_pages+0x1bf/0x3b0
>  [<c0146aa7>] __do_page_cache_readahead+0x107/0x150
>  [<c0146c62>] blockable_page_cache_readahead+0x22/0x60
>  [<c0146d95>] page_cache_readahead+0xf5/0x2a0
>  [<c0140375>] do_generic_mapping_read+0x355/0x510
>  [<f8a62a67>] jfs_open+0x17/0xa0 [jfs]
>  [<c0140a7b>] generic_file_sendfile+0x6b/0x90
>  [<f8b64f00>] nfsd_read_actor+0x0/0x100 [nfsd]
>  [<f8b65262>] nfsd_read+0x262/0x360 [nfsd]
>  [<f8b64f00>] nfsd_read_actor+0x0/0x100 [nfsd]
>  [<f8b6c2c5>] nfsd3_proc_read+0xd5/0x170 [nfsd]
>  [<f8b6dfc0>] nfs3svc_decode_readargs+0x0/0x190 [nfsd]
>  [<f8b61696>] nfsd_dispatch+0x136/0x200 [nfsd]
>  [<c0322587>] svc_authenticate+0x87/0xe0
>  [<c031fae9>] svc_process+0x409/0x620
>  [<f8b613d6>] nfsd+0x196/0x320 [nfsd]
>  [<f8b61240>] nfsd+0x0/0x320 [nfsd]
>  [<c0102345>] kernel_thread_helper+0x5/0x10
> Code: fe ff ff 8d 74 26 00 8d bc 27 00 00 00 00 53 85 c0 89 c3 74 4c
> 83 bb 2c 01 00 00 20 8b 80 a0 00 00 00 8b 40 24 74 3c 85 c0 74 07 <8b>
> 50 14 85 d2 75 3c 8d 43 24 ba 6c 6e 39 c0 e8 5f 8a 08 00 85
>=20
>=20
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_ide95&alloc_id=14396&op=CCk
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--=-45r7VlLnFYjswbxUL9Jw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD4DBQBCbS1No0feVm00f/8RAiGlAJ9GPC4/vW8IfvUnBlR7I8IhsoKF8wCY3Nba
v/pbR+Y5aXY4HVRlBAMpnw==
=Djrg
-----END PGP SIGNATURE-----

--=-45r7VlLnFYjswbxUL9Jw--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
