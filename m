Received: from mail-dy1-f193.google.com (mail-dy1-f193.google.com [74.125.82.193])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A04D28686
	for <linux-nfs@vger.kernel.org>; Tue,  9 Jun 2026 02:56:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.82.193
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780973771; cv=none; b=MA3ZHwYsBtqOaUbTYGtb2M1DXzkP01spWdezHAUffF2KFUk6FoxUNYFkA1bFCqQPjaLZbEglLxPhStpORo8gLtf36dYIJOG+vU4eq6CtzCLSHDR8pjbVgrScwAIKVQzP6hs5yIkCtQuzwkLLKoAQ+FZBGMW0UQYQ7O4y+KIqFKA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780973771; c=relaxed/simple;
	bh=DcGeipjJiKu3tJd2RGvGXKQ/sICd9xNA1Hy0bh4Xc30=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=nzO+GTZpck/Bc8f+STk5ejMEcPD7ud9WXTGwlubwUAZzWbkPFWr2CMsl2DBGzD/Yf5ZZGd6SHWnj7AK6gd2glhYpIAXxDCiHCr6fCGSIvxsHhuhwVF2tmT47qCAj8m0GRxu2yd7MvDfW58HUHZEPimMnX2FLXfzjXSLx2bUoBcI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=la8Spaiq; arc=none smtp.client-ip=74.125.82.193
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="la8Spaiq"
Received: by mail-dy1-f193.google.com with SMTP id 5a478bee46e88-3074adb8fcaso8480115eec.0
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jun 2026 19:56:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1780973769; x=1781578569; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=L3e7Rk4ntS8FSexXO00TxmUjl6TuxY3V3wBlljC1diM=;
        b=la8SpaiqPFbJtUHZm1oJI7G10A/95d+NUDmOsp9n88fidJI6vU85k0aKXnmtwKFG5U
         hH8wssxz9l5iCgELQglqQap76orR10jYhKrsqym2WC59fMEi37mlUtumEkSppzOysc6X
         o1sTZlUu5xnQdQQESP55lgMlCiJ7lAMjHxkso6yUTOPj85i7z2vrW3oS8VaQzQb7g1HT
         GGaXVJyVQ0pN8/rN1NVvgAPkihZ+glHnD+9P2xqm0Ch35I9n/kgYGkUcHUSc5RNOYJkv
         hAaDZJDPI69pUx2Y7U56i5L5Rx3gxR4LdC5MWt0Ys825gxC5RxB+DgKqhMXEHQvzCOnw
         2ciQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1780973769; x=1781578569;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=L3e7Rk4ntS8FSexXO00TxmUjl6TuxY3V3wBlljC1diM=;
        b=PY5jM7ujmNfQQHKKmA8EzCQIZA7Aomt24024wsTsTDiTWkm09xSnmfYvtKPKBZSOcU
         DKoTjAzvzBzBDW8rGxCs+geC9ZWmwMkxIG6bhxRwusx6GF25+8Ui2Y/B054nbAcyLDz6
         NRXWIYPDf1+hK0vz4kfZUoVxGiIvJPo6BeGT39+zBkPTzXVlCS30ovZJp7+OdGXyUu+E
         KOXCGFugwNRH2BrFicXf0oI7bxZ/eFAViN6GFJbbtChQ2fiR0nawQvshjwsOyBFuluvu
         3fAwmO6aDaTt/GdNsE5QyOwzelDLv+B8ge+ef6ADqzK0fhgwoaVzzCfiab8pgydlEBeI
         ntCA==
X-Gm-Message-State: AOJu0YzSRgR4DIxYmYOZ8bnS7ZxENGm7NfUZx1W1F0/FXbGcXtF4iPzJ
	35Q4nngnP8ejZoUafOfBuQbx15zc3QdJxn+TOKDpmZKsjQuFU2tsrEka6OARh+XE
X-Gm-Gg: Acq92OE+Mk1uWaerfxByJX0FcVshGxASbkwHiLmKpDN32Fm6gK5/YSfeR68pSykvboH
	MsAKtcbGsN+Pabv+3IFolZMnSnPI01uLpChQYfkD3diimY8J1rFQAiNSdPbZgK8iRX49876bOEa
	JjFisOxibaLJdspxOPbMp8s9BsW41FhC4yN9rZv947xn2gM/VWjTcHAOd9HZIL1BpDLT7c6mXpV
	q6XzcKEMPcjtfOfDQ6wa/if0FG2NxvTxetgckGc8LyFkWJRyHRAmOsFN07/1ku19KMUXbMLub3s
	WSEczPUjOO6wL3tM5HsE0IfzSUTQhRuuzrigkLLd/osbyprnmtZqe9gk5cACr//eE/Kec9pbTCS
	FQcf0MV1hh2UeV8rAyhJn/zGaAfQpxW2K2Z55yPElIrEwCP6tERh30MV7Y0Zst55sF0wRJZ0+Ml
	r7GiUmudsRmpjAnKP3n8nsnYdbtPMb9cu6tGC1wuCdp/lncqrAqkyGO093TSvGd5uV8oucn5q6a
	G9iQsT6IFUUQFSQAkTV5emLjZYwgR1/RVG5FLT7b29ARGbv+Xm7okt7nSPIB9E765exKaVfkxLU
	GL1t6Q0NhV2L2ive9vIQfz3dMcz9
X-Received: by 2002:a05:7300:730a:b0:307:2e1c:17f1 with SMTP id 5a478bee46e88-3077b1f6abcmr10582487eec.25.1780973769064;
        Mon, 08 Jun 2026 19:56:09 -0700 (PDT)
Received: from ethan-latitude5420.. (host-127-24.cafrjco.fresno.ca.us.clients.pavlovmedia.net. [68.180.127.24])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-3074db85f60sm24230095eec.8.2026.06.08.19.56.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 08 Jun 2026 19:56:08 -0700 (PDT)
From: Ethan Nelson-Moore <enelsonmoore@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Ethan Nelson-Moore <enelsonmoore@gmail.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Subject: [PATCH] NFS: correct CONFIG_NFS_V4 macro name in #endif comment
Date: Mon,  8 Jun 2026 19:56:04 -0700
Message-ID: <20260609025604.14156-1-enelsonmoore@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A comment in fs/nfs/dir.c incorrectly refers to CONFIG_NFSV4 instead of
CONFIG_NFS_V4. Correct it.

Discovered while searching for CONFIG_* symbols referenced in code but
not defined in any Kconfig file.

Signed-off-by: Ethan Nelson-Moore <enelsonmoore@gmail.com>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e9ce1883288c..9381563c0a2a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2299,7 +2299,7 @@ nfs4_lookup_revalidate(struct inode *dir, const struct qstr *name,
 	return nfs_do_lookup_revalidate(dir, name, dentry, flags);
 }
 
-#endif /* CONFIG_NFSV4 */
+#endif /* CONFIG_NFS_V4 */
 
 int nfs_atomic_open_v23(struct inode *dir, struct dentry *dentry,
 			struct file *file, unsigned int open_flags,
-- 
2.43.0

