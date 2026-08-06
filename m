Received: from canpmsgout02.his.huawei.com (canpmsgout02.his.huawei.com [113.46.200.217])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F85A2D5932;
	Thu,  6 Aug 2026 07:46:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.217
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786002415; cv=none; b=RrroOlU/A8J4KdCgZ2zbQfun9bzyROFVEnRKASWwcXlkt9QNTpvQdRpWH83Cwqej0+yOmu6aX3FinvCNUP5AWefM4ESSvKqz0zJxUsy9G6n7uWRgg+HVEY/bItHj7DBFJYbXyovOerdUo5jzc/YWBJigZi/L7A2yQD6JDqrm2aA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786002415; c=relaxed/simple;
	bh=rSPQ4UbmFnv0Jk2BythP6m+7IvoQhVJ/edVXNFoQWqw=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=H0QGg09AyHR0rYxVQ2p2tcXvgx19a5WMxMsdxRD1wo63ZQV/NjjfnQ/GPBBx+gvgSgCUbsRaIOweov2DX/VrRaAjb+hkd0UAYw86RfR+u6fCA31kTRE+ms83BPDtJq2I6PRkQ0NysY4U6qtEQ8PHqAXffluAy7f5BXnzzVDvBAU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=0TFEvI3D; arc=none smtp.client-ip=113.46.200.217
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="0TFEvI3D"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=sHNg/gjXTYN6SF0p5mSZ3vR0T/m6sOdcFl2o0mAz+wY=;
	b=0TFEvI3DFyWJR+QGtHydmhY4kgdSodj5v5esLy74Riq5BI2vlRTlgqS1wJYJ+hD6ZXaW9t+3k
	pPmOhTkWodN9od04KNBg6olJrs3LaPePkXpvmlN7peSPpKB758/nK3nPE2HA/7iMUmTXyQpDk1H
	LzzufOkvbNP4oixnpx3LUQw=
Received: from mail.maildlp.com (unknown [172.19.162.144])
	by canpmsgout02.his.huawei.com (SkyGuard) with ESMTPS id 4hFzcf3N7kzcbNp;
	Thu,  6 Aug 2026 15:36:50 +0800 (CST)
Received: from kwepemr500018.china.huawei.com (unknown [7.202.195.111])
	by mail.maildlp.com (Postfix) with ESMTPS id 8B25E4056D;
	Thu,  6 Aug 2026 15:46:46 +0800 (CST)
Received: from huawei.com (10.50.85.155) by kwepemr500018.china.huawei.com
 (7.202.195.111) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Thu, 6 Aug
 2026 15:46:46 +0800
From: Lai Zewei <laizewei3@huawei.com>
To: <cel@kernel.org>, <jlayton@kernel.org>, <neil@brown.name>,
	<okorniev@redhat.com>, <Dai.Ngo@oracle.com>, <tom@talpey.com>,
	<linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
CC: <chengzhihao1@huawei.com>, <yi.zhang@huawei.com>, <yangerkun@huawei.com>
Subject: [PATCH V5] nfsd: fix nfsd4_create_reclaim_record_grace crp null-ptr-deref in nfs4recover
Date: Thu, 6 Aug 2026 15:37:14 +0800
Message-ID: <20260806073714.3513158-1-laizewei3@huawei.com>
X-Mailer: git-send-email 2.52.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: kwepems500001.china.huawei.com (7.221.188.70) To
 kwepemr500018.china.huawei.com (7.202.195.111)

nfs4_client_to_reclaim() may return NULL if alloc_reclaim() fails. 
The caller __nfsd4_create_reclaim_record_grace() then unconditionally
dereferences the returned pointer via crp->cr_clp = clp, leading to a
null-ptr-deref crash.

Add a NULL check before assignment. If crp is NULL, just return.

Fixes: 4552f4e3f2c9 ("nfsd: change nfs4_client_to_reclaim() to allocate data")
Signed-off-by: Lai Zewei <laizewei3@huawei.com>
---
 fs/nfsd/nfs4recover.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 6ea25a52d2f4..005e3990da99 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -116,7 +116,8 @@ __nfsd4_create_reclaim_record_grace(struct nfs4_client *clp,
 	struct nfs4_client_reclaim *crp;
 
 	crp = nfs4_client_to_reclaim(name, princhash, nn);
-	crp->cr_clp = clp;
+	if (crp)
+		crp->cr_clp = clp;
 }
 
 static void
-- 
2.52.0

