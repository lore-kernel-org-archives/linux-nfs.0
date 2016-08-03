Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-db5eur01on0135.outbound.protection.outlook.com ([104.47.2.135]:18080
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759198AbcHEAP4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2016 20:15:56 -0400
Date: Wed, 3 Aug 2016 20:36:48 +0300
From: Cyrill Gorcunov <gorcunov@virtuozzo.com>
To: Stanislav Kinsburskiy <skinsbursky@virtuozzo.com>
CC: <bfields@fieldses.org>, <jlayton@poochiereds.net>,
        <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
        <devel@openvz.org>
Subject: Re: [RFC PATCH] sunrpc: do not allow process to freeze within RPC
 state machine
Message-ID: <20160803173648.GA10543@uranus>
References: <20160803165412.22407.47399.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <20160803165412.22407.47399.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 03, 2016 at 08:54:50PM +0400, Stanislav Kinsburskiy wrote:
> Otherwise freezer cgroup state might never become "FROZEN".
> 
> Here is a deadlock scheme for 2 processes in one freezer cgroup, which is
> freezing:
> 
> CPU 0                                   CPU 1
> --------                                --------
> do_last
> inode_lock(dir->d_inode)
> vfs_create
> nfs_create
> ...
> __rpc_execute
> rpc_wait_bit_killable
> __refrigerator
>                                         do_last
>                                         inode_lock(dir->d_inode)
> 
> So, the problem is that one process takes directory inode mutex, executes
> creation request and goes to refrigerator.
> Another one waits till directory lock is released, remains "thawed" and thus
> freezer cgroup state never becomes "FROZEN".
> 
> Notes:
> 1) Interesting, that this is not a pure deadlock: one can thaw cgroup and then
> freeze it again.
> 2) The issue was introduced by commit d310310cbff18ec385c6ab4d58f33b100192a96a.
> 3) This patch is not aimed to fix the issue, but to show the problem root.
> Look like this problem moght be applicable to other hunks from the commit,
> mentioned above.
> 
> Signed-off-by: Stanislav Kinsburskiy <skinsbursky@virtuozzo.com>

I think it's worth adding backtrace as well
---

=== pid: 708987 === (file_read)

[<ffffffff810de47b>] __refrigerator+0x5b/0x190
[<ffffffffa01e6d36>] rpc_wait_bit_killable+0x66/0x80 [sunrpc]
[<ffffffffa01e7bf4>] __rpc_execute+0x154/0x420 [sunrpc]
[<ffffffffa01e972e>] rpc_execute+0x5e/0xa0 [sunrpc]
[<ffffffffa01df220>] rpc_run_task+0x70/0x90 [sunrpc]
[<ffffffffa01df290>] rpc_call_sync+0x50/0xc0 [sunrpc]
[<ffffffffa035c5cb>] nfs3_rpc_wrapper.constprop.10+0x6b/0xb0 [nfsv3]
[<ffffffffa035c6cf>] nfs3_proc_setattr+0xbf/0x140 [nfsv3]
[<ffffffffa035db03>] nfs3_proc_create+0x1a3/0x220 [nfsv3]
[<ffffffffa036c023>] nfs_create+0x83/0x150 [nfs]
[<ffffffff8120639c>] vfs_create+0x8c/0x110
[<ffffffff8120963d>] do_last+0xc0d/0x11d0
[<ffffffff81209cc2>] path_openat+0xc2/0x460
[<ffffffff8120b45b>] do_filp_open+0x4b/0xb0
[<ffffffff811f8c63>] do_sys_open+0xf3/0x1f0
[<ffffffff811f8d7e>] SyS_open+0x1e/0x20
[<ffffffff81643449>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

=== pid: 708988 === (file_read)

[<ffffffff81208cb3>] do_last+0x283/0x11d0
[<ffffffff81209cc2>] path_openat+0xc2/0x460
[<ffffffff8120b45b>] do_filp_open+0x4b/0xb0
[<ffffffff811f8c63>] do_sys_open+0xf3/0x1f0
[<ffffffff811f8d7e>] SyS_open+0x1e/0x20
[<ffffffff81643449>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
