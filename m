Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36185 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934258AbcJVNdM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Oct 2016 09:33:12 -0400
Received: by mail-pf0-f171.google.com with SMTP id e6so72547212pfk.3
        for <linux-nfs@vger.kernel.org>; Sat, 22 Oct 2016 06:33:11 -0700 (PDT)
Date: Sat, 22 Oct 2016 21:32:56 +0800
From: Eryu Guan <guaneryu@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Subject: [4.9-rc1 regression] null pointer dereference triggered by
 generic/013
Message-ID: <20161022133256.GM2462@eguan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I can hit the following null pointer dereference pretty reliably when
testing NFSv4.1 and NFSv4.2, by running xfstests generic/013. NFSv4.0
and v3 seem have no problem. Both NFS server and client are the same
Linux box running 4.9-rc1 kernel.

And I bisected to this commit

commit 68778945e46f143ed7974b427a8065f69a4ce944
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Sep 15 10:55:37 2016 -0400

    SUNRPC: Separate buffer pointers for RPC Call and Reply messages

I did further confirmation. With this commit as HEAD, I can reproduce
the crash quite easily, then I reverted commit and the crash was gone.

Thanks,
Eryu

[   48.049827] FS-Cache: Loaded
[   48.198327] FS-Cache: Netfs 'nfs' registered for caching
[   48.269872] Key type dns_resolver registered
[   48.406405] NFS: Registering the id_resolver key type
[   48.406861] Key type id_resolver registered
[   48.407236] Key type id_legacy registered
[   49.167498] run fstests generic/013 at 2016-10-22 21:21:40
[   74.931485] BUG: unable to handle kernel NULL pointer dereference at           (null)
[   74.932427] IP: [<ffffffff8135ce99>] memcpy_orig+0x29/0x110
[   74.932427] PGD 212ca2067 PUD 212ca3067 PMD 0 
[   74.932427] Oops: 0002 [#1] SMP
[   74.932427] Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache ppdev parport_pc i2c_piix4 sg parport i2c_core virtio_balloon pcspkr acpi_cpufreq nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c sd_mod ata_generic pata_acpi virtio_scsi 8139too ata_piix libata 8139cp mii virtio_pci floppy virtio_ring serio_raw virtio
[   74.940337] CPU: 1 PID: 1540 Comm: nfsd Not tainted 4.9.0-rc1 #39
[   74.940337] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
[   74.940337] task: ffff88020d7ed200 task.stack: ffff880211838000
[   74.940337] RIP: 0010:[<ffffffff8135ce99>]  [<ffffffff8135ce99>] memcpy_orig+0x29/0x110
[   74.940337] RSP: 0018:ffff88021183bdd0  EFLAGS: 00010206
[   74.940337] RAX: 0000000000000000 RBX: ffff88020d7fa000 RCX: 000000f400000000
[   74.940337] RDX: 0000000000000014 RSI: ffff880212927020 RDI: 0000000000000000
[   74.940337] RBP: ffff88021183be30 R08: 01000000ef896996 R09: 0000000000000000
[   74.940337] R10: 0000000000000000 R11: 0000000000000000 R12: ffff880211704ca8
[   74.940337] R13: ffff88021473f000 R14: 00000000ef896996 R15: ffff880211704800
[   74.940337] FS:  0000000000000000(0000) GS:ffff88021fc80000(0000) knlGS:0000000000000000
[   74.940337] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   74.940337] CR2: 0000000000000000 CR3: 0000000212ca1000 CR4: 00000000000006e0
[   74.940337] Stack:
[   74.940337]  ffffffffa01ea087 ffffffff63400001 ffff880215145e00 ffff880211bacd00
[   74.940337]  ffff88021473f2b8 0000000000000004 00000000d0679d67 ffff880211bacd00
[   74.940337]  ffff88020d7fa000 ffff88021473f000 0000000000000000 ffff88020d7faa30
[   74.940337] Call Trace:
[   74.940337]  [<ffffffffa01ea087>] ? svc_tcp_recvfrom+0x5a7/0x790 [sunrpc]
[   74.940337]  [<ffffffffa01f84d8>] svc_recv+0xad8/0xbd0 [sunrpc]
[   74.940337]  [<ffffffffa0262d5e>] nfsd+0xde/0x160 [nfsd]
[   74.940337]  [<ffffffffa0262c80>] ? nfsd_destroy+0x60/0x60 [nfsd]
[   74.940337]  [<ffffffff810a9418>] kthread+0xd8/0xf0
[   74.940337]  [<ffffffff816dbdbf>] ret_from_fork+0x1f/0x40
[   74.940337]  [<ffffffff810a9340>] ? kthread_park+0x60/0x60
[   74.940337] Code: 00 00 48 89 f8 48 83 fa 20 72 7e 40 38 fe 7c 35 48 83 ea 20 48 83 ea 20 4c 8b 06 4c 8b 4e 08 4c 8b 56 10 4c 8b 5e 18 48 8d 76 20 <4c> 89 07 4c 89 4f 08 4c 89 57 10 4c 89 5f 18 48 8d 7f 20 73 d4 
[   74.940337] RIP  [<ffffffff8135ce99>] memcpy_orig+0x29/0x110
[   74.940337]  RSP <ffff88021183bdd0>
[   74.940337] CR2: 0000000000000000
[   74.940337] ---[ end trace 695c5805bd21c5dc ]---
