From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: list corruption in locks_start_grace with 2.6.28-rc3
Date: Fri, 21 Nov 2008 19:54:00 -0500
Message-ID: <20081122005400.GB28094@fieldses.org>
References: <x498wrokjj8.fsf@segfault.boston.devel.redhat.com> <20081120203735.GB30808@fieldses.org> <x49ej15gktp.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55401 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757871AbYKVAyC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Nov 2008 19:54:02 -0500
In-Reply-To: <x49ej15gktp.fsf-RRHT56Q3PSP4kTEheFKJxxDDeQx5vsVwAInAS/Ez/D0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 21, 2008 at 10:28:18AM -0500, Jeff Moyer wrote:
> "J. Bruce Fields" <bfields@fieldses.org> writes:
> 
> > On Wed, Nov 12, 2008 at 11:15:23AM -0500, Jeff Moyer wrote:
> >> Hi,
> >> 
> >> I'm doing some testing which involves roughly the following:
> >> 
> >> o mount a file system on the server
> >> o start the nfs service
> >> - mount the nfs-exported file system from a client
> >> - perform a dd from the client
> >> - umount the nfs-exported file system from a client
> >> o stop the nfs service
> >> o unmount the file system on the server
> >> 
> >> After several iterations of this, varying the number of nfsd threads
> >> started, I get the attached backtrace.  I've reproduced it twice, now.
> >> 
> >> Let me know if I can be of further help.
> >
> > Apologies for the delay, and thanks for the report.  Does the following
> > help?  (Untested).
> 
> I get a new and different backtrace with this patch applied.  ;)
> I'm testing with 2.6.28-rc5, fyi.

Thanks for the testing....

> 
> static inline void __module_get(struct module *module)
> {
>         if (module) {
>                 BUG_ON(module_refcount(module) == 0);      <------------
>                 local_inc(&module->ref[get_cpu()].count);
>                 put_cpu();
>         }
> }
> 
> Called from net/sunrpc/svcexport.c:svc_recv:687

You meant svc_xprt.c.  OK.

> 
>         } else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
>                 struct svc_xprt *newxpt;
>                 newxpt = xprt->xpt_ops->xpo_accept(xprt);
>                 if (newxpt) {
>                         /*
>                          * We know this module_get will succeed because the
>                          * listener holds a reference too
>                          */

So clearly the assumption stated in the comment is wrong.

I can't see any relationship between this and the previous bug, but
perhaps it was covering this up somehow.

>                         __module_get(newxpt->xpt_class->xcl_owner);

I don't see the problem yet, but I'll look some more....

--b.

> 
> Cheers,
> Jeff
> 
>  ------------[ cut here ]------------
> kernel BUG at include/linux/module.h:394!
> invalid opcode: 0000 [#1] PREEMPT SMP 
> last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:01:04.6/local_cpus
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> CPU 0 
> Modules linked in: nfsd lockd nfs_acl auth_rpcgss exportfs bridge stp bnep rfcomm l2cap bluetooth sunrpc iptable_filter ip_tables ip6table_filter ip6_tables x_tables ipv6 loop dm_round_robin dm_multipath sg sd_mod crc_t10dif ide_cd_mod cdrom bnx2 serio_raw ipmi_si pcspkr qla2xxx ipmi_msghandler scsi_transport_fc button dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod shpchp cciss scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
> Pid: 5733, comm: nfsd Tainted: G        W  2.6.28-rc5 #56
> RIP: 0010:[<ffffffffa03695a5>]  [<ffffffffa03695a5>] svc_recv+0x41f/0x7a1 [sunrpc]
> RSP: 0018:ffff8802148b3e60  EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffffffffa0382600 RCX: 0000000000000000
> RDX: 0000000000007f80 RSI: ffff8802148b3d70 RDI: ffffffffa0382600
> RBP: ffff8802148b3ef0 R08: ffff88021a1f1048 R09: 0000000000000000
> R10: 0000000000000000 R11: ffff8802148b3c30 R12: ffff8802195f9a50
> R13: ffff8802195f8000 R14: ffff88021c5904f0 R15: ffff8802299b45b0
> FS:  0000000000000000(0000) GS:ffffffff80855a00(0000) knlGS:0000000000000000
> CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> CR2: 00007f4d05281000 CR3: 000000021f5cc000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process nfsd (pid: 5733, threadinfo ffff8802148b2000, task ffff8802194c8040)
> Stack:
>  00000000195f8000 0000000000000000 000000000036ee80 ffff88021ed49930
>  ffff8802191eb3d8 ffffffffa0487118 0000000000000000 ffff8802194c8040
>  ffffffff80238e07 0000000000100100 0000000000200200 ffffffff804e2471
> Call Trace:
>  [<ffffffff80238e07>] ? default_wake_function+0x0/0xf
>  [<ffffffff804e2471>] ? __mutex_unlock_slowpath+0x11e/0x127
>  [<ffffffffa045d773>] nfsd+0xed/0x295 [nfsd]
>  [<ffffffffa045d686>] ? nfsd+0x0/0x295 [nfsd]
>  [<ffffffffa045d686>] ? nfsd+0x0/0x295 [nfsd]
>  [<ffffffff802506a8>] kthread+0x49/0x76
>  [<ffffffff8020d1d9>] child_rip+0xa/0x11
>  [<ffffffff8020c6c8>] ? restore_args+0x0/0x30
>  [<ffffffff8025065f>] ? kthread+0x0/0x76
>  [<ffffffff8020d1cf>] ? child_rip+0x0/0x11
> Code: 08 4c 89 f7 ff 50 08 48 85 c0 49 89 c7 0f 84 71 01 00 00 48 8b 00 48 8b 58 08 48 85 db 74 4e 48 89 df e8 17 9b ef df 85 c0 75 04 <0f> 0b eb fe bf 01 00 00 00 e8 9c d6 17 e0 e8 d4 a4 ff df 89 c0 
> RIP  [<ffffffffa03695a5>] svc_recv+0x41f/0x7a1 [sunrpc]
>  RSP <ffff8802148b3e60>
> ---[ end trace 4eaa2a86a8e2da22 ]---
