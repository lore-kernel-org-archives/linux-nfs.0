Received: from mail-pj1-f42.google.com (mail-pj1-f42.google.com [209.85.216.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB5605921F9
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 18:36:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788892582; cv=none; b=rHwfc/a0BijSCy+C19iGXOdSNY0pLPcEJb13nnvDNwG3y3Ulu47kgRc/2U85UQBg3opmSy0lzqf/ZEBCnZ+cSnv424s+IEo9R4vSJGAB9EZ/b5f6ldkdK606vNAg3JyNuF7+EwekHPu21hXlwqXBOLniRA0e48GQpeuxkJB1f3o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788892582; c=relaxed/simple;
	bh=X2f6y+PvEknVvBPCY9H1j4smNvHqxddfu1MtYEZcdoc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=nYvGg/N7NNysdpH5azKqE4U8UzmAdpd+hm5Y+FI5qRmsCtFrpLAQVXXH/Z3u4T2TCvIv03T83MkL6YUs+DbdatJy2NZpFcwG60DaJ/2/y5RWSUq2ec9Sz8bFI4wPRlB9SJa9JK5LOchvCnqvxaj9jQ1chcCWUKng217fMvqyrdI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ion1NeRU; arc=none smtp.client-ip=209.85.216.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ion1NeRU"
Received: by mail-pj1-f42.google.com with SMTP id 98e67ed59e1d1-38a0c7e841fso6310894a91.2
        for <linux-nfs@vger.kernel.org>; Tue, 08 Sep 2026 11:36:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788892577; x=1789497377; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=J03j5Oa+4o/cWwbhDEZ20AHDlnfgmdHJGREi3xwk5Pc=;
        b=ion1NeRUByGlgwTonLcMQz6vMwbIsASqFqkBlW+dYuYQT0MIGILIY0gAEMqGU6FdOx
         yyjQHlWd3r/tUg9nljPkvCyY66FAhOk1Qo8xErd8cygTTV0fsVVJl0KoXeSVJ/sRcBxM
         PLUkLjer12lCr/5enP20fzgTjB1r7acFZBhe/EZRsBpypjtR/biA+K9InVrsIEpL0lBv
         DQF+gx4EsgXrmnsfD9JEib4lm+Md/W7TLdTq4hHPXJIqqZaLGRSyax6OeZH/pmti2IKl
         rVJRKpnSyByJ5fK30+RnBNrFA2q8kblG51I40m154hs43LruTrUxXlXeVSn/xWadv0j8
         44cg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788892577; x=1789497377;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=J03j5Oa+4o/cWwbhDEZ20AHDlnfgmdHJGREi3xwk5Pc=;
        b=ZQ4H9VKf8XYZgC+Nv7t8ChhkAKj36cNy2xQ2nGGl5kdvGwjiPB8UXzwURJTAKkZJ6U
         zGgSS6AlLUUeOxxbCvpLZwJ3SGtWxkEY4+yRm6Mg5RL0LLAYNAefrMuMYiAVSUAuNUXM
         zgsYpuBrna+TGPLv+DpV4COmjqq+TWF6D1CLVYnixfV26gQ2r+6cTd9YfDyT6ZNRacqk
         stGkVHoCZiYVThSmodyiJAeaFbYxeP/RpHj5+3rcFNBwxc6erT6pq7BYAuSf9SgxpgSb
         TLfasEwKqTLpg2jVnyEjmAMhT4rx5o1ngX5u0BcZs1C3gbfrtXaWfU3hdXCU3pDQFZpc
         V+ng==
X-Forwarded-Encrypted: i=1; AKwUvBwKWqS9CtQwlFbnxctKqsuz/NWrSOgWJ3TlVwzuT0zC4aTXpyRk4Cf+V0mtqp/vnpsvujjUkqWamoQ=@vger.kernel.org
X-Gm-Message-State: AFuF++lKuWawCdN/0mx/wxanGuP9FX3TV0AVKQ8rGgPMBqaH0r85JIr1
	dHXShSqkM2xqUSnHjJPq/vIenIUwk0ru9FRyTU/6il6KXTIV9HSMDJuCpF/5YuTJ
X-Gm-Gg: AYBFou1lMDxTOAoLlaxR3+pHSGhYFcvsvAxpV/rdpH+BZBbUv3XlyV8aOpuwdY7Dpkz
	6XB9ZeMTl8iZKSYD7FpLfNaZD+Aey0/tn06OUznf54jAjp0eFmxOnmHSKK1p/wd+mwyEHDtakFm
	TlTft/R+TxNMsaeyGZIJUWLxSLKORR+4FCA2mkM/vfbWbhyyzCCV6cgb9yKHBv/TxhU7IrXoh3k
	yI90esuqbHmbWBcC9KfS2f+c/6KzDoAHEcjNEogTsZ5wupeo2PFbsQWTFNSUelzQRUJrA8U1bwK
	bR7lggMoNaxef9b6w1yZXMCXlREd4ikHECCyvlt0YU3eeda/lPG8h8IaBfmbBFdjyqRry50Ziqg
	9v4oHyA0FQjq+6TUAHJl11BzZ2WXbZdkpuPpOEiLtci02f03D+gNopj1EPrJbl0iGxltYMRcg+P
	kVw6YcqCMQl9arveVvBCKdyiFZgZ/usEB3OQg/te+Ih3mOCmEfZWCPyESeOSd/G2YX
X-Received: by 2002:a17:90b:3943:b0:398:d8eb:cb2a with SMTP id 98e67ed59e1d1-39b26273e31mr49215313a91.23.1788892576922;
        Tue, 08 Sep 2026 11:36:16 -0700 (PDT)
Received: from G15-5520 ([103.246.195.244])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-33825669695sm14884906eec.3.2026.09.08.11.36.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 08 Sep 2026 11:36:16 -0700 (PDT)
From: Lalit Shankar Chowdhury <lalitshankarch@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org (open list:NFS, SUNRPC, AND LOCKD CLIENTS),
	linux-kernel@vger.kernel.org (open list)
Cc: Lalit Shankar Chowdhury <lalitshankarch@gmail.com>
Subject: [PATCH] NFS: replace sprintf() with snprintf() in nfs_root_setup
Date: Tue,  8 Sep 2026 18:34:44 +0000
Message-ID: <20260908183444.183687-1-lalitshankarch@gmail.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace sprintf() with snprintf() to perform bounds checking when
formatting.

Signed-off-by: Lalit Shankar Chowdhury <lalitshankarch@gmail.com>
---
 fs/nfs/nfsroot.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 432612d22437..d2c26d5378a6 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -144,7 +144,7 @@ static int __init nfs_root_setup(char *line)
 		size_t n = strlen(line) + sizeof(NFS_ROOT) - 1;
 		if (n >= sizeof(nfs_root_parms))
 			line[sizeof(nfs_root_parms) - sizeof(NFS_ROOT) - 2] = '\0';
-		sprintf(nfs_root_parms, NFS_ROOT, line);
+		snprintf(nfs_root_parms, sizeof(nfs_root_parms), NFS_ROOT, line);
 	}
 
 	/*
-- 
2.53.0

