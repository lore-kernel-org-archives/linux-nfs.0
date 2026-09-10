Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD23A493D3B
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:55:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048508; cv=none; b=gZ48rxvmidzDDQXyMbsPoi2Fc30EsZqfVsmgPf259XiQKWcaH9ZEcBCDnLVYRgDzbWLqxowBsF696OwWpk68ClEaBJ3jDRR0ME6bG5t7xEow0ghsiVKaUeBbTFkw9zQZz3GYDHCISHiYP7hJD+eL1GNDwTz0Ja72x4v7k1CW3m0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048508; c=relaxed/simple;
	bh=SP+SCIxxnGQ0feK5YkDZcSxUba1lcmIF++968TdXgZ0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Jt0JIrSCIuqS88alyvmiDzsX3HcJvtgst+Op28Kk9T4D2mnA8WwUUbk564kfAWVlfGV1L9nuCD1z0s1zw4H3+S8DJk0ouWQ3FUMwQZMqXwbcuzb6zqdIGfSmaloJ4dC79pTrE8hPL5MAO9d0jejpMnt4tMN0zoiKMDI7qIhh/oA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YFn/pk5P; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YFn/pk5P"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E24FF1F000FF;
	Thu, 10 Sep 2026 13:55:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048507;
	bh=otGcKQLVU9f9km6oBqtOTQpIQ/Bt8U5pMSF0IPZnYtU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YFn/pk5PsP5Cnx5Hy/D6NRsjWMU62XCpSdhAqR/tMSqJMa798r5NRtCAX1dI65u7G
	 l9GfB1yq2Fv8ucX0olrmx3CsWYnLW3k1enX+7ApeSISqj2fAyVR1zZLnZguN2W5SQs
	 4XolbGu2Mq03XTxlAQcIe26C2ZXWO1onFzD+JhRiHfFP4cDe/vJBJFjlbTIIZMeZoz
	 B790MxS9kc0y41e3wpF35pP7PICRlFf6hpudOVROCctnkj3Jyu5bnffjRsYQLzvcbY
	 5hFAzsm2QaAmfsqvYllvV0i2khzPKMe0uRKoEgMWFk69tWiCo56evtopQajQtLCMfz
	 6hPDXSfrC80pA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 10 Sep 2026 09:54:52 -0400
Subject: [PATCH v3 12/12] NFSD: Remove hard cap on duplicate reply cache
 size
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-duplicate-reply-cache-v3-12-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2797; i=cel@kernel.org;
 h=from:subject:message-id; bh=SP+SCIxxnGQ0feK5YkDZcSxUba1lcmIF++968TdXgZ0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqorawz2FBh0UIk1UkSJEgC98isxea75U6E3AN8
 uoNVthfrEuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqK2sAAKCRAzarMzb2Z/
 l+ykD/92gzFM+5DMNDuKqAbEzQYSOQSjt00hidwC9NG7I2ceje024hRzln4+jrnlivaT6P9fh8l
 f1UBNb9bhf1dDEgzTkHjiDLiDmSSiTWGUyHFOvQbbGgVQn3zDYd1E+W7BSe0KC4J8WWlTOrBauy
 6j4do+H8/rfpGW2d0Tfh7cOiv0ZDsCGi2w5GXVhLikBwE1lN/9UXcS+3aBwF1oL4y2wR4RWLXw4
 1QPUWyzEhUYKZgbACIjdsGUa6K2ji40AXx4gK7rQPKl/fBUrNelYMO0y/puP0wE4Qr3SPqs+eNn
 6knKzupZK9KxsF5sTEx2NyTscCBnVK4NkwISa36I9uloLbz8vTg1wD1Dd7jpv84D54vMDHMORM4
 byEvT8VgbrEBI8Sz/H7ub7j48JKpzIxZiuIclLRUARUEYF0RTXLm21ZIekHOmM0eaWl9G3qBbeq
 MDKXgRRw1j7U+YQ5eacYG+ea38r0dVMGsC8clGgJDoXb8S6uJs+LB9LeA5H+FVeM3hAD35RAu0q
 2u5IPAyrKGh7kdNLYGLqLQWOYz5SVYGR1NXw3joHQHq5nKAjPUXvcYpX5AUEuWXo/euIv1Sd1LL
 JOcBOYh6ZCYFq1x/oAvA0GrkmNac2EklgRdP3dwy+v5dvJ7sKJYQe6T8qdSQYTeoLgceH31Otmk
 qHZ2seEZ2l63G0A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The DRC matters most during a network partition, when clients cannot
receive replies and the server must hold them for retransmission
after reconnect. Explicit and implied ACK are inactive then, leaving
only RC_EXPIRE, and a 256k entry ceiling can be too small for a large
client cohort through a long partition. During normal operation the
ACK paths keep the cache small regardless of the maximum, so the cap
constrains only the failure case, where headroom matters most.

Remove the cap and let the square-root formula govern sizing. It
scales sub-linearly with memory, and the hash table already uses
kvzalloc, so larger sizes need no physical contiguity. The limit is
unchanged at 16 GB and below. At 1 TB the formula yields 1048576
entries, four times the old cap. Even at 1 KB per entry, the worst
case the old comment assumed, a full cache is 1 GB, 0.1% of that
host's memory.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 4ab6595a0bcd..5adf3c225a4f 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -48,34 +48,35 @@ static void	nfsd_reply_ack(void *data, const svc_ack_cookie_t *cookie,
 			       bool delivered);
 
 /*
- * Put a cap on the size of the DRC based on the amount of available
- * low memory in the machine.
+ * Set the size of the DRC based on the amount of available low
+ * memory in the machine.  The sizing formula scales with the
+ * square root of available pages, so growth is sub-linear:
  *
  *  64MB:    8192
- * 128MB:   11585
+ * 128MB:   11584
  * 256MB:   16384
- * 512MB:   23170
+ * 512MB:   23168
  *   1GB:   32768
- *   2GB:   46340
+ *   2GB:   46336
  *   4GB:   65536
- *   8GB:   92681
+ *   8GB:   92672
  *  16GB:  131072
+ *  32GB:  185344
+ *  64GB:  262144
+ * 128GB:  370688
+ * 256GB:  524288
+ * 512GB:  741440
+ *   1TB: 1048576
  *
- * ...with a hard cap of 256k entries. In the worst case, each entry will be
- * ~1k, so the above numbers should give a rough max of the amount of memory
- * used in k.
- *
- * XXX: these limits are per-container, so memory used will increase
- * linearly with number of containers.  Maybe that's OK.
+ * These limits are per-net-namespace, but the per-namespace
+ * shrinker reclaims entries under memory pressure.
  */
 static unsigned int
 nfsd_cache_size_limit(void)
 {
-	unsigned int limit;
 	unsigned long low_pages = totalram_pages() - totalhigh_pages();
 
-	limit = (16 * int_sqrt(low_pages)) << (PAGE_SHIFT-10);
-	return min_t(unsigned int, limit, 256*1024);
+	return (16 * int_sqrt(low_pages)) << (PAGE_SHIFT - 10);
 }
 
 /*

-- 
2.55.0

