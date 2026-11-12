Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.171
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794501004;
	b=nox+Z2kIiv5ZIoiOYnLSIL2Ivt4lAc3Vn0eF6ZcBh+JeSwGzq+N4MT6Nf85EOk5mvOsC
	 SZjOgqlNppNQnQwFS6STsOfuH0k+XoEWYAPJ3+g9OcRCtyRvoG7gAJTE3ssO/WM28SbQs
	 QkBztKZx8PuMyvBb+TN9XiBVKV4BGpHJjGmLnW2gf7EtBaOC+d04zdyzgVYxKZxpF+U88
	 fYR+9fn9nB9aRuEFimpI0S1ymn5MNhf3//Fn/+kz8IKmHND0qsZ5jZwZ2mX0K4ulvNqek
	 HksmFDy5TOFCZoQiWhD49CKJvq9J5+67QwfTQwyhzqMliQe0d/Wu/n0uJV9ijTgwS4w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794501004;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=nIeidz39YEWLTsdrWkspKgvwARrIKlL4u59uZHie4Bk=;
	b=dtyvYZjSDz8V3FHolJhhiKtYcrAlJoym6+v5dk2BUVLY50Z4R6JBycf4RiQgPSb+4jbb
	 iecPkSM4oDwjCG/TFEdcPAuSmjsUhT/ShMk+fyhxT4SKNe1srxRO1Zq/rjquPCYr/AXTO
	 IdlGMBowU95QXhu8ypohHGk+j3wxdVsTNMqi1xp10tqD7CLivNBE319q2l1kt5CT2d/zo
	 SYWw3iUcCQFqWY5ocLFOL1GdaEbuUf32WMqJHrsB5l7wFyBMZq5LBTxDUZXWmHx26Hvwo
	 QkLqjMent2e04XD7pIyBhdSYt6/GTkukckjlL3kdo/1s7aVnWUjNrxQqWtbydTC/0sg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=uGbbynci;
	arc=none smtp.remote-ip=74.125.82.171
Received: from mail-dy1-f171.google.com (mail-dy1-f171.google.com [74.125.82.171])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67F96606A323
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 16:30:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 67F96606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=uGbbynci
Received: by mail-dy1-f171.google.com with SMTP id 5a478bee46e88-36e99cf7bb3so76642eec.0
        for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 08:30:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794501003; x=1795105803; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=nIeidz39YEWLTsdrWkspKgvwARrIKlL4u59uZHie4Bk=;
        b=uGbbyncilLtXMuA7FCuPCR2hXppaswn/eKnx6cVUI+wGxmWGn8qPfnoLJe7tncnZsN
         8/fFr0+2GjHUh4NWOy0T4/pdfJqH/+SWX+jM0hq0kPk3HaWc2t70PKIvoDGRjmt40SNF
         n8kb587+GDI0TKNmyP/ByOQowRvXIOyn30WWG2L+800frxfW/C1AzGxu4njCKRO95GiP
         8cHkBFEwnwX7est4qrXSFoJbwOQlW7fW4dacKYeRhirSU3U7Eiy0de/siUv29gzpPNJE
         bkLb43Upk3tuuLaG4vo34skJI/wYST76rXLBNdBo+LkQLdPYsPTEv/CGXS8qfMRaRhrG
         VFJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794501003; x=1795105803;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=nIeidz39YEWLTsdrWkspKgvwARrIKlL4u59uZHie4Bk=;
        b=uJrr17Ny5NoEtU4bh9iKbKF5adTgL7iwvXI0m9+e4vhOESormT2QjEg2GcXFBaLjSZ
         ybaSUVQkUtdvXepoz1XLpUCy6jHlqowYuk0fMa5xKk7d8hrAGntMtSoRT6R+qhNLbPcR
         7mJjiPQyyliHbjWxkb0AvmqN8TvEzlywWOPSnl+cSWJ34yLDUBKQiMEhB6K4Pi0Bhx+E
         mgcjq6U8Xv201Sw4VXfDSBhNknNW8jz6KKkkxk7l2ocSe/b242quEWirizUbfMaLL7iW
         qJTja6+PwlelcVdRPLi6LUd5TNJcuf8WoFgYa2YcNCW137OshZHCsrZIFl0myD06XwP6
         IYbg==
X-Forwarded-Encrypted: i=1; AL+hErHVXrjCdkLv6yR5uiwBg3ODd9a9F5QH9lG6Zzen9dyybFCt2LWZN579wkVknkA1DXCJV/0pEWwdzng=@vger.kernel.org
X-Gm-Message-State: APuU4Z8cGheXk2cgMKxhwZt/oCK2/X1fTTFOjxNjgGLjzpSMozJbhdSo
	PEYCf1HG5B06LqVKVrmfumCAuXaualjvvVd5wQVnN6zMrxxNcuxRdvIS
X-Gm-Gg: AYBFou19eTmPetuhQvABahCkZZ1QtUF0S1aRMQTTZNo50wpdTX6YAhuP6OYSMAG4J1M
	3CCYL8RBjBeL9o5wPo6s3apONv/d58A6Z6QAg/JatVzvDp8p7ZnL52TonPhbruy1CvE5fGmBx8W
	gDL7WsZ66buwY9tyVfRT+Hr+PDu5M2T8XM+06jYSF+/leVclDaYlxb+QgxgxIHqK2M+ga3RNr/d
	lyBv/6cpooWv7fBvLtExO30D5tcoAqM7KWS5vafzAunfhrjGHJ2p1o5sovGWDM/OHyU9Cr9MCRs
	EkdL/uKYcdj2obyu+GY9tMFyKIKUxzuqboR+oZi/TiyAlhPtMvrh5s+V1Tlz7RHhVhvizAwUCHM
	HXT0KXTGHw15O6GXEFYek2qrNOSJeki687aDyTUv1nYICQZwf1Bc0ylN3xRU/z4fnqE5yDXOuPS
	K0P9PWNo7B0ZPaz3SqJzqNqVvnP66h5xPsRjoIpAXVJ/AxJSHxkxrI1ted8vkUnmaIX/ipuqj2V
	VNSi0tL2hq9B/7j1hxAgEFS0soMFErYWx2NRQR91cZTAfOwoE+5Si24j/hXPPfpuNjXaFdsVql7
	cuq+DjRkKmZvikP3f9k5nuO6s58=
X-Received: by 2002:a05:7301:4184:b0:36c:ec0:23ef with SMTP id 5a478bee46e88-3768617340amr8581887eec.16.1794501003121;
        Thu, 12 Nov 2026 08:30:03 -0800 (PST)
Received: from ubuntu.. ([2405:201:8026:213e:d30:9c98:e9c8:b461])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-3792003aefasm1209418eec.0.2026.11.12.08.29.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 12 Nov 2026 08:30:02 -0800 (PST)
From: mdshahid03@gmail.com
To: trondmy@kernel.org
Cc: anna@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Mohammad Shahid <mdshahid03@gmail.com>
Subject: [PATCH v2] NFS: idmap: handle zero return from nfs_idmap_get_key()
Date: Thu, 12 Nov 2026 21:59:38 +0530
Message-ID: <20261112162938.14329-1-mdshahid03@gmail.com>
X-Mailer: git-send-email 2.43.0
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

From: Mohammad Shahid <mdshahid03@gmail.com>

nfs_idmap_get_key() can return zero, but nfs_idmap_lookup_name()
treats only negative values as errors.

Treat zero as an error to avoid reporting an unsuccessful lookup
as successful.

Signed-off-by: Mohammad Shahid <mdshahid03@gmail.com>
---
 fs/nfs/nfs4idmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index 06b193722660..8f5f0abf804d 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -353,7 +353,7 @@ static ssize_t nfs_idmap_lookup_name(__u32 id, const char *type, char *buf,
 
 	id_len = nfs_map_numeric_to_string(id, id_str, sizeof(id_str));
 	ret = nfs_idmap_get_key(id_str, id_len, type, buf, buflen, idmap);
-	if (ret < 0)
+	if (ret <= 0)
 		return -EINVAL;
 	return ret;
 }
-- 
2.43.0

