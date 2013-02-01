Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234Ab3BAPtE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2013 10:49:04 -0500
Date: Fri, 1 Feb 2013 10:48:54 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 08/16] nfsd: break out hashtable search into separate
 function
Message-ID: <20130201104854.02e4713d@tlielax.poochiereds.net>
In-Reply-To: <20130201102640.6b1898cb@tlielax.poochiereds.net>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
	<1359402082-29195-9-git-send-email-jlayton@redhat.com>
	<20130201131409.GB30668@fieldses.org>
	<20130201102640.6b1898cb@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 Feb 2013 10:26:40 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Fri, 1 Feb 2013 08:14:09 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Jan 28, 2013 at 02:41:14PM -0500, Jeff Layton wrote:
> > > Later, we'll need more than one call site for this, so break it out
> > > into a new function.
> > 
> > I'm applying these first 8 to the for-3.9 branch at:
> > 
> > 	git://linux-nfs.org/~bfields/linux.git for-3.9
> > 
> > --b.
> > 
> 
> Thanks Bruce. I rebased the remaining patches on top of these, and now
> I'm seeing this when I try to test against it. I don't think it's due
> to the DRC patches, but I haven't started tracking it down yet:
> 
> [10607.327785] BUG: unable to handle kernel NULL pointer dereference at           (null)
> [10607.328033] IP: [<ffffffffa0164f95>] qword_add+0x5/0xd0 [sunrpc]
> [10607.328033] PGD 0 
> [10607.328033] Oops: 0000 [#1] SMP 
> [10607.328033] Modules linked in: nfsd(OF) auth_rpcgss nfs_acl lockd sunrpc kvm_amd kvm microcode virtio_balloon virtio_net i2c_piix4 cirrus drm_kms_helper ttm drm virtio_blk i2c_core
> [10607.328033] CPU 0 
> [10607.328033] Pid: 5209, comm: nfsd Tainted: GF          O 3.8.0-0.rc5.git2.1.fc19.x86_64 #1 Bochs Bochs
> [10607.328033] RIP: 0010:[<ffffffffa0164f95>]  [<ffffffffa0164f95>] qword_add+0x5/0xd0 [sunrpc]
> [10607.328033] RSP: 0018:ffff88000307db58  EFLAGS: 00010286
> [10607.328033] RAX: ffff8800644e3a08 RBX: 000000000a5a51ab RCX: 0000000000000000
> [10607.328033] RDX: ffff88004367ee70 RSI: 0000000000000000 RDI: 000000000a5a51ab
> [10607.328033] RBP: ffff88000307db80 R08: 0000000000000000 R09: 0000000000000000
> [10607.328033] R10: ffff8800436c0000 R11: 0000000000000000 R12: ffff8800644bf730
> [10607.328033] R13: 0000000000000000 R14: ffff88000307db98 R15: ffff880002f5dd40
> [10607.328033] FS:  00007fb85bea8740(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
> [10607.328033] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [10607.328033] CR2: 0000000000000000 CR3: 00000000030ba000 CR4: 00000000000006f0
> [10607.328033] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [10607.328033] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [10607.328033] Process nfsd (pid: 5209, threadinfo ffff88000307c000, task ffff8800436c0000)
> [10607.328033] Stack:
> [10607.328033]  ffffffffa01b56de ffff88000307db78 ffff8800644bf730 00000000fffffff5
> [10607.328033]  ffff880005e409d8 ffff88000307dbd0 ffffffffa0166ee7 0000000000000078
> [10607.328033]  00000000510bb440 000000000a5a51ab ffff880005e43138 ffff8800644e3a08
> [10607.328033] Call Trace:
> [10607.328033]  [<ffffffffa01b56de>] ? expkey_request+0x2e/0x90 [nfsd]
> [10607.328033]  [<ffffffffa0166ee7>] cache_check+0xe7/0x350 [sunrpc]
> [10607.328033]  [<ffffffffa01b613e>] exp_find+0x17e/0x350 [nfsd]
> [10607.328033]  [<ffffffffa01b5fc5>] ? exp_find+0x5/0x350 [nfsd]
> [10607.328033]  [<ffffffffa01b76d5>] ? rqst_exp_find+0x5/0x300 [nfsd]
> [10607.328033]  [<ffffffffa01b77ee>] rqst_exp_find+0x11e/0x300 [nfsd]
> [10607.328033]  [<ffffffffa01b76d5>] ? rqst_exp_find+0x5/0x300 [nfsd]
> [10607.328033]  [<ffffffffa01b7a82>] rqst_find_fsidzero_export+0x22/0x30 [nfsd]
> [10607.328033]  [<ffffffffa01b7aaa>] exp_pseudoroot+0x1a/0xb0 [nfsd]
> [10607.328033]  [<ffffffffa01bf565>] nfsd4_putrootfh+0x25/0x30 [nfsd]
> [10607.328033]  [<ffffffffa01c00f3>] nfsd4_proc_compound+0x573/0x790 [nfsd]
> [10607.328033]  [<ffffffffa01abedb>] nfsd_dispatch+0xbb/0x200 [nfsd]
> [10607.328033]  [<ffffffffa015aadd>] svc_process_common+0x46d/0x6e0 [sunrpc]
> [10607.328033]  [<ffffffffa015ae57>] svc_process+0x107/0x170 [sunrpc]
> [10607.328033]  [<ffffffffa01ab28f>] nfsd+0xbf/0x130 [nfsd]
> [10607.328033]  [<ffffffffa01ab1d0>] ? nfsd_destroy+0x220/0x220 [nfsd]
> [10607.328033]  [<ffffffff81090cea>] kthread+0xea/0xf0
> [10607.328033]  [<ffffffff81090c00>] ? insert_kthread_work+0x80/0x80
> [10607.328033]  [<ffffffff816e086c>] ret_from_fork+0x7c/0xb0
> [10607.328033]  [<ffffffff81090c00>] ? insert_kthread_work+0x80/0x80
> [10607.328033] Code: 4c c3 81 e8 9e cd f6 e0 85 c0 0f 85 0d fe ff ff e9 5a ff ff ff 0f 0b 0f 0b 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 00 66 66 66 66 90 <8b> 0e 55 4c 8b 07 48 89 e5 85 c9 78 56 66 0f 1f 44 00 00 48 83 
> [10607.328033] RIP  [<ffffffffa0164f95>] qword_add+0x5/0xd0 [sunrpc]
> [10607.328033]  RSP <ffff88000307db58>
> [10607.328033] CR2: 0000000000000000
> [10607.961841] ---[ end trace b5a4adf462b23e9a ]---
> 
> Does it look familiar at all?
> 

A bisect narrowed it down to this:

[jlayton@salusa linux]$ git bisect bad
517eb5600b455b608fb4cf38e403909a82c76100 is the first bad commit
commit 517eb5600b455b608fb4cf38e403909a82c76100
Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date:   Tue Jan 15 11:09:31 2013 +0300

    SUNRPC: introduce cache_detail->cache_request callback
    
    This callback will allow to simplify upcalls in further patches in this
    series.
    
    Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

:040000 040000 c0474db96110ab75ee7625454f840ccb34c2710b 97f6aeeee53d8125b49d6e0ccabd7ee721c1248e M	fs
:040000 040000 9a0af12174857da2a384c7b290c878233319d347 99aed4dc4cea3fb02eafeb0df565bf5039f01561 M	include
:040000 040000 0e14940767d1ab0d2d5f9e7006cf845246fc224f cb3e8be2d456debb7433120b49caa54f8cb0c751 M	net

...the original oops only triggered when I ran pynfs against the server
after starting it up. At this commit, the machine oopsed when starting
the server:

[  261.469548] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
[  261.470014] IP: [<ffffffffa02067c1>] svc_export_request+0x21/0x70 [nfsd]
[  261.470014] PGD 0 
[  261.470014] Oops: 0000 [#1] SMP 
[  261.470014] Modules linked in: nfsd(OF) auth_rpcgss nfs_acl lockd sunrpc kvm_amd kvm microcode virtio_balloon virtio_net i2c_piix4 cirrus drm_kms_helper ttm drm virtio_blk i2c_core [last unloaded: nfsd]
[  261.470014] CPU 0 
[  261.470014] Pid: 1740, comm: exportfs Tainted: GF          O 3.8.0-0.rc5.git2.1.fc19.x86_64 #1 Bochs Bochs
[  261.470014] RIP: 0010:[<ffffffffa02067c1>]  [<ffffffffa02067c1>] svc_export_request+0x21/0x70 [nfsd]
[  261.470014] RSP: 0018:ffff880036d2be10  EFLAGS: 00010246
[  261.470014] RAX: 0000000000000000 RBX: 0000000000000025 RCX: 0000000000000000
[  261.470014] RDX: 0000000000000025 RSI: 0000000000000000 RDI: 0000000000000025
[  261.470014] RBP: ffff880036d2be28 R08: 0000000000000000 R09: 0000000000000000
[  261.470014] R10: ffff880036bc2150 R11: 0000000000000000 R12: 0000000000000000
[  261.470014] R13: ffff88005c2eb000 R14: 00007fffc97b9180 R15: ffff880036577b58
[  261.470014] FS:  00007fc93ca35740(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[  261.470014] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  261.470014] CR2: 0000000000000018 CR3: 000000005c2ec000 CR4: 00000000000006f0
[  261.470014] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  261.470014] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  261.470014] Process exportfs (pid: 1740, threadinfo ffff880036d2a000, task ffff880036bc2150)
[  261.470014] Stack:
[  261.470014]  0000000000000025 ffff88005c2eb000 ffff880077e66df0 ffff880036d2be58
[  261.470014]  ffffffffa0166207 0000000000000025 00007fffc97b9180 ffff880077e66df0
[  261.470014]  ffffea000170bac0 ffff880036d2be88 ffffffffa016629e ffff880077e66df0
[  261.470014] Call Trace:
[  261.470014]  [<ffffffffa0166207>] cache_do_downcall+0x57/0x70 [sunrpc]
[  261.470014]  [<ffffffffa016629e>] cache_downcall+0x7e/0x100 [sunrpc]
[  261.470014]  [<ffffffffa0166378>] cache_write_procfs+0x58/0x90 [sunrpc]
[  261.470014]  [<ffffffffa0166320>] ? cache_downcall+0x100/0x100 [sunrpc]
[  261.470014]  [<ffffffff8123b0e5>] proc_reg_write+0x75/0xb0
[  261.470014]  [<ffffffff811ccecf>] vfs_write+0x9f/0x170
[  261.470014]  [<ffffffff811cd089>] sys_write+0x49/0xa0
[  261.470014]  [<ffffffff816e0919>] system_call_fastpath+0x16/0x1b
[  261.470014] Code: 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 41 55 49 89 f5 41 54 49 89 cc 53 48 8b 46 28 48 89 d3 48 89 ce 48 89 df <48> 8b 50 18 e8 c6 e7 f5 ff 41 8b 14 24 48 8b 33 49 8d 7d 38 e8 
[  261.470014] RIP  [<ffffffffa02067c1>] svc_export_request+0x21/0x70 [nfsd]
[  261.470014]  RSP <ffff880036d2be10>
[  261.470014] CR2: 0000000000000018
[  261.511932] ---[ end trace 04a5087ac298f72e ]---

I think you may want to have a hard look at that patch...
-- 
Jeff Layton <jlayton@redhat.com>
