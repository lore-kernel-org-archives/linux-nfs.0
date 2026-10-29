Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.173
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793302467;
	b=FdeJ2qDnrXT+Sgm4JeA2EfcTiZznfK240IuFuS0lmqcOm82ixRkOWa1bsMlLdth/LqYW
	 sIvMLnrI6SSXEiU7c72OKLPf5+A2n+B/wGpdqiCoyCO+WMRDlKxXfK3PhdqGuQX5ACNir
	 SE0X6sMEYN+Zr2E7gksqHoMIYm3onIy5sCa5sCfneZ1pCvCKaUe4/YhVbJ58Enl+BsAzp
	 w1W3WCyxd0afIp9G+Q+S1EjHHvTfzz50jKvn2ZLp3/enaZB24bCuXMlYWWKWPa4c53LEB
	 UM0U4eyzd/+HnkTrd9mtGHSF0l8AtXRmeIg3yFRaliV0l5H2f3N5hNdl1QaklApIkPw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793302467;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=h3GA++Hq/34s1b9lN3mLXo4PS49mz1fPoQRGBwmaJxI=;
	b=2holAeUje4bV+mPHWuS8BMMxSZhQRIHw6Kvx7tPjdHWWj3rJoyU6ey5XMX8tEisgZph2
	 51Nhj9yhTrymjBDWvT2TtgUjq5KMzkt7lkBdWxFd+O72Kh+JOQvBirXBNhaF84ExW8Dfc
	 ySvx02hn6H3NyHfQqPa9mjeJDi87KHjJwK1pKZPy9NB/GzSM3RaxJrLBasiju9WrufRQY
	 5QJjlO+xQC3h3F5n4w3RPvKnP0aLcyJZPBMBoM0hTK8XCXo51OtGoGCn0h0yLSQckRfvI
	 WQ8ajLu7aQtax1ONTJoJ8dv2HSvd0hoNLKcjSdWHHTGy7KNApNfozEFtaYubSfilqTQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=b4PbRfGA;
	arc=none smtp.remote-ip=209.85.167.173
Received: from mail-oi1-f173.google.com (mail-oi1-f173.google.com [209.85.167.173])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CC20B606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 19:34:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CC20B606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=b4PbRfGA
Received: by mail-oi1-f173.google.com with SMTP id 5614622812f47-4f488ba6e90so1000703b6e.3
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 12:34:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793302466; x=1793907266; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=h3GA++Hq/34s1b9lN3mLXo4PS49mz1fPoQRGBwmaJxI=;
        b=b4PbRfGAz5gLiLG4Fky0n/J3f1oiK+WV+Byhd58wj56kqq6QoGhedl2hQ9/RQgOIgP
         mepDaiy42uTGzTeEDhZSl7OAytIxUgyfLzvUP0Y5D+so83pCrxQRW8E/rF9QfMSAUNAz
         w/F9IonBvFV5tx9FQE1aiQmnxl3br2EKpawTSSK/bxsmCZUKzNUt3w2n50CRiKx12IKC
         D+SJfbWjOybhzEsV+4gvsWT6Nyqn9E+HeupNwBC7JONXpBV90Y9faiQqiWHoFNgoZpH3
         4XjriCowKPYm+RMJio1ZOz3BEgOLt2u540zTj6ZaC+eEPVh9cdNvOL9LzRiLg42Ubr7w
         cmcQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793302466; x=1793907266;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=h3GA++Hq/34s1b9lN3mLXo4PS49mz1fPoQRGBwmaJxI=;
        b=selljISlppMuHkFjojgZ7iTZc9qbDRq/hHSiO49asifXgg5KPl5R1/ZXPpiTetLPGv
         SzTJKkLVgpbGKY6W96bdET1QrN7Wf6r02d4qKoYjP9W+nZEBb7gbN1RaWWJrjiQo/pcr
         UxIhWXNZFeUsiGfkvwLwLl/9emvEgRe0HY1R3i54niIXltuo2cEe8wfEKyy21dBjqHCW
         IhE/9ifYoWKIg7fsfOnb93fP493prrVTu5rmI9oYKh5g5C8VteD4mWpDm+kav2OazklA
         6nyL7vUfFqZuWS2dZmbWQXIFFGGipyhGAL/X+AWHF5gXPy6mUaw7ORanuZKUHJgEnB7u
         vHFg==
X-Gm-Message-State: AFq9FYIQhD9T+dbMMk+AAyJVYzCOiV8KuDpgX4PPvrQ1wY1zk3uSyt8C
	DG0Y2GJ1rum98mVPVwgRcYAP9GPhsvh13LO1ByL7Yotm+O9EDUu0wKNpwZ2InARi9tb8L4j31l2
	I5lMt
X-Gm-Gg: AYBFou1BbpJ5V20ly3RxL70u+ZR+dOvSC7DZAfqvEAT0osRJAN+NXxtR7tLSjuAxzsF
	WH3oLyKoM+UnvsuNjLHYeEV0CE0NZ7TH2FQ3FaF3byEEJv1cesicgerU8Rf3khsA8QljBxfqAze
	z5noSQntXGX2ELtgiS7CmaQAo4NOIGuBjxb18WGgPseatUmCK0GMorvfDa08b5yx64NDGGWB9qU
	7ZcmckTRKU1q5Q8kHnTsvGZTJM9NxJVC1aeIpzmr2Ftc/7zaXbwNtAJGKpTcbK78ZKpF/lswrtZ
	wisXolL5XQQED7i2AuAdLN2UdtQv3UDm4VQ4Cne9yEfCocR2V2nGVmIzKAa4AtvoBRpYjXrAaMg
	Y4LNaLCZ+R1LfW4Tn2HXVs6lg+isNh9aUdgO0YOddhkgLfwq5osaAmwMEg6I2MKhzQVZ9COhJZX
	mXWiDaA2axEh/hiU+P1FOxqcJm8dZJZ9LFoFz3hWIVIGWV6S9sK3NGDHuXzckmYbc7lOukwSV/0
	KWmNJVZJStAosOJqAsS9v5OwRba/pRjpUz82WCXZ5hjXNjHP+Xkc9B/mYGl2vJ0U50ZPZEjAsyO
	4Nyw1uNguC6gvtk1ZciFjY6AfY/1f2h46iljpbyz3/qmOFDKHyLo+oiESH6Of/QqlZ4T9dLJLc0
	h
X-Received: by 2002:a05:6808:1993:b0:55c:888:1321 with SMTP id 5614622812f47-5640dd86e2amr166615b6e.42.1793302465653;
        Thu, 29 Oct 2026 12:34:25 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640e37d046sm107380b6e.15.2026.10.29.12.34.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 12:34:25 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: [PATCH v3 1/2] pnfs/blocklayout: don't mark extents committed after a failed LAYOUTCOMMIT
Date: Thu, 29 Oct 2026 15:34:20 -0400
Message-ID: <873767a9a0e14df02e5acaa3bae31ac506591740.1793302358.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793302358.git.bcodding@hammerspace.com>
References: <cover.1793302358.git.bcodding@hammerspace.com>
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

bl_cleanup_layoutcommit() decides whether the server converted the
extents from res.status, which only decode_layoutcommit() sets.  When the
compound fails before the LAYOUTCOMMIT op is decoded, as with a soft
timeout or an error on PUTFH, res.status is still zero and
ext_tree_mark_committed() turns the extents into
PNFS_BLOCK_READWRITE_DATA, although the server may not have converted
them.

Fall back to the task status when res.status is zero.

Fixes: b2be7811dd94 ("pnfsblock: cleanup_layoutcommit")
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Daejun Park <daejun7.park@samsung.com>
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/blocklayout/blocklayout.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index d54a141a89b3..aafcb8e30057 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -794,7 +794,8 @@ bl_prepare_layoutcommit(struct nfs4_layoutcommit_args *arg)
 static void
 bl_cleanup_layoutcommit(struct nfs4_layoutcommit_data *lcdata)
 {
-	ext_tree_mark_committed(&lcdata->args, lcdata->res.status);
+	ext_tree_mark_committed(&lcdata->args,
+				lcdata->res.status ?: lcdata->task.tk_status);
 }
 
 static int
-- 
2.53.0

