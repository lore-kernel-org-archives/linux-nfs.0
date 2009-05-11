From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] nfs lockd: detect grace_list corruption
Date: Mon, 11 May 2009 14:13:50 +0800
Message-ID: <4A07C21E.3020309@cn.fujitsu.com>
References: <49F12D78.2040304@cn.fujitsu.com> <20090424231252.GD22477@fieldses.org> <4A0155A0.4020008@cn.fujitsu.com> <20090506203227.GM9861@fieldses.org> <4A0284EB.9050202@cn.fujitsu.com> <20090508182648.GD20539@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: neilb@suse.de, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org,
	FNST-Bian Naimeng <biannm@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50456 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751161AbZEKGOd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 May 2009 02:14:33 -0400
In-Reply-To: <20090508182648.GD20539@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields said the following on 2009-5-9 2:26:
> On Thu, May 07, 2009 at 02:51:23PM +0800, Wang Chen wrote:
>> J. Bruce Fields said the following on 2009-5-7 4:32:
>>> On Wed, May 06, 2009 at 05:17:20PM +0800, Wang Chen wrote:
>>>> J. Bruce Fields said the following on 2009-4-25 7:12:
>>>>> On Fri, Apr 24, 2009 at 11:09:44AM +0800, Wang Chen wrote:
>>>>>> Although I can't reproduce it now, it really happened that some lock manager
>>>>>> started grace period but didn't end it.
>>>>>> This causes an lm entry be left in grace_list, and when service nfs restart,
>>>>>> the same lm will be added again into the list.
>>>>>> As you know, adding an entry, which is in the list, to a list will leads to
>>>>>> list corruption.
>>>>> I'd really like to understand why locks_end_grace() isn't being called.
>>>>> I'm probably overlooking something obvious, but I just can't see how
>>>>> lockd or nfsd can be shut down right now without locks_end_grace() being
>>>>> called.
>>>>>
>>>> Me neither can figure out why locks_end_grace() isn't being called.
>>>>
>>>> But do locks_start_grace() twice can trigger this warning too.
>>>> You can do
>>>> 1. service nfs restart
>>>> 2. (immediately) kill -s SIGKILL lockd
>>>> this can trigger
>>>> ---
>>>> lockd(void *vrqstp)
>>>> ...
>>>> 		if (signalled()) {
>>>> 			flush_signals(current);
>>>> 			if (nlmsvc_ops) {
>>>> 				nlmsvc_invalidate_all();
>>>> 				set_grace_period();
>>>> ---
>>>> and makes locks_start_grace() be called twice without locks_end_grace().
>>> Ah-hah!
>>>
>>>> So I still suggest to do something to protect the lm list. :)
>>> I wouldn't be opposed to a simple WARN_ON(!list_empty()) in
>>> locks_start_grace(), but I'm mainly worried about fixing the original
>>> bug.  How about the following?
>>>
>> Yeah, the following fix is OK to me, although it only fixed
>> "start_grace again after start_grace" case.
> 
> OK, thanks.
> 
>> The bug about "quit lockd without end_grace", which I encountered before
>> incidentally, maybe is still there.
> 
> You're talking about the report that started this thread?:
> 
> 	http://marc.info/?l=linux-nfs&m=124054262421444&w=2
> 

Yes. I mean this.

> It looks to me like that could be explained by two start_grace's in a
> row.
> 

But in that report, I didn't post the total message.
Here are something show that:
1. not only lockd has the problem, but nfsd also.
2. every time I do "service nfs restart", I got the warning, so this is not
   "two start_grace's in a row" problem.
Following is more message I got on last month.
------------------------------------------------------
Apr 16 16:35:41 localhost mountd[15061]: Caught signal 15, un-registering and exiting.
Apr 16 16:35:42 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 16 16:35:43 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 16 16:35:43 localhost kernel: ------------[ cut here ]------------
Apr 16 16:35:43 localhost kernel: WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Apr 16 16:35:43 localhost kernel: Hardware name: Presario M2000 (PT365PA#AB2)      
Apr 16 16:35:43 localhost kernel: list_add corruption. next->prev should be prev (ef8fe958), but was ef8ff128. (next=ef8ff128).
Apr 16 16:35:43 localhost kernel: Modules linked in: fuse i915 drm i2c_algo_bit nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 p4_clockmod dm_multipath uinput snd_intel8x0m snd_intel8x0 snd_seq_dummy snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore 8139cp firewire_ohci firewire_core snd_page_alloc tifm_7xx1 i2c_i801 iTCO_wdt 8139too tifm_core i2c_core yenta_socket crc_itu_t iTCO_vendor_support pcspkr mii rsrc_nonstatic wmi video output ata_generic pata_acpi [last unloaded: microcode]
Apr 16 16:35:43 localhost kernel: Pid: 17455, comm: rpc.nfsd Tainted: G        W  2.6.30-rc2 #3
Apr 16 16:35:43 localhost kernel: Call Trace:
Apr 16 16:35:43 localhost kernel: [<c042d5b5>] warn_slowpath+0x71/0xa0
Apr 16 16:35:43 localhost kernel: [<efc17dec>] ? nfsd4_build_namelist+0x0/0x8e [nfsd]
Apr 16 16:35:43 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 16 16:35:43 localhost kernel: [<c051c61a>] ? _raw_spin_lock+0x53/0xfa
Apr 16 16:35:43 localhost kernel: [<c04a3f66>] ? mntput_no_expire+0x1c/0x101
Apr 16 16:35:43 localhost kernel: [<c04a0062>] ? dput+0x35/0x103
Apr 16 16:35:43 localhost kernel: [<c051c61a>] ? _raw_spin_lock+0x53/0xfa
Apr 16 16:35:43 localhost kernel: [<c051c89f>] __list_add+0x27/0x5c
Apr 16 16:35:43 localhost kernel: [<ef8f6daa>] locks_start_grace+0x22/0x30 [lockd]
Apr 16 16:35:43 localhost kernel: [<efc13a49>] nfs4_state_start+0x7a/0xdd [nfsd]
Apr 16 16:35:43 localhost kernel: [<efbfd5be>] nfsd_svc+0x57/0xf9 [nfsd]
Apr 16 16:35:43 localhost kernel: [<efbfdff6>] ? write_threads+0x0/0x59 [nfsd]
Apr 16 16:35:43 localhost kernel: [<efbfe02b>] write_threads+0x35/0x59 [nfsd]
Apr 16 16:35:43 localhost kernel: [<efbfd84d>] nfsctl_transaction_write+0x3b/0x58 [nfsd]
Apr 16 16:35:43 localhost kernel: [<efbfd812>] ? nfsctl_transaction_write+0x0/0x58 [nfsd]
Apr 16 16:35:43 localhost kernel: [<c04927af>] vfs_write+0x7c/0xad
Apr 16 16:35:43 localhost kernel: [<c0492879>] sys_write+0x3b/0x60
Apr 16 16:35:43 localhost kernel: [<c0403148>] sysenter_do_call+0x12/0x3c
Apr 16 16:35:43 localhost kernel: ---[ end trace fa484bd6d19ade87 ]---
Apr 16 16:35:43 localhost kernel: NFSD: starting 90-second grace period
...snip...
Apr 17 13:02:54 localhost mountd[17468]: Caught signal 15, un-registering and exiting.
Apr 17 13:02:54 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 13:02:55 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 13:02:55 localhost kernel: ------------[ cut here ]------------
Apr 17 13:02:55 localhost kernel: WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Apr 17 13:02:55 localhost kernel: Hardware name: Presario M2000 (PT365PA#AB2)      
Apr 17 13:02:55 localhost kernel: list_add corruption. next->prev should be prev (ef8fe958), but was ef8ff128. (next=ef8ff128).
Apr 17 13:02:55 localhost kernel: Modules linked in: fuse i915 drm i2c_algo_bit nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 p4_clockmod dm_multipath uinput snd_intel8x0m snd_intel8x0 snd_seq_dummy snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore 8139cp firewire_ohci firewire_core snd_page_alloc tifm_7xx1 i2c_i801 iTCO_wdt 8139too tifm_core i2c_core yenta_socket crc_itu_t iTCO_vendor_support pcspkr mii rsrc_nonstatic wmi video output ata_generic pata_acpi [last unloaded: microcode]
Apr 17 13:02:55 localhost kernel: Pid: 22642, comm: rpc.nfsd Tainted: G        W  2.6.30-rc2 #3
Apr 17 13:02:55 localhost kernel: Call Trace:
Apr 17 13:02:55 localhost kernel: [<c042d5b5>] warn_slowpath+0x71/0xa0
Apr 17 13:02:55 localhost kernel: [<efc17dec>] ? nfsd4_build_namelist+0x0/0x8e [nfsd]
Apr 17 13:02:55 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 13:02:55 localhost kernel: [<c051c61a>] ? _raw_spin_lock+0x53/0xfa
Apr 17 13:02:55 localhost kernel: [<c04a3f66>] ? mntput_no_expire+0x1c/0x101
Apr 17 13:02:55 localhost kernel: [<c04a0062>] ? dput+0x35/0x103
Apr 17 13:02:55 localhost kernel: [<c051c61a>] ? _raw_spin_lock+0x53/0xfa
Apr 17 13:02:55 localhost kernel: [<c051c89f>] __list_add+0x27/0x5c
Apr 17 13:02:55 localhost kernel: [<ef8f6daa>] locks_start_grace+0x22/0x30 [lockd]
Apr 17 13:02:55 localhost kernel: [<efc13a49>] nfs4_state_start+0x7a/0xdd [nfsd]
Apr 17 13:02:55 localhost kernel: [<efbfd5be>] nfsd_svc+0x57/0xf9 [nfsd]
Apr 17 13:02:55 localhost kernel: [<efbfdff6>] ? write_threads+0x0/0x59 [nfsd]
Apr 17 13:02:55 localhost kernel: [<efbfe02b>] write_threads+0x35/0x59 [nfsd]
Apr 17 13:02:55 localhost kernel: [<efbfd84d>] nfsctl_transaction_write+0x3b/0x58 [nfsd]
Apr 17 13:02:55 localhost kernel: [<efbfd812>] ? nfsctl_transaction_write+0x0/0x58 [nfsd]
Apr 17 13:02:55 localhost kernel: [<c04927af>] vfs_write+0x7c/0xad
Apr 17 13:02:55 localhost kernel: [<c0492879>] sys_write+0x3b/0x60
Apr 17 13:02:55 localhost kernel: [<c0403148>] sysenter_do_call+0x12/0x3c
Apr 17 13:02:55 localhost kernel: ---[ end trace fa484bd6d19ade88 ]---
Apr 17 13:02:55 localhost kernel: NFSD: starting 90-second grace period
Apr 17 13:04:07 localhost mountd[22655]: Caught signal 15, un-registering and exiting.
Apr 17 13:04:07 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 13:04:07 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 13:04:07 localhost kernel: NFSD: starting 90-second grace period
Apr 17 13:05:04 localhost mountd[22760]: Caught signal 15, un-registering and exiting.
Apr 17 13:05:04 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 13:05:05 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 13:05:05 localhost kernel: NFSD: starting 90-second grace period
Apr 17 13:06:10 localhost mountd[22859]: Caught signal 15, un-registering and exiting.
Apr 17 13:06:10 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 13:06:10 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 13:06:10 localhost kernel: NFSD: starting 90-second grace period
Apr 17 13:08:07 localhost mountd[22960]: Caught signal 15, un-registering and exiting.
Apr 17 13:08:07 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 13:08:07 localhost kernel: ------------[ cut here ]------------
Apr 17 13:08:07 localhost kernel: WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Apr 17 13:08:07 localhost kernel: Hardware name: Presario M2000 (PT365PA#AB2)      
Apr 17 13:08:07 localhost kernel: list_add corruption. next->prev should be prev (ef8fe958), but was ef8ff128. (next=ef8ff128).
Apr 17 13:08:07 localhost kernel: Modules linked in: fuse i915 drm i2c_algo_bit nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 p4_clockmod dm_multipath uinput snd_intel8x0m snd_intel8x0 snd_seq_dummy snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore 8139cp firewire_ohci firewire_core snd_page_alloc tifm_7xx1 i2c_i801 iTCO_wdt 8139too tifm_core i2c_core yenta_socket crc_itu_t iTCO_vendor_support pcspkr mii rsrc_nonstatic wmi video output ata_generic pata_acpi [last unloaded: microcode]
Apr 17 13:08:07 localhost kernel: Pid: 23062, comm: lockd Tainted: G        W  2.6.30-rc2 #3
Apr 17 13:08:07 localhost kernel: Call Trace:
Apr 17 13:08:07 localhost kernel: [<c042d5b5>] warn_slowpath+0x71/0xa0
Apr 17 13:08:07 localhost kernel: [<c0422a96>] ? update_curr+0x11d/0x125
Apr 17 13:08:07 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 13:08:07 localhost kernel: [<c044b270>] ? trace_hardirqs_on+0xb/0xd
Apr 17 13:08:07 localhost kernel: [<c051c61a>] ? _raw_spin_lock+0x53/0xfa
Apr 17 13:08:07 localhost kernel: [<c051c89f>] __list_add+0x27/0x5c
Apr 17 13:08:07 localhost kernel: [<ef8f6daa>] locks_start_grace+0x22/0x30 [lockd]
Apr 17 13:08:07 localhost kernel: [<ef8f34da>] set_grace_period+0x39/0x53 [lockd]
Apr 17 13:08:07 localhost kernel: [<c06b8921>] ? lock_kernel+0x1c/0x28
Apr 17 13:08:07 localhost kernel: [<ef8f3558>] lockd+0x64/0x164 [lockd]
Apr 17 13:08:07 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 13:08:07 localhost kernel: [<c04227b0>] ? complete+0x34/0x3e
Apr 17 13:08:07 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 13:08:07 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 13:08:07 localhost kernel: [<c043dd42>] kthread+0x45/0x6b
Apr 17 13:08:07 localhost kernel: [<c043dcfd>] ? kthread+0x0/0x6b
Apr 17 13:08:07 localhost kernel: [<c0403c23>] kernel_thread_helper+0x7/0x10
Apr 17 13:08:07 localhost kernel: ---[ end trace fa484bd6d19ade89 ]---
Apr 17 13:08:07 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 13:08:07 localhost kernel: NFSD: starting 90-second grace period
Apr 17 14:39:45 localhost mountd[23074]: Caught signal 15, un-registering and exiting.
Apr 17 14:39:45 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 14:39:45 localhost kernel: ------------[ cut here ]------------
Apr 17 14:39:45 localhost kernel: WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Apr 17 14:39:45 localhost kernel: Hardware name: Presario M2000 (PT365PA#AB2)      
Apr 17 14:39:45 localhost kernel: list_add corruption. next->prev should be prev (ef8fe958), but was ef8ff128. (next=ef8ff128).
Apr 17 14:39:45 localhost kernel: Modules linked in: fuse i915 drm i2c_algo_bit nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 p4_clockmod dm_multipath uinput snd_intel8x0m snd_intel8x0 snd_seq_dummy snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore 8139cp firewire_ohci firewire_core snd_page_alloc tifm_7xx1 i2c_i801 iTCO_wdt 8139too tifm_core i2c_core yenta_socket crc_itu_t iTCO_vendor_support pcspkr mii rsrc_nonstatic wmi video output ata_generic pata_acpi [last unloaded: microcode]
Apr 17 14:39:45 localhost kernel: Pid: 24287, comm: lockd Tainted: G        W  2.6.30-rc2 #3
Apr 17 14:39:45 localhost kernel: Call Trace:
Apr 17 14:39:45 localhost kernel: [<c042d5b5>] warn_slowpath+0x71/0xa0
Apr 17 14:39:45 localhost kernel: [<c0422a96>] ? update_curr+0x11d/0x125
Apr 17 14:39:45 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 14:39:45 localhost kernel: [<c044b270>] ? trace_hardirqs_on+0xb/0xd
Apr 17 14:39:45 localhost kernel: [<c051c61a>] ? _raw_spin_lock+0x53/0xfa
Apr 17 14:39:45 localhost kernel: [<c051c89f>] __list_add+0x27/0x5c
Apr 17 14:39:45 localhost kernel: [<ef8f6daa>] locks_start_grace+0x22/0x30 [lockd]
Apr 17 14:39:45 localhost kernel: [<ef8f34da>] set_grace_period+0x39/0x53 [lockd]
Apr 17 14:39:45 localhost kernel: [<c06b8921>] ? lock_kernel+0x1c/0x28
Apr 17 14:39:45 localhost kernel: [<ef8f3558>] lockd+0x64/0x164 [lockd]
Apr 17 14:39:45 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 14:39:45 localhost kernel: [<c04227b0>] ? complete+0x34/0x3e
Apr 17 14:39:45 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 14:39:45 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 14:39:45 localhost kernel: [<c043dd42>] kthread+0x45/0x6b
Apr 17 14:39:45 localhost kernel: [<c043dcfd>] ? kthread+0x0/0x6b
Apr 17 14:39:45 localhost kernel: [<c0403c23>] kernel_thread_helper+0x7/0x10
Apr 17 14:39:45 localhost kernel: ---[ end trace fa484bd6d19ade8a ]---
Apr 17 14:39:45 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 14:39:45 localhost kernel: NFSD: starting 90-second grace period
Apr 17 14:41:32 localhost mountd[24299]: Caught signal 15, un-registering and exiting.
Apr 17 14:41:32 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 14:41:33 localhost kernel: ------------[ cut here ]------------
Apr 17 14:41:33 localhost kernel: WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Apr 17 14:41:33 localhost kernel: Hardware name: Presario M2000 (PT365PA#AB2)      
Apr 17 14:41:33 localhost kernel: list_add corruption. next->prev should be prev (ef8fe958), but was ef8ff128. (next=ef8ff128).
Apr 17 14:41:33 localhost kernel: Modules linked in: fuse i915 drm i2c_algo_bit nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 p4_clockmod dm_multipath uinput snd_intel8x0m snd_intel8x0 snd_seq_dummy snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore 8139cp firewire_ohci firewire_core snd_page_alloc tifm_7xx1 i2c_i801 iTCO_wdt 8139too tifm_core i2c_core yenta_socket crc_itu_t iTCO_vendor_support pcspkr mii rsrc_nonstatic wmi video output ata_generic pata_acpi [last unloaded: microcode]
Apr 17 14:41:33 localhost kernel: Pid: 24399, comm: lockd Tainted: G        W  2.6.30-rc2 #3
Apr 17 14:41:33 localhost kernel: Call Trace:
Apr 17 14:41:33 localhost kernel: [<c042d5b5>] warn_slowpath+0x71/0xa0
Apr 17 14:41:33 localhost kernel: [<c0422a96>] ? update_curr+0x11d/0x125
Apr 17 14:41:33 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 14:41:33 localhost kernel: [<c044b270>] ? trace_hardirqs_on+0xb/0xd
Apr 17 14:41:33 localhost kernel: [<c051c61a>] ? _raw_spin_lock+0x53/0xfa
Apr 17 14:41:33 localhost kernel: [<c051c89f>] __list_add+0x27/0x5c
Apr 17 14:41:33 localhost kernel: [<ef8f6daa>] locks_start_grace+0x22/0x30 [lockd]
Apr 17 14:41:33 localhost kernel: [<ef8f34da>] set_grace_period+0x39/0x53 [lockd]
Apr 17 14:41:33 localhost kernel: [<c06b8921>] ? lock_kernel+0x1c/0x28
Apr 17 14:41:33 localhost kernel: [<ef8f3558>] lockd+0x64/0x164 [lockd]
Apr 17 14:41:33 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 14:41:33 localhost kernel: [<c04227b0>] ? complete+0x34/0x3e
Apr 17 14:41:33 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 14:41:33 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 14:41:33 localhost kernel: [<c043dd42>] kthread+0x45/0x6b
Apr 17 14:41:33 localhost kernel: [<c043dcfd>] ? kthread+0x0/0x6b
Apr 17 14:41:33 localhost kernel: [<c0403c23>] kernel_thread_helper+0x7/0x10
Apr 17 14:41:33 localhost kernel: ---[ end trace fa484bd6d19ade8b ]---
Apr 17 14:41:33 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 14:41:33 localhost kernel: NFSD: starting 90-second grace period
Apr 17 14:42:16 localhost mountd[24411]: Caught signal 15, un-registering and exiting.
Apr 17 14:42:17 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 14:42:17 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 14:42:17 localhost kernel: NFSD: starting 90-second grace period
Apr 17 14:42:52 localhost mountd[24508]: Caught signal 15, un-registering and exiting.
Apr 17 14:42:52 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 14:42:53 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 14:42:53 localhost kernel: NFSD: starting 90-second grace period
Apr 17 14:43:28 localhost mountd[24602]: Caught signal 15, un-registering and exiting.
Apr 17 14:43:28 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 14:43:29 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 14:43:29 localhost kernel: NFSD: starting 90-second grace period
Apr 17 14:43:59 localhost mountd[24697]: Caught signal 15, un-registering and exiting.
Apr 17 14:43:59 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 14:44:00 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 14:44:00 localhost kernel: NFSD: starting 90-second grace period
Apr 17 14:44:28 localhost mountd[24791]: Caught signal 15, un-registering and exiting.
Apr 17 14:44:28 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 14:44:29 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 14:44:29 localhost kernel: NFSD: starting 90-second grace period
Apr 17 14:45:33 localhost mountd[24885]: Caught signal 15, un-registering and exiting.
Apr 17 14:45:33 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 14:45:34 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 14:45:34 localhost kernel: NFSD: starting 90-second grace period
Apr 17 14:46:05 localhost mountd[24988]: Caught signal 15, un-registering and exiting.
Apr 17 14:46:05 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 14:46:05 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 14:46:05 localhost kernel: NFSD: starting 90-second grace period
Apr 17 14:46:34 localhost mountd[25082]: Caught signal 15, un-registering and exiting.
Apr 17 14:46:34 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 14:46:35 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 14:46:35 localhost kernel: NFSD: starting 90-second grace period
Apr 17 15:35:01 localhost mountd[25176]: Caught signal 15, un-registering and exiting.
Apr 17 15:35:02 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 15:35:02 localhost kernel: ------------[ cut here ]------------
Apr 17 15:35:02 localhost kernel: WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Apr 17 15:35:02 localhost kernel: Hardware name: Presario M2000 (PT365PA#AB2)      
Apr 17 15:35:02 localhost kernel: list_add corruption. next->prev should be prev (ef8fe958), but was ef8ff128. (next=ef8ff128).
Apr 17 15:35:02 localhost kernel: Modules linked in: fuse i915 drm i2c_algo_bit nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 p4_clockmod dm_multipath uinput snd_intel8x0m snd_intel8x0 snd_seq_dummy snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore 8139cp firewire_ohci firewire_core snd_page_alloc tifm_7xx1 i2c_i801 iTCO_wdt 8139too tifm_core i2c_core yenta_socket crc_itu_t iTCO_vendor_support pcspkr mii rsrc_nonstatic wmi video output ata_generic pata_acpi [last unloaded: microcode]
Apr 17 15:35:02 localhost kernel: Pid: 25883, comm: lockd Tainted: G        W  2.6.30-rc2 #3
Apr 17 15:35:02 localhost kernel: Call Trace:
Apr 17 15:35:02 localhost kernel: [<c042d5b5>] warn_slowpath+0x71/0xa0
Apr 17 15:35:02 localhost kernel: [<c0422a96>] ? update_curr+0x11d/0x125
Apr 17 15:35:02 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 15:35:02 localhost kernel: [<c044b270>] ? trace_hardirqs_on+0xb/0xd
Apr 17 15:35:02 localhost kernel: [<c051c61a>] ? _raw_spin_lock+0x53/0xfa
Apr 17 15:35:02 localhost kernel: [<c051c89f>] __list_add+0x27/0x5c
Apr 17 15:35:02 localhost kernel: [<ef8f6daa>] locks_start_grace+0x22/0x30 [lockd]
Apr 17 15:35:02 localhost kernel: [<ef8f34da>] set_grace_period+0x39/0x53 [lockd]
Apr 17 15:35:02 localhost kernel: [<c06b8921>] ? lock_kernel+0x1c/0x28
Apr 17 15:35:02 localhost kernel: [<ef8f3558>] lockd+0x64/0x164 [lockd]
Apr 17 15:35:02 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 15:35:02 localhost kernel: [<c04227b0>] ? complete+0x34/0x3e
Apr 17 15:35:02 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 15:35:02 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 15:35:02 localhost kernel: [<c043dd42>] kthread+0x45/0x6b
Apr 17 15:35:02 localhost kernel: [<c043dcfd>] ? kthread+0x0/0x6b
Apr 17 15:35:02 localhost kernel: [<c0403c23>] kernel_thread_helper+0x7/0x10
Apr 17 15:35:02 localhost kernel: ---[ end trace fa484bd6d19ade8c ]---
Apr 17 15:35:02 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 15:35:02 localhost kernel: NFSD: starting 90-second grace period
Apr 17 15:55:22 localhost mountd[25895]: Caught signal 15, un-registering and exiting.
Apr 17 15:55:22 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 15:55:23 localhost kernel: ------------[ cut here ]------------
Apr 17 15:55:23 localhost kernel: WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Apr 17 15:55:23 localhost kernel: Hardware name: Presario M2000 (PT365PA#AB2)      
Apr 17 15:55:23 localhost kernel: list_add corruption. next->prev should be prev (ef8fe958), but was ef8ff128. (next=ef8ff128).
Apr 17 15:55:23 localhost kernel: Modules linked in: fuse i915 drm i2c_algo_bit nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 p4_clockmod dm_multipath uinput snd_intel8x0m snd_intel8x0 snd_seq_dummy snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore 8139cp firewire_ohci firewire_core snd_page_alloc tifm_7xx1 i2c_i801 iTCO_wdt 8139too tifm_core i2c_core yenta_socket crc_itu_t iTCO_vendor_support pcspkr mii rsrc_nonstatic wmi video output ata_generic pata_acpi [last unloaded: microcode]
Apr 17 15:55:23 localhost kernel: Pid: 26230, comm: lockd Tainted: G        W  2.6.30-rc2 #3
Apr 17 15:55:23 localhost kernel: Call Trace:
Apr 17 15:55:23 localhost kernel: [<c042d5b5>] warn_slowpath+0x71/0xa0
Apr 17 15:55:23 localhost kernel: [<c0422a96>] ? update_curr+0x11d/0x125
Apr 17 15:55:23 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 15:55:23 localhost kernel: [<c044b270>] ? trace_hardirqs_on+0xb/0xd
Apr 17 15:55:23 localhost kernel: [<c051c61a>] ? _raw_spin_lock+0x53/0xfa
Apr 17 15:55:23 localhost kernel: [<c051c89f>] __list_add+0x27/0x5c
Apr 17 15:55:23 localhost kernel: [<ef8f6daa>] locks_start_grace+0x22/0x30 [lockd]
Apr 17 15:55:23 localhost kernel: [<ef8f34da>] set_grace_period+0x39/0x53 [lockd]
Apr 17 15:55:23 localhost kernel: [<c06b8921>] ? lock_kernel+0x1c/0x28
Apr 17 15:55:23 localhost kernel: [<ef8f3558>] lockd+0x64/0x164 [lockd]
Apr 17 15:55:23 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 15:55:23 localhost kernel: [<c04227b0>] ? complete+0x34/0x3e
Apr 17 15:55:23 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 15:55:23 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 15:55:23 localhost kernel: [<c043dd42>] kthread+0x45/0x6b
Apr 17 15:55:23 localhost kernel: [<c043dcfd>] ? kthread+0x0/0x6b
Apr 17 15:55:23 localhost kernel: [<c0403c23>] kernel_thread_helper+0x7/0x10
Apr 17 15:55:23 localhost kernel: ---[ end trace fa484bd6d19ade8d ]---
Apr 17 15:55:23 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 15:55:23 localhost kernel: NFSD: starting 90-second grace period
Apr 17 16:54:27 localhost mountd[26242]: Caught signal 15, un-registering and exiting.
Apr 17 16:54:27 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 16:54:28 localhost kernel: ------------[ cut here ]------------
Apr 17 16:54:28 localhost kernel: WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Apr 17 16:54:28 localhost kernel: Hardware name: Presario M2000 (PT365PA#AB2)      
Apr 17 16:54:28 localhost kernel: list_add corruption. next->prev should be prev (ef8fe958), but was ef8ff128. (next=ef8ff128).
Apr 17 16:54:28 localhost kernel: Modules linked in: fuse i915 drm i2c_algo_bit nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 p4_clockmod dm_multipath uinput snd_intel8x0m snd_intel8x0 snd_seq_dummy snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore 8139cp firewire_ohci firewire_core snd_page_alloc tifm_7xx1 i2c_i801 iTCO_wdt 8139too tifm_core i2c_core yenta_socket crc_itu_t iTCO_vendor_support pcspkr mii rsrc_nonstatic wmi video output ata_generic pata_acpi [last unloaded: microcode]
Apr 17 16:54:28 localhost kernel: Pid: 27044, comm: lockd Tainted: G        W  2.6.30-rc2 #3
Apr 17 16:54:28 localhost kernel: Call Trace:
Apr 17 16:54:28 localhost kernel: [<c042d5b5>] warn_slowpath+0x71/0xa0
Apr 17 16:54:28 localhost kernel: [<c0422a96>] ? update_curr+0x11d/0x125
Apr 17 16:54:28 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 16:54:28 localhost kernel: [<c044b270>] ? trace_hardirqs_on+0xb/0xd
Apr 17 16:54:28 localhost kernel: [<c051c61a>] ? _raw_spin_lock+0x53/0xfa
Apr 17 16:54:28 localhost kernel: [<c051c89f>] __list_add+0x27/0x5c
Apr 17 16:54:28 localhost kernel: [<ef8f6daa>] locks_start_grace+0x22/0x30 [lockd]
Apr 17 16:54:28 localhost kernel: [<ef8f34da>] set_grace_period+0x39/0x53 [lockd]
Apr 17 16:54:28 localhost kernel: [<c06b8921>] ? lock_kernel+0x1c/0x28
Apr 17 16:54:28 localhost kernel: [<ef8f3558>] lockd+0x64/0x164 [lockd]
Apr 17 16:54:28 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 16:54:28 localhost kernel: [<c04227b0>] ? complete+0x34/0x3e
Apr 17 16:54:28 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 16:54:28 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 16:54:28 localhost kernel: [<c043dd42>] kthread+0x45/0x6b
Apr 17 16:54:28 localhost kernel: [<c043dcfd>] ? kthread+0x0/0x6b
Apr 17 16:54:28 localhost kernel: [<c0403c23>] kernel_thread_helper+0x7/0x10
Apr 17 16:54:28 localhost kernel: ---[ end trace fa484bd6d19ade8e ]---
Apr 17 16:54:28 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 16:54:28 localhost kernel: NFSD: starting 90-second grace period
Apr 17 16:59:55 localhost mountd[27056]: Caught signal 15, un-registering and exiting.
Apr 17 16:59:55 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 16:59:56 localhost kernel: ------------[ cut here ]------------
Apr 17 16:59:56 localhost kernel: WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Apr 17 16:59:56 localhost kernel: Hardware name: Presario M2000 (PT365PA#AB2)      
Apr 17 16:59:56 localhost kernel: list_add corruption. next->prev should be prev (ef8fe958), but was ef8ff128. (next=ef8ff128).
Apr 17 16:59:56 localhost kernel: Modules linked in: fuse i915 drm i2c_algo_bit nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 p4_clockmod dm_multipath uinput snd_intel8x0m snd_intel8x0 snd_seq_dummy snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore 8139cp firewire_ohci firewire_core snd_page_alloc tifm_7xx1 i2c_i801 iTCO_wdt 8139too tifm_core i2c_core yenta_socket crc_itu_t iTCO_vendor_support pcspkr mii rsrc_nonstatic wmi video output ata_generic pata_acpi [last unloaded: microcode]
Apr 17 16:59:56 localhost kernel: Pid: 27197, comm: lockd Tainted: G        W  2.6.30-rc2 #3
Apr 17 16:59:56 localhost kernel: Call Trace:
Apr 17 16:59:56 localhost kernel: [<c042d5b5>] warn_slowpath+0x71/0xa0
Apr 17 16:59:56 localhost kernel: [<c0422a96>] ? update_curr+0x11d/0x125
Apr 17 16:59:56 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 16:59:56 localhost kernel: [<c044b270>] ? trace_hardirqs_on+0xb/0xd
Apr 17 16:59:56 localhost kernel: [<c051c61a>] ? _raw_spin_lock+0x53/0xfa
Apr 17 16:59:56 localhost kernel: [<c051c89f>] __list_add+0x27/0x5c
Apr 17 16:59:56 localhost kernel: [<ef8f6daa>] locks_start_grace+0x22/0x30 [lockd]
Apr 17 16:59:56 localhost kernel: [<ef8f34da>] set_grace_period+0x39/0x53 [lockd]
Apr 17 16:59:56 localhost kernel: [<c06b8921>] ? lock_kernel+0x1c/0x28
Apr 17 16:59:56 localhost kernel: [<ef8f3558>] lockd+0x64/0x164 [lockd]
Apr 17 16:59:56 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 16:59:56 localhost kernel: [<c04227b0>] ? complete+0x34/0x3e
Apr 17 16:59:56 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 16:59:56 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 16:59:56 localhost kernel: [<c043dd42>] kthread+0x45/0x6b
Apr 17 16:59:56 localhost kernel: [<c043dcfd>] ? kthread+0x0/0x6b
Apr 17 16:59:56 localhost kernel: [<c0403c23>] kernel_thread_helper+0x7/0x10
Apr 17 16:59:56 localhost kernel: ---[ end trace fa484bd6d19ade8f ]---
Apr 17 16:59:56 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 16:59:56 localhost kernel: NFSD: starting 90-second grace period
Apr 17 17:02:50 localhost mountd[27209]: Caught signal 15, un-registering and exiting.
Apr 17 17:02:50 localhost kernel: nfsd: last server has exited, flushing export cache
Apr 17 17:02:51 localhost kernel: ------------[ cut here ]------------
Apr 17 17:02:51 localhost kernel: WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Apr 17 17:02:51 localhost kernel: Hardware name: Presario M2000 (PT365PA#AB2)      
Apr 17 17:02:51 localhost kernel: list_add corruption. next->prev should be prev (ef8fe958), but was ef8ff128. (next=ef8ff128).
Apr 17 17:02:51 localhost kernel: Modules linked in: fuse i915 drm i2c_algo_bit nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 p4_clockmod dm_multipath uinput snd_intel8x0m snd_intel8x0 snd_seq_dummy snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore 8139cp firewire_ohci firewire_core snd_page_alloc tifm_7xx1 i2c_i801 iTCO_wdt 8139too tifm_core i2c_core yenta_socket crc_itu_t iTCO_vendor_support pcspkr mii rsrc_nonstatic wmi video output ata_generic pata_acpi [last unloaded: microcode]
Apr 17 17:02:51 localhost kernel: Pid: 27349, comm: lockd Tainted: G        W  2.6.30-rc2 #3
Apr 17 17:02:51 localhost kernel: Call Trace:
Apr 17 17:02:51 localhost kernel: [<c042d5b5>] warn_slowpath+0x71/0xa0
Apr 17 17:02:51 localhost kernel: [<c0422a96>] ? update_curr+0x11d/0x125
Apr 17 17:02:51 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 17:02:51 localhost kernel: [<c044b270>] ? trace_hardirqs_on+0xb/0xd
Apr 17 17:02:51 localhost kernel: [<c051c61a>] ? _raw_spin_lock+0x53/0xfa
Apr 17 17:02:51 localhost kernel: [<c051c89f>] __list_add+0x27/0x5c
Apr 17 17:02:51 localhost kernel: [<ef8f6daa>] locks_start_grace+0x22/0x30 [lockd]
Apr 17 17:02:51 localhost kernel: [<ef8f34da>] set_grace_period+0x39/0x53 [lockd]
Apr 17 17:02:51 localhost kernel: [<c06b8921>] ? lock_kernel+0x1c/0x28
Apr 17 17:02:51 localhost kernel: [<ef8f3558>] lockd+0x64/0x164 [lockd]
Apr 17 17:02:51 localhost kernel: [<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
Apr 17 17:02:51 localhost kernel: [<c04227b0>] ? complete+0x34/0x3e
Apr 17 17:02:51 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 17:02:51 localhost kernel: [<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
Apr 17 17:02:51 localhost kernel: [<c043dd42>] kthread+0x45/0x6b
Apr 17 17:02:51 localhost kernel: [<c043dcfd>] ? kthread+0x0/0x6b
Apr 17 17:02:51 localhost kernel: [<c0403c23>] kernel_thread_helper+0x7/0x10
Apr 17 17:02:51 localhost kernel: ---[ end trace fa484bd6d19ade90 ]---
Apr 17 17:02:51 localhost kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Apr 17 17:02:51 localhost kernel: NFSD: starting 90-second grace period
Apr 17 17:08:09 localhost mountd[27361]: authenticated mount request from 10.167.141.101:695 for /tmp/nfs3 (/tmp/nfs3)

> --b.
> 
>>> --b.
>>>
>>> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
>>> index abf8388..1a54ae1 100644
>>> --- a/fs/lockd/svc.c
>>> +++ b/fs/lockd/svc.c
>>> @@ -104,6 +104,16 @@ static void set_grace_period(void)
>>>  	schedule_delayed_work(&grace_period_end, grace_period);
>>>  }
>>>  
>>> +static void restart_grace(void)
>>> +{
>>> +	if (nlmsvc_ops) {
>>> +		cancel_delayed_work_sync(&grace_period_end);
>>> +		locks_end_grace(&lockd_manager);
>>> +		nlmsvc_invalidate_all();
>>> +		set_grace_period();
>>> +	}
>>> +}
>>> +
>>>  /*
>>>   * This is the lockd kernel thread
>>>   */
>>> @@ -149,10 +159,7 @@ lockd(void *vrqstp)
>>>  
>>>  		if (signalled()) {
>>>  			flush_signals(current);
>>> -			if (nlmsvc_ops) {
>>> -				nlmsvc_invalidate_all();
>>> -				set_grace_period();
>>> -			}
>>> +			restart_grace();
>>>  			continue;
>>>  		}
>>>  
>>>

