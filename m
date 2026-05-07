Received: from canpmsgout08.his.huawei.com (canpmsgout08.his.huawei.com [113.46.200.223])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 356FB3B6C18;
	Thu,  7 May 2026 11:18:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.223
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778152720; cv=none; b=IlGSFGMB20Ftyk7nwyljJwTuCT02A42XT1rpuAMcPlJdt0BhH67m7YKH+72LKFnStGkYij0D7DRWUgEfuImORXTGbOTxg39VvXM8K2bfcSTfTsk7sF12RmrZT5VjcPaK2V0PlbbAmcv82s/p5WiXAGsPdEDdxx+tbW3tQ4v0OQ8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778152720; c=relaxed/simple;
	bh=YQBLHtIL3sLkDZZb9b9xmTib8lOtK1kmV5+ERuLWKJ4=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=D77iK49xmPrZnmdCqqVA//zgfioVXVDEJ69xZEFM4QZKY8BcI9rhEmd+J3abdzAapt0jWFTD4NK01m5UMqSASim96hvMTd0Pxix6gTjoRbGDk5hB4+WFQJ1qOZ9Zv7H7YPXWUf/6rXoD8q65umC499WtMMtUu1y9r17ug48TCqM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=oNNTcj6j; arc=none smtp.client-ip=113.46.200.223
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="oNNTcj6j"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=uncgW9df5VjQV909YzewzWv4EDpnmYPD4iNOCRSrHRw=;
	b=oNNTcj6jfNgbabvkH+A4bzvtO3QoMxfqhiHKfleBUUzR3iF+UB1Vp1E4K3v/Q+GMkIVX969fF
	AtQ5ekF1U8duT0f04jkJPZ1VylVKuwvWqzaILFUVxei4/6w3oWmH5OPHzkMujCx1K+BCo+BJ9yp
	+QPYuOG/9bTdTF4Efn8t89w=
Received: from mail.maildlp.com (unknown [172.19.163.214])
	by canpmsgout08.his.huawei.com (SkyGuard) with ESMTPS id 4gB8gX2WP0zmV8v;
	Thu,  7 May 2026 19:10:48 +0800 (CST)
Received: from kwepemk500005.china.huawei.com (unknown [7.202.194.90])
	by mail.maildlp.com (Postfix) with ESMTPS id F363F4056C;
	Thu,  7 May 2026 19:18:22 +0800 (CST)
Received: from huawei.com (10.50.85.155) by kwepemk500005.china.huawei.com
 (7.202.194.90) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.1544.11; Thu, 7 May
 2026 19:18:22 +0800
From: Zhihao Cheng <chengzhihao1@huawei.com>
To: <trondmy@kernel.org>, <anna@kernel.org>, <viro@zeniv.linux.org.uk>,
	<brauner@kernel.org>, <jlayton@kernel.org>, <josef@toxicpanda.com>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <chengzhihao1@huawei.com>,
	<yangerkun@huawei.com>, <yi.zhang@huawei.com>, <changdiankang@huawei.com>
Subject: [PATCH] nsfs: fix wrong error code returned for pidns ioctls
Date: Thu, 7 May 2026 19:14:04 +0800
Message-ID: <20260507111404.638608-1-chengzhihao1@huawei.com>
X-Mailer: git-send-email 2.52.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: kwepems200001.china.huawei.com (7.221.188.67) To
 kwepemk500005.china.huawei.com (7.202.194.90)

When executing NS_GET_PID_FROM_PIDNS (or similar pidns ioctls), if the
target task cannot be found in the corresponding pid_ns, the error code
should be ESRCH instead of ENOTTY.

This bug was introduced when the extensible ioctl handling was added.
Without proper return, ret would be overwritten by the default case in
the extensible ioctl switch statement.

Fixes: a1d220d9dafa8 ("nsfs: iterate through mount namespaces")
Signed-off-by: Zhihao Cheng <chengzhihao1@huawei.com>
---
 fs/nfs/nfs4state.c | 1 +
 fs/nsfs.c          | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 305a772e5497..5044bb4c870f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2039,6 +2039,7 @@ static int nfs4_purge_lease(struct nfs_client *clp)
  *
  * Returns zero or a negative NFS4ERR status code.
  */
+
 static int nfs4_try_migration(struct nfs_server *server, const struct cred *cred)
 {
 	struct nfs_client *clp = server->nfs_client;
diff --git a/fs/nsfs.c b/fs/nsfs.c
index 51e8c9430477..160018c4fb36 100644
--- a/fs/nsfs.c
+++ b/fs/nsfs.c
@@ -266,7 +266,7 @@ static long ns_ioctl(struct file *filp, unsigned int ioctl,
 		else
 			tsk = find_task_by_pid_ns(arg, pid_ns);
 		if (!tsk)
-			break;
+			return ret;
 
 		switch (ioctl) {
 		case NS_GET_PID_FROM_PIDNS:
-- 
2.52.0

