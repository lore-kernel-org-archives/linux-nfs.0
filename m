Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755473Ab3BAP0r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2013 10:26:47 -0500
Date: Fri, 1 Feb 2013 10:26:40 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 08/16] nfsd: break out hashtable search into separate
 function
Message-ID: <20130201102640.6b1898cb@tlielax.poochiereds.net>
In-Reply-To: <20130201131409.GB30668@fieldses.org>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
	<1359402082-29195-9-git-send-email-jlayton@redhat.com>
	<20130201131409.GB30668@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 Feb 2013 08:14:09 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jan 28, 2013 at 02:41:14PM -0500, Jeff Layton wrote:
> > Later, we'll need more than one call site for this, so break it out
> > into a new function.
> 
> I'm applying these first 8 to the for-3.9 branch at:
> 
> 	git://linux-nfs.org/~bfields/linux.git for-3.9
> 
> --b.
> 

Thanks Bruce. I rebased the remaining patches on top of these, and now
I'm seeing this when I try to test against it. I don't think it's due
to the DRC patches, but I haven't started tracking it down yet:

[10607.327785] BUG: unable to handle kernel NULL pointer dereference at           (null)
[10607.328033] IP: [<ffffffffa0164f95>] qword_add+0x5/0xd0 [sunrpc]
[10607.328033] PGD 0 
[10607.328033] Oops: 0000 [#1] SMP 
[10607.328033] Modules linked in: nfsd(OF) auth_rpcgss nfs_acl lockd sunrpc kvm_amd kvm microcode virtio_balloon virtio_net i2c_piix4 cirrus drm_kms_helper ttm drm virtio_blk i2c_core
[10607.328033] CPU 0 
[10607.328033] Pid: 5209, comm: nfsd Tainted: GF          O 3.8.0-0.rc5.git2.1.fc19.x86_64 #1 Bochs Bochs
[10607.328033] RIP: 0010:[<ffffffffa0164f95>]  [<ffffffffa0164f95>] qword_add+0x5/0xd0 [sunrpc]
[10607.328033] RSP: 0018:ffff88000307db58  EFLAGS: 00010286
[10607.328033] RAX: ffff8800644e3a08 RBX: 000000000a5a51ab RCX: 0000000000000000
[10607.328033] RDX: ffff88004367ee70 RSI: 0000000000000000 RDI: 000000000a5a51ab
[10607.328033] RBP: ffff88000307db80 R08: 0000000000000000 R09: 0000000000000000
[10607.328033] R10: ffff8800436c0000 R11: 0000000000000000 R12: ffff8800644bf730
[10607.328033] R13: 0000000000000000 R14: ffff88000307db98 R15: ffff880002f5dd40
[10607.328033] FS:  00007fb85bea8740(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[10607.328033] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[10607.328033] CR2: 0000000000000000 CR3: 00000000030ba000 CR4: 00000000000006f0
[10607.328033] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[10607.328033] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[10607.328033] Process nfsd (pid: 5209, threadinfo ffff88000307c000, task ffff8800436c0000)
[10607.328033] Stack:
[10607.328033]  ffffffffa01b56de ffff88000307db78 ffff8800644bf730 00000000fffffff5
[10607.328033]  ffff880005e409d8 ffff88000307dbd0 ffffffffa0166ee7 0000000000000078
[10607.328033]  00000000510bb440 000000000a5a51ab ffff880005e43138 ffff8800644e3a08
[10607.328033] Call Trace:
[10607.328033]  [<ffffffffa01b56de>] ? expkey_request+0x2e/0x90 [nfsd]
[10607.328033]  [<ffffffffa0166ee7>] cache_check+0xe7/0x350 [sunrpc]
[10607.328033]  [<ffffffffa01b613e>] exp_find+0x17e/0x350 [nfsd]
[10607.328033]  [<ffffffffa01b5fc5>] ? exp_find+0x5/0x350 [nfsd]
[10607.328033]  [<ffffffffa01b76d5>] ? rqst_exp_find+0x5/0x300 [nfsd]
[10607.328033]  [<ffffffffa01b77ee>] rqst_exp_find+0x11e/0x300 [nfsd]
[10607.328033]  [<ffffffffa01b76d5>] ? rqst_exp_find+0x5/0x300 [nfsd]
[10607.328033]  [<ffffffffa01b7a82>] rqst_find_fsidzero_export+0x22/0x30 [nfsd]
[10607.328033]  [<ffffffffa01b7aaa>] exp_pseudoroot+0x1a/0xb0 [nfsd]
[10607.328033]  [<ffffffffa01bf565>] nfsd4_putrootfh+0x25/0x30 [nfsd]
[10607.328033]  [<ffffffffa01c00f3>] nfsd4_proc_compound+0x573/0x790 [nfsd]
[10607.328033]  [<ffffffffa01abedb>] nfsd_dispatch+0xbb/0x200 [nfsd]
[10607.328033]  [<ffffffffa015aadd>] svc_process_common+0x46d/0x6e0 [sunrpc]
[10607.328033]  [<ffffffffa015ae57>] svc_process+0x107/0x170 [sunrpc]
[10607.328033]  [<ffffffffa01ab28f>] nfsd+0xbf/0x130 [nfsd]
[10607.328033]  [<ffffffffa01ab1d0>] ? nfsd_destroy+0x220/0x220 [nfsd]
[10607.328033]  [<ffffffff81090cea>] kthread+0xea/0xf0
[10607.328033]  [<ffffffff81090c00>] ? insert_kthread_work+0x80/0x80
[10607.328033]  [<ffffffff816e086c>] ret_from_fork+0x7c/0xb0
[10607.328033]  [<ffffffff81090c00>] ? insert_kthread_work+0x80/0x80
[10607.328033] Code: 4c c3 81 e8 9e cd f6 e0 85 c0 0f 85 0d fe ff ff e9 5a ff ff ff 0f 0b 0f 0b 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 00 66 66 66 66 90 <8b> 0e 55 4c 8b 07 48 89 e5 85 c9 78 56 66 0f 1f 44 00 00 48 83 
[10607.328033] RIP  [<ffffffffa0164f95>] qword_add+0x5/0xd0 [sunrpc]
[10607.328033]  RSP <ffff88000307db58>
[10607.328033] CR2: 0000000000000000
[10607.961841] ---[ end trace b5a4adf462b23e9a ]---

Does it look familiar at all?

-- 
Jeff Layton <jlayton@redhat.com>
