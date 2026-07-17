Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 537201898FB
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 00:12:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784247159; cv=none; b=X0aMKDZ73AeEDPzjWpWNOCJdS8WC5VUOiJRGteo60df/18WN4XsWN20uBQXanPLJM4tsQK5wjR7Okxxh2FPdMGf7Nu02mrjM3FeW4wXs5ddJy43wBIfqkq/xa2N6OLe8uiDaQxmIHBkp5rcYvsMeuiyjy8VS7kFYgESV+l2sky8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784247159; c=relaxed/simple;
	bh=EQtEWAmAmWBo78sjn/qRfVKp7JBS1ZjzE0rcJGvKCFA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=asO/BO23MBRMpEhlmXvCV7pjBkH9KVuBs16pvx54+UboK9F7q8QxAlPwy9c6M7Bric3Jr7hlSs/Ez7QBvgCESqh0yEwuKuCoNhg/UXCvUVwwaWMgbdvetxszp2XWPxPwp6R58VYVCyoMasjE075rs7QH9TTn5HICLLPNubNEE4U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Qps1eZ0J; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Qps1eZ0J"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B5BDE1F00A3D;
	Fri, 17 Jul 2026 00:12:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784247158;
	bh=akLRc4UqQAjTlTLYAUckF7JDb/CjtI4G+CUGpKyEIg0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Qps1eZ0Jz714ZCPOyJms+CVMQBPVLGOYOIFBcUhO7C9BRbREKiEWZOc2uMH7YjC6a
	 gTJ0/gE5CCBk7HW3a8UijcjpImWfskiv/l7QUfPDcn8gJaEQgrkZro2/oU7/mh3r4W
	 r566kaEn9TYutBkZQXnl9Jhly71ReKfIkowRKTNbUcOx7MhPW7o3M3TJD/swecaO3U
	 flUBNFdliEufNcpAgQDuQ9e6ixp0pYhEnLS1fZOrNtoVu2wlVYlygLRFsb0JPGuGKB
	 mxx0j5SShBo2s9KKRssg2/Wx5cX34jTo1gLBiHznStWEBl58uhaK7F2D5+4yVdHrDb
	 LrIjAA6JYNdzA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/5] NFSD: Document reply_cache_stats ABI
Date: Thu, 16 Jul 2026 20:12:32 -0400
Message-ID: <20260717001232.438792-6-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260717001232.438792-1-cel@kernel.org>
References: <20260717001232.438792-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

/proc/fs/nfsd/reply_cache_stats has been present since v3.10 but
has no entry in Documentation/ABI/. Add one under testing/ that
documents the current field set, types, and parsing expectations.

This establishes a contract that parsers should match on field
name rather than line position, allowing fields to be added or
removed across kernel versions without breaking well-written
consumers.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 .../ABI/testing/procfs-nfsd-reply_cache_stats | 38 +++++++++++++++++++
 1 file changed, 38 insertions(+)
 create mode 100644 Documentation/ABI/testing/procfs-nfsd-reply_cache_stats

diff --git a/Documentation/ABI/testing/procfs-nfsd-reply_cache_stats b/Documentation/ABI/testing/procfs-nfsd-reply_cache_stats
new file mode 100644
index 000000000000..57ed5f8e6597
--- /dev/null
+++ b/Documentation/ABI/testing/procfs-nfsd-reply_cache_stats
@@ -0,0 +1,38 @@
+What:		/proc/fs/nfsd/reply_cache_stats
+Date:		March 2013
+KernelVersion:	3.10
+Contact:	linux-nfs@vger.kernel.org
+Description:
+		Provides statistics for the NFS server duplicate reply
+		cache (DRC). The file contains one labeled field per
+		line. Each line has the form "field name:" followed by
+		whitespace and a decimal value.
+
+		Fields:
+
+		=======================  ======  ==========================
+		max entries              u32     Upper bound on cache size
+		num entries              u32     Current entry count
+		hash buckets             u32     Number of hash buckets
+		mem usage                s64     Bytes consumed by the DRC
+		cache hits               s64     Requests answered from cache
+		cache misses             s64     Requests not found in cache
+		not cached               s64     Idempotent requests that
+		                                 bypass the cache
+		payload misses           s64     XID matched but request
+		                                 checksum did not
+		longest chain len        u32     Longest hash chain observed
+		cachesize at longest     u32     Cache size when longest
+		                                 chain was recorded
+		=======================  ======  ==========================
+
+		Counter fields (cache hits, cache misses, not cached,
+		payload misses, mem usage) are maintained with per-cpu
+		counters and may briefly show stale values under
+		concurrent load. There is no way to reset these
+		counters; consumers should compute rates by sampling
+		over time.
+
+		New fields may be appended in future kernels. Parsers
+		should match on field name, not line position.
+Users:		nfs-utils (https://git.linux-nfs.org/?p=steved/nfs-utils.git)
-- 
2.54.0

