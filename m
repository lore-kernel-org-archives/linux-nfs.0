Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CDF432931CC
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474955; cv=none; b=U0r0OXA8f4yqLAnS1S5+1wX7bD3M+MTo8O8Q58HdxRERU+3cAJqj2QMm2rr0hOEaJdbXf49hXxtAwEowCpE9qtePF1wsAjwRrK8s/6SAlDgC36fRqqLIN8G08n0zm0dvgDiDpJNdrOCq0wurV4DfNCQb79eMFQ6eav3zcJbJKRo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474955; c=relaxed/simple;
	bh=8/LkbZltpe1muds9FtVTQxrUU/859tWZ2Nw2rJ12aow=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fOOUX3Yckngj1mVFvkG+q2eadOPd7EP5BnlguJFQbQwfXtMluR7NActpHxIW8LUO05maeAtvgaaYDJx5IwCC4UVFwRsYG05pilsgmOzgoL0JLLK1Ze3roJrdkcCj8dt8djFaK7fgIQlscvS+jRWsmmuDGJQ9FLovHvhjKJAMtws=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=lDJN9RZK; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="lDJN9RZK"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4c6ed1de994so118896b6e.0
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474953; x=1790079753; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=IHdbIheE2uWjB889IxsFeSKw2QDXTxO2nQxLG6ECF+g=;
        b=lDJN9RZKHcKtbX2LyoOP7PJP6ZpBA9K3fVZNBWcJfHMsGBj9MDOGMv1x1eCFA+S4IF
         hopEGjJPiB5wvnwnw1SaZyGa7gtQ5cwaH0COv/pE5hl1XlyYUMX/nOMaQX/fP99i/XOy
         Tx6zYB7a7onpGMsQTts8kyMN4egh0Ip3J9Fjdm4HmpRNaOhKC8/rcLsNe5YG9VUs5woj
         eAw2DZNcoZmX9y5NZjDhH8VGTGJO+yaJhyOaym/z0ItvUgNzH+kqc7RfbTLKi3A/eNg8
         e+NxgRMiAWAQ8jvoJx6B4Co+w/HKg43SvB+yp5+ZxYoYiBX9wdEm3gvwJ5kv7Tl6keME
         7tqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474953; x=1790079753;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=IHdbIheE2uWjB889IxsFeSKw2QDXTxO2nQxLG6ECF+g=;
        b=z47Zp9qlDKldCRfG501Vou5HFFh0ENHKfw8SOIVZwJKs4y8iv2Y/tRsg9i2KTmszk1
         GNsB/vxpo9iq0ulfflNCTWfozIyRQM85DWaf55jaRwUVBGMk+Uf7vfSQlw9HJTceThBx
         rhlaWPPm9KdnNjxshpU2G5rBLHx5KnnU99JE3pg/5qCLnhNdK62LxqeUah1iU52a6GF1
         laD0q+D/OLhPCUYk+w4aA1HkEl7dC/LJb2Riyg9SrKjqQ5LRafn2MuOfFRKgK11ivB/a
         FBMG6MkTGuruHa8yljC9o3JGjTmjsdTBWJnBZNH+P2tG+fohjRCSMvhPLEfhH4ft+q+1
         mSpw==
X-Gm-Message-State: AFuF++nF0elng96EliSBtoHg8Ypis9AiWV3RHxm77QZu+lO4TgxpyWY4
	WsOOTa+0xYHo+3VwZrmwtxBT0CiPtrKdYdm080gJ23LxUstS43587aG9sZcV/IVxL8M=
X-Gm-Gg: AYBFou3aQwsbwnbT6x7dM0deigqikJoWRsr6m9Z33krSET6iOKdvKWoREpvZ0yjiqAg
	g3yAA4YlRWNMfEC2MbBw2Rcuo0+u82tmrNZIvfOaVkLpb2YmaP1TF4iWVCCCZPwW9W2HemDffWz
	mgkZdYr1MemCr4r798n+K4dpHZTq3wLYYsmegab/PjntJJ/4qcar8OWRzjeKSDveYVVcS97lRA6
	9CbMq2ThS4c+EZdj99GRmhOAoF2EK5mb5E+fcdKRwfM2CHrQP7OaT4t9CB6PYO3d03QFqpa9aXn
	wesniaLitSkjTG0m+o91Uk6d1X+KNPreGZY3ynQ6yqBb233JUAaTvXRh8Dy7BI74Xt8bh+VRjgA
	tkFP1gfZXi2J+wr/8BxsEjgDsBOJ4PZP45X78ZxwHWI79d91cmb0INLh0RmdVOv93ppGMhnoBDF
	2FC+RdlXkoRwVsFc3WWupJYgODgZTCMHB8FLMUhEYsSSHZVpxi9mCQn7lZuA6xUCEP99dMoWvW+
	RP2qRPFj19JKTtLIDH9wFTwompEFkbkM6w=
X-Received: by 2002:a05:6808:1823:b0:4b3:7fa3:890b with SMTP id 5614622812f47-4c9a845c11fmr577620b6e.2.1789474952604;
        Tue, 15 Sep 2026 05:22:32 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:32 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 03/24] NFSv4/pnfs: bound the CB_NOTIFY_DEVICEID array count before allocating
Date: Tue, 15 Sep 2026 08:22:05 -0400
Message-ID: <a4a3e33604e6c29d215bf2ef81e4fc6ad350cf19.1789474702.git.bcodding@hammerspace.com>
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

decode_devicenotify_args() hands the server's notification count
straight to kmalloc_objs() as the array length, without checking it
against the message that carried it.  Bound it the way nfs4xdr.c bounds
an attribute length, against xdr_stream_remaining().

Fixes: 1be5683b03a7 ("pnfs: CB_NOTIFY_DEVICEID")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_xdr.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 88e1af0fda01..b1bc2c02b5a6 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -271,6 +271,13 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 	if (n == 0)
 		goto out;
 
+	/* sanity check the count against the remaining stream */
+	if (n > xdr_stream_remaining(xdr) /
+		((4 * sizeof(uint32_t)) + NFS4_DEVICEID4_SIZE)) {
+		status = htonl(NFS4ERR_BADXDR);
+		goto out;
+	}
+
 	args->devs = kmalloc_objs(*args->devs, n);
 	if (!args->devs) {
 		status = htonl(NFS4ERR_DELAY);
-- 
2.53.0

