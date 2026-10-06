Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 20D6837F333;
	Tue,  6 Oct 2026 09:01:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.140.110.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791277270; cv=none; b=HsQja8AQXTDVzprEedEjp4pfEfSmIZx4Xxfgd561ZTFv6PtdkJgV9AOJJsUC5kdEswTEaAMJOdpq+oKoSuzm6BH3AQsQZJG0sQKuHFuU+5J8Bde2xg/0E5jOVS9iRRln58chrOUgqbO3psieyBYxf+/jrHKx9c/sDZgPr2R4oJM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791277270; c=relaxed/simple;
	bh=ZpoftAUkfRIGoYYuVdg4yQH4Wqf9qWgrdlwFTHzbGcU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uXr96JA4Z5xgtSYqairYW6CeZ49BWE3fB6N4h/PnqdXo14BftQg9mIDJWtGx7uzxp0kExWsR6Caoj4PsgTNkHKxY/FU5MhacfTVJEgQ4YCOuS/rR9HyZxtABOcs+fU50YZ3k5Or/jRMeUAJ6So34Ek02VN0H7yLxTULHECLK9To=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com; spf=pass smtp.mailfrom=arm.com; dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b=IyrLe7tr; arc=none smtp.client-ip=217.140.110.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b="IyrLe7tr"
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 29F5D1596;
	Tue,  6 Oct 2026 02:01:05 -0700 (PDT)
Received: from e132076.cambridge.arm.com (e132076.arm.com [10.2.197.107])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id CEBFD3F86F;
	Tue,  6 Oct 2026 02:01:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=arm.com; s=foss;
	t=1791277268; bh=ZpoftAUkfRIGoYYuVdg4yQH4Wqf9qWgrdlwFTHzbGcU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=IyrLe7trUZM5Jgb10+BcMnF/jeQYuLwiaUQ+jhuUvIPrcPqwgghY+i6YZPqDR1Qyg
	 1UtK5CarV3w35Iy3TJoZ2Ro4I+RrgDFlFgZhcGbwrcDySBM8YI6EPPKWcSX+OLxdz2
	 fojUe6XXIGj0+7dcrueb0pwhQpX7fm5IK0a2KmlU=
From: J Louis Kaplan <Louis.Kaplan@arm.com>
To: cel@kernel.org,
	dai.ngo@oracle.com,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	tom@talpey.com
Cc: linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	anna@kernel.org,
	jgg@ziepe.ca,
	leon@kernel.org,
	trondmy@kernel.org,
	J Louis Kaplan <Louis.Kaplan@arm.com>
Subject: [RFC PATCH 2/6] nfsd: Coalesce contiguous pages for direct reads
Date: Tue,  6 Oct 2026 10:00:24 +0100
Message-ID: <20261006090028.3412544-3-Louis.Kaplan@arm.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261006090028.3412544-1-Louis.Kaplan@arm.com>
References: <20261006090028.3412544-1-Louis.Kaplan@arm.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Use the previously added helper functions for nfsd direct read buffers.

Before this change, the direct-read path builds one bvec per base page,
even when the destination pages are physically contiguous.

Coalesce these pages into multipage bvecs to reduce the number of
entries traversed when advancing the filesystem's read iterator.

Signed-off-by: J Louis Kaplan <Louis.Kaplan@arm.com>
Assisted-by: LLM
---
 fs/nfsd/vfs.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c7dd94697f2ff..329bb7d410765 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1124,11 +1124,16 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	v = 0;
 	total = dio_end - dio_start;
 	while (total && v < rqstp->rq_maxpages && page < rqstp->rq_page_end) {
-		len = min_t(size_t, total, PAGE_SIZE);
-		bvec_set_page(&rqstp->rq_bvec[v], *page, len, 0);
+		len = svc_pages_to_bvec(&rqstp->rq_bvec[v],
+					page,
+					rqstp->rq_page_end - page,
+					0, min_t(size_t, total, UINT_MAX),
+					UINT_MAX);
+		if (!len)
+			break;
 
 		total -= len;
-		++page;
+		page += DIV_ROUND_UP(len, PAGE_SIZE);
 		++v;
 	}
 	rqstp->rq_next_page = page;
-- 
2.43.0

