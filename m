Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.108.3.11
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793407636;
	b=I8KAHAvJl7zIX5e84Cl+Rz6HuTT6C05fEI43/8keno1JJqoYXwEXXU5zF9qR0KgJvFY5
	 fQ7jLzRAkpxhYl34f9S/4uTvhrJWUYHDb8eFIrH5zLwf4Gh+T0Cl3X0exIMls+p20GoC/
	 F83E5t8Px4Ry2zx8VBMAgwdL44P6oDg8AH6fnHu+OSk6dNr/hqIKFOAqgdFppn3FAx/yN
	 352QjOXR/SYzv2zWooePSAoR5/KROZ7KA+6lKyn4N70f+wlf0bnKxLCtUd8yF/B1XU928
	 tJqcxIGwO+96LVQiGOLGHrkEtig0cOoTLKde3v9EYPUJEzcOM70yOhPviz/t5swH2Ww==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793407636;
	h=DMARC-Filter:DKIM-Signature:X-SMAIL-HELO:Received:X-Sender:X-Auth-ID:
	 X-SMAIL-MID:X-SMAIL-UIID:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=UCvegi+i1apDZdVVmEmHCl1vJCt7SNjmj4csEy7A/78=;
	b=TYguqLWMWbNwcH+ikOqO9z+/f61Jq2YspASwhROsNLs31C2bpGk49zHK6gX7CqJb4Wjg
	 nfgf54UhRyR1DIEprCobp2mrXnXF7LVmbREWc3M08DkzmyAI8cVY5Yu9UoT9ENAYoqHTr
	 mIcWg+GTmM4DULHQNcVfHUhERywbU0Qi65s+4dz3DGvYEsFIAAxZ9wOiZ6z7JG2hv9yF3
	 y1z8nzLgZQMYEyxt4IhTOWZ2KpH+b/HcSh3/qetnkhSgmbx0CJsH6B/wfdRgie7Lo+oyt
	 +B7qTj5Si+hOcEydJhErB+TpFN5XzNP2VQ4D7xKrUweQRWl2VceLjurrwbvP/OKnLug==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sina.com;
	spf=pass smtp.mailfrom=sina.com;
	dkim=pass header.d=sina.com header.i=@sina.com header.a=rsa-sha256 header.s=201208 header.b=DCJRq68V;
	arc=none smtp.remote-ip=202.108.3.11
Received: from r3-11.sinamail.sina.com.cn (r3-11.sinamail.sina.com.cn [202.108.3.11])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 394BD606A323
	for <linux-nfs@vger.kernel.org>; Sat, 31 Oct 2026 00:47:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 394BD606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sina.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sina.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=sina.com header.i=@sina.com header.a=rsa-sha256 header.s=201208 header.b=DCJRq68V
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sina.com; s=201208; t=1793407634;
	bh=UCvegi+i1apDZdVVmEmHCl1vJCt7SNjmj4csEy7A/78=;
	h=From:Subject:Date:Message-ID;
	b=DCJRq68V4I5T8V0jDpOrzk+Gk7RThJFghIsvDPtRjz85voPb1Omf2S4MCc53V2e2i
	 aAhpRqgKErC2NFazQ16n9H8m/yfRCVy9g6JeJZAf5Tvc65/Jg+lWhrs1InXmxUEWbz
	 e7m1DEgtEDlHVJ6LSlosjgSvW9TQjbMUWoHz06E0=
X-SMAIL-HELO: localhost.localdomain
Received: from unknown (HELO localhost.localdomain)([114.246.236.199])
	by sina.com (10.54.253.34) with ESMTP
	id 6AE53A860000686A; Sat, 31 Oct 2026 08:47:05 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
Authentication-Results: sina.com;
	 spf=none smtp.mailfrom=hdanton@sina.com;
	 dkim=none header.i=none;
	 dmarc=none action=none header.from=hdanton@sina.com
X-SMAIL-MID: 8196726291870
X-SMAIL-UIID: EE7AC67ADAD14D6B94E3B3DDB2C746CE-20261031-084705-1
From: Hillf Danton <hdanton@sina.com>
To: NeilBrown <neilb@ownmail.net>
Cc: "Kal Cutter Conley" <kalcutterc@nvidia.com>,
	"Chuck Lever" <cel@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sunrpc: fix lost wakeups when stopping service threads
Date: Sat, 31 Oct 2026 08:46:56 +0800
Message-ID: <20261031004657.251-1-hdanton@sina.com>
In-Reply-To: <179340033904.269288.4611945330659974906@noble.neil.brown.name>
References: 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Sat, 31 Oct 2026 09:45:39 +1100 NeilBrown wrote:
> On Sat, 31 Oct 2026, Kal Cutter Conley wrote:
> > Stopping NFS can leave rpc.nfsd 0 in an uninterruptible wait with
> > this stack:
> > 
> >   svc_stop_kthreads [sunrpc]
> >   svc_set_num_threads [sunrpc]
> >   nfsd_svc [nfsd]
> >   write_threads [nfsd]
> >   nfsctl_transaction_write [nfsd]
> > 
> > SP_NEED_VICTIM and SP_VICTIM_REMAINS remain set while all remaining
> > nfsd threads sleep in svc_recv() and none has RQ_VICTIM set.
> > 
> > The stop request is published with unordered set_bit() operations.
> > svc_pool_wake_idle_thread() checks the idle list and task state before
> > calling wake_up_process(). If it sees an empty list or TASK_RUNNING,
> > it skips the wakeup and its memory barrier. The requester can therefore
> > miss a sleeping worker while that worker misses the stop request.
> > 
> > Order work publication before both lockless checks, even when no
> > wakeup occurs. Pair with set_current_state() and llist_add() in
> > svc_thread_wait_for_work(), so the worker observes the pending work or
> > the requester observes the idle worker and wakes it.
> > 
> > Fixes: 60749cbe3d8a ("sunrpc: change sp_nrthreads from atomic_t to unsigned int.")
> > Signed-off-by: Kal Cutter Conley <kalcutterc@nvidia.com>
> > ---
> >  net/sunrpc/svc.c | 9 +++++++++
> >  1 file changed, 9 insertions(+)
> > 
> > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > index af8d87c1de83..f3cc63acc5e1 100644
> > --- a/net/sunrpc/svc.c
> > +++ b/net/sunrpc/svc.c
> > @@ -29,6 +29,8 @@
> >  #include <linux/sunrpc/clnt.h>
> >  #include <linux/sunrpc/bc_xprt.h>
> >  
> > +#include <asm/barrier.h>
> > +
> >  #include <trace/events/sunrpc.h>
> >  
> >  #include "fail.h"
> > @@ -693,6 +695,13 @@ void svc_pool_wake_idle_thread(struct svc_pool *pool)
> >  	struct svc_rqst	*rqstp;
> >  	struct llist_node *ln;
> >  
> > +	/*
> > +	 * Order work publication before the idle-list and task-state checks,
> > +	 * even when wake_up_process() is skipped. Pairs with the barriers in
> > +	 * set_current_state() and llist_add() in svc_thread_wait_for_work().
> > +	 */
> > +	smp_mb();
> > +
> 
> I don't like this.  Stand-alone barriers are, I think, harder to read
> than barriers combined with operations, like smp_load_acquire() or
> similar.  And this one seems quite detached from anything.
> 
> If I understand correctly, the possible race is between
> svc_thread_wait_for_work which includes:
> 
> 		llist_add(&rqstp->rq_idle, &pool->sp_idle_threads);
> 		if (likely(svc_thread_should_sleep(rqstp)))
> 
> and svc_stop_kthread which includes:
> 
> 		set_bit(SP_NEED_VICTIM, &pool->sp_flags);
> 		svc_pool_wake_idle_thread(pool);
> 
> The first sets ->sp_idle_threads.first and then checks SP_NEED_VICTIM
> and the second sets SP_NEED_VICTIM and then checks
> ->sp_idle_threads.first.
> 
> So we need barriers to ensure the values are seen is the expected order.
> Have I missed anything?
> 
> llist_add() always calls try_cmpxchg() which is fully ordered, so no
> extra barriers are needed there.
> 
> There is no barrier between the set_bit)( and the READ_ONCE() in
> svc_pool_wake_idle_thread(), so you added one.  I agree that is correct
> and solves the problem.
> But it is only this call to svc_pool_wake_idle_thread() that needs a
> barrier, not all calls.  So I would prefer the barrier went in
> svc_stop_kthreads().   Do you have a reason for not including it there?
> 
> We do need a full memory barrier - a "release" on the set_bit and an
> "acquire" on the test of ->sp_idle_threads.first
> 
> I would be happy with smp_load_acquire(->sp_idle_theads_first) in
> svc_pool_wake_idle_thread().  I'm not sure it is needed though.
> 
> I would like set_bit_release(SP_NEED_VICTIM) in svc_stop_kthreads()
> but we don't have that.

It is on the way [11].

[11] Subject: [PATCH 1/2] asm-generic/bitops: Add set_bit_release()
https://lore.kernel.org/lkml/20261021095512.1345191-3-phasta@kernel.org/

> We could do
>    atomic_long_fetch_or_release(BIT(SP_NEED_VICTIM), (atomic_long_t*)&pool->sp_flags)
> but that is ugly.
> 
> So I think the best solution is
> 
> 		set_bit(SP_NEED_VICTIM, &pool->sp_flags);
> 		/* Order SP_NEED_VICTIM before testing sp_idle_threads,
>                  * matching svc_thread_wait_for_work() which orders
>                  * setting sp_idle_threads before testing the bit
> 		 */
> +               smp_mb__after_atomic();
> 		svc_pool_wake_idle_thread(pool);
> 
> We probably need the same in svc_wake_up() after the set_bit().
> 
> Does this make the barriers easier to understand?
> 
> Thoughts?
> 
> Thanks,
> NeilBrown
> 
> 
> >  	rcu_read_lock();
> >  	ln = READ_ONCE(pool->sp_idle_threads.first);
> >  	if (ln) {
> > 
> > base-commit: b803428098f6fcd584db9f0499217b80e465bb34
> > -- 
> > 2.53.0
