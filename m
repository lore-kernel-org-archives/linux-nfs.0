Return-Path: linux-kernel-owner@vger.kernel.org
MIME-Version: 1.0
In-Reply-To: <20150202073334.GB9399@lst.de>
References: <20150201031917.GA18622@wfg-t540p.sh.intel.com>
	<20150202073334.GB9399@lst.de>
Date: Mon, 2 Feb 2015 08:43:46 -0500
Message-ID: <CAHQdGtTmm2u07h2V1vddBosogAjZ1qRfmfr+3Ej65pL79iaQAQ@mail.gmail.com>
Subject: Re: [nfs] WARNING: CPU: 1 PID: 1392 at kernel/sched/core.c:7300 __might_sleep+0xbd/0xd0()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Fengguang Wu <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>,
        lkp@01.org, Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 2, 2015 at 2:33 AM, Christoph Hellwig <hch@lst.de> wrote:
>
> On Sat, Jan 31, 2015 at 07:19:17PM -0800, Fengguang Wu wrote:
> > Hi Christoph,
> >
> > FYI, this patch discloses an 100% reproducible boot warning.
> >
> > git://git.infradead.org/users/hch/pnfs.git flexfiles+pnfsd
> > commit 34c311faa8dcd323907c6075ab24b4d9e3c6dcb0 ("nfs: force version 4.1")
>
> The branch is just test branch for some new pnfs patches.  But the fact
> that forcing the protocol version to 4.1 makes your boot fail still seems
> like an interesting observation.
>
> >
> > +------------------------------------------------------------------+------------+------------+
> > |                                                                  | 457be31a00 | 34c311faa8 |
> > +------------------------------------------------------------------+------------+------------+
> > | boot_successes                                                   | 20         | 10         |
> > | early-boot-hang                                                  | 1          |            |
> > | boot_failures                                                    | 0          | 12         |
> > | Kernel_panic-not_syncing:Out_of_memory_and_no_killable_processes | 0          | 2          |
> > | backtrace:vfs_write                                              | 0          | 2          |
> > | backtrace:SyS_write                                              | 0          | 2          |
> > | backtrace:populate_rootfs                                        | 0          | 2          |
> > | backtrace:kernel_init_freeable                                   | 0          | 2          |
> > | WARNING:at_kernel/sched/core.c:#__might_sleep()                  | 0          | 10         |
> > | backtrace:nfs41_callback_svc                                     | 0          | 10         |
> > +------------------------------------------------------------------+------------+------------+
> >
> >
> > [   12.520894] Key type id_resolver registered
> > [   12.522364] Key type id_legacy registered
> > [   12.530530] ------------[ cut here ]------------
> > [   12.532061] WARNING: CPU: 1 PID: 1392 at kernel/sched/core.c:7300 __might_sleep+0xbd/0xd0()
> > [   12.534114] do not call blocking ops when !TASK_RUNNING; state=1 set at [<ffffffff810b63af>] prepare_to_wait+0x2f/0x90
> > [   12.536264] Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver sg sr_mod cdrom ata_generic pata_acpi parport_pc floppy parport cirrus syscopyarea snd_pcm sysfillrect sysimgblt snd_timer ttm snd drm_kms_helper ata_piix soundcore libata drm pcspkr i2c_piix4
> > [   12.542569] CPU: 1 PID: 1392 Comm: nfsv4.1-svc Not tainted 3.19.0-rc5-wl-ga224126 #1
> > [   12.544509] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [   12.546252]  ffffffff81b7a3c0 ffff88007f627bd8 ffffffff818a735f 0000000000003658
> > [   12.548252]  ffff88007f627c28 ffff88007f627c18 ffffffff810725ea ffff88007f627bf8
> > [   12.550261]  ffffffff81b90e59 00000000000004d9 0000000000000000 0000000000000001
> > [   12.552359] Call Trace:
> > [   12.553868]  [<ffffffff818a735f>] dump_stack+0x4c/0x65
> > [   12.555666]  [<ffffffff810725ea>] warn_slowpath_common+0x8a/0xc0
> > [   12.557512]  [<ffffffff81072666>] warn_slowpath_fmt+0x46/0x50
> > [   12.559338]  [<ffffffff810a0104>] ? try_to_wake_up+0x1f4/0x380
> > [   12.561154]  [<ffffffff810b63af>] ? prepare_to_wait+0x2f/0x90
> > [   12.562993]  [<ffffffff810b63af>] ? prepare_to_wait+0x2f/0x90
> > [   12.564793]  [<ffffffff810986fd>] __might_sleep+0xbd/0xd0
> > [   12.566553]  [<ffffffff811c81e7>] kmem_cache_alloc_trace+0x1d7/0x250
> > [   12.568383]  [<ffffffff81095b0e>] ? groups_alloc+0x3e/0x130
> > [   12.570159]  [<ffffffff81095b0e>] groups_alloc+0x3e/0x130
> > [   12.571878]  [<ffffffff818781be>] svcauth_unix_accept+0x16e/0x290
> > [   12.573677]  [<ffffffff81876f11>] svc_authenticate+0xe1/0xf0
> > [   12.575405]  [<ffffffff818738f4>] svc_process_common+0x224/0x680
> > [   12.577184]  [<ffffffff818740d4>] bc_svc_process+0x1c4/0x260
> > [   12.578904]  [<ffffffffa01c3b64>] nfs41_callback_svc+0x104/0x1b0 [nfsv4]
> > [   12.580752]  [<ffffffff810b6790>] ? wait_woken+0xc0/0xc0
> > [   12.582441]  [<ffffffffa01c3a60>] ? nfs4_callback_svc+0x60/0x60 [nfsv4]
> > [   12.584268]  [<ffffffff81091fcf>] kthread+0xef/0x110
> > [   12.585859]  [<ffffffff81091ee0>] ? kthread_create_on_node+0x180/0x180
> > [   12.587572]  [<ffffffff818af9fc>] ret_from_fork+0x7c/0xb0
> > [   12.589175]  [<ffffffff81091ee0>] ? kthread_create_on_node+0x180/0x180
> > [   12.590895] ---[ end trace 7b39108134f7677c ]---
> > RESULT_ROOT=/result/vm-vp-2G/boot/1/debian-x86_64-2015-01-13.cgz/x86_64-rhel/a224126be542547c3d3040d2b4c145c0c024cc04/0
>
<snip away the looong .config>

That warning should hopefully be fixed by the following commit by Jeff:
  http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=commitdiff;h=6ffa30d3f734d4f6b478081dfc09592021028f90

I've already pulled it into my linux-next branch.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
