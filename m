Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36186 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1732813AbeISXJ0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Sep 2018 19:09:26 -0400
Received: by mail-it0-f66.google.com with SMTP id u13-v6so8802677iti.1
        for <linux-nfs@vger.kernel.org>; Wed, 19 Sep 2018 10:30:30 -0700 (PDT)
Message-ID: <159056b120aa0202aa87920c18f73cc016cafcee.camel@gmail.com>
Subject: Re: [PATCH v3 15/44] SUNRPC: Refactor xprt_transmit() to remove the
 reply queue code
From: Anna Schumaker <schumaker.anna@gmail.com>
To: Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 19 Sep 2018 13:30:27 -0400
In-Reply-To: <40dfd3e0a0ca056150d7ca8c23a3197abb73df67.camel@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
         <20180917130335.112832-2-trond.myklebust@hammerspace.com>
         <20180917130335.112832-3-trond.myklebust@hammerspace.com>
         <20180917130335.112832-4-trond.myklebust@hammerspace.com>
         <20180917130335.112832-5-trond.myklebust@hammerspace.com>
         <20180917130335.112832-6-trond.myklebust@hammerspace.com>
         <20180917130335.112832-7-trond.myklebust@hammerspace.com>
         <20180917130335.112832-8-trond.myklebust@hammerspace.com>
         <20180917130335.112832-9-trond.myklebust@hammerspace.com>
         <20180917130335.112832-10-trond.myklebust@hammerspace.com>
         <20180917130335.112832-11-trond.myklebust@hammerspace.com>
         <20180917130335.112832-12-trond.myklebust@hammerspace.com>
         <20180917130335.112832-13-trond.myklebust@hammerspace.com>
         <20180917130335.112832-14-trond.myklebust@hammerspace.com>
         <20180917130335.112832-15-trond.myklebust@hammerspace.com>
         <20180917130335.112832-16-trond.myklebust@hammerspace.com>
         <3df56a33b30660b7e4492c0c1b01c6b5b729b4fb.camel@gmail.com>
         <40dfd3e0a0ca056150d7ca8c23a3197abb73df67.camel@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-09-19 at 15:48 +0000, Trond Myklebust wrote:
> On Tue, 2018-09-18 at 17:01 -0400, Anna Schumaker wrote:
> > Hi Trond,
> > 
> > I'm seeing this crash while running cthon tests (on any NFS version)
> > after
> > applying this patch:
> > 
> > [   50.780104] general protection fault: 0000 [#1] PREEMPT SMP PTI
> > [   50.780796] CPU: 0 PID: 384 Comm: kworker/u5:1 Not tainted 4.19.0-
> > rc4-ANNA+
> > #7455
> > [   50.781601] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [   50.782232] Workqueue: xprtiod xs_tcp_data_receive_workfn [sunrpc]
> > [   50.782911] RIP: 0010:xprt_lookup_rqst+0x2c/0x150 [sunrpc]
> > [   50.783510] Code: 48 8d 97 58 04 00 00 41 54 49 89 fc 55 89 f5 53
> > 48 8b 87 58
> > 04 00 00 48 39 c2 74 26 48 8d 98 48 ff ff ff 3b 70 e0 75 07 eb 3f
> > <39> 68 e0 74
> > 3a 48 8b 83 b8 00 00 00 48 8d 98 48 ff ff ff 48 39 c2
> > [   50.785501] RSP: 0018:ffffc90000bebd60 EFLAGS: 00010202
> > [   50.786090] RAX: dead000000000100 RBX: dead000000000048 RCX:
> > 0000000000000051
> > [   50.786853] RDX: ffff8800b915dc58 RSI: 000000005a1c5631 RDI:
> > ffff8800b915d800
> > [   50.787616] RBP: 000000005a1c5631 R08: 0000000000000000 R09:
> > 00646f6974727078
> > [   50.788380] R10: 8080808080808080 R11: 00000000000ee5f3 R12:
> > ffff8800b915d800
> > [   50.789153] R13: ffff8800b915dc18 R14: ffff8800b915d800 R15:
> > ffffffffa03265b4
> > [   50.789930] FS:  0000000000000000(0000) GS:ffff8800bca00000(0000)
> > knlGS:0000000000000000
> > [   50.790797] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [   50.791416] CR2: 00007f9b670538b0 CR3: 000000000200a001 CR4:
> > 00000000001606f0
> > [   50.792182] Call Trace:
> > [   50.792471]  xs_tcp_data_recv+0x3a6/0x780 [sunrpc]
> > [   50.792993]  ? __switch_to_asm+0x34/0x70
> > [   50.793426]  ? xs_tcp_check_fraghdr.part.1+0x40/0x40 [sunrpc]
> > [   50.794047]  tcp_read_sock+0x93/0x1b0
> > [   50.794447]  ? __switch_to_asm+0x40/0x70
> > [   50.794879]  xs_tcp_data_receive_workfn+0xb2/0x190 [sunrpc]
> > [   50.795482]  process_one_work+0x1e6/0x3c0
> > [   50.795928]  worker_thread+0x28/0x3c0
> > [   50.796337]  ? process_one_work+0x3c0/0x3c0
> > [   50.796814]  kthread+0x10d/0x130
> > [   50.797170]  ? kthread_park+0x80/0x80
> > [   50.797570]  ret_from_fork+0x35/0x40
> > [   50.797961] Modules linked in: nfsv3 rpcsec_gss_krb5 nfsv4 nfs
> > fscache
> > cfg80211 rpcrdma rfkill crct10dif_pclmul crc32_pclmul crc32c_intel
> > ghash_clmulni_intel joydev pcbc mousedev aesni_intel psmouse
> > aes_x86_64 evdev
> > crypto_simd cryptd input_leds glue_helper led_class mac_hid pcspkr
> > intel_agp
> > intel_gtt i2c_piix4 nfsd button auth_rpcgss nfs_acl lockd grace
> > sunrpc
> > sch_fq_codel ip_tables x_tables ata_generic pata_acpi ata_piix
> > serio_raw
> > uhci_hcd atkbd ehci_pci libps2 ehci_hcd libata usbcore usb_common
> > i8042 floppy
> > serio scsi_mod xfs virtio_balloon virtio_net net_failover failover
> > virtio_pci
> > virtio_blk virtio_ring virtio
> > 
> 
> Thanks for finding that! It looks like the definition of
> xprt_request_need_enqueue_receive() was incorrect so I've pushed out a
> fixed version to the 'testing' branch.

The new version works for me, thanks!

Anna

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
> 
> 
