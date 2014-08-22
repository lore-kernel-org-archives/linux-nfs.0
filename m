Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:38154 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755265AbaHVHzk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2014 03:55:40 -0400
Message-ID: <53F6F772.6020708@oracle.com>
Date: Fri, 22 Aug 2014 15:55:30 +0800
From: Junxiao Bi <junxiao.bi@oracle.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: rpciod deadlock issue
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,

I got an nfs hung issue, looks like "rpciod" run into deadlock. Bug is
reported on 2.6.32, but seems mainline also suffers this bug from the
source code.

See the following rpciod trace. rpciod allocated memory using GFP_KERNEL
in xs_setup_xprt(). That triggered direct reclaim when available memory
was not enough, where it waited an write-back page done, but that page
was a nfs page, and it depended on rpciod to write back. So this caused
a deadlock.

I am not sure how to fix this issue. Replace GFP_KERNEL with GFP_NOFS in
xs_setup_xprt() can fix this trace, but there are other place allocating
memory with GFP_KERNEL in rpciod, like
xs_tcp_setup_socket()->xs_create_sock()->__sock_create()->sock_alloc(),
there is no way to pass GFP_NOFS to network command code. Also mainline
has changed to not care ___GFP_FS before waiting page write back done.
Upstream commit 5cf02d0 (nfs: skip commit in releasepage if we're
freeing memory for fs-related reasons) uses PF_FSTRANS to avoid another
deadlock when direct reclaim, i am thinking whether we can check
PF_FSTRANS flag in shrink_page_list(), if this flag is set, it will not
wait any page write back done? I saw this flag is also used by xfs, not
sure whether this will affect xfs.

Any advices is appreciated.

@ crash> bt 1539
@ PID: 1539   TASK: ffff88178f64a040  CPU: 1   COMMAND: "rpciod/1"
@  #0 [ffff88178f64d2c0] schedule at ffffffff8145833a
@  #1 [ffff88178f64d348] io_schedule at ffffffff8145842c
@  #2 [ffff88178f64d368] sync_page at ffffffff810d8161
@  #3 [ffff88178f64d378] __wait_on_bit at ffffffff8145895b
@  #4 [ffff88178f64d3b8] wait_on_page_bit at ffffffff810d82fe
@  #5 [ffff88178f64d418] wait_on_page_writeback at ffffffff810e2a1a
@  #6 [ffff88178f64d438] shrink_page_list at ffffffff810e34e1
@  #7 [ffff88178f64d588] shrink_list at ffffffff810e3dbe
@  #8 [ffff88178f64d6f8] shrink_zone at ffffffff810e425e
@  #9 [ffff88178f64d7b8] do_try_to_free_pages at ffffffff810e4978
@ #10 [ffff88178f64d828] try_to_free_pages at ffffffff810e4c31
@ #11 [ffff88178f64d8c8] __alloc_pages_nodemask at ffffffff810de370
@ #12 [ffff88178f64d978] kmem_getpages at ffffffff8110e18b
@ #13 [ffff88178f64d9a8] fallback_alloc at ffffffff8110e35e
@ #14 [ffff88178f64da08] ____cache_alloc_node at ffffffff8110e51f
@ #15 [ffff88178f64da48] __kmalloc at ffffffff8110efba
@ #16 [ffff88178f64da98] xs_setup_xprt at ffffffffa00a563f [sunrpc]
@ #17 [ffff88178f64dad8] xs_setup_tcp at ffffffffa00a7648 [sunrpc]
@ #18 [ffff88178f64daf8] xprt_create_transport at ffffffffa00a478f [sunrpc]
@ #19 [ffff88178f64db18] rpc_create at ffffffffa00a2d7a [sunrpc]
@ #20 [ffff88178f64dbf8] rpcb_create at ffffffffa00b026b [sunrpc]
@ #21 [ffff88178f64dc98] rpcb_getport_async at ffffffffa00b0c94 [sunrpc]
@ #22 [ffff88178f64ddf8] call_bind at ffffffffa00a11f8 [sunrpc]
@ #23 [ffff88178f64de18] __rpc_execute at ffffffffa00a88ef [sunrpc]
@ #24 [ffff88178f64de58] rpc_async_schedule at ffffffffa00a9187 [sunrpc]
@ #25 [ffff88178f64de78] worker_thread at ffffffff81072ed2
@ #26 [ffff88178f64dee8] kthread at ffffffff81076df3
@ #27 [ffff88178f64df48] kernel_thread at ffffffff81012e2a
@ crash>

Thanks,
Junxiao.
