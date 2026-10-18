Received: from mail-wm1-f52.google.com (mail-wm1-f52.google.com [209.85.128.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83FF94B828F
	for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 14:15:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792332939; cv=none; b=iB69N2wKUHL1/LXnrpAxjC7J27Tj7QBT6w9nKPnrruPR0fsSyk/O2SDfIbMw6VEaIZDOZj9LKioUkImXlY79bqMRhPD6qSxb+z3kDP3k/+feyEnqqtAFqt1dQhEoAql4v3AI0dIH/gDnXCNjbWz4GLuOhfZ+HB+iDfIIfxroVC4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792332939; c=relaxed/simple;
	bh=Yaf6iuLHe8actk3BKFm9qaT5HChHLGZtnasGXPCiPMM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=CTjs+b61Ndca6sNB8KdrqHvEoCCIwF2oS+uAoPGtEjMqDp1rA1RS2zK6p0BNv6Wp6VXfVp21IRDt/K2oETWrzcSL9MTVRFi5SfcUAy/c5rfFpLSuWLl8w18K8fNzB0f0Vh+WXXrt3QTELDVq/d0s2viOZl92k4Wav4o40Dj7mB4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NexwS/Kq; arc=none smtp.client-ip=209.85.128.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NexwS/Kq"
Received: by mail-wm1-f52.google.com with SMTP id 5b1f17b1804b1-4a1b07c3c5fso14737175e9.1
        for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 07:15:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792332933; x=1792937733; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=KmiEv9QYBY76uU+OzcAGvNIgjVHfk6qce+e5ESrDlrA=;
        b=NexwS/KqA7PCwfO5MXw9vRrs1Fafcsr4g6sIjODrjsIATzDi6y2Kubmsm4s7ya1B0r
         cuRrb1KjFaSlsPIRQ302Q+rWkVSIhEQ8W8d4eF8EsXW2NfgI2ds/gpoki4pGMJzH4M+G
         Hne3WAlCHiT8csAXNe6xwkC+mdSoE/G+QegpSyhrfykgXHofy9Rt8vtqBq+nFG9v3Vpx
         wollY9md8LLeYq5JcqudXKOLChbXt0UuXVXnqepoAMrskhfco7w8mtQAwpnForQgD7a3
         otZ4vKYxVT0otQB8Xwc7og84AaIEbsbwNUfFf5ME4atgQ3kNt/TcSTSLaM1VD1/xBiwr
         7bTQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792332933; x=1792937733;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=KmiEv9QYBY76uU+OzcAGvNIgjVHfk6qce+e5ESrDlrA=;
        b=v+PCwhMDjjikxMaHjCHFAFUeO0I1nwYyrQoLHW4fare6rwyxMfhsrosXgz3d/haWWP
         956hspdNYOb5FYgCNbxA5u3JFQ5JpAyju7VALSwIpIO31UMSB88zaiO6SOcrEwRGTslS
         YtKKKNunyvAfjx44dCCt1A0DnICGNSJp02vIza0xF9L4OISV2ugLxV17I/XIsADZ6ro8
         Kt0YM0a2Q+VLSPJni7wO0CwBD/+q/cGBe6G8TmrbvVncJdvOmQJwqpehAHcEgt1iQK7T
         xgZyCBQf6H7SO30XD+BBE1GGtJr0xF90doZX1pKvc/rpIW9qsqiAN1lnctUXrQIh/Dtz
         0sZw==
X-Forwarded-Encrypted: i=1; AKwUvBxXy0YyN7pfF4uI8V2aU8oX1Ze93TXCOJoFChUPuNDH/f9MvYkzGX4EAA/AO4mCZWNRaadNNGQUIjI=@vger.kernel.org
X-Gm-Message-State: AFq9FYKm91oXNxiJu/qZW5MgRNmhNIcWi3ateG/Ye6O4BZKNRS9ql3Qa
	PHIhD8jw9vhinQnFteBBJVC+0cvgul5VNUXGSVZ2WnrFuj7isERmgOWo
X-Gm-Gg: AYBFou2kiiHWMis66ys//pmIh23DuuymrTAXuq9aSB8cs5xxk/TqkbK3+Khz73/qOSR
	90Om6ddR/qj678N1t4gKuXj86zQ3zFO4+dFxo0a4uW+ScEtELg1/9iIlPQPbq40uEWWjq9JupSR
	otJJPlHw13SYvm6d+Y4Pr3U8bUc0l+NmiS2ebQQ7/gAeu0auOlhHwERUb7zCYd5LQbQTTXzP5LG
	2RVda77aWdt+lUpzi78NtJWzzXXfv93u9T2426lwQnD/2VBqdnnTFGMB0r22p/EDitzhne0Lr4J
	Sg+xK27PjoQS3bV0V0O7uCWR6MuxHNCjJMMgVLsQ16v8MO2DxSmG4ovvCOzSalncnEZfPriv9yF
	rKk7ojz8i6cPe02vO3JPfRFZVKlOSc7FYcGq4xCYvvw9YBJTh6MtgBigTp6A2oCqymUK0T783fB
	yRBuI6qjMIkrDFDe9zE+6cwMrU0AkXgC2BhY+yzME0Ocga77AyvIdRg3b2T7PLlnt9jeVcQdIqK
	zrpr468t2p7DVpX5+Ngi5U=
X-Received: by 2002:a05:600c:1393:b0:4a1:d248:25b5 with SMTP id 5b1f17b1804b1-4a1d760e327mr106868805e9.24.1792332933237;
        Sun, 18 Oct 2026 07:15:33 -0700 (PDT)
Received: from LAPTOP-AVI.taile24b5.ts.net ([2a06:c701:4778:c500:d430:1e43:f3d6:7b9e])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48dfd4f8bd9sm17717587f8f.35.2026.10.18.07.15.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 18 Oct 2026 07:15:32 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Lance Shelton <lance.shelton@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Avi Weiss <thnkslprpt@gmail.com>
Subject: [PATCH] NFS: update ctime for atime-only UTIME_NOW requests
Date: Sun, 18 Oct 2026 17:15:28 +0300
Message-ID: <20261018141528.1985569-1-thnkslprpt@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When an NFS client holds a timestamp delegation, utimensat()
with atime set to UTIME_NOW and mtime set to UTIME_OMIT reaches
nfs_setattr() with ATTR_TIMES_SET but without ATTR_ATIME_SET.

There may be other paths that can reach here as well.

The delegated-atime fast path treats this as an implicit atime
update, clears ATTR_ATIME and returns success without updating
ctime.

Add check for ATTR_TIMES_SET along with ATTR_ATIME_SET (OR) so
explicit timestamp requests use the normal SETATTR path while
incidental atime updates can keep using the local shortcut.

Fixes: e12912d94137 ("NFSv4: Add support for delegated atime and mtime attributes")
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---
 fs/nfs/inode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3022454f7698..255d7369cb3c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -740,7 +740,7 @@ nfs_setattr(struct mnt_idmap *idmap, struct dentry *dentry,
 	} else if (nfs_have_delegated_atime(inode) &&
 		   attr->ia_valid & ATTR_ATIME &&
 		   !(attr->ia_valid & ATTR_MTIME)) {
-		if (!(attr->ia_valid & ATTR_ATIME_SET)) {
+		if (!(attr->ia_valid & (ATTR_ATIME_SET | ATTR_TIMES_SET))) {
 			nfs_update_delegated_atime(inode);
 			attr->ia_valid &= ~ATTR_ATIME;
 		}

base-commit: 32c52ec87d6245ee2d12ed5dd509e40062939b50
-- 
2.43.0

