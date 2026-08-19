Received: from canpmsgout12.his.huawei.com (canpmsgout12.his.huawei.com [113.46.200.227])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0889815B135;
	Wed, 19 Aug 2026 07:52:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.227
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787125981; cv=none; b=Bq8uoKer/yl6zU37PBECtFbPxzGuEiSuyhrw64WAykhDlfyNtAc4usf9vXroFonI+1clcw/JcOGZ2ZNjG180dcSfGm5WCAPn5SpBxN5wdzJrIU+ajjDq4KIpLPwKnt37NTkhOOjE0Zu/poyUfkKDXhNEiASEtDmv61uMWAsikUU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787125981; c=relaxed/simple;
	bh=bO9gMnfPGoZCmX2d/F2b6vWBHaxVSSAe15dvlo98UAU=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=C25YmsJGNz0f6L+5hnCx0wjLdsm/CBp3F8fsvesPYuwp4lwEF9r+XO6m+0vniJAL5Kzjq+YQzZwENTNfNP1QUiaD21+JDj5lVOqC2gyNPxHFuiDykGZKlHW8vqPbHjaSDLKyq+h6wtz+f3i+kD/QkGcZEUfyWdPQmtY6BY6IE10=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=eFvs+Ee6; arc=none smtp.client-ip=113.46.200.227
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="eFvs+Ee6"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=PWM6qXosMaV/qbijAPdNlvqvrwwyE4L8SBYg/0ghMWE=;
	b=eFvs+Ee6zZ4RBbmrvCWv7Q1Ex1KGkXz7QhXXEOIrJZAq6w9HXHmASAw3wBwcN+oNWg0pKOwOh
	XdqndR6VIBXfzgJYy/2GV2jRVXiPFQZjauvx5vDViAUoueTbtoxl4Op9kBli/DOjwWKQ8kHvw4A
	Zx7rfgsNPQAKfkGpUXbi/4w=
Received: from mail.maildlp.com (unknown [172.19.162.92])
	by canpmsgout12.his.huawei.com (SkyGuard) with ESMTPS id 4hPz7H6J09znTvp;
	Wed, 19 Aug 2026 15:42:35 +0800 (CST)
Received: from dggpemr200001.china.huawei.com (unknown [7.185.36.96])
	by mail.maildlp.com (Postfix) with ESMTPS id 67B9640565;
	Wed, 19 Aug 2026 15:52:54 +0800 (CST)
Received: from huawei.com (10.50.85.155) by dggpemr200001.china.huawei.com
 (7.185.36.96) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.1544.11; Wed, 19 Aug
 2026 15:52:53 +0800
From: Ran Hongyun <ranhongyun1@huawei.com>
To: <trondmy@kernel.org>, <anna@kernel.org>, <cel@kernel.org>,
	<jlayton@kernel.org>, <viro@zeniv.linux.org.uk>, <bcodding@redhat.com>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<ranhongyun1@huawei.com>, <chengzhihao1@huawei.com>, <yangerkun@huawei.com>,
	<yi.zhang@huawei.com>
Subject: [PATCH 2/2] lockd: fix reference leak on lockowner allocation failure in nlmclnt_proc
Date: Wed, 19 Aug 2026 15:46:41 +0800
Message-ID: <20260819074641.1586137-3-ranhongyun1@huawei.com>
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

If nlmclnt_find_lockowner() fails, nlmclnt_release_call() is invoked
before call->a_callback_data is assigned, so it passes NULL to
nlmclnt_ops->nlmclnt_release_call() and the references taken by
nlmclnt_alloc_call() are leaked.

Fix it by moving the a_callback_data assignment before the lockowner
check, so nlmclnt_release_call() can free the references  properly.

Fixes: b1ece737f44f ("lockd: Introduce nlmclnt_operations")
Signed-off-by: Ran Hongyun <ranhongyun1@huawei.com>
---
 fs/lockd/clntproc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index dc0519ac0172..6b69a52788b7 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -171,6 +171,7 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl, void *dat
 
 	if (nlmclnt_ops && nlmclnt_ops->nlmclnt_alloc_call)
 		nlmclnt_ops->nlmclnt_alloc_call(data);
+	call->a_callback_data = data;
 
 	fl->fl_u.nfs_fl.state = 0;
 	fl->fl_u.nfs_fl.owner = nlmclnt_find_lockowner(host, fl->c.flc_owner);
@@ -184,7 +185,6 @@ int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl, void *dat
 
 	/* Set up the argument struct */
 	nlmclnt_setlockargs(call, fl);
-	call->a_callback_data = data;
 
 	if (IS_SETLK(cmd) || IS_SETLKW(cmd)) {
 		if (fl->c.flc_type != F_UNLCK) {
-- 
2.52.0

