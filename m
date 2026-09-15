Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0325E3B42E1
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474956; cv=none; b=J+hYW2cEagGZVqj4uggWPyzwJrKSLR7/RJpWc+NZwn24VbFHBFFWP9hbra12iDa5Ia5y+86ih0PfiLJeh701HGJF8TijtT0akVwXNbPDYu1DIQx0aFLld4ysEt0p2rTGF+mk497p7/coAt5pNkXGl1gHiI8JOSdrCB+XmrUt8w8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474956; c=relaxed/simple;
	bh=rMxNuG1j+cuZMcGBsjm3J6+c/H7kOhH6f/IOwhWVfeM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=EPEHqgpFPnNHf32N6YSWfgKo2TNjrZPZJTBjB2AQXkaTvKgv2DhjSUlWi/HRdDNIkVBorvm+j+JWyK59QwIelLrCgPJx/aTcUGAg/uz8HLwr/Tr9490bWVZy9cO8/TiJHsBuPpBC+PQDUSrtt7Rt5qgeB+8Ql1ktjmnig81OLGs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=jqOMhZ6d; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="jqOMhZ6d"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4c13f2685f2so2093900b6e.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474954; x=1790079754; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=FbwfmcQHpt9ILBq0YzZZ2JMYeFnfCP65xC+vbrXSm2I=;
        b=jqOMhZ6dDbBc/4dJY6JCupMlX1dmfXjrKmQAbM6QO/DVwfcFDFJ/o82N0dwd4Hilrt
         E50fmBFDqW5wjAUlVTQ2woHOdlca1HqsPPwG84e16EVqYfIT7du9ZmZqLPUsjZ4zAZ4S
         keFg8f8+4WTW3Y6M59gHGj+fFmmNYD6dUlAoVj5njhB3UU6y0WxJGz4ECcnOmXgAtomn
         AnvXi1spNkmhBm3Jndk3EGaVUe2ltxiWUfkGgw3TnI+TXPeb5clcosSiEAtJ3Lw+g7Ae
         gQjJBHy8qchqyNAxFu/css/XYe4nkPtS8ww9mFdG4W45/79c9VTvuCQVGPGSH/3qZOpN
         CLiA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474954; x=1790079754;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=FbwfmcQHpt9ILBq0YzZZ2JMYeFnfCP65xC+vbrXSm2I=;
        b=wuLv556lRlaHcYxKccExzpOhXQ5ZK3jdazcCax6ysvbQ7KzWG6PJjLS1pun56Lgse8
         0oKasaWhqIKGnzAi6Z/4756N9sqKMotraThKdUV+YhS3kQD3T+WiOH2C77mGdDeg5jed
         wEaGxOm1Co/sDP+ko+4AbWaCetCx6ob0Xqzo7yqYFZRdfQ6ICPGy3PPdqRA+QPG9RJTi
         9DirF3n11gjKdnLx3NacywmUF660h0JhsgAA6X3AcDxUe3EzdzTkkeGi3w1kFdkQjSYD
         GewdLjBBrm/MjwRNtkQmltxyMEjhfbXw0VLvX2WthxSsaZ74Pg9DrE0Zt2OuExvlBggc
         3h0A==
X-Gm-Message-State: AFuF++kfTrqrSKwx7y9TmZdv0u9b4Sy5OF89lYDs8PiuXn0I4mbJ3rp4
	wBFNkhmbA1I9QALicMVA9srIacfoK0hqniQNUW/sERorWhH7rEZXBrN142JUHsb/7AM=
X-Gm-Gg: AYBFou2P1CY7eMFNep3qMAAIgP3NQJ6KUR5tt6w/kRytJAvfTZU2Fb+wjE6TQHwhLZ7
	qnVFBeIZO1rsRc+bXs/WZPy3VRwdi5MQ6kMpNdRq98V5VH4L9zvwiv8hXFR9hcR0Rm5whf1kHFI
	qWNwBrT2TXg7tXFPL71lbaL/oCxdu00rI9Y+7kwBQwrIdvCkVqAKZAhEZcXoQ/J9wqVOOAbBu8O
	wznd1I0snr4bWLXpW33Qv6bk48FX78BspOatJtxurtT6BKMkss5queCG0kE4pm0lnIAcR/2U0n2
	WUnz+h0gtAQ2mz1QjiOsXhdxP/A3Avg7ESsJvK4uVpanpACMB0aB8yvQfoB1crYjenU7w1tX5R7
	7J30Ahqk3IfHSxGcuRnB7NRelGIU7doIEMe5xC9RLqj16hHWAUc2ntwOh3sTuRBzGecFGF0BW0i
	nS9/Z3oAuWAJm2Ri90DWXY2BSKk57jy6ES0EBmxtgTTI57Lqy0Who2qYG/bqS+iQ4uvIJj0VNJ/
	E8azKnkdOpgXBBwiThtmkg/iZTL6zeZMkDh
X-Received: by 2002:a05:6808:690b:b0:4b1:b83a:5878 with SMTP id 5614622812f47-4c7b3ec59c8mr4913669b6e.14.1789474953584;
        Tue, 15 Sep 2026 05:22:33 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:33 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 04/24] pNFS: Fix CB_NOTIFY_DEVICEID CHANGE to consume ndc_immediate
Date: Tue, 15 Sep 2026 08:22:06 -0400
Message-ID: <ec888f9f1d2e0e8ab8a11b988e06225e6296b020.1789474702.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789474702.git.bcodding@hammerspace.com>
References: <cover.1789474702.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

decode_devicenotify_args() gated the trailing ndc_immediate on
cbd_layout_type rather than cbd_notify_type, so the flag was never
consumed and a multi-item cnda_changes<> misaligned after the first
entry.

Fixes: 1be5683b03a7 ("pnfs: CB_NOTIFY_DEVICEID")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index b1bc2c02b5a6..5a1f05469268 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -319,7 +319,7 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 		memcpy(dev->cbd_dev_id.data, p, NFS4_DEVICEID4_SIZE);
 		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
 
-		if (dev->cbd_layout_type == NOTIFY_DEVICEID4_CHANGE) {
+		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE) {
 			p = xdr_inline_decode(xdr, sizeof(uint32_t));
 			if (unlikely(p == NULL)) {
 				status = htonl(NFS4ERR_BADXDR);
-- 
2.53.0

