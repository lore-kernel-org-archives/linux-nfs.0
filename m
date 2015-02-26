Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753554AbbBZKpZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2015 05:45:25 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1411654543.3044.24.camel@leira.trondhjem.org>
References: <1411654543.3044.24.camel@leira.trondhjem.org> <28059.1411650278@warthog.procyon.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: NMI/soft lockup in nfs_delegation_need_return()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 26 Feb 2015 10:45:19 +0000
Message-ID: <6150.1424947519@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Seems I can still reproduce this (see below).  I don't suppose you've had any
further insights since September?

David
---
NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s! [90.155.74.18-ma:2834]
Modules linked in: cachefiles nfsv4 nfsv3 nfsv2 nfs fscache auth_rpcgss nfs_acl lockd grace sunrpc
irq event stamp: 135774
hardirqs last  enabled at (135773): [<ffffffff81091701>] __call_rcu+0x241/0x253
hardirqs last disabled at (135774): [<ffffffff8155895a>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (135762): [<ffffffff810439a8>] __do_softirq+0x25a/0x319
softirqs last disabled at (135757): [<ffffffff81043c73>] irq_exit+0x5e/0xd6
CPU: 1 PID: 2834 Comm: 90.155.74.18-ma Tainted: G        W       3.19.0-fsdevel+ #1143
Hardware name:                  /DG965RY, BIOS MQ96510J.86A.0816.2006.0716.2308 07/16/2006
task: ffff88000ab6a410 ti: ffff88001cab8000 task.ti: ffff88001cab8000
RIP: 0010:[<ffffffffa010c418>]  [<ffffffffa010c418>] nfs_client_return_marked_delegations+0x9b/0x1a9 [nfsv4]
RSP: 0018:ffff88001cabbdb8  EFLAGS: 00000292
RAX: ffff880000e4b7c0 RBX: ffffffffa010c39c RCX: 0000000000000000
RDX: ffff880000e4b808 RSI: ffff88000ab6a410 RDI: ffff88000ab6a410
RBP: ffff88001cabbe08 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000296
R13: ffff88001cabbd98 R14: 0000000000000002 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88003db00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f419ab7a000 CR3: 000000003a7fa000 CR4: 00000000000007e0
Stack:
 ffff880038dc9cc8 ffff880010e8d7f8 ffff88000ab6a410 ffff880000e4b7c0
 ffff88001cabbe08 ffff880038dc9c00 ffff880038dc9c00 ffff880038dc9d30
 0000000000000000 0000000000000000 ffff88001cabbe58 ffffffffa010a54f
Call Trace:
 [<ffffffffa010a54f>] nfs4_run_state_manager+0x5da/0x5df [nfsv4]
 [<ffffffffa0109f75>] ? nfs4_do_reclaim+0x55d/0x55d [nfsv4]
 [<ffffffffa0109f75>] ? nfs4_do_reclaim+0x55d/0x55d [nfsv4]
 [<ffffffff81059b9d>] kthread+0x10e/0x116
 [<ffffffff81059a8f>] ? kthread_create_on_node+0x1bb/0x1bb
 [<ffffffff815579ac>] ret_from_fork+0x7c/0xb0
 [<ffffffff81059a8f>] ? kthread_create_on_node+0x1bb/0x1bb
Code: 00 48 89 45 c8 4c 8b 65 c8 48 8d 83 f8 07 00 00 48 89 45 b8 4c 3b 65 b8 0f 84 d6 00 00 00 49 8d 54 24 48 f0 41 0f ba 74 24 48 01 <72> 05 45 31 f6 eb 03 41 b6 01 f0 0f ba 32 02 72 02 eb 36 45 84 
