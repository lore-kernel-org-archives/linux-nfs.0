From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfsd oops in 2.6.7-rc1
Date: Thu, 3 Jun 2004 09:32:23 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <16574.25479.184526.524521@cse.unsw.edu.au>
References: <20040602224501.GA14994@core.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S263032AbUFBXcj@vger.kernel.org>
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.205] == wireless-205.wireless.cse.unsw.EDU.AU) (auth-user neilb) (ident-user Debian-exim)
	(for <christian@leber.de>) (for <linux-kernel@vger.kernel.org>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Thu, 3 Jun 2004 09:32:23 +1000
To: Christian Leber <christian@leber.de>
In-Reply-To: message from Christian Leber on Thursday June 3
List-ID: <nfs.lists.sourceforge.net>

On Thursday June 3, christian@leber.de wrote:
> 
> 2.6.7-rc1 on 4x opteron with very low nfs load, after this nfs stopped
> working and didn't unload

opteron oops reports don't seem to be as easy to read as i386, but I
am fairly certain that this is a bug that has since been fixed.
The fix is in rc2-mm1 or probably the latest BK snapshot.

NeilBrown

> 
> 
> Kernel BUG at nfsfh:276
> invalid operand: 0000 [1] SMP
> CPU 0
> Modules linked in: nfsd exportfs nls_iso8859_1 raw iptable_mangle
> iptable_nat ip_conntrack iptable_filter ip_tables ip6table_filter
> ip6_tables joydev st sr_mod floppy autofs usbserial parport_pc lp
> parport thermal processor fan button battery ac ipv6 af_packet mptscsih
> usbcore tg3 mptbase hw_random evdev binfmt_misc dm_mod
> Pid: 14415, comm: nfsd Not tainted 2.6.7-rc1
> RIP: 0010:[<ffffffffa016d76c>] <ffffffffa016d76c>{:nfsd:fh_compose+412}
> RSP: 0018:00000100dcd69d88  EFLAGS: 00010246
> RAX: 0000000000000000 RBX: 00000100df412000 RCX: 00000100db71a000
> RDX: 0000000000000000 RSI: 0000000000000020 RDI: 00000100df412000
> RBP: 00000100b6578db0 R08: 00000100dcd69c98 R09: 0000000000000000
> R10: 00000100dcd69cf8 R11: 0000000000000048 R12: 0000000000800002
> R13: 00000100bac5c168 R14: 00000100db71a000 R15: 00000100b5493990
> FS:  0000002a9588d6e0(0000) GS:ffffffff80566080(0000) knlGS:000000000a1af280
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000f78338 CR3: 0000000000101000 CR4: 00000000000006e0
> Process nfsd (pid: 14415, threadinfo 00000100dcd68000, task
> 00000100dae416b0)
> Stack: 00000100dcd69dd8 00000100b5489978 00000100b5493990 00000100dfc320f8
>        00000100b5493900 00000100db71a000 0000000000000007 0000010001e798ac
>        0000010080ecd400 0000000000000000
> Call Trace:<ffffffffa01716c4>{:nfsd:nfsd_lookup+1060}
> <ffffffff803b80a4>{svc_udp_recvfrom+308}
>        <ffffffffa016d1a4>{:nfsd:nfsd_proc_lookup+132}
> <ffffffffa016b120>{:nfsd:nfsd_dispatch+256}
>        <ffffffff803b6a23>{svc_process+947} <ffffffffa016b450>{:nfsd:nfsd+0}
>        <ffffffffa016b695>{:nfsd:nfsd+581}
> <ffffffff80134f8e>{schedule_tail+14}
>        <ffffffff80111377>{child_rip+8} <ffffffffa016b450>{:nfsd:nfsd+0}
>        <ffffffffa016b450>{:nfsd:nfsd+0} <ffffffff8011136f>{child_rip+0}
> 
> Code: 0f 0b 03 6e 18 a0 ff ff ff ff 14 01 f0 ff 45 00 48 89 ab 88
> RIP <ffffffffa016d76c>{:nfsd:fh_compose+412} RSP <00000100dcd69d88>
> 
> 
> Regards
> Christian Leber
> 
> -- 
>   "Omnis enim res, quae dando non deficit, dum habetur et non datur,
>    nondum habetur, quomodo habenda est."       (Aurelius Augustinus)
>   Translation: <http://gnuhh.org/work/fsf-europe/augustinus.html>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
