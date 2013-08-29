Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:36895 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754240Ab3H2QvK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Aug 2013 12:51:10 -0400
Received: by mail-qc0-f182.google.com with SMTP id k18so303607qcv.41
        for <linux-nfs@vger.kernel.org>; Thu, 29 Aug 2013 09:51:09 -0700 (PDT)
Message-ID: <521F7BFB.8020202@gmail.com>
Date: Thu, 29 Aug 2013 12:51:07 -0400
From: Bryan Schumaker <bjschuma@gmail.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>
Subject: Re: [PATCH v2 03/16] SUNRPC: Cleanup rpc_setup_pipedir
References: <1377718821-28159-1-git-send-email-Trond.Myklebust@netapp.com>  <1377718821-28159-2-git-send-email-Trond.Myklebust@netapp.com>  <1377718821-28159-3-git-send-email-Trond.Myklebust@netapp.com>  <521F6BAF.7000504@gmail.com> <1377792920.3202.4.camel@leira.trondhjem.org>
In-Reply-To: <1377792920.3202.4.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/29/2013 12:15 PM, Myklebust, Trond wrote:
> On Thu, 2013-08-29 at 11:41 -0400, Bryan Schumaker wrote:
>> Hi Trond,
>>
>> This patch is causing this bug for me on my testing server:
>>
>> [    6.742695] BUG: unable to handle kernel NULL pointer dereference at           (null)
>> [    6.742791] IP: [<ffffffff812de260>] skip_spaces+0x30/0x30
>> [    6.742848] PGD 1d719067 PUD 1de21067 PMD 0 
>> [    6.742900] Oops: 0000 [#1] PREEMPT SMP 
>> [    6.742949] Modules linked in: nfsd auth_rpcgss oid_registry nfs_acl snd_hda_intel pcspkr snd_hda_codec cirrus syscopyarea snd_hwdep sysfillrect psmouse snd_pcm serio_raw snd_page_alloc sysimgblt evdev snd_timer snd soundcore drm_kms_helper ttm drm i2c_piix4 i2c_core intel_agp intel_gtt button processor nfs lockd sunrpc fscache ata_generic pata_acpi btrfs libcrc32c xor zlib_deflate ata_piix crc32c_intel uhci_hcd libata scsi_mod usbcore usb_common raid6_pq floppy virtio_balloon virtio_net virtio_pci virtio_blk virtio_ring virtio
>> [    6.743339] CPU: 0 PID: 211 Comm: rpc.nfsd Not tainted 3.11.0-rc2-ARCH+ #250
>> [    6.743339] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>> [    6.743339] task: ffff88001bfc5c20 ti: ffff88001dff2000 task.ti: ffff88001dff2000
>> [    6.743339] RIP: 0010:[<ffffffff812de260>]  [<ffffffff812de260>] skip_spaces+0x30/0x30
>> [    6.743339] RSP: 0018:ffff88001dff3bc8  EFLAGS: 00010282
>> [    6.743339] RAX: ffffffffa025cb20 RBX: 0000000000000000 RCX: 0000000000000000
>> [    6.743339] RDX: ffff88001de62838 RSI: 0000000000000000 RDI: 0000000000000000
>> [    6.743339] RBP: ffff88001dff3bf0 R08: 0000000000017360 R09: 0000000000000000
>> [    6.743339] R10: ffff88001e401700 R11: ffff88001dff3fd8 R12: ffff88001df2a000
>> [    6.743339] R13: ffff88001cebca00 R14: 0000000000000000 R15: 0000000000000000
>> [    6.743339] FS:  00007f04a4159700(0000) GS:ffff88001fc00000(0000) knlGS:0000000000000000
>> [    6.743339] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [    6.743339] CR2: 0000000000000000 CR3: 000000001df02000 CR4: 00000000000407f0
>> [    6.743339] Stack:
>> [    6.743339]  ffffffffa0255dbe 0000000000000000 0000000000000000 ffff88001dff3d38
>> [    6.743339]  ffff88001cebca00 ffff88001dff3c38 ffffffffa023a0d9 ffffffff81511052
>> [    6.743339]  ffff88001de62800 00000000b2b4b509 ffff88001dff3d38 ffff88001cebca00
>> [    6.743339] Call Trace:
>> [    6.743339]  [<ffffffffa0255dbe>] ? rpc_d_lookup_sb+0x2e/0x50 [sunrpc]
>> [    6.743339]  [<ffffffffa023a0d9>] rpc_setup_pipedir_sb+0x39/0xf0 [sunrpc]
>> [    6.743339]  [<ffffffff81511052>] ? mutex_lock+0x12/0x30
>> [    6.743339]  [<ffffffffa023c653>] rpc_new_client+0x233/0x450 [sunrpc]
>> [    6.743339]  [<ffffffffa023d3ec>] rpc_create+0xcc/0x250 [sunrpc]
>> [    6.743339]  [<ffffffffa024f1ec>] rpcb_create_local_unix+0x5c/0xe0 [sunrpc]
>> [    6.743339]  [<ffffffffa024ff98>] rpcb_create_local+0x68/0x80 [sunrpc]
>> [    6.743339]  [<ffffffffa0249a3e>] svc_rpcb_setup+0x1e/0x40 [sunrpc]
>> [    6.743339]  [<ffffffffa0249a89>] svc_bind+0x29/0x30 [sunrpc]
>> [    6.743339]  [<ffffffffa0498475>] nfsd_create_serv+0xd5/0x1a0 [nfsd]
>> [    6.743339]  [<ffffffffa049a000>] write_ports+0x2f0/0x350 [nfsd]
>> [    6.743339]  [<ffffffff811335ae>] ? __get_free_pages+0xe/0x50
>> [    6.743339]  [<ffffffff81133606>] ? get_zeroed_page+0x16/0x20
>> [    6.743339]  [<ffffffffa0499d10>] ? write_leasetime+0xa0/0xa0 [nfsd]
>> [    6.743339]  [<ffffffffa0499178>] nfsctl_transaction_write+0x48/0x80 [nfsd]
>> [    6.743339]  [<ffffffff811997cd>] vfs_write+0xbd/0x1e0
>> [    6.743339]  [<ffffffff8119a229>] SyS_write+0x49/0xa0
>> [    6.743339]  [<ffffffff8151b99d>] system_call_fastpath+0x1a/0x1f
>> [    6.743339] Code: 89 f8 48 89 e5 f6 82 00 2a 64 81 20 74 15 0f 1f 44 00 00 48 83 c0 01 0f b6 10 f6 82 00 2a 64 81 20 75 f0 5d c3 66 0f 1f 44 00 00 <80> 3f 00 55 48 89 e5 74 15 48 89 f8 0f 1f 40 00 48 83 c0 01 80 
>> [    6.743339] RIP  [<ffffffff812de260>] skip_spaces+0x30/0x30
>> [    6.743339]  RSP <ffff88001dff3bc8>
>> [    6.743339] CR2: 0000000000000000
>> [    6.750025] ---[ end trace 112065af093b07b3 ]---
> 
> Argh! Thanks for bisecting that... The attached patch should fix it...

It did, thanks!
> 
> 

