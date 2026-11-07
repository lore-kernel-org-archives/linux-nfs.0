Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794071929;
	b=1q2GE/8yXQszBLBhjNgSdnUVXt//uv9gI4XTwKip8NWEWMRyWwId7Qjx1wij0onovNq4
	 gOIyIKHuj34p6niZmjZiQnyrZsqljH+rYLwKqdSnmtQciDDO8sjM7KRblm+wEZQLTTCAD
	 ULxcOpKKc3QWoydfjUFcAMk9QlF+bbbpElvsmMWQ83Xe+9emPF7o+K5EPsy7khSLT69r0
	 l0Kh5IEgzofAlTabA4TFHcJA/pOAO5N5QzBKS7XWCfNe2JbvUFclDyrt5TUm8u8C7Qvty
	 KcSRx3R66eV4E7LYxGmTHFN4MnnhHp2QN2lgjGzKDFslAPD5CkzjZfIm+BcwzEioklg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794071929;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=x2y+Qo7gZ6giSO/fHwPAkNJyPN86vjj5rYvWf1XuWa8=;
	b=Ac5fYKPCPUquQlx7DQYdD7Se06uswUKB4zjlSwjUbtSoRoyufKVNHeq48pKbsPh2Y6T6
	 G3LvA2wrTK5dzGg9tvrlp6OVtnt8t2qrj9EgzZRqFZgtAJ7C2zYwiDpdOIuJCsmoW2yZb
	 B/u3VhBpVDXGK8Ks5DmgqwA7Mt3YMPKwDCI3vgXZiOXZvG4m14tUpgRwgEziZl1pP+y44
	 opwfV4SjE3r9JgIE4LVhJkB2DsvAKHjG2OoDLaq8xo8Nq4lNIPFy1Ud+ImtN1i+KQjk7I
	 LNE5sBZg0UIb8CLI11gSnaZEjC/1y8L82ghreTYLs0YgTelU9z9EsQ1SBsJgILpkSKQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=e3B2PtJR;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=RSCMZ+8+;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B4ACE606A326
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 17:18:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B4ACE606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=e3B2PtJR;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=RSCMZ+8+
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794071927;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=x2y+Qo7gZ6giSO/fHwPAkNJyPN86vjj5rYvWf1XuWa8=;
	b=e3B2PtJRWsuKlFE/XRv9+9x32dnMaSQ7hXH1snvh7nfMjb4jcukr732G2BC6T3QvaqIXmX
	KlVywNk9+sJqRkEAFrZGlrExWYpXCOYu6MoSTog1q4cMiMHY9yCFHZI5vfrvXDMroT8N6u
	PP5hPFnAqxZmA4lU3wzSegSiEEOspOk=
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com
 [209.85.160.198]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-271-7Dnqm0LvMwurtnHct_IuFA-1; Sat, 07 Nov 2026 12:18:46 -0500
X-MC-Unique: 7Dnqm0LvMwurtnHct_IuFA-1
X-Mimecast-MFC-AGG-ID: 7Dnqm0LvMwurtnHct_IuFA_1794071926
Received: by mail-qt1-f198.google.com with SMTP id d75a77b69052e-537548d4bc0so44178471cf.2
        for <linux-nfs@vger.kernel.org>; Sat, 07 Nov 2026 09:18:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1794071926; x=1794676726; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=x2y+Qo7gZ6giSO/fHwPAkNJyPN86vjj5rYvWf1XuWa8=;
        b=RSCMZ+8+FU5aM3mDQzjqTO2YiTqaAWPD7mG8MLZtwhlurQ+ijJHOjBvgHXt/Uw0DSM
         NtQuFwFZWjc9mjuw4GWB4kpjHu83Ckr4p3CtdwHVmsmAyJHCmmPe5zZR/5Byamu3Ffmc
         TG6X/G9GY/3NwfudEQr5VCOSRJvUtISmdX3jMkhI8oBeSeys5tEeMsp5c/c35woARJvY
         +bleSQZ5cNL5BUtfX1jI1DYZmNT5LTSO76jksJhom9JkiSo0phy6VVFUbO/q5sny7r+e
         pRCrocTMgfn/mc5Eeu94Gdhx5GXriPAQn+5f2pF/hP2gD7moK7DJ/hrQO2NEUNF6Lo+9
         XviA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794071926; x=1794676726;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=x2y+Qo7gZ6giSO/fHwPAkNJyPN86vjj5rYvWf1XuWa8=;
        b=M5ZxXgFam5wsFa6PvfV48nsIEOKMCq103sYF3XgqROVs9Nj4UZi3km287D22Vk39l3
         ryVbICJCppNkIRqV2huIiOz+kQGIqDgYac2GgxIW1j4AzpsR2kCgXmC5V80m7831ZjYw
         0ep2HSm3EfQKPqaSHZZ6T3W3cpuofYyPvtIVpXC8oXoJrppfBHweiE0UoHN38gjdCWEl
         Sxt/JtC7D6IyLmCLY09qdNgJpU0bUAkg6xnmx6dqQabaF7HdmZOpix5NdnESpdPsbiUO
         NyTr64/Ye135IceUpuu5B0ZoerSafC+I1sh8LDENTcxi30wmWfh9F4+Wbzb/fGhtERLJ
         r7qQ==
X-Gm-Message-State: APuU4Z8nRUaVaB5M4uQtoV0Lr/rckrUa13EUj5nfCyk3uBbu1l9ogtcq
	z1dJjNP9MnYIYAEKSRwS2Y/565at8DVY6mMNKhusD4lL1vemnOrXHyFX0u30MpX4qb+9MD9+XdO
	LW1izmbZ6Bw1/JwjTmOTUP7hziIWpfYmfWivw8M8uNgqPMGUwUPJAdIYqBLtHjoeQDn3cKw==
X-Gm-Gg: AYBFou1hxAmh6iXdFRenfjtBxHddlNMiPgHMl+m0c1Q6s7PSOYzP+lEkkypcwb/9Khi
	KU3pmGKDeQJUHh9fCFLka7gQf7uNAQ/vkRpno/PBImioxMfPz7Mu2OH+jU9lNQJjaEIP44DXWmK
	3xIXi1TTfV8wRFidSu1ug96RhUgEW1dsLJagIOffUnQ0P8IQAy79Q24E9+cNc0ALxSLX8PTdIf0
	fbQ/B4LYmwC2Wdl/feu3vTFQyvnToiiojG8V0q3QOnHXmFoqlQ2GPnFQq8x6kihWN29dkblCg6U
	TjUMnPkZVeJQgk/5MqsZcd/sHyqUgxkwn0sD5Ds5fPt4Sg56VeeQn4sr/Zt8W7eNwH8wdU5C2Q7
	9h97DOiOh0URMZwIrXb3M8y5RAPt7f+tFRc9V0dHPu5VqQQ==
X-Received: by 2002:a05:622a:1f85:b0:536:6ef3:105 with SMTP id d75a77b69052e-54e1388222dmr97591371cf.21.1794071925627;
        Sat, 07 Nov 2026 09:18:45 -0800 (PST)
X-Received: by 2002:a05:622a:1f85:b0:536:6ef3:105 with SMTP id d75a77b69052e-54e1388222dmr97591141cf.21.1794071925180;
        Sat, 07 Nov 2026 09:18:45 -0800 (PST)
Received: from [172.31.1.12] ([70.105.246.93])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91ea675224bsm48329366d6.0.2026.11.07.09.18.44
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 07 Nov 2026 09:18:44 -0800 (PST)
Message-ID: <e0314a68-f0d4-4624-b35b-879778ed6c8a@redhat.com>
Date: Sat, 7 Nov 2026 12:18:43 -0500
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 0/4] mountd/exportd: exit signal handling fixups
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: linux-nfs@vger.kernel.org
References: <cover.1790263469.git.bcodding@hammerspace.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <cover.1790263469.git.bcodding@hammerspace.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/24/26 11:29 AM, Benjamin Coddington wrote:
> mountd and exportd exit from inside their SIGTERM handler: killer()
> unregisters with rpcbind, frees, logs and calls exit(), none of which is
> async-signal-safe.  It mostly gets away with it because mountd spends
> nearly all its time in select().
> 
> Setting rootdir in the [exports] section of nfs.conf makes it much
> easier to hit.  nfsd_path_init() then starts a workqueue thread to do
> path lookups in the chroot, and it does that after killer() is
> installed.  pthread_create() allocates the new thread's TLS with
> calloc(), so a SIGTERM there - say, from a reboot while mountd is still
> coming up - runs killer() on top of a half-finished malloc.  We hit this
> in a reboot test:
> 
>    malloc(): unsorted double linked list corrupted
>    ...
>    calloc
>    clnt_vc_create
>    local_rpcb
>    rpcb_unset
>    nfs_svc_unregister
>    unregister_services
>    killer
>    <signal handler called>
>    _int_malloc
>    calloc
>    allocate_dtv
>    _dl_allocate_tls
>    pthread_create
>    main
> 
> Once that thread exists malloc takes the arena lock, so the same
> re-entry later can deadlock instead of aborting.  Out of 400 SIGTERMs
> sent during startup with rootdir set, one mountd hung on a futex, which
> I think is that, though I didn't catch a stack.
> 
> These patches take HUP, INT and TERM through a signalfd in the cache
> loop, so the shutdown work runs in normal context.  The parent of forked
> workers keeps a handler, but all it does is kill(0, SIGTERM).  The last
> patch holds signals while mountd registers with rpcbind rather than
> ignoring them; a SIGTERM there used to just get dropped.
> 
> Tested in a private net namespace with its own rpcbind: foreground and
> -t 4, HUP, TERM, an ha-callout, and 400 SIGTERMs at random points in
> startup with rootdir set.  No aborts or hangs, and nothing dropped.
> 
> Benjamin Coddington (4):
>    support/export: take SIGINT/SIGTERM/SIGHUP via signalfd
>    mountd: stop exiting from a signal handler
>    exportd: stop exiting from a signal handler
>    mountd: hold SIGTERM during rpcbind registration instead of ignoring
>      it
> 
>   support/export/cache.c       | 122 ++++++++++++++++++++++++++++++++++-
>   support/export/export.h      |   2 +
>   support/include/ha-callout.h |   5 +-
>   utils/exportd/exportd.c      |  30 +++------
>   utils/mountd/mountd.c        |  32 +++------
>   utils/mountd/svc_run.c       |   2 +
>   6 files changed, 147 insertions(+), 46 deletions(-)
> 
Committed... (tag: nfs-utils-3-1-2.rc1)

steved.

