Received: from mail-ej1-f98.google.com (mail-ej1-f98.google.com [209.85.218.98])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C89D24A92DC
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 15:03:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.98
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790002984; cv=none; b=NL+dcebf7GC8ZdZJ2hZSyWLZzu9m81ze1jiN8jWWZaiK9eOwYwnDFzReZ0cT+Dj0ydfQyFMgn8V5saAYlMVVmRDcMVtOPcvxMmiOTKn19Q1zSxqJG0n5Z+Bc2CnRUIahvi6bKMLwbRC4j1RVvnF84dWh6McHXxp72ZhTOOnEGzc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790002984; c=relaxed/simple;
	bh=YqK0OIsbRJBMZV2x+UmnJ/uqWPJn4bDV3V5W07DY0WE=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=FKXyFjZ2cbD9j9QrSsrsSHN25cRzeANVjq7bd6D94f+ipIC+/+ZQcX5rDMnUNzkw23Ms1c0N4EiCjqpnDJmGWoj+Mrrpzqn39QnwNMPS7nVcbo/wrY7YAFMgUYXlPTifwLycZ6Q8G8Xj/pkccSdtcht98lD0P0bfdWIiMoLCcAI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=pL9Ngm5h; arc=none smtp.client-ip=209.85.218.98
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="pL9Ngm5h"
Received: by mail-ej1-f98.google.com with SMTP id a640c23a62f3a-c253425b253so96636566b.1
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 08:03:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1790002980; x=1790607780; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=YqK0OIsbRJBMZV2x+UmnJ/uqWPJn4bDV3V5W07DY0WE=;
        b=pL9Ngm5hN2/UMwLXuA90MZ0fuE6Le7KlVYCGYuxKfuiUDGN/gx64rSZGvgsC2txHm1
         jsf7rzGhH5JMpwjxe32ofiv9ImF01q/LQm7wBZaJosHwaVgYvlNsS2Ent9Tan+nl0zqq
         U5sUwDWb1a7oVmC0xJJSR8gSouCTLfeRDeS1Ett/D5rOAnFEV8R81xYPMfMjsZVjQFKF
         rnnxR0WElVi29ChATzgaesUM54xf9PU31IWtYQ1DLJfx3A74KOtbNWFtPcZnyfIxA1nk
         DvFyNCZBrrel1gYYNIbpMFwHGChkP7FO805Sla1IZshW6NGHTKL8keuAWSTompE4xEQ+
         dkFg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790002980; x=1790607780;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=YqK0OIsbRJBMZV2x+UmnJ/uqWPJn4bDV3V5W07DY0WE=;
        b=YKtgl2Xyw4S7ZSYr/HS+i4whuyFbV2s03f+pGkRnsk8XrmICY+4YMl+3bm5pNlXZp/
         uIdOzx/benq5SEHUAUOY7eALtaI9CPvoS4nTNmmJPrvv0kGsc07cenwy6HM0qCi0eEaP
         i+qlvCagb6RfC+BLUNzxLsBr3vPb5HGwe6nFS4dhEgvGaf9PbqZQFNAF323rj+hBaDAw
         K6uTt2mlFJGUY3hQvjaJxCbm2rTWxSlh8Mmr2XqcSnL2vwqt06TOjHHC/XUCvo2Nx4Aj
         ko4z/9DB+o2WGZDhtNfRf2d2rGdJhJVnvjtP45R4JXgiB/+AAdVpozHQuwz0QSxshn58
         u4ZA==
X-Forwarded-Encrypted: i=1; AKwUvBydRqq6mz0W+WGkhetxvd0VlTulg3jReA6v5mG3imgRJV8/isWKGjoEBz++ZY8Ngl11akFcEfJQyyo=@vger.kernel.org
X-Gm-Message-State: AFuF++mJOUYGyr+dWX3JuKT7hH502JojfSWCqRwZFRE5+hyuF3nQxZ0K
	T9Qt+xXqvES78WSa/IKTsLzRpZNvjMdYIiI60KHXfY776YfjbcpNWhop8y5mlGcoTlve6A/dOMW
	iPzQPvj2FAew8sc3Vn5RphXqcFdd0sY2Gyp6S
X-Gm-Gg: AYBFou2FqnXm8YYdqZHfsxg9udwP32xtBzb0qCPdrD4WF+hxwTKX9WX3CbcHKw5K1+k
	olthuIjacQAc+wUSzGDMlUnuo/E/eyHk5DNCoEr69wUSBXupHJJLNtnNdgcX5fTTfregjzPWUtV
	kZIY9HdI7fevZvzdRCta2/EEpo46HZoo3e6oU7wjrh1pIVjC0QnzgvtCFOIUPMnGYGUvwKDaMfc
	6GpnuE55rX/9l8z7wZQjWxUQzcK5H8ow/s7KM6HtOMqs2Gd7tFMGzWN5C/FU3VbOgY2CGf8kMXJ
	n426QFgf4Vzu66wadVGknjo8TaoMzbUB6WG4kCChba0LnsOHkWFaR3dDOwkAuko2iKg1NdNUTfB
	z9zDxhbLInSORwb74gpbI4/R8XwnNB91ux1hCW6Y=
X-Received: by 2002:a17:907:d2a:b0:c29:41e1:c918 with SMTP id a640c23a62f3a-c2a1569a2bamr930945066b.1.1790002979541;
        Mon, 21 Sep 2026 08:02:59 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id a640c23a62f3a-c2a358e15d6sm6289066b.32.2026.09.21.08.02.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 21 Sep 2026 08:02:59 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 14CA63403DA;
	Mon, 21 Sep 2026 08:02:58 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org,
	Jon Curley <jcurley@everpuredata.com>,
	Eric Badger <ebadger@everpuredata.com>
Subject: Re: [PATCH] pNFS: avoid repeatedly cancelling I/O for the same lseg
Date: Mon, 21 Sep 2026 15:02:58 +0000
Message-Id: <20260921150258.170643-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20260921044730.24614-1-prabhakar.pujeri@dell.com>
References: <20260921044730.24614-1-prabhakar.pujeri@dell.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Prabhakar,

Thanks for the review.

> One bounded-behavior point: with the latch set, if the driver's
> cancel_io() did not fully cancel on the first pass there is no retry
> -- intentional, since the lseg is draining and cancellation is
> best-effort, but worth a line in the changelog if you respin.

I'll add a note to the changelog and carry your Reviewed-by if I need to
respin the patch.

> Posting carried no test evidence; understood if this was observed
> under real RPC/RDMA data-server recovery. A reproducer pointer would
> help stable reviewers assess impact. Optional.

This was observed and tested with sustained pNFS/flexfiles I/O over
RPC/RDMA while restarting the NFS service on the data server. It was
originally seen on a many-client many-DS system, but cleanly reproduces
with one client and one DS.

Without this change, repeated cancellation of the same invalid lseg
drove the client into a reconnect loop with essentially all CPU
consumed, and the workload did not recover without intervention.

With this change, the client recovered after the data server came back.
There was still substantial RPC/RDMA reconnect activity and degraded
throughput during recovery, so this patch does not address all of the
recovery behavior; it specifically prevents repeated cancellation of
the same lseg from amplifying it.

Thanks,
Tim

