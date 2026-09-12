Received: from mail-pl1-f177.google.com (mail-pl1-f177.google.com [209.85.214.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8F29374A12
	for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 13:56:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789221390; cv=none; b=nWkz2tM5vgPImBEBV+OKMO4RXi6ulN9HpoDByG5eYVpfFjdgAy6/r8GsvU38IDXWZeJthEDcr2iIu9eC3lPKzl08aFH40uUHO5172PpZjNVLy/r7Sxwa9A+ylXYX2+roX2Gr1buW5rbKpSbG1ntoWUDQOpQqPjb3w0ykrL8tmd0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789221390; c=relaxed/simple;
	bh=r4qr1atOhqzJgVEOo1uT7xsHaD3qDrrY/KwK5TvOYyk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LOjDQNhLuu2LYLbYMUbzSgsy1Z/7xZiCZwg39BJZ7vzrI+7vaTAwGKwz7wJvjMouhkakwArO8z/LqKOZ5e9dz6LCWx12B6alqhg7BStUeLQ8ObjQlBrfAPTUfoxIItJEuSsxgQ+7D4MUBXxh+hrHs0iSuBgCPmZzxxj3X3KpgWE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=kOcOcjPx; arc=none smtp.client-ip=209.85.214.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="kOcOcjPx"
Received: by mail-pl1-f177.google.com with SMTP id d9443c01a7336-2db858d60e0so17797885ad.0
        for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 06:56:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1789221388; x=1789826188; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=z8PisNlwgdN5z8oDrbfsU7/ISYrUrPGO/VaKKGw0ObA=;
        b=kOcOcjPx/ZeLEKNNSDRVp6GB7/jn9JbSi9KSqVRbeHVUtwc1s/ir/T2rYngf3iXpYK
         X1OAR1vct2zntnVmdP9ojVX/Liuast9YncwylLiyx6+5RzOl1zdMZjlx+cLbYHjKSQCg
         +y4MtXBKoCUuCQMy7eiL7vnQuIQbVngYkfWHSiRirv6J/RvFvRudc5NFxdP58xMUoco+
         Sbajo/SdKX0nYUX4ntCH8g85A9+CTi90CdYCQbGRj3hHpB25ua9OUPaJA6dxhQ9A0C27
         g1MMGcrqtCwgETbxgmXw6F5LDsT3RG73Obg1keQuih57K8L9RWXHUGaYYOi6ScLRfZcq
         FM2w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789221388; x=1789826188;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=z8PisNlwgdN5z8oDrbfsU7/ISYrUrPGO/VaKKGw0ObA=;
        b=GKz+t13Zjj8G90zde4zy2Lb6l+HJF7Ops3BrYLFQDTxhCrBn2Y6U/DCMCLtn5FSl1N
         11tiXWEQporO79skTKNMzvHB1+dpDUyj16yrQO3RW3bw8ufwG8rlkty/4QkQM6K261Eq
         3CGH34vT0WaSNIwzznIBpnRfUFXiE6Sc+Rsg7PbLaG8bWAIe/Tot+Nx3IMtCzAb80HOE
         uiWOdTxP4NVbbujG2bbvYTA1rg49lBdBtrFLHGsEHi6YzogFeZA0PQ3G9iNK68WO4j4d
         QzdQXt0ktSO4WCnOIr/d6cpJ5hnAE9wKrqJZbXafS50M9I82zrQNs5A9QBdv2PrT35mp
         4oXQ==
X-Gm-Message-State: AFuF++kHd6QpH+FQGt9MHsdB9mRFmWs3ag+7tnI/kwfw0bbEA/DSw7rd
	Fbz9OmRQe4W7RD787YCgMCko5+jJ4aaHzfPPHtgPcs7r5fDRW2thJcXH56FcrTPDEW+Tp82SPbY
	qnwYgrOa0X0k=
X-Gm-Gg: AYBFou2HkIXL2bhlFtmH6cYvSz5vDEzBRnZxtbPX2TNqKQTVHcDXVLNNQoFZaP07N9B
	89RbgXxMdCfvmkyTbHrusU5/WJEORDmXAQtyNrbKYrPcPm0gA/AC9B1ufYDM7e2UonJpVBvwfkQ
	Vr12JNBsYn2CrbWzHegBMvLoI6Q3ejprukrT9VRwkf/HVRzHrHbZX10m5IXDOPVyFVpePp525Ns
	xDFx4xrJ31I9d9z84kPNU8GqDpEaUQBBHHjQdx6rMRANRU7fnwVB29V237IdRD6yiGVTTbvcy8/
	IbmUQSbHl62yNDk/i65+JlvV2BKK69yyGHJbTk5Q7E0/uCZlyejkIiudvw2V6NVPhX/dreMVopY
	PTCRxpKdwg2IPVAYkSn0JjjsF8eMAKDYTrow8jbQYmLhIrQ+KUJsmTU5sQr4e7+EDWxTUuOFk7z
	3naR8hQrLiIvg15oOE0kIqPds8qWuUELV6bPqQf/TF0V3UybJ1/iDVNUMp5LAMTMtoenQQ77qhl
	AWZiNo=
X-Received: by 2002:a17:903:178e:b0:2cf:b68a:340 with SMTP id d9443c01a7336-2dd2a336572mr174031925ad.10.1789221388042;
        Sat, 12 Sep 2026 06:56:28 -0700 (PDT)
Received: from Roxy.sysu.edu.cn ([2602:feda:30:ae86:295:dff:fe84:68f4])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-33ba4f1e434sm13947833eec.22.2026.09.12.06.56.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 12 Sep 2026 06:56:27 -0700 (PDT)
From: Zhiling Zou <zhilinz@nebusec.ai>
To: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Cc: trondmy@kernel.org,
	anna@kernel.org,
	cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	davem@davemloft.net,
	edumazet@google.com,
	pabeni@redhat.com,
	horms@kernel.org,
	vega@nebusec.ai,
	zhilinz@nebusec.ai
Subject: [PATCH net 1/1] SUNRPC: hold a reference while tracing accepted transports
Date: Sat, 12 Sep 2026 21:56:09 +0800
Message-ID: <d15495bff2247e3f9d4f9ef36df8e246a3898380.1789220778.git.zhilinz@nebusec.ai>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <cover.1789220778.git.zhilinz@nebusec.ai>
References: <cover.1789220778.git.zhilinz@nebusec.ai>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svc_handle_xprt() publishes a newly accepted transport before tracing it.
The publication can make the transport available to another worker, which
may close and free it before the tracepoint has finished reading it.

Take an extra reference before publication and drop it after the tracepoint
so the accepted transport remains alive for the tracepoint dereferences.

Fixes: 11bbb0f76e99 ("SUNRPC: Trace a few more generic svc_xprt events")
Cc: stable@vger.kernel.org
Reported-by: VEGA <vega@nebusec.ai>
Assisted-by: LLM
Signed-off-by: Zhiling Zou <zhilinz@nebusec.ai>
---
 net/sunrpc/svc_xprt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 40040af588fb2..9370401463b6a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -852,8 +852,10 @@ static void svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt) {
 			newxpt->xpt_cred = get_cred(xprt->xpt_cred);
+			svc_xprt_get(newxpt);
 			svc_add_new_temp_xprt(serv, newxpt);
 			trace_svc_xprt_accept(newxpt, serv->sv_name);
+			svc_xprt_put(newxpt);
 		} else {
 			module_put(xprt->xpt_class->xcl_owner);
 		}
-- 
2.43.0

