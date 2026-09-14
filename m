Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6DFCB466B77
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 13:14:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789391677; cv=none; b=NUuMEsQE1PQfBMjAtYh38DiC2Ls0NXEbLoL7cjuUs9EaE7CQimNrn1xCnc1o8BIUHBEu/8Id6581CiJN9+4O2MnNT/5Ub73nOdjvRbDv/zINUgwU9iGThftpOaLyJRK5R6UVUjVTlKqPoXWV9mxujQGDwxWgONy1ABVUd0i9+t8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789391677; c=relaxed/simple;
	bh=9GtU35jhOH2RW8atzIYlAT1VPQuLtHPIYsxUhWDW//o=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=SEltgvy4CiHYtBn6wbvCCf9XDn1cEas0IMCzDXM3XANl2intS20mVceiQrSEDrgRrQZKMmnTFiYzrUWVrrjdTE2MOprqrPTk4nlazyQZULng2COI2jMW2EvtTVUOBEOffCMMQkrkz+AXeExCtXV/7p2Z41qAwmH6vFb7ObLyUro=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EVIrhRvV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EVIrhRvV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B36771F0089A;
	Mon, 14 Sep 2026 13:14:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789391675;
	bh=EgMZx1JPFxaL9t3MA4NJJ99iouIMMDbAKw1tcKHNfAg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=EVIrhRvVubT8f9U/7KcwbDHElAEIMMJ6Z60YOB+ov16H7qCU5wXezVV7gxcwfVMOW
	 T4BjCshh5YLGM8UO7tzr92uh6PBVfuYI7r20cdE+8lbgF0AUr7M8+sZks+73k+muN/
	 wcVvQx2jyllrimdqH0vHqnf6uqkj+rucdyu7239w+yHsbaKsA5gjUHR5eL0n3thUU4
	 7ILGUuYBF/YaKC1VX/FchBQXVuOOo58c48yDp2J87jB36MS52/l31e+AtFTDnP2GYy
	 nhcTtaKKhRifSXsiYRIEjv7A8iaDYCjpTSrY9YVzPY02bfpNW04cHZlnSD0Sm9x5GM
	 SnZjKLMPzk+qA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 09:14:18 -0400
Subject: [PATCH nfs-utils v3 09/11] mountd: drop a deferred fsid lookup
 once it has been answered
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nl-crossmnt-v3-9-a984a6c94829@kernel.org>
References: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
In-Reply-To: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2738; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=9GtU35jhOH2RW8atzIYlAT1VPQuLtHPIYsxUhWDW//o=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqp/M0aR0YkLtwu7ocihnhXcuZXnM7DExCIRNnH
 jp9qtHUZcOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqfzNAAKCRAADmhBGVaC
 FZ4TEAC/xST3bqcl/ABUPjJLR1mCVV9MUtisPXhywYDcK2Rbr7iGiNsywGgFm8+OLwnEKHydvfj
 7eGiL9EVqcxFHSc0idZGgyCGE928iug9fkCJ+byE+KvQlNFGI/B1oMVGShYd3Nv4UUdixjE7Mis
 ZsRBFmA6zUinHdfKYQVKn/SE5vzh5lsGifi1kH3QKOZGvOnfR7a2/NmBAnMhJCtC2wbtazLIw6a
 bqgm3rVTbW/XHiwaCgUgStKYrk6rbcOjTWgHfJ3CEzk//VXqS83o7MFmvC+8y3dlGLaBBITdHev
 LSlaZiWVbihLHTL3cw1OtQVEzgITQ/WpWbTuKwXuue3OjlUPEV1GYkGyHgJUGkW0hcOag+3I0SG
 aDVjcz8GEDLinGCEF4Cbl2PfTT+c/TaAYwkFsuJk3ZM+w6/o32VUqfREXPLzsruA1frtrHtwL07
 ohCTM3VGhfULnSnkxNHmFHEUPmtr4FUou+PAktGp7+At6YA4Y1bvI4Tv1FcHzWkJaLFl3TQba6a
 IhfzDTTHNpzpDMjij4pqHLMpqPxpe9rarMlrIcKLpvKPMscA7G3vl/FHlP1L3v0ggp7MnzJRQGb
 YTrbTaw6dRYx6ij78BUMCOhGe6CkSHPG5Sy4cfz+JdsJUnz+L7uytqrlyv5U/m/51W1NbBen3xM
 F1UoPkOJQGrZ1ww==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Building an expkey batch can defer an entry, and a later failure of that
batch sends the same entries through nl_expkey_singly().  An entry that
resolves the second time is answered, but its record stays on
delayed_expkey, so nl_retry_expkey() answers it again within RETRY_SEC.

Take it off the queue instead, as nl_export_singly() already does for
delayed_export.  The tuple test nl_delay_expkey() dedups on moves into
delayed_expkey_matches() so both users agree on it.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: LLM
---
 support/export/cache.c | 39 +++++++++++++++++++++++++++++++++++----
 1 file changed, 35 insertions(+), 4 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index 290ce09bb66e..6c887cd50327 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -2399,15 +2399,39 @@ static void delayed_expkey_flush(void)
 	}
 }
 
+/* Does @d hold the deferred form of @req? */
+static bool delayed_expkey_matches(struct delayed_expkey *d,
+				   struct expkey_req *req)
+{
+	return d->fsidtype == req->fsidtype &&
+	       d->fsidlen == req->fsidlen &&
+	       !strcmp(d->client, req->client) &&
+	       !memcmp(d->fsid, req->fsid, req->fsidlen);
+}
+
+/* Forget any deferred form of @req; it has been answered */
+static void delayed_expkey_remove(struct expkey_req *req)
+{
+	struct delayed_expkey **dp = &delayed_expkey;
+
+	while (*dp) {
+		struct delayed_expkey *d = *dp;
+
+		if (delayed_expkey_matches(d, req)) {
+			*dp = d->next;
+			delayed_expkey_free(d);
+			return;
+		}
+		dp = &d->next;
+	}
+}
+
 static void nl_delay_expkey(struct expkey_req *req)
 {
 	struct delayed_expkey *d;
 
 	for (d = delayed_expkey; d; d = d->next)
-		if (d->fsidtype == req->fsidtype &&
-		    d->fsidlen == req->fsidlen &&
-		    !strcmp(d->client, req->client) &&
-		    !memcmp(d->fsid, req->fsid, req->fsidlen))
+		if (delayed_expkey_matches(d, req))
 			return;
 
 	d = calloc(1, sizeof(*d));
@@ -2511,6 +2535,11 @@ static enum expkey_result nl_expkey_one(struct expkey_req *req)
 	return res;
 }
 
+/*
+ * Answer [@start, @end) one at a time.  Building the batch may already have
+ * deferred some of these, so an entry that resolves this time has to come back
+ * off the retry queue, or it gets answered a second time.
+ */
 static void nl_expkey_singly(struct expkey_req *reqs, int start, int end)
 {
 	int i;
@@ -2518,6 +2547,8 @@ static void nl_expkey_singly(struct expkey_req *reqs, int start, int end)
 	for (i = start; i < end; i++)
 		if (nl_expkey_one(&reqs[i]) == EXPKEY_RETRY)
 			nl_delay_expkey(&reqs[i]);
+		else
+			delayed_expkey_remove(&reqs[i]);
 }
 
 /*

-- 
2.55.0

