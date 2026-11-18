Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795044354;
	b=CJLe/ahB1/LLKh4KHASSmEulyY2X95BaJuH8cEkWa78lptZbkpg9BZH2CWvQKCVJ0BEF
	 SN/Rx+e9u442bOty3eaHCOeS1FEPyruf8C7VxbCIYxroqoEhKVUXy4Xp7JDOqtQhp09MZ
	 JaKo6Kd01YEofoJ1+plPsbfE5TFEiYx6p1Q0G9u8qkkN4TX8ooHXiBVz62pJ8EWCYlk9t
	 Tj3TRsQrd025lzl05PUp2QpSceuGV5LyHSjWCDIZLCafg6eOJud2B0dv/GoJPqgJ9GtGk
	 xyrhEI8avVDhUX5wdKOJPZFwig8cmsAbHROAkgPB52DjqFvFrKEXRD9hPQO3lMRW8MQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795044354;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=tae7aopOIU89uF1DEdpjlBNPrnW3iY+79RkU9S52l98=;
	b=EiDBxOFEqbRGEdASHDkkdeC0X4xrinFp1fOgxx2uA3anUusCXlhaZ/P6yEWgr2rVSICb
	 EUZvdUQFa23xYnDl0lpWJJWvN1oFFXmwZnY/XbyXyxGbjiQ1YCPJXfcdv1NwJqCN+Uada
	 /HbBKLyqNxZ7YRxSzufq1dO5gq+uOa7N971dv2am+UnxEqLIVz7eUKYcTJX1IWsUVb7tA
	 tEXK2Kw/LsYTTzdMe/w2Qf1Y88693FSlmhdp/YgSIvrTysn5zhmaMLLDc34Js7mrMY++S
	 BOfrhEiO1l5xTYqcZXDjn6RgSyLx2lhgrce4M4N4N9d9rFdWLzXRnFF3zQ5aVrgIHLg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=gYzfkKJm;
	arc=none smtp.remote-ip=209.85.161.53
Received: from mail-oo1-f53.google.com (mail-oo1-f53.google.com [209.85.161.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74129606A320
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 23:25:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 74129606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=gYzfkKJm
Received: by mail-oo1-f53.google.com with SMTP id 006d021491bc7-70b875f6f13so1358679eaf.0
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 15:25:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795044353; x=1795649153; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=tae7aopOIU89uF1DEdpjlBNPrnW3iY+79RkU9S52l98=;
        b=gYzfkKJmTWn7W/2eqf+8CVGYtjKPDHNdGuX03FNCpawwPYSyLcbbZTPFa0HHyUTp9D
         Y0Rw6aVeBbpwBEIst3q6bk3acBxfjVE3wzc5uE0YOhImLzG4DYViG29YaGO6/4WN+rzj
         SSvPX93SqmzEoSBzfBWPOI9bgAxVujCp0ONFm8ub+OwqTFEEje/rzQ60zfzYJsuiSYut
         2X1+sPNsGEnJZa9O/1HexoO2on27BVBjSEa8N3np7cYV0bAONR7FSiEjMQZ9dWmeHnQy
         jVmiWbPbi4vMALNlmZ7FwFlsLJ/red90hv37BmWjEL/nGF/jWbPbGlGst4qIfCnmW+2Q
         SD+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795044353; x=1795649153;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=tae7aopOIU89uF1DEdpjlBNPrnW3iY+79RkU9S52l98=;
        b=ndE0afdtQ4slv9sFcAGRLRbbXV9eB1s39zb6zNPHycNAyF32Bu1txW8nc01ZdTE1th
         gePXfRXlSJXYuzFQ1dYuE7Pk62HWMPaiCE78rJvhrW6I2PipUyDCbwUnYCtFxBHHAYXl
         iBZSdOzLHJFWd5xjvdS44CEgDhounoeJdPYoDoMbxBnm+o2RDTgPTd1efQLUVv21Hdps
         9Mx8czgpTgF4kAJhwx06EyrZe6fux4Udv6gKJXlubz6yR1ldUS5puo9FwK1Z45drktJG
         KSfXYewP6dwL+asN+cTV5gFW/cQFOz2S9zFk0yr+lJmPmttRRW4sy7EZH/DQ2q5c+PVD
         GMNw==
X-Gm-Message-State: APuU4Z/DmNa8pqDlzmDTeYWxmPTMbnw5Xw1u99fDaESMFHQh4fVRHhJx
	X8dU3/NK67QLU8jDyXE6zD2hE9NZaRalJZXOZT1k4mwbwkjwWGpYSwOEl6HhfPD2rE8=
X-Gm-Gg: AYBFou2pwaDoK6pDXbnq78bQf69fD9pzSaEJdk8dSsKHzWdVhQBwPvYUlnDNHmvu6gS
	Hj2Vuxu9gWHQcde32jlO5/iiO1b5V3OzjoxaPmgbjTYKdI1MuecstIq49Iz6eraMCcG87naO5Vd
	JTO8+6j0+Xl5uYV/lN64jWSKky5xDhoWRHWyDBxmt0q8hVkQzcROBp6YOCDNUOK0ZPLkHEpRDlc
	J3yu+VyIuzD461qInhunm6hXDGSfqxHDERz2PXd1HAyTs7qiHXicqIyBLLDwsAiSOIaX1wB7vpA
	yo2+EZ3zubuwqThYYCzEdxXO1VbsxnoW+qbEWnXAD2ieRk+SCIDoz4ZFbTjiDw7Ng+EHr2Cnttf
	5pA44OvXmDvO9VDQSksXqNv6hLUZrvEDi/P9DdC+moSfiMWTV+KFrIUz0cHOe59wkXrYEaa+djj
	xkM5dK1hDiUfZUTkEEr0lGyN3yfps5HVZ/6KvvFREJTpg0RQTLPZMWk2PT0u3YLcQ0AiITRAxqN
	7se9MVtE7oU0S9fSb9nNraYddb8Mo9tYa0Qja1nipQ7+EyXn8revkKnYnIe2TRSAfza4ZtnZ0m3
	JuUU+hzAeumBx0u1HRoS0qQ2ExheizqbPurkCRP0ypMGID4LxlvqrlgbN0z/XNy4HzuOCT1K+GI
	uWw==
X-Received: by 2002:a05:6820:1518:b0:6f9:4f1b:3987 with SMTP id 006d021491bc7-71b185a5970mr3619585eaf.59.1795044353194;
        Wed, 18 Nov 2026 15:25:53 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-71b195163d3sm2981249eaf.10.2026.11.18.15.25.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Nov 2026 15:25:52 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] MAINTAINERS: add Benjamin Coddington as NFS client reviewer
Date: Wed, 18 Nov 2026 18:25:51 -0500
Message-ID: <eb85f7d92430faeb39efa90f9cdbdfa0707b0b2d.1795044097.git.bcodding@hammerspace.com>
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

From: Benjamin Coddington <bcodding@hammerspace.com>

Add myself as a reviewer for the NFS client.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index d738990161bd..cc43b32af0c8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -19869,6 +19869,7 @@ F:	tools/testing/selftests/nci/
 NFS, SUNRPC, AND LOCKD CLIENTS
 M:	Trond Myklebust <trondmy@kernel.org>
 M:	Anna Schumaker <anna@kernel.org>
+R:	Benjamin Coddington <bcodding@hammerspace.com>
 L:	linux-nfs@vger.kernel.org
 S:	Maintained
 W:	http://client.linux-nfs.org

base-commit: 666539eecdf4db623f5e3c3e55cf9f2dfad24aa4
-- 
2.53.0

