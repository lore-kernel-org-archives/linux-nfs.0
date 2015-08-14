Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:33597 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbbHNU7o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2015 16:59:44 -0400
Received: by igfj19 with SMTP id j19so21154503igf.0
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2015 13:59:44 -0700 (PDT)
Message-ID: <1439585961.82927.6.camel@primarydata.com>
Subject: Global protection fault in netfilter code
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linux Network Devel Mailing List <netdev@vger.kernel.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Fri, 14 Aug 2015 16:59:21 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

When doing NFS stress tests in a VM with a recent kernel (yesterday's
commit 7ddab73346a1 "Merge branch 'fixes' of git
://ftp.arm.linux.org.uk/~rmk/linux-arm"), I've been seeing the
following General Protection Fault code apparently in the nf_conntrack
code:


PID: 358    TASK: ffff88003630cb80  CPU: 0   COMMAND: "kworker/0:1H"
 #0 [ffff88013a603680] die at ffffffff81007608
 #1 [ffff88013a6036b0] do_general_protection at ffffffff8100407a
 #2 [ffff88013a6036e0] general_protection at ffffffff817888c8
    [exception RIP: detach_if_pending+103]
    RIP: ffffffff81101b37  RSP: ffff88013a603798  RFLAGS: 00010086
    RAX: dead000000200200  RBX: ffff8800b9771bd8  RCX: 000000000000000f
    RDX: ffff88013a60e818  RSI: ffff88013a60d980  RDI: 0000000000000046
    RBP: ffff88013a6037b8   R8: 0000000000000000   R9: 0000000000000001
    R10: ffff88013a60d998  R11: 0000000000000001  R12: ffff8800b9771bd8
    R13: ffff88013a60d980  R14: 0000000000000000  R15: 0000000000000001
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
 #3 [ffff88013a6037c0] mod_timer_pending at ffffffff81101fd2
 #4 [ffff88013a603820] __nf_ct_refresh_acct at ffffffffa055891b [nf_conntrack]
 #5 [ffff88013a603850] tcp_packet at ffffffffa056232e [nf_conntrack]
 #6 [ffff88013a603970] nf_conntrack_in at ffffffffa055b70a [nf_conntrack]
 #7 [ffff88013a603a40] ipv4_conntrack_in at ffffffffa0576326 [nf_conntrack_ipv4]
 #8 [ffff88013a603a50] nf_iterate at ffffffff81688dad
 #9 [ffff88013a603aa0] nf_hook_slow at ffffffff81688e42
#10 [ffff88013a603af0] ip_rcv at ffffffff81695ca3
#11 [ffff88013a603b60] __netif_receive_skb_core at ffffffff8164d688
#12 [ffff88013a603c00] __netif_receive_skb at ffffffff8164e108
#13 [ffff88013a603c20] netif_receive_skb_internal at ffffffff8164f7f6
#14 [ffff88013a603c60] napi_gro_complete at ffffffff8164fbf7
#15 [ffff88013a603cb0] dev_gro_receive at ffffffff81650508
#16 [ffff88013a603d20] napi_gro_receive at ffffffff81650a6b
#17 [ffff88013a603d50] e1000_clean_rx_irq at ffffffffa00308db [e1000]
#18 [ffff88013a603e00] e1000_clean at ffffffffa0030f3d [e1000]
#19 [ffff88013a603ec0] net_rx_action at ffffffff8164ffda
#20 [ffff88013a603f40] __do_softirq at ffffffff81087a18
#21 [ffff88013a603fb0] do_softirq_own_stack at ffffffff8178875c
--- <IRQ stack> ---
#22 [ffff880035fabaf0] do_softirq_own_stack at ffffffff8178875c
    [exception RIP: unknown or invalid address]
    RIP: ffff88007d7a6108  RSP: ffff88007d7a60d0  RFLAGS: ffffffffa02827e5
    RAX: ffffffff810868a9  RBX: ffff880035fabb38  RCX: ffff88007d7a6108
    RDX: ffff880136e56a00  RSI: ffff880035fabb78  RDI: ffffffff81786209
    RBP: ffffffff810d662d   R8: ffff880035fabb58   R9: 00000000fffffe00
    R10: 0000000000000046  R11: ffffffff810867e5  R12: 0000000000000046
    R13: ffffffff810ce565  R14: ffff880035fabb18  R15: 0000000000000000
    ORIG_RAX: ffff8800a4408840  CS: ffff880035fabbc8  SS: 0001
WARNING: possibly bogus exception frame
#23 [ffff880035fabbd0] nfs41_wake_and_assign_slot at ffffffffa06c7a9d [nfsv4]
#24 [ffff880035fabbe0] nfs41_sequence_done at ffffffffa069c7c0 [nfsv4]
#25 [ffff880035fabc30] nfs4_sequence_done at ffffffffa069caaf [nfsv4]
#26 [ffff880035fabc40] nfs4_read_done at ffffffffa06a2c0e [nfsv4]
#27 [ffff880035fabc60] nfs_readpage_done at ffffffffa0654736 [nfs]
#28 [ffff880035fabc90] nfs_pgio_result at ffffffffa0653414 [nfs]
#29 [ffff880035fabcc0] rpc_exit_task at ffffffffa027f10c [sunrpc]
#30 [ffff880035fabce0] __rpc_execute at ffffffffa02820dd [sunrpc]
#31 [ffff880035fabd60] rpc_async_schedule at ffffffffa0282725 [sunrpc]
#32 [ffff880035fabd70] process_one_work at ffffffff8109fe89
#33 [ffff880035fabdf0] worker_thread at ffffffff810a04ae
#34 [ffff880035fabe60] kthread at ffffffff810a6aef
#35 [ffff880035fabf50] ret_from_fork at ffffffff81786f5f

I do not see that in vanilla Linux-4.1, so it seems to be a 4.2 cycle
thing.

Is anyone else seeing this, and is it being looked at by the netfilter
folks?

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


