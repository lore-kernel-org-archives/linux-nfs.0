Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795539722;
	b=a4vmi8QhiIqmzZO8DP1RMqCEzM3nnjIY4cO1k+++ce/z8dfouQ35BULkncWT5fUw/gML
	 0ePKEwmwBQPYUwTTGg5xN8uo0oHjnWDu+p3QDAWItGhc/IrCmuIn7YpXSyCLzZ2812Wtp
	 /wJ5MDZMp0ID0Xur7j+ihqs7WyIdLhJRt4NU8xdnWhZO4a5adcgNYLPgc7QDDLXK31N4o
	 9fhHonG134pl3/fy7JojMTT6b6uY7XP2U4ND7BFZpEwNWcS2otVpPfXv4nMvnUaMNaTUt
	 Zub9CaM91qegZzDkDYXr0JUc52KnWnHXR6VYWugQZCYQRUXY8hy1tSoIs+2yeAJntOw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795539722;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=/YR2NdyGpQphRBfeuwhxgCxGzrHtOehNZjit7K3pY8Q=;
	b=KSu6d3+pPAFb4bzaMjaX/E37WNE+HpYMpzPU9qNaT5C//kLtisjX/unFkS0WPaWAi6xT
	 QYNkyZQ7r9EvOwNdgPIDYw+PBDX7PJNtmqe8okBGEUWPUJGBlgzomwmI2lqKMknCtM69D
	 fZ7jcc6LZPXq6Qmbm2cpOVhnhwLUr7pxmPJNWkiSzUZ/Mg3BTJ0Xnks0hEBu/g4Xlpovn
	 suhviKW36XpvIJ1L+9dSQOumOhfPIYHaJsejNbxr05fJtneDsDyyDpkVxHVpqjs91JysQ
	 9aDrdc8lIyG6pw4AxeWC01EEOwxjJWV3DspJbavlWPEpfm4itycoBvLJo9xswJPIezg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q6r7Kuur;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5268606A327;
	Tue, 24 Nov 2026 17:02:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q6r7Kuur
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1418A1F000D0;
	Tue, 24 Nov 2026 17:02:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795539722;
	bh=/YR2NdyGpQphRBfeuwhxgCxGzrHtOehNZjit7K3pY8Q=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Q6r7KuurGcYYmLIkXt/WJ7+8UUfu37x0nDZP8djVlQ041HlbCxMyn4Kl/nrlGvUX3
	 NAs3/l3Dfwq0YOGcnaCu8nvaue1VdNbeEQiQRD2c7L42qTbTaC9EjmTmZFx5kctAgM
	 vSkKeoj4P75ttUNdFDmJb7aaIUXB9HlPt9q/NkW1ar+Q+Ac9ZVcZbZkwf1yeM6VBgm
	 EKF+iI8MsWvaWljRiYWkLHQc726tHnkXbcno2VcKZHwIAiRq97cIh3BaZWtIimVVR0
	 nVuUF+eN4B/5UweKHOa7gDnrJ6wDI9P+mb91hUG3MGLTjZp5x+OtEgR3eYjsvW1WET
	 MzO3tCGlXWEyA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 47F03F40067;
	Tue, 24 Nov 2026 12:02:01 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 24 Nov 2026 12:02:01 -0500
X-ME-Sender: <xms:CcMFa6VhvKzWWezBDCEVI9-iNiaw_GtjfX_wen_jE6gXnPQn7jNhrQ>
    <xme:CcMFaxalmsFv48IzzzCDfQHyVQUa99_sK8AUfbrqyB8rpdyd_NI_4jGqX-gG6Eyjr
    HW7UCkRSKF5UnBgplSuNtB7OX8WhSqhqhXTRdVEgjZX8xcVeofysfgw>
X-ME-Proxy-Cause: dmFkZTFwXILTy4fQRfudKC0hWynHKvKwlza8s34nRlusPzeGPNvqBtaTo5l0TmHEx1Eu5e
    cIwjFljVodOPqo2gBfY/h05A8TwW/b1JFqT1+ptiF0pQxoQ2A+Qe/wVC1gyuqhRskXXytV
    X+SpdvMINxr8boRipFM6JVIyJSBEZwgqbmDrDXRC/mHxfLlQirs118vs006gGMqyG4dyMp
    F0uTz44+9j/Zod8N7si79U0pEkaqiS+dPPDDmzsws4/MDJ3xmf9O1rNqCqGZQ5fHgneyAA
    qSbBhZ1/JdJnb6dbVnZtVPD4q9gH3JboDauS/iK2U/Sl8Sac9TgCAQmRVgMv/vf/bNJyno
    fkzVieuKII/jw9eQ3uuCEEH2wHsd7ethpwCy47MVDl/wZsIQlJUkWSsYX2hdyemACPbnBB
    v0S5ckEvO3Kn5zbGLZrjV+mB1oTre18kZgpA+4mjKQLq/5PAaoGiDCOK08nItXQOAyNnay
    NpeQNwhenintVlBsGGfsN8samSJ9oZ1KXXerlkFLZZyPtCh3iANjJwqdBMzdxfpzebpi00
    TnQm8Y6MUmIpxOiRrm8xgR3uo9+1bwYTUp5sX+BvdwH9u+ENfRt4JFBU9kar7L1uQ7fmup
    b7Z1pcLMiJr6qmrESZ2y7g69g8AnVEx/e3WtjReZak/DmqkZeycLVaHu9Y2w
X-ME-Proxy: <xmx:CcMFazmMaSO0yDSxsO2ozkYPTgkjn6IK1ueRWu1DTfAEIvKjnz0gkg>
    <xmx:CcMFazNqWNvDK1Ow315AenCCN7ZoWWVnr1YwjlDRybLYdhkCG78_bA>
    <xmx:CcMFa-Gazjfw4O-qEbDK79ylh_xy_VhYq3l0bWqseg0F7_q4BiABMw>
    <xmx:CcMFa5ssv84Qzxa-B3OSpAKnGfN_lfOsh2jxKRipQStc4tAMzbLVnA>
    <xmx:CcMFa-TfI_9dq8GyDUiZPK4aefosCKMaclLq-0FxyOS7oOgEbl8TzedC>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 29F2678007B; Tue, 24 Nov 2026 12:02:01 -0500 (EST)
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
X-ThreadId: A_umGGPHPaig
Date: Tue, 24 Nov 2026 12:01:40 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Li Xiasong" <lixiasong1@huawei.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, linux-nfs@vger.kernel.org,
 linux-rdma@vger.kernel.org, stable@vger.kernel.org, yuehaibing@huawei.com,
 zhangchangzhong@huawei.com, weiyongjun1@huawei.com
Message-Id: <40af69a1-be6b-4afd-acba-2185a7ad832a@slotpi15m67>
In-Reply-To: <20261124021842.130141-4-lixiasong1@huawei.com>
References: <20261124021842.130141-1-lixiasong1@huawei.com>
 <20261124021842.130141-4-lixiasong1@huawei.com>
Subject: Re: [PATCH v3 3/3] xprtrdma: Wake connect worker on device removal
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 24 Nov 2026 10:18:42 +0800, Li Xiasong wrote:
> Device removal only forces a transport disconnect, leaving a connect
> worker asleep while re_connect_status is zero and blocking endpoint
> cleanup.
>
> Set -ENODEV and wake pending connects on removal.

On InfiniBand, waking the connect worker works as described. On iWARP
the woken connect worker goes on to rpcrdma_xprt_disconnect(), and
the rdma_destroy_id() call in rpcrdma_ep_destroy() waits in
destroy_cm_id() until IWCM_F_CONNECT_WAIT clears. Only the provider's
connect reply clears that bit. The worker still waits for the peer or
for the provider's connect timeout, and it now holds XPRT_LOCKED and
rx_unmap_rwsem while it waits.

On iWARP, then, this patch moves the wait from re_connect_wait into
rdma_destroy_id(). I don't see a way around that in xprtrdma. The
patch description should still not claim that removal unblocks
endpoint cleanup on every device type.


> The final endpoint put can free id->context before rdma_destroy_id()
> synchronizes with CM callbacks. Destroy the CM ID in the endpoint
> destructor before freeing its context to close this window. Remove the
> CM callback get/put pairs so final puts occur outside CM callbacks.

Removing the get/put pairs from the CM event handler also moves the
last ep put into rpcrdma_xprt_disconnect(), before xprt_rdma_destroy()
reaches xprt_free(). That ordering closes the stale ep->re_xprt window
I described in my reply to patch 2/3. Let's mention that ordering in
this patch's commit message, since patch 2/3 relies on it.


-- 
Chuck Lever
