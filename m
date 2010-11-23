Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:52608 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724Ab0KWJ4j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Nov 2010 04:56:39 -0500
Message-ID: <4CEB8FD4.6060608@panasas.com>
Date: Tue, 23 Nov 2010 11:56:36 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: 2.6.37-rc1 krash
References: <4CE54463.7070805@desy.de> <4CE55B5D.3030509@panasas.com> <4CE65F1A.1080600@desy.de>
In-Reply-To: <4CE65F1A.1080600@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-19 13:27, Tigran Mkrtchyan wrote:
> Hi Benny,
> 
> 
> On 11/18/2010 05:59 PM, Benny Halevy wrote:
>> Hi Tigran, Can you please gdb your nfs.ko module to get the line number of the warning?
>> (gdb) list *(pnfs_destroy_layout+0xd6)
>> I'm not sure what arch you're using but these offsets don't make sense on
>> my x86_64 machine...
> here is the corresponding lines:
> 
>          if (lo) {
>                  pnfs_clear_lseg_list(lo, &tmp_list, &range);
>                  WARN_ON(!list_empty(&nfsi->layout->segs));
>                  WARN_ON(!list_empty(&nfsi->layout->layouts));
>                  WARN_ON(nfsi->layout->refcount != 1);
> 
>                  /* Matched by refcount set to 1 in alloc_init_layout_hdr */
>                  put_layout_hdr_locked(lo);
>          }

and what line in particular? :)

> 
>> By "crashed", you mean these warnings, or is there anything else?
>>
> 
> after that machine was dead and I have to reset it. This messages I got 
> from
> /var/log/messages and they was the last entries before new boot sequence.
> 
> I will do the same exercise with -rc2 next week.

Thanks!

> 
> Regards,
>     Tigran.
> 
>> Benny
>>
>> On 2010-11-18 17:21, Tigran Mkrtchyan wrote:
>>> During dead client recovery procedure you client crashed in did.
>>>
>>> The procedure was: during IO disconnect network cable. We was testing
>>> server cleanup sequence.  Then we have connected  client back. After some
>>> time client reconnected...and crashed. The last thing I have seen was
>>> BAD_SESSION
>>> from the server on READ call:
>>>
>>>
>>>
>>> Nov 18 16:04:29 slinux kernel: [  555.385877] Got error -10052 from the
>>> server on DESTROY_SESSION. Session has been destroyed regardless...
>>> Nov 18 16:04:29 slinux kernel: [  555.395300] ------------[ cut here
>>> ]------------
>>> Nov 18 16:04:29 slinux kernel: [  555.395321] WARNING: at
>>> fs/nfs/pnfs.c:477 pnfs_destroy_layout+0xd6/0x100 [nfs]()
>>> Nov 18 16:04:29 slinux kernel: [  555.395323] Hardware name: VirtualBox
>>> Nov 18 16:04:29 slinux kernel: [  555.395324] Modules linked in:
>>> nfs_layout_nfsv41_files nfs lockd fscache nfs_acl auth_rpcgss sunrpc
>>> ipv6 af_packet binfmt_misc dm_mirror dm_multipath scsi_dh video output
>>> thermal sbs sbshc pci_slot fan container battery lp sg ac option
>>> usb_wwan usbserial thermal_sys button parport_pc tpm_tis tpm serio_raw
>>> tpm_bios parport e1000 i2c_piix4 pata_mpiix dm_region_hash dm_log dm_mod
>>> [last unloaded: mperf]
>>> Nov 18 16:04:29 slinux kernel: [  555.395425] Pid: 2259, comm:
>>> 131.169.40.35-m Not tainted 2.6.37-rc1.pnfs.1 #1
>>> Nov 18 16:04:29 slinux kernel: [  555.395427] Call Trace:
>>> Nov 18 16:04:29 slinux kernel: [  555.395434]  [<ffffffffa024a256>] ?
>>> pnfs_destroy_layout+0xd6/0x100 [nfs]
>>> Nov 18 16:04:29 slinux kernel: [  555.395440]  [<ffffffffa024a256>] ?
>>> pnfs_destroy_layout+0xd6/0x100 [nfs]
>>> Nov 18 16:04:29 slinux kernel: [  555.395444]  [<ffffffff81041fbc>] ?
>>> warn_slowpath_common+0x8c/0xc0
>>> Nov 18 16:04:29 slinux kernel: [  555.395450]  [<ffffffffa024a256>] ?
>>> pnfs_destroy_layout+0xd6/0x100 [nfs]
>>> Nov 18 16:04:29 slinux kernel: [  555.395456]  [<ffffffffa024a302>] ?
>>> pnfs_destroy_all_layouts+0x82/0xc0 [nfs]
>>> Nov 18 16:04:29 slinux kernel: [  555.395462]  [<ffffffffa0242b93>] ?
>>> nfs4_run_state_manager+0x4e3/0x540 [nfs]
>>> Nov 18 16:04:29 slinux kernel: [  555.395469]  [<ffffffffa02426b0>] ?
>>> nfs4_run_state_manager+0x0/0x540 [nfs]
>>> Nov 18 16:04:29 slinux kernel: [  555.395471]  [<ffffffff8105b466>] ?
>>> kthread+0x96/0xa0
>>> Nov 18 16:04:29 slinux kernel: [  555.395474]  [<ffffffff81003a14>] ?
>>> kernel_thread_helper+0x4/0x10
>>> Nov 18 16:04:29 slinux kernel: [  555.395476]  [<ffffffff8105b3d0>] ?
>>> kthread+0x0/0xa0
>>> Nov 18 16:04:29 slinux kernel: [  555.395478]  [<ffffffff81003a10>] ?
>>> kernel_thread_helper+0x0/0x10
>>> Nov 18 16:04:29 slinux kernel: [  555.395479] ---[ end trace
>>> 8f55223a1de06cc6 ]---
>>> Nov 18 16:04:29 slinux kernel: [  555.395480] ------------[ cut here
>>> ]------------
>>> Nov 18 16:04:29 slinux kernel: [  555.395486] WARNING: at
>>> fs/nfs/pnfs.c:478 pnfs_destroy_layout+0xfc/0x100 [nfs]()
>>> Nov 18 16:04:29 slinux kernel: [  555.395487] Hardware name: VirtualBox
>>> Nov 18 16:04:29 slinux kernel: [  555.395488] Modules linked in:
>>> nfs_layout_nfsv41_files nfs lockd fscache nfs_acl auth_rpcgss sunrpc
>>> ipv6 af_packet binfmt_misc dm_mirror dm_multipath scsi_dh video output
>>> thermal sbs sbshc pci_slot fan container battery lp sg ac option
>>> usb_wwan usbserial thermal_sys button parport_pc tpm_tis tpm serio_raw
>>> tpm_bios parport e1000 i2c_piix4 pata_mpiix dm_region_hash dm_log dm_mod
>>> [last unloaded: mperf]
>>> Nov 18 16:04:29 slinux kernel: [  555.395503] Pid: 2259, comm:
>>> 131.169.40.35-m Tainted: G        W   2.6.37-rc1.pnfs.1 #1
>>> Nov 18 16:04:29 slinux kernel: [  555.395504] Call Trace:
>>> Nov 18 16:04:29 slinux kernel: [  555.395510]  [<ffffffffa024a27c>] ?
>>> pnfs_destroy_layout+0xfc/0x100 [nfs]
>>> Nov 18 16:04:29 slinux kernel: [  555.395516]  [<ffffffffa024a27c>] ?
>>> pnfs_destroy_layout+0xfc/0x100 [nfs]
>>> Nov 18 16:04:29 slinux kernel: [  555.395518]  [<ffffffff81041fbc>] ?
>>> warn_slowpath_common+0x8c/0xc0
>>> Nov 18 16:04:29 slinux kernel: [  555.395523]  [<ffffffffa024a27c>] ?
>>> pnfs_destroy_layout+0xfc/0x100 [nfs]
>>> Nov 18 16:04:29 slinux kernel: [  555.395529]  [<ffffffffa024a302>] ?
>>> pnfs_destroy_all_layouts+0x82/0xc0 [nfs]
>>> Nov 18 16:04:29 slinux kernel: [  555.395536]  [<ffffffffa0242b93>] ?
>>> nfs4_run_state_manager+0x4e3/0x540 [nfs]
>>> Nov 18 16:04:29 slinux kernel: [  555.395542]  [<ffffffffa02426b0>] ?
>>> nfs4_run_state_manager+0x0/0x540 [nfs]
>>> Nov 18 16:04:29 slinux kernel: [  555.395544]  [<ffffffff8105b466>] ?
>>> kthread+0x96/0xa0
>>> Nov 18 16:04:29 slinux kernel: [  555.395546]  [<ffffffff81003a14>] ?
>>> kernel_thread_helper+0x4/0x10
>>> Nov 18 16:04:29 slinux kernel: [  555.395548]  [<ffffffff8105b3d0>] ?
>>> kthread+0x0/0xa0
>>> Nov 18 16:04:29 slinux kernel: [  555.395550]  [<ffffffff81003a10>] ?
>>> kernel_thread_helper+0x0/0x10
>>> Nov 18 16:04:29 slinux kernel: [  555.395551] ---[ end trace
>>> 8f55223a1de06cc7 ]---
>>> Nov 18 16:04:29 slinux kernel: [  555.395552] ------------[ cut here
>>> ]------------
>>> Nov 18 16:04:29 slinux kernel: [  555.395558] WARNING: at
>>> fs/nfs/pnfs.c:479 pnfs_destroy_layout+0xe9/0x100 [nfs]()
>>> Nov 18 16:04:29 slinux kernel: [  555.395559] Hardware name: VirtualBox
>>> Nov 18 16:04:29 slinux kernel: [  555.395560] Modules linked in:
>>> nfs_layout_nfsv41_files nfs lockd fscache nfs_acl auth_rpcgss sunrpc
>>> ipv6 af_packet binfmt_misc dm_mirror dm_multipath scsi_dh video output
>>> thermal sbs sbshc pci_slot fan container battery lp sg ac option
>>> usb_wwan usbserial thermal_sys button parport_pc tpm_tis tpm serio_raw
>>> tpm_bios parport e1000 i2c_piix4 pata_mpiix dm_region_hash dm_log dm_mod
>>> [last unloaded: mperf]
>>> Nov 18 16:04:29 slinux kernel: [  555.395575] Pid: 2259, comm:
>>> 131.169.40.35-m Tainted: G        W   2.6.37-rc1.pnfs.1 #1
>>> Nov 18 16:04:29 slinux kernel: [  555.395576] Call Trace:
>>>
>>> this is
>>>
>>> pnfs-all-2.6.37-rc1-2010-11-03 from Banny's tree (git
>>>    6a1df873544d146fcdc493034b170879985909e8) +
>>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blobdiff;f=mm/vmstat.c;h=42eac4d33216b81c307a87016e821051bc86146e;hp=cd2e42be7b68f73dc60f40631f2b9f87708d3b47;hb=ff8b16d7e15a8ba2a6086645614a483e048e3fbf;hpb=81a6cff678ecee7cdc0658285d3150660c07cfce
>>>
>>>
>>>
>>> Regards,
>>>      Tigran.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
