Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191075;
	b=H9uHqoktAugcM/JHGBtsATgikXBYxqWVCMPextwya0cLO52aTXlgrv7xFB7Yb8KhzmY0
	 67FWL7GBj+T2LoMTjZmIMZOcDiDfESyBvHrOWr/81GxGPb3vSmZEqHGKIM7oZhMxqttFB
	 fCT9hMoo55jeiMWWL21TpnD5zb8tjQwb8qxJ9YYi1drQ3EINxQAXWyls02R2Jwkz41uen
	 wJGDMrjUHEEkvlLq4UHHmaS03VBk0vKp5/pebrrCCK+4Gekqzt+/Oqpgcbvvpvw+MkIEa
	 tW/d+zawdJv7je7GoVOl+oYCASl/S61/CoQBPfym59XYdhaf1OMBWr0jOUKNGDYlBfw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191075;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=05AWmn3mnkNgqbOPl54/Wf+SJ++2MQiAXE3LCkb0Wn0=;
	b=iEr58SVrS6n0q5yy2X2PH4/n8A0F7JcSpcKmD9gqSGKNSn2/db9f3E3n2SM9KIMRYahL
	 tRuHfo67tqAPv8X7v/xykyVEVplWura+hRq5IF50wwX/AVdAEnKEMfa7mTNxJP+hv12TV
	 xVc25p1w3AkTOdK7s0Ub0UOtlswdCxu/9CMflu1byZUoiwv2TPb4B/vzWtKvooLbMV7FL
	 HhMRcEUBqKKIoLLASWYdBOXgyW74LKVb0QLsVMX1bXsT0YQiAH/sG/QHLxsp+OcDHwf8b
	 vP/ZBvNUDOSpJN/NZ/dLNf3XVw55WDePBPixHF4GoAEcPtEpeyuDtMvBFqnn7Rs1HFg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=kFS2vpzw;
	arc=none smtp.remote-ip=209.85.210.47
Received: from mail-ot1-f47.google.com (mail-ot1-f47.google.com [209.85.210.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BCD6860A2603
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:11:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BCD6860A2603
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=kFS2vpzw
Received: by mail-ot1-f47.google.com with SMTP id 46e09a7af769-85c1135c286so808034a34.1
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 08:11:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795191074; x=1795795874; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=05AWmn3mnkNgqbOPl54/Wf+SJ++2MQiAXE3LCkb0Wn0=;
        b=kFS2vpzwy/VV3Ghxzre7QNRCUbUcgFU6yUdq6pr6jbqgsow6TfGMwL2S+bmHJUVpnn
         3tK6b7n3CMKS58Sfz0iqUgXDXVAHjN6Gbrv3Au7F56VEyiYJqSxz9UHQ8GTGYUrltooe
         VFwOIa0uFBBFLaoTv5wTiDH9B6TZHQK7wgByP5+ze0S/TxNiv6qtvYIMk3JlrrGd6O1l
         sXn8bcsNE2FQKMLo4tOamMyyTrqLpCxGq5DbwB+TELZFnCcJL4KdbrTHWGkSOkzsNv1z
         ID8QOsmQzVDVO3B72jK5coDjhBEYQF1b5c51vbTx8ruNpihqx2hGmHhFS7pSXSDlVCb/
         1IaQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795191074; x=1795795874;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=05AWmn3mnkNgqbOPl54/Wf+SJ++2MQiAXE3LCkb0Wn0=;
        b=qqU/9Qice5rF0ZqDAKVi02rXjYkWo7gcah3iGA7JSFKWIeSstC8zbDzdOOxhKQrHxj
         5dS4PBycUjQOpGytbVbGwi4BC7MlvtmWmCn1eAhg8gtNFUkzs1Qg6Bkckk1/3rh2GXDc
         XGbZsC0RN30s7I+cXYpmcHZHzJ+JWuGVMpSFNriCc0A3l2ZKqwVswkkRQWlETjqlo6KD
         9q8lHX88p/LTNenWaMjVGRQIlr6FddSQgvmLsrTQ4lARz2yDvZC3obJNPD/PM3yimMnF
         S0YiC+leXBKQnw2r/jRDS31YZiQn7IoRGKgqYzwyl2UUe6feM8eHaPahsZBZGMWoJ71e
         vftQ==
X-Gm-Message-State: APuU4Z9vYpwHWsbXlU5uKmWvqSpWDwx4dw6SCLamPD0iKJzstPl2I+N/
	NaYpF6LD19Vjd3QOfJdFfvQXe41MCoYSna/UKdWTrvjLrN6HDFa8TsLPZrpdQtPdyRM=
X-Gm-Gg: AYBFou04i1nXSLCCt/9/XkyPxbVwdUndRGyyt+zWOkfgA3BKhUF6wuvMgbZz79s4uBq
	xYLczvh6LKaR3/MRzANgcLzbh9P+MLjlmPNiECtWB6wOgEQlOfxXReejuSJsmtPweY41SW50uCt
	p1mRvBNUNj32LPYjdhJzztnLjiRlM+fqeAfaV9hHlbIgxVZLgc9dqPR2mHe0wk0YT6EsW1UvRHx
	14kLvO+OENE64gev0y1IAqx9rHC0bLF5KNaMqYHEu0wWCYVQT5kUqkkV6zV0n3Iadr/UCbMt0NE
	IALAYdaPTSLdO8k9GSUfzyyvNtpmCR6d+ofUISa5/fDbnd7Gu8y1azcD/o6XqifLpEDECG4QrpR
	fK4m3Rwy9FNyZeHOimfYpDARJn7R8xE7cYerLbRJxaK6NQ8DykWHMmdWBuOCpJbb1v7XWYlPZ8z
	IEI8JgxeG04/hK48cT+MyLDGvBq0I441uXRH9lAjS1Md1iKlJfvVMTknWrD5JOn/7As3/Ht0W92
	JZz+LMbnC5C+YEF/VohZh8oaATXe5IuyrHtMjn8Wz95iSSv7aFWWftR0AH+rde+PSdTe9EQeAby
	DAsGL/vKgO55KN7nxAogsdRGUJBFiOmE4bNFKZ3eL6AVGu00LlM/aBX8mouv7yCyrYC04aI27o1
	xKwkAerQz8BFAtLgcrwUsmffYVIwAxOI=
X-Received: by 2002:a05:6830:91f:b0:819:1804:d208 with SMTP id 46e09a7af769-863157b52e1mr5458680a34.13.1795191073544;
        Fri, 20 Nov 2026 08:11:13 -0800 (PST)
Received: from bcodding.csb.hammerspace.com (196.sub-174-201-28.myvzw.com. [174.201.28.196])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8631690fd36sm2441034a34.20.2026.11.20.08.11.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Nov 2026 08:11:13 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/4] NFS: don't use a mirror after pg_init can free it
Date: Fri, 20 Nov 2026 11:10:48 -0500
Message-ID: <f19e933eacc1b8aafc4b88464364a6a649e4bab9.1795148523.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795148523.git.bcodding@hammerspace.com>
References: <cover.1795148523.git.bcodding@hammerspace.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

When a layout driver's pg_init switches a mirrored descriptor to the MDS,
nfs_pageio_reset_write_mds() frees pg_mirrors_dynamic.  nfs_do_recoalesce()
keeps the mirror pointer it took before calling __nfs_pageio_add_request()
and, on error, splices the remaining requests onto it and sets
pg_recoalesce, writing to freed memory.  Look up the current mirror again
after the add.

nfs_pageio_complete() also keeps completing the remaining mirrors after one
of them fails.  A pg_init that fails during completion may have released
the layout segment, and the next mirror's pg_doio then sends with a NULL
pg_lseg.  Stop completing mirrors once pg_error is set; error cleanup then
handles the requests still queued on every mirror.

Fixes: 862f35c94730 ("NFS: Fix memory leaks in nfs_pageio_stop_mirroring()")
Fixes: a7d42ddb3099 ("nfs: add mirroring support to pgio layer")
Cc: stable@vger.kernel.org # v4.0+
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pagelist.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index bdf8b7305e61..3bdf3f308c8e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1299,6 +1299,8 @@ static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
 			req = list_first_entry(&head, struct nfs_page, wb_list);
 			if (__nfs_pageio_add_request(desc, req))
 				continue;
+			/* pg_init may have switched to the MDS and freed the mirrors */
+			mirror = nfs_pgio_current_mirror(desc);
 			if (desc->pg_error < 0) {
 				list_splice_tail(&head, &mirror->pg_list);
 				mirror->pg_recoalesce = 1;
@@ -1457,8 +1459,12 @@ void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
 {
 	u32 midx;
 
-	for (midx = 0; midx < desc->pg_mirror_count; midx++)
+	for (midx = 0; midx < desc->pg_mirror_count; midx++) {
+		/* A failed pg_init may have released what the next mirror needs */
+		if (desc->pg_error < 0)
+			break;
 		nfs_pageio_complete_mirror(desc, midx);
+	}
 
 	if (desc->pg_error < 0)
 		nfs_pageio_error_cleanup(desc);
-- 
2.53.0

