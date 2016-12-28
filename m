Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:37304 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752807AbcL1Bjd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Dec 2016 20:39:33 -0500
Date: Tue, 27 Dec 2016 19:55:35 -0500
From: Dave Jones <davej@codemonkey.org.uk>
To: netdev@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: sunrpc: Illegal context switch in RCU read-side critical section!
Message-ID: <20161228005535.oh7ip4wkc2bfed74@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just noticed this on 4.9. Will try and repro on 4.10rc1 later, but hitting
unrelated boot problems on that machine right now.

===============================
[ INFO: suspicious RCU usage. ]
4.9.0-backup-debug+ #1 Not tainted
-------------------------------
./include/linux/rcupdate.h:557 Illegal context switch in RCU read-side critical section!

other info that might help us debug this:

rcu_scheduler_active = 1, debug_locks = 1
5 locks held by kworker/4:1/66:
 #0:  ("%s"("ipv6_addrconf")){.+.+..}, at: [<ffffffff8e09dd14>] process_one_work+0x184/0x790
 #1:  ((addr_chk_work).work){+.+...}, at: [<ffffffff8e09dd14>] process_one_work+0x184/0x790
 #2:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8e9eadc7>] rtnl_lock+0x17/0x20
 #3:  (rcu_read_lock_bh){......}, at: [<ffffffff8ea8b0a3>] addrconf_verify_rtnl+0x23/0x500
 #4:  (rcu_read_lock){......}, at: [<ffffffff8e0a6c65>] atomic_notifier_call_chain+0x5/0x110

stack backtrace:
CPU: 4 PID: 66 Comm: kworker/4:1 Not tainted 4.9.0-backup-debug+ #1
Workqueue: ipv6_addrconf addrconf_verify_work
 ffffc90000273a28 ffffffff8e5b4ca5 ffff88042ae19780 0000000000000001
 ffffc90000273a58 ffffffff8e0d530e 0000000000000000 ffffffff8efcc659
 00000000000009a7 ffff8804180b8580 ffffc90000273a80 ffffffff8e0ad2b7
Call Trace:
 [<ffffffff8e5b4ca5>] dump_stack+0x68/0x93
 [<ffffffff8e0d530e>] lockdep_rcu_suspicious+0xce/0xf0
 [<ffffffff8e0ad2b7>] ___might_sleep.part.103+0xa7/0x230
 [<ffffffff8e0b74db>] __might_sleep+0x4b/0x90
 [<ffffffff8e9b9ed2>] lock_sock_nested+0x32/0xb0
 [<ffffffff8e9ba2cb>] sock_setsockopt+0x8b/0xa50
 [<ffffffff8e088025>] ? __local_bh_enable_ip+0x65/0xb0
 [<ffffffff8e9b5f39>] kernel_setsockopt+0x49/0x50
 [<ffffffff8eae7d6a>] svc_tcp_kill_temp_xprt+0x4a/0x60
 [<ffffffff8eafa9ef>] svc_age_temp_xprts_now+0x12f/0x1b0
 [<ffffffff8e350e32>] nfsd_inet6addr_event+0x192/0x1f0
 [<ffffffff8e350ca5>] ? nfsd_inet6addr_event+0x5/0x1f0
 [<ffffffff8e0a69f9>] notifier_call_chain+0x39/0xa0
 [<ffffffff8e0a6cce>] atomic_notifier_call_chain+0x6e/0x110
 [<ffffffff8e0a6c65>] ? atomic_notifier_call_chain+0x5/0x110
 [<ffffffff8eac58cb>] inet6addr_notifier_call_chain+0x1b/0x20
 [<ffffffff8ea8a89c>] ipv6_del_addr+0x12c/0x200
 [<ffffffff8ea8b497>] addrconf_verify_rtnl+0x417/0x500
 [<ffffffff8ea8b0a3>] ? addrconf_verify_rtnl+0x23/0x500
 [<ffffffff8ea8b593>] addrconf_verify_work+0x13/0x20
 [<ffffffff8e09dd9b>] process_one_work+0x20b/0x790
 [<ffffffff8e09dd14>] ? process_one_work+0x184/0x790
 [<ffffffff8e09e36e>] worker_thread+0x4e/0x490
 [<ffffffff8e09e320>] ? process_one_work+0x790/0x790
 [<ffffffff8e09e320>] ? process_one_work+0x790/0x790
 [<ffffffff8e0a4ecf>] kthread+0xff/0x120
 [<ffffffff8e0a4dd0>] ? kthread_worker_fn+0x140/0x140
 [<ffffffff8eb14517>] ret_from_fork+0x27/0x40

