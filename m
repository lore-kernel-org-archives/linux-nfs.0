Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.43
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795136520;
	b=TlweJdm4cKzaI1by2FErz6N5EKY9YdG7UNdDKLwVyFi+2kWUyWi6d1GdIQN92HP7fywT
	 V4OWVnfZIFj5c+ITZ0a9o13o8hF/Hdlue1fUsNJL8fEjLRDGrc1ZNqNqlF1xz1nH11R1W
	 KejXXtmFTdgGIzQ7Q+FxEJ/Ed2eHoZWJdwU7pI1brGfwadVqdkWreEYc7po0x5ccgCRmC
	 opgaeni9nL2PlziQEl4LBjoi9GJjQNIeGtSCYUwA377uaP4F5fGv/55LzYVqD/Iqn/2zS
	 SpWqaa/p2lAXI4jBAL7kF6KGxaIindZ8d2Eilw1+P0hRtuQdPADkNOl5BU6AvGRpAXw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795136520;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=RJF1LQwepLu6WRzJCpDZBxa3Fd67BOeHnb9dxUl8x2o=;
	b=S/R15Fxi7bzXzYylfi4zPYly+8HlYLYg7SFQyBb1C8wN9RsgMPs1wvWlc7AQBLbYZek9
	 zbE24b2Eqk9JEVlKPdB2wYa5TgMJ2gfDN9Z/3XnyqSALm2GkRpHSIlnEyRhRNHCVEvaIX
	 kSQHqDKPp3nDlOSQh/FYcfCBd0Da7xj8nb+w1AQPnV/ZY6WEesyAlFtY0btFhUcPh8N4N
	 uesp04ZfXmCv5/l3IiVBUtA6TClPq+CE9aNgIc646jQiN/lyHjLFAIOpyw5z6zn7LB65G
	 oI/Ci0gFUc2PE0mwgPg3vI3PAZy+6kXgqAr2HSr9fhvxB5rDCFiMsCLRrfxBmsv6rSA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=GP9rvFHg;
	arc=none smtp.remote-ip=209.85.210.43
Received: from mail-ot1-f43.google.com (mail-ot1-f43.google.com [209.85.210.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C35E606A326
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 01:01:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1C35E606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=GP9rvFHg
Received: by mail-ot1-f43.google.com with SMTP id 46e09a7af769-862aca1ed4dso209289a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 17:01:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795136519; x=1795741319; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=RJF1LQwepLu6WRzJCpDZBxa3Fd67BOeHnb9dxUl8x2o=;
        b=GP9rvFHgMYXEiY7TrqtwBW72sOSRZo2RiX112vUK0HcHV54tDunxa517goFifg+HdD
         sMCsupIlQTIlAxUgkZbPQvWrW6JiYabVLrjXYMXUyaoQ6DkrxwKXQDBGPj8xBbOMvLmp
         79CLbsJWY7yj5rK+UQM/n/pzuBkLDj3GzalbpS/BVHsj0ZT13JgWEHtWrxgVvb03KiPZ
         3co5QVCW5IDIQ2Ti3GNfyklJFl6GXmopoRRec2ZG9wwaLzdV16biSob3DRL4jIpAmXGF
         z+OyCeXyl34xaaY8Dx48qUJgp3Btj+jLwiLwY/p08dHgNr/jRckpLV0debwc2tRn+kHq
         DNqw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795136519; x=1795741319;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=RJF1LQwepLu6WRzJCpDZBxa3Fd67BOeHnb9dxUl8x2o=;
        b=B3CySZDNBlk7G0gmkbzGQD0iuxR5XM/JIJa0nAld3IMj55242ZRVwoFbZ10HRmDQuY
         NL/bwZ6kG4tHC8/D9al8OPne1SfFgmcsYwj5zm/KNgNQOfZLwdURzA6QVP42BLj4c1rl
         XxV6gdi3liZEpYpdclgsulpCHh9O+QwgCpwJSLQ+HSvq4VZ9CuTPfED815NoMFGOEC+h
         G0mcceDA+Dqd3WsfXk4kswoc1+FUcDZnwXCobLbjrBo+cxkXGWhME0K6+Q3lRy+mB+cq
         DZveigDzJUtkFs2i78iHDXaSvtQ4Ytv2GCAHCaKw/vGnfgA6c7aBogCUitmbf0Apc35H
         9RDw==
X-Gm-Message-State: APuU4Z+GotfSm6IV4V4NGThg/D1reli2zlZcupBz2KxSaZaNUbZJJV05
	QpcxK0LkZeONd1yuOBoAJoODofspUDIuhQpEjVU+2B4thac5RzfTLrXBqdEThBqf8aRg5T2a5FQ
	hcZKs
X-Gm-Gg: AYBFou0vNaOug0mX/CMbOGsiXQwTh/gzYORKRlofct3iYlvgxWkvI8eC8qN18dO1Jie
	7uBQU2VmDTsZcjjvslFICsZmLGgkW0Nin9H8tJK6y4TPdWWM1rr066PffwkJAZPjJ2vZRSA5oNv
	cONIq2JSOKXhODKXdyOZpjao5hxXVeLJqlNm/1XxvoOxEdHt++IYS9zQL87xCNTzLA5Tysv3cRg
	MxW8fw9jhrTvj9zeHE0bIRTsiz5iz/CoipV567UtOgLikbXkELug9x2vKfNCzrPOqBzAZekOFwE
	4xLtlG68EVAOjteDEm/rbfQ2B4jVZU8buQgIYc/AgRcncyjWJ7bBSiKympY0/TkfF8qsyYFhwJR
	SldqwGljZGHU6i9XCyMxnqeSYkZs16AnDaLUApDBNABo6N0btAGZfwOz8Gto0L2s21ErX06FTlb
	bsoTToAyqczzZjj54D2w9yYUXQIZjLcn4uvPURcCrOmwzivzrPjhgzgcGQCJ4L3Jtajox+X1zPF
	WOm9Aepp3dSakM4gnzhxyf80JegfaE+z6fLi4L8dJn1o4eOlkfxny+bKG9SsOPTULEcyEbe5jW5
	mHaN9vf+G/tIwGNVtOXdrJXekqa40AXKQJ06ujadWOXfRJbd0pt6w17Hh50DCVwELp+uV9ZIrV8
	kmv3uoCmbThN+xV0su+UClg==
X-Received: by 2002:a05:6820:82b:b0:71a:f0b8:5dc7 with SMTP id 006d021491bc7-71b39206939mr1416764eaf.8.1795136518746;
        Thu, 19 Nov 2026 17:01:58 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-71b37ea818bsm1101995eaf.1.2026.11.19.17.01.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 17:01:58 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS: don't use a mirror after pg_init can free it
Date: Thu, 19 Nov 2026 20:01:53 -0500
Message-ID: <b848a173b03e00d9a3faf17eda185a379b771d5e.1795136323.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795136323.git.bcodding@hammerspace.com>
References: <cover.1795136323.git.bcodding@hammerspace.com>
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

Fixes: 03d5eb65b538 ("NFS: Fix a memory leak in nfs_do_recoalesce")
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

