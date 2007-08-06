From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.23-rc1-mm2
Date: Mon, 06 Aug 2007 12:24:05 -0400
Message-ID: <1186417445.6616.23.camel@localhost>
References: <20070731230932.a9459617.akpm@linux-foundation.org>
	<20070803172137.GA3783@tv-sign.ru>
	<1186381496.21957.30.camel@johannes.berg>
	<200708061305.37208.marc.dietrich@ap.physik.uni-giessen.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-uAbj9Yeafew4w7bjZykd"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Neil Brown <neilb@suse.de>, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
	Johannes Berg <johannes@sipsolutions.net>,
	Oleg Nesterov <oleg@tv-sign.ru>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II5Ne-0004WE-Qu
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 09:24:30 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+W30PqSTz3crMZmv6IxWjE0GGPbkHIWw4=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1II5Nd-0005zO-LB
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 09:24:33 -0700
In-Reply-To: <200708061305.37208.marc.dietrich@ap.physik.uni-giessen.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--=-uAbj9Yeafew4w7bjZykd
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2007-08-06 at 13:05 +0200, Marc Dietrich wrote:
> Hi,
> 
> Am Monday 06 August 2007 08:24 schrieb Johannes Berg:
> > On Fri, 2007-08-03 at 21:21 +0400, Oleg Nesterov wrote:
> > > To avoid a possible confusion: it is still OK if work->func() flushes
> > > its own workqueue, so strictly speaking this trace is false positive,
> > > but it would be very nice if we can get rid of this practice.
> >
> > I just had a thought: we could get rid of this warning by using a
> > read-lock here. That way, flushing from within a work function (which
> > would be seen as read-after-read recursive lock) won't trigger this
> > warning. Patch below. This would, however, also get rid of any warnings
> > for run_workqueue recursion. Which again we may or may not want, the
> > code inidicates that it should be allowed up to a depth of three.
> >
> > However, the question whether we should allow flush_workqueue from
> > within a struct work is mainly an API policy issue; it doesn't hurt to
> > flush a workqueue from within a work, but it is probably nearer the
> > intent to use targeted cancel_work_sync() or such. OTOH, one could
> > imagine situations where multiple different work structs are on that
> > workqueue belonging to the same subsystem and then the general
> > flush_scheduled_work() call is the only way to guarantee nothing is on
> > scheduled at a given point... I don't feel qualified to make the
> > decision for or against allowing this use of the API at this point.
> >
> > Marc, do you have an easy way to trigger this warning? Could you verify
> > that it goes away with the patch below applied?
> 
> just booting into X is enough.
> 
> I applied the patch, but now I get:
> 
> =================================
> [ INFO: inconsistent lock state ]
> 2.6.23-rc1-mm2 #4
> ---------------------------------
> inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
>  (rpc_credcache_lock){-+..}, at: [<c01dc487>] _atomic_dec_and_lock+0x17/0x60
> {softirq-on-W} state was registered at:
>   [<c013e870>] __lock_acquire+0x650/0x1030
>   [<c013f2b1>] lock_acquire+0x61/0x80
>   [<c02db9ac>] _spin_lock+0x2c/0x40
>   [<c01dc487>] _atomic_dec_and_lock+0x17/0x60
>   [<dced55fd>] put_rpccred+0x5d/0x100 [sunrpc]
>   [<dced56c1>] rpcauth_unbindcred+0x21/0x60 [sunrpc]
>   [<dced3fd4>] a0 [sunrpc]
>   [<dcecefe0>] rpc_call_sync+0x30/0x40 [sunrpc]
>   [<dcedc73b>] rpcb_register+0xdb/0x180 [sunrpc]
>   [<dced65b3>] svc_register+0x93/0x160 [sunrpc]
>   [<dced6ebe>] __svc_create+0x1ee/0x220 [sunrpc]
>   [<dced7053>] svc_create+0x13/0x20 [sunrpc]
>   [<dcf6d722>] nfs_callback_up+0x82/0x120 [nfs]
>   [<dcf48f36>] nfs_get_client+0x176/0x390 [nfs]
>   [<dcf49181>] nfs4_set_client+0x31/0x190 [nfs]
>   [<dcf49983>] nfs4_create_server+0x63/0x3b0 [nfs]
>   [<dcf52426>] nfs4_get_sb+0x346/0x5b0 [nfs]
>   [<c017b444>] vfs_kern_mount+0x94/0x110
>   [<c0190a62>] do_mount+0x1f2/0x7d0
>   [<c01910a6>] sys_mount+0x66/0xa0
>   [<c0104046>] syscall_call+0x7/0xb
>   [<ffffffff>] 0xffffffff
> irq event stamp: 5277830
> hardirqs last  enabled at (5277830): [<c017530a>] kmem_cache_free+0x8a/0xc0
> hardirqs last disabled at (5277829): [<c01752d2>] kmem_cache_free+0x52/0xc0
> softirqs last  enabled at (5277798): [<c0124173>] __do_softirq+0xa3/0xc0
> softirqs last disabled at (5277817): [<c01241d7>] do_softirq+0x47/0x50
> 
> other info that might help us debug this:
> no locks held by swapper/0.
> 
> stack backtrace:
>  [<c0104fda>] show_trace_log_lvl+0x1a/0x30
>  [<c0105c02>] show_trace+0x12/0x20
>  [<c0105d15>] dump_stack+0x15/0x20
>  [<c013ccc3>] print_usage_bug+0x153/0x160
>  [<c013d8b9>] mark_lock+0x449/0x620
>  [<c013e824>] __lock_acquire+0x604/0x1030
>  [<c013f2b1>] lock_acquire+0x61/0x80
>  [<c02db9ac>] _spin_lock+0x2c/0x40
>  [<c01dc487>] _atomic_dec_and_lock+0x17/0x60
>  [<dced55fd>] put_rpccred+0x5d/0x100 [sunrpc]
>  [<dcf6bf83>] nfs_free_delegation_callback+0x13/0x20 [nfs]
>  [<c012f9ea>] __rcu_process_callbacks+0x6a/0x1c0
>  [<c012fb52>] rcu_process_callbacks+0x12/0x30
>  [<c0124218>] tasklet_action+0x38/0x80
>  [<c0124125>] __do_softirq+0x55/0xc0
>  [<c01241d7>] do_softirq+0x47/0x50
>  [<c0124605>] irq_exit+0x35/0x40
>  [<c0112463>] smp_apic_timer_interrupt+0x43/0x80
>  [<c0104a77>] apic_timer_interrupt+0x33/0x38
>  [<c02690df>] cpuidle_idle_call+0x6f/0x90
>  [<c01023c3>] cpu_idle+0x43/0x70
>  [<c02d8c27>] rest_init+0x47/0x50
>  [<c03bcb6a>] start_kernel+0x22a/0x2b0
>  [<00000000>] 0x0
>  =======================

That is a different matter. I assume this patch should suffice to fix
the above problem.

Trond


--=-uAbj9Yeafew4w7bjZykd
Content-Disposition: inline;
	filename=linux-2.6.23-005-dont_call_rpc_putcred_from_rcu.dif
Content-Type: message/rfc822;
	name=linux-2.6.23-005-dont_call_rpc_putcred_from_rcu.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Mon, 6 Aug 2007 12:18:34 -0400
NFSv4: Don't call put_rpccred() from an rcu callback
Subject: No Subject
Message-Id: <1186417445.6616.24.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

Doing so would require us to introduce bh-safe locks into put_rpccred().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 20ac403..c55a761 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -20,10 +20,8 @@
 #include "delegation.h"
 #include "internal.h"
 
-static void nfs_free_delegation(struct nfs_delegation *delegation)
+static void nfs_do_free_delegation(struct nfs_delegation *delegation)
 {
-	if (delegation->cred)
-		put_rpccred(delegation->cred);
 	kfree(delegation);
 }
 
@@ -31,7 +29,18 @@ static void nfs_free_delegation_callback(struct rcu_head *head)
 {
 	struct nfs_delegation *delegation = container_of(head, struct nfs_delegation, rcu);
 
-	nfs_free_delegation(delegation);
+	nfs_do_free_delegation(delegation);
+}
+
+static void nfs_free_delegation(struct nfs_delegation *delegation)
+{
+	struct rpc_cred *cred;
+
+	cred = rcu_dereference(delegation->cred);
+	rcu_assign_pointer(delegation->cred, NULL);
+	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
+	if (cred)
+		put_rpccred(cred);
 }
 
 static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_state *state)
@@ -166,7 +175,7 @@ static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *
 	int res = 0;
 
 	res = nfs4_proc_delegreturn(inode, delegation->cred, &delegation->stateid);
-	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
+	nfs_free_delegation(delegation);
 	return res;
 }
 
@@ -448,7 +457,7 @@ restart:
 		spin_unlock(&clp->cl_lock);
 		rcu_read_unlock();
 		if (delegation != NULL)
-			call_rcu(&delegation->rcu, nfs_free_delegation_callback);
+			nfs_free_delegation(delegation);
 		goto restart;
 	}
 	rcu_read_unlock();

--=-uAbj9Yeafew4w7bjZykd
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--=-uAbj9Yeafew4w7bjZykd
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-uAbj9Yeafew4w7bjZykd--
