Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794257094;
	b=AikRLYWm05B72nEIR50K0JGqzz12VoEBKt85UVsGm5J5dakXH+2nn/lpvJPm+6KPLzDq
	 5ivnWqVO/i48CmAC/bfOyZY4q6OBCRL8nnNXmwZO5/yKVi61pqKARNH4EEZXB23bdu2QS
	 gJ8u1L2Rra/LY4IBTOoVND/ZTPATi68FK8eh6fqPbKX0exSiy1tk6j/N8pbEQFo2iHYmo
	 KLRfDWf7rXbre+gDpttSQgw4GefmH7j4oys2VnvpJ8NjImw9t4nAXTt1ZSPUVWnCn+DhJ
	 Sj0hkqFC+uXGHKl6YQVEpWBZcHC8w16OSs4g7Rv4kF11g3YxGGd1cFeqiUGGiEmstDQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794257094;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=wg3N0zeCU+V87W+DhVAiPtVIVV/pYPZTF3215VLc+s4=;
	b=qT5IhSfdTCML4wi0Ylou6q/v7c/K6opxhcfcQ5lkIY3eSjfQwKe2i1CKMSsvW3ouRtFN
	 920YHk0B7mCEhuI2/Ma96lagUPvIFIGhKAb/IvPhy4nEyPLUFYIj1Vl4ZMDHU5rcQV9FS
	 W7YG+vlaReduPN3zGaeRpxvaBau7kAe0GKWu2nnwZUmp2taH9vB/KsXbpvvlgSlXrq+XE
	 C4y2cRz1aKvIpqG8mHhk+HUwzc+lBQGxbZhMsqSytT95mrgziGq+6mIo9lW2UCKWRB++C
	 Vm3gmiZOTYCuPAq2F2BLosScU2GPnUhMJSLM5xWAzGRqv4OfghtW0Dn3L5Z7CztvKNw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XoHtTmRL;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E455D606A331;
	Mon,  9 Nov 2026 20:44:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XoHtTmRL
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1D6931F008A3;
	Mon,  9 Nov 2026 20:44:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794257093;
	bh=wg3N0zeCU+V87W+DhVAiPtVIVV/pYPZTF3215VLc+s4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XoHtTmRLHgVdiYjcxOxjlSkkFUd/FtDJPlYIXUcHtgPg40sZQg+ai2KLHjfS+HOYp
	 09XtAvC4nBLhSky06yhv9SVSqL94MrMKpy0pO/Ccbgkf4aBvgx7Kc1M8mt9k64PmM4
	 /8+XtXVZGSrGkZnnFLS167d4fKug1ear4srGKwEpuqQ/QehBRA9WFZgK0h1YgonAAi
	 02qz6kuApOLY2l3xxGNtWfjpFHiy59aRimbLvZCeHUapzIINrDjhJAw9zQ8wZh2rmr
	 upyJY4McJQhUGsjOCKmCR1vERgdPSd6qmzBYYeJoXWQpXBgWMLJlfj8FzfhSgqG2Kz
	 KkuDubC+xsOqg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 09 Nov 2026 15:44:47 -0500
Subject: [PATCH v2 1/3] NFS: don't let delegated c/mtime stamps go backward
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
Message-Id: <20261109-delegts-nfs-v2-1-9d1e926cc3d5@kernel.org>
References: <20261109-delegts-nfs-v2-0-9d1e926cc3d5@kernel.org>
In-Reply-To: <20261109-delegts-nfs-v2-0-9d1e926cc3d5@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Lance Shelton <lance.shelton@hammerspace.com>, 
 Olga Kornievskaia <okorniev@redhat.com>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3172; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=/i+WgRkUTNLoT+wZXDiWG93r/fsgNbR+dFkibZFuirs=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8jDDiVYldjueX0OrVuKTDBFgjmWyCDfaZE83J
 2HosYwTPyOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIwwwAKCRAADmhBGVaC
 FZRIEACCPS6FuiAmKDRj+am+Ge8Lbyhg0lzWzZwAq0N60XemXTowRN2l08BjLOZV5ERwJ/uiufx
 RhfS+ANphcgSlTeAMYSzhhsFD8GWf1fD2zfN1HhkL5BBeEzCyOwdCawMBwFBJA/eyrOWqCHoBch
 0OGjpg0GDf/PU6WbfPBPyG1cyNvA5S4GCUW3DdV1eJPYF51tl+EwblQkO37+CJzuYEM0hoLkyD7
 XhPdP3Nd36K+VCSVvDeZ9LDl13scPpcZA5ExAHKL3i+y4VAHIQ5DUiZ8CGThJs4BbsA9ehpoxND
 L8/p4SRcbdtgM8MVderZhOTsoR9znBKNSTKduXPzeNCsQanChoqG8S9C5goYRu9WVfPF5agaApa
 SHHaRaasaKeBQXYN6RdZg5vtXnl7IY5l9F/tWE8YPCZtRVE5djArzbCmRwKv9MYdjF/Ep8H9MsX
 sugsT+m6033nj35gR3bkfLF3bQc9TM0m2uM0y6h16LAI5QvLRxZU1qmn474waqZISVHVxRCX5NY
 8Y8AQQpxPXtbHKROLZPWB551fIwdx9kmOTN/CgscpWfWRtddnNRjVzDSwnSqAaPSzRkebCiwqbX
 GwcPnFzvnpMT8rNZ23yF7T75mB4LzF8+w5LMJOugOpVQhDmyQe+val6bQ3FIe1qBmwR25kENYhb
 zcB/OAQDYjSxImQ==
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
ctime + 1ns instead. Compute the stamp before storing it, so lockless
readers (getattr, CB_GETATTR) never see the trailing coarse time.

Fixes: e12912d94137 ("NFSv4: Add support for delegated atime and mtime attributes")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/inode.c | 40 ++++++++++++++++++++++++++--------------
 1 file changed, 26 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 9839087cf373..98d8a34fab9d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -629,25 +629,33 @@ nfs_fattr_fixup_delegated(struct inode *inode, struct nfs_fattr *fattr)
 	}
 }
 
+/*
+ * With delegated timestamps, the client's coarse clock can trail the
+ * server's fine-grained ctime cached from an OPEN or SETATTR reply. The
+ * server won't move ctime backward when the times are returned, so a
+ * new stamp must land after the cached ctime.
+ */
+static struct timespec64 nfs_delegated_stamp(struct inode *inode)
+{
+	struct timespec64 ctime = inode_get_ctime(inode);
+	struct timespec64 now = current_time(inode);
+
+	if (timespec64_compare(&now, &ctime) <= 0) {
+		now = ctime;
+		timespec64_add_ns(&now, 1);
+	}
+	return now;
+}
+
 static void nfs_set_timestamps_to_ts(struct inode *inode, struct iattr *attr)
 {
 	unsigned int cache_flags = 0;
 
 	if (attr->ia_valid & ATTR_MTIME_SET) {
-		struct timespec64 ctime = inode_get_ctime(inode);
-		struct timespec64 mtime = inode_get_mtime(inode);
-		struct timespec64 now;
-		bool updated = false;
-
-		now = inode_set_ctime_current(inode);
-		if (!timespec64_equal(&now, &ctime))
-			updated = true;
-
+		/* The stamp is always after the old ctime */
+		inode_set_ctime_to_ts(inode, nfs_delegated_stamp(inode));
 		inode_set_mtime_to_ts(inode, attr->ia_mtime);
-		if (!timespec64_equal(&now, &mtime))
-			updated = true;
-
-		inode_maybe_inc_iversion(inode, updated);
+		inode_maybe_inc_iversion(inode, true);
 		cache_flags |= NFS_INO_INVALID_CTIME | NFS_INO_INVALID_MTIME;
 	}
 	if (attr->ia_valid & ATTR_ATIME) {
@@ -665,7 +673,11 @@ static void nfs_update_atime(struct inode *inode)
 
 static void nfs_update_mtime(struct inode *inode)
 {
-	inode_update_time(inode, FS_UPD_CMTIME, 0);
+	struct timespec64 now = nfs_delegated_stamp(inode);
+
+	/* Not inode_update_time(): lockless readers would see its stamp */
+	inode_set_ctime_to_ts(inode, now);
+	inode_set_mtime_to_ts(inode, now);
 	NFS_I(inode)->cache_validity &=
 		~(NFS_INO_INVALID_CTIME | NFS_INO_INVALID_MTIME);
 }

-- 
2.56.0

