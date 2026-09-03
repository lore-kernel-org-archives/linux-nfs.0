Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D7E4D47F799
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:54:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788458095; cv=none; b=XP788xzvygMbdewupyTLqdAIpMHLfuXWuu+oVdxGoPglZdUIs/xKP8K7Eku0tzLIRVCVzBVP3Eo/hROL6d4w4DnkTcMRel5erURoDBl9CtmphY5IkyzMcTNyHooWkHEHcH71GoeMZt7LTzsYV/sTewGkSaawqrPNDPT96TP+V7c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788458095; c=relaxed/simple;
	bh=PeAMl6ek/PW4CTG3kfYFcCGDYCnj7QLi/+OtxelcC5E=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=LJebs7SZqFEwSUoMrlW/aZZg3EjkKRru0l8lnHBj8sTG8A71LMA6D+1QtFyitM5tBNO+NkiAvbQ+7VQyVHebCK07d6mwvdSP95ma0sVyrytgEnvHrDQsS30+yeNKKxZXEOMPKb/U7DPRwNbZpvcG7VwdTwwYmR9H027pVB3xQ8c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=W2exEU7A; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="W2exEU7A"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788458092;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=oH3VPxriK76ZcL+R3cR9oO2hoVEIpI+iXZvVnQYlkSg=;
	b=W2exEU7Ax5/Fv1sEVCqIHbVyrd2NCzR876uTruLUURm3hCd4wZycQa6jfbiSKJVO7jKIW9
	4hfHzuCNsaxILEJYYMGL3BTijz3Wldha608fVu8OTMiXUCtK9ybSqDYtxVrkZHYPvFi3MV
	4HYry3pcvu6MSrRA6UpvtgL0Nhf6ULk=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-663-y6gDACplPnmA1Yz8efOSAg-1; Thu,
 03 Sep 2026 13:54:50 -0400
X-MC-Unique: y6gDACplPnmA1Yz8efOSAg-1
X-Mimecast-MFC-AGG-ID: y6gDACplPnmA1Yz8efOSAg_1788458089
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 3C8521954213
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:54:49 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 18511195608A;
	Thu,  3 Sep 2026 17:54:49 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 71B025345C2E;
	Thu, 03 Sep 2026 13:54:48 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] blkmapd: reject zero-length signature components while decoding block signatures
Date: Thu,  3 Sep 2026 13:54:48 -0400
Message-ID: <20260903175448.1214235-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

A zero-length signature can cause blkmapd to map to an unintended
device.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/blkmapd/device-process.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index f53a6165..a47cc36e 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -81,6 +81,10 @@ static int decode_blk_signature(uint32_t **pp, uint32_t * end,
 		BLK_READBUF(p, end, 12);
 		READ64(comp->bs_offset);
 		READ32(siglen);
+		if (siglen == 0) {
+			BL_LOG_ERR("0 length signature component\n");
+			goto out_err;
+		}
 		comp->bs_length = siglen;
 		BLK_READBUF(p, end, siglen);
 		/* Note we rely here on fact that sig is used immediately
-- 
2.55.0

