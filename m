Received: from mail-wm1-f48.google.com (mail-wm1-f48.google.com [209.85.128.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 813E93921ED
	for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2026 08:24:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777364700; cv=none; b=C+JzM1LvdLjppsP2S+tQzy5+wFAuytnB7LlyzIJmTQK53saDphyFUQUDQqHoULJtz+5Psf0rHtj6tV9CVzl/gpx9oB9a0LU9xF9AFYI9ha6AJoA5gXlGwhMZvqurBZTErUuqNsN3vIv+YuNJrlzKwWTl3ZxGk1wqT+dkfhymhVc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777364700; c=relaxed/simple;
	bh=CQ3GaHA7NL7ewDN3CSbNEb9w0aVmEQz7PCK/5xpVBPs=;
	h=From:To:Subject:Date:Message-ID:MIME-Version; b=HGrMWj3zSgzw6krxidvblJISl7sGc7lIzS4ukZe+72b5XdN6LdfD14+ExW4Kq7WfP8Irqou2ygj4hYtF20Smmz7T4U/lTnTWgUVOGWnZOQR+Tu16QdQhvfoKpvnyRovj3uC+tMTQFZvtf2cLU8UXQNLBDqMGnYOMfFkFWTLgFD0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=grimberg.me; spf=pass smtp.mailfrom=gmail.com; arc=none smtp.client-ip=209.85.128.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=grimberg.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Received: by mail-wm1-f48.google.com with SMTP id 5b1f17b1804b1-488d2079582so131211405e9.2
        for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2026 01:24:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1777364697; x=1777969497;
        h=content-transfer-encoding:mime-version:reply-to:message-id:date
         :subject:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=i/SOIwk6JFY4kiwKYICkEYlTGSV7bIkJwlX50Zyd5eU=;
        b=C53dEVkraofd38DBC76woj5Sa5SB19dY8zA9FvwgnqzATST2XUGUznjOdYym+GFBmd
         ggmcKnw0sdXJvZuiR3GgJQmH/Ib+AucxICtDZmsRddjLwjDLeQQP35wDjCMPOqLk9GdZ
         w82DPSY+ADo9wyBivdxCuqnp1fuDX3FrJUfDUpdR5dDvplzFHsDaZX+ns2eWazfr2fh/
         CntaxgVrUf8B3B1MCTWCBm7jDIBc7afPEzN04L4mql4+9a2NqjY2OBeW0Sh5qUeO8iXz
         emWqf4mdZc4xqkVzTLzyqu0ALw34LuFW8M3pcToZpdOK+CGe+7PgQHt4h1sM+ue6JFZI
         vbnw==
X-Gm-Message-State: AOJu0Yw/jhrILcPNohRv+lXiqKkGBBlMwwDPbdyE053DvzsZAbmjRkMF
	UEI8SwvvmczlVJJ/FNPIVnp0/FMqE+CE8NI3eE381jppg3nQzsr+rfY7WofhqA==
X-Gm-Gg: AeBDiev6p2PAOMvdH/uGO9E8AzObf2YUkg4VPykGeHkWKqEUI3zZ7zHaT2ikbBcRam1
	G5Q3nE8s73DK3os1C6btZucOyqG6Y770FnJtCpVgXpWcCo9tdmtle86A0CmEtWvXxZkvdEzrGqs
	hg2ahLfOcOoSLYv70+WsmFwBnTYO+kT7sgP355rTeyvFVIb2lKEBpXyDgNjmUUsk2rqBQ6eluXW
	CeFqEQD+m0eMBKDOr0pqA5ppqfm8cJU1DvaUR60UvUE34G74Dgfa6usIdF4WRucUm3bXgIG9GI3
	i3f0U2qI1Q5uzIihh/pfrnUYYOJFlsCMwjXbDdWmKXhYv6ir1n+cxbCmfB1ZAp99ig4fACJiBv+
	pmAwF+k7FBNCE0as2wBYB49yI1Yp1MD+mT23b7ig66ip0DQksmmRANpeXLy3VH69lbMWUIeRiEA
	NOg0MTWOnLDc+PT8koFs/q0i88/XGI65PfOhGWEU3DhIzXSZmNanKXLyTj2zXT8ftP0XpOPBgxl
	mJSutKhYgk1Wrn8aNLHNl5i
X-Received: by 2002:a05:600c:3b1b:b0:48a:56de:d62a with SMTP id 5b1f17b1804b1-48a77afdb10mr32046075e9.11.1777364696692;
        Tue, 28 Apr 2026 01:24:56 -0700 (PDT)
Received: from vastdata-ubuntu2.vastdata.com (bzq-84-110-32-226.static-ip.bezeqint.net. [84.110.32.226])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-48a775eb91dsm13394375e9.20.2026.04.28.01.24.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 28 Apr 2026 01:24:56 -0700 (PDT)
From: Sagi Grimberg <sagi@grimberg.me>
To: linux-nfs@vger.kernel.org,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH rfc] NFSv4: Keep delegation post REMOVE in case server supports preserved-unliked
Date: Tue, 28 Apr 2026 11:24:54 +0300
Message-ID: <20260428082454.26045-1-sagi@grimberg.me>
X-Mailer: git-send-email 2.43.0
Reply-To: sagi@grimberg.me
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

If the server returns NFS4_OPEN_RESULT_PRESERVE_UNLINKED, it means that
the file handle is kept alive for as long as the file is opened (or its
delegation is held). Hence, we can skip re-opening the file and returning
the delegation in this case.

Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
---
 fs/nfs/nfs4proc.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 91bcf67bd743..129424eacf99 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4921,10 +4921,17 @@ static int nfs4_proc_remove(struct inode *dir, struct dentry *dentry)
 	int err;
 
 	if (inode) {
-		if (inode->i_nlink == 1)
-			nfs4_inode_return_delegation(inode);
-		else
+		/*
+		 * nlink > 1 or server supports NFS_INO_PRESERVE_UNLINKED
+		 * the inode is not going away. we're promised to keep the
+		 * inode alive past REMOVE for as long as any client reference
+		 * remains. So we can keep the delegation around.
+		 */
+		if (inode->i_nlink > 1 ||
+		    test_bit(NFS_INO_PRESERVE_UNLINKED, &NFS_I(inode)->flags))
 			nfs4_inode_make_writeable(inode);
+		else
+			nfs4_inode_return_delegation(inode);
 	}
 	do {
 		err = _nfs4_proc_remove(dir, &dentry->d_name, NF4REG);
-- 
2.43.0

