Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-3.desy.de ([131.169.56.86]:52323 "EHLO
	smtp-out-3.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085Ab0IQGd6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 02:33:58 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-out-3.desy.de (DESY_OUT_3) with ESMTP id 9327B15D7
	for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 08:33:57 +0200 (MEST)
Received: from adserv70.win.desy.de (adserv70.win.desy.de [131.169.97.56])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 8B7F215D5
	for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 08:33:57 +0200 (MEST)
Message-ID: <4C930BB3.5080907@desy.de>
Date: Fri, 17 Sep 2010 08:33:23 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Benny Halevy <bhalevy@panasas.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: kernel panic
References: <4C90C872.7080100@desy.de> <4C923933.9040907@panasas.com>
In-Reply-To: <4C923933.9040907@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  On 09/16/2010 05:35 PM, Benny Halevy wrote:
> On 2010-09-15 15:21, Tigran Mkrtchyan wrote:
>> This is pnfs-all-latest git fa5a03da84b02026396be0736288b3f4a8143ff2
> Hmm, it's pnfs-all-2.6.35 by now :)

I already moved my desktop and 2.6.36-rc3 git 
7c40d303e13ec2f2e0b6cf217c008106b391d058
and farm nodes will be upgraded today.
> but nevertheless, the IP below doesn't seem to agree with the assembly
> code for nfs41_sequence_done.
> Do mind running gdb on your binary (fs/nfs/nfs.ko) and locating
I will do that next time. Unfortunately when I got your mail my system was
running newer kernel.

Thanks
    Tigran.

P.S: the rss feed from git does not show rebases and I am missing latest 
updates. Could you send a e-mail around whem you merge?
> the exact line and cpu instruction to see what's going on?
>
> Thanks,
>
> Benny
>
>> $ uname -a
>> Linux anahit 2.6.35-pnfs-2 #22 SMP Fri Aug 27 17:47:27 CEST 2010 x86_64
>> x86_64 x86_64 GNU/Linux
>> $
>>
>> On server restart:
>>
>> [624967.868286] BUG: unable to handle kernel NULL pointer dereference at
>> (null)
>> [624967.868291] IP: [<ffffffffa0492f42>] nfs41_sequence_done+0x52/0x2e0
>> [nfs]
>> [624967.868312] PGD 0
>> [624967.868315] Oops: 0002 [#1] SMP
>> [624967.868317] last sysfs file:
>> /sys/devices/pci0000:00/0000:00:1a.7/usb1/1-5/1-5:1.0/host8/target8:0:0/8:0:0:0/block/sdb/sdb1/stat
>> [624967.868321] CPU 0
>> [624967.868322] Modules linked in: nfs_layout_nfsv41_files snd_pcm_oss
>> snd_mixer_oss snd_seq edd rpcsec_gss_krb5 vboxnetadp vboxnetflt nfs
>> lockd fscache nfs_acl auth_rpcgss sunrpc vboxdrv cpufreq_conservative
>> cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf fuse loop dm_mod
>> snd_hda_codec_idt snd_usb_audio snd_hda_intel snd_hda_codec snd_hwdep
>> iTCO_wdt snd_pcm sr_mod snd_timer iTCO_vendor_support snd_usbmidi_lib sg
>> cdrom pcspkr serio_raw snd_rawmidi snd_seq_device ohci1394 ieee1394
>> i2c_i801 button snd microcode e1000e snd_page_alloc ext4 jbd2 crc16 fan
>> processor ide_pci_generic ide_core ata_generic pata_marvell thermal
>> thermal_sys
>> [624967.868363]
>> [624967.868366] Pid: 2267, comm: rpciod/0 Tainted: G          I
>> 2.6.35-pnfs-2 #22 DX38BT/pczW1007
>> [624967.868368] RIP: 0010:[<ffffffffa0492f42>]  [<ffffffffa0492f42>]
>> nfs41_sequence_done+0x52/0x2e0 [nfs]
>> [624967.868382] RSP: 0018:ffff880107e8dda0  EFLAGS: 00010246
>> [624967.868384] RAX: 0000000000000000 RBX: ffff88012d28ca98 RCX:
>> 0000000000000000
>> [624967.868386] RDX: 0000000000000000 RSI: ffff88012d28ca98 RDI:
>> ffff880107c9e180
>> [624967.868388] RBP: ffff880107e8ddc0 R08: 0000000000000000 R09:
>> 0000000000000000
>> [624967.868391] R10: 0000000000000000 R11: 00000000ffffffff R12:
>> ffff880107c9e180
>> [624967.868393] R13: 0000000000000001 R14: 0000000000000000 R15:
>> ffff880116802300
>> [624967.868396] FS:  0000000000000000(0000) GS:ffff880001a00000(0000)
>> knlGS:0000000000000000
>> [624967.868398] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [624967.868400] CR2: 0000000000000000 CR3: 00000000015c8000 CR4:
>> 00000000000406f0
>> [624967.868403] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> [624967.868405] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>> 0000000000000400
>> [624967.868408] Process rpciod/0 (pid: 2267, threadinfo
>> ffff880107e8c000, task ffff880116802300)
>> [624967.868410] Stack:
>> [624967.868411]  0000000000012300 ffff880107c9e180 ffff880022c5a000
>> 0000000000000001
>> [624967.868415]<0>  ffff880107e8dde0 ffffffffa04934d0 ffff880107c9e180
>> ffff880107c9e1f0
>> [624967.868419]<0>  ffff880107e8de00 ffffffffa040ab17 0000000000000001
>> ffff880107c9e180
>> [624967.868423] Call Trace:
>> [624967.868435]  [<ffffffffa04934d0>]
>> nfs41_sequence_call_done+0x20/0x100 [nfs]
>> [624967.868447]  [<ffffffffa040ab17>] rpc_exit_task+0x27/0x60 [sunrpc]
>> [624967.868457]  [<ffffffffa040b322>] __rpc_execute+0xa2/0x290 [sunrpc]
>> [624967.868466]  [<ffffffffa040b510>] ? rpc_async_schedule+0x0/0x20 [sunrpc]
>> [624967.868475]  [<ffffffffa040b520>] rpc_async_schedule+0x10/0x20 [sunrpc]
>> [624967.868481]  [<ffffffff81059fed>] worker_thread+0x12d/0x1f0
>> [624967.868485]  [<ffffffff8105e530>] ? autoremove_wake_function+0x0/0x40
>> [624967.868488]  [<ffffffff81059ec0>] ? worker_thread+0x0/0x1f0
>> [624967.868491]  [<ffffffff8105e08e>] kthread+0x8e/0xa0
>> [624967.868495]  [<ffffffff81003b54>] kernel_thread_helper+0x4/0x10
>> [624967.868498]  [<ffffffff8105e000>] ? kthread+0x0/0xa0
>> [624967.868501]  [<ffffffff81003b50>] ? kernel_thread_helper+0x0/0x10
>> [624967.868503] Code: 08 80 fa 80 74 73 48 8b 0b 0f b6 c2 48 c1 e0 02 48
>> 03 41 60 8b 4b 0c 81 f9 e8 d8 ff ff 0f 84 26 01 00 00 85 c9 0f 85 fe 00
>> 00 00<83>  00 01 48 8b 03 4c 8b 6b 10 4c 8b a0 38 02 00 00 49 8d bc 24
>> [624967.868532] RIP  [<ffffffffa0492f42>] nfs41_sequence_done+0x52/0x2e0
>> [nfs]
>> [624967.868544]  RSP<ffff880107e8dda0>
>> [624967.868546] CR2: 0000000000000000
>> [624967.868548] ---[ end trace a7919e7f17c0a727 ]---
>>
>>
>> Tigran.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

