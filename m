Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4B3191684B0
	for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2026 17:47:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782409625; cv=none; b=FSCxhudt5ZWBMsVuUvPene6zhugGcxeIuLEXaahcT5YtAtDu+LW1h+zyJ2UV7aMBjuZ3fk4zXJIVr6cd8ypHnNki4oN6TGhSbBgKFaFGgyekhLMYEoQFuZ1BGXct22DOVkB73D3AjtB98A2xb2RYB6ngX8u4h0y/Axapj9rJIUU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782409625; c=relaxed/simple;
	bh=cB6H0nN/Lw70LKeXaV+mrqvGgDNTkTZR5GboLybo9bw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=KCRjg0tlvgG7mW/7diWBCxd3OE2LbrRqBB7KINyLDQlj5Li3DeYjAbP5sQ0Cqm9AgzTWXA4DZ2SxS/WaxGaR4Yj7VkWvh8v4i1OJf5NBqQKPmbfwlWD1kU2VcMpfYjFUhfba/CkcHQPnVHwcrJjuKwLDSMQrMPQKJ+AYa//5h0M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=bHeQ6ZUg; arc=none smtp.client-ip=209.85.161.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="bHeQ6ZUg"
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-69dead44101so69241eaf.3
        for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2026 10:47:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1782409622; x=1783014422; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=+j0HUPyrwQkvTNXDQM/PgRSXJ9NkNOhG/0ux2wZgmu8=;
        b=bHeQ6ZUgxtx+d/EgWWWG+J2jPSxTQY1L6RSzRRhgwfE6rJnvXz9990YXDh3fY/S60y
         RWXSofFVTSfkPDymFpm3Zz/yHzNyPY6Fm3uGY5xkpj6K10fRHgGi0BECVLTuX4Bu88Q2
         5CTca57EkXYyz5dap4Xfcoi3cmURdot3bCfDWjNYsdIWP9u3479aj63knI3vS4DtiI/6
         FEzPg+qtF7WbJ7QbVh17pPMMFA+WsX0K926pFya7opt9yFT+7LzDbuuoDLD6kfyzneyH
         dEsIlYrPmmvM7pPiVe9Ed55usUsatrjsdw4Jc7DpSPoJ4P4lRgwbzu5NjDcxXTXc9Mw8
         dkKA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1782409622; x=1783014422;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=+j0HUPyrwQkvTNXDQM/PgRSXJ9NkNOhG/0ux2wZgmu8=;
        b=BjWfaix2tiVXDV/r+ZQ0jX790brz6wpjHKITKs39rwwDgE4WfudL2XPMAIvuRI96jY
         ia59NEM8FW1TpTI2H2pu8iL6KIK0Vkbi9zDBmxNtmAlzt4x73zbdbZgeWRKT1UVQS8bT
         JkGG02FMHKD1boNddDKMJ98V/9EZuuarxDS3oAd0L52lGTFJJjHnaQKNhKSIz9Q/zonY
         mujwhTK1ZqGsUQLA3btL6k1IUIBFLk5dhPhHT4xAwCUR4O+rMYl3DUD0cBPHVW4wr/UL
         sK9PvF1ToeeZmJ4HpCrGolKMI7AUNvOTn9xuPTbN0904zGw2Q42VsE7F8E2iSBTIIXCF
         zSMw==
X-Forwarded-Encrypted: i=1; AFNElJ/ew8FeiS41t7ZTyW5nENGYOgEbIOHdPdNb8kSIW0OtfRGf8OCOZ1NGTQgCTlY7eDPIR9u6al3ckkU=@vger.kernel.org
X-Gm-Message-State: AOJu0Yx/g6jcVKAKuO/NNE3hX92j2Q2Zn5RMOlwKDrFyTrfgR8fBT2Lx
	Zyq/2FSxsIwIcfhh+jBeJD6IUnsv5KQVP3T4pSFumCxUg7e43vFXRMXCdxTwXjV5pDM=
X-Gm-Gg: AfdE7cm3o4qrMtclDgKXPeoT4zMuxeED1ADQJC1BNB3GF6m9FHNxpw16KX8TwdXOpuY
	333hIDg9idNEs72Pw/hHxF175itFxjACiLQWFGo8qz5Up6F0AoVsjJirqdNh/KOpGJ1SyU5e+i4
	dJ8dZ9hh9HIDhMKxSQWMThmSyINVjt44vTCIG7u76qNcfkqMSfMQH0oPz0aBAZbQTx+mNVvvipO
	rMWgZaYXyzSuixrOG7ZTYBBCH2EpRPJaNfHS71lUM8PHfqi4XzirYqVmISnJEA9yD8HmE30yb3p
	hKFRZQxvPCfyrJPoSAwmoqfmbK3WE5l/jM7zgSX7aDxq8KzSgHBSbXc2kkesdwXURSvnT7R1LvL
	feplsqk/RPl5rcCxiHMWGuGVijA1LwmxxNG6NkNy8OUWWKRasxQ3FwDMekgTpU9Dh3jNvo49oRU
	Wf42MfqJ7KEBfXnGRpDJGqryikZrXmYZMP
X-Received: by 2002:a05:6820:2912:b0:6a0:e3ec:7a5d with SMTP id 006d021491bc7-6a13521cb6amr2696656eaf.56.1782409621681;
        Thu, 25 Jun 2026 10:47:01 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4472ec52815sm13610942fac.1.2026.06.25.10.47.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 25 Jun 2026 10:47:01 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neilb@ownmail.net>,
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>, Daire Byrne <daire@dneg.com>,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 2/3] SUNRPC: dispatch idle transports ahead of
 backlogged ones
Date: Thu, 25 Jun 2026 13:46:59 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <ADEE8294-3A99-4259-B5DD-3CB2AD68EC99@hammerspace.com>
In-Reply-To: <538fd605-e7be-4450-ad3f-804fad6224eb@app.fastmail.com>
References: <cover.1782314746.git.bcodding@hammerspace.com>
 <8b65b751a62984fa08797b18be7dfaf16bdb3721.1782314746.git.bcodding@hammerspace.com>
 <538fd605-e7be-4450-ad3f-804fad6224eb@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 25 Jun 2026, at 12:09, Chuck Lever wrote:

> On Wed, Jun 24, 2026, at 1:04 PM, Benjamin Coddington wrote:
>> A pool dispatches ready transports in FIFO order, so a connection that=

>> already has requests in flight sits in the same queue, on equal terms,=

>> as one that has been idle.  A client driving many concurrent requests
>> therefore delays the next request of an interactive client whose
>> previous reply has already completed: the interactive request waits
>> behind the busy client's backlog even though servicing it costs a
>> single round trip.
>
>> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
>> index 63d1002e63e7..ec4c05094e9a 100644
>> --- a/net/sunrpc/svc_xprt.c
>> +++ b/net/sunrpc/svc_xprt.c
>> @@ -523,7 +523,10 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
>>
>>  	percpu_counter_inc(&pool->sp_sockets_queued);
>>  	xprt->xpt_qtime =3D ktime_get();
>> -	lwq_enqueue(&xprt->xpt_ready, &pool->sp_xprts);
>> +	if (atomic_read(&xprt->xpt_nr_rqsts))
>> +		lwq_enqueue(&xprt->xpt_ready, &pool->sp_xprts);
>> +	else
>> +		lwq_enqueue(&xprt->xpt_ready, &pool->sp_xprts_hi);
>>
>>  	svc_pool_wake_idle_thread(pool);
>>  }
>
> The classification is keyed on in-flight request count, but a deferred
> close is enqueued the same way.  svc_xprt_deferred_close() sets
> XPT_CLOSE and calls svc_xprt_enqueue() while the slot is still held;
> svc_rdma_sendto() on a send error is one such path, and
> svc_check_conn_limits() is another.  svc_handle_xprt() reserves the
> slot before calling recvfrom and releases it only after svc_process()
> returns; recvfrom clears XPT_BUSY in between (svc_rdma_recvfrom ->
> svc_xprt_received).  So the deferred close is enqueued with XPT_BUSY
> clear and xpt_nr_rqsts !=3D 0, and the close lands on sp_xprts.  Since
> svc_xprt_dequeue() drains sp_xprts_hi first, the teardown waits behind
> idle-flow traffic precisely when the server is busy and wants the
> resources back.
>
> Control work isn't request work, and svc_xprt_ready() already treats
> XPT_CONN|XPT_CLOSE|XPT_HANDSHAKE as a class distinct from XPT_DATA.
> Routing that class to the high-priority queue regardless of the request=

> count keeps the two consistent:
>
>   if (xprt->xpt_flags & (BIT(XPT_CONN) | BIT(XPT_CLOSE) |
>                        BIT(XPT_HANDSHAKE)) ||
>       !atomic_read(&xprt->xpt_nr_rqsts))
>         lwq_enqueue(&xprt->xpt_ready, &pool->sp_xprts_hi);
>   else
>         lwq_enqueue(&xprt->xpt_ready, &pool->sp_xprts);
>
> The burst-allowance patch narrows this -- a close with credit left
> rides sp_xprts_hi -- but a flow that has spent its budget still routes
> its close to the bulk queue, so the gap remains for exactly the
> backlogged connections most worth closing promptly.

Excellent - if we v1, I'll add this fix.

> You should also have a look at the pre-existing issue that sashiko
> identified: it might be amplified by this patch, so we should
> consider addressing that issue as a pre-requisite to this series.
>
> https://sashiko.dev/#/patchset/cover.1782314746.git.bcodding@hammerspac=
e.com?part=3D2

I'll head over there (cool - sashiko looks smart) and give that issue att=
ention for any v1.

Ben
