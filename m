Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793664390;
	b=xLmXF0aKC/91ppmgFODI+P/AymzDxB1dGbzYC6iwHEFwWLMzqs5DyMmlxwQEankAJ5lI
	 Mo7JJCheXQmWWztFkbVG4PZ1ejmxjLqDaPlIJJEitu69KOPQB/K9L90MhAIcVTOEq33Ov
	 Iqb6PaFyfDdKXvF1QUcoC2qG1ZbWV1k5OORwsROeJjYd8vfc2/Kc4aBpR7peE7Olh1FXr
	 9XXQJ+miS9otS+O1su37CbbYJdgZkKkSyTRIM5OFgFYGt2Jc1uXDTmKtqswahsEwpTCnI
	 R6CJk8BVIUkeRWx+ffiQPomisZr3AfqlHf0KUfSb9xnhSUIvrR/RhFzDeR5fThP3d2g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793664390;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=yyaofbO1LBA3jJXlLCq+QmfJxp+UmzYZ0d2Ds1aVJSs=;
	b=5ckjkI5DNaQrixBLCmb7lQCmwGV0+q7olQejekVP9k6DNR7AkALKjD/7z0LegbYyhrHy
	 eQ03+Wyk9OhERHgIp1kNR7h7vf/xYgfZn4F4EvywIdYm8UWQXUjE+6DmgWLWbqrMJpNcf
	 4H70zgCfYrzSpjB+KRiv/GS78P+LW0RJEwhefyLQ5DYSjsBRGvzHJR7QV3lmdh4lVDuqn
	 //W4++DxJmwRAnGwlvDOQIjwtOuw8VfI/Ui6jMilURF/NcpCBhCBj/RG88ghqqIucMnXk
	 +kpCmcoqQyPx0CWwiJ0d0xlacsadnFbrDj+Zcez7fw3mK1klG/OVw3SKC7Y+AHlCZ5Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=Jf5xPeAE;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=htfp+WoF;
	arc=none smtp.remote-ip=202.12.124.144
Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 14302606A327
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 00:06:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 14302606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=Jf5xPeAE;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=htfp+WoF
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.stl.internal (Postfix) with ESMTP id 6062D1D00178
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:06:28 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Mon, 02 Nov 2026 19:06:28 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1793664388; x=1793750788; bh=yyaofbO1LBA3jJXlLCq+QmfJxp+UmzYZ0d2
	Ds1aVJSs=; b=Jf5xPeAEATC99T1P4pJqixYKKUPabJwcd6BsY0D8BuTdxx3FMuQ
	rRDXTiJE1q/vuAFA7LRPdylvH4xm/Xw5SylKFuYSqqsOZhDM2JArg6KhqXNtZ83+
	kApsrl0tqFdjgS+dWZ9hhbb/Y+99iQOvhaPa7ph3LSpjRopBQS7fZCOtEtOB+cpp
	jJqP+IQwZHr7QqWXQgGxj+V5vYBjFRKP47jXqPq5LgZzB2w8UgrTydlkp2Sjr/Aj
	E3JblkDKImRGrLXj3UEZX3y/rk9z99g1nVIQDBKmotgO9puJJtlmEB83qhkSt4lJ
	onOyxkwJOlzN49mIYkG2pqUUPreX3WM5opA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1793664388; x=
	1793750788; bh=yyaofbO1LBA3jJXlLCq+QmfJxp+UmzYZ0d2Ds1aVJSs=; b=h
	tfp+WoF11SnDxt/Gxp5SpFFiAHk/VuEiwvrTDAVRHf5K18oqLiJGxhgpPWAcJBYy
	rWmDo5uHnMU79+znHPqIYRXUXvX0rX2IzBapcnlLwzmEw/e4TFM1lmOHVMeEgaOR
	+Ol2NOZ/pZ0DtP6nqnJV9kuIj1ZTApo58+z0m5v6mkfYbtwQOoOgIKUuupedfwU+
	fRAY9NlxtduQ/+tSqotXTPEpPQzqGDKDzhhm2VCFfp3JHT+UlCIXZrJZthRT61la
	rOrv4TxXSere4zEqxBVUcRszhe+pN+RLZQBeAvqzC6rc7lLFyIoIGpNeT1ZUeiem
	7v8cXqA3oWrPxfSBorR5w==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793664388; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:TnJ7ySuOlAh3W3jCv+mY978FZZVyHtkZiRq9NmduBZrLqD1
	noKcCKk3JgFQtpkkearn884ljEZ0iv0RAHqEUQWQ2qb2IkNC9DbybTPdvkl/S2zy
	Qnnkfw0Ea3yojpdNUA6CkRKDwmT78qDed1yE7d8CIprjqyXCpXeICJl+bO8//dX4
	R8bFdbNId8WW9/dNrPgclLcUBUKTFmisANLxu2Lh0rgSY2qlW2BRO5lr/kBwe93/
	Sd4GrBi/3VhHpYZqa5Ryb2q4xVX+BkrW/nlsk0/xGICuJ0etUA96fqauTuGvH+K/
	OfvMMB9JwXScEzz794yKkXK9fz2UhlG/hWGrt9Q==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:dklhOffOaQJTuxqDCFFWJLMt1T+v+cevOGkLkR7nowY=:/g0Zcv3T6QmHaJPUgUetWS/VnF75sGdG4jLoaFGbuBk=;
X-ME-Sender: <xms:gyXpar6y8sFvZSCALH3z2pcuIY7rZFrk243v9oPB2HYMVvciaiba8g>
    <xme:gyXpastWZkDW2p0NVXhE0FIEY8y8NaGmlZDUjCQiqnNwzmU18yxG0R-RnKOc2ywro
    Qkrw904-C4flVQK6WSVMLutHlRP8fSwlmb7Als2VK6U32ws3cc>
X-ME-Received: <xmr:gyXpan-UN0r7AD4287uuhbUwR2Z_b9ok-NZwjX-1VmO9nYkEJHzUcmtedjb-Q5yXPoKKez07BxZjlq-xnqG580AQ7XEejOY>
X-ME-Proxy-Cause: dmFkZTGAvNPpkdBmLL2NbMWgsBGLNi9qwJiWELuyUZizI+Ie5naw16C56PCB1rX4OVGAZ+
    hUyb0II0WxOKlOJkUSsLka6a7tiSTLIMdGbW69c300mKt/urXg/t6hVFeeHjOZlSrUn8y0
    swt8/sXRYTw5aAMyuPorISsWjvLhgbdovRVnur1wAuuRxnLAujFzUzJ4mke9Da6TAJYsfa
    7yKjNDkZxUNDALSib0WP6+HtVlL0TPxbhEMlfkEbCiwfiERk9p2ziyZVq+ZxrCMOKD/vEX
    H60Lr0am98W3njnEPZgGpYRmtttxmzVx8DLhPXJgL6RMSBdeT04c0Qd3UFCpP3fWo0DSjs
    9Fgvx/HTnpGI2AVde92OjJV0KLonWwdWOAenTMq7c1jRjIqI/vg9g0eclsYe503Wk3cmyw
    m5a8gz0EVznJRtBI3f1F/WH6XIuUjq/+/saOz+Iqa7iCtAWudz7gdxiMTl1/AGczmF8ui+
    zhr3yJIhzwwKZAlqB3MIGjEtqs7KZr43FJkuwQbdVDhyS+okfr5d0HPVdopwBZBVlWzIF4
    yWuT1jB6ymswGkYNvniJJH2oU2prlxJOWrr8ecVBD0nRPYPFsVJatEP3haVIvPqBoqfApC
    6SL6ARf72yD9HuqF4VAOUPBk+u4/XRZHXxUW4egBc4nQosnjfo89uCciYcPw
X-ME-Proxy: <xmx:gyXpaulvJAZDSLB899qgG_-nVM_-s3bk1I4PV0gmj_VBi-tzWtlcgQ>
    <xmx:gyXpavNHQWSiQroWrohRk6Mjt8ziRp0L_acssh-pWD23IBs2oWwSdw>
    <xmx:gyXpalIyczRnoxuW6m-1J15YTjIF0OruFtjjBecfjrpKTgIyvljE5g>
    <xmx:gyXpaiGXEpA5e0NwFCSQETs0yGkmrWMf3az7DPaPZsDU19sIakS72A>
    <xmx:hCXpaqr4_fWw-r8VXrYMSR1vis0xnNCctoGZ2d3k4CzwsBdQPaDEuhV7>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 2 Nov 2026 19:06:23 -0500 (EST)
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
Subject: Re: [PATCH v2] sunrpc: fix lost wakeups when stopping service threads
In-reply-to: <20261102225358.414367-1-kalcutterc@nvidia.com>
References: <20261030130629.103716-1-kalcutterc@nvidia.com>
  <20261102225358.414367-1-kalcutterc@nvidia.com>
Date: Tue, 03 Nov 2026 11:06:19 +1100
Message-id: <179366437930.1728055.15983070911544727032@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 03 Nov 2026, Kal Cutter Conley wrote:
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
> Use smp_mb__after_atomic() after the flag updates in
> svc_stop_kthreads() and svc_wake_up() to order work publication before
> both lockless checks, even when no wakeup occurs. Pair with
> set_current_state() and llist_add() in svc_thread_wait_for_work(), so
> the worker observes the pending work or the requester observes the
> idle worker and wakes it.
>=20
> Fixes: 60749cbe3d8a ("sunrpc: change sp_nrthreads from atomic_t to unsigned=
 int.")
> Signed-off-by: Kal Cutter Conley <kalcutterc@nvidia.com>
> ---
> Changes in v2:
> - Move the barrier into svc_stop_kthreads() and svc_wake_up(), using
>   smp_mb__after_atomic(). This avoids adding a redundant barrier on the
>   transport enqueue path.
>=20
> v1: https://lore.kernel.org/r/20261030130629.103716-1-kalcutterc@nvidia.com
>=20
>  net/sunrpc/svc.c      | 7 +++++++
>  net/sunrpc/svc_xprt.c | 5 +++++
>  2 files changed, 12 insertions(+)
>=20
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index af8d87c1de83..76232774646c 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -29,6 +29,8 @@
>  #include <linux/sunrpc/clnt.h>
>  #include <linux/sunrpc/bc_xprt.h>
> =20
> +#include <asm/barrier.h>

I doubt this include is really needed, but I'm not sure that matters.

> +
>  #include <trace/events/sunrpc.h>
> =20
>  #include "fail.h"
> @@ -784,6 +786,11 @@ svc_stop_kthreads(struct svc_serv *serv, struct svc_po=
ol *pool, int nrservs)
>  	do {
>  		set_bit(SP_VICTIM_REMAINS, &pool->sp_flags);
>  		set_bit(SP_NEED_VICTIM, &pool->sp_flags);
> +		/*
> +		 * Order flag updates before the idle list and task state checks.
> +		 * Pairs with the barriers in svc_thread_wait_for_work().
> +		 */
> +		smp_mb__after_atomic();
>  		svc_pool_wake_idle_thread(pool);
>  		wait_on_bit(&pool->sp_flags, SP_VICTIM_REMAINS, TASK_IDLE);
>  		nrservs++;
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 076c624fe675..868e3da57b6c 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -632,6 +632,11 @@ void svc_wake_up(struct svc_serv *serv)
>  	struct svc_pool *pool =3D &serv->sv_pools[0];
> =20
>  	set_bit(SP_TASK_PENDING, &pool->sp_flags);
> +	/*
> +	 * Order flag updates before the idle list and task state checks.
> +	 * Pairs with the barriers in svc_thread_wait_for_work().
> +	 */
> +	smp_mb__after_atomic();
>  	svc_pool_wake_idle_thread(pool);

Reviewed-by: NeilBrown <neil@brown.name>

Thanks,
NeilBrown

>  }
>  EXPORT_SYMBOL_GPL(svc_wake_up);
>=20
> base-commit: 2d3259f652bb0f1d137ccabecac6763da05064ec
> --=20
> 2.53.0
>=20
>=20

