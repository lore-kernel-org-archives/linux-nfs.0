Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6648 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753508Ab3B1Q43 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Feb 2013 11:56:29 -0500
Date: Thu, 28 Feb 2013 08:56:25 -0800
From: "J. Bruce Fields" <bfields@redhat.com>
To: majianpeng <majianpeng@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: BUG: rpc.nfsd/5066 still has locks held!
Message-ID: <20130228165623.GA14856@pad.fieldses.org>
References: <201302281623470389097@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201302281623470389097@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 28, 2013 at 04:23:49PM +0800, majianpeng wrote:
> After  i updated the lastest code,

Sorry, I don't know what you mean by "updated the lastest code".  What
kernel version were you running previously, and what version are you
running now?

--b.

> those messages occured. Every reboot, it can occur at least 10 times.
> 
> [   17.763939] =====================================
> [   17.763942] [ BUG: rpc.nfsd/5066 still has locks held! ]
> [   17.763944] 3.8.0+ #131 Not tainted
> [   17.763945] -------------------------------------
> [   17.763947] 2 locks held by rpc.nfsd/5066:
> [   17.763948]  #0:  (nfsd_mutex){......}, at: [<ffffffffa012b45f>] write_ports+0x2f/0x3f0 [nfsd]
> [   17.763963]  #1:  (rpcb_create_local_mutex){......}, at: [<ffffffffa00824fe>] rpcb_create_local+0x3e/0x90 [sunrpc]
> [   17.763986] 
> [   17.763986] stack backtrace:
> [   17.763989] Pid: 5066, comm: rpc.nfsd Not tainted 3.8.0+ #131
> [   17.763990] Call Trace:
> [   17.763996]  [<ffffffff810917ea>] debug_check_no_locks_held+0x9a/0xa0
> [   17.764003]  [<ffffffffa0076a35>] rpc_wait_bit_killable+0x75/0xa0 [sunrpc]
> [   17.764022]  [<ffffffff816f2dd7>] __wait_on_bit+0x57/0x80
> [   17.764031]  [<ffffffffa00769c0>] ? rpc_queue_empty+0x40/0x40 [sunrpc]
> [   17.764038]  [<ffffffffa006ce10>] ? call_bind_status+0x2f0/0x2f0 [sunrpc]
> [   17.764064]  [<ffffffff816f2e77>] out_of_line_wait_on_bit+0x77/0x90
> [   17.764068]  [<ffffffff81060d80>] ? autoremove_wake_function+0x40/0x40
> [   17.764075]  [<ffffffffa006ce10>] ? call_bind_status+0x2f0/0x2f0 [sunrpc]
> [   17.764084]  [<ffffffffa0077f6c>] __rpc_execute+0x11c/0x400 [sunrpc]
> [   17.764087]  [<ffffffff810609d9>] ? wake_up_bit+0x29/0x40
> [   17.764096]  [<ffffffffa0078918>] rpc_execute+0x68/0xc0 [sunrpc]
> [   17.764104]  [<ffffffffa006f4f0>] rpc_run_task+0x70/0x90 [sunrpc]
> [   17.764112]  [<ffffffffa006f5fe>] rpc_call_sync+0x3e/0xa0 [sunrpc]
> [   17.764120]  [<ffffffffa006f6ad>] rpc_ping+0x4d/0x70 [sunrpc]
> [   17.764127]  [<ffffffffa006f8a8>] rpc_create+0x158/0x1f0 [sunrpc]
> [   17.764137]  [<ffffffffa008236a>] ? rpcb_get_local+0xaa/0xd0 [sunrpc]
> [   17.764147]  [<ffffffffa0082147>] rpcb_create_local_unix+0x57/0xe0 [sunrpc]
> [   17.764173]  [<ffffffffa0082530>] rpcb_create_local+0x70/0x90 [sunrpc]
> [   17.764182]  [<ffffffffa007b49e>] svc_rpcb_setup+0x1e/0x40 [sunrpc]
> [   17.764191]  [<ffffffffa007b4ef>] svc_bind+0x2f/0x40 [sunrpc]
> [   17.764198]  [<ffffffffa0129546>] nfsd_create_serv+0x106/0x1e0 [nfsd]
> [   17.764210]  [<ffffffffa0129440>] ? nfsd_reset_versions+0x80/0x80 [nfsd]
> [   17.764216]  [<ffffffffa012b74c>] write_ports+0x31c/0x3f0 [nfsd]
> [   17.764222]  [<ffffffffa012b680>] ? write_ports+0x250/0x3f0 [nfsd]
> [   17.764230]  [<ffffffff816f6416>] ? _raw_spin_unlock+0x26/0x30
> [   17.764234]  [<ffffffff811660b3>] ? simple_transaction_get+0xc3/0xe0
> [   17.764240]  [<ffffffffa012b430>] ? exports_open+0xb0/0xb0 [nfsd]
> [   17.764250]  [<ffffffffa012a3fc>] nfsctl_transaction_write+0x5c/0x80 [nfsd]
> [   17.764254]  [<ffffffff81140641>] vfs_write+0xb1/0x180
> [   17.764257]  [<ffffffff81140980>] sys_write+0x50/0xa0
> [   17.764265]  [<ffffffff816fe252>] system_call_fastpath+0x16/0x1b
