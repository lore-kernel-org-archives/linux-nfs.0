Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58089 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756439Ab1BKP35 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 10:29:57 -0500
Date: Fri, 11 Feb 2011 16:29:56 +0100
Message-ID: <s5h62sqbnd7.wl%tiwai@suse.de>
From: Takashi Iwai <tiwai@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tino Keitel <tino.keitel@tikei.de>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 2.6.38-rc3: kernel BUG at fs/nfsd/nfs4state.c:3132!
In-Reply-To: <20110211152112.GA3005@fieldses.org>
References: <20110208221235.GA16984@mac.home>
	<s5hsjvuoqqt.wl%tiwai@suse.de>
	<20110211152112.GA3005@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

At Fri, 11 Feb 2011 10:21:12 -0500,
J. Bruce Fields wrote:
> 
> On Fri, Feb 11, 2011 at 10:38:34AM +0100, Takashi Iwai wrote:
> > At Tue, 8 Feb 2011 23:12:35 +0100,
> > Tino Keitel wrote:
> > > 
> > > Hi,
> > > 
> > > I get the following error with kernel 2.6.38-rc3 during normal file access via
> > > NFS v4.
> > > 
> > > At least one other user seems to have the same problem:
> > > http://pastebin.com/QRq1TMkj
> > > 
> > > <0>------------[ cut here ]------------
> > > kernel BUG at fs/nfsd/nfs4state.c:3132!
> > > <0>invalid opcode: 0000 [#1] SMP 
> > > <0>last sysfs file: /sys/devices/virtual/block/dm-8/uevent
> > > CPU 0 
> > > Modules linked in: ipv6 usblp btusb bluetooth loop arc4 ecb
> > > snd_hda_codec_idt snd_hda_intel snd_hda_codec snd_pcm_oss ath5k
> > > dvb_usb_vp7045 ath dvb_usb snd_pcm snd_timer mac80211
> > >  snd_page_alloc evdev dvb_core sky2 rc_core ata_piix cfg80211
> > > 
> > > Pid: 2280, comm: nfsd Not tainted 2.6.38-rc3-00062-gb64606b #6
> > > Mac-F4208EAA/Macmini2,1
> > > RIP: 0010:[<ffffffff8119f973>]  [<ffffffff8119f973>]
> > > nfs4_preprocess_stateid_op+0x3a3/0x490
> > > RSP: 0018:ffff8800b399bd50  EFLAGS: 00010246
> > > RAX: 0000000000000000 RBX: ffff8800b60a9000 RCX: ffffffff8175a010
> > > RDX: ffff8800ab784e48 RSI: ffffffff8175a020 RDI: ffffffff8175a000
> > > RBP: ffff8800a4ce5678 R08: 0000000000000000 R09: 0000000000000000
> > > R10: ffff8800b3910180 R11: c600000000000000 R12: ffff8800b390f1c0
> > > R13: ffff8800b390f1a0 R14: 0000000000000000 R15: ffff8800aba079a0
> > > FS:  0000000000000000(0000) GS:ffff8800bde00000(0000)
> > > knlGS:0000000000000000
> > > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > CR2: 00007f2b8805d000 CR3: 00000000b6fe8000 CR4: 00000000000006b0
> > > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > > Process nfsd (pid: 2280, threadinfo ffff8800b399a000, task
> > > ffff8800b63a62d0)
> > > <0>Stack:
> > >  000000004d507f0d ffff8800b390f1a0 ffff8800b3910040 ffff8800b391c000
> > >  0000000016000000 0000000000000000 ffff8800b3910040 ffffffff8118f549
> > >  ffff8800b390f000 ffff8800b3910000 ffff8800b390f000 ffff8800b391c000
> > > <0>Call Trace:
> > >  [<ffffffff8118f549>] ? nfsd4_read+0x79/0xc0
> > >  [<ffffffff81190096>] ? nfsd4_proc_compound+0x416/0x4d0
> > >  [<ffffffff8117f5ad>] ? nfsd_dispatch+0xfd/0x240
> > >  [<ffffffff8146f1f9>] ? svc_process_common+0x339/0x680
> > >  [<ffffffff81035b70>] ? default_wake_function+0x0/0x20
> > >  [<ffffffff8117ecc0>] ? nfsd+0x0/0x150
> > >  [<ffffffff8146f80a>] ? svc_process+0x10a/0x160
> > >  [<ffffffff8117ecc0>] ? nfsd+0x0/0x150
> > >  [<ffffffff8117ed72>] ? nfsd+0xb2/0x150
> > >  [<ffffffff81055ff6>] ? kthread+0x96/0xa0
> > >  [<ffffffff810039b4>] ? kernel_thread_helper+0x4/0x10
> > >  [<ffffffff81055f60>] ? kthread+0x0/0xa0
> > >  [<ffffffff810039b0>] ? kernel_thread_helper+0x0/0x10
> > > <0>Code: 27 29 41 3b 47 50 0f 87 9a fd ff ff 0f 83 e9 fe ff ff e9 76 ff
> > > ff ff 48 8b 42 48 45 31 f6 49 89 04 24 48 85 c0 0f 85 7b fd ff ff <0f>
> > > 0b 49 8b 57 48 48 8b 42 40 48 85 c
> > > 0 0f 85 2a ff ff ff 48 8b 
> > > RIP  [<ffffffff8119f973>] nfs4_preprocess_stateid_op+0x3a3/0x490
> > >  RSP <ffff8800b399bd50>
> > > ---[ end trace 7ef2fa5b1b62014a ]---
> > 
> > [Added relevant guys to Cc]
> > 
> > This occurred on my machine with 2.6.38-rc4.
> 
> Again, 2.6.38-rc4 does not have a BUG() on line 3132.  Could you post
> the full oops message from your machine?

Well, on vanilla 2.6.38-rc4, it's in nfs4_preprocess_stateid_op():
               if (filpp) {
                        *filpp = find_readable_file(dp->dl_file);
==>                     BUG_ON(!*filpp);
                }


Anyway, here is the Oops log on my machine:

Feb  9 16:12:12 alsa2 kernel: ------------[ cut here ]------------
Feb  9 16:12:12 alsa2 kernel: kernel BUG at fs/nfsd/nfs4state.c:3132!
Feb  9 16:12:12 alsa2 kernel: invalid opcode: 0000 [#1] SMP 
Feb  9 16:12:12 alsa2 kernel: last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
Feb  9 16:12:12 alsa2 kernel: CPU 0 
Feb  9 16:12:12 alsa2 kernel: Modules linked in: md5 nfs fscache autofs4 nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs snd_pcm_oss snd_mixer_oss microcode nls_iso8859_1 nls_cp437 vfat fat snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep kvm_intel snd_pcm kvm snd_timer sr_mod snd tg3 shpchp i5000_edac soundcore ppdev edac_core sg cdrom snd_page_alloc pci_hotplug parport_pc iTCO_wdt libphy iTCO_vendor_support wmi parport pcspkr floppy nouveau ttm drm_kms_helper uhci_hcd ehci_hcd drm sd_mod usbcore rtc_cmos rtc_core crc_t10dif i2c_algo_bit i2c_core rtc_lib button edd ext4 mbcache jbd2 crc16 fan ata_piix ahci libahci libata scsi_mod thermal processor
Feb  9 16:12:12 alsa2 kernel: 
Feb  9 16:12:12 alsa2 kernel: Pid: 1976, comm: nfsd Not tainted 2.6.38-rc4-test2 #70 0A04h/HP xw6400 Workstation
Feb  9 16:12:12 alsa2 kernel: RIP: 0010:[<ffffffffa04bbe26>]  [<ffffffffa04bbe26>] nfs4_preprocess_stateid_op+0x213/0x3e7 [nfsd]
Feb  9 16:12:12 alsa2 kernel: RSP: 0018:ffff880112959d50  EFLAGS: 00010246
Feb  9 16:12:12 alsa2 kernel: RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffffffffa04c9870
Feb  9 16:12:12 alsa2 kernel: RDX: ffff8801134be0b8 RSI: ffff88011103b528 RDI: ffffffffa04c9860
Feb  9 16:12:12 alsa2 kernel: RBP: ffff880112959d90 R08: 0000000000000004 R09: 0000000000000004
Feb  9 16:12:12 alsa2 kernel: R10: 00000000000056ce R11: 000000000000273b R12: ffff8801146fc000
Feb  9 16:12:12 alsa2 kernel: R13: ffff8801142531c0 R14: ffff88011103b4c0 R15: ffff880114f10040
Feb  9 16:12:12 alsa2 kernel: FS:  0000000000000000(0000) GS:ffff8800dfc00000(0000) knlGS:0000000000000000
Feb  9 16:12:12 alsa2 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Feb  9 16:12:12 alsa2 kernel: CR2: 00007f86edc58000 CR3: 00000001139ae000 CR4: 00000000000006f0
Feb  9 16:12:12 alsa2 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Feb  9 16:12:12 alsa2 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Feb  9 16:12:12 alsa2 kernel: Process nfsd (pid: 1976, threadinfo ffff880112958000, task ffff880114bb0040)
Feb  9 16:12:12 alsa2 kernel: Stack:
Feb  9 16:12:12 alsa2 kernel:  ffff880112959d80 ffff8801142531a0 ffff88011664d880 ffff8801142531a0
Feb  9 16:12:12 alsa2 kernel:  ffff880114f10040 ffff880113692000 0000000016000000 ffff880113692000
Feb  9 16:12:12 alsa2 kernel:  ffff880112959dc0 ffffffffa04aec1b ffff880114f10000 ffff880114253198
Feb  9 16:12:12 alsa2 kernel: Call Trace:
Feb  9 16:12:12 alsa2 kernel:  [<ffffffffa04aec1b>] nfsd4_read+0x4b/0x92 [nfsd]
Feb  9 16:12:12 alsa2 kernel:  [<ffffffffa04af746>] nfsd4_proc_compound+0x22a/0x3b7 [nfsd]
Feb  9 16:12:12 alsa2 kernel:  [<ffffffffa04a07fa>] nfsd_dispatch+0xec/0x1cf [nfsd]
Feb  9 16:12:12 alsa2 kernel:  [<ffffffffa0464836>] svc_process+0x446/0x734 [sunrpc]
Feb  9 16:12:12 alsa2 kernel:  [<ffffffffa04a0025>] ? nfsd+0x0/0x13a [nfsd]
Feb  9 16:12:12 alsa2 kernel:  [<ffffffffa04a0116>] nfsd+0xf1/0x13a [nfsd]
Feb  9 16:12:12 alsa2 kernel:  [<ffffffff810668ea>] kthread+0x7d/0x85
Feb  9 16:12:12 alsa2 kernel:  [<ffffffff8100a824>] kernel_thread_helper+0x4/0x10
Feb  9 16:12:12 alsa2 kernel:  [<ffffffff8106686d>] ? kthread+0x0/0x85
Feb  9 16:12:12 alsa2 kernel:  [<ffffffff8100a820>] ? kernel_thread_helper+0x0/0x10
Feb  9 16:12:12 alsa2 kernel: Code: 61 da 00 00 4d 85 ed 0f 84 89 01 00 00 49 8b 56 40 48 8b 42 38 48 85 c0 75 04 48 8b 42 48 49 89 45 00 48 85 c0 0f 85 6b 01 00 00 <0f> 0b 44 89 e6 48 8b 7d c8 e8 0a b7 ff ff 49 89 c6 bb 00 00 27 
Feb  9 16:12:12 alsa2 kernel: RIP  [<ffffffffa04bbe26>] nfs4_preprocess_stateid_op+0x213/0x3e7 [nfsd]
Feb  9 16:12:12 alsa2 kernel:  RSP <ffff880112959d50>
Feb  9 16:12:12 alsa2 kernel: ---[ end trace 3beccd8999adc82a ]---


--
Takashi Iwai <tiwai@suse.de>		ALSA Developer - www.alsa-project.org

