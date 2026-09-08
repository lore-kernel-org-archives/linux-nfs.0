Received: from mail-pf1-f227.google.com (mail-pf1-f227.google.com [209.85.210.227])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C8A359574F
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 18:19:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.227
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788891601; cv=none; b=V45e0EvgyewiqUL9AOdZEYUiyq6F8IlwqFxn4hmm1pi+M9AEStVAjFiZQFab9M30yFehnfpI3cdp+MUOSGOQ9Pr9v5DA+BFXXMQddK5xP2ZElaqO1qblhteU/TzQxoj5s/mZwKfofc720vpOW8eYrqCmtR/CUhUQgX1zCUt/3lE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788891601; c=relaxed/simple;
	bh=qiDv62Xva9oTEOsugrQNk034VmUQViPUM+ER9vte+0M=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=Xo5ufdHqLK3IoXk3oGDaUMPMF6BhKwF6d+vd1ofBE/jlUZb3a8ZsW1pM8EWo7Vv/nHQwSprWwNq1VuS5r7InXhNYasRh/w1OM0FP7naMbh5ERuqm7n3r4TzLBf5eyHtyrSWmaNjKRF2U91krdvwPkZDeg68/IEQY/Wd60MrirpE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com; spf=pass smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b=MBC+6B7S; arc=none smtp.client-ip=209.85.210.227
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b="MBC+6B7S"
Received: by mail-pf1-f227.google.com with SMTP id d2e1a72fcca58-84f38f3b36eso3444266b3a.1
        for <linux-nfs@vger.kernel.org>; Tue, 08 Sep 2026 11:19:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1788891599; x=1789496399; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=sL+3R8dC0d/UZInnr5kKfu/nnPuO6yeb+usfGZ1iKxk=;
        b=MBC+6B7SJE2MTZmfhk9bEWf4QBxPSOF6/qNJq2g2akOwSrN48PCRVzCOaXe9oZF3+s
         VhRWC8L4NCa0bBMC37F11G9iKTfHnz8/t2Pk8bOa6f++hhIFbuYYAT3Xi7Tck/fCZ2Pd
         4YZy5GtV4tWLuFFa6B17LZM+6U2Jady0Hkpk4VNorRfHAp1fW0rQEm31cihC2ZhYNYsz
         50AIQbaKJM/2HbGl+6pPIWLA/7CqhnEcn0xADVG6M5fUBYIA4lBTHEeM9EUVeTP2Aj8c
         IvWFXfdyASPes+4ghgC9m3lLLfiGP3PgoHLPgHsYb+zYsdirApEeSCk0XXQi0BDe/A+3
         h3Pg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788891599; x=1789496399;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=sL+3R8dC0d/UZInnr5kKfu/nnPuO6yeb+usfGZ1iKxk=;
        b=SkDA2kfeCGJywDXa3Nz5GYE1j0OR+0otwlVr0+aw6cqXr7+VC1CgVnZjQNWpvoMZIC
         PED3Xx+LgGG3+T4kyZ3Eo+KlqgvRZWdr3YVD7ewG25eByWleO/BGtIO3oOMvih9sV1lD
         StYHniUhRDX01hdIEOY830ZDs/rD41kxDildXOIjRvCn+Apid7paWzhOkKvcPdpmnkgr
         ftllY5EONqUlXPzryhCk2yT5069yiala/I1dn2E3kUqoWUE2fnOeaf1r6g9f2X77/c8J
         Rxch+ttO5vukO3R61pABlR6j+7LOUyPN3xv+XEdkJSgMPW0ouUwq9KJG1dJRTKhS8r0D
         VTHw==
X-Forwarded-Encrypted: i=1; AKwUvBxOIDIcfWGxjiHVsYd4NF/KzvVry6P7O8Ul3yHcR1HmmRD28vntL8u6rTeKDUM+DToaHcACKi7j820=@vger.kernel.org
X-Gm-Message-State: AFuF++m8X4b67PKDUqhEwl2+aoKXpoNDee3+kCga9VG+ZUdQEVHV9nWL
	RKEBmvgbanzc08WXmWNXkdxb533VjXXh5/h2HZGZ5eH46U0XcHgHYpidXbsJ5P16f0UWMq6rakf
	k+zH7ZeBNVJt4UWwtY7uAsV61AYuA1StDmYmI
X-Gm-Gg: AYBFou0i1k2QgGxWbkmc2VrL9rimwAdLN3XpOMDqOmoICtcblv5ftCShvY+XTvnh3Kd
	fE39sLTzsiFXHK7iI5ayOBVOoKHJCnS94yht/11obsEUBWhMMRm0AdPKo6DE7z81+D1QiKxJHI/
	BtcqgiVg74RtaaEq5lGiYKrah9285BGGGF4MxgoN/fhheE04+njUEUj+FOHgkof42hFUishi0Jz
	AmsL8CO2U0wlgQ41rOnlKA/DjZ6xsGlswvYeUKLgbe9PZbfrTTsJyhWmJGGNsyVV0dSOkbg8pPk
	JFPEWNVZ0jnENZ7Jpsm8KxlTGFZtQEu0ghun+czfog5C/yRYA3TueFE6lftyfszeqUtPMH9hWgq
	Sjd4BhS0XaFv+/yTKqmM9lAMnwKgOEh02+MjKlA==
X-Received: by 2002:a05:6a00:9286:b0:84f:77cc:63cd with SMTP id d2e1a72fcca58-8616a06be4amr42617120b3a.17.1788891598814;
        Tue, 08 Sep 2026 11:19:58 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 41be03b00d2f7-cc45542b998sm2714294a12.8.2026.09.08.11.19.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 08 Sep 2026 11:19:58 -0700 (PDT)
X-Relaying-Domain: purestorage.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id A822234041D;
	Tue,  8 Sep 2026 11:19:27 -0700 (PDT)
From: tmenninger@purestorage.com
To: Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Lai Jiangshan <jiangshanlai@gmail.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Badger <ebadger@everpuredata.com>,
	Jon Curley <jcurley@everpuredata.com>
Subject: Re: [PATCH RFC 6/8] SUNRPC: Reduce rpciod workqueue contention
Date: Tue,  8 Sep 2026 18:19:27 +0000
Message-Id: <20260908181927.783442-1-tmenninger@purestorage.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <425864a2-3276-4c16-a861-32defe5e04e2@slotpi15m67>
References: <425864a2-3276-4c16-a861-32defe5e04e2@slotpi15m67>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

I reran the matrix. I'm at a loss for why, but I can no longer reproduce
the "bad" throughput with cache_shard. I saw that a few times last week.
Furthermore, the "bad" throughput is now a 10% degradation rather than 50%.
Nevertheless, it's still reliably reproducible when CQs all stack on NUMA 0
and using smt affinity_scope.

Patches 1-2 alone do not reproduce it across 5 trials where 3 of them fell
32/0 and 2 fell 17/15 on NUMA 0/1. All had full, unchanged throughput.

Patches 3-8 do reproduce it (as well as the full 1-8): throughput dips by
10% when all CQs fall on NUMA 0. Another behavior that I'm seeing again is,
within the same run, toggling affinity_scope to cache_shard fully restores
throughput, then back to smt and the throughput falls again.

The mpstat results, CPU idle times:

                        All NUMA 0          17/15 Split
    aggregate           20%                 70%
    CPU 0-23,48-71      0-2%                60-80%
    CPU 24-47,72-95     40-46%              70-90%

This shape is generally consistent among all three patch subsets: patches
1-2, patches 3-8, and patches 1-8. All of these are without modifying
affinity_scope for the respective defaults.

For patches 3-8 I reran the same experiment but captured mpstat on each
segment of smt -> cache_shard -> smt, on a run where all CQs were on NUMA
0, all idle times again:

                        smt         cache_shard     smt
    aggregate           15%         32%             19%
    CPU 0-23,48-71      0-1%        6-9%            0-2%
    CPU 24-47,72-95     28-32%      55-61%          35-40%

I've also seen all CQs land on NUMA 1, which seems less common than NUMA 0,
but the same behavior appears there with the node roles reversed.

Would there be a downside to using WQ_AFFN_CACHE_SHARD here instead of
WQ_AFFN_SMT?
