From: "=?iso-8859-1?Q?linux?=" <linux@karasik.org>
Subject: Re: Q: How can I run nfs-utils on MIPS uclibc-based distro 	with kernel 2.6?
Date: Wed, 04 Jan 2006 10:35:19 +0000
Message-ID: <20060104103519.9306.qmail@hoster903.com>
Reply-To: "=?iso-8859-1?Q?linux?=" <linux@karasik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: "" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eu5zF-0006v9-Cn
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 02:35:21 -0800
Received: from hoster903.com ([66.211.137.15])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1Eu5zE-0000bm-V2
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 02:35:21 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

According to Vincent Roqueta (I received his  reply to my private address=
)   nfs-utils v.1.0.1 shouldn't work with kernels 2.6.

Vitaly


>  -------Original Message-------
>  From: Trond Myklebust <trond.myklebust@fys.uio.no>
>  Subject: Re: [NFS] Q: How can I run nfs-utils on MIPS uclibc-based dis=
tro 	with kernel 2.6?
>  Sent: 04 Jan '06 09:56
> =20
>  On Wed, 2006-01-04 at 08:43 +0000, linux wrote:
>  > I'm trying to install nfs-utils on my mips kernel2.6 and uclibc-base=
d linux box.
>  >
>  > The first thing I did it's compilation the latest stable=A0=A01.0.7 =
version with mips uclibc-based toolchain. comiplation failed with
>  > ../../support/lib/libexport.a(client.o)(.text+0x718):/disks/uilstore=
/disk604/vkarasik/CDA/NFS-UTILS/mike/nfs-utils-1.0.7/support/export/clien=
t.c:385: undefined reference to `innetgr'
>  > message - as far as I understand, because uclibc misses some NIS-rel=
ated functions.
>  >
>  > We were able to build=A0=A0binaries using 1.0.1 nfs-utils. NFS serve=
r starts but each time when client access NFS share there is error messag=
es in dmesg log and nfs works very-very slowly.=A0=A0May be nfs-utils 1.0=
.1 isn't supposed to work with kernel 2.6?
>  >
>  > Any ideas are welcome!
>  > TIA, Vitaly
>  > PS: this is errors from dmesg:
>  > Badness in local_bh_enable at kernel/softirq.c:140
>  > Call Trace:
>  >=A0=A0[<8002f498>] local_bh_enable+0x74/0x9c
>  >=A0=A0[<800231ac>] __wake_up_common+0x68/0xb8
>  >=A0=A0[<8025d48c>] svc_write_space+0x48/0xb8
>  >=A0=A0[<8025d48c>] svc_write_space+0x48/0xb8
>  >=A0=A0[<801dffdc>] sock_wfree+0x104/0x184
>  >=A0=A0[<8002323c>] __wake_up+0x40/0x7c
>  >=A0=A0[<c04d73f4>] BDBG_P_TestAndPrintHeader+0x28/0xa0 [balcore]
>  >=A0=A0[<8003db48>] queue_work+0x58/0xdc
>  >=A0=A0[<801e3320>] __kfree_skb+0xb8/0x150
>  >=A0=A0[<8003dabc>] __queue_work+0x6c/0xa0
>  >=A0=A0[<c04feff0>] BINT_Isr+0x15c/0x21c [balcore]
>  >=A0=A0[<8017b754>] bcmemac_net_xmit+0xbc/0x7d0
>  >=A0=A0[<8017d0a8>] tx_reclaim_timer+0x0/0x104
>  >=A0=A0[<8017d0cc>] tx_reclaim_timer+0x24/0x104
>  >=A0=A0[<8000973c>] timer_interrupt+0x128/0x270
>  >=A0=A0[<8003408c>] run_timer_softirq+0x118/0x228
>  >=A0=A0[<8002f28c>] __do_softirq+0x8c/0x16c
>  >=A0=A0[<8002f28c>] __do_softirq+0x8c/0x16c
>  >=A0=A0[<8002f3f8>] do_softirq+0x8c/0xb8
>  >=A0=A0[<80004914>] do_IRQ+0x24/0x34
>  >=A0=A0[<80001d68>] brcmIRQ+0x108/0x180
>  >=A0=A0[<80001d84>] brcmIRQ+0x124/0x180
>  >=A0=A0[<80004b58>] cpu_idle+0x58/0x60
>  >=A0=A0[<80002fa4>] r4k_wait+0x0/0xc
>  >=A0=A0[<c0551c04>] BREG_Read32+0x0/0x88 [balcore]
>  >=A0=A0[<80004b3c>] cpu_idle+0x3c/0x60
>  >=A0=A0[<80002fa8>] r4k_wait+0x4/0xc
>  >=A0=A0[<8000141c>] _stext+0x1c/0x28
>  >=A0=A0[<80137ce0>] idr_cache_ctor+0x0/0xc
>  >=A0=A0[<802d9000>] _sinittext+0x0/0x88
>  >=A0=A0[<802d97d0>] start_kernel+0x1d4/0x200
>  >=A0=A0[<802d97b4>] start_kernel+0x1b8/0x200
>  >=A0=A0[<802d9138>] unknown_bootoption+0x0/0x324
>  >=A0=A0[<802d9024>] _sinittext+0x24/0x88
>  >=A0=A0[<8023016c>] udp_push_pending_frames+0x2c0/0x2c8
>  >=A0=A0[<802305b4>] udp_sendmsg+0x440/0xa50
>  >=A0=A0[<8020c920>] ip_generic_getfrag+0x0/0xbc
>  >=A0=A0[<8020d1ec>] ip_append_data+0x810/0xa7c
>  >=A0=A0[<800029b4>] brcm_mips_int2_dispatch+0xfc/0x1d8
>  >=A0=A0[<80263adc>] xdr_sendpages+0x1dc/0x29c
>  >=A0=A0[<801e0c18>] lock_sock+0xc4/0xd8
>  >=A0=A0[<802303d8>] udp_sendmsg+0x264/0xa50
>  >=A0=A0[<802303c0>] udp_sendmsg+0x24c/0xa50
>  >=A0=A0[<801e2250>] sk_common_release+0x50/0x10c
>  >=A0=A0[<8020c920>] ip_generic_getfrag+0x0/0xbc
>  >=A0=A0[<801dc934>] sock_sendmsg+0xac/0xf0
>  >=A0=A0[<80044b30>] autoremove_wake_function+0x0/0x44
>  >=A0=A0[<801dc934>] sock_sendmsg+0xac/0xf0
>  >=A0=A0[<801dc99c>] kernel_sendmsg+0x24/0x38
>  >=A0=A0[<801e0c18>] lock_sock+0xc4/0xd8
>  >=A0=A0[<801e1000>] sock_no_sendpage+0x68/0x74
>  >=A0=A0[<80230d0c>] udp_sendpage+0x148/0x1b0
>  >=A0=A0[<80230c68>] udp_sendpage+0xa4/0x1b0
>  >=A0=A0[<80252f00>] rpc_call_sync+0x9c/0xd8
>  >=A0=A0[<8025d044>] svc_sendto+0x8c/0x274
>  >=A0=A0[<8025d1b4>] svc_sendto+0x1fc/0x274
>  >=A0=A0[<8013d640>] memset_partial+0x24/0x6c
>  >=A0=A0[<8025ddd4>] svc_udp_sendto+0x20/0x70
>  >=A0=A0[<80262b30>] svcauth_unix_release+0xd8/0x108
>  >=A0=A0[<8025eef4>] svc_send+0x23c/0x29c
>  >=A0=A0[<8025ed18>] svc_send+0x60/0x29c
>  >=A0=A0[<80260e88>] svc_authorise+0x2c/0xec
>  >=A0=A0[<c01551b0>] nfs3svc_release_fhandle+0x18/0x28 [nfsd]
>  >=A0=A0[<8025c298>] svc_process+0x354/0x83c
>  >=A0=A0[<80023124>] default_wake_function+0x0/0x20
>  >=A0=A0[<8025e5b0>] svc_recv+0x0/0x6b8
>  >=A0=A0[<8003892c>] sigprocmask+0x0/0x1bc
>  >=A0=A0[<c013f5dc>] nfsd+0x250/0x5a0 [nfsd]
>  >=A0=A0[<c013f38c>] nfsd+0x0/0x5a0 [nfsd]
>  >=A0=A0[<80005064>] kernel_thread_helper+0x10/0x18
>  >=A0=A0[<80005054>] kernel_thread_helper+0x0/0x18
> =20
>  The above looks like an unbalanced local_bh_disable()/local_bh_enable(=
)
>  pair in the kernel. Since we're not seeing it on any other setup that
>  I'm aware of, then I'd guess that this is a MIPS arch bug, or possibly=
 a
>  bug in one of your hardware drivers (the NIC would be a prime candidat=
e
>  given the above trace).
> =20
>  As for the inability to compile nfs-utils with uclibc: I doubt any of
>  the developers have tested that. Patches would be welcome.
> =20
>  Cheers,
>  =A0=A0Trond
> =20
> =20
> =20
>  -------------------------------------------------------
>  This SF.net email is sponsored by: Splunk Inc. Do you grep through log=
 files
>  for problems?=A0=A0Stop!=A0=A0Download the new AJAX search engine that=
 makes
>  searching your log files as easy as surfing the=A0=A0web.=A0=A0DOWNLOA=
D SPLUNK!
>  http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
>  _______________________________________________
>  NFS maillist=A0=A0-=A0=A0NFS@lists.sourceforge.net
>  https://lists.sourceforge.net/lists/listinfo/nfs
> =20


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
