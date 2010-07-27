Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:42402 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664Ab0G0Ksk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jul 2010 06:48:40 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <johannes@sipsolutions.net>)
	id 1OdhiB-0006pn-RO
	for linux-nfs@vger.kernel.org; Tue, 27 Jul 2010 12:48:39 +0200
Subject: auth_gss.c - rcu dereference warning
From: Johannes Berg <johannes@sipsolutions.net>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 27 Jul 2010 12:48:38 +0200
Message-ID: <1280227718.3755.3.camel@jlt3.sipsolutions.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I consistently get this when I unmount an NFS volume.

johannes

[  381.427221] ===================================================
[  381.427225] [ INFO: suspicious rcu_dereference_check() usage. ]
[  381.427228] ---------------------------------------------------
[  381.427232] /home/johannes/sys/wireless-testing/net/sunrpc/auth_gss/auth_gss.c:947 invoked rcu_dereference_check() without protection!
[  381.427236] 
[  381.427237] other info that might help us debug this:
[  381.427238] 
[  381.427241] 
[  381.427242] rcu_scheduler_active = 1, debug_locks = 1
[  381.427246] 2 locks held by rpciod/0/1881:
[  381.427248]  #0:  (rpciod){+.+.+.}, at: [<ffffffff810640cf>] run_workqueue+0x11f/0x3c0
[  381.427262]  #1:  ((&task->u.tk_work)){+.+.+.}, at: [<ffffffff810640cf>] run_workqueue+0x11f/0x3c0
[  381.427271] 
[  381.427272] stack backtrace:
[  381.427276] Pid: 1881, comm: rpciod/0 Not tainted 2.6.35-rc6-wl-47665-gc2e2180-dirty #174
[  381.427280] Call Trace:
[  381.427289]  [<ffffffff8107e494>] lockdep_rcu_dereference+0xa4/0xc0
[  381.427297]  [<ffffffffa05e0191>] gss_free_ctx+0x91/0xa0 [auth_rpcgss]
[  381.427311]  [<ffffffffa05e19ed>] gss_destroy_nullcred+0x4d/0x70 [auth_rpcgss]
[  381.427331]  [<ffffffffa0598f97>] put_rpccred+0x127/0x140 [sunrpc]
[  381.427348]  [<ffffffffa059922e>] rpcauth_unbindcred+0x2e/0x70 [sunrpc]
[  381.427371]  [<ffffffffa05970ea>] rpc_put_task+0x3a/0xd0 [sunrpc]
[  381.427386]  [<ffffffffa0597810>] rpc_release_task+0x70/0xa0 [sunrpc]
[  381.427402]  [<ffffffffa0598229>] __rpc_execute+0x179/0x200 [sunrpc]
[  381.427433]  [<ffffffffa05982f5>] rpc_async_schedule+0x15/0x20 [sunrpc]
[  381.427438]  [<ffffffff81064120>] run_workqueue+0x170/0x3c0
[  381.427457]  [<ffffffff81064413>] worker_thread+0xa3/0x110
[  381.427472]  [<ffffffff81069386>] kthread+0x96/0xa0
[  381.427479]  [<ffffffff81003514>] kernel_thread_helper+0x4/0x10


