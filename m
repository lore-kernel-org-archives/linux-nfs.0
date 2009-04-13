From: Rince <rincebrain@gmail.com>
Subject: Re: NFS BUG_ON in nfs_do_writepage
Date: Mon, 13 Apr 2009 18:06:00 -0400
Message-ID: <5da0588e0904131506k5c58e8ddob9bf38f61da6302a@mail.gmail.com>
References: <alpine.LFD.2.00.0904130145050.4396@centaur.acm.jhu.edu>
	 <20090412235010.c8e3475b.akpm@linux-foundation.org>
	 <1239650202.16771.15.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:51075 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbZDMWLx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 18:11:53 -0400
In-Reply-To: <1239650202.16771.15.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 13, 2009 at 3:16 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Sun, 2009-04-12 at 23:50 -0700, Andrew Morton wrote:
>> (cc linux-nfs)
>>
>> On Mon, 13 Apr 2009 01:46:24 -0400 (EDT) rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org wrote:
>>
>> > Hi world,
>> > I've got a production server that's running as an NFSv4 client, al=
ong with
>> > a number of other machines.
>> >
>> > All the other machines are perfectly happy, but this one is a bit =
of a
>> > bother. It's got a Core 2 Duo 6700, with a D975XBX2 motherboard an=
d 4 GB
>> > of ECC RAM.
>> >
>> > The problem is that, under heavy load, NFS will trip a BUG_ON in
>> > nfs_do_writepage, as follows:
>> > ------------[ cut here ]------------
>> > kernel BUG at fs/nfs/write.c:252!
>> > invalid opcode: 0000 [#1] SMP
>> > last sysfs file: /sys/devices/virtual/block/dm-
>> > 0/range
>> > CPU 0
>> > Modules linked in: fuse autofs4 coretemp hwmon nfs lockd nfs_acl
>> > auth_rpcgss sunrpc ipv6 cpufreq_ondemand acpi_cpufreq freq_table k=
vm_intel
>> > kvm snd_hda_codec_idt snd_hda_intel snd_hda_codec snd_hwdep snd_se=
q_dummy
>> > snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss
>> > snd_mixer_oss snd_pcm snd_timer usb_storage snd cpia_usb e1000e so=
undcore
>> > cpia ppdev firewire_ohci snd_page_alloc firewire_core i2c_i801 vid=
eodev
>> > parport_pc pcspkr iTCO_wdt i2c_core v4l1_compat crc_itu_t parport
>> > iTCO_vendor_support v4l2_compat_ioctl32 i82975x_edac edac_core rai=
d1
>> > Pid: 309, comm: pdflush Not tainted 2.6.29.1 #1
>> > RIP: 0010:[<ffffffffa0291a47>] =A0[<ffffffffa0291a47>]
>> > nfs_do_writepage+0x106/0x1a2 [nfs]
>> > RSP: 0018:ffff88012d805af0 =A0EFLAGS: 00010282
>> > RAX: 0000000000000001 RBX: ffffe20001f66878 RCX: 0000000000000015
>> > RDX: 0000000000600020 RSI: 0000000000000000 RDI: ffff88000155789c
>> > RBP: ffff88012d805b20 R08: ffff88012cd53460 R09: 0000000000000004
>> > R10: ffff88009d421700 R11: ffffffffa02a98d0 R12: ffff88010253a300
>> > R13: ffff88000155789c R14: ffffe20001f66878 R15: ffff88012d805c80
>> > FS: =A00000000000000000(0000) GS:ffffffff817df000(0000)
>> > knlGS:0000000000000000
>> > CS: =A00010 DS: 0018 ES: 0018 CR0: 000000008005003b
>> > CR2: 00000000f7d2b000 CR3: 000000008708a000 CR4: 00000000000026e0
>> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> > Process pdflush (pid: 309, threadinfo ffff88012d804000, task
>> > ffff88012e4fdb80)
>> > Stack:
>> > =A0 ffff88012d805b20 ffffe20001f66878 ffffe20001f66878 00000000000=
00000
>> > =A0 0000000000000001 0000000000000000 ffff88012d805b40 ffffffffa02=
91f5a
>> > =A0 ffffe20001f66878 ffff88012d805e40 ffff88012d805c70 ffffffff810=
a9c1d
>> > Call Trace:
>> > =A0 [<ffffffffa0291f5a>] nfs_writepages_callback+0x14/0x25 [nfs]
>> > =A0 [<ffffffff810a9c1d>] write_cache_pages+0x261/0x3a4
>> > =A0 [<ffffffffa0291f46>] ? nfs_writepages_callback+0x0/0x25 [nfs]
>> > =A0 [<ffffffffa0291f1c>] nfs_writepages+0xb5/0xdf [nfs]
>> > =A0 [<ffffffffa02932bd>] ? nfs_flush_one+0x0/0xeb [nfs]
>> > =A0 [<ffffffff81060f78>] ? bit_waitqueue+0x17/0xa4
>> > =A0 [<ffffffff810a9db7>] do_writepages+0x2d/0x3d
>> > =A0 [<ffffffff810f4a51>] __writeback_single_inode+0x1b2/0x347
>> > =A0 [<ffffffff8100f7d4>] ? __switch_to+0xbe/0x3eb
>> > =A0 [<ffffffff810f4ffb>] generic_sync_sb_inodes+0x24a/0x395
>> > =A0 [<ffffffff810f5354>] writeback_inodes+0xa9/0x102
>> > =A0 [<ffffffff810a9f26>] wb_kupdate+0xa8/0x11e
>> > =A0 [<ffffffff810aac9d>] pdflush+0x173/0x236
>> > =A0 [<ffffffff810a9e7e>] ? wb_kupdate+0x0/0x11e
>> > =A0 [<ffffffff810aab2a>] ? pdflush+0x0/0x236
>> > =A0 [<ffffffff810aab2a>] ? pdflush+0x0/0x236
>> > =A0 [<ffffffff81060c9e>] kthread+0x4e/0x7b
>> > =A0 [<ffffffff810126ca>] child_rip+0xa/0x20
>> > =A0 [<ffffffff81011fe7>] ? restore_args+0x0/0x30
>> > =A0 [<ffffffff81060c50>] ? kthread+0x0/0x7b
>> > =A0 [<ffffffff810126c0>] ? child_rip+0x0/0x20
>> > Code: 89 e7 e8 d5 cc ff ff 4c 89 e7 89 c3 e8 2a cd ff ff 85 db 74 =
a0 e9 83
>> > 00 00 00 41 f6 44 24 40 02 74 0d 4c 89 ef e8 e2 a5 d9 e0 90 <0f> 0=
b eb fe
>> > 4c 89 f7 e8 f5 7a e1 e0 85 c0 75 49 49 8b 46 18 ba
>> > RIP =A0[<ffffffffa0291a47>] nfs_do_writepage+0x106/0x1a2 [nfs]
>> > =A0 RSP <ffff88012d805af0>
>> > ---[ end trace 6d60c9b253ebcf15 ]---
>> >
>> > 64bit kernel, 32bit userland. 2.6.29.1 vanilla, bug occurred as ea=
rly as
>> > 2.6.28, bug still occurs with 2.6.30-rc1. I'm running bisect now, =
but
>> > there's a limit on how often I can reboot a production server, so =
I'll
>> > report back when I find it.
>
> This looks like the same issue as
> =A0 =A0http://bugzilla.kernel.org/show_bug.cgi?id=3D12913
>
> Does the following patch from Nick help? It should apply on top of
> 2.6.30-rc1, and fixes a race in which the VM layer can end up marking=
 a
> page dirty after the filesystem has cleaned it...
>
> Cheers
> =A0Trond
>

Patch does not apply cleanly to 2.6.30-rc1. Working on this.

- Rich
--=20

I'm so miserable without you, it's almost like you're here.
