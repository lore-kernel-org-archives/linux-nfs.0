Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793998091;
	b=R4OiufZh2c0A7cVpRm2Y7mRhf+umke7sRoHCbIQvIlIQdQm4gl/R/h74D3eV5TAypX1W
	 Rz57tHi3QaSvBem04nv9p7yZ7D+I+ydqm/0IVajUSIKy7/32h3nIVtq0iSNopWCo9DnPR
	 JsBOzn050q1fJmULrZ2lfk2SyAIJUAS6ATIxzMQjNokyiAisbe7O+IeZVtBp2WBG6DfGq
	 mBVFzJ3YzWiL/vduBzuCLC2khSWgKrl1uLOl9dDCWo22t3JWogfGijcr4jntvL4ccuLV5
	 2ic1f/0BNTvlKPKH+HVtB1kf41VxVILz6rWa76Xh8jXTO5Mym4CmSR2Gn112hMtmXCg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793998091;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=ciquV3vPy68f5MnqmpQnI7ZaQ1xSUKf3tzr1etzBwoI=;
	b=1EZs4yZnsuodqfrwLi0ZVpScLog39P21ZyxZZxiUiWaiCkutPcLGaQDvy1O4raBdtbYz
	 7C6k+hsV9/M6al4IhvHYOn+80IVHIzx2V/FClCdMgEWwkz31zeR+4TrtCFQFFqFV1iJ8E
	 4DpfCjPFFzCH8edvNwLrOdj/rHtrHN6Bcwaswx011SITpRzJQWqdtP8IwBpxI92sq0pHk
	 68Gx4/lGU22SPVOp93A5WvDkGaytrnuZR5fMYZArnQyubxGGYlWjZ8YQXxyldJ27Qp2ay
	 ecsdoUbjpEgrmF2QtZXlOqG1FfhlzpqMC3DNEVnX3dyIyCdDRrrHh6foOwvZPna7bEw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=h4XTutrN;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5284B606A33A;
	Fri,  6 Nov 2026 20:48:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=h4XTutrN
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 60EFA1F0089F;
	Fri,  6 Nov 2026 20:48:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793998091;
	bh=ciquV3vPy68f5MnqmpQnI7ZaQ1xSUKf3tzr1etzBwoI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=h4XTutrN4+U6GG/rvtpgXm8olVsEIpkcPt4Hu3xmd2hyRDyq6pV4tl3x3l9BjkWOg
	 xYUhMavC4NAIox2wXlSnm4Xy/qsW9fO56LSWskQi2p64KnGv6VDSxyWJDe6hxZyFfO
	 jtACN2i/CvYsYH9clgEIBuK1zS90Gd1/ToQIIMt2jd4+mXz45JFOOoIsPXZwbYofcy
	 pPeGrP5FERX9WKj0M7ihHKNpTeKWet24HMPSJ0BEQ8gJLp4VcqzLRrUu1ia5SRHpiW
	 yAimeQxg9I40CpGu54xYyQClEeodNksmQj2I/iktl55T7Q9gu0u7Ow9gdHQoLscslL
	 +jlsKYvCexItA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 06 Nov 2026 15:48:05 -0500
Subject: [PATCH 2/3] NFS: stamp after the server's ctime when truncating
 under delegated times
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
Message-Id: <20261106-delegts-nfs-v1-2-1d5c5e364a07@kernel.org>
References: <20261106-delegts-nfs-v1-0-1d5c5e364a07@kernel.org>
In-Reply-To: <20261106-delegts-nfs-v1-0-1d5c5e364a07@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Lance Shelton <lance.shelton@hammerspace.com>, 
 Olga Kornievskaia <okorniev@redhat.com>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2080; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=hOI/cN37fyAVRxddCfmazyAvHiAKdfX1A3jB+g2tyCk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq7j0IAtyNdo5PQA92EOLvgFlpFPV5kYZD67Myj
 Sv7YZGeMyeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCau49CAAKCRAADmhBGVaC
 FQVAEACJdAZ8//i3GsPbnme5QPfPXeV+shnOEHcc1CCYqTAxjYlQU+8awdiq+q7bTPrTmXki5pb
 MBHS7F9n2GOgOknsAmoRjU7v3+DzKa3FyijtgbjQdPIRasSbFs4l8/rqzYEcgVInzvypXKHZes/
 NqD9pSXMWVKPvvXOxoWvSuHEk8kyY75hPOjAUSzgeFwyv2SXVe4mcnMckh+khbXcd/GyMmvZ2xK
 MGKbtZ99l8lDu0et8lfaTyjK++qB6HiOj9JuDrshJnYTIPHROH3wpJvtkUiKAF+SuWNgZRzgxCG
 uhDO0Dpy3fm6L4UDJi+wx3gMMsqsmWadSXrN+YmjFSG3vdqVHmOGl3E4POinVdLD5gpSIayyWKD
 TV1EQWoJ6xOAFlwSnieOqIqjQms3EDBsbZWEqQt5tJHfNAJmCECN0tkW21gGs41ETMi2FYvdd/m
 F6pfcr4gAoTkNl2E05s6uB/rZlQzq8QnNZI85pYWZS+YZY1/v5kF/QoRHcMYgyHK/QWNd/Rc4kJ
 UTpmECDNBQCyZiP+cwjQtEtiCBIeSNlvbelQGUedFcNHFg/OhzvyhvuMeA8rOItMtDw3e+tIIwa
 hvxvYdJEFYBErRDrqW2ro/+ywrrijn7SvWhxpuLVkcZVpN+9pUSDf/Eho5yjFOWDS/Qq127ChjO
 hTb5dKYg/5i+Lxw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A size-changing SETATTR always has the server stamp c/mtime
(__nfsd_setattr(), per RFC 5661 section 18.30.4). With delegated
timestamps the client discards the reply's ctime and stamps its own in
nfs_vmtruncate(), clamped only against its cached ctime. A coarse client
stamp can still land before the server's, which then won't move ctime
back when the holder returns its times, so ctime changes after
DELEGRETURN.

Raise the cached ctime to the reply's before nfs_vmtruncate() stamps, so
the delegated stamp lands after the server's.

Fixes: e12912d94137 ("NFSv4: Add support for delegated atime and mtime attributes")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/inode.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e990f353b7d0..8b86d93f8101 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -648,6 +648,21 @@ nfs_delegated_ctime_after(struct inode *inode, const struct timespec64 *old)
 	return now;
 }
 
+/*
+ * The server stamped c/mtime itself (e.g. for a size change). Raise the
+ * cached ctime to the server's so that the next delegated stamp lands
+ * after it.
+ */
+static void nfs_delegated_ctime_raise(struct inode *inode,
+				      const struct nfs_fattr *fattr)
+{
+	struct timespec64 ctime = inode_get_ctime(inode);
+
+	if ((fattr->valid & NFS_ATTR_FATTR_CTIME) &&
+	    timespec64_compare(&fattr->ctime, &ctime) > 0)
+		inode_set_ctime_to_ts(inode, fattr->ctime);
+}
+
 static void nfs_set_timestamps_to_ts(struct inode *inode, struct iattr *attr)
 {
 	unsigned int cache_flags = 0;
@@ -860,6 +875,8 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr,
 	if ((attr->ia_valid & ATTR_SIZE) != 0) {
 		if (!nfs_have_delegated_mtime(inode))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_MTIME);
+		else
+			nfs_delegated_ctime_raise(inode, fattr);
 		nfs_set_cache_invalid(inode, NFS_INO_INVALID_BLOCKS);
 		nfs_inc_stats(inode, NFSIOS_SETATTRTRUNC);
 		nfs_vmtruncate(inode, attr->ia_size);

-- 
2.56.0

