Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41732 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752335AbdJaR32 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Oct 2017 13:29:28 -0400
Date: Tue, 31 Oct 2017 13:29:26 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [RFC PATCH 0/2] race of lockd/nfsd inetaddr notifiers with
 pointers change
Message-ID: <20171031172926.aryzmxz6nvsqlg56@tonberry.usersys.redhat.com>
References: <24d4e50e-80f7-1874-6745-511f9e7b5739@virtuozzo.com>
 <8b62ad69-5f12-1bff-5388-151367a1075e@virtuozzo.com>
 <b18dff43-ebf4-f53c-1aab-9b85cb4b8354@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <b18dff43-ebf4-f53c-1aab-9b85cb4b8354@virtuozzo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Oct 2017, Vasily Averin wrote:

> I've reproduced the problem both on RHEL7 and then on last mainline kernel:
> 
> 1) start nfsd on host 
> # service nfs start
> 
> 2) create separate net and mount namespaces:
> # unshare -m -n  ; mount -t nfsd nfsd /proc/fs/nfsd
> 
> 3) execute screen (we need 2 consoles with newly created namespaces)
> 4) on first console:
> # ifconfig lo up
> # while : ; do ip a a  1.2.3.4/32 dev lo ; do ip a d 1.2.3.4/32 dev lo ; done
> 
> 5) on second console:
> # while : ; do echo 1 > /proc/fs/nfsd/threads ; sleep 1 ; echo 0 > /proc/fs/nfsd/threads ; sleep 1 ; done
> 
> Result: crash inside nfsd_inteddr_event(), see attached log.
> 
> Submitted patches have resolved the problem, patched kernel was not crashed after day of testing.

Thanks for that reproducer.  I see the same panic (it seems to
reproduce more quickly with the rpcdebug printk's enabled).  I've been
running the same reproducer with your patches for the past day and
haven't seen the panic.

Tested-by: Scott Mayhew <smayhew@redhat.com>

> 
> NB: during my experiments I've found "list_add double add" in set_grace_period()
> and fixed it by recently submitted "[PATCH] lockd: fix lockd shutdown race with signal"
> 
> Thank you,
> 	Vasily Averin
> 
> On 2017-10-19 18:42, Vasily Averin wrote:
> > cc: Scott Mayhew
> > 
> > Dear Scott,
> > could you please take look at patches?
> > 
> > Let me describe the problem once again:
> > 
> > lockd_inetaddr_event()
> > ...
> >         if (nlmsvc_rqst) {  
> > 		... 
> >                 svc_age_temp_xprts_now(nlmsvc_rqst->rq_server, (struct sockaddr *)&sin);
> >         }
> > 
> > Usually access to  nlmsvc_rqst is protected by nlmsvc_mutex 
> > However lockd_inet[6]addr_event does not take the mutex,
> > therefore nlmsvc_rqst can be changed during execution.
> > 
> > as result "if (nlmsvc_rqst)" can be passed,
> > then another thread frees the memory or zeroes this pointer,
> > and then svc_age_temp_xprts_now crash the host on access to already freed memory.
> > 
> > Moreover on initialization nlmsvc_rqst can be temporally set to ERR_PTR.
> > 
> > NFSD have similar issue.
> > 
> > On 2017-10-17 19:40, Vasily Averin wrote:
> >> lockd and nfsd inet[6]addr notifiers use pointer that can be changed during execution.
> >>
> >> lockd_inet[6]addr_event use nlmsvc_rqst without taken nlmsvc_mutex,
> >> nfsd notifier have similar trouble.
> >>
> >> We got few crashes from OpenVz customers on RHEL6-based kernel,
> >> and I have reproduced the problem locally on this kernel.
> >>
> >> I was unable to reproduce the problem on new kernels,
> >> however seems they are affected.
> >>
> >> We cannot add mutexes into notifiers because inet6addr notifiers should be atomic.
> >>
> >> To fix the problem I use atomic counter and waitqueue:
> >> counter allows notifier to access the pointer,
> >> waitqueue allows to delay stop of service until notifier is in use.
> >>
> >> Patches was not tested because I was unable to reproduce the problem on new kernels. 
> >>
> >> Please review it carefully and let me know if this can be fixed in a better way.
> >>
> >> Vasily Averin (2):
> >>   race of lockd inetaddr notifiers with nlmsvc_rqst change
> >>   race of nfsd inetaddr notifiers with nn->nfsd_serv change
> >>
> >>  fs/lockd/svc.c   | 16 ++++++++++++++--
> >>  fs/nfsd/netns.h  |  3 +++
> >>  fs/nfsd/nfsctl.c |  3 +++
> >>  fs/nfsd/nfssvc.c | 14 +++++++++++---
> >>  4 files changed, 31 insertions(+), 5 deletions(-)
> >>
> 

> [  604.294055] nfsd_inetaddr_event: removed 1.2.3.4
> [  604.294060] nfsd: last server has exited, flushing export cache
> [  604.295922] BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
> [  604.296189] IP: _raw_spin_lock_bh+0x1b/0x30
> [  604.296189] PGD 5a596067 P4D 5a596067 PUD 3052e067 PMD 0 
> [  604.296189] Oops: 0002 [#1] SMP
> [  604.298844] Modules linked in: binfmt_misc nfsd auth_rpcgss nfs_acl lockd(E) grace ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw iptable_security ebtable_filter ebtables ip6table_filter ip6_tables sunrpc joydev ppdev virtio_balloon crct10dif_pclmul crc32_pclmul ghash_clmulni_intel pvpanic parport_pc pcspkr parport i2c_piix4 xfs libcrc32c virtio_console virtio_net virtio_scsi bochs_drm drm_kms_helper crc32c_intel ttm drm serio_raw virtio_pci virtio_ring virtio ata_generic pata_acpi floppy
> [  604.302188] CPU: 6 PID: 4310 Comm: ip Tainted: G            E   4.14.0-rc6+ #2
> [  604.302188] Hardware name: Virtuozzo KVM, BIOS 1.9.1-5.3.2.vz7.7 04/01/2014
> [  604.305117] task: ffff8e9eda512840 task.stack: ffffb1074f288000
> [  604.305166] RIP: 0010:_raw_spin_lock_bh+0x1b/0x30
> [  604.306034] RSP: 0018:ffffb1074f28b950 EFLAGS: 00010246
> [  604.306034] RAX: 0000000000000000 RBX: 0000000000000038 RCX: 0000000000000000
> [  604.307034] RDX: 0000000000000001 RSI: ffffb1074f28b9d0 RDI: 0000000000000010
> [  604.307034] RBP: ffffb1074f28b950 R08: 00000000000190bd R09: 0000000000000000
> [  604.307034] R10: 00000000ff000000 R11: 00000000ffffffff R12: ffffb1074f28b978
> [  604.307034] R13: ffffb1074f28b9d0 R14: ffff8e9eefcd8ae8 R15: 0000000000000000
> [  604.307034] FS:  00007f16f5e720c0(0000) GS:ffff8e9effd80000(0000) knlGS:0000000000000000
> [  604.313236] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  604.313236] CR2: 0000000000000010 CR3: 000000005a695005 CR4: 00000000001606e0
> [  604.313236] Call Trace:
> [  604.313236]  svc_age_temp_xprts_now+0x4b/0x200 [sunrpc]
> [  604.315173]  nfsd_inetaddr_event+0x87/0xb0 [nfsd]
> [  604.315173]  notifier_call_chain+0x4a/0x70
> [  604.315173]  blocking_notifier_call_chain+0x43/0x60
> [  604.315173]  __inet_del_ifa+0x16b/0x2c0
> [  604.315173]  inet_rtm_deladdr+0x129/0x1c0
> [  604.315173]  rtnetlink_rcv_msg+0x1f9/0x280
> [  604.315173]  ? rtnl_calcit.isra.24+0x110/0x110
> [  604.315173]  netlink_rcv_skb+0x91/0x130
> [  604.322850]  rtnetlink_rcv+0x15/0x20
> [  604.322850]  netlink_unicast+0x18e/0x220
> [  604.322850]  netlink_sendmsg+0x2c5/0x3c0
> [  604.325114]  sock_sendmsg+0x38/0x50
> [  604.325150]  ___sys_sendmsg+0x29a/0x2f0
> [  604.325150]  ? lru_cache_add+0x3a/0x80
> [  604.325150]  ? lru_cache_add_active_or_unevictable+0x4c/0xf0
> [  604.325150]  ? __handle_mm_fault+0x9be/0x11a0
> [  604.325150]  ? handle_mm_fault+0xb1/0x200
> [  604.325150]  __sys_sendmsg+0x54/0x90
> [  604.325150]  ? __sys_sendmsg+0x54/0x90
> [  604.325150]  SyS_sendmsg+0x12/0x20
> [  604.325150]  entry_SYSCALL_64_fastpath+0x1a/0xa5
> [  604.325150] RIP: 0033:0x7f16f5579e57
> [  604.331665] RSP: 002b:00007fffa38b4628 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
> [  604.332366] RAX: ffffffffffffffda RBX: 00000000006714c0 RCX: 00007f16f5579e57
> [  604.332920] RDX: 0000000000000000 RSI: 00007fffa38b4670 RDI: 0000000000000003
> [  604.333191] RBP: 00007fffa38bcaf0 R08: 0000000000000001 R09: fefefeff77686d74
> [  604.333191] R10: 0000000000000006 R11: 0000000000000246 R12: 00007fffa38bc800
> [  604.333191] R13: 0000000000000000 R14: 00007fffa38bc7a0 R15: 00007fffa38bc7a8
> [  604.333191] Code: 00 5d c3 31 c0 5d c3 66 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 65 81 05 af 47 76 64 00 02 00 00 48 89 e5 31 c0 ba 01 00 00 00 <f0> 0f b1 17 85 c0 75 02 5d c3 89 c6 e8 d4 ac 84 ff 5d c3 66 90 
> [  604.335102] RIP: _raw_spin_lock_bh+0x1b/0x30 RSP: ffffb1074f28b950
> [  604.335102] CR2: 0000000000000010

