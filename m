From: Adrian Bunk <bunk@stusta.de>
Subject: Re: Opps in 2.6.21-rc4 nfsd
Date: Fri, 23 Mar 2007 16:29:13 +0100
Message-ID: <20070323152913.GH752@stusta.de>
References: <2fe399760703221224g40fc44ddof41d1fcd442612d5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
To: Phy Prabab <phyprabab@gmail.com>, neilb@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752022AbXCWP3M@vger.kernel.org>
In-Reply-To: <2fe399760703221224g40fc44ddof41d1fcd442612d5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, Mar 22, 2007 at 12:24:12PM -0700, Phy Prabab wrote:
> Hello,
> 
> I have a recent oopps on a small file server I have running.  The
> machine in question is a dual, dual core AMD Opteron 2.2GHz w/4G RAM,
> 3Ware 9650SE (14 drive RAID 10), using XFS, LVM2 (latest), exported
> via knfsd.  Kernel is 2.6.21-rc4 64b.  Here is the bt:
> 
> Mar 22 12:09:01 rcfs05 kernel: Modules linked in:
> Mar 22 12:09:01 rcfs05 kernel: Pid: 3102, comm: nfsd Not tainted
> 2.6.21-rc4-smp #3
> Mar 22 12:09:01 rcfs05 kernel: RIP: 0010:[<ffffffff80350613>]
> [<ffffffff80350613>] fh_compose+0x3e3/0x4d0
> Mar 22 12:09:01 rcfs05 kernel: RSP: 0018:ffff8101197fdd70  EFLAGS: 00010297
> Mar 22 12:09:01 rcfs05 kernel: RAX: 0000000000000006 RBX:
> 000000000ee00004 RCX: 0000000000000000
> Mar 22 12:09:01 rcfs05 kernel: RDX: 0000000000000018 RSI:
> ffff81011975a940 RDI: 0000000000000080
> Mar 22 12:09:01 rcfs05 kernel: RBP: 0000000000000001 R08:
> 00000000ffffffff R09: 00002ba24f06ca50
> Mar 22 12:09:01 rcfs05 kernel: R10: ffff81011975a808 R11:
> ffffffff8022f500 R12: ffff81011975a938
> Mar 22 12:09:01 rcfs05 kernel: R13: 0000000000000006 R14:
> ffff81010eaab0c0 R15: ffff8100cc714940
> Mar 22 12:09:01 rcfs05 kernel: FS:  00002b020c71b6d0(0000)
> GS:ffff81011dcf56c0(0000) knlGS:0000000000000000
> Mar 22 12:09:01 rcfs05 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 
> 000000008005003b
> Mar 22 12:09:01 rcfs05 kernel: CR2: 0000000000000000 CR3:
> 00000001173d1000 CR4: 00000000000006e0
> Mar 22 12:09:01 rcfs05 kernel: Process nfsd (pid: 3102, threadinfo
> ffff8101197fc000, task ffff81011b7ef020)
> Mar 22 12:09:01 rcfs05 kernel: Stack:  ffff81010fa7b868
> ffffffff80239d8a 0000000000000286 ffff810111aee5e8
> Mar 22 12:09:01 rcfs05 kernel:  ffff810105af2890 ffff81011975a808
> ffff810105af2890 000000000eaab0c0
> Mar 22 12:09:01 rcfs05 kernel:  ffff810105af2890 ffff81011975a808
> ffff810105af2890 000000000000000a
> Mar 22 12:09:01 rcfs05 kernel: Call Trace:
> Mar 22 12:09:01 rcfs05 kernel:  [<ffffffff80239d8a>] 
> __lookup_hash+0x7a/0x160
> Mar 22 12:09:01 rcfs05 kernel:  [<ffffffff803547a5>] nfsd_lookup+0x435/0x4d0
> Mar 22 12:09:01 rcfs05 kernel:  [<ffffffff8035aaa8>]
> nfsd3_proc_lookup+0xe8/0x110
> Mar 22 12:09:01 rcfs05 kernel:  [<ffffffff8034d69d>] 
> nfsd_dispatch+0xfd/0x1f0
> Mar 22 12:09:01 rcfs05 kernel:  [<ffffffff80608094>] svc_process+0x3e4/0x730
> Mar 22 12:09:01 rcfs05 kernel:  [<ffffffff8026bbf2>] __down_read+0x12/0xa2
> Mar 22 12:09:01 rcfs05 kernel:  [<ffffffff8034dd00>] nfsd+0x1a0/0x2d0
> Mar 22 12:09:01 rcfs05 kernel:  [<ffffffff80264f38>] child_rip+0xa/0x12
> Mar 22 12:09:01 rcfs05 kernel:  [<ffffffff8034db60>] nfsd+0x0/0x2d0
> Mar 22 12:09:01 rcfs05 kernel:  [<ffffffff80264f2e>] child_rip+0x0/0x12
> Mar 22 12:09:01 rcfs05 kernel:
> Mar 22 12:09:01 rcfs05 kernel:
> Mar 22 12:09:01 rcfs05 kernel: Code: 48 8b 01 ba 10 00 00 00 bf 10 00
> 00 00 48 89 06 48 8b 41 08
> Mar 22 12:09:01 rcfs05 kernel: RIP  [<ffffffff80350613>] 
> fh_compose+0x3e3/0x4d0
> Mar 22 12:09:01 rcfs05 kernel:  RSP <ffff8101197fdd70>
> Mar 22 12:09:01 rcfs05 kernel: CR2: 0000000000000000
> 
> Once this oops happens, the machine is still usable, however NFS
> crawls to a halt (in fact one of the machines with a mount point of
> this machine, failed to respond anymore - I assume that thread is the
> one that ooops'ed).
> 
> Any more information or debugging, please let me know.


Does it work with kernel 2.6.20?


> TIA!
> Phy

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
