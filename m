Received: from mail-pf1-f169.google.com (mail-pf1-f169.google.com [209.85.210.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F37D52DB7AE
	for <linux-nfs@vger.kernel.org>; Sat,  7 Mar 2026 14:08:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772892540; cv=none; b=b9q38jsg3tCVJ5taPITBJX+vHRu7k4sZhBOCSEB9mQYZOU2iJubUCjHyojEXEun8jIRyBLsdqFv1tKXbC/2zplgn1+17q/Cw7yUw/QEK47f2dro1hksq5T+xJHa8rrH0xYZsBDamP2Ll59TS5QHbCzRsotAav0oR9Ro5VHUnu+w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772892540; c=relaxed/simple;
	bh=EKC+gjybz5QCo3/A2SoLkAdJ9dHzP8glwvLLU31BmCA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=F+Gq394CNx+fqYDWW3Mx8ztrpVostCRLEnrv+lfk0A4kKIOdP/MX9ImT4dryjP/Gxsl5tsZsooPlHDXm+irfpbnbP91wb0+OT8D92uzTtRNxhKhMnq7W98rTZgkchwpCx6ihRdhWLBBmYK0aesfaUJEc3cYk8k9abk9C7FSLQzc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Wb4wDDw+; arc=none smtp.client-ip=209.85.210.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Wb4wDDw+"
Received: by mail-pf1-f169.google.com with SMTP id d2e1a72fcca58-829a568f3ccso738083b3a.0
        for <linux-nfs@vger.kernel.org>; Sat, 07 Mar 2026 06:08:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1772892538; x=1773497338; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=cE+gTqS6Acm3OjdFoCwcpAog50aFpqNiNU85af164dY=;
        b=Wb4wDDw+bHkQ4QFzd7CHYDyzuX9Cl9DuRHEoFHcFXRQBaG189KJfreVVIKpg0El3ca
         Yuse00bqCOE7lUV8ol5l8BttdYmXWtdgfInJa2s4lr7KWXKlPikHYp9gToDd23z/uFPX
         U+TjbjA09cEMI7QhrOSNztXQQVqWppg93HTKILs6u4qdZ5V720HMM9ubv/3AkShDxd9+
         HRuqnQAn4xWwYR1PHOJdWmJCGECsOSGBGhYLHsia68y4sZd5DPJY4F2d+2aJsGGMLRsr
         F0HGQMF39Ct7hJv9fyZjDVmFUDKFQybmZJkVqkcXWPKPr5N6RY0roySeVDzrZld+y9WG
         fo4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1772892538; x=1773497338;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=cE+gTqS6Acm3OjdFoCwcpAog50aFpqNiNU85af164dY=;
        b=WJSjglDjfSQq0sQck5LTI9Wbj3HW2T8WJo09fGmqwVSZtGMx8Sk2OV3uUiHfd/Azc0
         2MU3oWlSmesd1Wrt/3B7r1hTbLBWIQTNafr/JKvvUF+mjUqgNLzOFNe/gvB/7wepnXHs
         UM02il7crIDABEtoRXiYBfylGfUb1Q4h2KpkzmCsTzKUwlZ+DA10gevJte10F1T1faL+
         GPTLjp0Bnx65FEloIk0rdkvHZ0TD3VBNMSbi9Ex5w93nvCSjF8jf9wxQlpAiCOOgIgt4
         xmjlCUF08FNL9Sgj8BizpM/m/FqNjYCXML6ElH9DkI2U15ycNqNT5ALu3PT7Hxqj4BNy
         moPA==
X-Forwarded-Encrypted: i=1; AJvYcCW/B24WmHESEQG3TGXZkPW26kgEteGtRJzQxHkZvmtb9ls7MP6sCpnAnEcOlW7VH05uEMRAD+YcdLE=@vger.kernel.org
X-Gm-Message-State: AOJu0YzfHtrm7pmC0CrQDCHfDfJk3ujzENqaC8DWMrGX6mQMMXapOCN2
	jUh6dps43/xplLBqZUVcC8cG23388XU9cY2jOaIr1LpMUOIbjzUWOIK5
X-Gm-Gg: ATEYQzyIGlGVcYY1LV5n1iSPO9KiyZMvCDLHkXTeRSlXOb3Ws8nbJFv8pwd4fPXrBq7
	aAbmw7dJVBBkE81s22t5wAZ4wFAb/CQ7FWwTSwnwe2LUjUP5I8ufkt2UThioV20cqDGnkyN5C8u
	gt2sGhzmZ0NkMLbvKfkGhNfU7blyCz2zOxIlny9Vctj2UHd+dOgnV4Zz1EUsbv9+Nmhdzd3+E3n
	oXz3Cye6W1VZFNFBINPA8pEvAImd4p2HCvde/uicunBvffcIkQ/jWbc+155SvItbbS/jq0beapb
	dmPLEqGdWsuvc3U+nJCT9LPrjGTsMNa1VWwx0paYJvCDdJj0v+9Ya813DOf3aMhUHcU93MrrMuK
	Z4qmSIoxxMiQyCK7QS8fQlZUUZRAKvpIxY50hYhMVhhyBHkj+zNnanVwFw+Jdr9Jwdu79RyYn9W
	JuqxNHbaDxqAdJmK2MYTeayjwZ47iPW9MzWcUPXfouhvGdoQ6jhUveugc=
X-Received: by 2002:a05:6a21:700c:b0:366:14ac:e20a with SMTP id adf61e73a8af0-398591082a4mr5640721637.72.1772892538431;
        Sat, 07 Mar 2026 06:08:58 -0800 (PST)
Received: from toolbx ([103.103.35.10])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-829a48ddd18sm4747313b3a.56.2026.03.07.06.08.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 07 Mar 2026 06:08:58 -0800 (PST)
From: Dorjoy Chowdhury <dorjoychy111@gmail.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	gfs2@lists.linux.dev,
	linux-nfs@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	v9fs@lists.linux.dev,
	linux-kselftest@vger.kernel.org,
	viro@zeniv.linux.org.uk,
	brauner@kernel.org,
	jack@suse.cz,
	jlayton@kernel.org,
	chuck.lever@oracle.com,
	alex.aring@gmail.com,
	arnd@arndb.de,
	adilger@dilger.ca,
	mjguzik@gmail.com,
	smfrench@gmail.com,
	richard.henderson@linaro.org,
	mattst88@gmail.com,
	linmag7@gmail.com,
	tsbogend@alpha.franken.de,
	James.Bottomley@HansenPartnership.com,
	deller@gmx.de,
	davem@davemloft.net,
	andreas@gaisler.com,
	idryomov@gmail.com,
	amarkuze@redhat.com,
	slava@dubeyko.com,
	agruenba@redhat.com,
	trondmy@kernel.org,
	anna@kernel.org,
	sfrench@samba.org,
	pc@manguebit.org,
	ronniesahlberg@gmail.com,
	sprasad@microsoft.com,
	tom@talpey.com,
	bharathsm@microsoft.com,
	shuah@kernel.org,
	miklos@szeredi.hu,
	hansg@kernel.org
Subject: [PATCH v5 4/4] mips/fcntl.h: convert O_* flag macros from hex to octal
Date: Sat,  7 Mar 2026 20:06:46 +0600
Message-ID: <20260307140726.70219-5-dorjoychy111@gmail.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260307140726.70219-1-dorjoychy111@gmail.com>
References: <20260307140726.70219-1-dorjoychy111@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Following the convention in include/uapi/asm-generic/fcntl.h and other
architecture specific arch/*/include/uapi/asm/fcntl.h files.

Signed-off-by: Dorjoy Chowdhury <dorjoychy111@gmail.com>
---
 arch/mips/include/uapi/asm/fcntl.h | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/arch/mips/include/uapi/asm/fcntl.h b/arch/mips/include/uapi/asm/fcntl.h
index 0369a38e3d4f..6aa3f49df17e 100644
--- a/arch/mips/include/uapi/asm/fcntl.h
+++ b/arch/mips/include/uapi/asm/fcntl.h
@@ -11,15 +11,15 @@
 
 #include <asm/sgidefs.h>
 
-#define O_APPEND	0x0008
-#define O_DSYNC		0x0010	/* used to be O_SYNC, see below */
-#define O_NONBLOCK	0x0080
-#define O_CREAT		0x0100	/* not fcntl */
-#define O_TRUNC		0x0200	/* not fcntl */
-#define O_EXCL		0x0400	/* not fcntl */
-#define O_NOCTTY	0x0800	/* not fcntl */
-#define FASYNC		0x1000	/* fcntl, for BSD compatibility */
-#define O_LARGEFILE	0x2000	/* allow large file opens */
+#define O_APPEND	0000010
+#define O_DSYNC		0000020	/* used to be O_SYNC, see below */
+#define O_NONBLOCK	0000200
+#define O_CREAT		0000400	/* not fcntl */
+#define O_TRUNC		0001000	/* not fcntl */
+#define O_EXCL		0002000	/* not fcntl */
+#define O_NOCTTY	0004000	/* not fcntl */
+#define FASYNC		0010000	/* fcntl, for BSD compatibility */
+#define O_LARGEFILE	0020000	/* allow large file opens */
 /*
  * Before Linux 2.6.33 only O_DSYNC semantics were implemented, but using
  * the O_SYNC flag.  We continue to use the existing numerical value
@@ -33,9 +33,9 @@
  *
  * Note: __O_SYNC must never be used directly.
  */
-#define __O_SYNC	0x4000
+#define __O_SYNC	0040000
 #define O_SYNC		(__O_SYNC|O_DSYNC)
-#define O_DIRECT	0x8000	/* direct disk access hint */
+#define O_DIRECT	0100000	/* direct disk access hint */
 
 #define F_GETLK		14
 #define F_SETLK		6
-- 
2.53.0

