Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191078;
	b=FbWVGqIcDMXJ0kNFc65e8hizcHMNh7gu7342q33NSI1jWLgNVXEXR6lGthmBsNneGJWF
	 BOQzesGepmu4VmSbyOKGN0+k+FqAw635aDJtIOLQP0sFZRN/INKduc1Z2ETf9CHOZfSZN
	 7zeaR9UZVFzseZefNlOSpjrylGFQ6asQQNyZigyjAFLnql/FbbuEBj37oK6YUCCgBGWtA
	 uuDQLC8Z4FziNGIZmjLy2xfnxmTbVMQRBVwgM3aSYDTR7oXk7VT2b64FROxPhXrfFZhDu
	 e2yGW8MQ2qqCJm6otp7Lpp8Sp8Rz/HR5Obov9gMupDtLUviiWWIsp0Wg5lz9Szt2dlA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191078;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=Uyo4lB4yQx7W9EnVOW4MMcxsyvBpxnlVfuHyB486xb4=;
	b=oIfqgs+192qWb2TWA1vv7MRGDtg0zi71cqzkVRzgVMzmqJvu78T2OlhcDBY0Z2HxT7eR
	 41i3jmHEGBVJ8C7lcmaAS3P6Bj++Kc5/dZ3v/93lLC+dg9sNabJrGqt8EfquyX5ICNOQC
	 9z9SiARUSaKaXCESzvNsfOPr83uo2I9zO7jCwO1cicUCIZ7hwjJ6uMvpfvGFbopx4hPAv
	 HV90BgT6vCWefyt6FYHX5yLM+Azl8YXfvG69JFe1OVb0rrhE+yDfOnUNRXvNKtMbULepJ
	 LkMFqzNY87DwUUWfa3750olyHWWpRc8kDArdizIxGUbTpMm5wYI2UXE8JqVgfiupFLQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Cv0+y+0V;
	arc=none smtp.remote-ip=209.85.210.50
Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com [209.85.210.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B43FB606A331
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:11:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B43FB606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Cv0+y+0V
Received: by mail-ot1-f50.google.com with SMTP id 46e09a7af769-847ac7ccd85so695247a34.3
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 08:11:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795191077; x=1795795877; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Uyo4lB4yQx7W9EnVOW4MMcxsyvBpxnlVfuHyB486xb4=;
        b=Cv0+y+0VeifsAnHx/5p9BPy0gf4neufD5TYxVqCy9W34NRRDsTQ9/8VCvyudmF/YiN
         upCySjLMsmPXLdTpfgyAZSyUFJclJC8R+7RrXuZIQPHAJP+apj901XpyZsajmZB0Hyi/
         64U9wRvJX2hjq3Olod9IWJMMuv5zQR8tSiKz1t7IjlwUigLfqDmceMtAZdjHAat1Bri/
         UjZ5qB1nEwpCezzVqW6/L5+Ch1FeNW+K/aZLAhkLzr3mep0JMzmi//Zo+ozBlbQZxwEn
         N8aE0q6WPRFm23jE9VShFprqtrh1rszP/sFs8kLuZawxPvXH0SgXbltZ+VsY8/JIEjEl
         sjkQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795191077; x=1795795877;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Uyo4lB4yQx7W9EnVOW4MMcxsyvBpxnlVfuHyB486xb4=;
        b=UkMp2qjfnCPgl+glekWVgLMs8W7Fxhrhnl/Qr1BZiy/9ylieeIGe5tRRBmICBlnb0N
         yZ1a6pcvcilFMCNLwnZVhObsc/1gzLjK0W8wMzAcIy99IBYln7Kl04MzSG/nKcO/STSD
         bw+tXqHvbk3pJs/6M1TLVMjOJ3xTlfM+k+u8Yj6tblI7IkA6ytKm+QWW5j++qncYEhxs
         SaphJ8CWAVKHJEIZJrcfOOtm6Y4SEkPE+oRblQKzBnhXTevoJYQneFNoq3CH1HBRW0x7
         5F1eXo6168XynQ+trJnoDxr4RjC1gjjGFoM/9it/ATPKMB8CU8YPjaWi8kEbCNzRo2gX
         K4tA==
X-Gm-Message-State: APuU4Z/TWoIRyK1WjPSdsv5OnsmPPs0+z7Wvzn9WUtjb0evCv/Mn8RGY
	YNoAGsrA3WnXNs88TWRT3wRDBilZsazITBWpohCJrVCoCGyt9jD/+eTExpANnhFDr40=
X-Gm-Gg: AYBFou1iJ7h4xVOPqa4JJUIPM9S0fXefH3MnNXA2c/VZnLbmxby22KNjqgzJnchzYOq
	kOf0HtOO3mtiPNH/+R+Us7tdpuSgM/KfoXJ9/VLgEtV5tEr8r2DdhC+jP8G9SbOX7rMf5RHYIKp
	UFzyhp2TMcS1ukc+6Fig3z6yqXO8GREq3bQHPXsNNKkmUSZz7ocDHKkrygLvg1kpgcUwaVEsRbW
	B/TsArm0tCEDshgejSpExcx+BPle7+Udls85vjUQBViHT0SgNqwvGHTxnfYgKJLlw50EQ0C92xo
	b7hpcApQ6Mag+/XAmg8nK1LL7MdBb9lLvNNvldcYtzl7QSQu6AK4E62yRAwT2miMriu6bUTNOTQ
	0LlidJAkZfV+1/3a50o+nxFfQdxRkCoTq5dvNN6Ii2O1VyFgGACn65xt7rbUPDed8Yfw8SzS08L
	vegemJoUaWD3LCuFDdsmrLU0F5Q9/Jty4jZXJI0pGKTv5M1QvbKH+QQ64Pkyw2X3UPAwc8XNlH4
	/GLhrll1dq8AoB9y0BeMzGgQ+5z6daJCecA4OtKgem3gtG7bGDfV7r7K9xgaZ/WObdzRubiv1V/
	whvZtKfCcWw+JnGfb2zTwR7HDoA2T9awsr7fGJlZ/dboEq+VwB7uYNwXUzzSCDvLKr1Nj1ES08N
	zX7B5//JFy+ByV9AIAf4Ac2CMUiFMsJNlu7yGwNyA+pGTigi6bwAE
X-Received: by 2002:a05:6830:82f6:b0:862:bc33:da95 with SMTP id 46e09a7af769-86315995c28mr4183473a34.20.1795191076490;
        Fri, 20 Nov 2026 08:11:16 -0800 (PST)
Received: from bcodding.csb.hammerspace.com (196.sub-174-201-28.myvzw.com. [174.201.28.196])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8631690fd36sm2441034a34.20.2026.11.20.08.11.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Nov 2026 08:11:16 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/4] NFS: send every mirror when one of them can take no more
Date: Fri, 20 Nov 2026 11:10:49 -0500
Message-ID: <4587dba019b165584671fa8aa89d2259264490a9.1795148523.git.bcodding@hammerspace.com>
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

When a request doesn't fit, __nfs_pageio_add_request() sends only the
current mirror.  The other mirrors keep their requests until they fill
too or the descriptor completes, so a pg_init for the next request runs
while they still hold the previous ones.  If that pg_init has to give up
the mirrors, as flexfiles does when the next range has no layout segment
and its write falls back to the MDS, the requests still queued on them
are stranded.

Send every mirror at that point.  With the same wsize on each data
server the mirrors fill at the same request anyway; otherwise a mirror
is sent before it is full.  Either way the copies go out together and
the mirrors stay in step.

Only the current mirror is recoalesced on this path, so if sending
another mirror requeues its requests for a retry, fail the descriptor
with -EAGAIN; error cleanup then redirties or requeues the requests of
every mirror for the next pass.

Fixes: a7d42ddb3099 ("nfs: add mirroring support to pgio layer")
Cc: stable@vger.kernel.org # v4.0+
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pagelist.c | 34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 3bdf3f308c8e..108d0b4168c6 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1201,6 +1201,38 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
 	}
 }
 
+/*
+ * When one mirror can take no more, send every mirror: the copies stay in
+ * step, and a pg_init for the next request finds the descriptor empty.
+ */
+static void nfs_pageio_doio_mirrors(struct nfs_pageio_descriptor *desc)
+{
+	u32 cur = desc->pg_mirror_idx;
+	u32 midx, restore_idx;
+
+	nfs_pageio_doio(desc);
+	/* A single mirror can have a nonzero pg_mirror_idx (flexfiles reads) */
+	if (desc->pg_mirror_count == 1)
+		return;
+	for (midx = 0; midx < desc->pg_mirror_count; midx++) {
+		if (desc->pg_error < 0)
+			break;
+		if (midx == cur)
+			continue;
+		restore_idx = nfs_pgio_set_current_mirror(desc, midx);
+		nfs_pageio_doio(desc);
+		/*
+		 * Only the current mirror is recoalesced from here, so fail a
+		 * retry on another one; error cleanup then redirties or
+		 * requeues the requests of every mirror.
+		 */
+		if (desc->pg_error >= 0 &&
+		    nfs_pgio_current_mirror(desc)->pg_recoalesce)
+			desc->pg_error = -EAGAIN;
+		nfs_pgio_set_current_mirror(desc, restore_idx);
+	}
+}
+
 static void
 nfs_pageio_cleanup_request(struct nfs_pageio_descriptor *desc,
 		struct nfs_page *req)
@@ -1262,7 +1294,7 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			/* Can't coalesce any more, so do I/O */
 			nfs_page_group_unlock(req);
 			desc->pg_moreio = 1;
-			nfs_pageio_doio(desc);
+			nfs_pageio_doio_mirrors(desc);
 			if (desc->pg_error < 0 || mirror->pg_recoalesce)
 				return 0;
 			/* retry add_request for this subreq */
-- 
2.53.0

