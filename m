Received: from mail-wm1-f98.google.com (mail-wm1-f98.google.com [209.85.128.98])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2AE5A4C6EF2
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 23:25:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.98
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789601149; cv=none; b=jJpN3Y8pMC/SMREHZobuH5WWo1ZqTkJRkmQXtksZwhKft1giSRpoRTc8U9xrBwn6AjIRGb6lSDsNM6WqEI7jgUYHVkSF1/W9Za91Hk4cr9k6UPfxW5WEY6xG4Vio+Vtp3Mm0Rb/hLaaZYrU/FgJ8xaKVjbHvEN0F7L6vV1JxbC8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789601149; c=relaxed/simple;
	bh=abZ+0AvUY4oazPRqaXspWDPFpaIpjOBE+mBXBPZkJLw=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=Arah3aiBYiLtNy+wchHs1qHpHzABXDZwTCD7jJIEvZj3DewSZs/h3ExQtmFu9cKg3kO42h2i6POR1WIDVDodRUIaUrEtEtXop+THt9VwE46bOY4jBRcLDzZuqwdKF5JVmDEed1Uk1L9/AFkYfBW3uI+3td3lvvAEPkAj8AuJR7A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=Xf72g0Hz; arc=none smtp.client-ip=209.85.128.98
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="Xf72g0Hz"
Received: by mail-wm1-f98.google.com with SMTP id 5b1f17b1804b1-4980fe6b3beso904915e9.0
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:25:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1789601145; x=1790205945; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=PPMmzeMGw5inM8GWwOz7lS3Of5P0aQnoyqgcSMcVsuo=;
        b=Xf72g0HzpXjPRHx/aZbRnuHo7gLoR9zyhVlhb6+DSotRD3cjWSKzlmDIyR4mjbXjG4
         9+kE0dy0h1XQN27MlrUc4NgMYzl53IzqfY62FozdGeMPBKEv8MtfA4OpaAnAetrkp1RG
         /XDmX5YPdS/EJuYlFWZL+x9zX0qcjjV0WBSdE1wlLA0gwvtCK7g/v0M7LihfmxajNbm5
         cqS+3nlUevJHEJHD3pBYNAU+6AxGvYTzJYDbV5FALCPLK7ip3pTguriFFHqfDPQ/Vl1y
         3yQs5qS5rTo88jlYVNbniOL6Y9Y3OWpYn1mKeEC7BGpZPb5kRcJvz+gilRIpBrhhCE89
         zhmw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789601145; x=1790205945;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=PPMmzeMGw5inM8GWwOz7lS3Of5P0aQnoyqgcSMcVsuo=;
        b=WzxO2jor1B/hfjTxWMbjDY/Gjb9i7itPwU5wkiWaaCc84Arucqa+K6CkKGUb6tfB/0
         iWuigVPnZoPTIlykwJ8sMwhVyRCHjV7257AaIHAB0xxXaIyOMyIsjdrnbxdhhTdXfDxZ
         gasZU0mADSp2E2WMDnfC/MkkIYBShhwv6MTlBG+s0WTCHs662vmjZaPXFqwNitYs2FJu
         tz9B7cLS6LxUEUdbLn60cFrBAOkftKFNw6hmWfaZIayX2bjyCdPoh/t7vCt2sVoDZACl
         FexKxfnHYSQL8FcJteMDCSiBrlVii1Fk/5wWg0SjVXE7d/BqllGgj2+TT8S7/ZVSmkzK
         rcvA==
X-Forwarded-Encrypted: i=1; AKwUvBxQGfTWrN5rGK049jBuQKjC1MY7thg1x5J51IX3GyIxYd6gvx0S5t3pxZK5hwKYqLleUhY+9okyyCs=@vger.kernel.org
X-Gm-Message-State: AFuF++nl1Vyu4ZzAyFiFSTKLOAx3k0f1WwR4YEfGxJiXPcvyjFAz9rpl
	dBO444nP7835tiqSOnqpiOAX7Lz+OJt9srXSBuTTec/UKSwloTYSHTxCG8bYzSPLxe/eiYIIUE8
	+EosfjBRP+H1JbaRh3lB6y445A/REPiWBFyz8
X-Gm-Gg: AYBFou0FgVedis3GmjWP3WCx28e3p/6SMUdu1P5Hu16ZqmYkprwXLzV0hh+qWJ0ngDi
	+GXNzTdYJ/T5NBiWfZGIIC07PCAjIeZutFo1CmCm1oFEo7ut3UlkflNn0nZgZUPUK3SXQyc3J6/
	NlYF3pbmeD5ujQoNROD1Q0hrCyvqG/GQW1pNaAX8wkYJRibizTXfFwzi4KzsrpYuKiOeYc4YHWX
	Ej6GcR6Im1AJWkCn0NfeEQ9d46trQRa6VyGNmwas7xPRiCc+RA4LlhOMxX2+t7Ivib4LQvmkPVJ
	xNzRSAZ/x2f4y2w1eWHEamzRhXqjk1LmC3sbnAeJJAGV/YoIwkMX/zpdoNmvILtJKOlIDiOWwjd
	1/tYKAcqJegKCZqyR31BbbJEroXdeYltWrymDRBI=
X-Received: by 2002:a05:600d:8643:20b0:49e:7c8c:bc77 with SMTP id 5b1f17b1804b1-49fbd1c9005mr12325555e9.7.1789601145442;
        Wed, 16 Sep 2026 16:25:45 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 5b1f17b1804b1-49fbd520ad4sm1982415e9.1.2026.09.16.16.25.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 16 Sep 2026 16:25:45 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id D574934014B;
	Wed, 16 Sep 2026 16:25:43 -0700 (PDT)
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
Date: Wed, 16 Sep 2026 23:25:43 +0000
Message-Id: <20260916232543.4100078-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <0e2f9688-097c-4bb9-a7ec-82b41bdb3653@slotpi15m67>
References: <0e2f9688-097c-4bb9-a7ec-82b41bdb3653@slotpi15m67>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

I took the SLUB side of this to linux-mm as you suggested:

    https://lore.kernel.org/linux-mm/20260916232227.4098143-1-tmenninger@everpuredata.com/

The more careful reruns also resolved the inconsistency you pointed
out between the perf-lock wait time and the idle CPU measurement.
When mpstat is collected during the same 10-second perf-lock window,
the machine is almost fully utilized and throughput drops
substantially; without that instrumentation there is significant idle
CPU remaining.

I also collected cmpxchg_double_fail over uninstrumented 10-second
windows in several NUMA/CQ placements. Those numbers are included in
the linux-mm report.

Thanks again for helping separate the allocator behavior from the NFS
regression.
