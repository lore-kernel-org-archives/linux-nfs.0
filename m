Received: from mail-pj1-f99.google.com (mail-pj1-f99.google.com [209.85.216.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 638E54AA59F
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 20:40:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.99
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788381659; cv=none; b=KdITY/xh9v9LghPsG7zliKMxQNtaaS2deCWPw/7bbUGYRwAQI+itLxt3nMbXLsh66850d/D19vfv08vIUBsPo5gIqPWakTjmQ18BYOXubZMBO/k69ShJFUSYU+Heba56BnPcfznIFIRPOHvAynCAWA3FcnMvNVEnJRuTN4nMSJM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788381659; c=relaxed/simple;
	bh=2AOzbfze9GxhHWoUdvI8sofdY4TtcK2hVkMRcbw+AkI=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=txzebwmUWnXw+z74dDEVjRnO3EnBEJBiEI/eNYIKVFRX0hUjEC8re2Vh9wTEZ4glkQmy/odvn+DoEWnvkST0NnywDCEb/tD/0jdgJsxGXCWjV5pT/GvuG67m1aHktMYYHqbi9LAACxx4z7mkGaep00RNENLDswI3VWsJmVvykws=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=csUzlSVW; arc=none smtp.client-ip=209.85.216.99
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="csUzlSVW"
Received: by mail-pj1-f99.google.com with SMTP id 98e67ed59e1d1-3964dfb5b9aso2037647a91.1
        for <linux-nfs@vger.kernel.org>; Wed, 02 Sep 2026 13:40:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1788381650; x=1788986450; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=IHleeibfspL0c+dohY0ul8TuzUb19RkhPlnJA1SPRN0=;
        b=csUzlSVWbpvQxbee8PgK+sEgnQ2FaSJ2QrcBTn7XGj0SP7Y/DtBnvktF+Syh4a5KFV
         kms2G8Bmozu4Vpr+8emRz2yd516woM0X5uZdof8vwxB3lS18txuOL3vK13G3+lzkFxW3
         l+tZhvSIuJHH6tMKIH6vs3VLI7KpAjYb2erWkwSRbNSpEVdsNLgq73DsrF3SQd4fEODR
         cyb1dFZH7xSYZRGjGpxx30GdWwGBliltTOgWsvdZCwH5jMFWDzlcfFVHB9nnEW02aLmo
         hpA4ymndZ0r8A5hu6akR3gdSMPv0ikp4BgbhlwTYlhoT0Zo8uV5JK3Vg/n3ZDntBsgbS
         4V3A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788381650; x=1788986450;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=IHleeibfspL0c+dohY0ul8TuzUb19RkhPlnJA1SPRN0=;
        b=SIyfxn9j3mKlIkN16pNoma861UQnBsQahGnTwf5tLyOGWIGflMjkALKFb4vpDT5QXx
         lHH5uXqFidt1C6Z0UYvZEZmZZWAghlLiC5/bc10E25dqDk+A8pR2txe+x4MtdM6u3ZLd
         Ie8PNM/NyvOXjx8b3DEdymZ4r5RyHc0o06NEDfKQlFjW6hSBxo9LtRdEax06QJZT+s9O
         wHeTnyD3jcyT6JzNqYdPMx1fOeZbEJRiYAZBAqJblQdN5103Ho88IRkPADH3nxYwgvrJ
         DZL2WSKUtMGuA1z3JuF2EwlSTBywOdKOGl/G4Dw1eRqhb9c99q99NcwOO3qKICOTQZwf
         jPpQ==
X-Forwarded-Encrypted: i=1; AKwUvBxk5Bru+LK0ulkFGmFmZQLUihOd8gy4GhY4QywNw2Sf9IH3H56Oz0X+kdmovCcoMrXX2jEH+EWdQ8E=@vger.kernel.org
X-Gm-Message-State: AFuF++kMBQWiAi+cVGi94iY63iwkosTg+iyaVTD9Mjs9sG7Nrk4JU4dg
	vIsRe4olupyg5UAqbstBavgnYD0zZxQ9Cb5f68PG17BvQYHPxOANsaIwhCGQxM39/V30+dc5U4L
	4y1KfXNrxX/0u3XjFv/uOfK8+eDXg9yhMdgRs
X-Gm-Gg: AYBFou0OLeCXk3DIhh7CJ+xmN+QrYLLU1NHxnQXyHCJGXlaCrEl//6GH8YjaVSAyOyd
	+G8rn+IOfGtL9YmIYkCdQAqDtZs8k2ldk7fVWl+CLd6jWYjyu1+CSr7v88BqdsOWNaamUy/t0K1
	RyOtnO4G2het1QXLPGio5+/Ktaxxjw2Ex8srNHEL6kVZGeLEYq3MLnW6ctnbmapQK5YtkOXcQ/5
	8EWb9Cm0lt63kOacn/PuqFB+ybrJHZydgnIq0wGSJNBxcnIV986qjbf27S042EPfSckLMTADPle
	jDnr8E8lf6sokqmsFNycpPhtN1xf3OwmJ9dY582qKQNQHusUWnCOBIVYPpexfxiuatJgj5Gx4je
	Mj1QIO31x5Et4rnjqLo+vVg3hqjQsG51FXUqoAJM=
X-Received: by 2002:a17:90a:c10e:b0:398:c3a3:dbd0 with SMTP id 98e67ed59e1d1-39aedfcc05dmr11464023a91.8.1788381649998;
        Wed, 02 Sep 2026 13:40:49 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 98e67ed59e1d1-39b0e607aa9sm61929a91.5.2026.09.02.13.40.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 02 Sep 2026 13:40:49 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id B4A553402BD;
	Wed,  2 Sep 2026 13:40:48 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
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
Date: Wed,  2 Sep 2026 20:40:48 +0000
Message-Id: <20260902204048.4100864-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20260831-performance-v1-6-8d9fd9b67f96@kernel.org>
References: <20260831-performance-v1-6-8d9fd9b67f96@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

I am seeing a significant throughput regression from the rpciod SMT
affinity change on a high-throughput NFS/RDMA workload.

This is a 96-CPU, two-socket system with 48 physical cores (2 threads per
core). I bisected the regression to the patch that changes rpciod to use
WQ_AFFN_SMT.

With the default cache_shard scope, the workload sustains approximately 45
GB/s. With the SMT scope, some runs fall to approximately 15-25 GB/s.

The failure is intermittent across workload starts and appears easier to
reproduce shortly after boot. However, once I have a bad run, the
dependency on the rpciod affinity scope is reproducible without restarting
the workload.

For example, during one continuously running workload with the regression
actively reproducing, throughput recovers to ~45 GB/s immediately when I
change /sys/bus/workqueue/devices/rpciod/affinity_scope to cache_shard,
then regresses again immediately when I restore smt.

Nothing else about the workload, mount, RPC connections, or RDMA
connections is changed between those transitions.

On this machine, wq_dump.py reports:

    SMT:          48 affinity pods
    CACHE_SHARD:   6 affinity pods

The SMT pods correspond to one physical core / two sibling CPUs, while each
cache_shard pod contains eight physical cores / sixteen logical CPUs.

I have not yet identified the exact mechanism that causes the SMT
configuration to lose throughput, so I don't want to speculate about the
specific lock or scheduler interaction involved. But the live smt ->
cache_shard -> smt transition seems to isolate the regression to this
affinity-scope change.

Given the magnitude of the regression, I think this needs to be understood
before the rpciod SMT affinity change is merged.

I can collect additional workqueue or scheduler traces if there is
something specific that would help characterize why the SMT scope performs
poorly here.

