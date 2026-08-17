Received: from szxga01-in.huawei.com (szxga01-in.huawei.com [45.249.212.187])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68665319601;
	Mon, 17 Aug 2026 06:14:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=45.249.212.187
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786947287; cv=none; b=kuuYYt6KgnTgl4rDiCuT+CxFh4lqyBm90Qi7vPFavKyCh83XyagHB5o1t4evV4iGm45fsm+Xqu9JxC7UdylngU1B5wNZECn0j7JZ/qxrzMODRx57OY9HHdYkI3L+vSuUiko6/ZSxYJKxiWfRGmx6qYDiVMrXOWEM6WrpWSrXv9I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786947287; c=relaxed/simple;
	bh=en23Wo/1Efu4e8c4+HV0A40Kkdt49pHjM//oXjD6TRY=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=B7K+5qeOGHTDC2KqDM6EMwfxZRoVFw3nVaiMqmZnihYSKooNTN35a0BQcj50olU0eUr3yyFIwH0xhvcEzUWOJy4VTLGQZ0L3pTKbFcy12Yhtl9nRp2TJF7V3ljaYshyB5S8FqYRZB7jj58pPswVSXwPZ/uJDOrQKwcbC7lB8L/Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=jab2KOK0; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=jab2KOK0; arc=none smtp.client-ip=45.249.212.187
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="jab2KOK0";
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="jab2KOK0"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=wEO9JOScI1pE2p9TUhPPcnDsPsquEu4SuzovJASV3qY=;
	b=jab2KOK0XvbO7rDik2T/2XCUCYjNrx3tU3WvmrCJhzBjKw2YUMD09zSWwZmT7U/7u02gxUE6M
	Fyf1CdynnCicfcPJd9um+ci5PT1NyzZEHr075VdjzS6CcqHRD/vC4egUr3Q2zN0SuYzMbXpPJZl
	vKG5pDJWGmy+1UeOMizmiOg=
Received: from canpmsgout12.his.huawei.com (unknown [172.19.92.144])
	by szxga01-in.huawei.com (SkyGuard) with ESMTPS id 4hNjGS68QVz1BFmt;
	Mon, 17 Aug 2026 14:14:24 +0800 (CST)
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=wEO9JOScI1pE2p9TUhPPcnDsPsquEu4SuzovJASV3qY=;
	b=jab2KOK0XvbO7rDik2T/2XCUCYjNrx3tU3WvmrCJhzBjKw2YUMD09zSWwZmT7U/7u02gxUE6M
	Fyf1CdynnCicfcPJd9um+ci5PT1NyzZEHr075VdjzS6CcqHRD/vC4egUr3Q2zN0SuYzMbXpPJZl
	vKG5pDJWGmy+1UeOMizmiOg=
Received: from mail.maildlp.com (unknown [172.19.163.200])
	by canpmsgout12.his.huawei.com (SkyGuard) with ESMTPS id 4hNj2Y3K3mznTwN;
	Mon, 17 Aug 2026 14:04:05 +0800 (CST)
Received: from dggpemr200001.china.huawei.com (unknown [7.185.36.96])
	by mail.maildlp.com (Postfix) with ESMTPS id 2EA5740563;
	Mon, 17 Aug 2026 14:14:25 +0800 (CST)
Received: from huawei.com (10.50.85.155) by dggpemr200001.china.huawei.com
 (7.185.36.96) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.1544.11; Mon, 17 Aug
 2026 14:14:24 +0800
From: Ran Hongyun <ranhongyun1@huawei.com>
To: <cel@kernel.org>, <jlayton@kernel.org>, <trondmy@kernel.org>,
	<anna@kernel.org>, <viro@zeniv.linux.org.uk>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<ranhongyun1@huawei.com>, <chengzhihao1@huawei.com>, <yangerkun@huawei.com>,
	<yi.zhang@huawei.com>
Subject: [PATCH] lockd: fix NULL pointer dereference in nlmclnt_locks_release_private
Date: Mon, 17 Aug 2026 14:08:20 +0800
Message-ID: <20260817060820.963195-1-ranhongyun1@huawei.com>
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

nlmclnt_locks_init_private() unconditionally sets fl->fl_ops even when
nlmclnt_find_lockowner() returns NULL due to allocation failure. When
locks_release_private() later sees a non-NULL fl_ops, it calls
fl_release_private, which dereferences fl->fl_u.nfs_fl.owner.

nlmclnt_proc()
	nlmclnt_locks_init_private <----set fl->fl_ops unconditionally
		if (!fl->fl_u.nfs_fl.owner) <----forget to clear fl->fl_ops

locks_release_private()
	if (fl->fl_ops) <----fl->fl_ops is not NULL but owner is NULL
		fl->fl_ops->fl_release_private()
			nlmclnt_locks_release_private() <----NULL ptr dereference

Fix this by clearing fl_ops when nlmclnt_find_lockowner() fails in
nlmclnt_proc(), so that locks_release_private() skips the
fl_release_private call path.

Fixes: bf8848918d75 ("lockd: handle lockowner allocation failure in nlmclnt_proc()")
Signed-off-by: Ran Hongyun <ranhongyun1@huawei.com>
---
 fs/lockd/clntproc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index f06faf577cea..4b54481fecd5 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -176,6 +176,7 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl, void *dat
 	if (!fl->fl_u.nfs_fl.owner) {
 		/* lockowner allocation has failed */
 		nlmclnt_release_call(call);
+		fl->fl_ops = NULL;
 		return -ENOMEM;
 	}
 	/* Set up the argument struct */
-- 
2.52.0

