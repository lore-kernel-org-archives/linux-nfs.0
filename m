Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate2.disneyanimation.com ([198.187.190.102]:24187 "EHLO
	mailgate2.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754774Ab1CQRsr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2011 13:48:47 -0400
From: Kevin Constantine <Kevin.Constantine@disneyanimation.com>
Message-ID: <4D82497E.6000004@disney.com>
Date: Thu, 17 Mar 2011 10:48:46 -0700
To: Steve Dickson <SteveD@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS hanging waiting for a process to be killable?
References: <4D80F8B9.1080900@disney.com> <4D823B81.5040702@RedHat.com>
In-Reply-To: <4D823B81.5040702@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks Steve-

It sure looks similar.  I guess there's an el6 equivalent issue as well: 
672305


On 03/17/2011 09:49 AM, Steve Dickson wrote:
> I wonder if this is the same problem Jim was seeing a while back
> as well as some other people.... Something similar to:
>      https://bugzilla.redhat.com/show_bug.cgi?id=669204
>
> steved.
>
> On 03/16/2011 01:51 PM, Kevin Constantine wrote:
>> We had a rash of machines start spewing the following backtraces last night every 63 seconds:
>>
>> Mar 16 10:07:52 drfa506 kernel: BUG: soft lockup - CPU#2 stuck for 61s! [maya.bin:19659]
>> Mar 16 10:07:52 drfa506 kernel: Modules linked in: autofs4 fcoe libfcoe libfc scsi_transport_fc scsi_tgt 8021q garp stp llc nfs lockd fscache nfs_acl auth_rpcgss sunrpc cpufreq_ondemand acpi_cpufreq freq_table ipv6 uinput sg dcdbas serio_raw i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support i5k_amb hwmon i5000_edac edac_core shpchp e1000e ext4 mbcache jbd2 sd_mod crc_t10dif ata_generic pata_acpi ata_piix mptsas mptscsih mptbase scsi_transport_sas dm_mod [last unloaded: microcode]
>> Mar 16 10:07:52 drfa506 kernel: CPU 2:
>> Mar 16 10:07:52 drfa506 kernel: Modules linked in: autofs4 fcoe libfcoe libfc scsi_transport_fc scsi_tgt 8021q garp stp llc nfs lockd fscache nfs_acl auth_rpcgss sunrpc cpufreq_ondemand acpi_cpufreq freq_table ipv6 uinput sg dcdbas serio_raw i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support i5k_amb hwmon i5000_edac edac_core shpchp e1000e ext4 mbcache jbd2 sd_mod crc_t10dif ata_generic pata_acpi ata_piix mptsas mptscsih mptbase scsi_transport_sas dm_mod [last unloaded: microcode]
>> Mar 16 10:07:52 drfa506 kernel: Pid: 19659, comm: maya.bin Tainted: G      W  ----------------  2.6.32-71.14.1.el6.x86_64 #1 BlackfordESB2
>> Mar 16 10:07:52 drfa506 kernel: RIP: 0010:[<ffffffff814cb597>] [<ffffffff814cb597>] _spin_unlock_irqrestore+0x17/0x20
>> Mar 16 10:07:52 drfa506 kernel: RSP: 0018:ffff8807fa8cb8f8  EFLAGS: 00000282
>> Mar 16 10:07:52 drfa506 kernel: RAX: 0000000000000282 RBX: ffff8807fa8cb8f8 RCX: ffff8800280359c0
>> Mar 16 10:07:52 drfa506 kernel: RDX: ffff8800280359b8 RSI: 0000000000000282 RDI: 0000000000000282
>> Mar 16 10:07:52 drfa506 kernel: RBP: ffffffff81013c8e R08: ffff8800280359c0 R09: f84d68504e493607
>> Mar 16 10:07:52 drfa506 kernel: R10: 0000000000000000 R11: 0000000000000000 R12: ffffffffa0229557
>> Mar 16 10:07:52 drfa506 kernel: R13: ffff8807fa8cb888 R14: ffffffff814cb72b R15: ffff8807fa8cb858
>> Mar 16 10:07:52 drfa506 kernel: FS:  00007f1a57277860(0000) GS:ffff880028280000(0000) knlGS:0000000000000000
>> Mar 16 10:07:52 drfa506 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> Mar 16 10:07:52 drfa506 kernel: CR2: 00007f484ea2a180 CR3: 000000072615d000 CR4: 00000000000006e0
>> Mar 16 10:07:52 drfa506 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> Mar 16 10:07:52 drfa506 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> Mar 16 10:07:52 drfa506 kernel: Call Trace:
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff81091ede>] ? abort_exclusive_wait+0x6e/0xb0
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff814c9ca4>] ? __wait_on_bit_lock+0xa4/0xc0
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff8104af40>] ? __phys_addr+0x0/0x50
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffffa02cc560>] ? nfs_wait_bit_killable+0x0/0x40 [nfs]
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff814c9d38>] ? out_of_line_wait_on_bit_lock+0x78/0x90
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff81091e20>] ? wake_bit_function+0x0/0x50
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffffa02d9c9a>] ? nfs_commit_inode+0xaa/0x1c0 [nfs]
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffffa02d9e29>] ? nfs_wb_page+0x79/0xd0 [nfs]
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffffa02d8170>] ? nfs_page_find_request+0x50/0x70 [nfs]
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffffa02d9ec0>] ? nfs_flush_incompatible+0x40/0x70 [nfs]
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffffa02c8aa3>] ? nfs_write_begin+0x93/0x220 [nfs]
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff8110cb0e>] ? generic_file_buffered_write+0x10e/0x2a0
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff8110e460>] ? __generic_file_aio_write+0x250/0x480
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff8110e6ff>] ? generic_file_aio_write+0x6f/0xe0
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffffa02c971a>] ? nfs_file_write+0xda/0x1e0 [nfs]
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff8116cd9a>] ? do_sync_write+0xfa/0x140
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff81091de0>] ? autoremove_wake_function+0x0/0x40
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff81059db2>] ? finish_task_switch+0x42/0xd0
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff811ffb76>] ? security_file_permission+0x16/0x20
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff8116d098>] ? vfs_write+0xb8/0x1a0
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff810d42b2>] ? audit_syscall_entry+0x272/0x2a0
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff8116dad1>] ? sys_write+0x51/0x90
>> Mar 16 10:07:52 drfa506 kernel: [<ffffffff81013172>] ? system_call_fastpath+0x16/0x1b
>> Mar 16 10:08:57 drfa506 kernel: BUG: soft lockup - CPU#2 stuck for 61s! [maya.bin:19659]
>> Mar 16 10:08:57 drfa506 kernel: Modules linked in: autofs4 fcoe libfcoe libfc scsi_transport_fc scsi_tgt 8021q garp stp llc nfs lockd fscache nfs_acl auth_rpcgss sunrpc cpufreq_ondemand acpi_cpufreq freq_table ipv6 uinput sg dcdbas serio_raw i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support i5k_amb hwmon i5000_edac edac_core shpchp e1000e ext4 mbcache jbd2 sd_mod crc_t10dif ata_generic pata_acpi ata_piix mptsas mptscsih mptbase scsi_transport_sas dm_mod [last unloaded: microcode]
>> Mar 16 10:08:57 drfa506 kernel: CPU 2:
>> Mar 16 10:08:57 drfa506 kernel: Modules linked in: autofs4 fcoe libfcoe libfc scsi_transport_fc scsi_tgt 8021q garp stp llc nfs lockd fscache nfs_acl auth_rpcgss sunrpc cpufreq_ondemand acpi_cpufreq freq_table ipv6 uinput sg dcdbas serio_raw i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support i5k_amb hwmon i5000_edac edac_core shpchp e1000e ext4 mbcache jbd2 sd_mod crc_t10dif ata_generic pata_acpi ata_piix mptsas mptscsih mptbase scsi_transport_sas dm_mod [last unloaded: microcode]
>> Mar 16 10:08:57 drfa506 kernel: Pid: 19659, comm: maya.bin Tainted: G      W  ----------------  2.6.32-71.14.1.el6.x86_64 #1 BlackfordESB2
>> Mar 16 10:08:57 drfa506 kernel: RIP: 0010:[<ffffffff81091ce1>] [<ffffffff81091ce1>] bit_waitqueue+0x51/0xd0
>> Mar 16 10:08:57 drfa506 kernel: RSP: 0018:ffff8807fa8cb978  EFLAGS: 00000246
>> Mar 16 10:08:57 drfa506 kernel: RAX: 0000000000000000 RBX: ffff8807fa8cb988 RCX: 0000000000000082
>> Mar 16 10:08:57 drfa506 kernel: RDX: 0000000000010d80 RSI: 0000000000000007 RDI: ffff8807949994d8
>> Mar 16 10:08:57 drfa506 kernel: RBP: ffffffff81013c8e R08: ffff8800280359c0 R09: f84d68504e493607
>> Mar 16 10:08:57 drfa506 kernel: R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800280359b8
>> Mar 16 10:08:57 drfa506 kernel: R13: f84d68504e493607 R14: 0000000000000000 R15: 0000000000000000
>> Mar 16 10:08:57 drfa506 kernel: FS:  00007f1a57277860(0000) GS:ffff880028280000(0000) knlGS:0000000000000000
>> Mar 16 10:08:57 drfa506 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> Mar 16 10:08:57 drfa506 kernel: CR2: 00007f484ea2a180 CR3: 000000072615d000 CR4: 00000000000006e0
>> Mar 16 10:08:57 drfa506 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> Mar 16 10:08:57 drfa506 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> Mar 16 10:08:57 drfa506 kernel: Call Trace:
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff81091ca7>] ? bit_waitqueue+0x17/0xd0
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff814c9ced>] ? out_of_line_wait_on_bit_lock+0x2d/0x90
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff81091e20>] ? wake_bit_function+0x0/0x50
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffffa02d9c9a>] ? nfs_commit_inode+0xaa/0x1c0 [nfs]
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffffa02d9e29>] ? nfs_wb_page+0x79/0xd0 [nfs]
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffffa02d8170>] ? nfs_page_find_request+0x50/0x70 [nfs]
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffffa02d9ec0>] ? nfs_flush_incompatible+0x40/0x70 [nfs]
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffffa02c8aa3>] ? nfs_write_begin+0x93/0x220 [nfs]
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff8110cb0e>] ? generic_file_buffered_write+0x10e/0x2a0
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff8110e460>] ? __generic_file_aio_write+0x250/0x480
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff8110e6ff>] ? generic_file_aio_write+0x6f/0xe0
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffffa02c971a>] ? nfs_file_write+0xda/0x1e0 [nfs]
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff8116cd9a>] ? do_sync_write+0xfa/0x140
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff81091de0>] ? autoremove_wake_function+0x0/0x40
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff81059db2>] ? finish_task_switch+0x42/0xd0
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff811ffb76>] ? security_file_permission+0x16/0x20
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff8116d098>] ? vfs_write+0xb8/0x1a0
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff810d42b2>] ? audit_syscall_entry+0x272/0x2a0
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff8116dad1>] ? sys_write+0x51/0x90
>> Mar 16 10:08:57 drfa506 kernel: [<ffffffff81013172>] ? system_call_fastpath+0x16/0x1b
>>
>>
>> The process 19659 was in the process of being killed when these messages began.  That process became disinherited by its parent and is now parented to init before the kill was sent.  All of the other processes on the machine are now blocking in Uninteruptible sleep.
>>
>> I'm hoping that maybe this will spark some idea about what might be causing this issue.
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

