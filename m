Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795618422;
	b=2WhmVI6dDphV73Y2tdIu1XsMbopCxEk2NKvlTWaWfYB27zpDacAa/01B6MXusJ3nikf7
	 H+JYZ+vhcn7VTSkNKQdzR8b110tR8ltNYa/v9cY7zf4uYv7mejngHHq67jf+zYM+hLF5A
	 JUxP4B7jBoQm0KUVVPct/BAH1UceSJn2dhsxoyr5Q0+gYbvGGujm8VWM7tEITA+31alRi
	 xlbI/lSN09lsUaT1wy0VmgU4YVUYZ4P3lmfqvkUktNE2K9GJfNUiUVEQ6O6oMnrYf0Kgx
	 ihGgQF5lOiFX2R9CwaVA1kHjc5/opyFvMqQxEJL9p8Xj483mKDiDwY4UqQiXxKKaXng==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795618422;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=d2lfChipG1VDsT9gsXVt4ivGa36+iCcyx6HOJviIIa8=;
	b=FBkcMhp2ssYy/COn6SOxjZfWD3wtMAA126HW3T/ZmmCe2ZGcvyt4wt4qrC4D1Va5+k2o
	 jp/dWcp0W3Jp9TXr/mMNgvFC7hUaIT5AwJOPOOBTLQQncefKDRAQZ1qk0GMYFPM01dRvX
	 3IGbY/ZKohlFlUtBtsYZUEvnc+IAQI5FxPGhTUPWI2c9xGJy8CA/p9WcSTqAK57RV9KuC
	 PdO6LsCCV3TmIDssDSB/sdz1RX8Cp0l48dbyYZoyKfS+TqXTUMjN3lz0mhSN8m68OZGKP
	 WEzxJX8mC7gKivFg87qb7V+GkGKpBdYAwTM1QM/olCUdlH7JFbT5vEacbWnL8eZxGAw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=bLzUDUab;
	arc=none smtp.remote-ip=209.85.221.53
Received: from mail-wr1-f53.google.com (mail-wr1-f53.google.com [209.85.221.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB843606A323
	for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 14:53:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DB843606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=bLzUDUab
Received: by mail-wr1-f53.google.com with SMTP id ffacd0b85a97d-49a92144733so2901879f8f.0
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 06:53:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795618420; x=1796223220; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=d2lfChipG1VDsT9gsXVt4ivGa36+iCcyx6HOJviIIa8=;
        b=bLzUDUabM6HHF8ReJZ+PuhxvKuo2UBrsG+2dFq9ThxqsLMATJKKrpBJsZpaWj3n2Kn
         lCo1dS8gNa6UgXcaTeNiwA+4ct1a3T64sHL2u1evKn19KSADQZuBUdlbmxI9AVmAA10J
         T8goHJrum4r2ugmh8gNvgB4nK3ONFOTLN5S8fW47/FjHtJUa+Xyzi+0L2Wj24m4fpLS8
         YLhSOY6HCpG4MWDPhv17NRwMr3ND2UXcL3PbNeBCKoSqxY/4spYBZ80jdLbO2Lme2RvX
         CCnWa+oJqbPG6lRz6EndETnAabR927wrLJ1CS5Gu/8s4dtyvag/1c2PdeJF3N3U1Ru+0
         WQHQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795618420; x=1796223220;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=d2lfChipG1VDsT9gsXVt4ivGa36+iCcyx6HOJviIIa8=;
        b=HDYzjWa7Rs6TjPXSuTc0IOMkC5h3d2jiz/HmxXFBUjI31IbL7SKVyVoKghfUWDVNZV
         +1WL4ZKwVFrDCyWXhS/5K36S1FAb5lbOuKe9iZfCZd7DWLNr1JeFTBV1qdjiRNSxqEcW
         /wzGFaOrjgUwIt3Wzrs72do8dz19/EBLbHfyX5hdusjeUiw/PmIYQgG0Y4ghbp6ULHer
         PtsoYQdPpsZGr3sCoXfmPEUZi85I6Qzfg6r9SmvI/I3Jm6pDQemIwxs065z5wLIEknc3
         GPAJRM8fLvHlzTS1/yiw3F5crbRJgAjaBnBAjN/cxWf8g3pN0rpsAM0pCJ8+ZZbgMuMj
         dySg==
X-Gm-Message-State: APuU4Z8CiDvTywyyUcIMGGebxYZAt59uv0oCPtVkAyyqKo8zKcBR31hJ
	uWvi4khXH76Jxt4dSskA/tXltA0FAHq1Q7Bww1zuQmEZV6RWNJUEF5k3
X-Gm-Gg: AZFdTZfDkaf0HJ8oJWi0MR4h+eerteFDeN4+JQoxEG1CjioYf2Lhy+HA9E/aKLauNHA
	aFC9aOsZc9NGIp2pDWNjwVuBjEORmIEJYSxcVS22CgNUT2q7njYnWWf32x+a7sB1DPKiJdzOXIC
	rpXCjcHVQ2R6IRXob26D7cHJRCIB1IUwf74YJhOkSD8lk/9pZiFe/HTUR0EiTFe5gA5jPy7hUqe
	2acw7qZC3ZeAeV9TgzNbf9Zvkd+3jNy8/4+sqZpNez8qPglCcIYponj5TCRt1d7SwHlon+xhfL/
	MS5AYC55aqnEyAO42bSac7rqMr8sDyybXGi5+zOav++7R6NvDp5cA1FflM+axdmpuvLMUOY7XCW
	5hj1szUbfvwzH+Wkru++ukkAnqpO5d4KGPvhhMmzv+if5XO6gDscmDGNP59AJeqpgrc1xiImj7j
	lKarS9irIDQ/WjNQkYzZpCr2OZ+55EA34wOtQxeoqQPVvs9zMLg5sYNc1St8PtuKgDIGSjkMc0J
	m2b1PGNLjxy3Ns1v9pnVwHkPiPDjVY59MrTrzsFxOoGV7AVJ+cZIhFYzJJQ9/WqDipPXjrFtvjV
	c9qALsAYvWD6ouerxznsZMQPrVDcT9j/0kXVwdkMVqqdwoM5HH38Vgz7Viu4Px7Pg23aDoCsdL6
	Jhu4Gy9lM0iNM60u4xEv9XDXQ2PgTY2AMqndSfhIelqMnHP+J5JW0hns9L6kocWggnBOhKw==
X-Received: by 2002:a5d:5888:0:b0:490:a481:7ac8 with SMTP id ffacd0b85a97d-4abb532ea79mr33520603f8f.29.1795618419795;
        Wed, 25 Nov 2026 06:53:39 -0800 (PST)
Received: from DESKTOP-0KSTGNI.localdomain ([197.52.150.30])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ab6a67f204sm41154207f8f.21.2026.11.25.06.53.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 25 Nov 2026 06:53:39 -0800 (PST)
From: Temitope obabi <obabitemitope765@gmail.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	rostedt@goodmis.org,
	obabitemitope765@gmail.com
Subject: [PATCH] NFSv4: Remove unused nfs4_renew tracepoint
Date: Wed, 25 Nov 2026 16:53:02 +0200
Message-ID: <20261125145302.4091-1-obabitemitope765@gmail.com>
X-Mailer: git-send-email 2.53.0
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

The nfs4_renew tracepoint was added by commit c6d01c6f9bf9 ("NFSv4: Add
tracepoints for debugging state management problems") but nothing has
ever called trace_nfs4_renew().

Remove this unused tracepoint.

Signed-off-by: Temitope obabi <obabitemitope765@gmail.com>
---
 fs/nfs/nfs4trace.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index b5c89eeef2bc..d3406f132ff5 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -70,7 +70,6 @@ DECLARE_EVENT_CLASS(nfs4_clientid_event,
 			TP_ARGS(clp, error))
 DEFINE_NFS4_CLIENTID_EVENT(nfs4_setclientid);
 DEFINE_NFS4_CLIENTID_EVENT(nfs4_setclientid_confirm);
-DEFINE_NFS4_CLIENTID_EVENT(nfs4_renew);
 DEFINE_NFS4_CLIENTID_EVENT(nfs4_renew_async);
 DEFINE_NFS4_CLIENTID_EVENT(nfs4_exchange_id);
 DEFINE_NFS4_CLIENTID_EVENT(nfs4_create_session);
-- 
2.53.0

