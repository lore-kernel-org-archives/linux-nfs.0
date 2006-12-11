From: "Christian G. Warden" <cwarden@xerus.org>
Subject: nfs3/krb5 mounts fail
Date: Mon, 11 Dec 2006 10:55:47 -0800
Message-ID: <20061211185547.GD25219@xerus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GtqKQ-0002MD-Kq
	for nfs@lists.sourceforge.net; Mon, 11 Dec 2006 10:56:42 -0800
Received: from sage.xerus.org ([64.74.153.194] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GtqKR-0008F1-6l
	for nfs@lists.sourceforge.net; Mon, 11 Dec 2006 10:56:44 -0800
To: nfs@lists.sourceforge.net
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

I'm having a problem where nfs3 filesystems mounted with krb5 fail after
about 2 hours.  In userspace, I get a permission denied error when
trying to access such a filesystem.  Restarting rpc.svcgssd on the
server fixes the problem.

Below is the debugging output from the client and server?  Does anything
indicate where the problem might be?

Thanks,
Christian

Here's the output from rpc.gssd on the client:
Dec 11 10:18:45 www01 rpc.gssd[19639]: handling krb5 upcall
Dec 11 10:18:45 www01 rpc.gssd[19639]: getting credentials for client with uid 1005 for server nfs.bnw.com
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_1005' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_1000_QYEMLn' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_machine_BNW.COM' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_1002' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_1003' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_1008' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_1007' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_33' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_1010' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_1009' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_1000_y4tZKK' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_1000_3h7VQe' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_1006' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: CC file 'krb5cc_1000_I3Clxh' being considered
Dec 11 10:18:45 www01 rpc.gssd[19639]: using FILE:/tmp/krb5cc_1005 as credentials cache for client with uid 1005 for server nfs.bnw.com
Dec 11 10:18:45 www01 rpc.gssd[19639]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_1005
Dec 11 10:18:45 www01 rpc.gssd[19639]: creating context using fsuid 1005 (save_uid 0)
Dec 11 10:18:45 www01 rpc.gssd[19639]: creating tcp client for server nfs.bnw.com
Dec 11 10:18:45 www01 rpc.gssd[19639]: creating context with server nfs@nfs.bnw.com
Dec 11 10:18:45 www01 rpc.gssd[19639]: WARNING: Failed to create krb5 context for user with uid 1005 for server nfs.bnw.com
Dec 11 10:18:45 www01 rpc.gssd[19639]: WARNING: Failed to create krb5 context for user with uid 1005 for server nfs.bnw.com
Dec 11 10:18:45 www01 rpc.gssd[19639]: doing error downcall

Here's the rpc and nfs kernel debug output:
Dec 11 10:18:45 www01 kernel: RPC:     looking up RPCSEC_GSS cred
Dec 11 10:18:45 www01 kernel: RPC: gc'ing RPC credentials for auth ea5851c0
Dec 11 10:18:45 www01 kernel: RPC:      gss_destroy_cred
Dec 11 10:18:45 www01 kernel: RPC:      gss_create_cred for uid 1005, flavor 390003
Dec 11 10:18:45 www01 kernel: RPC: gss_upcall for uid 1005
Dec 11 10:18:45 www01 kernel: RPC:      gss_find_upcall found nothing
Dec 11 10:18:45 www01 kernel: RPC:      gss_fill_context returning 13
Dec 11 10:18:45 www01 kernel: RPC:      gss_find_upcall found msg ea5850c0
Dec 11 10:18:45 www01 kernel: RPC:      gss_destroy_ctx
Dec 11 10:18:45 www01 kernel: RPC:      gss_pipe_downcall returning length 16
Dec 11 10:18:45 www01 kernel: RPC: gss_create_upcall for uid 1005 result -13
Dec 11 10:18:45 www01 kernel: NFS: permission(0:e/525387), mask=0x1, res=-13
Dec 11 10:18:45 www01 kernel: RPC:     looking up RPCSEC_GSS cred
Dec 11 10:18:45 www01 kernel: RPC: gss_upcall for uid 1005
Dec 11 10:18:45 www01 kernel: RPC:      gss_find_upcall found nothing
Dec 11 10:18:45 www01 kernel: RPC:      gss_fill_context returning 13
Dec 11 10:18:45 www01 kernel: RPC:      gss_find_upcall found msg ea5850c0
Dec 11 10:18:45 www01 kernel: RPC:      gss_destroy_ctx
Dec 11 10:18:45 www01 kernel: RPC:      gss_pipe_downcall returning length 16
Dec 11 10:18:45 www01 kernel: RPC: gss_create_upcall for uid 1005 result -13
Dec 11 10:18:45 www01 kernel: NFS: permission(0:e/525387), mask=0x1, res=-13
Dec 11 10:18:45 www01 kernel: RPC:     looking up RPCSEC_GSS cred
Dec 11 10:18:45 www01 kernel: RPC: gss_upcall for uid 1005
Dec 11 10:18:45 www01 kernel: RPC:      gss_find_upcall found nothing
Dec 11 10:18:45 www01 kernel: RPC:      gss_fill_context returning 13
Dec 11 10:18:45 www01 kernel: RPC:      gss_find_upcall found msg ea5850c0
Dec 11 10:18:45 www01 kernel: RPC:      gss_destroy_ctx
Dec 11 10:18:45 www01 kernel: RPC:      gss_pipe_downcall returning length 16
Dec 11 10:18:45 www01 kernel: RPC: gss_create_upcall for uid 1005 result -13
Dec 11 10:18:45 www01 kernel: NFS: permission(0:e/525387), mask=0x1, res=-13
Dec 11 10:18:45 www01 kernel: NFS: revalidating (0:e/525387)
Dec 11 10:18:45 www01 kernel: NFS call  getattr
Dec 11 10:18:45 www01 kernel: RPC: 18632 new task procpid 23069
Dec 11 10:18:45 www01 kernel: RPC: 18632 allocated task
Dec 11 10:18:45 www01 kernel: RPC: 18632 looking up RPCSEC_GSS cred
Dec 11 10:18:45 www01 kernel: RPC: gss_upcall for uid 1005
Dec 11 10:18:45 www01 kernel: RPC:      gss_find_upcall found nothing
Dec 11 10:18:45 www01 kernel: RPC:      gss_fill_context returning 13
Dec 11 10:18:45 www01 kernel: RPC:      gss_find_upcall found msg ea5850c0
Dec 11 10:18:45 www01 kernel: RPC:      gss_destroy_ctx
Dec 11 10:18:45 www01 kernel: RPC:      gss_pipe_downcall returning length 16
Dec 11 10:18:45 www01 kernel: RPC: gss_create_upcall for uid 1005 result -13
Dec 11 10:18:45 www01 kernel: RPC: 18632 release task
Dec 11 10:18:45 www01 kernel: RPC:      rpc_release_client(f3d4be00, 1)
Dec 11 10:18:45 www01 kernel: RPC: 18632 freeing task
Dec 11 10:18:45 www01 kernel: NFS reply getattr: -13
Dec 11 10:18:45 www01 kernel: nfs_revalidate_inode: (0:e/525387) getattr failed, error=-13

On the server, rpc.svcgssd prints out:
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: leaving poll
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: handling null request
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: readline: read 940 chars into buffer of size 2048: \x \x608201cf06092a864886f71201020201006e8201be308201baa003020105a10302010ea20703050020000000a381fb6181f83081f5a003020105a1091b07424e572e434f4da21d301ba003020103a11430121b036e66731b0b6e66732e626e772e636f6da381c33081c0a003020101a103020103a281b30481b0becfb2731645185cc9d1fbff60def080d79e891629d6b09098886c31c5b817b0c3a01a5a45745a70c240a8e0df538efa69ce92c267a07fbd0abdab46a278c9d873b4126f669af3565df813b41da349a6285100843dde816a7f5222d1af987f05692...
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: in_handle:
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: length 0
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: in_tok:
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: length 467
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0000: 6082 01cf 0609 2a86 4886 f712 0102 0201  `.....*.H.......
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0010: 006e 8201 be30 8201 baa0 0302 0105 a103  .n...0..........
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0020: 0201 0ea2 0703 0500 2000 0000 a381 fb61  ........ ......a
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0030: 81f8 3081 f5a0 0302 0105 a109 1b07 424e  ..0...........BN
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0040: 572e 434f 4da2 1d30 1ba0 0302 0103 a114  W.COM..0........
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0050: 3012 1b03 6e66 731b 0b6e 6673 2e62 6e77  0...nfs..nfs.bnw
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0060: 2e63 6f6d a381 c330 81c0 a003 0201 01a1  .com...0........
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0070: 0302 0103 a281 b304 81b0 becf b273 1645  .............s.E
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0080: 185c c9d1 fbff 60de f080 d79e 8916 29d6  .\....`.......).
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0090: b090 9888 6c31 c5b8 17b0 c3a0 1a5a 4574  ....l1.......ZEt
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   00a0: 5a70 c240 a8e0 df53 8efa 69ce 92c2 67a0  Zp.@...S..i...g.
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   00b0: 7fbd 0abd ab46 a278 c9d8 73b4 126f 669a  .....F.x..s..of.
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   00c0: f356 5df8 13b4 1da3 49a6 2851 0084 3dde  .V].....I.(Q..=.
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   00d0: 816a 7f52 22d1 af98 7f05 6926 844b 6f36  .j.R".....i&.Ko6
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   00e0: 4c3c 405c 0380 0f43 6abb 80c2 66f1 4c5e  L<@\...Cj...f.L^
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   00f0: 0209 6dc1 5174 4189 12da 60dd c544 43e5  ..m.QtA...`..DC.
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0100: b624 4d9a 9aa7 0bef dce9 9b5c fa97 5ac4  .$M........\..Z.
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0110: 0ed6 d176 4ef5 9bd7 ad1b f319 b4f8 6422  ...vN.........d"
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0120: e371 764d 4959 3ca3 8078 a481 a630 81a3  .qvMIY<..x...0..
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0130: a003 0201 01a2 819b 0481 989d fc6f 7570  .............oup
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0140: 6f6f b5a6 3438 8003 fcba c734 b4dd 7e57  oo..48.....4..~W
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0150: aa28 d54e 7f3c b17a d928 e307 3ddc f44f  .(.N.<.z.(..=..O
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0160: 3859 758f d14e 43ff a274 ba7e e59e 90e6  8Yu..NC..t.~....
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0170: 11d2 c01d 2808 652f 52cb 34b3 7b37 8b2f  ....(.e/R.4.{7./
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0180: 48dc 2456 00d5 ea96 3505 00d8 12fe 087e  H.$V....5......~
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   0190: 54bb 23a1 49e4 3fe7 79ce 11f1 0e5b b0fd  T.#.I.?.y....[..
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   01a0: 5778 db8f e47b 6d3a 0b18 2294 46ff 2610  Wx...{m:..".F.&.
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   01b0: 563c f1c4 7d42 f037 8b1c 40df 1c32 23e4  V<..}B.7..@..2#.
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   01c0: 05d7 5bd6 a676 4269 bba6 a973 8dae 02c4  ..[..vBi...s....
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]:   01d0: 4671 73                                  Fqs
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: sname = www0002@BNW.COM
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: DEBUG: serialize_krb5_ctx: lucid version!
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: doing downcall
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: \x21010000 2147483647 1005 1004 1 1004 krb5 \x0000000000000000c0c4e2a7b87d0508780398af8212d6a7000000000000000006277e450da5f42d090000002a864886f7120102020400000008000000f7e520922907fba404000000080000000715d062d9f70b54
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: sending null reply
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: writing message: \x \x608201cf06092a864886f71201020201006e8201be308201baa003020105a10302010ea20703050020000000a381fb6181f83081f5a003020105a1091b07424e572e434f4da21d301ba003020103a11430121b036e66731b0b6e66732e626e772e636f6da381c33081c0a003020101a103020103a281b30481b0becfb2731645185cc9d1fbff60def080d79e891629d6b09098886c31c5b817b0c3a01a5a45745a70c240a8e0df538efa69ce92c267a07fbd0abdab46a278c9d873b4126f669af3565df813b41da349a6285100843dde816a7f5222d1af987f056926844b6f364c3c405c03800f436abb80c26...
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: finished handling null request
Dec 11 10:18:35 fs01 rpc.svcgssd[2527]: entering poll

And the nfsd and rpc debug output on the server:
Dec 11 10:18:35 fs01 kernel: svc: socket b26dee00 TCP (listen) state change 10
Dec 11 10:18:35 fs01 kernel: svc: socket b26dee00 served by daemon f1790e00
Dec 11 10:18:35 fs01 kernel: svc: server f1790e00, socket e6e27ac0, inuse=1
Dec 11 10:18:35 fs01 kernel: svc: tcp_recv e6e27ac0 data 0 conn 1 close 0
Dec 11 10:18:35 fs01 kernel: svc: tcp_accept e6e27ac0 sock e9fef900
Dec 11 10:18:35 fs01 kernel: svc: tcp_accept eb714500 allocated
Dec 11 10:18:35 fs01 kernel: svc: socket b26dee00 busy, not enqueued
Dec 11 10:18:35 fs01 kernel: nfsd: connect from 66.102.137.186:0349
Dec 11 10:18:35 fs01 kernel: svc: svc_setup_socket eb714500
Dec 11 10:18:35 fs01 kernel: setting up TCP socket for reading
Dec 11 10:18:35 fs01 kernel: svc: svc_setup_socket created e6db9240 (inet e83bb280)
Dec 11 10:18:35 fs01 kernel: svc: socket e83bb280 served by daemon e6e93600
Dec 11 10:18:35 fs01 kernel: svc: socket b26dee00 served by daemon f3924800
Dec 11 10:18:35 fs01 kernel: svc: got len=0
Dec 11 10:18:35 fs01 kernel: svc: socket b26dee00 busy, not enqueued
Dec 11 10:18:35 fs01 kernel: svc: server f1790e00 waiting for data (to = 900000)
Dec 11 10:18:35 fs01 kernel: svc: server e6e93600, socket e6db9240, inuse=1
Dec 11 10:18:35 fs01 kernel: svc: tcp_recv e6db9240 data 1 conn 0 close 0
Dec 11 10:18:35 fs01 kernel: svc: socket e6db9240 recvfrom(e6db9294, 4) = -11
Dec 11 10:18:35 fs01 kernel: RPC: TCP recvfrom got EAGAIN
Dec 11 10:18:35 fs01 kernel: svc: got len=-11
Dec 11 10:18:35 fs01 kernel: svc: server e6e93600 waiting for data (to = 900000)
Dec 11 10:18:35 fs01 kernel: svc: server f3924800, socket e6e27ac0, inuse=1
Dec 11 10:18:35 fs01 kernel: svc: tcp_recv e6e27ac0 data 0 conn 1 close 0
Dec 11 10:18:35 fs01 kernel: svc: tcp_accept e6e27ac0 sock e9fef900
Dec 11 10:18:35 fs01 kernel: svc: tcp_accept f3563780 allocated
Dec 11 10:18:35 fs01 kernel: svc: got len=0
Dec 11 10:18:35 fs01 kernel: svc: server f3924800 waiting for data (to = 900000)
Dec 11 10:18:35 fs01 kernel: svc: socket e83bb280 TCP data ready (svsk e6db9240)
Dec 11 10:18:35 fs01 kernel: svc: socket e83bb280 served by daemon f3924800
Dec 11 10:18:35 fs01 kernel: svc: server f3924800, socket e6db9240, inuse=1
Dec 11 10:18:35 fs01 kernel: svc: tcp_recv e6db9240 data 1 conn 0 close 0
Dec 11 10:18:35 fs01 kernel: svc: socket e6db9240 recvfrom(e6db9298, 0) = 4
Dec 11 10:18:35 fs01 kernel: svc: TCP record, 532 bytes
Dec 11 10:18:35 fs01 kernel: svc: socket e6db9240 recvfrom(f2dc6214, 3564) = 532
Dec 11 10:18:35 fs01 kernel: svc: TCP complete record (532 bytes)
Dec 11 10:18:35 fs01 kernel: svc: socket e83bb280 served by daemon e6e93600
Dec 11 10:18:35 fs01 kernel: svc: got len=532
Dec 11 10:18:35 fs01 kernel: svc: svc_authenticate (6)
Dec 11 10:18:35 fs01 kernel: RPC:      svcauth_gss: argv->iov_len = 504
Dec 11 10:18:35 fs01 kernel: Want update, refage=120, age=0
Dec 11 10:18:35 fs01 kernel: svc: svc_process dropit
Dec 11 10:18:35 fs01 kernel: svc: socket e6db9240 dropped request
Dec 11 10:18:35 fs01 kernel: svc: socket e83bb280 busy, not enqueued
Dec 11 10:18:35 fs01 kernel: svc: server f3924800 waiting for data (to = 900000)
Dec 11 10:18:35 fs01 kernel: svc: server e6e93600, socket e6db9240, inuse=2
Dec 11 10:18:35 fs01 kernel: svc: tcp_recv e6db9240 data 1 conn 0 close 0
Dec 11 10:18:35 fs01 kernel: svc: socket e6db9240 recvfrom(e6db9294, 4) = -11
Dec 11 10:18:35 fs01 kernel: RPC: TCP recvfrom got EAGAIN
Dec 11 10:18:35 fs01 kernel: svc: got len=-11
Dec 11 10:18:35 fs01 kernel: svc: server e6e93600 waiting for data (to = 900000)
Dec 11 10:18:35 fs01 kernel: RPC:      Succesfully imported new context.
Dec 11 10:18:35 fs01 kernel: revisit queued
Dec 11 10:18:35 fs01 kernel: svc: socket e83bb280 served by daemon e6e93600
Dec 11 10:18:35 fs01 kernel: svc: server e6e93600, socket e6db9240, inuse=1
Dec 11 10:18:35 fs01 kernel: svc: tcp_recv e6db9240 data 0 conn 0 close 0
Dec 11 10:18:35 fs01 kernel: svc: socket e83bb280 served by daemon f3924800
Dec 11 10:18:35 fs01 kernel: svc: got len=532
Dec 11 10:18:35 fs01 kernel: svc: svc_authenticate (6)
Dec 11 10:18:35 fs01 kernel: RPC:      svcauth_gss: argv->iov_len = 504
Dec 11 10:18:35 fs01 kernel: svc: socket e6db9240 sendto([e9ff4000 168... ], 168) = 168 (addr ba896642)
Dec 11 10:18:35 fs01 kernel: svc: socket e83bb280 busy, not enqueued
Dec 11 10:18:35 fs01 kernel: svc: server e6e93600 waiting for data (to = 900000)
Dec 11 10:18:35 fs01 kernel: svc: server f3924800, socket e6db9240, inuse=1
Dec 11 10:18:35 fs01 kernel: svc: tcp_recv e6db9240 data 0 conn 0 close 0
Dec 11 10:18:35 fs01 kernel: svc: socket e6db9240 recvfrom(e6db9294, 4) = -11
Dec 11 10:18:35 fs01 kernel: RPC: TCP recvfrom got EAGAIN
Dec 11 10:18:35 fs01 kernel: svc: got len=-11
Dec 11 10:18:35 fs01 kernel: svc: server f3924800 waiting for data (to = 900000)
Dec 11 10:18:35 fs01 kernel: svc: socket e83bb280 TCP (connected) state change 8 (svsk e6db9240)
Dec 11 10:18:35 fs01 kernel: svc: socket e83bb280 served by daemon f3924800
Dec 11 10:18:35 fs01 kernel: svc: socket e83bb280 TCP data ready (svsk e6db9240)
Dec 11 10:18:35 fs01 kernel: svc: socket e83bb280 busy, not enqueued
Dec 11 10:18:35 fs01 kernel: svc: server f3924800, socket e6db9240, inuse=1
Dec 11 10:18:35 fs01 kernel: svc: tcp_recv e6db9240 data 1 conn 0 close 1
Dec 11 10:18:35 fs01 kernel: svc: svc_delete_socket(e6db9240)
Dec 11 10:18:35 fs01 kernel: svc: server socket destroy delayed
Dec 11 10:18:35 fs01 kernel: svc: got len=0
Dec 11 10:18:35 fs01 kernel: svc: releasing dead socket
Dec 11 10:18:35 fs01 kernel: svc: server f3924800 waiting for data (to = 900000)


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
