Received: from mail-wm1-f97.google.com (mail-wm1-f97.google.com [209.85.128.97])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D3BD54BD7B9
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 18:29:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.97
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789496948; cv=none; b=cEMeiMPk6tQY7LZ8mC8VfpHlgeuuZkgMTMmKIkwEhLPwO6IRbg+tEnmVQSn7ophNcEWXbQ1L74bvyJblNvRd/z0IkQF0fRRloSRG2GWsDZMNePxQouK8zdv8VWdmRpCiHrdEJTLb/q53lOv3jLfBZFe4zQ5n3ISIGhDOa7uS4Jg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789496948; c=relaxed/simple;
	bh=MrEZTfC+g+kxva7PRn966b+Tpu70MKEJcB5kPNVfj1s=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=smw2pcI307PyMRg0ufyf+O4m0PjzvxdUK5cUHWzivpIyVuLfzrw52N+onvjmDSiWXoxc2jLiofsUinymuejFi4EXJnkecMRhaR/607BQBvFRpmHgRSrODOthT6gNXZFK4RKoyqU9wR41fkON779+OJTE8oYw/xn29KJKx47H4k4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=RIzVaSP3; arc=none smtp.client-ip=209.85.128.97
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="RIzVaSP3"
Received: by mail-wm1-f97.google.com with SMTP id 5b1f17b1804b1-49e6b280cadso38684665e9.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 11:29:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1789496943; x=1790101743; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=MrEZTfC+g+kxva7PRn966b+Tpu70MKEJcB5kPNVfj1s=;
        b=RIzVaSP3L4Y2Uu6h4QkK7G/njvLEZM/Jm/JNyczMbL4BbFfif5RdhT86gDh96pD7kC
         LKuuM5FgTw7EdKaYg194M59I2MkBGtCkwsm9qvHQsOB96dRSjkTq2+4sJLDGo3TPOpoT
         Y5+FlWGUKfUUhyenAuEdv9w2h+spuabHNW/eunG4MPKNcxPdE+hmRF+EfSmyPTml1YS+
         aMPN6wrKWOmPppYk4xgsJFEDv1GG7pPPXAAPTzx5auaKdqavnnce8tBygRMclc1IOx4t
         ybhRMldVBLabTUuKGT8F5ktRO5jTuQj5euSoB9U7H0qva1drHgzL/W64KMf/lAx3Eo6s
         esiw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789496943; x=1790101743;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=MrEZTfC+g+kxva7PRn966b+Tpu70MKEJcB5kPNVfj1s=;
        b=CpkxMNjFMb7GKbh5NFzFs2qTVSMtDyKj3Hrmfe1OGOzNuOEEc3ON1KH8S1IdiaHS1H
         hiLuJlYrc7YzdJUwP38X28f8DCiFOHNwWTIuT6iNLrYhAe30HJuXqNJrfr5qzQa5xaNn
         tzZPwFW/jn2ZKyAuJtBYDOuYvcRgi/meXrPHjMU6o1QJO60XJ7ZQ4UrP+5vynWiB3Qtl
         +nXvk8FrkpeLiqeGdB/Wz+/eO0GuJg/jav5IkxaNoG2mBN2yLyevaABk6uHjwSPpmsgx
         SMaephqw/liDGTaQXxn1yjJeR62Ed3RtVbNJlUT9uOgBU8Wdss81R6zS1UySN3mnBcGK
         f91w==
X-Forwarded-Encrypted: i=1; AKwUvBzKm74XXD/0D9zXdT66dmkn97HnpYPFfWWWJ/4CnJupoJo9zVDLPbykxGh+JKI5lw5mM1ZTOESBD3I=@vger.kernel.org
X-Gm-Message-State: AFuF++mmyPGoR3KU/aZ0q+8xErfTKy4RWhmSDXqL4sH5hzSZi0BLymqY
	g7BcCstV8NLsVLU+Yep5YnqowfWyWdyRz3pxyXYvqmxhHg/97OSktKTBfk1IuLNtMt1xNoWDDnh
	esvjLNmvCtvlDmGeLE8piSeXoX4lpgnOJSx7o
X-Gm-Gg: AYBFou2c9sE7J4CuAUYbmG1Y3NOOiWRKtM3+zx1Yh0wM1kEaRzYXAUNZjXdZhhQdT27
	QdboYu0sWZrfzzXrB6ni+z9vQlQW0vCvrVSYD9qpZNNMcdlQzVllDIOMz/rr5HPDWp8OEt/TPBy
	9rzegU1wbfz5hJrokMsGNWHRhPAOILzhIgmJmAWOdyEhxU4bFF7GJmy37Ypl2ckSpu/Ah5ktXEF
	kUOWdiVE2/Oz2LFCiowsNkfchp0wq2/elBTvz8cXod/+wD61EbHOhAZn8+16IJTRpV2nsEOOwWC
	njMY7eONsDiCGgbm0HkS7FuQuB+jR1ZR8ousRp2tXSbQNRkHUglZtJuloPwZTJPZtZ62mcSkjA1
	K6D7FdPz53jDk4yrxrWWCuWE+93gKsX+PRothe3E=
X-Received: by 2002:a05:600c:c48e:b0:49c:fc6e:8cb4 with SMTP id 5b1f17b1804b1-49e8228f39emr33669775e9.24.1789496942659;
        Tue, 15 Sep 2026 11:29:02 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 5b1f17b1804b1-49e83daef6asm869685e9.13.2026.09.15.11.29.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 11:29:02 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 2178C3402AD;
	Tue, 15 Sep 2026 11:29:01 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jon Curley <jcurley@everpuredata.com>,
	Eric Badger <ebadger@everpuredata.com>
Subject: Re: [PATCH v3 0/4] Reduce lock contention in the NFS client
Date: Tue, 15 Sep 2026 18:29:00 +0000
Message-Id: <20260915182900.2995708-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20260915-performance-v3-0-ae26d460bfd3@kernel.org>
References: <20260915-performance-v3-0-ae26d460bfd3@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

I built and tested v3 on the same 96-CPU dual-socket NFS/RDMA client
where I reproduced the v2 rpciod affinity regression.

With the WQ_AFFN_SMT scope changes removed, I can no longer reproduce
the throughput regression on my workload.

I also reviewed the remaining four patches and found no issues.

Reviewed-by: Tim Menninger <tmenninger@everpuredata.com>
Tested-by: Tim Menninger <tmenninger@everpuredata.com>
