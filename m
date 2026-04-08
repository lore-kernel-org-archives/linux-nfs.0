Received: from mail-pf1-f170.google.com (mail-pf1-f170.google.com [209.85.210.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D6C634B43F
	for <linux-nfs@vger.kernel.org>; Wed,  8 Apr 2026 16:14:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775664884; cv=none; b=c8EEyZwBbBiVNGBgiUtr7Mg+Lmuug+JMbZ1siJF/0BGybTsMz3siKl3y6sAEYCswIPhdr/nyFFu6sz2XaPL2iYnoSCZ8vAnXnrnFKFLtiD6B0qj8Zo2lA6L/HrHUtYOI1jk7xyLf4g2iBjd+BBfF/KP3DH1/aBdvYltcy+lMDIg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775664884; c=relaxed/simple;
	bh=We0Ga4xBIv/TGdOESC7u6547XRvqcfYukXrOn3fq6Oc=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=E2m7wyThtrpxw0btOPmQ0xWwxEP8ex4EPcfSP4jYPV3gq1Lnq3IUypOHdqn4moDJYXlEhIM+ux5XKIjKTB3wn6thycF9Yd9Lme2E+lUjZ4n77Vxr4SEr7ce4omrch3hZRvzNJLWRtIxtat+c7cdWWBjUEvaQZD55X6a5s7uqwzU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=F5gkwl/8; arc=none smtp.client-ip=209.85.210.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="F5gkwl/8"
Received: by mail-pf1-f170.google.com with SMTP id d2e1a72fcca58-82735a41920so2305176b3a.2
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2026 09:14:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1775664882; x=1776269682; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=xu4kBECQDX+Dvod6HfElP5DdkVcjXtKLiG9bBHD4KiA=;
        b=F5gkwl/8BSn2aq6ciAJjVPIsm0JpkznbaCPyw2rwJddt3GcVKLe69d62z78hif7Nce
         Z13StFMdF5hgnCOTTZm/6ZZJyPU6f00GwYmS/xvQZ5cVrTazf0crHgU4kHp3c19KYyZV
         ZWVwEZqd7d/YzR1i1c9S4PXqxvWpnbAVl8IYzcbQJBNWPDQCBOwjKl7rgS8p6JblbZD3
         Wc7ktFccJoNn/tg+4vu62x4MyP3aLas3FMJmMbQYQtwqr6xqXpH8dGGCuNJpYbi8VgFy
         WjC++StoiIw2SUQkgsAfCBokjE8abqtm/KWoGZwi0P4a+0Ct+1pCr9CLpunwrp7w44M3
         DHbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1775664882; x=1776269682;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=xu4kBECQDX+Dvod6HfElP5DdkVcjXtKLiG9bBHD4KiA=;
        b=jeYS9tzQIyQ2QOep8h0sathv2oKu3CsHUTKDQTLuuMpuGp/E3rHECa6APX65NdXFz8
         8fBSwf6Eh7OgtCfdVltQ6SXpnnp76o5RFQyup98x4rLzDyQ+TS8gtZ8GZTuT9XNFcTqJ
         C4npodmkVovIQTVlUw1w4jojNEBhoezEEUfzvOaz1xbhmqSkNuJACyH0RUnvXSbR5rej
         qYJqO3SOlXGmvSIEw4cqJJLQ5/jas4ryu2DHy+I/SCftyLDQqMLPafvrLldWHJQs/eYx
         SY12ZvC9K7seBVTHVTvOBsbFDv8bHh6T096GtlIueyKqC6VsKfWnlSEgSjp/TeOpCrED
         FySw==
X-Gm-Message-State: AOJu0Yw25NussjAb+NTQZHfzMuyHQr+YAv23QBmY3/SI380VBc0ff9RI
	Y1M9ARrS0XaRsqYzHMgKawkyQYwvClaXn1Ws6dhfD89MD7ROMckDt7O5
X-Gm-Gg: AeBDieu1hRJkDJKU81XhrZuL47193LDuKo7KyGfvKbIMmB2cyjvN1AlQ/0IF1/rG8R+
	FyM8mU482u/sO2j5CBbzXx1dJMS+9AviPjmX5vo9EhrhokWX5RY6VfAYgJ8qBHjpdr4lBsmACtR
	GbgwuLa40Oigr0303R8dfJqijMqduYenb6O04JhmZSzf/ocXVQApmgM3GBhVlfXcebdMrzCg4qS
	YuCCQF/SBsvKoQUKVM7JePobBZ2pNQp6xMWeujPS3Y8dtvliLS/4ZlA95Whz9gys5TisF4lZofX
	Xf0NK90Gmz7jz3TzaIsyDF9Wq5IyAlWWrYCYeUECnMuHOp8m4aqOYsU5Yo5t8vmtJTjcibT4muU
	beNosV76Ib9PfSTBEOEjgUKTVncKni41BdYhOMPvph+DaiKA1WXk1QJ6vQ/rcH50pqOitlCKSMv
	whKHnqzzBL2Wiehf8RpP6Qrdgt2ZTedz3Czn5HQagHHHs+kQQ52/TQ6Nmo+8Ji8lwvChnq0OPaV
	g==
X-Received: by 2002:a05:6a00:a0b:b0:81f:852b:a925 with SMTP id d2e1a72fcca58-82d0da4594cmr21144896b3a.1.1775664881789;
        Wed, 08 Apr 2026 09:14:41 -0700 (PDT)
Received: from sean-All-Series.. (59-115-195-252.dynamic-ip.hinet.net. [59.115.195.252])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-82cf9ca4efesm21916840b3a.61.2026.04.08.09.14.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 08 Apr 2026 09:14:41 -0700 (PDT)
From: Sean Chang <seanwascoding@gmail.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sean Chang <seanwascoding@gmail.com>
Subject: [PATCH v1 1/2] NFS: fix RCU safety in nfs_compare_super_address
Date: Thu,  9 Apr 2026 00:14:27 +0800
Message-Id: <20260408161428.155169-2-seanwascoding@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20260408161428.155169-1-seanwascoding@gmail.com>
References: <20260408161428.155169-1-seanwascoding@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The cl_xprt pointer in struct rpc_clnt is marked as __rcu. Accessing
it directly in nfs_compare_super_address() without RCU protection is
unsafe and triggers Sparse warnings about dereferencing noderef
expressions.

Fix this by wrapping the access with rcu_read_lock() and using
rcu_dereference() to safely retrieve the transport pointer. This
ensures the xprt remains valid during the comparison of network
namespaces and addresses, preventing potential use-after-free during
concurrent transport updates.

Signed-off-by: Sean Chang <seanwascoding@gmail.com>
---
 fs/nfs/super.c | 32 ++++++++++++++++++++++----------
 1 file changed, 22 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7a318581f85b..071337f9ea37 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1166,43 +1166,55 @@ static int nfs_set_super(struct super_block *s, struct fs_context *fc)
 static int nfs_compare_super_address(struct nfs_server *server1,
 				     struct nfs_server *server2)
 {
+	struct rpc_xprt *xprt1, *xprt2;
 	struct sockaddr *sap1, *sap2;
-	struct rpc_xprt *xprt1 = server1->client->cl_xprt;
-	struct rpc_xprt *xprt2 = server2->client->cl_xprt;
+	int ret = 0;
+
+	rcu_read_lock();
+
+	xprt1 = rcu_dereference(server1->client->cl_xprt);
+	xprt2 = rcu_dereference(server2->client->cl_xprt);
+
+	if (!xprt1 || !xprt2)
+		goto out;
 
 	if (!net_eq(xprt1->xprt_net, xprt2->xprt_net))
-		return 0;
+		goto out;
 
 	sap1 = (struct sockaddr *)&server1->nfs_client->cl_addr;
 	sap2 = (struct sockaddr *)&server2->nfs_client->cl_addr;
 
 	if (sap1->sa_family != sap2->sa_family)
-		return 0;
+		goto out;
 
 	switch (sap1->sa_family) {
 	case AF_INET: {
 		struct sockaddr_in *sin1 = (struct sockaddr_in *)sap1;
 		struct sockaddr_in *sin2 = (struct sockaddr_in *)sap2;
 		if (sin1->sin_addr.s_addr != sin2->sin_addr.s_addr)
-			return 0;
+			goto out;
 		if (sin1->sin_port != sin2->sin_port)
-			return 0;
+			goto out;
 		break;
 	}
 	case AF_INET6: {
 		struct sockaddr_in6 *sin1 = (struct sockaddr_in6 *)sap1;
 		struct sockaddr_in6 *sin2 = (struct sockaddr_in6 *)sap2;
 		if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
-			return 0;
+			goto out;
 		if (sin1->sin6_port != sin2->sin6_port)
-			return 0;
+			goto out;
 		break;
 	}
 	default:
-		return 0;
+		goto out;
 	}
 
-	return 1;
+	ret = 1;
+
+out:
+	rcu_read_unlock();
+	return ret;
 }
 
 static int nfs_compare_userns(const struct nfs_server *old,
-- 
2.34.1

