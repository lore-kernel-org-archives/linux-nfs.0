Received: from mail-pf1-f169.google.com (mail-pf1-f169.google.com [209.85.210.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4D243D3B8
	for <linux-nfs@vger.kernel.org>; Thu, 19 Dec 2024 03:27:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1734578836; cv=none; b=JO/Nzf2E/j+yKUGlYKRpYkPoOUC9Oxop1PEhZgfzpbwdjOOtwIBP0f7oan5sk36cl7zJrWspFH4flKaLnHpG29JqV58bMAth2vzXDgK0yls5QrwlVE5bmRX3f4u2Qqil+YbTy0vKaT4dglgH92uz+XA+VLtw2x/qhA3qUVOPhxE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1734578836; c=relaxed/simple;
	bh=QZ4+f7yIRKcM9/zfQV/ov5cp5AvsVkeqvaPWgOc1yoU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=N9EecCrzW8bdLj0U668oKqZolw8ZDaP6RBXBK6+b+0KG6u4gmDjZvlvtHbcdvAWSpe7DLPCw2JJGIvnUf33S4/2DGJt6hyn9Znmz6kFLTMICVTdLD0RThXZL5gqnX0MmwlyB0Gjv2DZF3HKbM05x2umDejZsYk8d5omocTDbAXU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=en53Dg+I; arc=none smtp.client-ip=209.85.210.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="en53Dg+I"
Received: by mail-pf1-f169.google.com with SMTP id d2e1a72fcca58-7292a83264eso305742b3a.0
        for <linux-nfs@vger.kernel.org>; Wed, 18 Dec 2024 19:27:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1734578834; x=1735183634; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=d71Cs0LA8jsUYI3W9Wprc5B7qzJhXd0CqvlwHf9UOhw=;
        b=en53Dg+IkF4pUZ/KhkJwk7/+srAQTJzm9IVcxFM3brU3o+i2GaE2m8sLfBxTJpTNax
         rLfJd6OzJgzwLrYf7vQkLYOTVDtSPPmjWLHzqijMgcxdaXNxok4IAfrQ4pwRpn1btK4l
         9+TbD/GX7jSnMw2cJWkcvEQ5+v9OJT2XWdyCQw67+MDD/IovJj7bPEzHOCZnUqsKbx/f
         p1fsflBGl2V6v84apxeeLICvqVJ7Ge8Wf1h+vk77n/bbKMztsAGbiQOXRDSYiO7BGwFC
         6gWiApgOldFmBiDb6ii2hI1vims328wJrDGwot/ef4Qg5/1v1Wl+SEZ9qJZbVih/zk1O
         Z6+g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1734578834; x=1735183634;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=d71Cs0LA8jsUYI3W9Wprc5B7qzJhXd0CqvlwHf9UOhw=;
        b=TDg6JXOer9ErQuqN3wdM1LS2RLsYy8M4jF2sot8fXqP8e7m5uEH2t/mCoh9w5yWIiw
         AXWV42zcs20s3Cf2r/2KHX5PEProoZP44OWIoTDtKF+mBH94gkR/F0OAKmQmhlJih62Y
         lCwhUVacYXHTKOh/7ddrvKUahCtGqgVMaMtjpdYJ90BHRALAz8vTunUs8MANY3uJa0R4
         bswOOd/xdUfZGXRfE3u/19UYK7qSvOt4Myo9jDsHGtatZUABhDBVCHawAmLqqVTQ5tLp
         kDgH2xS8geq6mFohhmKTF/AhXbY18NFjRScE8fWk4fnzHTgQvAhoJbxhZyzUX2CNKlrw
         sGmA==
X-Gm-Message-State: AOJu0YwQCL+7cGUxWLGDMfy9seKH9JEHjYZdAt/KQYZodEq+owsC2hRF
	E/0XNiniWmCjSKg2ffVHywTJ6ZKRAIOE8fyp8JCID7It1/GtYHOBIsjSS5sQ
X-Gm-Gg: ASbGnct4m8ZEupX6bSKuiJbMTtzm6VAcp6FLITXan2D971P6ZEbp3GLm9dyLhxK9BAY
	ogWtXiWpCa7itjMALKY61ScXqCJBYzpa0n9SvQ3jUm8+hIfb9IREZsNW8SeL/aFdPav+jChV8HT
	XyYjxMepRGRMP7yV7ehqO0t+EFnaPuN/hjzDAJ2VlPdpxb4tSla+gNBwUpcJ+6QHHjZPhkPticV
	Tm9BtD8GSVhZcvjKur6y82gxGfFJXiwolgThNpgYwp2E2uNQvM3jm/12w==
X-Google-Smtp-Source: AGHT+IEHO/BXRvK5sfp1QTbRoSs9X+2goozDv6bBhIyf0ib/Fb4O6O/a/bWZyUSfAyzAXxXa7/XUHQ==
X-Received: by 2002:a05:6a20:6a1d:b0:1db:df34:a1d6 with SMTP id adf61e73a8af0-1e5b48a4612mr8096914637.42.1734578833606;
        Wed, 18 Dec 2024 19:27:13 -0800 (PST)
Received: from apollo.hsd1.ca.comcast.net ([2601:646:8201:fd20::d5a])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-72aad90ba0asm225194b3a.172.2024.12.18.19.27.12
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Dec 2024 19:27:13 -0800 (PST)
From: Khem Raj <raj.khem@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Khem Raj <raj.khem@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>,
	Steve Dickson <steved@redhat.com>
Subject: [PATCH] Fix typecast warning with clang
Date: Wed, 18 Dec 2024 19:27:09 -0800
Message-ID: <20241219032709.4173094-1-raj.khem@gmail.com>
X-Mailer: git-send-email 2.47.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Fixes
file.c:200:8: error: assigning to 'char *' from 'const char *' discards qualifiers [-Werror,-Wincompatible-pointer-types-discards-qualifiers]

Signed-off-by: Khem Raj <raj.khem@gmail.com>
Cc: Benjamin Coddington <bcodding@redhat.com>
Cc: Steve Dickson <steved@redhat.com>
---
 support/nsm/file.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/nsm/file.c b/support/nsm/file.c
index de122b0..0fa6164 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -197,7 +197,7 @@ nsm_make_temp_pathname(const char *pathname)
 
 	base = strrchr(pathname, '/');
 	if (base == NULL)
-		base = pathname;
+		base = (char*)pathname;
 	else
 		base++;
 
