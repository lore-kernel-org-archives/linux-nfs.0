From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: block layout oops
Date: Thu, 30 Sep 2010 10:29:54 +0200
Message-ID: <4CA44A82.7010506@panasas.com>
References: <20100929172552.GA24460@merit.edu>	<4CA3F1CE.2070108@cn.fujitsu.com> <AANLkTikwS_FXEPp=RzkxpSjpPYWtQutJKEcpnvsxZ8=E@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Bian Naimeng <biannm@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:40598 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751873Ab0I3I35 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 04:29:57 -0400
In-Reply-To: <AANLkTikwS_FXEPp=RzkxpSjpPYWtQutJKEcpnvsxZ8=E@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-09-30 09:23, Benny Halevy wrote:
> 2010/9/30 Bian Naimeng <biannm@cn.fujitsu.com>:
>>> I'm getting this when I try to do a block layout mount with benny's new
>>> pnfs-all-latest kernel, 2.6.36-rc6-pnfs:
>>>
>>> BUG: unable to handle kernel NULL pointer dereference at 00000008
>>> IP: [<e0c5f9a3>] nfs4_proc_getdevicelist+0x3c/0x118 [nfs]
>>> *pde = 00000000
>>> Oops: 0000 [#1]
>>> last sysfs file: /sys/module/sunrpc/initstate
>>> Modules linked in: blocklayoutdriver nfs lockd fscache nfs_acl auth_rpcgss sunrpc ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm microcode snd_timer snd i2c_piix4 pcnet32 i2c_core soundcore pcspkr snd_page_alloc mii [last unloaded: speedstep_lib]
>>>
>>> Pid: 1226, comm: mount.nfs4 Not tainted 2.6.36-rc6-pnfs #9 /VirtualBox
>>> EIP: 0060:[<e0c5f9a3>] EFLAGS: 00210246 CPU: 0
>>> EIP is at nfs4_proc_getdevicelist+0x3c/0x118 [nfs]
>>> EAX: 00000000 EBX: e0cb3310 ECX: 00000004 EDX: de9c3c40
>>> ESI: df756000 EDI: de9c3c68 EBP: de9c3c90 ESP: de9c3c30
>>>  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0069
>>> Process mount.nfs4 (pid: 1226, ti=de9c2000 task=df626380 task.ti=de9c2000)
>>> Stack:
>>>  de9c3c40 de9c3c68 debfb300 dec0ee00 00000000 00000000 df756000 e0caec47
>>> <0> c14b830c dea26588 dea26590 de9c3c88 c10a2f7f 00000008 00200246 e0cb3310
>>> <0> c14b8624 de9c3c90 00000000 00000000 00000000 e0cb3310 00000003 de9c3d38
>>> Call Trace:
>>>  [<e0caec47>] ? T.983+0x12/0x14 [blocklayoutdriver]
>>>  [<c10a2f7f>] ? __kmalloc+0xf7/0x103
>>>  [<e0caed2e>] ? bl_initialize_mountpoint+0xe5/0x36b [blocklayoutdriver]
>>>  [<e0c7233e>] ? set_pnfs_layoutdriver+0x146/0x1e2 [nfs]
>>>  [<e0c48ba8>] ? nfs_probe_fsinfo+0x18a/0x2c0 [nfs]
>>>  [<e0c483a6>] ? nfs_init_server_rpcclient+0x25/0xd1 [nfs]
>>>  [<e0c49511>] ? nfs_clone_server+0x11f/0x206 [nfs]
>>>  [<e0c51ca2>] ? nfs4_xdev_get_sb+0x42/0x1cc [nfs]
>>>  [<c10acf0a>] ? vfs_kern_mount+0x9b/0x15d
>>>  [<e0c59871>] ? nfs_follow_mountpoint+0x1df/0x31e [nfs]
>>>  [<c10b3950>] ? do_follow_link+0xcc/0x1ed
>>>  [<c10b3d54>] ? link_path_walk+0x2e3/0x3be
>>>  [<c10b3f18>] ? path_walk+0x52/0xaf
>>>  [<c10b3fe6>] ? vfs_path_lookup+0x71/0xb5
>>>  [<e0c5197f>] ? nfs_follow_remote_path+0x126/0x255 [nfs]
>>>  [<e0c51b9b>] ? nfs4_try_mount+0x61/0x94 [nfs]
>>>  [<e0c52586>] ? nfs4_get_sb+0x22a/0x299 [nfs]
>>>  [<c10acf0a>] ? vfs_kern_mount+0x9b/0x15d
>>>  [<c10ad01b>] ? do_kern_mount+0x38/0xc2
>>>  [<c10be1e9>] ? do_mount+0x5ee/0x634
>>>  [<c10bcd5c>] ? copy_mount_options+0x78/0xd7
>>>  [<c10be295>] ? sys_mount+0x66/0x94
>>>  [<c132425c>] ? syscall_call+0x7/0xb
>>> Code: c0 89 4d ac 8d 7d e8 b9 03 00 00 00 89 55 a8 8d 55 b0 f3 ab 8d 45 d8 89 45 a4 89 55 a0 8b 86 a8 01 00 00 b9 04 00 00 00 8b 7d a4 <8b> 50 08 31 c0 f3 ab 8b 4d a8 8b 7d a0 89 55 dc 89 4d d8 b9 06
>>> EIP: [<e0c5f9a3>] nfs4_proc_getdevicelist+0x3c/0x118 [nfs] SS:ESP 0068:de9c3c30
>>> CR2: 0000000000000008
>>
>>
>>  Is this patch can fix it?
>>
>> ----------------------------------------------------------------------
>> We must specify the layout type before initialize mountpoint, so we should try set
>> pnfs_curr_ld earlier.
>>
>> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
> 
> patch looks good to me.

Applied. Thanks!

> 
> Benny
> 
>>
>> ---
>>  fs/nfs/pnfs.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index a225cd1..72ec712 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -162,6 +162,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
>>                dprintk("%s: Could not grab reference on module\n", __func__);
>>                goto out_no_driver;
>>        }
>> +       server->pnfs_curr_ld = ld_type;
>>        if (ld_type->initialize_mountpoint(server, mntfh)) {
>>                printk(KERN_ERR
>>                       "%s: Error initializing mount point for layout driver %u.\n",
>> @@ -169,7 +170,6 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
>>                module_put(ld_type->owner);
>>                goto out_no_driver;
>>        }
>> -       server->pnfs_curr_ld = ld_type;
>>        dprintk("%s: pNFS module for %u set\n", __func__, id);
>>        return;
>>
>> --
>> 1.7.0.1
>>
>>
>>
>>
>> --
>> Regards
>> Bian Naimeng
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
