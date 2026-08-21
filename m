Received: from mail-oi1-f173.google.com (mail-oi1-f173.google.com [209.85.167.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1D81493637
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329776; cv=none; b=dTKSqPOyVNgMINbvuuuiY3U/9xhChWRMQc9dCM1iZMr7HBX/O6VtcvL6ZLvmfRhm5xyVcg40dw7icwBOJYmJkxAwsNc3NTBN18MuV2UqeWYYEmPu26NFVKTflUQxtmMECcHnAh03725nSsd695J3jqVW7oe564HwjKr6ZVWekTM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329776; c=relaxed/simple;
	bh=vknl/QhcQ2vYMnPnp3B3HfXGaEuVlDf8RgDUdev9Qkk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=iuFxAPPtlBcRd6TSRmyN/9hO/TGQxwRsJAs/dKbBtlDuDJOFfz6ryp1WE3cQM1Zp891zPlqlkZdR7nOcfsh4ZjnJlaLptItoDBxRqtfQokqELW/7Y8Hx2dQP052BaYnieO/agHr/bHXnk2QKk23YS9jczfba+rZAWHXjpmKU3zI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=Z7FmZD2C; arc=none smtp.client-ip=209.85.167.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Z7FmZD2C"
Received: by mail-oi1-f173.google.com with SMTP id 5614622812f47-4b21f09ea42so981701b6e.2
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329773; x=1787934573; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=mOZ5ghgnHM4NaQLKbM8wRRQ9DpsBmpgyJnmMZPERWFw=;
        b=Z7FmZD2CB0bH1+Mz8HW8Z2H78CTA2y0A8l+R6x8nMEl/p6iKF+bku2QdwIZUdwH387
         nAfTIO6Qk7kvHiZKf0abWcuiYa8rLmBK8Inw6oCA/yV4senuwyRla6myyKIeRWdKH1sQ
         olXOVObaVU/hv0t6c3JCABYaik35UnQlX+mugbQdJKo3Ljw0pMy2qxFn78gF0T+XE5U8
         YIDPKAL0c/MomDqh1IkN9V9/T+JSFCVCsEjXPVcIY8myEvHEowGxhr1BFCKlTf3jLuKw
         gHwLUNyN2CHTfAfKwmogLqgZY7d0P26W8kKAlAjD1vZI1qYUdPhKKRd1EF3bfbqPyO2N
         Ob3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329773; x=1787934573;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=mOZ5ghgnHM4NaQLKbM8wRRQ9DpsBmpgyJnmMZPERWFw=;
        b=ZRyL/DLi1djGewhZqS9Gt3PrVYmr5It9HH0t9+fk+ljEK45waxyzTqIvGxu8qJ8ezX
         o69ksPXDbhzQP0FrEmmyGD0VUX6i3HeMQH5seOlqU5CXXXCLKONSVdAeUTRkQdeJcn15
         4ebfofx3jGgEtS7pwDE9FEQwHyXFvhtqv1jZ5Kjo5bdXwXFDd23L6DfjgrHmNK8fIin/
         Rm8kmmCufSlKnJMcp2i6euAqFw6M0Tjq8XHqsf8ObJ1a/3VnspGau9DxTYlrpBbEDNvL
         qxryR72LKfK7D9R1chjZE3NuXU84nHE1EQrcuYB+qzUamngUvlcCFQ1JDJAobBpMyAl8
         gscg==
X-Gm-Message-State: AOJu0YwNQbj+4E4rKxDzRO7ICgCJRVfWq3k+DQLq8gCcdDn2hGWsNpb3
	MsEf0Y1XSayJHnwCbaRpxhSNx7iwBIiZ1seXodW9oUDIuqO6ORnorcUMJjCWnyIdE3UvFnJzJsz
	f5+In
X-Gm-Gg: AR+sD13+RcyXvP7UG6zHvqYcs5QpoPVjxn6juL7bPX8dkY3zeC1rH/Vgy7ftW7txab4
	AcvO8LsqMrhbOWI5+zT2nWMSKW2FWTzGaht3BU4WfpiLtxYFrkHnNTmBwEZrbWpNeVDXTSYWZnR
	dl53qSOt1/hoxqku3Nnub2Kn5ouoTXGEZdfgZwkpRPlRG1ktcX/16VW9DKOSTsd8RI4SZLEWzvb
	KxPf1J0SqcHNsyXtgvGf0o/JO7w8/Cm3XajjW/V6BVEEJpSLZORO34/c1r+cklWCSWNYdsgu2K1
	PzTj2a5FX5u3jORquy5uKtbflD+76ZxLVE/Fs+xmjjc+NCmes7KOIcQTbnZoJNInTuEnXaAcTZi
	Tsy2c4Axa80/ICkaoUh4dk9M/fPv88Q/gH6WeFAK/F3gCXeFn0uuLSF52uLDn0Xx2glaD8f9XIL
	26ebRA8zFuDwgXh/rbwnmBnDvmjauG8N5OtBaFirUdJfNwelozVcaE77WWf9KRAWCcqjK+tK5k0
	3Ud/sGJ0tn8lqdE12Zrrmoz
X-Received: by 2002:a05:6808:5290:b0:495:d7ec:b6ae with SMTP id 5614622812f47-4b2ef3a0a02mr7192033b6e.16.1787329773538;
        Fri, 21 Aug 2026 09:29:33 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:31 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 03/23] pNFS: Fix CB_NOTIFY_DEVICEID CHANGE to consume ndc_immediate
Date: Fri, 21 Aug 2026 12:29:07 -0400
Message-ID: <7c8b7b9c08d588a52f68c27bf3cae8fb0b7347a2.1787327939.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787327939.git.bcodding@hammerspace.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
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
index 2d3d0f237ba1..8d1a446a8ad8 100644
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

