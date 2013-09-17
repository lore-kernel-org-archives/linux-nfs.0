Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55456 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753007Ab3IQWTU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Sep 2013 18:19:20 -0400
Date: Tue, 17 Sep 2013 18:19:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: gss_destroy crash
Message-ID: <20130917221914.GB3079@fieldses.org>
References: <20130917214115.GA3079@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130917214115.GA3079@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 17, 2013 at 05:41:15PM -0400, bfields wrote:
> As of eb6dc19d8e72ce3a957af5511d20c0db0a8bd007 "RPCSEC_GSS: Share all
> credential caches on a per-transport basis" I'm getting an occasional
> crash on shutdown of nfsd's 4.0 callback client (see appended oops),
> because  rpc_shutdown_client() is called on a client whose cl_auth is a
> gss_auth with gss_pipe[0]->clnt pointing to freed memory.
> 
> Is there any known bug here?
> 
> While I try to understand this....
> 
> I'm wondering what guarantees that gss_pipe[0]->clnt is still good at
> this point, and that leads me to be suspicious of the sharing introduced
> by this patch--how do we know that a gss_auth can't be shared between
> two clients that could disappear in either order?
> 
> The chasing of cl_parent pointers in gss_create() suggests that the
> auth's pointers back to clients are always supposed to be back to a
> common ancestor, but does gss_auth_find_or_add_hashed really guarantee
> that the auth will only be shared between clients that are cloned from a
> common ancestor?

Confirmed that adding a check like

@@ -1085,6 +1085,8 @@ gss_auth_find_or_add_hashed(struct rpc_auth_create_args *args,
 			gss_auth,
 			hash,
 			hashval) {
+		if (gss_auth->client != clnt)
+			continue;
 		if (gss_auth->rpc_auth.au_flavor != args->pseudoflavor)
 			continue;
 		if (gss_auth->target_name != args->target_name) {

fixes the problem.  I can send in a proper patch if you think that makes
sense....

--b.

> 
> --b.
> 
> general protection fault: 0000 [#1] PREEMPT SMP 
> Modules linked in: rpcsec_gss_krb5 nfsd auth_rpcgss oid_registry nfs_acl lockd sunrpc
> CPU: 3 PID: 4071 Comm: kworker/u8:2 Not tainted 3.11.0-rc2-00182-g025145f #1665
> Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> Workqueue: nfsd4_callbacks nfsd4_do_callback_rpc [nfsd]
> task: ffff88003e206080 ti: ffff88003c384000 task.ti: ffff88003c384000
> RIP: 0010:[<ffffffffa00001f3>]  [<ffffffffa00001f3>] rpc_net_ns+0x53/0x70 [sunrpc]
> RSP: 0000:ffff88003c385ab8  EFLAGS: 00010246
> RAX: 6b6b6b6b6b6b6b6b RBX: ffff88003af9a800 RCX: 0000000000000002
> RDX: ffffffffa00001a5 RSI: 0000000000000001 RDI: ffffffff81e284e0
> RBP: ffff88003c385ad8 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000015 R12: ffff88003c990840
> R13: ffff88003c990878 R14: ffff88003c385ba8 R15: ffff88003e206080
> FS:  0000000000000000(0000) GS:ffff88003fd80000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007fcdf737e000 CR3: 000000003ad2b000 CR4: 00000000000006e0
> Stack:
>  ffffffffa00001a5 0000000000000006 0000000000000006 ffff88003af9a800
>  ffff88003c385b08 ffffffffa00d52a4 ffff88003c385ba8 ffff88003c751bd8
>  ffff88003c751bc0 ffff88003e113600 ffff88003c385b18 ffffffffa00d530c
> Call Trace:
>  [<ffffffffa00001a5>] ? rpc_net_ns+0x5/0x70 [sunrpc]
>  [<ffffffffa00d52a4>] __gss_pipe_release+0x54/0x90 [auth_rpcgss]
>  [<ffffffffa00d530c>] gss_pipe_free+0x2c/0x30 [auth_rpcgss]
>  [<ffffffffa00d678b>] gss_destroy+0x9b/0xf0 [auth_rpcgss]
>  [<ffffffffa000de63>] rpcauth_release+0x23/0x30 [sunrpc]
>  [<ffffffffa0001e81>] rpc_release_client+0x51/0xb0 [sunrpc]
>  [<ffffffffa00020d5>] rpc_shutdown_client+0xe5/0x170 [sunrpc]
>  [<ffffffff81098a14>] ? cpuacct_charge+0xa4/0xb0
>  [<ffffffff81098975>] ? cpuacct_charge+0x5/0xb0
>  [<ffffffffa019556f>] nfsd4_process_cb_update.isra.17+0x2f/0x210 [nfsd]
>  [<ffffffff819a4ac0>] ? _raw_spin_unlock_irq+0x30/0x60
>  [<ffffffff819a4acb>] ? _raw_spin_unlock_irq+0x3b/0x60
>  [<ffffffff810703ab>] ? process_one_work+0x15b/0x510
>  [<ffffffffa01957dd>] nfsd4_do_callback_rpc+0x8d/0xa0 [nfsd]
>  [<ffffffff8107041e>] process_one_work+0x1ce/0x510
>  [<ffffffff810703ab>] ? process_one_work+0x15b/0x510
>  [<ffffffff810712ab>] worker_thread+0x11b/0x370
>  [<ffffffff81071190>] ? manage_workers.isra.24+0x2b0/0x2b0
>  [<ffffffff8107854b>] kthread+0xdb/0xe0
>  [<ffffffff819a4ac0>] ? _raw_spin_unlock_irq+0x30/0x60
>  [<ffffffff81078470>] ? __init_kthread_worker+0x70/0x70
>  [<ffffffff819ac7dc>] ret_from_fork+0x7c/0xb0
>  [<ffffffff81078470>] ? __init_kthread_worker+0x70/0x70
> Code: a5 01 00 a0 31 d2 31 f6 48 c7 c7 e0 84 e2 81 e8 f4 91 0a e1 48 8b 43 60 48 c7 c2 a5 01 00 a0 be 01 00 00 00 48 c7 c7 e0 84 e2 81 <48> 8b 98 10 07 00 00 e8 91 8f 0a e1 e8 3c 4e 07 e1 48 83 c4 18 
> RIP  [<ffffffffa00001f3>] rpc_net_ns+0x53/0x70 [sunrpc]
>  RSP <ffff88003c385ab8>
> ---[ end trace ce5e3f2a85c100c0 ]---
> 
