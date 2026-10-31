Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793455298;
	b=1DaZ+SErBuJ45j+dYIJO8R9FtfOCyNjaBEPN/A6+iJDL1851eKAUHMMXcpn+hUd3Lwl8
	 IeL9yLwaxMkCZGysgY7mPutV5lfFih10m1yGFt7QHniEtqI1OzFP/O2/j7cCF+E88WOrF
	 30rRD0vqZpL/NnM904VdpL2er2cvvJy6jqAN+gVr5MxrbrUak7nVo07FuCLr9cGZUNL/p
	 ZNbYO9N5gYoldMIK4eP5sbZbOa3j+Rqe+grrlZ5GwZSOeHLXlT71FEjq/HavKS2zuZz5+
	 MgLiGG3R56TFvNCv415Qo0tK2Wq8eGOYpYvXUwpeu7MeR3DHbPEqmx6D2r7e/HAhQgA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793455298;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=qlxETbMEjoAzP8XM9VVKvs0aq198sYaqIYGCvv4J8aM=;
	b=k8ag9YNUi69e8P3as+dbAeG5zxrRAXmczX4mcnjaYeK9Jqt0xMOnIywr5PwAolAJ7WBp
	 O3+VOQ3uA1mcTs4JtvLum8n/7pfbzIetLTgg1LtgBKbpCdBM6it5a3hSpAaMHF9mtTeIS
	 BQOGwKfIB9UQInL7vt8n/c3VUrgEdrbYuXcm1zHzZIe/GRERkdIdAvpBuTQvs/8DYyEIS
	 hp7JP9EVh8xgJDHnwhNmtgtj5xhAYSpKsScG6ZCd3qtHHe9b7tyFaFQtKFjT9Eaa1Zb0z
	 EtX8NaB4V+GXGuDdG1jnazjtFVjaWVL0pXd3WVxZWl1f67lElDaRzm0/N84Q37YHkeQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KdSrTV0T;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C278A606A31C;
	Sat, 31 Oct 2026 14:01:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KdSrTV0T
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C8FF41F000C1;
	Sat, 31 Oct 2026 14:01:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793455297;
	bh=qlxETbMEjoAzP8XM9VVKvs0aq198sYaqIYGCvv4J8aM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=KdSrTV0TE1H6slCwCQjATUxv7oux6CVS9eVctew258Dmcjegqamx6DhOKaek6YzFs
	 xBxRNY18yOVZ3RHuZBcDMek+X8c5hdnxrqawwfGMD4832U11RBYWP+4032cmoVj26u
	 0YnkbdbuJHDpNPUSVd3F9k8l/QvaG1TAbLcK0oChMB1q3+Acx4fSAMwiQVBjcNDurF
	 0dy2nNM1Y/UhxISbWUbeoXAFrE3GfdsUjT6MGM5/x3KrPqo4Hf0GvhpfO5zKcQbjxV
	 2BuL0r1SGZwKnym7QIg04LiiouM2wyNiJMX6uCwyRVK9jSAgIFk8cEJgLCMlzs4F6i
	 F8qAkJTEj3GOQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 1000BF40066;
	Sat, 31 Oct 2026 10:01:36 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 31 Oct 2026 10:01:36 -0400
X-ME-Sender: <xms:v_Tlaib5Yib547iuUSIk_ndMzf-YUuNLv4KofcaWK3M_kU2mcq7ihg>
    <xme:v_TlagMNk8KwMFDpqaW4g5RiQaMMuMA9pGGLJYZL_kT27ayojOIN2LXxW4wTAscPB
    gbokRTDjvXrnRI_k2JwYMpH-Ve-RTI7dltMrFrylWXMJ9dTmn0anQ>
X-ME-Proxy-Cause: dmFkZTFbnwXPtfUJ8TOIh/2YtHnqlVp+wY0Lc4pIVwZ1MqbZW4KTXu1pZrx7Cd5LCrmRK+
    RbTH7wiFeWIi0ZG4+rSLatRSXg8soJu9J/dLSesI0u+30a1VP7fSze3kiaUkq4gpKh8E4O
    k6Q6k1X3ZjO8gir323OR58KtmV+AA/xCHwEjyiAPe/8kZSqbhgiDVVcCpSCD84A1azOBTN
    G3KtwfoWQyMQLEW64q7hWp35tZTyc186DhYS5g6bgc1vdTC5Cw2ariX2I06hpIt0iuptba
    bXpTLGH5dv92jLOYf8EjurjZpgFS3fY6vfFnGfZpYCN8ZvZXnGnB1+AMIEaCn0ssv7eMdE
    kerMulL04F/rsVFIEiYbns6xnND+DzfPuPgjoUUFA0sgmvCvI4duSn8bMiyjbPKXkk6VE3
    /f6GHFWd7/7t4s99SxZmhWT4NTFE2ir+w5VKVK7WNS4SRw868jkrTnS/R0ZGOBIVglqcu5
    +uPFnzUfMbko2OBM6v2V5QFkyC/VhtAqDfSVHJISEkgdy6nvIaOYVf1iusxmcjrrTeHz8w
    b8Hj3PTEydvOMAvP+b8Z31c67aU3pJ2gncUX86ypRLjPb/ZaRauPy1ADNpW5JsW8n0w7pp
    GXz1nzZj/dV5K8oaK27A2FZSZ+iJ16spTklrHvzuDXOIZA7FouoBh/9sjLeg
X-ME-Proxy: <xmx:v_Tlaj3GHLzRa0W6w_2BixaYdWX1qGD7bO88XnmGbQPok7ChaWWAHw>
    <xmx:wPTlas9Rkw4-mx2GbL09dK75cjOJc2uyB09TwzcI-U7nsfqs-y8t4g>
    <xmx:wPTlauEadE4JQrLU4vqppEzPDoX5M3G6200z-Hb2KYLXVRwT44Ximg>
    <xmx:wPTlaqjVAG2yA_DRkagNKsHPKobQGDyLlhjQ0fNG9goENFvBTIg-0A>
    <xmx:wPTlar9maAxbWeGYJdB5f85BK3jCzq-wMvhYVySOLBENkaoE4u9mvT-R>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id CE4E878273B; Sat, 31 Oct 2026 10:01:35 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: Am0AR9z1Vk8F
Date: Sat, 31 Oct 2026 10:01:15 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>, "Kal Cutter Conley" <kalcutterc@nvidia.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@kernel.org>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <44664d64-3694-49d1-ad17-ca70221ed327@app.fastmail.com>
In-Reply-To: <179340033904.269288.4611945330659974906@noble.neil.brown.name>
References: <20261030130629.103716-1-kalcutterc@nvidia.com>
 <179340033904.269288.4611945330659974906@noble.neil.brown.name>
Subject: Re: [PATCH] sunrpc: fix lost wakeups when stopping service threads
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Oct 30, 2026, at 6:45 PM, NeilBrown wrote:
> On Sat, 31 Oct 2026, Kal Cutter Conley wrote:
>> Stopping NFS can leave rpc.nfsd 0 in an uninterruptible wait with
>> this stack:
>> 
>>   svc_stop_kthreads [sunrpc]
>>   svc_set_num_threads [sunrpc]
>>   nfsd_svc [nfsd]
>>   write_threads [nfsd]
>>   nfsctl_transaction_write [nfsd]
>> 
>> SP_NEED_VICTIM and SP_VICTIM_REMAINS remain set while all remaining
>> nfsd threads sleep in svc_recv() and none has RQ_VICTIM set.
>> 
>> The stop request is published with unordered set_bit() operations.
>> svc_pool_wake_idle_thread() checks the idle list and task state before
>> calling wake_up_process(). If it sees an empty list or TASK_RUNNING,
>> it skips the wakeup and its memory barrier. The requester can therefore
>> miss a sleeping worker while that worker misses the stop request.
>> 
>> Order work publication before both lockless checks, even when no
>> wakeup occurs. Pair with set_current_state() and llist_add() in
>> svc_thread_wait_for_work(), so the worker observes the pending work or
>> the requester observes the idle worker and wakes it.
>> 
>> Fixes: 60749cbe3d8a ("sunrpc: change sp_nrthreads from atomic_t to unsigned int.")
>> Signed-off-by: Kal Cutter Conley <kalcutterc@nvidia.com>
>> ---
>>  net/sunrpc/svc.c | 9 +++++++++
>>  1 file changed, 9 insertions(+)
>> 
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index af8d87c1de83..f3cc63acc5e1 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -29,6 +29,8 @@
>>  #include <linux/sunrpc/clnt.h>
>>  #include <linux/sunrpc/bc_xprt.h>
>>  
>> +#include <asm/barrier.h>
>> +
>>  #include <trace/events/sunrpc.h>
>>  
>>  #include "fail.h"
>> @@ -693,6 +695,13 @@ void svc_pool_wake_idle_thread(struct svc_pool *pool)
>>  	struct svc_rqst	*rqstp;
>>  	struct llist_node *ln;
>>  
>> +	/*
>> +	 * Order work publication before the idle-list and task-state checks,
>> +	 * even when wake_up_process() is skipped. Pairs with the barriers in
>> +	 * set_current_state() and llist_add() in svc_thread_wait_for_work().
>> +	 */
>> +	smp_mb();
>> +
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
> We could do
>    atomic_long_fetch_or_release(BIT(SP_NEED_VICTIM), 
> (atomic_long_t*)&pool->sp_flags)
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

Kal's patch as written adds an mfence-class instruction to every transport
enqueue (a common case) for no ordering benefit. So let's go with Neil's
proposed solution. Kal, can you send a v2?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
