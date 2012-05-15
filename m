Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:33968 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758809Ab2EONSl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 09:18:41 -0400
Message-ID: <4FB25799.8060306@panasas.com>
Date: Tue, 15 May 2012 16:18:17 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Johannes Schild <JSchild@gmx.de>
CC: <osd-dev@open-osd.org>, <linux-nfs@vger.kernel.org>
Subject: Re: Questions about Exofs
References: <20120515090332.182970@gmx.net> <4FB22658.9010909@panasas.com> <20120515121931.192500@gmx.net>
In-Reply-To: <20120515121931.192500@gmx.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/15/2012 03:19 PM, Johannes Schild wrote:

> Hi,
> 
> thanks for your fast reply.
> 
> But now i run into a nullpointer exception while mounting /dev/osd0
> 
> 

> [ 329.919112] Modules linked in: raid456 async_raid6_recov async_pq
> 		raid6_pq async_memcpy bnx2i cnic cxgb4i cxgb3i iscsi_tcp be2iscsi
> 		iscsi_boot_sysfs uio cxgb4 libcxgbi cxgb3 mdio libiscsi_tcp libiscsi
> 		scsi_transport_iscsi fuse ip6t_REJECT nf_conntrack_ipv6
> 		nf_defrag_ipv6 xt_state nf_conntrack 8021q ip6table_filter ip6_tables
> 		garp stp llc fcoe libfcoe libfc scsi_transport_fc scsi_tgt
> 		snd_ens1371 gameport snd_rawmidi snd_ac97_codec ac97_bus joydev
> 		snd_seq snd_seq_device snd_pcm ppdev vmw_balloon floppy parport_pc
> 		snd_timer snd pcnet32 microcode parport pcspkr mii snd_page_alloc
> 		i2c_piix4 i2c_core shpchp uinput mptspi mptscsih mptbase
> 		scsi_transport_spi [last unloaded: iscsi_tcp] [ 329.919133]


One thing that worries me here is this: [last unloaded: iscsi_tcp]

Actually it should be in the loaded bunch not unloaded. I have no idea how can that happen.
Do you see any prints in dmsg regarding iscsi, before the crash?

> [  329.919134] Pid: 2234, comm: mount Not tainted 3.3.0-pnfs #1 VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform
> [  329.919137] RIP: 0010:[<ffffffff81259799>]  [<ffffffff81259799>] exofs_free_sbi+0x59/0xa0
> [  329.919139] RSP: 0018:ffff88003c4e5bc8  EFLAGS: 00010246
> [  329.919141] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000001795
> [  329.919142] RDX: 0000000000000000 RSI: 0000000000000046 RDI: ffff88003c4f5000
> [  329.919143] RBP: ffff88003c4e5bd8 R08: 0000000000000000 R09: 0000000000000000
> [  329.919144] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88003c4f5000
> [  329.919145] R13: ffff88003c4e5d58 R14: 00000000fffffffb R15: ffff88003bd4e360
> [  329.919146] FS:  00007f68ce81d800(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
> [  329.919148] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  329.919149] CR2: 0000000000000000 CR3: 000000003cbfd000 CR4: 00000000000406f0
> [  329.919152] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  329.919155] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  329.919156] Process mount (pid: 2234, threadinfo ffff88003c4e4000, task ffff88003aa42e40)
> [  329.919157] Stack:
> [  329.919158]  ffff88003c4f5000 ffff88003c4f5800 ffff88003c4e5d18 ffffffff8125a780
> [  329.919160]  ffff88003c4e5c84 0000000081f27618 ffffffff81f27600 ffff88003f80c288
> [  329.919162]  ffff88003ddbeee0 0000000000000000 ffff88003c4e5c48 ffffffff812c8433
> [  329.919164] Call Trace:
> [  329.919166]  [<ffffffff8125a780>] exofs_fill_super+0x440/0x6e0
> [  329.919171]  [<ffffffff812c8433>] ? idr_pre_get+0x53/0x90
> [  329.919173]  [<ffffffff8125a340>] ? exofs_read_lookup_dev_table+0x480/0x480
> [  329.919176]  [<ffffffff81180e18>] mount_nodev+0x58/0xb0
> [  329.919178]  [<ffffffff812594ff>] exofs_mount+0x4f/0x80
> [  329.919179]  [<ffffffff81181e13>] mount_fs+0x43/0x1b0
> [  329.919182]  [<ffffffff8119b56a>] vfs_kern_mount+0x6a/0xf0
> [  329.919183]  [<ffffffff8119bd44>] do_kern_mount+0x54/0x110
> [  329.919185]  [<ffffffff8119d4b4>] do_mount+0x1a4/0x830
> [  329.919188]  [<ffffffff8115da33>] ? alloc_pages_current+0xa3/0x110
> [  329.919191]  [<ffffffff811229e4>] ? __get_free_pages+0x14/0x50
> [  329.919193]  [<ffffffff8119d18a>] ? copy_mount_options+0x3a/0x170
> [  329.919194]  [<ffffffff8119dc80>] sys_mount+0x90/0xe0
> [  329.919199]  [<ffffffff81605aa9>] system_call_fastpath+0x16/0x1b
> [  329.919200] Code: 66 90 41 8b 84 24 70 03 00 00 83 eb 01 39 c3 72 50 41 8b 94 24 74 03 00 00 01 c2 39 d3 73 42 89 da 29 c2 49 8b 84 24 88 03 00 00 <48> 8b 04 d0 48 8b 38 48 85 ff 74 0c 48 c7 00 00 00 00 00 e8 6f 
> [  329.919214] RIP  [<ffffffff81259799>] exofs_free_sbi+0x59/0xa0
> [  329.919216]  RSP <ffff88003c4e5bc8>
> [  329.919217] CR2: 0000000000000000
> [  329.919220] ---[ end trace e5a3b1124e42d9e3 ]---
> 
> 


could you please do:
[]$ gdb fs/exofs/exofs.ko
Inside gdb
> list *(exofs_free_sbi+0x59)
and also
> list *(exofs_fill_super+0x440)

> Is there any possibility to avoid these failure?
> 


I've never had it lets try to resolve it.

Could you enable CONFIG_EXOFS_DEBUG it's under:
	miscellaneous-filesystems/exofs in make xconfig

Then re-run everything send me the output
[]$ ./do-osd stop
[]$ ls /dev/osd*
<1>
[]$ ./do-osd
[]$ ls /dev/osd*
[]$ ./do-exofs format
Send me the output of that
[]$ ./do-exofs start
Send me the dmesg output of this stage, or if not too big
the dmesg output of from before ./do-osd <1>

> Just now i am using the 3.3.0 kernel from the linux-pnfs repository.
> 


When compiling the Kernel, Did you enable CONFIG_PNFSD ?
(That is the pNFSD Server Kernel Support)
What platform are you using? Distro + ARCH ?

This should be a good tree. Though usually I use an
open-osd.org/linux-open-osd.git based tree. But I don't see much
difference. Let me have a look if there is something grossly
missing.

> 
> Thanks in adavance
> 


Sorry for your trouble I have neglected the public trees for a
while. Let me see if I can push a more tested tree up on
open-osd.org.

> Cheers
> Johannes 
> 


Thanks
Boaz

> -------- Original-Nachricht --------
>> Datum: Tue, 15 May 2012 12:48:08 +0300
>> Von: Boaz Harrosh <bharrosh@panasas.com>
>> An: Johannes Schild <JSchild@gmx.de>
>> CC: linux-nfs@vger.kernel.org, open-osd <osd-dev@open-osd.org>
>> Betreff: Re: Questions about Exofs
> 
>> On 05/15/2012 12:03 PM, Johannes Schild wrote:
>>
>>> Hi,
>>>
>>> i try to set up the object-based layout with pnfs.
>>> I am using the OSC-OSD as target. It works well and i can login.
>>> Trying the scripts "do-*" from git://git.open-osd.org/open-osd.git the
>> do-osd script works for me. The do-exofs doesnt, here i have some question:
>>>
>>> 1. Is the UUID in the do-exofs script optional?
>>>
>>
>>
>> No it is not optional
>>
>>> 2. If no how can i get it for my device?
>>>
>>
>>
>> Exactly! the ./do-exofs format command will set this for you, as well as
>> mkfs.exofs the
>> FS for you.
>>
>>> 3. It is mandatory to use raid-driver (raid456) in the script? Why?
>>>
>>
>>
>> What? where? Rrrr you are right. this is a very old tree. Let me see
>> if I have something newer to push. It should all load automatically now.
>>
>> But yes the dependency on raid456.ko is built in. Though if you use
>> raid=0 on the format command line it will not be used in run time.
>>
>>>
>>> The error is: 
>>> mount -t exofs -o
>> osdname=d2683732-c906-4ee1-9dbd-c10c27bb40df,pid=0x10000,_netdev /dev/osd0 /mnt/osd0/
>>> mount: wrong fs type, bad option, bad superblock on /dev/osd0,
>>>        missing codepage or helper program, or other error
>>>        In some cases useful info is found in syslog - try
>>>        dmesg | tail  or so
>>>
>>> dmesg says:
>>> exofs: Unable to mount exofs on (null) pid=0x0 err=-22
>>>
>>
>>
>> Probably you forgot the "./do-exofs format" stage. Please read the script
>> before, you might need to edit it. It is the stage that calls mkfs.exofs
>> to make a new filesystem for you. (An OSD is a raw device that can host
>> many filesystems each in it's own osd-partition.
>>
>>>
>>> Thanks for answering my questions.
>>
>>
>>> Regards
>>> Johannes
>>>
>>
>>
>> Cheers
>> Boaz
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


