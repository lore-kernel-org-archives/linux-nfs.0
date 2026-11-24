Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795539400;
	b=tn2H6IddjlysroOvWYKh/g5/WV1hAuZb8NJwhOvC4oJmcNxHa0MCYGUz/7YZMjarzl4L
	 ooYLyTgGnd8nTlytu7dWW0qCfyb98kwkcJtYL3pTzcuuM+maurPJzOFBzNGtaVDZRHtqa
	 ydml0u6cX4k+QDuwUp/f+LGzaVbStgSa4jA99FbBcWhAPORyd9U+zGIWyS3n+1M9UjT1J
	 B49RKCQGl4gZfwZcVyoWXI9lWbMYIyx9VofBTkOSTB0ozkBgeW/RWcRCggu0asW0P+mE2
	 ADNzOceoInqCKWOUhJ386IZWU3ajF5I/C1bRD1ut4mcO8nIrXksBHwXh85pX+ICwoxQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795539400;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=qhxOXXFZ0iFZgMtxr8bKuOyibgt1tlrxvRTZg6/cDpM=;
	b=rKNRuWVN8JKvIm20qeZf5SVmgL4Mk1/mHiIPKKQjsq7YTpLkW70fYa4RkwvrhBxqyaBW
	 IykyILrZNlvT5s04KzzWd3TCiwyEqRFomfcg9Y99zrynXxGAUbCY+0sVYJEad++csCgEb
	 tg9RrEQ+sfyOIcHSgurfTGYYIvxJgqxTf8Y/2o5ngEQvGZEljW/iVuBQjfWDJwGRd28aq
	 QzvrAaWHjFs3oT4DauC/J6Wmf2TIYFkif3e59Xxx8aLY76KGXDX37JbDZETEdM+Me0Ckq
	 gwcg2WQuop+bEp9gNx9XJehtIavEB/EdTqb+JNKKsH3mQIQn6ObJ/26Zlh7zXyBfzNQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lciNhcqy;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FEB5606A33C
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 16:56:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lciNhcqy
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7C1231F000CA;
	Tue, 24 Nov 2026 16:56:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795539399;
	bh=qhxOXXFZ0iFZgMtxr8bKuOyibgt1tlrxvRTZg6/cDpM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=lciNhcqy+2x9lkztYKu4Asji27wAvtheFi2JsqqNhZec4neS1ksQPSDLXO5YnHOSp
	 a5FU9SxjYjtYFDyN+6nQvBl6D3aVAxVMsknN8MhxEDLgSONLKLMa47J0UduvC60baZ
	 hMGqM9QREqc/O2aBVeBY0IN+bqHKfdU6tiKxzd0tOXtBwVacnz2ItIheUYsGl//k4Q
	 //WrXk7C03fiig7YCClBvAp5iLm8HRrYzAod83V4k/8dAvdVwfX3N9mlwc6305QsD6
	 63gEDlwujz5sldJ9RlgBBfr8QBQU1z1b1BvqTO8vDDcq+NlL5JLCN77MOOV3d2Xs5f
	 vVtqE/mx+9wEA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id C3516F40066;
	Tue, 24 Nov 2026 11:56:37 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 24 Nov 2026 11:56:37 -0500
X-ME-Sender: <xms:xcEFaxT8iLiHmwu699nsiUTM9zDwCjDjbrEIStCOZ3N6QXE0QjYmJQ>
    <xme:xcEFa1kgzDopqJRYjMCFw48BqG3zpGSGD9ZDLosSFXq0B2G_MVC7wCPTCvof09-an
    ZyomVLFKZkkxyxGHDWm4Z9Dy1q9dmZ1V58j0WNBLVFWQ6__79OIM-Gm>
X-ME-Proxy-Cause: dmFkZTF2VPGdT3hwcSDfWSc5JZX9KcZ0BchKoqOJPVYsgmirjUgvIp4kLlb9X2f0DBd3KZ
    Fb25azhflb3Ei9Kc2zitmQR5FVbMvNPcKm3yoqR/+Z5HTFogksQxZjzkb3QI4GIYUhmNId
    aRm+EfHXNnWTSWXfGrjzrUYJsOTApRtU7T6c8zPIRHWMfZggP9jCWubUYCPBnUsDDRe9GZ
    nMpiDfw0WMDr4wsPT9OjHQgMpWz8qxgWARSgxj66PdCMe6dxvRinrzVXh2XTqb7N0mOT73
    P4h3z1oFQNGk4ieat+e83I/RKEiUwpyFP4gK3T6dFnR6hHzoUwW76XZbO59J/van0/Q/es
    2E0oBgXuPe1CP/kiu2VPQ1ccJw9DxpalTO2rgrYjK/FIHulSmdjKa/M2JqVmIjhNjbrZhA
    RWtJEKcO33xvTqRKyCfDx5U3j3J8DJlUL4AYhNOaKglY20SkFNl9sWcuu8/DAJCvzBQCFS
    /2DRUcW9KeWZVrAvECcL6d2CSndStrtlFyWWjJko3JFiDgMfltVSwvkRWxSfx9ndghm6PH
    Ah1q04sM1vM9Zsyuu+wpfrypiFxxFJ/XlMekFaNYTVe9dVvp9g+QJGyPH+4s28eE+hSc85
    w3XWtwIkr/jDmtZ7ga35jYkEmRNHsIJM/Fd5o7Fhf64/WcZF4JzeSSvLFYZg
X-ME-Proxy: <xmx:xcEFazgwJgPvFtsLuu8tlCD8WS2enSgzj-wfogdi5mG7PKEPKrw1-w>
    <xmx:xcEFa8ZXFeuf5EZdfZ5po-zoI0ZrnX0-hnn_K2H7qnUo8WsoUvXkog>
    <xmx:xcEFa3jUNSZ0MCSJEQd4S7GuDIA4dCKidFLQvEk2h1Uf6XaFc9Stjg>
    <xmx:xcEFa-ZbpBeyb0Q3TSGgNjAYGrExt3MahJfbl2u26yn0BnfMtyHNsw>
    <xmx:xcEFa9NkWpTEWACW44cc5JkIfZ6mxaotze9UKH3TNsHX8AzxExGobPVF>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A212F780070; Tue, 24 Nov 2026 11:56:37 -0500 (EST)
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
X-ThreadId: AqqI4B7Q9Jis
Date: Tue, 24 Nov 2026 11:56:17 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Li Xiasong" <lixiasong1@huawei.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, linux-nfs@vger.kernel.org,
 linux-rdma@vger.kernel.org, stable@vger.kernel.org, yuehaibing@huawei.com,
 zhangchangzhong@huawei.com, weiyongjun1@huawei.com
Message-Id: <aa51ee58-3404-494b-bbdc-2f9b6a6a7cd6@slotpi15m67>
In-Reply-To: <20261124021842.130141-3-lixiasong1@huawei.com>
References: <20261124021842.130141-1-lixiasong1@huawei.com>
 <20261124021842.130141-3-lixiasong1@huawei.com>
Subject: Re: [PATCH v3 2/3] rpcrdma: Serialize removal callbacks with unregister
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 24 Nov 2026 10:18:41 +0800, Li Xiasong wrote:
> @@ -195,9 +214,17 @@ static void rpcrdma_remove_one(struct ib_device *device,
>
>  	mutex_lock(&rpcrdma_device_mutex);
>  	set_bit(RPCRDMA_RD_F_REMOVING, &rd->rd_flags);
> +	xa_for_each(&rd->rd_xa, index, rn) {
> +		struct rpcrdma_notification_release release = {};
> +
> +		rn->rn_done(rn, &release);
> +		if (!release.release)
> +			continue;
> +		mutex_unlock(&rpcrdma_device_mutex);
> +		release.release(release.data);
> +		mutex_lock(&rpcrdma_device_mutex);
> +	}
>  	mutex_unlock(&rpcrdma_device_mutex);

AFAICT the release hooks now run one at a time inside the walk. A
hook that blocks holds off rn_done() for every registrant after it.
Before this patch, rpcrdma_remove_one() notified every registrant
and then waited once.

A client hook can block. When its xprt_put() drops the last reference,
xprt_destroy() waits for XPRT_LOCKED. If the connect worker holds that
bit in rpcrdma_xprt_connect(), it is waiting on re_connect_wait with
no timeout, and only a CM event from the peer ends the wait. 3/3 wakes
re_connect_wait from rn_done(). A connect worker still resolving the
address or route has not registered its ep yet, though, so rn_done()
cannot wake it.

On iWARP, waking the connect worker does not release XPRT_LOCKED
either. iw_cm_connect() returns with IWCM_F_CONNECT_WAIT set, and only
the provider's connect reply clears it. destroy_cm_id() waits for that
bit. The woken worker goes on to rpcrdma_xprt_disconnect(), and the
rdma_destroy_id() call that 3/3 adds to rpcrdma_ep_destroy() blocks
until the peer replies or the provider's connect timeout fires. A
release hook waiting on XPRT_LOCKED waits that long too. One stalled
transport should not delay the removal notification for all the
others.

Can rpcrdma_remove_one() call rn_done() for every registrant first,
and run the release hooks after the walk finishes? The hooks would
have to be collected somewhere, because a registrant can unregister as
soon as the mutex is dropped.


> @@ -289,12 +289,30 @@ rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)

[ ... ]

> +	/*
> +	 * Pin the transport while the removal callback runs. Release the
> +	 * reference outside rpcrdma_device_mutex: a final xprt_put() can wait
> +	 * for the connect worker, which may need the mutex to unregister.
> +	 */
> +	xprt = xprt_get(ep->re_xprt);
> +	if (!xprt)
> +		return;

xprt_get() pins a transport whose refcount has reached zero but whose
memory is still allocated. It does not help once the rpc_xprt has been
freed. At this point in the series an ep can outlive its rpc_xprt.
The ESTABLISHED event takes an ep reference that only the DISCONNECTED
event drops. When the put in rpcrdma_xprt_disconnect() is not the last
one, xprt_rdma_destroy() goes on to xprt_free() while the ep is still
registered. If the peer does not respond to the DREQ, the ep stays
registered until the CM gives up. A device removal in that window
calls xprt_get() on freed memory. I have not reproduced this.

The xprt_force_disconnect(ep->re_xprt) call this patch replaces has
the same problem, so your patch does not introduce this issue. 3/3
closes this window by moving every ep put out of the CM event handler.
But "Pin the client transport during its callback" in the patch
description promises more than xprt_get() provides. Let's reword the
description or note that 3/3 is what makes ep->re_xprt safe to
dereference in this callback.


-- 
Chuck Lever
