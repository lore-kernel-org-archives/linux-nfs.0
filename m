From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: another RCU lockdep splat
Date: Wed, 16 Jun 2010 10:10:06 -0400
Message-ID: <1276697406.5267.16.camel@heimdal.trondhjem.org>
References: <1276696474.3640.23.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-nfs <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:52495 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758850Ab0FPOKO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jun 2010 10:10:14 -0400
In-Reply-To: <1276696474.3640.23.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-06-16 at 15:54 +0200, Johannes Berg wrote:
> Got this when trying to access an NFS filesystem where the server was
> down. I think that caused it anyway.
> 
> [24891.782023] ===================================================
> [24891.782027] [ INFO: suspicious rcu_dereference_check() usage. ]
> [24891.782030] ---------------------------------------------------
> [24891.782034] net/sunrpc/auth_gss/auth_gss.c:947 invoked rcu_dereference_check() without protection!
> [24891.782038] 
> [24891.782039] other info that might help us debug this:
> [24891.782040] 
> [24891.782043] 
> [24891.782044] rcu_scheduler_active = 1, debug_locks = 1
> [24891.782048] 1 lock held by rpc.gssd/1895:
> [24891.782050]  #0:  (&sb->s_type->i_mutex_key#12){+.+.+.}, at: [<ffffffffa05567c3>] rpc_pipe_write+0x43/0x90 [sunrpc]
> [24891.782081] 
> [24891.782082] stack backtrace:
> [24891.782086] Pid: 1895, comm: rpc.gssd Not tainted 2.6.35-rc3-wl-47328-g368319a-dirty #168
> [24891.782090] Call Trace:
> [24891.782100]  [<ffffffff8107e344>] lockdep_rcu_dereference+0xa4/0xc0
> [24891.782109]  [<ffffffffa058f191>] gss_free_ctx+0x91/0xa0 [auth_rpcgss]
> [24891.782116]  [<ffffffffa05901fe>] ? gss_release_msg+0xe/0x80 [auth_rpcgss]
> [24891.782124]  [<ffffffffa05918d4>] gss_pipe_downcall+0x1b4/0x260 [auth_rpcgss]
> [24891.782141]  [<ffffffffa05567e2>] rpc_pipe_write+0x62/0x90 [sunrpc]
> [24891.782147]  [<ffffffff811110d8>] vfs_write+0xb8/0x1a0
> [24891.782153]  [<ffffffff811112b1>] sys_write+0x51/0x90
> [24891.782159]  [<ffffffff8100273b>] system_call_fastpath+0x16/0x1b

That's another false positive. We only call gss_free_ctx when the
ctx->count reference counter is zero.

Hmm... On the other hand, I'm not sure we really need RCU protection for
ctx->gc_gss_ctx in the first place.

Cheers
  Trond

