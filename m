Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A69D52701B6
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 07:38:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789717140; cv=none; b=ZU76VvgH2astKkjAkVz6fTZYcy4H6I5BrEl/AGI2yQ1WoIQ6Q8bM5EotnYm0CYnPAL9hy5+pP2jncLRLoA5HhIO5TeYD4LhHoH6YfMic/ht8D26W66NV3zalZxkGfFxP4sHw3hCe7hpwXn4MRM5/wEw3kC1hIMOghHtJj/Orb+I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789717140; c=relaxed/simple;
	bh=k/8XvjlmKlHETkUOk5bLjBjvWaF1CYDJJgRep4XFPr4=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=B+0Ms3XL+Xu0oN7K7EL+Spa4mn2cTLH1Ko5kVNhe3HDQF2TIWrTjc8SFvKcZClgqzKMEgej+H5c2OPoNKp14k82LuRPpOte3/2NIEMxaeh72nGpWL9kCpBIoa9awizwnna56rV0ae2iH17hNCh4SOVq3Ell6Lqs4rKDmAhj9zFo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=IzGkupqV; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=Tt3Q/Jdp; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="IzGkupqV";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="Tt3Q/Jdp"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789717128;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=fs8yQ6l55UDTlVQGnKxMoDt2qN2pbV1oiCNfVOkRQ4E=;
	b=IzGkupqVeyN0PP2z2sCsntZKR8bApnsBQDYt/3U+UfMCqd89YUGC46gz+Ydas7M0JRCegq
	quTlHpqX6uZyIYfKzPoKlQ+l5A0sv38ZR6OXp97jDZhNSyCu24QjvLovocAvJ1WqGWBPJ0
	prCDb1BfAQBBPG6sShQP4caRkefimxU=
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com
 [209.85.222.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-351-RiZJK5v_MBKGMcR1KEUY8w-1; Fri, 18 Sep 2026 03:38:46 -0400
X-MC-Unique: RiZJK5v_MBKGMcR1KEUY8w-1
X-Mimecast-MFC-AGG-ID: RiZJK5v_MBKGMcR1KEUY8w_1789717126
Received: by mail-qk1-f200.google.com with SMTP id af79cd13be357-93a2d361e1aso105164585a.1
        for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 00:38:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789717126; x=1790321926; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=fs8yQ6l55UDTlVQGnKxMoDt2qN2pbV1oiCNfVOkRQ4E=;
        b=Tt3Q/JdpzOZZNoctSbSk5h8lyH9nbflK42r5puEUeTYBJDRoIdwkHiLEqfWs0WKUlB
         61Jkr+RS13ApCbU5XSQcPZbuIKRB+vULleFhIsPxql2SmMzaKftTeMbi8XKiWIRHbmXu
         ibLY1/Q2SR5A3muzpqNnLe2hsvQia1/2E700lSn5IiYltiyUUu01dc0wvD9MiefdzFZ5
         78+F+QMN+vBNbMYFnXfxDfAJBuKKgqbPeyxD8iu70vXDvivdg/tlGIMJHcL8+SsmwIIu
         LUR0XFVyrZ46uvVf837bJY58FuQvWOywFMYdtiXAQ3s8aTOu8SGm8qoiWbWZ3PA/1yXz
         ci4Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789717126; x=1790321926;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=fs8yQ6l55UDTlVQGnKxMoDt2qN2pbV1oiCNfVOkRQ4E=;
        b=zCGbHQbu1t79GGw1++TGqv/1OxPLqc3kCNbX0j5u5AkXeW+gXl2mhwJSM47FJMOhHE
         ueaaDtS1QGCQVn+b3O+X+irUGQURCLU2WoiSbVB0SZYFvD0X4VhYlK3OZ5xTqEoQgSr5
         C3DTGnwpmSMjYQK1ISWfK0350QAXB9BVOe6O/zYLIxhNHGfhzy844452fdyH/h1ulrWP
         AJDs2yo2kc5/NyIcWS1uN9b10WdIUWKRxgjUVtdoTgIrk8njVHQsATjBX3SyZaVkw0pc
         4osSEEu5xSk0+5ZgthN1voLsEw5w3VtSfDT5B7RHIwwWb7QbJrNw+uoxic4SpO+iKh1L
         LoSw==
X-Gm-Message-State: AFuF++n2iTcrqAP/GvEyJu31nFQJud1QfqNahcJhiEKcJiN/RavJXs7D
	XtrO5Q8+3k+GmwZiz5UhK1uPVFqOy6tFPHKcFiTQlhbh8a/yIJl7WA8/iSb+4Ny97lI3mW74etX
	PzP6dTPHPT7rMCAyzLYT2AEqIzvLt9H68Dauu1diSOlTvYGFtQdl7X/xFKL5/jXMuhXuPkQ==
X-Gm-Gg: AYBFou0bd0OBiBXm70pB6ZSIPTJJ2fICxu3t85+h0ncdYHAvmNM2+gW6TUPY3odRrXN
	l3gyyrilztzbqQtWKgTef22wkCNczXRQN5pY1vCOLc3J4US/gbDy1FNBb8nt//WlrC9ui+vfrOP
	OX/BU7/4zKWVr1/F7vaqoDAPxZZcsP3bTpOj6uRmJDTenemFk2N+AcKvpASfEu0wIEjYBOmM+4N
	y772b8+VLDWVfvYgy5iV4grihb1fSv/zeyMyKM0KgmWEiI7KAx6nDTAGAy6MeKdkPmGArUqIK9p
	qWRTrDI89BvFEwsURZWaY1841ssOzMNFa7Z2IEmq/cXFTZi46qIdgSasDJ6Vrsbl5Zj2nTNX
X-Received: by 2002:a05:620a:2810:b0:93a:2e8:5af5 with SMTP id af79cd13be357-93bdc6d4782mr189986485a.6.1789717125907;
        Fri, 18 Sep 2026 00:38:45 -0700 (PDT)
X-Received: by 2002:a05:620a:2810:b0:93a:2e8:5af5 with SMTP id af79cd13be357-93bdc6d4782mr189982785a.6.1789717125413;
        Fri, 18 Sep 2026 00:38:45 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.241.2])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93be0e8fe0bsm72778985a.17.2026.09.18.00.38.43
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 18 Sep 2026 00:38:44 -0700 (PDT)
Message-ID: <2f0c6fe2-be04-4c22-9305-20dae95ac8c6@redhat.com>
Date: Fri, 18 Sep 2026 03:38:43 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC nfs-utils v2 00/10] nfsdctl: allow it to handle
 rpcbind registration and deregistration
To: Jeff Layton <jlayton@kernel.org>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>,
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
References: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/14/26 12:00 PM, Jeff Layton wrote:
> This version fixes some problems that Sashiko flagged in review.
> 
> This patchset adds support for NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND,
> which tells the kernel to not do rpcbind registration and to instead
> allow userland to handle it. After setting listeners, nfsdctl will then
> call out to rpcbind using the normal libtirpc client interfaces.
> 
> This is a companion set to the kernel set I recently posted (and which
> also should have been marked RFC).
> 
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
Committed... (tag: nfs-utils-2-9-3-rc7)

steved.> ---
> Changes in v2:
> - Fixes for bugs v1 introduced are folded into the patches that
>    introduced them. Three pre-existing bugs found along the way are
>    separate patches at the end, so the set is 10 patches instead of 7.
> - "register nfsd listeners with rpcbind": register only once the
>    listener_set reply has been parsed. On a reply carrying no rpcbind
>    attributes the sweep cleared every NFS and NFSACL entry and put
>    nothing back, leaving a running server advertising nothing. Also
>    abort rather than send a listener_set that lost the ownership flag.
> - "clear rpcbind entries when the serv is torn down" (was "... when the
>    last thread stops"): also sweep on the autostart teardown path.
> - New, pre-existing: fix a heap overflow in autostart_func(). A failed
>    listener set zeroed the pool count before the thread array was sized,
>    but the array is filled from the nfs.conf list, so any [nfsd] threads
>    setting wrote past the allocation.
> - New, pre-existing: reject a listener insertion when the table is full,
>    instead of writing one element past nfsd_sockets[].
> - New, pre-existing: check the nla_put() calls in set_listeners().
> - Link to v1: https://lore.kernel.org/r/20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org
> 
> ---
> Jeff Layton (10):
>        nfsdctl: sync nfsd_netlink.h with the kernel
>        nfsdctl: probe the policy of any command
>        nfsdctl: share the listener nest parser
>        nfsdctl: add rpcbind registration helpers
>        nfsdctl: register nfsd listeners with rpcbind
>        nfsdctl: clear rpcbind entries when the serv is torn down
>        nfsdctl: add missing break in update_listeners()
>        nfsdctl: fix heap overflow in autostart_func() listener cleanup
>        nfsdctl: reject a listener insertion when the table is full
>        nfsdctl: check the netlink attribute puts in set_listeners()
> 
>   configure.ac                   |   2 +-
>   support/include/nfsd_netlink.h |  18 +++
>   utils/nfsdctl/Makefile.am      |  10 +-
>   utils/nfsdctl/nfsdctl.8        |  16 +++
>   utils/nfsdctl/nfsdctl.adoc     |  17 +++
>   utils/nfsdctl/nfsdctl.c        | 256 +++++++++++++++++++++++++++++++++--------
>   utils/nfsdctl/rpcbind.c        | 251 ++++++++++++++++++++++++++++++++++++++++
>   utils/nfsdctl/rpcbind.h        |  42 +++++++
>   8 files changed, 562 insertions(+), 50 deletions(-)
> ---
> base-commit: 630393e9c73667b3fda6a7507cb5171ec0ec38dc
> change-id: 20260908-nfsdctl-rpcb-adc5a1fc090b
> 
> Best regards,

