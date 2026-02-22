Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C40A3D3B3
	for <linux-nfs@vger.kernel.org>; Sun, 22 Feb 2026 16:20:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771777209; cv=none; b=dXVfYL8p/xMQfW6KK0cER2CAPijXs735sdpQNLUxubZmgDOHWyhRdR3Ix/g3YWvnPIOD0HpNdFyB81d+UHwWxAFraUdYt528NIaqLgztRIVbukqyxxYxTqfCVjajhJoJDJ05srojUY+e38O7aALsQvZCyP0UxITVSbI0NGuMhRQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771777209; c=relaxed/simple;
	bh=VFyA/3xbtENe5w9y9gbMB5Ioss1AJvv4HBPiVC3hu9I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WPbyChXk+Y/T3XGKURfhH7zIHufPd5mR0raTXJ+H9ZxzIutj4E+KUSP4QrTBNv1OEwyusHVgvDMzO+o5RHsNZGGmUXAXyXel9k3QHHdIi2HxrwW8t471yy4SGai0bCsNamWQygxhAz5/W7OC6/Ca5GeTnUJf5WlLzzX0BAB/DRQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kAoVh6b8; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kAoVh6b8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 61CA1C2BC86;
	Sun, 22 Feb 2026 16:20:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771777209;
	bh=VFyA/3xbtENe5w9y9gbMB5Ioss1AJvv4HBPiVC3hu9I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=kAoVh6b8FZT+/Ksuc5Je160lKsDU5Gt6emyQqoOEqI5f3Dv+pb70Rdw7Tfz0xR5pt
	 YCDSvUqjrvFh6AJ7ypXU5/J0ZMgYrmlCo58ehXKYtTYwNtsgXJr2i1GwK4T3+sx0uN
	 G8rXGFgJ2i2Qtqiw8ZwsZ1s7WdowqJBypHy43RBebLMP9dZBhG/56EU19BN/l/lBGA
	 c4GYx44J4AXO49R0ayBwXnu6NW3wgdmiuXO9xiVgwGZYc1S+smmLTv4IwbsZEol/+j
	 ayWU4ySIbf4ARq5J3XzPZrn0wLtmfVjbyOOyDLjHtUnnW9bNZe0T12hFmThR1uTe04
	 /6Fu2yRjD4nMQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [RFC PATCH 3/6] sunrpc: Handle NULL entries in svc_rqst_release_pages
Date: Sun, 22 Feb 2026 11:19:59 -0500
Message-ID: <20260222162002.10613-4-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260222162002.10613-1-cel@kernel.org>
References: <20260222162002.10613-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

svc_rqst_release_pages() releases response pages between rq_respages
and rq_next_page. It currently passes the entire range to
release_pages(), which does not expect NULL entries.

A subsequent patch preserves the rq_next_page pointer in
svc_rdma_save_io_pages() so that it accurately records how many
response pages were consumed. After that change, the range
[rq_respages, rq_next_page) can contain NULL entries where pages
have already been transferred to a send context.

Iterate through the range entry by entry, skipping NULLs, to handle
this case correctly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svc.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index f850a2af90c2..620de9abedbb 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -989,18 +989,24 @@ EXPORT_SYMBOL_GPL(svc_rqst_replace_page);
  * svc_rqst_release_pages - Release Reply buffer pages
  * @rqstp: RPC transaction context
  *
- * Release response pages that might still be in flight after
- * svc_send, and any spliced filesystem-owned pages.
+ * Release response pages in the range [rq_respages, rq_next_page).
+ * NULL entries in this range are skipped, allowing transports to
+ * transfer pages to a send context before this function runs.
  */
 void svc_rqst_release_pages(struct svc_rqst *rqstp)
 {
-	int i, count = rqstp->rq_next_page - rqstp->rq_respages;
+	struct page **pp;
 
-	if (count) {
-		release_pages(rqstp->rq_respages, count);
-		for (i = 0; i < count; i++)
-			rqstp->rq_respages[i] = NULL;
+	for (pp = rqstp->rq_respages; pp < rqstp->rq_next_page; pp++) {
+		if (*pp) {
+			if (!folio_batch_add(&rqstp->rq_fbatch,
+					     page_folio(*pp)))
+				__folio_batch_release(&rqstp->rq_fbatch);
+			*pp = NULL;
+		}
 	}
+	if (rqstp->rq_fbatch.nr)
+		__folio_batch_release(&rqstp->rq_fbatch);
 }
 
 /**
-- 
2.53.0

