Received: from canpmsgout07.his.huawei.com (canpmsgout07.his.huawei.com [113.46.200.222])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE86C3F44C9;
	Wed, 19 Aug 2026 07:53:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.222
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787125983; cv=none; b=DX/BVgZPNW9Kqzie5yrMgR2rJ8kQaDTEubXU3wDWBU2j6C2JnGNrWaS1exNbkl9q5zqFHl4K3G1CRaDKYpF8p8cuzkldIiFkSxLRUvS44N/eBKFAfogVgO8eeUBV4HYDa+bcFiYKm/vm63IDNZTtl6B7dHN60uIOsiGgG+9VAdg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787125983; c=relaxed/simple;
	bh=hRRWu8+QTwiA0TCLOSs10Bw+VYRms8sxL30bdwQy44A=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=Y07f+GqYNuRiWQZsHnX0rZ0TaG9ZC+i6KL5BFyuQKlL7uosgyfvI4QnBwc1EmdWNvXSNi96/YFPkmWRfLIVw2Oh9VHljs4JfYLUSkV27zbCfrDo2OUrd5d43LVcRQcdi5TAWIVfNmdRNWVcAQxzaSC2TaKbExx5JkJDI0/cD7jw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=udcNtZ5b; arc=none smtp.client-ip=113.46.200.222
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="udcNtZ5b"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=fn7HUZVjKjBRqiYLxRzOeVnsXcvyBJqfObUl8rvM3h4=;
	b=udcNtZ5bBTN8c44K23HTjFHNrpYRWZf3e3c66UuIROS3FYEk37Y28NVPfIqvhMAD6GYCemO6w
	3Nbl+dYjKBWGlwOi6A0ggAFtR78BLJ01IHIr/oAi80Y2gsGmCPE7GvsGj13TOZWy/7wgPdWHYbb
	+z1m5twNcuCohxmQ2lWgtRc=
Received: from mail.maildlp.com (unknown [172.19.163.214])
	by canpmsgout07.his.huawei.com (SkyGuard) with ESMTPS id 4hPz6q5YV0zLlXf;
	Wed, 19 Aug 2026 15:42:11 +0800 (CST)
Received: from dggpemr200001.china.huawei.com (unknown [7.185.36.96])
	by mail.maildlp.com (Postfix) with ESMTPS id 03F0C4056C;
	Wed, 19 Aug 2026 15:52:53 +0800 (CST)
Received: from huawei.com (10.50.85.155) by dggpemr200001.china.huawei.com
 (7.185.36.96) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.1544.11; Wed, 19 Aug
 2026 15:52:52 +0800
From: Ran Hongyun <ranhongyun1@huawei.com>
To: <trondmy@kernel.org>, <anna@kernel.org>, <cel@kernel.org>,
	<jlayton@kernel.org>, <viro@zeniv.linux.org.uk>, <bcodding@redhat.com>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<ranhongyun1@huawei.com>, <chengzhihao1@huawei.com>, <yangerkun@huawei.com>,
	<yi.zhang@huawei.com>
Subject: [PATCH 0/2] lockd: fix two bugs on nlmclnt_find_lockowner() failure path
Date: Wed, 19 Aug 2026 15:46:39 +0800
Message-ID: <20260819074641.1586137-1-ranhongyun1@huawei.com>
X-Mailer: git-send-email 2.52.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: kwepems100001.china.huawei.com (7.221.188.238) To
 dggpemr200001.china.huawei.com (7.185.36.96)

Both bugs are triggered when nlmclnt_find_lockowner() returns NULL
due to allocation failure in nlmclnt_proc():

Patch 1 fixes a NULL pointer dereference: nlmclnt_locks_init_private()
unconditionally sets fl->fl_ops before checking whether owner is NULL,
so locks_release_private() later calls fl_release_private which
dereferences the NULL owner. Fix by inlining the function so that
fl_ops is only set after the owner is valid.

Patch 2 fixes a reference leak: call->a_callback_data has not been
assigned when nlmclnt_release_call() is invoked on the error path,
so nlmclnt_ops->nlmclnt_release_call(NULL) skips cleanup and the
references taken by nlmclnt_alloc_call() are never freed. Fix by
moving the assignment before the lockowner check.

Ran Hongyun (2):
  lockd: fix NULL pointer dereference in nlmclnt_locks_release_private
  lockd: fix reference leak on lockowner allocation failure in
    nlmclnt_proc

 fs/lockd/clntproc.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

-- 
2.52.0

