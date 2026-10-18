Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 501551419A4
	for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 18:31:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792348268; cv=none; b=Dme9iBgSLcMbo+2opV6mSMTFCZLvCn7umB2vLIodsiq/QyVxpjZGpxYxwWgXswtMNiSlOyKuFp/AhYNjfawgX9YXixdsM4gNOWO3IGQJBRJlzu8JJGyRs0gLfFYh4bSAMbVO6J7+1G3S1Jfnoa6axSMJIqa9CvrCGKki+JA2qr4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792348268; c=relaxed/simple;
	bh=Uj9+qHky+dE9izYYbvuHNTGILko5SLhWfIyvo0wld78=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Y8u1WcIlqTNsbIqsHGbRoZJFDx/FahwVdlrIstlmdH487rOUme34EUCNKLOh3ywGBehoKa09Jn6hCtLesEAWfV0Icd7JCGvMvKEkb73zaEkI5P+e0WPXUWMlx7DhPT/+UXQVn19VmKK9X0rSBjeh2ehcokl+boxov9VFOA6iB7Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=hK6NlHMC; arc=none smtp.client-ip=209.85.221.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hK6NlHMC"
Received: by mail-wr1-f51.google.com with SMTP id ffacd0b85a97d-48df54150dfso974226f8f.0
        for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 11:31:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792348264; x=1792953064; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=JcMP7Q1KNhaLlQR+4iLuiM4GDLeg5VcH7SeMyQePIo4=;
        b=hK6NlHMCIvy0uiRkex2m9R2EM/pYtRlUsao1LT4f6Mt1hiIWKgNv0+IrD5w5OWSxNQ
         ZK08ECJkQfquh7BofnzXmGNH6ciSQraaf+ZWEw1Trii4vNeKxssKVUYPTgp8s82QtgvX
         XVGB3RWthRvk2vyVeeZWWqCZFYvgpoj+I2aP0fGbU4GhKWW52DUoLMPnA/X73r6G5oay
         MxuUxEC05WgWIINUZGx/NsdlS9c6JaNgWcSTQq3UdMiiLK689e1BhAnGRWMiSnPJ749T
         7REIk44RYfP1ZQMziG1WHFt8Zpc+ANN3grUj2jO+Y33vxr0sjF+SLRc6zwSITmFbOngP
         Yw5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792348264; x=1792953064;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=JcMP7Q1KNhaLlQR+4iLuiM4GDLeg5VcH7SeMyQePIo4=;
        b=s/wqKnAOsklS51t4tCoGyLQJ1D32GnPS3we8pY8agOaDK7BtEiHooUdDwXO5YG3KEK
         0HY7u/DyL0Tc4ueb7jKBCDq0aiAVA6jqfFH1AgpmT8tpS9DvJQTSaj8zt9Br6Esh5PRY
         x4NBlU60alj0uaPMSORLXK0EG78doF38kkDPbHK8rX12vglqZrWs8hOI3z/cORoZOZ8f
         hy0ghv1WPTeFhDDk3qTUmu6vhkPoI9eh+Ae1YLhLarx6ojU9ykN/bDDZxw+1a6rY9hMK
         e2sBIqN9RYXdFiT6T8BfBbjAk9sq86gvR8388y06CrV5ai9OVuYnp1us+hhMwuCEnip5
         sGtA==
X-Forwarded-Encrypted: i=1; AKwUvByWj+IQ5PUhyx8Zwe6B73cnlu0xT6dPqtVzElZaPlKOVkec7uR6Q6QtrW20JWz9MPmQCOoqWCCRxA0=@vger.kernel.org
X-Gm-Message-State: AFq9FYJXBSYdmw1mTJu5w2kQcTsYwbFk5ozRZ1Y8FNqEs/U4Rgbnkeqi
	KFME/8+Ys/dr3pVlARqy5IJgsTyRt7zRuBK5xIll8hv/niYul7jn2Rru
X-Gm-Gg: AYBFou1lib3KpcmWxTokKtiFmPDhDCXDSWDekauGUdxP7envck6h9AqsdjXpQqRvpBX
	1xtLejWcgL9eR+3UBgz4f7M5cDruRR2ip3216ngichjbAwl6UZpT+KSd9DVavKNYTgyOSoXjZH4
	8YzYtbNIaqhLPBColI1UlYokOfV7IGYHDQI+QQSknTG88eTlk5wldhaZy3bo+qC6vfwSD6wG2Xn
	QBHY9OOLA+puhrmPkhrg6II715n0gaBpIjASbwNfrNuz3nKEbiBfTudejdbfWFJJWCGc7+IheMq
	xtY676SP+slIFUqSgsmzvyesTIJv8o1RWT4bZz4Gx6/lST40EzeDTShvrh5noKUbtNzFLtla85b
	RdAnyksOqGVX41wFm+jORuk2TQkTcGNrgexFkyWI6SV5E6PooP5yUJcOxtOJ5YdpDrxOCunFiwQ
	tx0OYgck7+qS0qi4zmB6WHcBrpIuknd5rMgki4GHQzOvGnF8Em33vGBOrluPqX+3cnAtZHTneV4
	E7uZQ0jVAKNCHu/86Y37T4=
X-Received: by 2002:a05:600d:4447:20b0:4a1:d483:559b with SMTP id 5b1f17b1804b1-4a1d7612bbdmr82057095e9.24.1792348264208;
        Sun, 18 Oct 2026 11:31:04 -0700 (PDT)
Received: from LAPTOP-AVI.taile24b5.ts.net ([2a06:c701:4778:c500:9bfa:b312:9d38:19b6])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4a1d85f92d9sm144701735e9.4.2026.10.18.11.31.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 18 Oct 2026 11:31:03 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Avi Weiss <thnkslprpt@gmail.com>
Subject: [PATCH] NFS: Fix inverted cross-directory rename check
Date: Sun, 18 Oct 2026 21:30:42 +0300
Message-ID: <20261018183042.2221243-1-thnkslprpt@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfs_rename_is_unsafe_cross_dir() returns false for cross-directory
renames, causing nfs_rename() to skip nfs_sync_inode() even when
filehandles may expire on rename. Same-directory renames may instead
trigger unnecessary synchronization.

Current condition directly contradicts the function name/comments.

Return false for same-directory renames so cross-directory renames
reach the existing filehandle-volatility check. Keep the conservative
fallback unchanged..

Fixes: dcd21b609d4ab ("NFS: Avoid flushing data while holding directory locks in nfs_rename()")
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 49394123bd09..aff6b9d45523 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2740,7 +2740,7 @@ static bool nfs_rename_is_unsafe_cross_dir(struct dentry *old_dentry,
 {
 	struct nfs_server *server = NFS_SB(old_dentry->d_sb);
 
-	if (old_dentry->d_parent != new_dentry->d_parent)
+	if (old_dentry->d_parent == new_dentry->d_parent)
 		return false;
 	if (server->fh_expire_type & NFS_FH_RENAME_UNSAFE)
 		return !(server->fh_expire_type & NFS_FH_NOEXPIRE_WITH_OPEN);

base-commit: 32c52ec87d6245ee2d12ed5dd509e40062939b50
-- 
2.43.0

