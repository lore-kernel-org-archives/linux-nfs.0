Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 536623750BC;
	Tue,  6 Oct 2026 09:01:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.140.110.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791277269; cv=none; b=u5ppsUqgnZXrbk/YCTSmyb0XiaOeCauSuwQYXnkoxWVQhdfpn1MP6Fr4r0W3xtTz6UyKSGRHM3e3OJ6QVlUwFm5+c823Pguz9xxijnKAJoCBEEWSKUfzp1U+FokEMZ39olQLSkqweZfbstIyr4bsObpGiHyx3sfi0xs+0OSmamk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791277269; c=relaxed/simple;
	bh=1z7+s6FCjiOp+Ci+ruEl/3AqA8zxFNSnY01F/EIs0as=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=NPB+88O1AQnBar3a9AYJhxq2VdFB2eoRq7MYxKI9058XQqZvdBh+eS87FsQjZ6JprjkS48+ZjN0DmeXnPItQLq/t7fj1i0OmMHcQZYo3IhQPxKjucOneu7FNUjlaQWu+0qewCijcNPo7LTKmIBlc6u89oopu8IZCTES/gdC7kJw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com; spf=pass smtp.mailfrom=arm.com; dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b=krJXs8nS; arc=none smtp.client-ip=217.140.110.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arm.com header.i=@arm.com header.b="krJXs8nS"
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2D046152B;
	Tue,  6 Oct 2026 02:01:03 -0700 (PDT)
Received: from e132076.cambridge.arm.com (e132076.arm.com [10.2.197.107])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id D8B333F86F;
	Tue,  6 Oct 2026 02:01:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=arm.com; s=foss;
	t=1791277266; bh=1z7+s6FCjiOp+Ci+ruEl/3AqA8zxFNSnY01F/EIs0as=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=krJXs8nSizZ0pLDkW9hnxRvtBLyX+TwfMFUpZgFjIglKVkCh8/YaUX4UA3VSHi9SX
	 IMKN3JvFsLq/rKjl29Bv5AVxT4zSa0F7fN2PWRsYiNRM3/QdMrqd3F4XuDsPhY8JWJ
	 ok1N1fCqGsyEWxJfJ8z1Yh1czLJ9KfR9TKcevGGE=
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
Subject: [RFC PATCH 1/6] sunrpc: Add helpers to build bvecs from contiguous pages
Date: Tue,  6 Oct 2026 10:00:23 +0100
Message-ID: <20261006090028.3412544-2-Louis.Kaplan@arm.com>
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

Add helpers to describe contiguous runs with multipage bvecs. These
functions have no callers. They are used in later commits.

Accept a caller-supplied maximum bvec length so transport callers
can enforce direct memory access (DMA) mapping and device segment
length limits. Also support counting entries without populating
an array so callers can size their allocations using the same
coalescing rules.

Coalescing requires contiguous physical memory and page descriptors,
and is disabled under KMSAN. Xen constraint handling remains WIP.

Signed-off-by: J Louis Kaplan <Louis.Kaplan@arm.com>
Assisted-by: LLM
---
 include/linux/sunrpc/svc.h | 90 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 90 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index dfadea50e0c6d..e651c2312a912 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -11,6 +11,7 @@
 #ifndef SUNRPC_SVC_H
 #define SUNRPC_SVC_H
 
+#include <linux/bvec.h>
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/sunrpc/types.h>
@@ -376,6 +377,95 @@ static inline void svc_thread_init_status(struct svc_rqst *rqstp, int err)
 		kthread_exit(1);
 }
 
+/**
+ * svc_pages_to_bvec - build one bvec from physically contiguous pages
+ * @bv: bio_vec to initialize, or NULL to only measure the next extent
+ * @pages: first page-array slot in the range
+ * @nr_pages: number of page-array slots available from @pages
+ * @offset: byte offset in @pages[0]
+ * @len: maximum byte count to describe
+ * @max_bvec_len: maximum byte count in one bvec
+ *
+ * Return: The number of bytes described by @bv. The scan stops at a missing
+ * or physically non-contiguous page.
+ */
+static inline unsigned int
+svc_pages_to_bvec(struct bio_vec *bv, struct page *const *pages,
+		  unsigned int nr_pages, unsigned int offset,
+		  unsigned int len, unsigned int max_bvec_len)
+{
+	unsigned long first_pfn;
+	unsigned int bytes, used = 1;
+
+	if (WARN_ON_ONCE(!nr_pages || offset >= PAGE_SIZE || !len ||
+			 !max_bvec_len || !pages[0]))
+		return 0;
+	first_pfn = page_to_pfn(pages[0]);
+
+	bytes = min3(len, max_bvec_len,
+		     (unsigned int)(PAGE_SIZE - offset));
+	while (bytes < len && bytes < max_bvec_len && used < nr_pages) {
+		// TODO: handle Xen merge constraints, see `bvec_try_merge_page`
+		//	 for reference, or unify helper functionality
+		if (IS_ENABLED(CONFIG_KMSAN))
+			break;
+
+		if (!pages[used] ||
+		    page_to_pfn(pages[used]) != first_pfn + used ||
+		    pages[0] + used != pages[used])
+			break;
+		used++;
+		bytes = min3(len, max_bvec_len,
+			     (used << PAGE_SHIFT) - offset);
+	}
+
+	if (bv)
+		bvec_set_page(bv, pages[0], bytes, offset);
+	return bytes;
+}
+
+/**
+ * svc_pages_to_bvecs - build bvecs for a service page-array range
+ * @bvecs: bio_vec array to populate, or NULL to only count the entries
+ * @pages: first page-array slot in the range
+ * @nr_pages: number of page-array slots available from @pages
+ * @offset: byte offset in @pages[0]
+ * @len: byte count to describe
+ * @max_bvec_len: maximum byte count in one bvec
+ *
+ * If @bvecs is not NULL, it must have room for the count returned by a
+ * preceding count-only call.
+ *
+ * Return: The number of populated or required bvecs, or zero if the range
+ * cannot be described from the supplied page-array slots.
+ */
+static inline unsigned int
+svc_pages_to_bvecs(struct bio_vec *bvecs, struct page *const *pages,
+		   unsigned int nr_pages, unsigned int offset,
+		   unsigned int len, unsigned int max_bvec_len)
+{
+	unsigned int remaining = len;
+	unsigned int nents = 0;
+
+	while (remaining && nr_pages) {
+		struct bio_vec *bv = bvecs ? &bvecs[nents] : NULL;
+		unsigned int advanced;
+		unsigned int bytes;
+
+		bytes = svc_pages_to_bvec(bv, pages, nr_pages, offset,
+					  remaining, max_bvec_len);
+		if (!bytes)
+			break;
+		advanced = (offset + bytes) >> PAGE_SHIFT;
+		offset = offset_in_page(offset + bytes);
+		pages += advanced;
+		nr_pages -= advanced;
+		remaining -= bytes;
+		nents++;
+	}
+	return remaining ? 0 : nents;
+}
+
 struct svc_deferred_req {
 	u32			prot;	/* protocol (UDP or TCP) */
 	bool			secure;	/* RQ_SECURE of the original request */
-- 
2.43.0

