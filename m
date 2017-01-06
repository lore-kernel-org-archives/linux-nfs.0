Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58922 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965060AbdAFVqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Jan 2017 16:46:55 -0500
Date: Fri, 6 Jan 2017 16:46:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: jlayton@poochiereds.net, davej@codemonkey.org.uk,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] nfsd/lockd notifier block fixes
Message-ID: <20170106214654.GE31401@fieldses.org>
References: <1483652091-25508-1-git-send-email-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1483652091-25508-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks.  I'm assuming the third at least should also get a stable cc
with Fixes: c3d4879e01be.

What about the first two?  I'm not clear what the actual consequences
are.  If it's that some local listeners might not get shut down, that
sounds like a lower priority.

--b.

On Thu, Jan 05, 2017 at 04:34:48PM -0500, Scott Mayhew wrote:
> These patches fix some issues with the notifier blocks used by nfsd and
> lockd.  The first two patches initialize the scope id for link local
> addresses (this is needed because rpc_cmp_addr6 looks at it when
> comparing link local addresses).  The third patch fixes the illegal
> context switch warnings such as the following:
> 
> 
> Jan 04 16:27:20 fedora25 kernel: ===============================
> Jan 04 16:27:20 fedora25 kernel: [ INFO: suspicious RCU usage. ]
> Jan 04 16:27:20 fedora25 kernel: 4.10.0-rc2+ #9 Not tainted
> Jan 04 16:27:20 fedora25 kernel: -------------------------------
> Jan 04 16:27:20 fedora25 kernel: ./include/linux/rcupdate.h:557 Illegal context switch in RCU read-side critical section!
> Jan 04 16:27:20 fedora25 kernel: 
>                                  other info that might help us debug this:
> Jan 04 16:27:20 fedora25 kernel: 
>                                  rcu_scheduler_active = 1, debug_locks = 1
> Jan 04 16:27:20 fedora25 kernel: 2 locks held by ip/1281:
> Jan 04 16:27:20 fedora25 kernel:  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff977abd6b>] rtnetlink_rcv+0x1b/0x40
> Jan 04 16:27:20 fedora25 kernel:  #1:  (rcu_read_lock){......}, at: [<ffffffff970d76c5>] atomic_notifier_call_chain+0x5/0x100
> Jan 04 16:27:20 fedora25 kernel: 
>                                  stack backtrace:
> Jan 04 16:27:20 fedora25 kernel: CPU: 3 PID: 1281 Comm: ip Not tainted 4.10.0-rc2+ #9
> Jan 04 16:27:20 fedora25 kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.1-1.fc24 04/01/2014
> Jan 04 16:27:20 fedora25 kernel: Call Trace:
> Jan 04 16:27:20 fedora25 kernel:  dump_stack+0x86/0xc3
> Jan 04 16:27:20 fedora25 kernel:  lockdep_rcu_suspicious+0xc5/0x100
> Jan 04 16:27:20 fedora25 kernel:  __schedule+0x4a8/0xab0
> Jan 04 16:27:20 fedora25 kernel:  ? irq_work_queue+0x8d/0xa0
> Jan 04 16:27:20 fedora25 kernel:  _cond_resched+0x2b/0x40
> Jan 04 16:27:20 fedora25 kernel:  lock_sock_nested+0x24/0xa0
> Jan 04 16:27:20 fedora25 kernel:  sock_setsockopt+0x8b/0xac0
> Jan 04 16:27:20 fedora25 kernel:  ? __local_bh_enable_ip+0x70/0xc0
> Jan 04 16:27:20 fedora25 kernel:  kernel_setsockopt+0x49/0x50
> Jan 04 16:27:20 fedora25 kernel:  svc_tcp_kill_temp_xprt+0x4a/0x60 [sunrpc]
> Jan 04 16:27:20 fedora25 kernel:  svc_age_temp_xprts_now+0x186/0x210 [sunrpc]
> Jan 04 16:27:20 fedora25 kernel:  nfsd_inet6addr_event+0x1a5/0x200 [nfsd]
> Jan 04 16:27:20 fedora25 kernel:  ? nfsd_inet6addr_event+0x5/0x200 [nfsd]
> Jan 04 16:27:20 fedora25 kernel:  notifier_call_chain+0x4a/0x70
> Jan 04 16:27:20 fedora25 kernel:  atomic_notifier_call_chain+0x67/0x100
> Jan 04 16:27:20 fedora25 kernel:  ? atomic_notifier_call_chain+0x5/0x100
> Jan 04 16:27:20 fedora25 kernel:  inet6addr_notifier_call_chain+0x1b/0x20
> Jan 04 16:27:20 fedora25 kernel:  ipv6_del_addr+0x145/0x250
> Jan 04 16:27:20 fedora25 kernel:  inet6_addr_del+0xf1/0x1b0
> Jan 04 16:27:20 fedora25 kernel:  inet6_rtm_deladdr+0xa9/0xc0
> Jan 04 16:27:20 fedora25 kernel:  rtnetlink_rcv_msg+0xe6/0x210
> Jan 04 16:27:20 fedora25 kernel:  ? debug_lockdep_rcu_enabled+0x1d/0x20
> Jan 04 16:27:20 fedora25 kernel:  ? rtnl_newlink+0x860/0x860
> Jan 04 16:27:20 fedora25 kernel:  netlink_rcv_skb+0xa4/0xc0
> Jan 04 16:27:20 fedora25 kernel:  rtnetlink_rcv+0x2a/0x40
> Jan 04 16:27:20 fedora25 kernel:  netlink_unicast+0x1e5/0x2e0
> Jan 04 16:27:20 fedora25 kernel:  ? netlink_unicast+0x16f/0x2e0
> Jan 04 16:27:20 fedora25 kernel:  netlink_sendmsg+0x2fe/0x3b0
> Jan 04 16:27:20 fedora25 kernel:  sock_sendmsg+0x38/0x50
> Jan 04 16:27:20 fedora25 kernel:  ___sys_sendmsg+0x2e0/0x2f0
> Jan 04 16:27:20 fedora25 kernel:  ? trace_hardirqs_on_caller+0xf5/0x1b0
> Jan 04 16:27:20 fedora25 kernel:  ? _raw_spin_unlock+0x27/0x30
> Jan 04 16:27:20 fedora25 kernel:  ? handle_mm_fault+0x6b5/0x15f0
> Jan 04 16:27:20 fedora25 kernel:  ? handle_mm_fault+0x4f/0x15f0
> Jan 04 16:27:20 fedora25 kernel:  ? debug_lockdep_rcu_enabled+0x1d/0x20
> Jan 04 16:27:20 fedora25 kernel:  __sys_sendmsg+0x54/0x90
> Jan 04 16:27:20 fedora25 kernel:  SyS_sendmsg+0x12/0x20
> Jan 04 16:27:20 fedora25 kernel:  entry_SYSCALL_64_fastpath+0x1f/0xc2
> Jan 04 16:27:20 fedora25 kernel: RIP: 0033:0x7f8fd55e6037
> Jan 04 16:27:20 fedora25 kernel: RSP: 002b:00007ffc7f1a7558 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
> Jan 04 16:27:20 fedora25 kernel: RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f8fd55e6037
> Jan 04 16:27:20 fedora25 kernel: RDX: 0000000000000000 RSI: 00007ffc7f1a75a0 RDI: 0000000000000003
> Jan 04 16:27:20 fedora25 kernel: RBP: 00007ffc7f1a75a0 R08: 0000000000000400 R09: fefefeff77686d74
> Jan 04 16:27:20 fedora25 kernel: R10: 00000000000005eb R11: 0000000000000246 R12: 0000000000000000
> Jan 04 16:27:20 fedora25 kernel: R13: 000000000065d3a0 R14: 00007ffc7f1af6e0 R15: 00007ffc7f1af6e8
> 
> 
> Scott Mayhew (3):
>   nfsd: initialize sin6_scope_id in nfsd_inet6addr_event()
>   lockd: initialize sin6_scope_id in lockd_inet6addr_event()
>   sunrpc: don't call sleeping functions from the notifier block
>     callbacks
> 
>  fs/lockd/svc.c                  |  2 ++
>  fs/nfsd/nfssvc.c                |  2 ++
>  include/linux/sunrpc/svc_xprt.h |  1 +
>  net/sunrpc/svc_xprt.c           | 10 +++++++---
>  4 files changed, 12 insertions(+), 3 deletions(-)
> 
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
