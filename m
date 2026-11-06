Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793998090;
	b=xRPb85Lvmmw82zSnmdau/UVo1e9IJq6QW+Yoh16/tfwyd3OM2GW4ZMDUU7ZXsDJnuMFA
	 Nx0BXoOMRODQdLJMgOEu0WtvsJxp2wdaI36wHZ2nkX8GVTnjGwt/rojcNZQzuy7eT9eE3
	 62U08yLcg7UxyA3tvvgt6C7CT6B8+c4HwABoIjr/HD3KGdfh5lSqQzEob7uSNHt3IZmeU
	 znDzqRn8t7tm5GamOrDlehMdQnpgo7Zat2ALQmc428bOnIbQMX59qMJBitKpp3Kdli1aS
	 Wgy+cvK/kpqRgKvUfXV2sV0nMM6F/n5ZBFSAydF/9hJxxOj5YP2VhjKlKYrHwIdWJOA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793998090;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=jkwvppxqe7zoTjsnV9GYTl/ycm565RjM3YeZNrThr38=;
	b=DFuPj5u1usmrYK89jtCThYU3BjhI1xl8OJlNdkIU84ImN2NFtqPupCn9914xVS6XRZvH
	 UARR1u+paVj9L/FOpv9IuxNJimUIqI+WK/qdyDH2f2yNRV2+DvXsEs7Bhkbcd1q5bVTH1
	 ICpG7FEALrE1+X5oEhhBRgWP/uslcWHKZSg+Lm7c/zZ1BPu8AmuMzCYXIdQB5W6xHOqWf
	 Lh4jeO6HZ5V3AokVYX1GUxYWA+28VvyiLkIBn4draPwzBHpZaWCrpghYhVqNmjo8tTA9r
	 g2qEmOAe9rN63XfsfuMDEjYQYwnUAjiOAkTd9XEO//nXpLjW/qYzKT92V9yJyKh3e3Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Xhrqw/vZ";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B14F606A32F;
	Fri,  6 Nov 2026 20:48:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Xhrqw/vZ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 889931F008A1;
	Fri,  6 Nov 2026 20:48:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793998090;
	bh=jkwvppxqe7zoTjsnV9GYTl/ycm565RjM3YeZNrThr38=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Xhrqw/vZH6swBYMP4+CcZDg8v/SNfYXM8RZuBkrySXPEoVAieTaGm5NDRfcqbhcqo
	 jsDvMlcjaNQeZiWsm9p2RYrHnHJIhXnuLfapeg1QqyPmANnOrGvIwYTNQJ3CulASIW
	 E5NQLsZwGKZ/IivB3IYd32G5H2qoYpaJtRqahe1Hgw2xfU0N3janOLVwkgRU5iQg0F
	 0HuvuwA6Sxn3YYA+OEBOx3A5DLDalh/AhLgcwxr9Y2d4QqO1uWa4LdSVeQFl9zhfOn
	 cbnqbELiFB3DewOIMm7ypbN3oaE6GxN3rRpIvQc4zVJFCj5/zMbBmR5892Nd7OPLD9
	 0I1sOnsHJerWw==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 06 Nov 2026 15:48:04 -0500
Subject: [PATCH 1/3] NFS: don't let delegated c/mtime stamps go backward
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261106-delegts-nfs-v1-1-1d5c5e364a07@kernel.org>
References: <20261106-delegts-nfs-v1-0-1d5c5e364a07@kernel.org>
In-Reply-To: <20261106-delegts-nfs-v1-0-1d5c5e364a07@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Lance Shelton <lance.shelton@hammerspace.com>, 
 Olga Kornievskaia <okorniev@redhat.com>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2596; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=P5vqOyWJihfIDobbLARQx5RfTfD+T7X6K7i17/wiS4g=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq7j0HmBNLqo4j1APHEI+Hs9jtzSx66qrV2UWSv
 wZ9ZWCu3yuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCau49BwAKCRAADmhBGVaC
 FW1QEAComa0K7FslzCwxml+JHs4srkWyQ9CX4AzhiozWjDYVqqXl+m814Mh31OjZnXG4JwUtR0a
 IwHNYZI34xW3mz7A6UaiNcbSyRC0wzyrJYPlCYqOLpQK2DnLen1HZLm0I2GVQXU86orkYqEMuXl
 JWjBEQGUBY+ctRgt6NToVHtvxqghjI2AdYqfZEBwdf7W+183+E1U5ndVHhgne3993gF3vWyvIR4
 aM3fDfiGovRmESA2V8pHjkeXQLa+9ClQG6ApudB901uYoQPN5IysPKCuXgi89/lIRmgUe8Bc6CQ
 HqkNt7I1Ez6DBGOfxmCt3lRveVGV+nvuIU/k+8PoLS1Likz7qSjkbn8h/5M+XxGT3yLVffl5yKJ
 8X1HWS3wjutrbcWEur1O6ajJocx8Cdz+og8fgEim+54+/M6jlUVId7u84Z0lr5eASespLOfZwm+
 VrLQsff9YSzUPV4U3+A13XeyqIqMfZ+cstBrC6w8e7rqhdeAeFuCmAmpvvAgEZRxBkYhHKfFqF6
 LaucAqdfZ5xa+uMGYHcZNBNa0MC5Dws8XoTMcX48NvriUI0EOXPFhTvNAegRsKiuZA5QYCjev61
 K721UqNrzYp8wKB0diTsOy16h5XU/2c72weKNupeLxNPA8CGhHfzAGbYjl9NpRE0c271FJs/qFv
 mKGdzq1Nx/5Czag==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

With a timestamp delegation the client stamps c/mtime from its own
coarse clock. That can land before the server's fine-grained ctime the
client cached from the OPEN or SETATTR reply, e.g. on a WRITE right
after an exclusive create. The server then either rejects the times
(they don't pass dl_ctime) or can't apply the ctime, since
inode_set_ctime_deleg() never moves ctime backward. Either way the
c/mtime the client reported while holding the delegation changes
after DELEGRETURN; git t1092 over NFSv4.2 sees a stat-dirty file.

When a delegated stamp isn't after the cached ctime, use the cached
ctime + 1ns instead.

Fixes: e12912d94137 ("NFSv4: Add support for delegated atime and mtime attributes")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/inode.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e0a2e92952af..e990f353b7d0 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -629,6 +629,25 @@ nfs_fattr_fixup_delegated(struct inode *inode, struct nfs_fattr *fattr)
 	}
 }
 
+/*
+ * With delegated timestamps, the client's coarse clock can trail the
+ * server's fine-grained ctime cached from an OPEN or SETATTR reply. The
+ * server won't move ctime backward when the times are returned, so a
+ * new stamp must land after the cached ctime.
+ */
+static struct timespec64
+nfs_delegated_ctime_after(struct inode *inode, const struct timespec64 *old)
+{
+	struct timespec64 now = inode_get_ctime(inode);
+
+	if (timespec64_compare(&now, old) <= 0) {
+		now = *old;
+		timespec64_add_ns(&now, 1);
+		inode_set_ctime_to_ts(inode, now);
+	}
+	return now;
+}
+
 static void nfs_set_timestamps_to_ts(struct inode *inode, struct iattr *attr)
 {
 	unsigned int cache_flags = 0;
@@ -639,7 +658,8 @@ static void nfs_set_timestamps_to_ts(struct inode *inode, struct iattr *attr)
 		struct timespec64 now;
 		bool updated = false;
 
-		now = inode_set_ctime_current(inode);
+		inode_set_ctime_current(inode);
+		now = nfs_delegated_ctime_after(inode, &ctime);
 		if (!timespec64_equal(&now, &ctime))
 			updated = true;
 
@@ -665,7 +685,10 @@ static void nfs_update_atime(struct inode *inode)
 
 static void nfs_update_mtime(struct inode *inode)
 {
+	struct timespec64 ctime = inode_get_ctime(inode);
+
 	inode_update_time(inode, FS_UPD_CMTIME, 0);
+	inode_set_mtime_to_ts(inode, nfs_delegated_ctime_after(inode, &ctime));
 	NFS_I(inode)->cache_validity &=
 		~(NFS_INO_INVALID_CTIME | NFS_INO_INVALID_MTIME);
 }

-- 
2.56.0

