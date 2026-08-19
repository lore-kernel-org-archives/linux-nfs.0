Received: from canpmsgout10.his.huawei.com (canpmsgout10.his.huawei.com [113.46.200.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5A313E6394;
	Wed, 19 Aug 2026 07:52:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.225
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787125982; cv=none; b=WkB9D6rG3mZItcnlA5MeSWEc7Z1gRgrxM/weAjF2M6ibCPMV8BVmCqTJIE3km3lqjZUwqQEiB+hvvyGt+jQuqFE3wqEe35hkZFUZiPLphExEJfuHEjolhEcDe4+NCjbZZ6eWd38nRFmN9KXGtwFET6hyBxed1O7hYQ2zbjzV61Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787125982; c=relaxed/simple;
	bh=pTTucBIfXr8LKkDoNg3Q6NwVpHVnGWQM64uvRXgD3Ak=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=IAs7TL7wYB43mrncpI5xzBcyg7qVmhVS1o5Hh2lmo4R815+w4HtZUQNYqidGv9Dmz1UKmZZhvnaxOul7jERCyM6dr7UDZ8dmhaqJgh5xXA+NC7akIM7HAm9YynqtD1mikgWJkm+mAkQ1LCrJ1EKKlBDVmZNjkqaBop3nYt2AIaE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=byB+sRej; arc=none smtp.client-ip=113.46.200.225
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="byB+sRej"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=wTp8wohQnTHU6adLQvDCXYWOG7pDEixjT/cCU2qkXEk=;
	b=byB+sRejSN9wwgTA9PfpGrV47cz7Dy/5FOqsGUFwbmKTyf4dO0nempizHLXmV5A06PtKnAg01
	kvA9aIGq+/LSMDAgXfzFbpityEpljsOKEUcit70wcLp3SudUON1+t32Kp0k2zS48XTol8WKaLaM
	BY0O06iFZYWVwx9x22oHXkQ=
Received: from mail.maildlp.com (unknown [172.19.163.127])
	by canpmsgout10.his.huawei.com (SkyGuard) with ESMTPS id 4hPz6r2L74z1K96b;
	Wed, 19 Aug 2026 15:42:12 +0800 (CST)
Received: from dggpemr200001.china.huawei.com (unknown [7.185.36.96])
	by mail.maildlp.com (Postfix) with ESMTPS id AF4A0402AB;
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
Subject: [PATCH 1/2] lockd: fix NULL pointer dereference in nlmclnt_locks_release_private
Date: Wed, 19 Aug 2026 15:46:40 +0800
Message-ID: <20260819074641.1586137-2-ranhongyun1@huawei.com>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <20260819074641.1586137-1-ranhongyun1@huawei.com>
References: <20260819074641.1586137-1-ranhongyun1@huawei.com>
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

Fix it by inlining nlmclnt_locks_init_private() into its single
caller nlmclnt_proc(), so that fl_ops is only set after
nlmclnt_find_lockowner() succeeds

Fixes: bf8848918d75 ("lockd: handle lockowner allocation failure in nlmclnt_proc()")
Signed-off-by: Ran Hongyun <ranhongyun1@huawei.com>
---
 fs/lockd/clntproc.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index f06faf577cea..dc0519ac0172 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -31,11 +31,11 @@ static int	nlmclnt_test(struct nlm_rqst *, struct file_lock *);
 static int	nlmclnt_lock(struct nlm_rqst *, struct file_lock *);
 static int	nlmclnt_unlock(struct nlm_rqst *, struct file_lock *);
 static int	nlm_stat_to_errno(__be32 stat);
-static void	nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *host);
 static int	nlmclnt_cancel(struct nlm_host *, int , struct file_lock *);
 
 static const struct rpc_call_ops nlmclnt_unlock_ops;
 static const struct rpc_call_ops nlmclnt_cancel_ops;
+static const struct file_lock_operations nlmclnt_lock_ops;
 
 /*
  * Cookie counter for NLM requests
@@ -172,12 +172,16 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl, void *dat
 	if (nlmclnt_ops && nlmclnt_ops->nlmclnt_alloc_call)
 		nlmclnt_ops->nlmclnt_alloc_call(data);
 
-	nlmclnt_locks_init_private(fl, host);
+	fl->fl_u.nfs_fl.state = 0;
+	fl->fl_u.nfs_fl.owner = nlmclnt_find_lockowner(host, fl->c.flc_owner);
 	if (!fl->fl_u.nfs_fl.owner) {
 		/* lockowner allocation has failed */
 		nlmclnt_release_call(call);
 		return -ENOMEM;
 	}
+	INIT_LIST_HEAD(&fl->fl_u.nfs_fl.list);
+	fl->fl_ops = &nlmclnt_lock_ops;
+
 	/* Set up the argument struct */
 	nlmclnt_setlockargs(call, fl);
 	call->a_callback_data = data;
@@ -484,15 +488,6 @@ static const struct file_lock_operations nlmclnt_lock_ops = {
 	.fl_release_private = nlmclnt_locks_release_private,
 };
 
-static void nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *host)
-{
-	fl->fl_u.nfs_fl.state = 0;
-	fl->fl_u.nfs_fl.owner = nlmclnt_find_lockowner(host,
-						       fl->c.flc_owner);
-	INIT_LIST_HEAD(&fl->fl_u.nfs_fl.list);
-	fl->fl_ops = &nlmclnt_lock_ops;
-}
-
 static int do_vfs_lock(struct file_lock *fl)
 {
 	return locks_lock_file_wait(fl->c.flc_file, fl);
-- 
2.52.0

