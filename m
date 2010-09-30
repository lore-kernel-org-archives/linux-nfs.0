Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:10569 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753191Ab0I3VkU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 17:40:20 -0400
Message-ID: <4CA503C2.2090607@panasas.com>
Date: Thu, 30 Sep 2010 23:40:18 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: another block layout oops
References: <20100930171325.GA5731@merit.edu>
In-Reply-To: <20100930171325.GA5731@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jim, would you mind retesting with pnfs-all-2.6.36-rc6-2010-09-30?
Not that there's any possible fix there, but a fresh Oops could
help, if you can reproduce it.

Thanks,

Benny

On 2010-09-30 19:13, Jim Rees wrote:
> 2.6.36-rc6-pnfs+ from benny's tree of this morning, block layout mount,
> connectathon general "Large Compile" test fails.  This worked with the
> previous 2.6.36-rc3.
> 
> collect2: ld terminated with signal 9 [Killed]
> 
> BUG: unable to handle kernel NULL pointer dereference at 00000090
> IP: [<e0c2e06e>] nfs4_proc_layoutget+0x4b/0x159 [nfs]
> *pde = 00000000 
> Oops: 0000 [#1] 
> last sysfs file: /sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A03:00/PNP0C0A:00/power_supply/BAT0/energy_full
> Modules linked in: blocklayoutdriver nfs lockd fscache nfs_acl auth_rpcgss sunrpc ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm microcode snd_timer snd pcspkr i2c_piix4 soundcore pcnet32 i2c_core snd_page_alloc mii [last unloaded: speedstep_lib]
> 
> Pid: 1385, comm: ld Not tainted 2.6.36-rc6-pnfs+ #10 /VirtualBox
> EIP: 0060:[<e0c2e06e>] EFLAGS: 00210202 CPU: 0
> EIP is at nfs4_proc_layoutget+0x4b/0x159 [nfs]
> EAX: 00000000 EBX: de471300 ECX: 00000004 EDX: df8631c0
> ESI: ffffd8e8 EDI: df625d84 EBP: df625dac ESP: df625d58
>  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0069
> Process ld (pid: 1385, ti=df624000 task=df8631c0 task.ti=df624000)
> Stack:
>  df625d68 df625d84 de978000 de471334 00000000 de81ad00 df625d84 e0c42414
> <0> de471300 00000000 00000001 e0c4c258 de471300 de471334 00000000 000000c8
> <0> 00000001 00000000 de471300 df625ddc de471318 df625dec e0c3fb7d de978000
> Call Trace:
>  [<e0c3fb7d>] ? pnfs_update_layout+0x24e/0x29d [nfs]
>  [<e0c23d45>] ? nfs_readpage_async+0x109/0x13b [nfs]
>  [<e0c23e75>] ? nfs_readpage+0xfe/0x123 [nfs]
>  [<c107eac0>] ? generic_file_aio_read+0x3e3/0x538
>  [<e0c1a372>] ? nfs_file_read+0x94/0xbe [nfs]
>  [<c10ab3e3>] ? do_sync_read+0x8e/0xc9
>  [<c1146067>] ? fsnotify_perm+0x44/0x50
>  [<c11460c4>] ? security_file_permission+0x27/0x2b
>  [<c10ab4bb>] ? rw_verify_area+0x9d/0xc0
>  [<c10ab355>] ? do_sync_read+0x0/0xc9
>  [<c10aba04>] ? vfs_read+0x82/0xde
>  [<c10abafe>] ? sys_read+0x40/0x62
>  [<c132425c>] ? syscall_call+0x7/0xb
> Code: 00 8b 80 60 01 00 00 89 45 b4 31 c0 f3 ab 8d 43 34 89 45 b8 8d 45 d8 89 45 b0 8d 45 bc 89 45 ac 8b 43 24 b9 04 00 00 00 8b 7d b0 <8b> 80 90 00 00 00 8b 90 60 01 00 00 31 c0 f3 ab 8b 45 b8 8b 7d 
> EIP: [<e0c2e06e>] nfs4_proc_layoutget+0x4b/0x159 [nfs] SS:ESP 0068:df625d58
> CR2: 0000000000000090
> ---[ end trace 5333af79b6361d78 ]---
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
