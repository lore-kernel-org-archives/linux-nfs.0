Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-1-out2.atlantis.sk ([80.94.52.71]:52797 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757210Ab2FEO2R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 10:28:17 -0400
From: Ondrej Zary <linux@rainbow-software.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: Re: [bisected commit 0fc9d10] NFS-server corruption with 3.4
Date: Tue, 5 Jun 2012 16:20:47 +0200
Cc: Hugh Dickins <hughd@google.com>,
        Kernel development list <linux-kernel@vger.kernel.org>,
        Dave Jones <davej@redhat.com>, Hans de Bruin <jmdebruin@xmsnet.nl>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Toralf =?utf-8?q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
        "richard -rw- weinberger" <richard.weinberger@gmail.com>
References: <201206051116.17711.linux@rainbow-software.org> <4FCE0A83.4050502@openvz.org>
In-Reply-To: <4FCE0A83.4050502@openvz.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Message-Id: <201206051620.47925.linux@rainbow-software.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday 05 June 2012, Konstantin Khlebnikov wrote:
> Ondrej Zary wrote:
> > Hello,
> > I use NFS for deploying HDD images on new machines. My machine has 2nd
> > network card just for this, running DHCPD, TFTPD and kernel NFS server.
> > The target machine is set to boot from LAN and boots SystemRescueCD from
> > my machine with an autorun script that launches Partimage and deploys the
> > HDD image (400 to 900 MB compressed).
> >
> > It worked fine for years, until now. With kernel 3.4, everyting
> > works only for the first time after boot (and not always). Next time
> > (next machine), partimage aborts almost immediately as it's probably
> > unable to decompress the image file. md5sum is different on my machine
> > vs. on the target (through NFS). Also SystemRescueCD boot aborts with md5
> > error sometimes. Everything works fine after rebooting back to 3.3.
> >
> > Bisection found this:
> >
> > 0fc9d1040313047edf6a39fd4d7c7defdca97c62 is the first bad commit
> > commit 0fc9d1040313047edf6a39fd4d7c7defdca97c62
> > Author: Konstantin Khlebnikov<khlebnikov@openvz.org>
> > Date:   Wed Mar 28 14:42:54 2012 -0700
> >
> >      radix-tree: use iterators in find_get_pages* functions
> >
> > Reverting this commit in 3.4 fixes the problem.
>
> [all reporters added to CC] let's keep all in one thread
>
> In attachment two patches which might help to debug this regression:
>
> "mm: recheck page index in find_get_pages_contig" adds paranoid check into
> find_get_pages_contig(). It can explain everything, but currently I don't
> see how this can hapens.
>
> "mm: debug fing_get_pages speculative restart" shows lookup restarting
> condition which was removed by bisected commit.

My dmesg (after corruption occured) with these two patches applied:

[   79.999511] ------------[ cut here ]------------
[   79.999564] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   79.999611] Hardware name: VT82C694X
[   79.999617] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   79.999653] Pid: 1563, comm: nfsd Not tainted 3.4.0-omega #4
[   79.999659] Call Trace:
[   79.999729]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   79.999744]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   79.999753]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   79.999763]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   79.999772]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   79.999805]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   79.999853]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   79.999873]  [<c04f2589>] ? common_interrupt+0x29/0x30
[   79.999900]  [<f892c710>] ? _fh_update.isra.11.part.12+0x60/0x60 [nfsd]
[   79.999931]  [<c022c9f7>] ? exportfs_decode_fh+0xc7/0x250
[   79.999981]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   80.000000]  [<c0150215>] ? getboottime+0x35/0x40
[   80.007383]  [<c04f0da8>] ? __schedule+0x198/0x470
[   80.007505]  [<f88cbf34>] ? sunrpc_cache_lookup+0x54/0x2d0 [sunrpc]
[   80.007574]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   80.007590]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   80.007599]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   80.007608]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   80.007618]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   80.007654]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   80.007700]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   80.007715]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   80.007732]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   80.007745]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   80.007779]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   80.007825]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   80.007838]  [<f892a000>] ? 0xf8929fff
[   80.007846]  [<f892a000>] ? 0xf8929fff
[   80.007858]  [<c01389bc>] ? kthread+0x6c/0x80
[   80.007867]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   80.007896]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   80.007937] ---[ end trace 0bc8170cf5ac5466 ]---
[   80.007944] ------------[ cut here ]------------
[   80.007966] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   80.007973] Hardware name: VT82C694X
[   80.007977] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   80.014458] Pid: 1563, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   80.014547] Call Trace:
[   80.014580]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   80.014603]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.014612]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.014624]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   80.014676]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.014697]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   80.014709]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   80.014727]  [<c04f2589>] ? common_interrupt+0x29/0x30
[   80.014767]  [<f892c710>] ? _fh_update.isra.11.part.12+0x60/0x60 [nfsd]
[   80.014857]  [<c022c9f7>] ? exportfs_decode_fh+0xc7/0x250
[   80.014886]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   80.014939]  [<c0150215>] ? getboottime+0x35/0x40
[   80.014950]  [<c04f0da8>] ? __schedule+0x198/0x470
[   80.015030]  [<f88cbf34>] ? sunrpc_cache_lookup+0x54/0x2d0 [sunrpc]
[   80.015080]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   80.015095]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   80.015104]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   80.015113]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   80.015162]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   80.015177]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   80.015190]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   80.015205]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   80.015221]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   80.015234]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   80.015305]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   80.015318]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   80.015330]  [<f892a000>] ? 0xf8929fff
[   80.015337]  [<f892a000>] ? 0xf8929fff
[   80.015350]  [<c01389bc>] ? kthread+0x6c/0x80
[   80.015359]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   80.015415]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   80.015424] ---[ end trace 0bc8170cf5ac5467 ]---
[   80.015430] ------------[ cut here ]------------
[   80.015446] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   80.015452] Hardware name: VT82C694X
[   80.015456] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   80.015534] Pid: 1563, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   80.015540] Call Trace:
[   80.015560]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   80.015570]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.015579]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.015588]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   80.015597]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.015625]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   80.015672]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   80.015683]  [<c04f2589>] ? common_interrupt+0x29/0x30
[   80.015697]  [<f892c710>] ? _fh_update.isra.11.part.12+0x60/0x60 [nfsd]
[   80.015712]  [<c022c9f7>] ? exportfs_decode_fh+0xc7/0x250
[   80.015726]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   80.015782]  [<c0150215>] ? getboottime+0x35/0x40
[   80.015792]  [<c04f0da8>] ? __schedule+0x198/0x470
[   80.015829]  [<f88cbf34>] ? sunrpc_cache_lookup+0x54/0x2d0 [sunrpc]
[   80.015843]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   80.015867]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   80.015911]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   80.015921]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   80.015930]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   80.015945]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   80.015958]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   80.015972]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   80.016083]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   80.016096]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   80.016168]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   80.016182]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   80.016191]  [<f892a000>] ? 0xf8929fff
[   80.016198]  [<f892a000>] ? 0xf8929fff
[   80.016209]  [<c01389bc>] ? kthread+0x6c/0x80
[   80.016218]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   80.016278]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   80.016285] ---[ end trace 0bc8170cf5ac5468 ]---
[   80.016291] ------------[ cut here ]------------
[   80.016309] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   80.016315] Hardware name: VT82C694X
[   80.016319] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   80.016397] Pid: 1563, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   80.016403] Call Trace:
[   80.016420]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   80.016430]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.016439]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.016449]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   80.016458]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.016483]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   80.016529]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   80.016541]  [<c04f2589>] ? common_interrupt+0x29/0x30
[   80.016554]  [<f892c710>] ? _fh_update.isra.11.part.12+0x60/0x60 [nfsd]
[   80.016570]  [<c022c9f7>] ? exportfs_decode_fh+0xc7/0x250
[   80.016584]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   80.016645]  [<c0150215>] ? getboottime+0x35/0x40
[   80.016656]  [<c04f0da8>] ? __schedule+0x198/0x470
[   80.016688]  [<f88cbf34>] ? sunrpc_cache_lookup+0x54/0x2d0 [sunrpc]
[   80.016701]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   80.016712]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   80.016769]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   80.016779]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   80.016788]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   80.016802]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   80.016816]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   80.016829]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   80.016851]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   80.016890]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   80.016915]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   80.016927]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   80.016936]  [<f892a000>] ? 0xf8929fff
[   80.016943]  [<f892a000>] ? 0xf8929fff
[   80.016951]  [<c01389bc>] ? kthread+0x6c/0x80
[   80.016963]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   80.017018]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   80.017024] ---[ end trace 0bc8170cf5ac5469 ]---
[   80.017030] ------------[ cut here ]------------
[   80.017046] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   80.017052] Hardware name: VT82C694X
[   80.017056] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   80.017136] Pid: 1563, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   80.017142] Call Trace:
[   80.017158]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   80.017169]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.017178]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.017188]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   80.017197]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.017222]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   80.017285]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   80.017301]  [<f892c710>] ? _fh_update.isra.11.part.12+0x60/0x60 [nfsd]
[   80.017317]  [<c022c9f7>] ? exportfs_decode_fh+0xc7/0x250
[   80.017331]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   80.017342]  [<c0150215>] ? getboottime+0x35/0x40
[   80.017352]  [<c04f0da8>] ? __schedule+0x198/0x470
[   80.017391]  [<f88cbf34>] ? sunrpc_cache_lookup+0x54/0x2d0 [sunrpc]
[   80.017445]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   80.017456]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   80.017465]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   80.017474]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   80.017483]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   80.017538]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   80.017551]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   80.017659]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   80.017675]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   80.017687]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   80.017713]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   80.017725]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   80.017782]  [<f892a000>] ? 0xf8929fff
[   80.017790]  [<f892a000>] ? 0xf8929fff
[   80.017799]  [<c01389bc>] ? kthread+0x6c/0x80
[   80.017808]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   80.017821]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   80.017829] ---[ end trace 0bc8170cf5ac546a ]---
[   80.017834] ------------[ cut here ]------------
[   80.017851] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   80.017900] Hardware name: VT82C694X
[   80.017905] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   80.017936] Pid: 1563, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   80.017941] Call Trace:
[   80.017960]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   80.017970]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.018029]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.018040]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   80.018049]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.018062]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   80.018073]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   80.018087]  [<f892c710>] ? _fh_update.isra.11.part.12+0x60/0x60 [nfsd]
[   80.018114]  [<c022c9f7>] ? exportfs_decode_fh+0xc7/0x250
[   80.018165]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   80.018177]  [<c0150215>] ? getboottime+0x35/0x40
[   80.018189]  [<c04f0da8>] ? __schedule+0x198/0x470
[   80.018227]  [<f88cbf34>] ? sunrpc_cache_lookup+0x54/0x2d0 [sunrpc]
[   80.018283]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   80.018296]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   80.018305]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   80.018314]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   80.018323]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   80.018339]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   80.018397]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   80.018412]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   80.018426]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   80.018438]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   80.018464]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   80.018522]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   80.018532]  [<f892a000>] ? 0xf8929fff
[   80.018539]  [<f892a000>] ? 0xf8929fff
[   80.018549]  [<c01389bc>] ? kthread+0x6c/0x80
[   80.018558]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   80.018572]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   80.018578] ---[ end trace 0bc8170cf5ac546b ]---
[   80.018584] ------------[ cut here ]------------
[   80.018609] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   80.018648] Hardware name: VT82C694X
[   80.018654] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   80.018684] Pid: 1563, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   80.018690] Call Trace:
[   80.018705]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   80.018725]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.018771]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.018782]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   80.018791]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   80.018805]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   80.018816]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   80.018830]  [<c022c9f7>] ? exportfs_decode_fh+0xc7/0x250
[   80.018891]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   80.018903]  [<c0150215>] ? getboottime+0x35/0x40
[   80.018913]  [<c04f0da8>] ? __schedule+0x198/0x470
[   80.018947]  [<f88cbf34>] ? sunrpc_cache_lookup+0x54/0x2d0 [sunrpc]
[   80.018959]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   80.019015]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   80.019025]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   80.019034]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   80.019044]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   80.019058]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   80.019071]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   80.019084]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   80.019139]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   80.019152]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   80.019177]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   80.019189]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   80.019198]  [<f892a000>] ? 0xf8929fff
[   80.019205]  [<f892a000>] ? 0xf8929fff
[   80.019257]  [<c01389bc>] ? kthread+0x6c/0x80
[   80.019267]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   80.019279]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   80.019286] ---[ end trace 0bc8170cf5ac546c ]---
[   91.774922] ------------[ cut here ]------------
[   91.775125] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   91.775327] Hardware name: VT82C694X
[   91.775334] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   91.775483] Pid: 1564, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   91.775570] Call Trace:
[   91.775642]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   91.775816]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.775829]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.775842]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   91.796462]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.796487]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   91.796554]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.796565]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   91.796580]  [<c01b7cec>] ? iput+0x2c/0x210
[   91.796588]  [<c01b5a5f>] ? d_obtain_alias+0x2f/0x170
[   91.796608]  [<c0203f89>] ? ext3_fh_to_dentry+0x19/0x20
[   91.796637]  [<c022c9b7>] ? exportfs_decode_fh+0x87/0x250
[   91.796706]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   91.796722]  [<c04c35a6>] ? udp_recvmsg+0x186/0x2d0
[   91.796731]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.796755]  [<c0103b03>] ? do_IRQ+0x43/0xa0
[   91.796855]  [<f88cdc71>] ? cache_check+0x71/0x3f0 [sunrpc]
[   91.796925]  [<c04f2589>] ? common_interrupt+0x29/0x30
[   91.796941]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   91.796951]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   91.796960]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   91.796969]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   91.796986]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   91.797042]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   91.797057]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   91.797074]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   91.797086]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   91.797119]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   91.797195]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   91.797207]  [<f892a000>] ? 0xf8929fff
[   91.797215]  [<f892a000>] ? 0xf8929fff
[   91.797227]  [<c01389bc>] ? kthread+0x6c/0x80
[   91.797236]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   91.797250]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   91.797259] ---[ end trace 0bc8170cf5ac546d ]---
[   91.797311] ------------[ cut here ]------------
[   91.797330] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   91.797337] Hardware name: VT82C694X
[   91.797341] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   91.797374] Pid: 1564, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   91.797379] Call Trace:
[   91.797412]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   91.797495]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.797505]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.797565]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   91.797576]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.797590]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   91.797604]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.797614]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   91.797628]  [<c01b7cec>] ? iput+0x2c/0x210
[   91.797686]  [<c01b5a5f>] ? d_obtain_alias+0x2f/0x170
[   91.797697]  [<c0203f89>] ? ext3_fh_to_dentry+0x19/0x20
[   91.797711]  [<c022c9b7>] ? exportfs_decode_fh+0x87/0x250
[   91.797727]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   91.797737]  [<c04c35a6>] ? udp_recvmsg+0x186/0x2d0
[   91.797746]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.797761]  [<c0103b03>] ? do_IRQ+0x43/0xa0
[   91.797841]  [<f88cdc71>] ? cache_check+0x71/0x3f0 [sunrpc]
[   91.797856]  [<c04f2589>] ? common_interrupt+0x29/0x30
[   91.797869]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   91.797879]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   91.797931]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   91.797941]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   91.797957]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   91.797971]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   91.797985]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   91.798000]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   91.798052]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   91.798078]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   91.798090]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   91.798100]  [<f892a000>] ? 0xf8929fff
[   91.798107]  [<f892a000>] ? 0xf8929fff
[   91.798118]  [<c01389bc>] ? kthread+0x6c/0x80
[   91.798176]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   91.798188]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   91.798195] ---[ end trace 0bc8170cf5ac546e ]---
[   91.798201] ------------[ cut here ]------------
[   91.798216] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   91.798222] Hardware name: VT82C694X
[   91.798226] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   91.798306] Pid: 1564, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   91.798312] Call Trace:
[   91.798328]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   91.798338]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.798347]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.798357]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   91.798366]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.798426]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   91.798437]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.798447]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   91.798459]  [<c01b7cec>] ? iput+0x2c/0x210
[   91.798467]  [<c01b5a5f>] ? d_obtain_alias+0x2f/0x170
[   91.798477]  [<c0203f89>] ? ext3_fh_to_dentry+0x19/0x20
[   91.798491]  [<c022c9b7>] ? exportfs_decode_fh+0x87/0x250
[   91.798551]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   91.798561]  [<c04c35a6>] ? udp_recvmsg+0x186/0x2d0
[   91.798571]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.798579]  [<c0103b03>] ? do_IRQ+0x43/0xa0
[   91.798617]  [<f88cdc71>] ? cache_check+0x71/0x3f0 [sunrpc]
[   91.798673]  [<c04f2589>] ? common_interrupt+0x29/0x30
[   91.798687]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   91.798697]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   91.798706]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   91.798716]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   91.798731]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   91.798745]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   91.798794]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   91.798811]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   91.798823]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   91.798847]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   91.798859]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   91.798912]  [<f892a000>] ? 0xf8929fff
[   91.798920]  [<f892a000>] ? 0xf8929fff
[   91.798929]  [<c01389bc>] ? kthread+0x6c/0x80
[   91.798938]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   91.798950]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   91.798957] ---[ end trace 0bc8170cf5ac546f ]---
[   91.798963] ------------[ cut here ]------------
[   91.798976] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   91.798982] Hardware name: VT82C694X
[   91.799028] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   91.799060] Pid: 1564, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   91.799066] Call Trace:
[   91.799080]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   91.799091]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.799100]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.799110]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   91.799161]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.799175]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   91.799186]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.799195]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   91.799206]  [<c01b7cec>] ? iput+0x2c/0x210
[   91.799214]  [<c01b5a5f>] ? d_obtain_alias+0x2f/0x170
[   91.799225]  [<c0203f89>] ? ext3_fh_to_dentry+0x19/0x20
[   91.799288]  [<c022c9b7>] ? exportfs_decode_fh+0x87/0x250
[   91.799304]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   91.799314]  [<c04c35a6>] ? udp_recvmsg+0x186/0x2d0
[   91.799323]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.799331]  [<c0103b03>] ? do_IRQ+0x43/0xa0
[   91.799377]  [<f88cdc71>] ? cache_check+0x71/0x3f0 [sunrpc]
[   91.799426]  [<c04f2589>] ? common_interrupt+0x29/0x30
[   91.799438]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   91.799448]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   91.799457]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   91.799466]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   91.799484]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   91.799527]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   91.799542]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   91.799557]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   91.799569]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   91.799592]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   91.799654]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   91.799664]  [<f892a000>] ? 0xf8929fff
[   91.799671]  [<f892a000>] ? 0xf8929fff
[   91.799681]  [<c01389bc>] ? kthread+0x6c/0x80
[   91.799690]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   91.799703]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   91.799710] ---[ end trace 0bc8170cf5ac5470 ]---
[   91.799715] ------------[ cut here ]------------
[   91.799743] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   91.799783] Hardware name: VT82C694X
[   91.799789] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   91.799820] Pid: 1564, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   91.799825] Call Trace:
[   91.799840]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   91.799925]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.799935]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.799946]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   91.799956]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.799968]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   91.799979]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.799989]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   91.800000]  [<c01b7cec>] ? iput+0x2c/0x210
[   91.820316]  [<c01b5a5f>] ? d_obtain_alias+0x2f/0x170
[   91.820387]  [<c0203f89>] ? ext3_fh_to_dentry+0x19/0x20
[   91.820415]  [<c022c9b7>] ? exportfs_decode_fh+0x87/0x250
[   91.820484]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   91.820500]  [<c04c35a6>] ? udp_recvmsg+0x186/0x2d0
[   91.820516]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.820537]  [<c0103b03>] ? do_IRQ+0x43/0xa0
[   91.820673]  [<f88cdc71>] ? cache_check+0x71/0x3f0 [sunrpc]
[   91.820728]  [<c04f2589>] ? common_interrupt+0x29/0x30
[   91.820750]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   91.820760]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   91.820769]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   91.820823]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   91.820840]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   91.820854]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   91.820868]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   91.820886]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   91.820901]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   91.820964]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   91.820977]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   91.820990]  [<f892a000>] ? 0xf8929fff
[   91.820997]  [<f892a000>] ? 0xf8929fff
[   91.821009]  [<c01389bc>] ? kthread+0x6c/0x80
[   91.821019]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   91.821075]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   91.821084] ---[ end trace 0bc8170cf5ac5471 ]---
[   91.821091] ------------[ cut here ]------------
[   91.821112] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   91.821119] Hardware name: VT82C694X
[   91.821123] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   91.821205] Pid: 1564, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   91.821211] Call Trace:
[   91.821233]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   91.821244]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.821253]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.821262]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   91.821318]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.821332]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   91.821343]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.821353]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   91.821365]  [<c01b7cec>] ? iput+0x2c/0x210
[   91.821373]  [<c01b5a5f>] ? d_obtain_alias+0x2f/0x170
[   91.821383]  [<c0203f89>] ? ext3_fh_to_dentry+0x19/0x20
[   91.821438]  [<c022c9b7>] ? exportfs_decode_fh+0x87/0x250
[   91.821454]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   91.821463]  [<c04c35a6>] ? udp_recvmsg+0x186/0x2d0
[   91.821472]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.821481]  [<c0103b03>] ? do_IRQ+0x43/0xa0
[   91.821529]  [<f88cdc71>] ? cache_check+0x71/0x3f0 [sunrpc]
[   91.821599]  [<c04f2589>] ? common_interrupt+0x29/0x30
[   91.821616]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   91.821627]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   91.821636]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   91.821717]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   91.821734]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   91.821748]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   91.821762]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   91.821881]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   91.821896]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   91.821938]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   91.822017]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   91.825357]  [<f892a000>] ? 0xf8929fff
[   91.825368]  [<f892a000>] ? 0xf8929fff
[   91.825383]  [<c01389bc>] ? kthread+0x6c/0x80
[   91.825402]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   91.825457]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   91.825466] ---[ end trace 0bc8170cf5ac5472 ]---
[   91.825473] ------------[ cut here ]------------
[   91.825496] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
[   91.825502] Hardware name: VT82C694X
[   91.825506] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto 
firewire_ohci firewire_core
[   91.825585] Pid: 1564, comm: nfsd Tainted: G        W    3.4.0-omega #4
[   91.825590] Call Trace:
[   91.825612]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
[   91.825622]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.825632]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.825689]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
[   91.825699]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
[   91.825719]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
[   91.825734]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.825744]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
[   91.825759]  [<c01b7cec>] ? iput+0x2c/0x210
[   91.825812]  [<c01b5a5f>] ? d_obtain_alias+0x2f/0x170
[   91.825833]  [<c0203f89>] ? ext3_fh_to_dentry+0x19/0x20
[   91.825850]  [<c022c9b7>] ? exportfs_decode_fh+0x87/0x250
[   91.825881]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
[   91.825939]  [<c04c35a6>] ? udp_recvmsg+0x186/0x2d0
[   91.825949]  [<c01254bf>] ? irq_exit+0x4f/0x90
[   91.825960]  [<c0103b03>] ? do_IRQ+0x43/0xa0
[   91.826039]  [<f88cdc71>] ? cache_check+0x71/0x3f0 [sunrpc]
[   91.826102]  [<c04f2589>] ? common_interrupt+0x29/0x30
[   91.826117]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
[   91.826127]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
[   91.826179]  [<c01c4330>] ? do_splice_to+0x60/0x90
[   91.826189]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
[   91.826206]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
[   91.826219]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
[   91.826233]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
[   91.826249]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
[   91.826305]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
[   91.826332]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
[   91.826344]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
[   91.826353]  [<f892a000>] ? 0xf8929fff
[   91.826360]  [<f892a000>] ? 0xf8929fff
[   91.826370]  [<c01389bc>] ? kthread+0x6c/0x80
[   91.826427]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
[   91.826439]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
[   91.826446] ---[ end trace 0bc8170cf5ac5473 ]---


-- 
Ondrej Zary
