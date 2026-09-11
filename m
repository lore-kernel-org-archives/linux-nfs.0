Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 51B744A3F0E
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 16:25:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789143948; cv=none; b=qgWr2qqaSbMwAiS9VAvlmz6tsIj2kkQtBKjtkRatm8oMKtn+m/mrcyKHQjFACUeUZCDcfRO63h3f6xxLq1J7Cn8kg2Rit4Ob9g+a26wChhRNtvZHLm7DISo0LFy7/jI4i9MCiCyg+iN+C8TmIUwhe9xuUU/h78eYUyYBjRnvEl0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789143948; c=relaxed/simple;
	bh=CITuT398+uEUlmVVqkkkFJ8u8JJTWoAAgXtqm5ZC0E4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=lnincgEQXbLBHKrgCIC4uPEpoBar4hqnxiWAzEeObDLCj8M2RwNE+BKDHSMINGhZEqRXk9r5AaWAdMEyQCM/1+uCZqcryIM3XI3LCKtJHzpERl9Rkf7xoa/gSZYR+KO6aqPXxIUZc2IvOPIHyRwuIqdrE9sQuXwXkhtFnAd1Fjs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=okGq/E42; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="okGq/E42"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D174B1F0089B;
	Fri, 11 Sep 2026 16:25:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789143947;
	bh=nAzXjDFN0VkpPXFxZvRA3W2IrT4MNiwMXYsL1FGbOLM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=okGq/E42KVHeZBJez3w3byC3moNpiMmnHyUeCnidWxH8tDJOqWUywosh71UZLbbm7
	 DA+nk54rCLCAMPj4Yb+kp3ap+CRcY/F6DoEz9PfkzpDOz1T8/bkEs7xUKMwcxnY6Wd
	 +hfHNxdKenGf6n2T+YvWicX7Q4jtxB35OeuVSWh7wQxaDeP2b693DZgXU45EKsjWek
	 PkPZxAVrc3F7FZkeV52SoLxco5R1hcJsWAD9H2qp0wk0cGzA1eirz/P19rPptgF4wS
	 MctArCwsdR0xxUlhylBsN187Qvh0J/Ok9tilL1+jinoacAW8TZ5yfuE5wTzMj6ncb2
	 uSePkvKc8VU8Q==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 11 Sep 2026 12:25:34 -0400
Subject: [PATCH nfs-utils v2 09/10] mountd: drop a deferred fsid lookup
 once it has been answered
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260911-nl-crossmnt-v2-9-f4d869951c5e@kernel.org>
References: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
In-Reply-To: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2738; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=CITuT398+uEUlmVVqkkkFJ8u8JJTWoAAgXtqm5ZC0E4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqpCuE1+0HMnqaHshbBfSgZe5w5FpGXjehqvx+6
 huivqilLLuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqQrhAAKCRAADmhBGVaC
 Fcf5EACNBgR6TPi6om1mgh0OETQMg8FWHkER8uyD3+2unHMXTrph60egWvUG8YFF6SnHyOekA/w
 Ixayj/mIEiR3LLnzCDXIfVPDRq6Clazj7QW+cYmO8JPEmhlAEk0119j6MEFpy2y6Dk646Mn7i1v
 SF51vdbmEcBvRkxCUesmZRNXHL3XbY8ETTcMV1pN3Kv52dgGARDNrTNNeXb67mnXYvlzQ83YzZ6
 4M/qx42dBej6zhdebErTViKZZOsxzZLlXvYMclcpCtPzzSxvqmuWAtRZMZoU1gesfVGuIRVGel+
 hBQNOHJKhDmv5r4LMIo184BpWnx/V+IEuddQBd9k3pbxlfvIg3TCXd+gnHgU2MZXVhgJD7aarXo
 67nJv10CELvTCm/egDWFLLZnq/mUOBtUTWqS6CflAB7kYt0c6/pmbrUM6H8Jtbep9hAdmqf1Qgc
 ZMjFhFoN8eUWCh2Nsn6TfbxK4SVxZUIt5JETweE4nHbHGOgIAZphTAweew6/dsZDqaNHRQitvFM
 RnpDBsGIVwaeBQlZwMmfqZeK9riYatt2cj25nkFoxN2RUybYHbrpvXF4PFiGTWoAteF4DCdw3As
 Jme9Nqhfq3GdNBSHRMHJK1wclmRpYxIUBY18O7vvvKGckLWgu57rlenXtjxjmAAlUz+7nVZ6jrv
 IOqsiy5+WlWjxqQ==
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
index 1a734a4f61f4..ba82a30d295b 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -2349,15 +2349,39 @@ static void delayed_expkey_flush(void)
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
@@ -2460,6 +2484,11 @@ static enum expkey_result nl_expkey_one(struct expkey_req *req)
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
@@ -2467,6 +2496,8 @@ static void nl_expkey_singly(struct expkey_req *reqs, int start, int end)
 	for (i = start; i < end; i++)
 		if (nl_expkey_one(&reqs[i]) == EXPKEY_RETRY)
 			nl_delay_expkey(&reqs[i]);
+		else
+			delayed_expkey_remove(&reqs[i]);
 }
 
 /*

-- 
2.55.0

