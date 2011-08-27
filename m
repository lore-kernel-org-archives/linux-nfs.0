Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52832 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753634Ab1H0AC0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 20:02:26 -0400
Date: Fri, 26 Aug 2011 20:02:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: NeilBrown <neilb@suse.de>, Greg Banks <gnb@fastmail.fm>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Message-ID: <20110827000219.GF18699@fieldses.org>
References: <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
 <20110729164836.GL23194@fieldses.org>
 <20110729165345.GM23194@fieldses.org>
 <F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
 <20110730093025.716f3f50@notabene.brown>
 <20110729234857.GA30941@fieldses.org>
 <1311998914.2873.27.camel@edumazet-laptop>
 <20110730160610.0b751ffd@notabene.brown>
 <1312006990.2873.75.camel@edumazet-laptop>
 <1312095534.2873.108.camel@edumazet-laptop>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1312095534.2873.108.camel@edumazet-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Jul 31, 2011 at 08:58:54AM +0200, Eric Dumazet wrote:
> Le samedi 30 juillet 2011 à 08:23 +0200, Eric Dumazet a écrit :
> > Le samedi 30 juillet 2011 à 16:06 +1000, NeilBrown a écrit :
> > > umount /proc/fs/nfsd
> > > 
> > > 
> > 
> > Thans  a lot, this was the thing I missed !
> > 
> > 
> 
> Hmm, after this, I left things as the were (nfsd module loaded, but a 0
> use count )
> 
> I got a BUG while updatedb was running,
> (I tried this on a debian machine/kernel)
> 
> Same bug on :
> 
> cat /proc/self/mounts 

Any luck figuring this out?

I tried reproducing, by stopping everything to get nfsd refcount to
zero:

	# lsmod | grep '^nfsd'
	nfsd                  300025  0 

then running 'cat /proc/self/mounts'.

But I don't see any crash.

This is only 3.1.0-rc1 plus some nfsd patches.

--b.

> 
> I'll take a look at this issue later, after my vacations, unless someone
> wants to take a look before me ;)
> 
> [1020029.301174] BUG: unable to handle kernel paging request at ffffffffa03da0d0
> [1020029.301318] IP: [<ffffffff811105bd>] show_type+0x17/0x5a
> [1020029.301436] PGD 1605067 PUD 1609063 PMD 127353067 PTE 0
> [1020029.301574] Oops: 0000 [#1] SMP 
> [1020029.301637] last sysfs file: /sys/module/nfsd/initstate
> [1020029.301722] CPU 6 
> [1020029.301765] Modules linked in: nfsd fuse btrfs zlib_deflate crc32c libcrc32c ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs xfs reiserfs ext4 jbd2 crc16 ext2 dm_mod nls_utf8 isofs lockd fscache auth_rpcgss nfs_acl sunrpc loop i5000_edac radeon edac_core ttm drm_kms_helper snd_pcm drm snd_timer snd i2c_algo_bit soundcore i2c_core snd_page_alloc i5k_amb power_supply ipmi_si evdev psmouse rng_core ipmi_msghandler hpilo hpwdt shpchp processor button pcspkr serio_raw pci_hotplug container ext3 jbd mbcache hpsa usbhid hid uhci_hcd cciss scsi_mod ehci_hcd usbcore bnx2 thermal thermal_sys [last unloaded: nfsd]
> [1020029.303561] 
> [1020029.303588] Pid: 23460, comm: updatedb.mlocat Tainted: G  R          2.6.39-2-amd64 #1 HP ProLiant BL460c G1
> [1020029.303751] RIP: 0010:[<ffffffff811105bd>]  [<ffffffff811105bd>] show_type+0x17/0x5a
> [1020029.303866] RSP: 0018:ffff880011da7e48  EFLAGS: 00010296
> [1020029.303953] RAX: ffffffffa03da0d0 RBX: ffff8801288a4a80 RCX: 0000000000007774
> [1020029.304061] RDX: ffffffff814c9935 RSI: ffff880129ea3800 RDI: ffff8801288a4a80
> [1020029.304169] RBP: ffff880129ea3800 R08: ffff880011da7e68 R09: ffffffffffffffff
> [1020029.304263] R10: ffff880011d883b2 R11: 0000000000000007 R12: ffff88012794a2c0
> [1020029.304263] R13: ffff8801288a4a80 R14: ffff88012794a338 R15: 0000000000000000
> [1020029.304263] FS:  00007f9cf0dec700(0000) GS:ffff88012fd80000(0000) knlGS:0000000000000000
> [1020029.304263] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [1020029.304263] CR2: ffffffffa03da0d0 CR3: 0000000058f90000 CR4: 00000000000006e0
> [1020029.304263] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [1020029.304263] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [1020029.304263] Process updatedb.mlocat (pid: 23460, threadinfo ffff880011da6000, task ffff88002741a440)
> [1020029.304263] Stack:
> [1020029.304263]  ffff8801288a4a80 ffff8801288a4a80 ffff88012794a338 ffffffff81110abf
> [1020029.304263]  ffff88012794a2c0 ffff88010d992440 0000000000000400 00007f9cf0df3000
> [1020029.304263]  ffff880127960cc0 ffff8801288a4a80 ffff88012794a338 ffffffff8111427a
> [1020029.304263] Call Trace:
> [1020029.304263]  [<ffffffff81110abf>] ? show_vfsmnt+0x9b/0x134
> [1020029.304263]  [<ffffffff8111427a>] ? seq_read+0x276/0x350
> [1020029.304263]  [<ffffffff810fc207>] ? vfs_read+0xa1/0xfb
> [1020029.304263]  [<ffffffff810d8052>] ? sys_mmap_pgoff+0x127/0x15a
> [1020029.304263]  [<ffffffff810fc317>] ? sys_read+0x45/0x6e
> [1020029.304263]  [<ffffffff81338e52>] ? system_call_fastpath+0x16/0x1b
> [1020029.304263] Code: 01 00 65 48 03 14 25 20 dc 00 00 66 ff 02 c3 f0 ff 47 38 c3 55 48 89 f5 48 c7 c2 35 99 4c 81 53 48 89 fb 48 83 ec 08 48 8b 46 28 
> [1020029.304263]  8b 30 e8 c7 36 00 00 48 8b 85 b8 02 00 00 48 85 c0 74 2b 80 
> [1020029.304263] RIP  [<ffffffff811105bd>] show_type+0x17/0x5a
> [1020029.304263]  RSP <ffff880011da7e48>
> [1020029.304263] CR2: ffffffffa03da0d0
> [1020029.311417] ---[ end trace ebf19aff1e083659 ]---
> 
> 
