Received: from mail-oi1-f181.google.com (mail-oi1-f181.google.com [209.85.167.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B36036C0DC
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653802; cv=none; b=YGkTvqU26u3TrLpdP3ZyW5WsVN2X2xmggZC80XjiVfVBmaJGJtLbQHqTqyuXctyQDlQZRNPtb6k/O5RRhdBgZ6d+GMDRmdY3RQXE2IHsuEPgGMkDROOo0Y/TzTIHPn4wTPb/drBZ77VNe9u2hExpK4dbD2Jwgl32u8sUPA7TDgg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653802; c=relaxed/simple;
	bh=YadvcT9EYUlsDWRNIJhmmWy9UFupO+fqP3G3xMldyA4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DS28s5fRHpScaZ+DTXQz+Rs20iEzmDMfmcEr5RTtkOF8aEJzPnxFLWZuN23QuOxfdv9TMWqfoDyePlBL96+taVJkaBjrgETfUyDDa9djAYesyrYwDWE0omoldTd1OYWkN2Jy0CPfBhq6dlYKZPYpEhmI+CVrc9q2zL9ULHdkqts=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=LlJHzBXo; arc=none smtp.client-ip=209.85.167.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="LlJHzBXo"
Received: by mail-oi1-f181.google.com with SMTP id 5614622812f47-4af7283bf83so111089b6e.3
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653800; x=1787258600; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=RtzhqKDB0d3ie60rRGmPxPO5oIkTtmVhytZR71t+bck=;
        b=LlJHzBXoDq8mq+la3cO19Ezekux8HQI0h9dEBCeWwawoAZbi9QwwFAR06T9IhOcVIf
         /J6tmtzHlD3D6atwqDfFk+0ZEtwE2pE6Sh0tzDPkhv5IHstGC2ZJy+ZrOIJFxY4liYqW
         OgHFzHfd8D2Dl8H39ddirBbOJMP8V17//ixxrLdpAn7LpkykLkPKDLkqvVxnrSBTkwk5
         S+2uG5RVRYxPY36jl8L5ZUJOK1Mohnlzvf5iWAJv/xaW+NnDNrhrOjQD1QTHQSNGn1qZ
         RVEGaojT9Rv25pXWcCKtP3a6WfgK9n8YGT8Ql6XzSU/9deNB58Rmf4KqxUMr9nX1Lo/h
         1UJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653800; x=1787258600;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=RtzhqKDB0d3ie60rRGmPxPO5oIkTtmVhytZR71t+bck=;
        b=AvXNYj1V1rdH2VUzJfRoSUNI+DkVEoY3q6iSnrVJ+AQj6r47J+fY/Ll3j3LDZDMAmR
         TXw3vcllIn5cuAlns03CpwUwiDv1x+8V6VJlnqmh9gnNR84U6pGpL2LdGI5+6u7Yfvya
         33wUd+qbhkgksjlmeqh06xsKY5RwTfD3C5r71k/pQ6Bi2ysfTYnK8IG916fPhSPzHjWT
         0YNdapd5ZdjFvDgStu5awTj9CrSXkhfKWDMQlQ0QqHyWpnnb+vrJjHCP9UkuvXqrkmkS
         IeuEL0Oai9o7KuFyYEdiV+A95AjIoKFqX7gp53r+5u325u/s8vw0tvwxhcchvk//K7Dz
         tJLA==
X-Gm-Message-State: AOJu0Yw0AyYRyHft0xwMzhEMQz3VP+E7sB1jJ1Btr7U46hy2MYtxpGH/
	yzkXd+TERAE31ymuqE9ybQtb0VDe2Ng9GLyWBQBTMKDtfljaic+E8hlZMf0iulAYpgc=
X-Gm-Gg: AR+sD12Kb60VoYEwsAuzECYrWG6zDS4n7lRTPWwULgUCqlGgEyU95JA0RQt0FOj+mqy
	OIIgZ39nTVaeaSPstTqJ3mYmzoYjN8L98SXltLELhBKCE7Q98FSjK8NGKRPEGZwPR217Eu96UFe
	m3JuHW5rj/Z6PKGS2wLS1b15YZe13+ER7oJnpi0T9fxEPssPoVAcvP0DEMeSc5j6r6CRW3q9KOd
	FmMmrMEsekbjQmXA7pHG8e/kr3Dm8e/k8F+8l7niexuZ09V/LbKcZE4AVBdYiWVTRMONYEmwOnm
	qBP/uTpAMnloSttnmsCspQSehxJVgVazUBaNKNDYSso5doX+04vDiDRkv85HZfmevHWx4JmMugQ
	5ao/tc0g+UkJTB3Lv9EZSDB2TDEItKo0pqKdxFrbmiKLs++OA7/fO387vFF4l0qYnaINAWKjxPV
	9ABdLeCjPhmvq+febrABEoRVRyfPWXXbBiBqPNez3qUDEXNu0euiokDcpBWvZ1jaY+nrtiVoZq1
	lQmLbUxgGuVgja3VfQAioru
X-Received: by 2002:a05:6808:5291:b0:479:f7e7:4a81 with SMTP id 5614622812f47-4b240662d51mr778848b6e.0.1786653800484;
        Thu, 13 Aug 2026 13:43:20 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:20 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 01/21] pNFS: Fix CB_NOTIFY_DEVICEID CHANGE to consume ndc_immediate
Date: Thu, 13 Aug 2026 16:42:57 -0400
Message-ID: <b59cd6c4b551436a39d097ce280a18543d312bf1.1786653063.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653063.git.bcodding@hammerspace.com>
References: <cover.1786653063.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

decode_devicenotify_args() gated consuming the trailing ndc_immediate
boolean on cbd_layout_type instead of cbd_notify_type.  cbd_layout_type
holds the pNFS layout type (e.g. 4 for flexfiles) and is never equal to
NOTIFY_DEVICEID4_CHANGE (2), so ndc_immediate was never consumed: it was
silently lost for a single CHANGE, and a multi-item cnda_changes<> array
misaligned after the first item and failed with NFS4ERR_INVAL/BADXDR.

Key the decode off the notification type.

Fixes: 1be5683b03a7 ("pnfs: CB_NOTIFY_DEVICEID")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 4382baddc9ee..04af8b9078a0 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -312,7 +312,7 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 		memcpy(dev->cbd_dev_id.data, p, NFS4_DEVICEID4_SIZE);
 		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
 
-		if (dev->cbd_layout_type == NOTIFY_DEVICEID4_CHANGE) {
+		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE) {
 			p = xdr_inline_decode(xdr, sizeof(uint32_t));
 			if (unlikely(p == NULL)) {
 				status = htonl(NFS4ERR_BADXDR);
-- 
2.53.0

