Received: from mail-pj1-f51.google.com (mail-pj1-f51.google.com [209.85.216.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF5AA3CD8CB
	for <linux-nfs@vger.kernel.org>; Fri, 20 Mar 2026 18:10:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774030249; cv=none; b=aK4HZCJzDz2kbmX35Q6mN+oNNT3MMzNzO3n2DJMkhQO2HIMA3qn+FSvbTQ2YMjajtOykBskuLnZU0WdBB9EmhUH4Z9iGVkvrd9P1llMBVVSGOWsjlFH+mAEs33a5c0EAjNso4x9hAyea2EDXfJsVZkcFBMhUiJcBaS3aVqFubGs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774030249; c=relaxed/simple;
	bh=su0qCKHnq3PtTnb31b3a9kZUX/DqBj3yiDnEaH4YW+w=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=WZROY7hnuSALQ4uAuS9tiI+HpHLc4KxYSwQ48zkrJg151qs5TBdji9FGMsiA/C0vjKSzPLVNwHoivVxTddPfEZI2qCVJBfeUbIofHzXNJQDvZ6AmFA5pVAVSG9Hue8Kg5p2BJsz3HHUFlIbSv9gqQC2nw2tjbTvp4J6t8Sh+mjI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=CkDWpgXf; arc=none smtp.client-ip=209.85.216.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CkDWpgXf"
Received: by mail-pj1-f51.google.com with SMTP id 98e67ed59e1d1-35b95a7444bso548937a91.1
        for <linux-nfs@vger.kernel.org>; Fri, 20 Mar 2026 11:10:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1774030245; x=1774635045; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=md5Ntsc0rRpCFPPT7+6W0Dr1q7JQYEVArLNrJ+0AKc8=;
        b=CkDWpgXfofYCcZUwyDcaJ5h7BJ9F9rPzEeN2VE2QiBsbQ+pkvNkvfPD+e6yHK+Pbyd
         ikwCe8KDI+cNEuEsEFrWwbS6pYsD16FkK00C+scdNXAJ0gIz65SNFVi+4bLRaEKxZQRq
         yBiRVagUQBdbvz0dtwBUITeRUeN1BASy66P9FTt/CJ+PHR2i8RIge8lElSJPOOPDR+ku
         M3kWanabV2SZdJOVBJyK8AWj/V59jGxPQ8DlakMIn1/IzMZ9vGt3iLKEFrfXTYdTq3Kh
         LCGg+X+d9tbDY/8JDHgsp7IjE80aS3x5jvRWyhP6R39B+ljYI8b5JfKfYAJlF/GewnVQ
         Kx1w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1774030245; x=1774635045;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=md5Ntsc0rRpCFPPT7+6W0Dr1q7JQYEVArLNrJ+0AKc8=;
        b=RSUarY+T1hYMI44Z7CWy7+LrhrdIwYTGxK0KsNP2DJyp+ZtZs77h8yYv2omc3zaXen
         2Cbj+bAte2UQCswWTzoqoNnWpGiqvODgTUnYCUfoo0fFXbCabO8gyCjs9ZCJhlLM5wwY
         WidG+z8m4ixoraWZEY/u+v6qiRElLP/k5hJxwYrZy7uFUga4VQxjY+/X/jioXqtlynj1
         4GPF2VFk0Fvnb9vK7ykezm1YogtblhYU4xC7m3OlkmMJp8lNDFv9+WA1sOnMFhg5E2CY
         s1skwZz4E3hLICSS8n0hjyRLOK8rOns5J+xf93vLrJdbx6UmBxgorYRxskPyt/tBSf5+
         S4HQ==
X-Forwarded-Encrypted: i=1; AJvYcCVd17cPL6jJ/T98jkDRkbo+bXNRNs3tdDF1JcAKHFfzzYGS4Q0I2/cHrHvyRWacdUFz+awKOFOLmE8=@vger.kernel.org
X-Gm-Message-State: AOJu0YzvjBGUoR0RNiG+nbgX0siKDIKMsDndFT0tywfjHT+wbKjwph+C
	TKQOfJ6Sxgs3rksgvYCjV4sz3XSAYmPnwhj3ybMxJYwjrNC0TA6nL9Vh
X-Gm-Gg: ATEYQzwaMRCHPgqrKHJwEBb4awMNT4XKRfpv2K29BME9qhbkwdC/gqbZl2vT250xrqS
	lO0Or2q7RVzyKop62NluEdteSR2wtFJm1jhRMTdxUolyvucPP/iUTlTefRweE29gxCJ/XqC+hTd
	GIBW5CPK/vH68pc/zBivwLfO650fdCysOBdI/UiIpVrvtdLJHtaGoWodEYVVYQYirLQq9Qe3VNM
	J9H4P1poYBdJwVZqhFxTSdVElQjM+IRwPg2WbAA8j47ekbYaNRDCjeTqOk3O+IDP1Ht1nNdKfB+
	s7hoTeo8mHWwmGS1FjtKa3HX+aDa0dkwQ7alYo4yqdpAtnnq7dAr7dMZc8ezlHlg6pqDaKMrSJC
	2mJstNwXnKgU7w+imKrq6KbKgOPgS7N71YOPFltatuXXe4pxUEhxjGKd80dHg5IQrPaqekkz+DS
	STViJV5DezkA8TRr3tMB/R18ymzpx+Mmme4oGpBNQxo6sLDWUlvYpRmtzgrT2HXcWJH8t+lxI=
X-Received: by 2002:a17:90b:3f8e:b0:35b:ccb2:9fad with SMTP id 98e67ed59e1d1-35bd2d1d572mr2544272a91.24.1774030244701;
        Fri, 20 Mar 2026 11:10:44 -0700 (PDT)
Received: from sean-All-Series.. (1-160-226-215.dynamic-ip.hinet.net. [1.160.226.215])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-35bd368837bsm959352a91.11.2026.03.20.11.10.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Mar 2026 11:10:44 -0700 (PDT)
From: Sean Chang <seanwascoding@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>,
	Chuck Lever <chuck.lever@oracle.com>,
	David Laight <david.laight.linux@gmail.com>,
	Anna Schumaker <anna@kernel.org>,
	Andy Shevchenko <andriy.shevchenko@intel.com>
Cc: netdev@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sean Chang <seanwascoding@gmail.com>
Subject: [PATCH v4 1/5] sunrpc: Fix dprintk type mismatch using do-while(0)
Date: Sat, 21 Mar 2026 02:09:51 +0800
Message-Id: <20260320180955.150696-2-seanwascoding@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20260320180955.150696-1-seanwascoding@gmail.com>
References: <20260320180955.150696-1-seanwascoding@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Following David Laight's suggestion, simplify the macro definitions by removing
the unnecessary 'fmt' argument and using no_printk(VA_ARGS) directly.

To resolve a Sparse warning (void vs int mismatch) when dfprintk is used in
conditional statements, wrap the non-debug definition in a do-while(0) block.
This ensures the macro always evaluates to a void expression.

Suggested-by: David Laight <david.laight.linux@gmail.com>
Signed-off-by: Sean Chang <seanwascoding@gmail.com>
---
 include/linux/sunrpc/debug.h | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index ab61bed2f7af..f6f2a106eeaf 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -38,8 +38,6 @@ extern unsigned int		nlm_debug;
 do {									\
 	ifdebug(fac)							\
 		__sunrpc_printk(fmt, ##__VA_ARGS__);			\
-	else								\
-		no_printk(fmt, ##__VA_ARGS__);				\
 } while (0)
 
 # define dfprintk_rcu(fac, fmt, ...)					\
@@ -48,15 +46,13 @@ do {									\
 		rcu_read_lock();					\
 		__sunrpc_printk(fmt, ##__VA_ARGS__);			\
 		rcu_read_unlock();					\
-	} else {							\
-		no_printk(fmt, ##__VA_ARGS__);				\
 	}								\
 } while (0)
 
 #else
 # define ifdebug(fac)		if (0)
-# define dfprintk(fac, fmt, ...)	no_printk(fmt, ##__VA_ARGS__)
-# define dfprintk_rcu(fac, fmt, ...)	no_printk(fmt, ##__VA_ARGS__)
+# define dfprintk(fac, ...)		no_printk(__VA_ARGS__)
+# define dfprintk_rcu(fac, ...)	no_printk(__VA_ARGS__)
 #endif
 
 /*
-- 
2.34.1

