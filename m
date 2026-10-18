Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 489F3499F31
	for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 12:38:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792327131; cv=none; b=G1O/r4gcr8AT0TxBmzqkvOY46DcPlKlTk6Q3jFwYBOB0dA3Or60LGC3LW2fch6AafljcHT50JJiVJ60Aw9owSBN799MLrxQyaLnEuO5/ciSfBb6Dam/6eAFAaVY/c7IudeAqi6IFqqkVVdPzAlOKlo9eQ9OLJSXgzKx+LiI2M/c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792327131; c=relaxed/simple;
	bh=JV0s2Xv4Dlty4I6/E87zQbK2+zYAn6I2yr8xmOV1kT4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Ei814FnfNICogYdnDDCJD4J7iA2nYPNM2gW48nHmJ51XZfK1Gg/vIUsqqMJMYvZMWSRlMYelJg5zEYYYxRxXIt/mWwtJQaWtNui951MKayaP7eLLyMpZZkq47NVSfToSz53SkKFXhkGdKK+Cvjn3ilkd510NI8Sn4K7FlNYOdUI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Qg0Lwl40; arc=none smtp.client-ip=209.85.128.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Qg0Lwl40"
Received: by mail-wm1-f43.google.com with SMTP id 5b1f17b1804b1-4a021c809e3so11977555e9.0
        for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 05:38:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792327125; x=1792931925; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=uNqS6+7gVpfXiKwApglNgee+T7VedzIxHvUWv5uW3EY=;
        b=Qg0Lwl40L2DG31N+fbMu0cVdcEWCbFDcY1OArLjRaY4r3IXVPQhJTLSdw6shKK+26a
         HCHCYXLcXHPu7wkouNM0NkYNtFYDaXxL/OWvxRiraT14Ddz60ViX/ZKU5YRY0Y9Wo2uJ
         /vMrrcWTG7kBgMCduFUKkOvy3WB6BF3yZO8hZZ+307I6QY/Nzlh8nFzUpDahI1iVVwU0
         dWjKO2cfxgJmzL3o0prty7sOfcwMWlYNR3QQ9q0olxP3QqYEbqkS5BkaMZ+GLEwdCfvs
         UY3f0rheDeTdDseLdRLQSsM/C7NceLLv+/T+cf3AdgtchayPxamnfJOfi64iqLh2OPYC
         opeg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792327125; x=1792931925;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=uNqS6+7gVpfXiKwApglNgee+T7VedzIxHvUWv5uW3EY=;
        b=EWdGfCVcX5BfQGlVzf8VnflowxoJqocA/yv/I7vnSRQdl0K3DFSKVwP0aIMaRO6ZiB
         AoNTAWzY5DH5oB/SPP12JcjFWd3HQkeysxo+aa7itOnMgIA96Uz+Gog8eIqOcmZRPaoE
         Aa06dRwWdRTxM/Mivt8TSyS5fPkJeN5zB4fx2YjWt72vJMr9CdNmoSJIFARTP0irzOy5
         RO+2DFlQAdT9zxW9YKWrjGHvOuYE/q9Khqswh84PjMQywb/WM0Z/7qejNNS6WKQ0SUjY
         /6oJbQk/RChfLts/ReBgVC4sNydhprXK0aTwmoEPyKGa5DIvVvaMleODFRR1YQi/kvvH
         PjPg==
X-Forwarded-Encrypted: i=1; AKwUvBxCGS/pvhvojJWRDpbkup87FQQvwmP+/Tdxjh0Y2VcB1rH/rML1awnZcB7LlezxfnIux518/SmnRDY=@vger.kernel.org
X-Gm-Message-State: AFq9FYKLmtfXGpDB27eTj94p49dfawBlM49NrA6M7GHhId6NdCB971J8
	+kt2CDqko1DIS3W+/nzP9jJim9YVmcAvlujVGooi0Ol3qD9rhbHTalCG+nV160/C
X-Gm-Gg: AYBFou1Z8JvkuHiLK3mlYG3oJHg91niIuE0yI+BXsSdpEsYyQbCQiIaQR0rDshDHi6G
	V7JNePUKj7Axpjc8tI880n6AZiDw/SF1xDNzwrjgnb+vAAjPtY4BMddDS6dKRv2JUbu9XUFk2Qo
	BOgWCDxMiMAKzzIj6xaTGefL00021f0xchO3+0PXp1FdocGWL/suwelGvH6wgiu6mk5V2BP1oIi
	fUVnnQiCWLbqinDa5OKFvIGt7h4MTrDI5a8o3EKuA3yT/NiHIE2R9raRoIQtJiFGPV33g2ikn/O
	yr0566C7GJaASDJwPWi9akUeKA8uH4gIVAde645KAMyVjGOYTwqI3K6G4UWNWWVN3htCUiKTLxR
	e5s0/wmpUw/jnQcFIcha7Lp1/WX4N5Krl0BaOa9VGWSs9uac9bHnuxEQqpUlZ8QASoq7oo5M6cU
	dSdhi9ANWjd758FnE72NdjQnRuQ4v4tLOEUlCyt3DVfQ4ZujEnczKLMNfJ3fZJR8qvuGbvmrKRl
	/pcl2eqB4cJK+ohr8fNOJQN/Gw2Q7u2+g==
X-Received: by 2002:a05:600c:4684:b0:49c:cee0:e7c1 with SMTP id 5b1f17b1804b1-4a1d76001e9mr99341255e9.16.1792327124837;
        Sun, 18 Oct 2026 05:38:44 -0700 (PDT)
Received: from LAPTOP-AVI.taile24b5.ts.net ([2a06:c701:4778:c500:d430:1e43:f3d6:7b9e])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48dfd471a35sm14367798f8f.7.2026.10.18.05.38.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 18 Oct 2026 05:38:44 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Sagi Grimberg <sagi@grimberg.me>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Avi Weiss <thnkslprpt@gmail.com>
Subject: [PATCH] NFS: honor UTIME_NOW atime with explicit mtime
Date: Sun, 18 Oct 2026 15:38:41 +0300
Message-ID: <20261018123841.1855641-1-thnkslprpt@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When utimensat() requests UTIME_NOW for atime and an explicit mtime,
the VFS sets ATTR_ATIME but not ATTR_ATIME_SET (as it should). The
delegated explicit-mtime path calls nfs_set_timestamps_to_ts(), which
skips atime, but nfs_setattr() then clears ATTR_ATIME, allowing the
syscall to succeed without updating atime.

The delegated explicit-mtime path already updates ctime locally.
The VFS also supplies the requested atime value in ia_atime,
even when ATTR_ATIME_SET is absent.

Check ATTR_ATIME instead of ATTR_ATIME_SET to also apply the
UTIME_NOW atime value supplied by the VFS.

Fixes: aba41e90aade ("NFSv4.2: fix setattr caching of TIME_[MODIFY|ACCESS]_SET when timestamps are delegated")
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---
Reproduced on 7.0.0-38-generic with an NFSv4.2 wa delegation:
utimensat() returned success but left atime unchanged.

Tested the fix on 7.3.0-rc7+ also with a wa delegation. 
The same operation updated both atime and mtime correctly. 
A kprobe confirmed nfs_setattr() received flags including:
ATTR_ATIME, ATTR_MTIME, ATTR_CTIME, ATTR_MTIME_SET and 
ATTR_TIMES_SET; (0x10170) and returned 0.

 fs/nfs/inode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3022454f7698..4fa6c5547ab8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -644,7 +644,7 @@ static void nfs_set_timestamps_to_ts(struct inode *inode, struct iattr *attr)
 		inode_maybe_inc_iversion(inode, updated);
 		cache_flags |= NFS_INO_INVALID_CTIME | NFS_INO_INVALID_MTIME;
 	}
-	if (attr->ia_valid & ATTR_ATIME_SET) {
+	if (attr->ia_valid & ATTR_ATIME) {
 		inode_set_atime_to_ts(inode, attr->ia_atime);
 		cache_flags |= NFS_INO_INVALID_ATIME;
 	}

base-commit: 32c52ec87d6245ee2d12ed5dd509e40062939b50
-- 
2.43.0

