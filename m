Received: from canpmsgout09.his.huawei.com (canpmsgout09.his.huawei.com [113.46.200.224])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47EF61D61B7;
	Fri, 12 Jun 2026 03:04:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.224
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781233449; cv=none; b=d4rq7fbExx8nE1LdmfvrOWJt3AVP3chdbZXhpd19LMAfXD0OrS/0jI9dI3jrZXdXKeAf97JJHwgimGXvR18bwCChkqHYGDw0u8f67UopkfFwn6TX0bfFqjlvmY2QBTBoqDG65CjLGl/gvrtO5UuVWKgFKijjE0x5vgbaUy3WETE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781233449; c=relaxed/simple;
	bh=6yL8yF1AN1Y6lyG75NedicN+N9hFV9Tcm3z2LAXnhR4=;
	h=Message-ID:Date:MIME-Version:From:To:CC:Subject:Content-Type; b=jZ57TVVBSMfgKQ7WUA1LPG5shY0lZEnMjuRt0ggiSJKcyuHViQBKtpo5lrEn7N5CyRTBYHuPGTkM1mTMXOXsCwzR/ubmIFxZb1cWIItHTokXTn+ynZ8bQZG/MDsu2Cj5kQqy2hhn6hEl0gLngOjPqA2E+OPWKp1AXT+N9F/CARc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=h-partners.com; dkim=pass (1024-bit key) header.d=h-partners.com header.i=@h-partners.com header.b=c0UmLHAh; arc=none smtp.client-ip=113.46.200.224
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=h-partners.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=h-partners.com header.i=@h-partners.com header.b="c0UmLHAh"
dkim-signature: v=1; a=rsa-sha256; d=h-partners.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=0HywzYvhVtWBXP8M63XKsN420d8S8kqpVKz/hDIXSp4=;
	b=c0UmLHAhbQyHo8oRSAzLo0YfY+jK73IUdu/mEIejNYLx2ZR4DRxEuzLpEA6iUYb8iLBsHV6pK
	WeCsxF3FP4SQgudvQ+8Y/L53DDWZ13pZ9sgNCcx0teXzcJExcQKs45jXIJRX1FSqOGV1tlDzNjV
	Pq8WpPyC3Medcy0Ay86zl1Q=
Received: from mail.maildlp.com (unknown [172.19.163.15])
	by canpmsgout09.his.huawei.com (SkyGuard) with ESMTPS id 4gc40435v2z1cyPd;
	Fri, 12 Jun 2026 10:56:04 +0800 (CST)
Received: from dggpemr100013.china.huawei.com (unknown [7.185.36.198])
	by mail.maildlp.com (Postfix) with ESMTPS id 81BAD40539;
	Fri, 12 Jun 2026 11:03:58 +0800 (CST)
Received: from [10.174.186.66] (10.174.186.66) by
 dggpemr100013.china.huawei.com (7.185.36.198) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1544.36; Fri, 12 Jun 2026 11:03:57 +0800
Message-ID: <39030635-e879-4cca-adfc-b6e94d2ec3ab@huawei.com>
Date: Fri, 12 Jun 2026 11:03:56 +0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
From: "zhangjian (CG)" <zhangjian496@huawei.com>
To: <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>,
	<neil@brown.name>, <okorniev@redhat.com>, <Dai.Ngo@oracle.com>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: sunrpc:fix shift-out-of-bounds for majortimeo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: kwepems100001.china.huawei.com (7.221.188.238) To
 dggpemr100013.china.huawei.com (7.185.36.198)

For UDP proto, to->to_exponential is true. Too large to_retries
may cause shift-out-of-bounds error for "majortime <<= to_retries"
Add sanity checks to fix it.

Signed-off-by: zhangjian <zhangjian496@huawei.com>
---
 net/sunrpc/xprt.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 48a3618cbb29..c62f9998ffe9 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -656,10 +656,16 @@ static unsigned long xprt_calc_majortimeo(struct
rpc_rqst *req,
 {
 	unsigned long majortimeo = req->rq_timeout;

-	if (to->to_exponential)
-		majortimeo <<= to->to_retries;
-	else
+	if (to->to_exponential) {
+		if (to->to_retries >= BITS_PER_LONG ||
+		    majortimeo > (ULONG_MAX >> to->to_retries)) {
+			majortimeo = ULONG_MAX;
+		} else {
+			majortimeo <<= to->to_retries;
+		}
+	} else {
 		majortimeo += to->to_increment * to->to_retries;
+	}
 	if (majortimeo > to->to_maxval || majortimeo == 0)
 		majortimeo = to->to_maxval;
 	return majortimeo;
-- 
2.33.0

