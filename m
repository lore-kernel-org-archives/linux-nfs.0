Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793346036;
	b=1kXG8CDgoWgvpxjUH/gL+GKa61Z0+iLBqTpGgyxalUYw9O1GAl7NT2FRENYsMFcDlMOr
	 tpaJF2X8yGo/sFe+iMjXNFQhcyVED9ngPnfkdWcd3HaT4xFeZknOL297VhUBTTCHgmnPS
	 OQJbjQbdViDfonZtl32uAwRj0ew3+rcp4LaSknPOiq+DboT20qQVARKe6n17kHHT4d7QJ
	 iy3CV4h6TAroVr+U241F9bY9e9B+qDmUlvZPzm0u2fZ0sN7fHdoOuyv+RK5bHJIagcXfZ
	 Alx36gmLwXnPrrX5PidcaQKqBWQJpa5AZPRMzZS2KD0XOV0bFFEHMo2wuJg9iOua0Jw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793346036;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:X-B4-Tracking:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=ZlYNTWGnsh5fremtLRvgVCnRqsnX/opydOiKsYvnaoc=;
	b=eJ9Yq7pXQlOIMKgOk+5m8hd/loK6+4IXN7a4S0lP+ApdsYrFgKqQNxMXAh3WTADMm+3n
	 1mrH3PdVk9yzbl7qAOGnFhQwlZD8a3RSlJVltTgFKiGtNtBuw6yCC2HBNZYcXLu5AZ3v9
	 negMqEVwojaHo77iVYu76J7c/uuNuFCIp1MSRZVW1y2Aavf43ZeNfm68s0Pwi0NA5lOYt
	 R4yVtJQWwN2MEilKJMrjNfwKwuTfEHXQ2QaR+gUQQdq8umSvtCykUAhNPWzEd6AR58kRv
	 zDcLHACO/oi08iR+vtL6CDAzLMWNsMJtws+YW1bIMbAmTRiNyPMQF6GVsEPoWNC8sqg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Zn48h8m5;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 94CA7606A31D
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 07:40:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Zn48h8m5
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1793346036;
	b=c5OWiZVCR6plAK2fgOGJwjC3xP7ecejEA2c28Ozf+uM1vml//lr8azPDx5ss+1UEJXIK
	 zKmqxZmaYqoSrwTNA9To4LQw6CH17gNX5qk4S07BmSax9sPhjym8KnkJWauIy0R95gzxR
	 ND/2iMVG/EU4mKGns7A8Lx8wPO/i1zzIDbBpS+F/A8S6aOOpBfmtlQlKTVQbLKQI1ibXA
	 6thVopxUceUlYbNLXwkkJHlXIc3cO0OQ6x+P2DHIJRywZnrTX43nRpxuyVd8WEz0GO8LJ
	 6hBHkbyb3KYUq35v2kJOgSXtD9ObtK1VOEHuVx34Cuh5wb0FEvDqjMPS3Gi8FExgEag==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1793346036;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:X-B4-Tracking:To:Cc:X-Mailer:X-Developer-Signature:
	 X-Developer-Key:X-Endpoint-Received:X-Original-From:Reply-To:
	 Content-Transfer-Encoding;
	bh=ZlYNTWGnsh5fremtLRvgVCnRqsnX/opydOiKsYvnaoc=;
	b=btC2aSNFWSU4KqUtJ+CEHpqGFzfzhVErim6G4h/Ruwx2Qv6j0hML9aLWRNXzCeFiWUFK
	 Anrb5fwV/IVJS5ipnEafPJL4FGRHssvoc3hEZCEJW1OLAbHMSuCttLORXBQ/uG6XWbCBd
	 BoI/pDAAuo1G7lzpzuhB8JpS0BDfOEI+KsEFpO4EvaNuwbnXzVgU8hkYoFYOu85XWp9xk
	 XCeOiRlpB3lisQDRtmacQ8eadxCvYqxzfi+xPZ4oQ7P9xJAVjAcLfFxRAqdyjhX5WJeth
	 fQYPH0Y08D3jxzJl8oK9iZCCBgULQYelvI7Yu+/dbtNCm7HNrBiScmMkG18KyYu760A==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 9F9871F000C1;
	Fri, 30 Oct 2026 07:40:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793346036;
	bh=ZlYNTWGnsh5fremtLRvgVCnRqsnX/opydOiKsYvnaoc=;
	h=From:Date:Subject:To:Cc:Reply-To;
	b=Zn48h8m566PtqIduJ3DrwxPqBUyahft19jBsRClKbakftiOdwI6F7siEA1yl/PBMV
	 U80FSbA8Vx+30PRNfN0v61OS5DPYZ7Zdc/FV84ZmAE/ez0Brzc7VCJSoY0FN7kB43n
	 0nxXvDacV4+1dlvnVdwwgqg1rr74C78ZQEfpMAcSMv8E1CtBYDdQxs7y0hvsI3GXZK
	 9d7KM0k+/vKN7aSz1odAvq28JgALTT0z2pcfDVYjrNAyrlb5xL33bR9qVT28yXpEm3
	 vmk9ov6b3qz8CRQPzNTRva+XsG2uIEfnrPMRybcJoavuv+GPM4Pqc222MooikBZCFe
	 yVGriC0BD7fPw==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 05868436B9;
	Fri, 30 Oct 2026 07:40:35 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Fri, 30 Oct 2026 16:40:35 +0900
Subject: [PATCH] pnfs/blocklayout: don't let a READ layout hide written
 extents
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
Message-Id: <20261030-nfs-bl-ro-v1-1-2a0957b016c3@samsung.com>
X-B4-Tracking: v=1; b=H4sIAPJJ5GoC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzNDA2MD3by0Yt2kHN2ifN3klKQ0MwOLNJM0gxQloPqCotS0zAqwWdGxtbU
 A07nqblsAAAA=
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <ben.coddington@hammerspace.com>, 
 linux-nfs@vger.kernel.org, Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1793346034; l=2743;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=Vg6etV6xipx1KtXlbZppd+PVJsnrjMUfS5rmlQPPAX8=;
 b=EsAhAGkMBbHjOtISsOnoWbk0zcXYFxK7Vsmd/tiA5mZ+N7kq4EtAjMqlyA9Dm34X3e+fUHM97
 m5lpCG3qc27C4QS1mrcx99fb6EcvrICvzbYFbrPr+/yEaO2MFK1JaVh
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com
Content-Transfer-Encoding: 7bit

From: Daejun Park <daejun7.park@samsung.com>

Once a client writes to an INVALID_DATA extent, reads must use it
(RFC 5663, section 2.3.4). A READ layout fetched before LAYOUTCOMMIT
can map the range as NONE_DATA. Lookups check read-only extents first.
The client then reads zeroes until the layout is returned.

Do not add read-only extents over written or READ_WRITE_DATA extents.

Fixes: 8067253c8cc5 ("pnfs/blocklayout: rewrite extent tracking")
Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
Against next-20261006. extent_tree.c is the same in next-20261029
and in mainline 65ba8f34ec88.

Tested against Linux nfsd on XFS: an O_DIRECT write into a range with
no data, then a read across it, returned zeroes in 12 of 12 runs before
and the written data after. generic/013, 091 and 263 pass.
---
 fs/nfs/blocklayout/extent_tree.c | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index 7393118c42..40a6ab6329 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -252,6 +252,28 @@ __ext_tree_remove(struct rb_root *root,
 	return 0;
 }
 
+/*
+ * Return the first extent at or after @start that a new read-only
+ * extent must not cover: an ro extent, or an rw extent before @end
+ * that reads use. An INVALID_DATA extent not yet written to does
+ * not count: reads of it use the ro extent below it (copy-on-write).
+ */
+static struct pnfs_block_extent *
+ext_tree_search_ro(struct pnfs_block_layout *bl, sector_t start, sector_t end)
+{
+	struct pnfs_block_extent *be = __ext_tree_search(&bl->bl_ext_ro, start);
+	struct pnfs_block_extent *rw;
+
+	if (be && be->be_f_offset < end)
+		end = be->be_f_offset;
+	for (rw = __ext_tree_search(&bl->bl_ext_rw, start);
+	     rw && rw->be_f_offset < end; rw = ext_tree_next(rw)) {
+		if (rw->be_state != PNFS_BLOCK_INVALID_DATA || rw->be_tag)
+			return rw;
+	}
+	return be;
+}
+
 int
 ext_tree_insert(struct pnfs_block_layout *bl, struct pnfs_block_extent *new)
 {
@@ -275,7 +297,10 @@ ext_tree_insert(struct pnfs_block_layout *bl, struct pnfs_block_extent *new)
 
 	spin_lock(&bl->bl_ext_lock);
 retry:
-	be = __ext_tree_search(root, new->be_f_offset);
+	if (root == &bl->bl_ext_ro)
+		be = ext_tree_search_ro(bl, new->be_f_offset, ext_f_end(new));
+	else
+		be = __ext_tree_search(root, new->be_f_offset);
 	if (!be || be->be_f_offset >= ext_f_end(new)) {
 		__ext_tree_insert(root, new, true);
 	} else if (new->be_f_offset >= be->be_f_offset) {

---
base-commit: eea3fef32a9cf36abcb5975a5a594e4135a6b026
change-id: 20261030-nfs-bl-ro-cdbf608f4f0d

Best regards,
-- 
Daejun Park <daejun7.park@samsung.com>


