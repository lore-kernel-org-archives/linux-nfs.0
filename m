Received: from mail-qk1-f170.google.com (mail-qk1-f170.google.com [209.85.222.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E688493625
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 12:56:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788526582; cv=none; b=rTThPO3JAOJCP/1FjT8vCAf/nO2vD95AuzsOkKldfoH/bU60bl4aTx2mUtANPVoHA4NhVYoFLAyON/yhFl1nybeMH6SPDsv3RQsJVYrLC4vGuDE+l/Hyvk5U/wjNJuVIN8Ub36Qke0b6bjUxpUbRkqGY2CIFmG+LYqgT44YRLss=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788526582; c=relaxed/simple;
	bh=ag4Uo3LH5x3vtapELOO9My1VAOChaTe+9oGi29SwAXU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WloZ48vM3P9JSGC1zjrIIu1Howq0VrofOZfPL30eLJ8V/0Wd0dZku0q1B2X936sRLSwfMBba1sDsp+XRbyn4hkjfGpLUSIQ0qAt5IxtIBrmBCByetOufYJ/ch8RKdeeGGamWgTInHxWRf5v5y1DSBXuOSd3WX5u20O48OkjHKag=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=ljBbGb9A; arc=none smtp.client-ip=209.85.222.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ljBbGb9A"
Received: by mail-qk1-f170.google.com with SMTP id af79cd13be357-930f618435cso107122385a.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 05:56:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788526579; x=1789131379; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=uzFH4Zom6AbRRdI7xN8oIq/v0nBv6CZmSa3K9ru7RRM=;
        b=ljBbGb9AW79x5P38EgdU4US6CfVkZAW/wB6k5BTIghgZvgU0+zjAk13hzfJqJdbdB/
         sUO0DxUohRAlCmH7MoIDUlQhcBn4akWYfqw8zFMH1bRvagPaI/YzqzKZBuj8Qc8azGko
         adXrxJzoxLI+tzQLJO3NdqNpvaJQ2xNTAkEs2iG/9LHCjmSopMHJA0B6Zk1zoimoqVuG
         ZuxYVBEAx2zYsqKPPunracAH5IyH59Yp848iDoAVZYl93cqUUAPn3u4kOnhTSlRqVsz0
         sTmaMPB0nERkTud4qL4Wr01xogHQN41t3phtS5ALVsWi8QIKisTvU4Yt9a5xYny2FHO2
         kRCw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788526579; x=1789131379;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=uzFH4Zom6AbRRdI7xN8oIq/v0nBv6CZmSa3K9ru7RRM=;
        b=g3JmVOoiDdgnvUnm6GfJ/rfOeeedwNG4crOE9G7XAbaoLOBSQDbdrbaG9dsfBgEkCC
         Y4XKdBiXJ/94n0XAgKYBAuHMzE5xGk9dXxhCNgSSoKxHNt1G6VbIAZo0gyumiK0omF5f
         3lZUbyVijj0pdzor73tFK8STpfqQsFIpPoW4/1EY6GP7PdwI2Z6q6fhXbUdJh3KpK0h3
         Sih7mfGY2RoHSRd2GFc6/GQTR0hWVFTSGBUERZFejfIFT0K8dMNvsgrDbug8IUfudnuU
         WIG6lxAquljeQ0T5VQR/LsjRni6ISLt5Fzo1GBEdQaNUmx08u1ZbWspsez53qOJCThsI
         Hmvw==
X-Gm-Message-State: AFuF++kkE0RugarR9jjHYrJf5G6BMcRexPbUaPIe0WuXRMxD6enQOItl
	50pIXeGV6D5+Hx124XyMiLbPgTuAaA5Moxx7ja5UWkPHdyHigA0iKjxt2w0KP/cvFfM=
X-Gm-Gg: AYBFou3aPfpL7aK6vi1FfP5u+oVO08e5wnItp5APL9jAXYA2l4gpGjGjWHb1v0Y31o1
	LtGDMIJi48qqybewStczklDcsSQVXQL1mDYPp4PNhg8CuHA39bik0xYwGe2Jyl7j5rWC6dHayYB
	gN5OXJf68Zplj4yAOKBBuPd3xXwZKrcukjdJofMFtA1zKf04zqXyFQNJ1UHBm7YvxvHlJ2mvXRc
	FP7favDdBIS6YUMFmWWfmkpYZQg2Pmk4FFt1+Mb/mcZ6mmst98fn+OjZo5ySq92MMtz9JYqcxWC
	VjABA8gx9QTe6bZO1SW7MJf0XYyqT/VeLHmsYJ9jdHRb/s46Iwa35dFHLV/hz0rhMySDVvkWtd8
	Wtyu2B64sdHu5xQ7hpR1Ratks60k81KgnlfIZztOwzIM9NUQm7HMjL5QnFkN6SurDkNXpl/S5QI
	CSCNIKM/aUB+/TT8FLtgW4MBXYXHuSm6U1UrIdmE4M5wbf7e+67BLQC52sWh4YLcv1qHwpZT6Hv
	U/cAQbQl2icbvkxCDoh4yip
X-Received: by 2002:a05:620a:a00c:b0:939:6dbd:de57 with SMTP id af79cd13be357-9398043520bmr515469985a.32.1788526579365;
        Fri, 04 Sep 2026 05:56:19 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fb2fd82sm203324985a.17.2026.09.04.05.56.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 05:56:18 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 4/6] NFSv4.1/pnfs: treat an oversized LAYOUTGET reply as -EMSGSIZE
Date: Fri,  4 Sep 2026 08:56:05 -0400
Message-ID: <95a22363196fa21f38b3055141199c68bbf5181c.1788453839.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788453839.git.bcodding@hammerspace.com>
References: <cover.1788453839.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

decode_layoutget() already detects a server that sends a layout body
larger than the reply buffer we provided ("server cheating in
layoutget reply") but maps it to -EINVAL, which pnfs_update_layout()
treats as a transient error: the client falls back to the MDS for
this I/O only and re-sends a doomed LAYOUTGET on every subsequent
pageio attempt.

A server that overruns the reply buffer has ignored loga_maxcount, but
the client can recover the same way it recovers from a conformant
server's NFS4ERR_TOOSMALL: return -EMSGSIZE from exactly this check so
that the layoutget path retries once with a session-sized reply buffer
and otherwise marks the layout mode failed and falls back to the MDS.

Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fc049ce4ba8a..8b3d96b4a0f0 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6187,7 +6187,7 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 		dprintk("NFS: server cheating in layoutget reply: "
 				"layout len %u > recvd %u\n",
 				res->layoutp->len, recvd);
-		status = -EINVAL;
+		status = -EMSGSIZE;
 		goto out;
 	}
 
-- 
2.53.0

