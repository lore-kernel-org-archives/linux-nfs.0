Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76B964779B2
	for <linux-nfs@vger.kernel.org>; Sun,  4 Oct 2026 19:40:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791142835; cv=none; b=CNDM4AHfInsM228TR1RCQd0B+pPrzvy/OJP32CvtbNSWKyMUP9Cj6QhglT8mWbN7ueMgExjr4Mybly6FtMHn33BZy5ig4bYEYRVME/cxEiLWVY7qhUDWonpJsxogHSdtNpugdQ/3VcV1RXyQPHcQTfzNahJDq2bbw0UZug33ICI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791142835; c=relaxed/simple;
	bh=J7yDwimF6DUSq+BiTnTde+mgwhggWVy5b0oxAT/fQMc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JkBTmznoxaw+hO/5H0hbftsthwuy+1mm4U/e3A2kBliZ7LuC1xc6Qpmu7ca3TDggy5RqoxGknozyebQdfNHtdnY5GL9a+4LNQmowYyhHmLSjUOl6uZq4oIzi0VyLLa5rpbXFscpgyhnbbKfN0UM9ToNzNv1Wew9RcaQZOvYDOaA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=j9fTGjPu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="j9fTGjPu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C5CFA1F00898;
	Sun,  4 Oct 2026 19:40:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791142834;
	bh=OwuXYIzof/ysbKdLt+T9FeyyjF+LhZS3MrgE3idXx9w=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=j9fTGjPuUDaehnJgGhvVXDClt9rnyAVhdbAxDTzdDHpgExDX3WbH//m71wz/QSae6
	 zZNZ3jdo/si97d5h+qvqtu1rMgHGhJCYF/AWFx/MI+M2RPOu4jiTML7e6zSOJ+cUE2
	 65VrwoAid/kytJQLp6VNNk/S0v35OSWv9UTCdtJF68FBEPHKy/eJIxrlJMF+eJ4AXu
	 GnkBAEF3M1INAiU9jYmXmkzjWaftmnOns8dooWS26QM8T4rDCHF0hg8p4sY7jomGss
	 El9Hdou2p6bMRxZBikN5oMtiXqEkfuPSbzXuytqpgY9AN4FOIpkQwbbp8rJ7sOBAKi
	 22loo9Fs/1Btw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 4/7] nfsd: keep spliced pages below rq_next_page when a READ fails
Date: Sun,  4 Oct 2026 15:40:26 -0400
Message-ID: <20261004194029.10714-5-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261004194029.10714-1-cel@kernel.org>
References: <20261004194029.10714-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_splice_actor() replaces rq_respages entries with page cache
pages and advances rq_next_page past them. When
svc_encode_result_payload() then fails, nfsd4_encode_splice_read()
zeroes page_len, and nfsd4_encode_operation() computes rq_next_page
from the empty payload. svc_rqst_release_pages() and svc_alloc_arg()
handle only the entries below rq_next_page, so the spliced pages
stay in rq_respages. A later reply that encodes into those entries
overwrites the page cache of the file that was read.

svc_rdma_result_payload() returns -E2BIG when the READ payload is
larger than the Write chunk the client provided, so an NFS/RDMA
client can trigger the failure.

When an operation fails, do not move rq_next_page backward. A
successful operation still sets rq_next_page from the payload
length, because a short read through nfsd_iter_read() leaves
rq_next_page past pages the reply does not use.

Fixes: 76e5492b161f ("NFSD: Invoke svc_encode_result_payload() in "read" NFSD encoders")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b86d181b58c3..d9417ebbe9db 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -6804,7 +6804,14 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	next_page = xdr->buf->pages +
 		DIV_ROUND_UP(xdr->buf->page_base + xdr->buf->page_len,
 			     PAGE_SIZE);
-	rqstp->rq_next_page = min(next_page, rqstp->rq_page_end);
+	next_page = min(next_page, rqstp->rq_page_end);
+	/*
+	 * A failed splice read leaves page cache pages in rq_respages
+	 * above the truncated payload. Keep them below rq_next_page so
+	 * that svc_rqst_release_pages() releases them.
+	 */
+	if (!op->status || next_page > rqstp->rq_next_page)
+		rqstp->rq_next_page = next_page;
 }
 
 /**
-- 
2.55.0

