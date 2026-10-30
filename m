Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.152
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793400355;
	b=tgdrZIzBitBe9xdOY7AUpupG9lK+tU0hmVGD515CucXj1rX2Be0ueNtkNAyJQSAlEyE2
	 9Y0fKn/pb/2o8fg5byjr5xJQDZJvBiL1kEXmphnGESBH49iPsCdN03EGXk/MvLtwqWpxU
	 I8bad9LjobqpRndj4oSuO8JUSXy45n9F6ilgNoSEtC0E7bnUtEzLwlFF1UrEzJKfUNiQN
	 YCFq5H9hqqjCFvIYuqtHb3wUHmuUvmaXaDji1vnfE0+PtoJH9+MWlgfwd/G0PGIoB6QWA
	 +YMUD8CFWXNISkXYv37ka04h65SHGGLC0ABrT7tFGc+ez/tk6uqmuJW6UKdSMvyFodg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793400355;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=0B8O7nu9f1oA8mtZ669QAgxW4AUmioLSCxqsLxGiP0U=;
	b=stQwIh+m4HeKL6Vd1NxzgQ1LRBT5aic/O/ycTd6OVf5uCME9TawaTBSrfRKN/TAcxhNO
	 l6hySJYKnAEnd1im0cknURcCuy+XgDaEKUyIBzOurb0D26n4Qb9NWgYuw+AqHo3iDmaf9
	 8wSL0Tp9TeypxS++I4GTxQMpNCm6cmJpyNW5NsUZIECvfUL9f0/PO3ADxq37xWTL6c7RL
	 YtyvLa3knWqlrJo+VtspOmy6QyzDMTYFI9mYOm5HBvxCWH+doo/8ZusZ1LDr/CwPlVU6a
	 CLWIhGYcS2yFkxMZpG1OAjCTR/ckmjaccyKVYLJAJ8ekLSsYOK2KYaEXMP595u69gow==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=RLnZSdWX;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=imNKQsTW;
	arc=none smtp.remote-ip=202.12.124.152
Received: from fhigh-b1-smtp.messagingengine.com (fhigh-b1-smtp.messagingengine.com [202.12.124.152])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67FD3606A31A
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 22:45:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 67FD3606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=RLnZSdWX;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=imNKQsTW
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfhigh.stl.internal (Postfix) with ESMTP id A2A8C7A00EC
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 18:45:48 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-03.internal (MEProxy); Fri, 30 Oct 2026 18:45:48 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1793400348; x=1793486748; bh=0B8O7nu9f1oA8mtZ669QAgxW4AUmioLSCxq
	sLxGiP0U=; b=RLnZSdWXklO+Dl2hB1PDqehMxnk3I51lzbjzPytoWS9xCjFA9fV
	MQx3N3RqieAIr4vjBtzsQTG+aohUO+J6RzAvzJcszeIcDlXiDhx7zgm0jqPEQuID
	Szrw0Huay946e2avB8uE4NSLfZeNNzSdSfwJoDShf3rUooJ4phG9AQUux2jD0PGA
	epKrmomaUqCZiAwXz/UnA03f6vPcy9oKx45QiJ/QtedwHyunREFJ+xbfuo0u60Wd
	7hfFFngjj/rvic/heSFunGpXyUhEBunmlLCwEWhna7TiDT6r9G+K6jXaYKL7VwU5
	mSpxkG5cmI27rSuJsQelmCWUHjdKw+1u7/g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1793400348; x=
	1793486748; bh=0B8O7nu9f1oA8mtZ669QAgxW4AUmioLSCxqsLxGiP0U=; b=i
	mNKQsTWMXZmUzulgqrFmEbjY81/LIz4JpcFmkB03Ln6T8IHtITkSQZSkL/045rO6
	GQdgkM0ki1gnCMB2c8GlXWVGG5HpfVcLCrQA4fnVBMJzJOSjwCJaz4WNa6htCMPw
	BjLf20xCKVEnihA+dW9eMAxsTaZXrPth6oY0CMgaQPEn2ECWLUuJwYPCB+s1in+z
	K05PcdyFGeQvBW5PebP8ovdXo7pw33DLWZYO4ANFSORCgkb268V1Yah1W1hzX9BL
	xkcqBQgsm9IwyE0FgXWN+/FTT/hwYAAANUlPEnXg6mOR6H6RyoWFf3ihIucDtMO0
	OJ2kNK3kx1DrRrmjId4HA==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793400348; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:PKUTeXXvelpP/eDN3z73xF1ggkeXFi8Xt+AiTGsFKOYO9MW
	d7LsATy18mxpKyFHk3ituBOfyCSI6qHDtl20gOfQdU9RuMImIRb3EvhAOPXzMhGP
	RASYrebbqHKL7S6fcIslbXDS+DQTnQ7UDHuEqA+PxLl6WWCX0RQk6/guiq5CaMKu
	hW1aHTvxF059swk15DPrekA6yQ6B2AC1q8qYNxY7vbu8GM0bKodYdWnOP42lWn4U
	0GWsztqUeZG5m6pbrOApRl2AO7DquARMvcXdmk7JglM9nQ3SaOLljowXti5gRmXp
	tSWGz6oUTdLzBhpsdMdxEDpdCIHET/tTlHxUZdw==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:6hS8kX8/2Y/Z02XsQ/S0GdyJ84NWRMwe7axxxaOjTNY=:ln1xf0CyP84OtQxdxCpn+k5tLttKTvxi8ap5isSNh3Q=;
X-ME-Sender: <xms:Gx7lamfFP_mfuzxUGs31fMhFiGpsD89uYDXoIuF6aQ6VpYLsK9j4DQ>
    <xme:Gx7lalz2KGzxldIGZbbOubnNLn4FlKwqlyWQpBEbOE3ZghM9rK5p4FjMT7Bf8_MHe
    cLXafqcplc9g_GNWkH_rbYBwXPePQ67c5Z88K4X3PlbjM-G0w>
X-ME-Received: <xmr:Gx7lahEV6dNd6QNAJZ3SLh9G0utdymFzsJ9N9xhMf_faIqdHSKItJWt1kop7KsJM6L4WCn_AJ4Dp1S8BTLFkrwMGo-qmjno>
X-ME-Proxy-Cause: dmFkZTENnjV24hxZOZ2AhqWYYvaUGnTJGIvJXMAM/HCP0jMhhBPFe17oUdYSKatVeqdPzZ
    Vpf2QikxTbrzIGvPM/XTu8ZdA0ZvVMjiSS8sTUT/UG0mF0QujI4xuz7+fDuJ5fTBeMOZk0
    kT32b7viec1SkGY98z0PRJepQN7PQw1ZBEsLFhS7Qavt9hRt19/navlj949D1uf/jv0Mqr
    9PwjMspBYtAkOteLu/NieyU9rupiM/H8tYIpKPslQ5IXfKTDPA6GCoTrpi1qm+RGexx32/
    zB+YItZ4XCdwtse0c4X6q5GMd9zWnFwtaQFTSKgeDMt4jl5mAOaDGjGZjz8hYGaUgva9oT
    J1H9fNRGhuYdB31gjto3Zjhemlf9hp3w66eNSTNeJOJ/i92vuY6qN7J2G0e3SYuccD2LaZ
    Fg0BNSr8Tymvkq4pMiseqGVLQnzkgVnRwmlQZwSNAeZNdG2Y90LOoqxjUazSlamHSVUemY
    A2HBRsKd1y0RVmnzGNZt4QM8s3WEk1BNBo7tIAVkP99LGGjcOnIK7QIp4pGGhI4qvILU5t
    kpnkaJQl9/0716DR7BMF143vlmB9Xp6YaXk8plsLI7gS/f2WqPD7p9Gslq28DfNV9jKzFH
    slzHq88UugB2KdDb2Fb/Y0XbLOJcA//KdfGkWuHfQBVhKtK4ohYPFWPpgnAQ
X-ME-Proxy: <xmx:Gx7lak18XawSA9qLkltB3cMfg6XV692L5nRUg8HkeSaEEj7iugQFeg>
    <xmx:Gx7lap82czRjD0aSai-Gy-5GXHxnKPQqwmd5saoxmdm5DGP6Ab_-KA>
    <xmx:Gx7lanFnG-Y30YA5hc7OmETIL3qVu9bC8Mx4unaftyRX8J4Q8_GDsQ>
    <xmx:Gx7lavjOxcLUTtrjQR5y1RaHo_h7J9MpDXR2MQt3K6mLIPvf5mk-jA>
    <xmx:HB7lakzguzV6FITwoQXyGzP9IxX1OkMztxcoHOS75Tg8a4Q2Efuv6sYa>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 30 Oct 2026 18:45:43 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Kal Cutter Conley" <kalcutterc@nvidia.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@kernel.org>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "Kal Cutter Conley" <kalcutterc@nvidia.com>, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sunrpc: fix lost wakeups when stopping service threads
In-reply-to: <20261030130629.103716-1-kalcutterc@nvidia.com>
References: <20261030130629.103716-1-kalcutterc@nvidia.com>
Date: Sat, 31 Oct 2026 09:45:39 +1100
Message-id: <179340033904.269288.4611945330659974906@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sat, 31 Oct 2026, Kal Cutter Conley wrote:
> Stopping NFS can leave rpc.nfsd 0 in an uninterruptible wait with
> this stack:
>=20
>   svc_stop_kthreads [sunrpc]
>   svc_set_num_threads [sunrpc]
>   nfsd_svc [nfsd]
>   write_threads [nfsd]
>   nfsctl_transaction_write [nfsd]
>=20
> SP_NEED_VICTIM and SP_VICTIM_REMAINS remain set while all remaining
> nfsd threads sleep in svc_recv() and none has RQ_VICTIM set.
>=20
> The stop request is published with unordered set_bit() operations.
> svc_pool_wake_idle_thread() checks the idle list and task state before
> calling wake_up_process(). If it sees an empty list or TASK_RUNNING,
> it skips the wakeup and its memory barrier. The requester can therefore
> miss a sleeping worker while that worker misses the stop request.
>=20
> Order work publication before both lockless checks, even when no
> wakeup occurs. Pair with set_current_state() and llist_add() in
> svc_thread_wait_for_work(), so the worker observes the pending work or
> the requester observes the idle worker and wakes it.
>=20
> Fixes: 60749cbe3d8a ("sunrpc: change sp_nrthreads from atomic_t to unsigned=
 int.")
> Signed-off-by: Kal Cutter Conley <kalcutterc@nvidia.com>
> ---
>  net/sunrpc/svc.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>=20
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index af8d87c1de83..f3cc63acc5e1 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -29,6 +29,8 @@
>  #include <linux/sunrpc/clnt.h>
>  #include <linux/sunrpc/bc_xprt.h>
> =20
> +#include <asm/barrier.h>
> +
>  #include <trace/events/sunrpc.h>
> =20
>  #include "fail.h"
> @@ -693,6 +695,13 @@ void svc_pool_wake_idle_thread(struct svc_pool *pool)
>  	struct svc_rqst	*rqstp;
>  	struct llist_node *ln;
> =20
> +	/*
> +	 * Order work publication before the idle-list and task-state checks,
> +	 * even when wake_up_process() is skipped. Pairs with the barriers in
> +	 * set_current_state() and llist_add() in svc_thread_wait_for_work().
> +	 */
> +	smp_mb();
> +

I don't like this.  Stand-alone barriers are, I think, harder to read
than barriers combined with operations, like smp_load_acquire() or
similar.  And this one seems quite detached from anything.

If I understand correctly, the possible race is between
svc_thread_wait_for_work which includes:

		llist_add(&rqstp->rq_idle, &pool->sp_idle_threads);
		if (likely(svc_thread_should_sleep(rqstp)))

and svc_stop_kthread which includes:

		set_bit(SP_NEED_VICTIM, &pool->sp_flags);
		svc_pool_wake_idle_thread(pool);

The first sets ->sp_idle_threads.first and then checks SP_NEED_VICTIM
and the second sets SP_NEED_VICTIM and then checks
->sp_idle_threads.first.

So we need barriers to ensure the values are seen is the expected order.
Have I missed anything?

llist_add() always calls try_cmpxchg() which is fully ordered, so no
extra barriers are needed there.

There is no barrier between the set_bit)( and the READ_ONCE() in
svc_pool_wake_idle_thread(), so you added one.  I agree that is correct
and solves the problem.
But it is only this call to svc_pool_wake_idle_thread() that needs a
barrier, not all calls.  So I would prefer the barrier went in
svc_stop_kthreads().   Do you have a reason for not including it there?

We do need a full memory barrier - a "release" on the set_bit and an
"acquire" on the test of ->sp_idle_threads.first

I would be happy with smp_load_acquire(->sp_idle_theads_first) in
svc_pool_wake_idle_thread().  I'm not sure it is needed though.

I would like set_bit_release(SP_NEED_VICTIM) in svc_stop_kthreads()
but we don't have that.
We could do
   atomic_long_fetch_or_release(BIT(SP_NEED_VICTIM), (atomic_long_t*)&pool->s=
p_flags)
but that is ugly.

So I think the best solution is

		set_bit(SP_NEED_VICTIM, &pool->sp_flags);
		/* Order SP_NEED_VICTIM before testing sp_idle_threads,
                 * matching svc_thread_wait_for_work() which orders
                 * setting sp_idle_threads before testing the bit
		 */
+               smp_mb__after_atomic();
		svc_pool_wake_idle_thread(pool);

We probably need the same in svc_wake_up() after the set_bit().

Does this make the barriers easier to understand?

Thoughts?

Thanks,
NeilBrown


>  	rcu_read_lock();
>  	ln =3D READ_ONCE(pool->sp_idle_threads.first);
>  	if (ln) {
>=20
> base-commit: b803428098f6fcd584db9f0499217b80e465bb34
> --=20
> 2.53.0
>=20
>=20

