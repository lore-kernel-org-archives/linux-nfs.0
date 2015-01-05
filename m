Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40162 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750995AbbAEUU0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 15:20:26 -0500
Date: Mon, 5 Jan 2015 15:20:26 -0500
To: Trond Myklebust <trondmy@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: schedule WARNING from nfs41_callback_svc
Message-ID: <20150105202026.GA12067@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3.19-rc2 I'm getting:

	[  426.715480] WARNING: CPU: 2 PID: 7920 at kernel/sched/core.c:7303 __might_sleep+0x92/0xa0()
	[  426.715485] do not call blocking ops when !TASK_RUNNING; state=1 set at [<ffffffff810ad99f>] prepare_to_wait+0x2f/0x90
	...
	[  426.715613]  [<ffffffff81094eb4>] groups_alloc+0x34/0x110
	[  426.715638]  [<ffffffffa00181da>] svcauth_unix_accept+0x14a/0x280 [sunrpc]
	[  426.715659]  [<ffffffffa00170a8>] svc_authenticate+0xc8/0xe0 [sunrpc]
	[  426.715683]  [<ffffffffa0012cf2>] svc_process_common+0x202/0x6d0 [sunrpc]
	[  426.715703]  [<ffffffffa00135d8>] bc_svc_process+0x1c8/0x260 [sunrpc]
	[  426.715725]  [<ffffffffa01da8e0>] nfs41_callback_svc+0x100/0x1b0 [nfsv4]
	...

Looks like this is a new check added by 8eb23b9f35aa "sched: Debug
nested sleeps".  I don't *think* it's catching a real problem here, but
maybe I'm missing some subtlety.  I suppose nfs41_callback_svc() could
move the finish_wait() so it's done before the bc_svc_process()?

--b.
