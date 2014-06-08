Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:56958 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022AbaFHBvM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 21:51:12 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so7205430qgf.21
        for <linux-nfs@vger.kernel.org>; Sat, 07 Jun 2014 18:51:12 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sat, 7 Jun 2014 21:51:09 -0400
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: WARN_ON_ONCE pop with tip of your nfsd-next branch
Message-ID: <20140607215109.3cb5e368@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

Just a heads up...

Was doing some testing with a pile of patches (mostly v4 state-related)
on top of your nfsd-next branch, and saw this pop:

[  111.066217] ------------[ cut here ]------------
[  111.067223] WARNING: CPU: 0 PID: 588 at fs/nfsd/nfs4xdr.c:3941 nfs4svc_encode_compoundres+0x9a/0xb0 [nfsd]()
[  111.070074] Modules linked in: rpcsec_gss_krb5 snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ppdev joydev snd_timer microcode serio_raw snd virtio_console virtio_balloon virtio_net pcspkr soundcore parport_pc parport pvpanic nfsd(OE) i2c_piix4 auth_rpcgss nfs_acl lockd sunrpc qxl drm_kms_helper ttm virtio_blk drm virtio_pci virtio_ring i2c_core virtio ata_generic pata_acpi floppy
[  111.081001] CPU: 0 PID: 588 Comm: nfsd Tainted: G           OE 3.15.0-rc1.jlayton.1+ #2
[  111.083615] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  111.084924]  0000000000000000 00000000051421a7 ffff8800d6c3dcf0 ffffffff817d318e
[  111.086613]  0000000000000000 ffff8800d6c3dd28 ffffffff810958bd ffff88003602d000
[  111.088308]  ffff8800d8880000 ffff880118fb4018 ffff880118fb4000 000000000000001c
[  111.089978] Call Trace:
[  111.090552]  [<ffffffff817d318e>] dump_stack+0x4d/0x66
[  111.091652]  [<ffffffff810958bd>] warn_slowpath_common+0x7d/0xa0
[  111.092927]  [<ffffffff810959ea>] warn_slowpath_null+0x1a/0x20
[  111.094189]  [<ffffffffa018d91a>] nfs4svc_encode_compoundres+0x9a/0xb0 [nfsd]
[  111.095565]  [<ffffffffa016cf5f>] nfsd_dispatch+0x14f/0x200 [nfsd]
[  111.096915]  [<ffffffffa00f2bd0>] svc_process_common+0x480/0x6f0 [sunrpc]
[  111.098228]  [<ffffffffa00f2f47>] svc_process+0x107/0x170 [sunrpc]
[  111.099898]  [<ffffffffa016c253>] nfsd+0xd3/0x160 [nfsd]
[  111.100971]  [<ffffffffa016c180>] ? nfsd_destroy+0x210/0x210 [nfsd]
[  111.102219]  [<ffffffff810c260f>] kthread+0xff/0x120
[  111.103185]  [<ffffffff810c2510>] ? insert_kthread_work+0x80/0x80
[  111.104345]  [<ffffffff817e6bfc>] ret_from_fork+0x7c/0xb0
[  111.105376]  [<ffffffff810c2510>] ? insert_kthread_work+0x80/0x80
[  111.106476] ---[ end trace 48ac61da47c8e691 ]---

It's possible that it's due to something I broke, but seems more likely
to be something in your XDR overhaul.

-- 
Jeff Layton <jlayton@primarydata.com>
