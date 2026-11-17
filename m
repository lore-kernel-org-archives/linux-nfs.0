Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.216.98
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794940080;
	b=wmKS2eqrxCP+yHACXR6iFuOOz4Ff8Vhq4QobrVyDjU4IMBdQF3/6PJFRxmL617ayldnP
	 +qQ+8rvuBNHwq80dszz0FmKUF3JHBjcgu76U8AFwiRMQWbzj/HUvIwoVtuxNtEvIQ1Yhr
	 rKwnEZrdHAXpkf14YOxkatyy6N+O7dRdVY7DVJ/mPXI0RZJQdNuDXsdLrdMVQ5gXF0/Oy
	 6SgXjNeatb45SxTZ81MNLs+749KsTS/omGsHzTgW1z6vajAZIjIDw940lZT/dlx+gk8Zc
	 Lv9/qDOhUQUPy3xE+J/CMOw/BzyfNHOGDXuDbVOmFfL0240Goz5yQQpwLzBH1BAbDNA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794940080;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=4HIDElfk1fUBR+g3gRBqfDseCIheuM9kcM5hnFH2Y+g=;
	b=W277MLJNbX3lY8LwWE0fCJ1U971qE4jaTaI7BxC8nmzlrTLF+ZMGdSnb8kpupos639VX
	 4X0y4lzDEu6JPjYvVRcSqkV5BxiqAdGtmEtq5oSQxE602bW77oP2Qu7iNbMpMz4ciNqan
	 QMOcUNCfPoSeCIMO7DGxiwcMT9RE2taoDW98YRXewuKnV3ckGlhRs9EkUJPkRUApdMmmO
	 9qJTPYUCfTpBl2GL4ZHrEI7WNWCD51fin8pXiGdAqmOpoUKDrjeNZSPVM1QbeBzVZdNMI
	 AeKCtF5k2R3Zo6YCRHvAWwphcemf1extnG6g6sWWQGpAn0L7o5uD72jH+94h090OiUA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=uOs3Ahgj;
	arc=none smtp.remote-ip=209.85.216.98
Received: from mail-pj1-f98.google.com (mail-pj1-f98.google.com [209.85.216.98])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2AC4C606A335
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 18:27:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2AC4C606A335
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=uOs3Ahgj
Received: by mail-pj1-f98.google.com with SMTP id 98e67ed59e1d1-3ac78f4c10bso3745a91.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 10:27:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1794940078; x=1795544878; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4HIDElfk1fUBR+g3gRBqfDseCIheuM9kcM5hnFH2Y+g=;
        b=uOs3Ahgj9+nx34cROVVGq20lgcXGJt2vVPpnszE6xPya+N5tpyTvWqV2gfQ0r597kQ
         u7OsHsx+A7t/z+rXxrCwGza0CSjZD6bMOgOUg0n+rqq3U3M40TIKsaC2vgg1HqbNkSLM
         sRvpK2gq1/qjHMc/LU6b4IQKPPTsHsqL/nITdkzcL0HOh/kDRXL75jTdDQ8s3dEkGWGm
         CRnGH/pPh0XydxUFACuGxsOn/gdkqSXeTToq/fctuyImgwYaE+OkDZR8gLb36ux8ELL9
         sZiUpJDnJwu+QOgjCUagnIkqaS4xu2BIg/6ufW608Ooyjt0mYI1+38OhK2vxwyEMhCr2
         AysQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794940078; x=1795544878;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=4HIDElfk1fUBR+g3gRBqfDseCIheuM9kcM5hnFH2Y+g=;
        b=eWu8gf50EIFvQclEbUq5WnXd1sEOU2hXHfwyvnN9qutMzBldEDNhL64m81nXM1wzdM
         bnhb/rOj68mPEh4zbv8cMl2B9ajSa4p4gizU1bP/sC99CBvWVM9kzkK6mhiyjFGuKMm5
         pt5xLWc3LhMiT2oG+G2+DiWaybvvmHFkf0BZlGr7PVnmgvxxl6wgVVWL1OPwALyIA+zd
         PtFl2x94M5E60uGPX4ZPLexnuuWrpaufUG0RbYYEIG3jHoYROBU2H3Lxj3eyX+B5MGEo
         k2i62qZyCADaL0MAz49lIC0zwEuKoQD+lLUGNcUAJNgZAVdPowBhGa4jmpKJmtzwsNRX
         Azpg==
X-Forwarded-Encrypted: i=1; AL+hErFEHdCASWXkcMSJCPq6f1oldu0a6gS7oX0p5MApkcE+/LiiwgmmXUw/jFi1omHFD86kcAMtoSZEqxQ=@vger.kernel.org
X-Gm-Message-State: APuU4Z+NFia0cVR16SVThyvwqFI0/vaTT9U2Oli/l85f+T7Si8rwAP9q
	SVbzk1y8vDl8ULYsW0/yptAlmbiB2YRd+7Lrde33+TNdgm1cZ1llifAOTk0PGQ9pKpG9l0Uwigs
	QIgCpXyAXmP9PLLAJfy76IGaPnr3qxUYyC2TEcHJwfJr2642Mae0c+I6aPSM8w0JKBusrmU33It
	vvA3h6eWA2XHH0RdQIIqJt4aE4jb/iDt0Ckza2Za0NO1vsQw9A6lpAz3hmSAA6QHlDi5XT0ysfq
	Uxb2uldCDXOhMXpas9EJ5pOgPg=
X-Gm-Gg: AZFdTZepDjTGtzmPuG4P7I8p61TiyXKqd52gkL7E/0yy3iwqqwNcK5A0MifeL0ZiFbL
	qHdXdtEjxhk2E8lr7Z3v0dx+5SgzDfjny5gTWyXTFzMBrJ/oCawG4aPdXGL+PO7+crO7oCIGqM4
	pvk6pU7ElJejnsbqhp7GcYcaiiwdF9dqkMebChcXgiRLT8J11O487CAWFhfN8UL2PElW5yWT5oU
	zy3rYd2TtZfjz3wniR4yb155n+qBqO0vSmkoNP0gWCBbZ+e/ne0H2Atk7ex9ThMbkLaDLHxg4Qp
	be7nRTgmhCAkg0I5u7JUvF7ktMpd2KenDgsK/4lIJf43J5X4ZZDA4yX6Fig07JsvN240NQxPnLL
	0iI88mM/rMAFPcBFea6E3VszUo2rqM9cKgbD/Qts=
X-Received: by 2002:a17:90b:4c0a:b0:3b0:934c:5e41 with SMTP id 98e67ed59e1d1-3b3d07aa71bmr289902a91.29.1794940078336;
        Tue, 17 Nov 2026 10:27:58 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 98e67ed59e1d1-3b3d0987ac9sm136956a91.0.2026.11.17.10.27.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 10:27:58 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 1C2BE34052C;
	Tue, 17 Nov 2026 10:27:27 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: lixiasong1@huawei.com
Cc: Dai.Ngo@oracle.com,
	anna@kernel.org,
	cel@kernel.org,
	jlayton@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	stable@vger.kernel.org,
	tom@talpey.com,
	trondmy@kernel.org,
	weiyongjun1@huawei.com,
	yuehaibing@huawei.com,
	zhangchangzhong@huawei.com
Subject: Re: [PATCH v2 3/3] xprtrdma: Wake connect worker on device removal
Date: Tue, 17 Nov 2026 18:27:27 +0000
Message-ID: <20261117182727.104697-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261103032758.1302493-4-lixiasong1@huawei.com>
References: <20261103032758.1302493-4-lixiasong1@huawei.com>
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

I encountered a refcount_t underflow warning in rpcrdma_ep_put() on
7.4.0-rc3 during a pNFS flexfiles read workload with one MDS and one DS.
The trigger was restarting the NFS engine on the DS while reads were
in flight. The warning came from xprt_rdma_connect_worker via
rpcrdma_xprt_disconnect() -> rpcrdma_ep_put().

With all three patches from this v2 series applied to 7.4-rc3, the
warning no longer occurred under the same test. This test did not
involve removing the RDMA device.

Tested-by: Tim Menninger <tmenninger@everpuredata.com>
