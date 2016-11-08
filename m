Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:51764 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932270AbcKHRoL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Nov 2016 12:44:11 -0500
Date: Tue, 8 Nov 2016 10:43:46 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Ross Zwisler <ross.zwisler@linux.intel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andy Adamson <andros@Netapp.com>
Subject: Re: net/sunrpc/clnt.c:2773 suspicious rcu_dereference_check() usage!
Message-ID: <20161108174346.GA17545@linux.intel.com>
References: <20161108054202.GA12406@linux.intel.com>
 <1478606028.2443.2.camel@redhat.com>
 <1478606957.2443.8.camel@redhat.com>
 <60a0f29b-7a0a-c5e2-0e98-fa9a923dd339@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <60a0f29b-7a0a-c5e2-0e98-fa9a923dd339@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 08, 2016 at 07:42:59AM -0500, Anna Schumaker wrote:
> On 11/08/2016 07:09 AM, Jeff Layton wrote:
> > On Tue, 2016-11-08 at 06:53 -0500, Jeff Layton wrote:
> >> On Mon, 2016-11-07 at 22:42 -0700, Ross Zwisler wrote:
> >>>
> >>> I've got a virtual machine that has some NFS mounts, and with a newly compiled
> >>> kernel based on v4.9-rc3 I see the following warning/info message:
> >>>
> >>> [   42.750181] ===============================
> >>> [   42.750192] [ INFO: suspicious RCU usage. ]
> >>> [   42.750203] 4.9.0-rc3-00002-g7b6e7de #3 Not tainted
> >>> [   42.750213] -------------------------------
> >>> [   42.750225] net/sunrpc/clnt.c:2773 suspicious rcu_dereference_check() usage!
> >>> [   42.750235] 
> >>> [   42.750235] other info that might help us debug this:
> >>> [   42.750235] 
> >>> [   42.750246] 
> >>> [   42.750246] rcu_scheduler_active = 1, debug_locks = 0
> >>> [   42.750257] 1 lock held by mount.nfs4/6440:
> >>> [   42.750278]  #0: 
> >>> [   42.750299]  (
> >>> [   42.750319] &(&nn->nfs_client_lock)->rlock
> >>> [   42.750340] ){+.+...}
> >>> [   42.750362] , at: 
> >>> [   42.750372] [<ffffffff813012b5>] nfs_get_client+0x105/0x5e0
> >>> [   42.750383] 
> >>> [   42.750383] stack backtrace:
> >>> [   42.750394] CPU: 0 PID: 6440 Comm: mount.nfs4 Not tainted 4.9.0-rc3-00002-g7b6e7de #3
> >>> [   42.750406] Hardware name: Intel Corporation PURLEY/PURLEY, BIOS PLYDCRB1.MBH.0096.D23.1608240105 08/24/2016
> >>> [   42.750429]  ffffc9000092fa68 ffffffff8150730f ffff88014ec8da40 0000000000000001
> >>> [   42.750452]  ffffc9000092fa98 ffffffff810bc3f7 ffff880150b0b228 ffff88015068dbb0
> >>> [   42.750475]  ffffc9000092fb38 ffff88014fc99180 ffffc9000092fac0 ffffffff81b243e5
> >>> [   42.750486] Call Trace:
> >>> [   42.750498]  [<ffffffff8150730f>] dump_stack+0x67/0x98
> >>> [   42.750511]  [<ffffffff810bc3f7>] lockdep_rcu_suspicious+0xe7/0x120
> >>> [   42.750524]  [<ffffffff81b243e5>] rpc_clnt_xprt_switch_has_addr+0x115/0x150
> >>> [   42.750536]  [<ffffffff813013f4>] nfs_get_client+0x244/0x5e0
> >>> [   42.750549]  [<ffffffff813012ac>] ? nfs_get_client+0xfc/0x5e0
> >>> [   42.750561]  [<ffffffff813568f8>] nfs4_set_client+0x98/0x130
> >>> [   42.750574]  [<ffffffff8135872e>] nfs4_create_server+0x13e/0x390
> >>> [   42.750588]  [<ffffffff8134cd0e>] nfs4_remote_mount+0x2e/0x60
> >>> [   42.750600]  [<ffffffff811f3a29>] mount_fs+0x39/0x170
> >>> [   42.750614]  [<ffffffff81214a0b>] vfs_kern_mount+0x6b/0x150
> >>> [   42.750626]  [<ffffffff8134cbec>] ? nfs_do_root_mount+0x3c/0xc0
> >>> [   42.750639]  [<ffffffff8134cc36>] nfs_do_root_mount+0x86/0xc0
> >>> [   42.750652]  [<ffffffff8134d014>] nfs4_try_mount+0x44/0xc0
> >>> [   42.750664]  [<ffffffff81302097>] ? get_nfs_version+0x27/0x90
> >>> [   42.750677]  [<ffffffff81310f8c>] nfs_fs_mount+0x4ac/0xd80
> >>> [   42.750689]  [<ffffffff810bb938>] ? lockdep_init_map+0x88/0x1f0
> >>> [   42.750701]  [<ffffffff81311ac0>] ? nfs_clone_super+0x130/0x130
> >>> [   42.750713]  [<ffffffff8130f300>] ? param_set_portnr+0x70/0x70
> >>> [   42.750726]  [<ffffffff811f3a29>] mount_fs+0x39/0x170
> >>> [   42.750740]  [<ffffffff81214a0b>] vfs_kern_mount+0x6b/0x150
> >>> [   42.750752]  [<ffffffff812176f1>] do_mount+0x1f1/0xd10
> >>> [   42.750765]  [<ffffffff81217441>] ? copy_mount_options+0xa1/0x140
> >>> [   42.750777]  [<ffffffff81218543>] SyS_mount+0x83/0xd0
> >>> [   42.750790]  [<ffffffff81002abc>] do_syscall_64+0x5c/0x130
> >>> [   42.750802]  [<ffffffff81c479a4>] entry_SYSCALL64_slow_path+0x25/0x25
> >>>
> >>> This rcu_dereference_check() was introduced by the following commit:
> >>>
> >>> commit 39e5d2df959dd4aea81fa33d765d2a5cc67a0512
> >>> Author: Andy Adamson <andros@netapp.com>
> >>> Date:   Fri Sep 9 09:22:25 2016 -0400
> >>>
> >>>     SUNRPC search xprt switch for sockaddr
> >>>     
> >>>     Signed-off-by: Andy Adamson <andros@netapp.com>
> >>>     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> >>>
> >>> Thanks,
> >>> - Ross
> >>
> >> Thanks Ross,
> 
> Hi Ross,
> 
> Can you try this patch and let me know if it helps:
> 
> http://git.linux-nfs.org/?p=anna/linux-nfs.git;a=commitdiff;h=bb29dd84333a96f309c6d0f88b285b5b78927058
> 
> I'm planning on sending it to Linus soon, so it should be in rc5.

Hi Anna,

Yep, this patch makes the warning go away in my setup.

Thanks,
- Ross
