Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A37943C09F5
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 13:22:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789996962; cv=none; b=gXWKqAm60EHGZeppexo84iyGCUQhMWqlkZa0lfLzzUPO89bRfcbQ5wyChmSG9UQwTde54q5UOgNDdThjkpc8+8X4poegKwrARd45gfS3oWZveocWUCFVwjRKxMXnSq/bL2N/OMjwx8UJwk8gmyEeqAtlTRFZqkQuMey4OMiM5f4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789996962; c=relaxed/simple;
	bh=qnEUXYehdn/gEW6PL/EGlL3o/RfA7WITlL+fyac4vDA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=IvBLqziufUr5wmpIcnhe7qGNO6YsoWXdISjEweOWsxJQ3ehPi+gC+wt0d4oICTtF0dfR8qHj1RfzYQT98RCPlPwosVJcPHrfK/nxhhAGs2mu8MKXYecVCKpi+gKUK33nwglNagj73JvibZ2KHOV8Lk10KLjRGJz6pI4UloMCBXI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Du72lAf/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Du72lAf/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 802CE1F00893;
	Mon, 21 Sep 2026 13:22:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789996960;
	bh=nCUWB+Wa3VU6AYkNoA2e5rIIo3e9NEWxZCdAiNufrOg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Du72lAf/0oHyBGWU8fhwR/8IwIQHb0Zqi5hDoffF75fZpFNPnzWN7kI9tU6i2yVfy
	 dSqux9B8AfGZCECEzn+f405K9LEAh2O2BLxryR3HueZ8aNtwhcil0Ht+RbCV9RaG2g
	 Ag16SD7hLwJGHKYgda7EP6tpKBRp+5TmG/BmmocK9NroYR97kN5pZpIIXJfCKAxc7I
	 aBIQymAYTy6CMB+oBWsed/1fI22zGBd7mEb39T55xF6/WQ1JyR8tqoyT0pW7LBak6x
	 S00vJaf73HaWakpQQ4tkMZ0wj/EA5Zf+rnPum9q74mDSmEXMgZQI+IWFY5w6nNvROO
	 srxzd84+0WYng==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 21 Sep 2026 09:22:27 -0400
Subject: [PATCH v6 01/12] NFSD: Make the DRC size limit independent of page
 size
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-duplicate-reply-cache-v6-1-db5e13fd9944@kernel.org>
References: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
In-Reply-To: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1357; i=cel@kernel.org;
 h=from:subject:message-id; bh=qnEUXYehdn/gEW6PL/EGlL3o/RfA7WITlL+fyac4vDA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqsS+djo7mFpSKOfQpVE1GpLbpkQm4YsGwGnngp
 Zystb4gqW6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarEvnQAKCRAzarMzb2Z/
 lz+hD/0bVN1CLdNWPxIu2oNaasRrvGXN3jcrI00Pu6w6VYpD23thTip2hDroFQoPAhZ95AmjKdS
 vGDpAX57WnJUUIUx5Dvdj4Cn8NUSma9/fXm4jfQU0/9cMKGgYY8WNdUHBR5W8QnRlq/7Wvsu1UX
 hea4MdBwdfQsqIIoo4voCCaphmIzbFF5I8+GJMgUNDCqqeh7l8pTekSvqGuJLjIKZopyueHOKLr
 iQtSFu2l+E8n2S1sX0IIC3+oZ6qmrO3hUDZPiiwsCFKECIRDYEYQjKZU9hP4gPr8kSeeZ76VZIk
 B2BCaOOMAbMxQCSVwzQH77RD9ogQkWT943rJFQ/kPnnvCpiuizcwkiUMAitH6qB6xOCDLoKIMEv
 EZGL2112JqR+1TOddb/4jqEAFK/MgQolcg+rEhezfpvGedR0m3Z9s7da7FGKKhxK0uHKMczSFdX
 6EbTIJRqu+hGbs6JU6SBTeZyOGY99tatotdfTXvnkHqB52bDmmwA4N/+0NBC7vV+JHcGTRSwj6Y
 xS5/rKlEpJxSxUgAo7Tf7Z97GmnnYp5HCb/jxdvae3bceqCP1SlV1MCD3CfUpvM/5IwdMFgv+A0
 pafkgTRzzm3lkQpEZerfgWLiSpFIu7LAj4UxpR4P/6xgTizmI23x00rvJSGlhe4uNf7KAhLqO45
 SevaG67USL5peow==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_cache_size_limit() takes the square root of the low-memory page
count and then shifts the result by the page size in KB. The shift
belongs under the root. A host with 64 KB pages has a page count 16
times smaller than a 4 KB host with the same memory, so its root is
4 times smaller and its shift 16 times larger, and the limit comes
out 4 times larger. With 8 GB of low memory the limit is 92672
entries on 4 KB pages and 370688 on 64 KB pages.

Take the root of the byte count instead. The result matches the
table above the function on every page size. Low memory on a 32-bit
host is under 1 GB, so the byte count fits in an unsigned long.

Fixes: 0338dd157282 ("nfsd: dynamically allocate DRC entries")
Suggested-by: NeilBrown <neil@brown.name>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 80364b91331a..b43b276a92b3 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -73,7 +73,7 @@ nfsd_cache_size_limit(void)
 	unsigned int limit;
 	unsigned long low_pages = totalram_pages() - totalhigh_pages();
 
-	limit = (16 * int_sqrt(low_pages)) << (PAGE_SHIFT-10);
+	limit = int_sqrt(low_pages << PAGE_SHIFT);
 	return min_t(unsigned int, limit, 256*1024);
 }
 

-- 
2.55.0

