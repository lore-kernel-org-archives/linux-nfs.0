Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A2535364931
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 19:33:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786563240; cv=none; b=aZk53QBjvKX+6wbKqAb767vZOpXok1dmJ/RREmpy0iHAX6zx0Ml3d2E55pNnpHLPOiUc0ydCY3lymjync8JWCeiYbeytYiCAHX1nYPrmg9IqX8wts7T53EBCsrfrwmm+zNY7UyJngBNkSJNq1E800ED3nSqFcqfqMCGILRiASyk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786563240; c=relaxed/simple;
	bh=yElmTG1roafynoJRh1CuPN5CyHd9fl8iVdtIKxnjuMg=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=t7F4X+G0iog879pL/DX37URhyGRwMHi4b26MuK1ySFEc629fcmbkStmnMySTfMs0bwRoMwFvrYyQQLoWCuW5i0VyjWkNBM4SeqcPaZ+kAMm5kGUEJfatzhQ5WQQbBCzuy3GrmWvvMZp8d5WowDS/VWbhdAivRmyJ9JYi5AJv6kA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=crZ53tnZ; arc=none smtp.client-ip=209.85.128.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="crZ53tnZ"
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-49554ebb87dso12692775e9.3
        for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 12:33:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1786563237; x=1787168037; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=ttthw1cb3naGTiwU7qvaf/lxYP33hzvYE+/CcOc+3vQ=;
        b=crZ53tnZ8LDC9W53P+0W0Mt77t4VRlUOda5sRc3CyEfbqUADOnSYCcFjW42IH1AZ7S
         dqSVh30SaNICeeHD/eieY93sr/5VhVI4WDQ9dhizx3eQ9vqXWNC+tkM9M8hZ/ZnPt/vZ
         +js7xkhfRIh24A/bb9P24i/5eW4OoeOuUhF7kRmbECJ9Mc87DXWcxELUtND6PFE1ydCM
         GWtykzjVyyQO6cFlE5Yo1UNjwA3ckGIzwZFuKJ6YD7Fz1wIrGaIOvIgea9cuhxJ2VDcj
         cVFbLmKg03yhNebEBhGiGVUxpmPvKx2p//2XM83vVhT1NV82WRejdorTiIRQdIE0AOKn
         i1BQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786563237; x=1787168037;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ttthw1cb3naGTiwU7qvaf/lxYP33hzvYE+/CcOc+3vQ=;
        b=LXSflzMiukIUmQmludWqq1J9eiykrxpydwg2iaqTgOyPQtT72nMccawJ1rAvFg9csK
         MqNdF5bdHkSKuyJXzkB79BE0mJvwOiFFnvas1juq2SJJSql9yrhoyjW4qSYZF2OLdUYH
         3uoGWZRmbSPBH6IvySHOGU+9MFcQcv1MgcWq7CuWtF0HVprPh42nbG0g1NoIHtEt6GkO
         7ZVEMJEv63zKFN0oOEWNX+C39coLst44YIoFcBPs2VcwtDvDwaaClXaK9ZnktRQBkQ51
         WXYNSttzUwbDSJmIgogrRLeZlXBG1ywUZet6jfeOyu8CQHW8qKlTWC75xWNcDJkuUWQ9
         vLzg==
X-Forwarded-Encrypted: i=1; AHgh+RpSv9xQpLqUIbNfE0P9eogUd0mtEFwkGrZ3A0y23iBdQFQGc2RgYL5/owF0bFuyRq46+IkO5/r9TPg=@vger.kernel.org
X-Gm-Message-State: AOJu0Yy5lzREZXKyfx4Hr1zDiEAWbEZEX60xeRmO8xFDdpeZNOCNOtA4
	3UUFWfFyc4RARyZyYPXACSI+Zg4NwEdCjVewD3KSD9upZbvCucAYc+2R
X-Gm-Gg: AR+sD10+2TR9+C1s4SIgqM996UurBgIUHwAztg+rQqFmw8QUWFuiAkpQHRaBlfMsjmS
	jhEP63b1d7Z14UFezmOt/sb6v4SMNvFoaR0OVi3C01jlBZUzT37eBgOd5kOmeGxx8Ya106/YB2c
	Hr71psHSCz+TxhCKAW5c+yF9hzpqT8DWcCbis/42cI1w3FctAaANcDoXp1+Hr7CPRbwlPD9dGZz
	3yS44rmKPegEXuTuUfZmkPMz6TYYkijcZYlvLQuMl6B4hyRIFidNuFwDmyMlbhZv3k2nVJQ5PJA
	4yMvvFxGkGz0qaXNRLLYI9yEy2dBZOQKyPsSa75jTUcGlwtrWSpZgBEhywvpqxlznJcPWaqvOFk
	LLBdHU5fP5Ge3U5Dyw3Ou5+Ch2RWvUlrC3lQIOfTzSPBz4lkuDjI0Rwr5l7FwKDaWXei1JIBT05
	VYtrIMXA+K6HVdHe5Eoe2yZ60fLD+QW4moxphzGPoRj1CRkn8eSNQ0m6gId93vtsoxg4jj7wQbv
	yI7NAtqKb+KaVAlr0vJmq9yf8f/K80z4hqU1Gpt+3kVdA==
X-Received: by 2002:a05:600c:4f87:b0:499:8191:62c7 with SMTP id 5b1f17b1804b1-499821d7e83mr37705e9.18.1786563236569;
        Wed, 12 Aug 2026 12:33:56 -0700 (PDT)
Received: from snowdrop.snailnet.com (82-69-66-36.dsl.in-addr.zen.co.uk. [82.69.66.36])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-49982165351sm849785e9.10.2026.08.12.12.33.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 12 Aug 2026 12:33:56 -0700 (PDT)
From: David Laight <david.laight.linux@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Greg Banks <gnb@melbourne.sgi.com>
Cc: David Laight <david.laight.linux@gmail.com>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Andrew Morton <akpm@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>
Subject: [PATCH net-next] fs: nfsd: Fix buffer overflow in write_pool_threads()
Date: Wed, 12 Aug 2026 20:33:49 +0100
Message-Id: <20260812193349.13347-1-david.laight.linux@gmail.com>
X-Mailer: git-send-email 2.39.5
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

write_pool_threads() writes the number of threads in each pool into a
caller-supplied 'almost PAGE_SIZE' buffer.
If there are enough pools to overflow the buffer the code continues
writing beynd its end.

Fix the overflow check so that it actually works.

Fixes: eed2965af1bae "knfsd: allow admin to set nthreads per node"
Signed-off-by: David Laight <david.laight.linux@gmail.com>
---

I'm pretty sure this is 'root only' code.
So you'd have to try very hard to actually get the overflow.

 fs/nfsd/nfsctl.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 39e7012a60d8..b74048aa2402 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -483,8 +483,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 		 * file, sorry.  Report zero threads.
 		 */
 		mutex_unlock(&nfsd_mutex);
-		strcpy(buf, "0\n");
-		return strlen(buf);
+		return strscpy(buf, "0\n", SIMPLE_TRANSACTION_LIMIT);
 	}
 
 	nthreads = kzalloc_objs(int, npools);
@@ -523,13 +522,14 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 
 	mesg = buf;
 	size = SIMPLE_TRANSACTION_LIMIT;
-	for (i = 0; i < npools && size > 0; i++) {
-		snprintf(mesg, size, "%d%c", nthreads[i], (i == npools-1 ? '\n' : ' '));
-		len = strlen(mesg);
+	for (i = 0; i < npools; i++) {
+		len = scnprintf(mesg, size, "%d ", nthreads[i]);
 		size -= len;
 		mesg += len;
 	}
 	rv = mesg - buf;
+	if (rv != SIMPLE_TRANSACTION_LIMIT - 1)
+		msg[-1] = '\n';
 out_free:
 	kfree(nthreads);
 	mutex_unlock(&nfsd_mutex);
-- 
2.39.5

