Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E94F23AEF47
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 23:20:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787181658; cv=none; b=d7S3AzIb3xfgNVFLI8LzzYkuOffrv4mlmN48+oFR3lzbUgRcEcN/nz91OxhK5R7GsUq7BdWXoho6RWqP0bxDuXGs2n3V4Hnfvx+/pBiySQLN488pnn1ra2DBVKcnNcUWTPQVHc/Sa7XNDEInWN2RwyUhGzsVA+4AepQGLr8bt0A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787181658; c=relaxed/simple;
	bh=m77jxEjK4S2B1+jye9ifpeUzrXTHiQ7NiOrOnXuMj1I=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=X69O1BJP9YBPltVJqC+VcZp2netdqSMZlm1EMvNqnDUCttTctA86R8hx24yOW5taHTpmo6/OMC6oW20PfOPsfBPvLynSL32XZqi18OQy3y+WVVej3F1CRKhB4TdwH68+UkRMfWnvNow6VA+wTNoW8bkJNkb9HodaHJKBmnuWQP8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=g0Glx58i; arc=none smtp.client-ip=209.85.128.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="g0Glx58i"
Received: by mail-wm1-f45.google.com with SMTP id 5b1f17b1804b1-499b0eefa61so1958695e9.2
        for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 16:20:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787181655; x=1787786455; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=qQOc3Ov92x9cWdu0gZIX/NbsfGv8+wMlaXIMKoECqC4=;
        b=g0Glx58i3m1m8SwiQwpo4OeyvnvCgmfzFXLNzN5EriHughP+gW0aqrg8rvgLNa4Y5d
         sGtYUbSmSV4tTamVJcv4uyAdC31N3m8Q7CxhHB9YF9ySD9QW6sxyh0hSNhEPQw7JEVRU
         uK3tKSgYW32O9z27xpoVxlhUFK/dbpAJ29wz6PyCAJzNt6iM3aXeTkkeTbpMkTXUXA8S
         JM7+AKA1MOm5oP0g8wcFND8ntosBSxv0ndIOBbebb1tqHH4vda/ABtoyWJrbMGX13Gn2
         QtuBlo1EZKWsG3xnd+om96mr0coiHqK+TCM87EHpyHbF/mEtXGMpeRfhwkzPlr06v+TK
         BfeA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787181655; x=1787786455;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=qQOc3Ov92x9cWdu0gZIX/NbsfGv8+wMlaXIMKoECqC4=;
        b=TnYPW3yORt1ckSBQ0MLRsJr6f1t4PojMLkj5tns6Tza4fJUx/yz1V+iUcFwKRxy+bA
         ONcdq9A/fcLCq1nqLfhiN+pt20s0tuzAaUrSXo9NyqCt8/C7nP2Nr1eWbWBqF8jNWPND
         o55YFh9maHHngk4ytpLjZdEEF3mHeNtaLJuCCDj425d72Ah61Z3hynLporQICkuX8M+o
         Dj55/V4ZDM/LaD2Dvg7WHMmB4oERNorHGAuQ1dIVP0G+3s4TcQ+/amOlW1OUC00mhZEK
         ZIIsh9tXppB/JiMRfDJgfZ1CWNrrzwQ97nSEv+MRPnqXEAbfjYMYd2yhYtTHDJcv7Emk
         itwg==
X-Gm-Message-State: AOJu0YxERyWZzVfFNb1xmhNpWEE6x9gjy1ow1y5PnEKHnhXp0KF9uG1J
	q6C2ZCcwLFtjqgCy+UroWFk3A1enu3FCJn5M7meFLNMLC4cPCLR2gaN7uhizWw==
X-Gm-Gg: AR+sD13K60tZiAZX9DMkEIpY0vMr9N9/ipWwvwF3YP++mvmDbEmBv081rZIF5600yiW
	+VEp3twz/DL5eNlTe+/1QOviaS0EZKNoLz3Fm8n8nEGL9TCm1IfYB0p3++sEHjAcR+6PPy4fZ72
	k8zn/NtLWGLoj56P4025FuCc1nQQMrkBqZQRAPUaIDQuihawtsY8+1QZjCMD8acjUPProQD8Oqf
	qoYnfsAG/03HgNphrntae4Q3pWGGWw5AGPrAB/i/4hyC3aZt6XmuTjduyCZqJswGtHOIDdNthYj
	7ElfmWXtqfAfFFg2Xj/Qqj5CmksiHEpn/HS7TmidUSkqCRWLh4RnBJAu3UAgHY8g47Qb7iAzoiN
	65sO5mCt6eqhPAc2BXD4JKu6lkEXLBTjqbRt7l7B5L9E0yT8GGr/PVUaXkJb27lDwsT+KBSsKl4
	w4f0OkAcT45vPwzQ/auTBHtKv81I1g8LU38CFhNKORFSIj8RL8oTNdsOc4rYa+nZ/1b8O0Za5nB
	lI4/07J+sZimEWjGHWG2p+VkjUabnFXkQ==
X-Received: by 2002:a05:600c:37c6:b0:496:c379:b2a1 with SMTP id 5b1f17b1804b1-499aa1801c3mr164290795e9.2.1787181654963;
        Wed, 19 Aug 2026 16:20:54 -0700 (PDT)
Received: from x230 (gw1.ms-free.net. [185.243.124.10])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-499aa1947c6sm93193005e9.15.2026.08.19.16.20.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 19 Aug 2026 16:20:54 -0700 (PDT)
From: Petr Vorel <petr.vorel@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Petr Vorel <petr.vorel@gmail.com>,
	Steve Dickson <SteveD@RedHat.com>,
	Giulio Benetti <giulio.benetti@benettiengineering.com>,
	Julien Olivain <ju.o@free.fr>
Subject: [FTBFS,PATCH,nfs-utils 1/1] getport: Fix switch case on old compilers
Date: Thu, 20 Aug 2026 01:20:49 +0200
Message-ID: <20260819232049.438643-1-petr.vorel@gmail.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Buildroot distro compiles with fairly old compilers, which defaults to
old C11 standard (some of still used compilers don't even have newer
standard than C11). Workaround code which requires C23 with using { }.

This fixes error:

    getport.c:460:3: error: a label can only be part of a statement and a declaration is not a statement
       size_t path_len = len - offsetof(struct sockaddr_un, sun_path);
       ^~~~~~

Fixes: 1a6dcd74 ("Removed warnings in nfs_sockaddr2universal()")
Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
---
Steve, other option would be to use ';'. Not sure which one you prefer.

Found with Buildroot, which still uses:

$ aarch64-linux-gcc --version
aarch64-linux-gcc.br_real (Buildroot 2017.05) 6.3.0
Copyright (C) 2016 Free Software Foundation, Inc.

 support/nfs/getport.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 6bd2f713..18ea0777 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -456,9 +456,10 @@ char *nfs_sockaddr2universal(const struct sockaddr *sap)
 	int len = sizeof(struct sockaddr);
 
 	switch (sap->sa_family) {
-	case AF_LOCAL:
+	case AF_LOCAL: {
 		size_t path_len = len - offsetof(struct sockaddr_un, sun_path);
 		return strndup(sun->sun_path, path_len);
+	}
 	case AF_INET:
 		if (inet_ntop(AF_INET, (const void *)&sin->sin_addr.s_addr,
 					buf, (socklen_t)sizeof(buf)) == NULL)
-- 
2.53.0

