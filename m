Received: from mail-ot1-f49.google.com (mail-ot1-f49.google.com [209.85.210.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E093374E48
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:41:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653703; cv=none; b=NQVTroV4IW8TofYZsw1n1IMioWceZS2rivJ5+XOIdxfL9nnma+m4BNQSnTgXE/TJTQ9tTLY87DlFd+3LGIHjuiELNfEy/97oKa9fQhhjGcTgrch+AzLb+qEnS8DKRpuWPG/gWc4srrbNGtPQ74ItqRCKMsrdQkdLapgxoTYduWY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653703; c=relaxed/simple;
	bh=N0AyItrxG0EUhZk/iW2g4sr97e/Ab367XqaKJQiq5gM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=SbGC6sXkIexLdlajoKG5bTMjwgQ+sY3+tgyOXxm52vBVail/5TZWcvIiAv7lLC5WeGnLFr1B59ct0GNv6dtscGopbBItb9rm6QOpFeOXxpxwm/eaxERyvGkDcp+S74mWmdOYULXBexGb6NEPF0DF+k8a/Mnw5hgpl+8Kkvy5cYo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=TBElA3Fk; arc=none smtp.client-ip=209.85.210.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="TBElA3Fk"
Received: by mail-ot1-f49.google.com with SMTP id 46e09a7af769-7eb64371a2aso286301a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:41:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653700; x=1787258500; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=mUhum8PQxuodAcFF25L6KKwDaTO1+tJtXMUUs/p8gu0=;
        b=TBElA3Fkp7Er2PaSrPORZRDo20rcdepa732t3U2HdUPz7bePr5Ldg2vekwb4sKRS3A
         dujlU09ux/ZkddIWQnToDfI1WOz6Brn/+sBUGjYo5rAlmVWDLgGEDogyeLn93+Mq11gb
         DOpGz/iz1m1HQpSwBR0ViwTav0DPtVhGu+8Ffrwd+DIGiicyzc0fGhQt+raa1RhB0Oyu
         laq1RPAYBdX+dC+jwnd4TbMyVMrf51bo3dTzSjQbU97sVnzrBByV1vJE3XNdlRfslTW2
         /kt3ior2Qp2jp+WXinmyQcUKTbzEgScuNbRe5vpKFmPAK0cBbZGCu7VfL4pOKWNzxE6t
         oBLA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653700; x=1787258500;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=mUhum8PQxuodAcFF25L6KKwDaTO1+tJtXMUUs/p8gu0=;
        b=iyNUKcQuzpUi5AAiD88OlhdCYxfhU60rPX7Na7Q4ywlRCQmG6Xq9H9Ajh1TPQjAwPe
         EJVu7U1NVEF8O5GuOEiY3EEvSmc9ZBPmxu0qUjuO00KTmv7ONKQOGKmCb8YBLx9v9GPu
         p71YZ624q2qkypwgpg2GY2alNW0z1AgDTyJpr8zVJmBPjWGSz74UunCn6lpX27rf5YJ1
         z/aCUH+GCN4mAtWU9KoXcwYxhB8z4F6pzgpnOCStDGJt07t2531mS08Y0M+xhRxJDbvN
         aGxQ7dCvbI9czT891McX7XkUJb5dTbk24y39U1s0lQO8qtj3fnmZaA1BBc0BZGUyC5Do
         iVbg==
X-Gm-Message-State: AOJu0YwrcVxFTZfza9QGjCzyCy+juA5bMVtcfPL1FcMK9DfkAuNrNPTo
	Q0rllZaat/52TC7xpm/D8vNUnF0qpv7QIi0o49n23rikIEwjKNjmRTj4r/Ziucz0jjw=
X-Gm-Gg: AR+sD10Iv32tDixGTpxBuKBeiRWFZCoUiHuS6Qqf3X4oFDH/A+MoTa/nCOzSHIayaF6
	rJHiqtuZMwR1hBAhZB90dVRIhiU0U34U/ocMeWdASx7eIgFjEgIX72bP0WSS1FsfaPb6dOGbxVL
	qKMoYhDhWHwkW1Zp2jzIZr70bvkWtm/8OOuZyhZeL1v7EUMYYgmPAztdHqaQTAId7fAy46NLR4B
	nI32SnWeSsREAVAw1xJt46uwqx0onIxjwxooyoaPvWs20zwpOywjvhxHCJFh0+l7UfihAKcxtLD
	R0Z7L8yj1A45RoVxo3vU6fS2fGl6rGm1OhkwxWkc4mu/L96rM6MM+uWKDcP6pMaSp90fbOfpECV
	EEjaa107Esub/HYgdwIai6fRtTje/6Jei/LWh1pNJM6wgFbmPzypbT7cJMFA8hnWNpQbLsrEHJg
	I96LN/kkIGrCl5EsK3IdqNB4tfYtN+MilB8GDZrdaIHOe9SfjbVI+9R1Y1zm4Nv+XLQ7p5umiYt
	mgmzj+Rf4/zspP35CNwT3ZNsIVukXqKM5s=
X-Received: by 2002:a05:6830:6ab1:b0:7ec:6749:f38d with SMTP id 46e09a7af769-7f3ddfd0405mr620332a34.0.1786653700422;
        Thu, 13 Aug 2026 13:41:40 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7f3c9e23b6fsm3087958a34.25.2026.08.13.13.41.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:41:40 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 6/6] NFSv4/flexfiles: allocate the per-mirror stripe array with kvzalloc_objs
Date: Thu, 13 Aug 2026 16:41:31 -0400
Message-ID: <e68826b1ff9d6b60fe018c1eed72e8a09840762e.1786653456.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653456.git.bcodding@hammerspace.com>
References: <cover.1786653456.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Each mirror's stripe array is a single contiguous allocation of
dss_count * sizeof(struct nfs4_ff_layout_ds_stripe) -- roughly 300
bytes per stripe.  With the LAYOUTGET reply buffer no longer capped at
a single page, a wide striped layout can push this well past the
high-order allocation comfort zone (a 2048-stripe mirror is a ~600KB
contiguous allocation) where it can fail under memory fragmentation.

Use kvzalloc_objs() so wide stripe arrays fall back to vmalloc.  Note
the vmalloc fallback is unavailable when the pageio path allocates
under memalloc_noio (swap over pNFS); that case simply behaves as
before.

Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index c4aa995026f6..d96d73d04f01 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -285,8 +285,8 @@ static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(u32 dss_count,
 
 	mirror->dss_count = dss_count;
 	mirror->dss =
-		kzalloc_objs(struct nfs4_ff_layout_ds_stripe, dss_count,
-			     gfp_flags);
+		kvzalloc_objs(struct nfs4_ff_layout_ds_stripe, dss_count,
+			      gfp_flags);
 	if (mirror->dss == NULL) {
 		kfree(mirror);
 		return NULL;
@@ -315,7 +315,7 @@ static void ff_layout_free_mirror(struct nfs4_ff_layout_mirror *mirror)
 		nfs4_ff_layout_put_deviceid(mirror->dss[dss_id].mirror_ds);
 	}
 
-	kfree(mirror->dss);
+	kvfree(mirror->dss);
 	kfree(mirror);
 }
 
-- 
2.53.0

