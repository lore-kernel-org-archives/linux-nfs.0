Received: from canpmsgout04.his.huawei.com (canpmsgout04.his.huawei.com [113.46.200.219])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 02C651A08A3;
	Wed, 22 Apr 2026 06:53:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.219
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776840838; cv=none; b=OqZH6oDl9Qe43T7ixqaudhU79xOZJHLvo73iAUz2pG/VokbaKzNXoF0gflcecCEHQg1brxiEDrVloOiqnY2su4H3B0rHEQbFuax8NfODzzwr706zqQZV4GcOrLh0cFYF+aEi/J6pqNTStWD8ssTZLaz7pfG51CWxD1oAAjXcJrY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776840838; c=relaxed/simple;
	bh=MDAG9yzSfLlepf3l+P1VsaVExI60Oz/cyIvQz2yW4U4=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=VEoMVZYyS9nIj4gwuyZs7YrdgkmTuvWDglwzanBDUNElS4Hdl8/Y1F2vFPFxWv19NhorssIAeD7SlhoIZXbbd5pxENI2EskPA8rsTzZVZR/WHsUvXED6wU4He9foIpXoWDTdt6DVoaGoAe8ZzDV22cC3pCrhYGuBiyqmRss2nIo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=RVbmirbK; arc=none smtp.client-ip=113.46.200.219
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="RVbmirbK"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=/5Y9tiFsJJvdsWUPfuKYgEyvMInh6o3g8y2GR1YEEF0=;
	b=RVbmirbKyM4ddUEQBIbG6p2S5LWLs3e4/vopEIh59rnIrkulqMZ5PLLMSjivNJknf+25lzWrJ
	syiRJxsXDByW72mcFwwWgCPJ/vWxezY0QRI/EnMxbZru0gv7eAScKRdXw5pAiFWGSs0a/y1nDAA
	NmsBK7dFuJ1Q/fZ39bNkfF8=
Received: from mail.maildlp.com (unknown [172.19.162.223])
	by canpmsgout04.his.huawei.com (SkyGuard) with ESMTPS id 4g0qXc0gdKz1prNG;
	Wed, 22 Apr 2026 14:47:28 +0800 (CST)
Received: from kwepemk500005.china.huawei.com (unknown [7.202.194.90])
	by mail.maildlp.com (Postfix) with ESMTPS id 6B01E40561;
	Wed, 22 Apr 2026 14:53:53 +0800 (CST)
Received: from huawei.com (10.50.85.155) by kwepemk500005.china.huawei.com
 (7.202.194.90) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.1544.11; Wed, 22 Apr
 2026 14:53:52 +0800
From: Zhihao Cheng <chengzhihao1@huawei.com>
To: <trondmy@kernel.org>, <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<chengzhihao1@huawei.com>, <yangerkun@huawei.com>
Subject: [PATCH] NFSv4: Fix state recovery deadlock when server misses grace period
Date: Wed, 22 Apr 2026 14:44:47 +0800
Message-ID: <20260422064447.358447-1-chengzhihao1@huawei.com>
X-Mailer: git-send-email 2.52.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: kwepems500001.china.huawei.com (7.221.188.70) To
 kwepemk500005.china.huawei.com (7.202.194.90)

NFS server restart causes client to enter an infinite loop during state
recovery. The state manager gets stuck in NFS4CLNT_RECLAIM_NOGRACE processing,
with the server repeatedly returning NFS4ERR_GRACE for each file iteration.
This problem is reported in [1].

Trigger sequence:
 1. Client opens 2 files. After server reboot, client enters
    nfs4_do_reclaim(RECLAIM_REBOOT). Server misses grace period and returns
    NFS4ERR_NO_GRACE, causing client to set NFS4CLNT_RECLAIM_NOGRACE.
 2. Client enters nfs4_do_reclaim(RECLAIM_NOGRACE) to recover first file.
    Server reboots again, open request returns NFS4ERR_BADSESSION, client
    sets NFS4CLNT_SESSION_RESET.
 3. nfs4_reset_session calls nfs4_proc_create_session which fails with
    ETIMEDOUT due to network¹ÊÕÏ, nfs4_handle_reclaim_lease_error sets
    NFS4CLNT_LEASE_EXPIRED but does NOT set NFS4CLNT_RECLAIM_REBOOT.
 4. When nfs4_reclaim_lease runs, because NFS4CLNT_RECLAIM_NOGRACE is already
    set, it skips setting NFS4CLNT_RECLAIM_REBOOT (the bug, modified by
    commit b42353ff8d346 ("NFSv4.1: Clean up nfs4_reclaim_lease")).
 5. Server never receives RECLAIM_COMPLETE, so cl_flags lacks
    NFSD4_CLIENT_RECLAIM_COMPLETE. When processing subsequent files,
    server always returns nfserr_grace, causing infinite retry loop.

Fix it by setting NFS4CLNT_RECLAIM_REBOOT in nfs4_reclaim_lease if
NFS4CLNT_SERVER_SCOPE_MISMATCH is not set, so that the client sends
RECLAIM_COMPLETE to the server first, allowing subsequent nograce
recovery to proceed.

Fetch a reproducer in [2].

[1] https://lore.kernel.org/linux-nfs/55da00d4-a656-4ed2-ae57-7f881297a1b2@huawei.com/
[2] https://bugzilla.kernel.org/show_bug.cgi?id=221399

Fixes: b42353ff8d346 ("NFSv4.1: Clean up nfs4_reclaim_lease")
Cc: stable@vger.kernel.org
Reported-by: Li Lingfeng <lilingfeng3@huawei.com>
Closes: https://lore.kernel.org/linux-nfs/55da00d4-a656-4ed2-ae57-7f881297a1b2@huawei.com/
Signed-off-by: Zhihao Cheng <chengzhihao1@huawei.com>
---
 fs/nfs/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 305a772e5497..817327e73d88 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2012,7 +2012,7 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 		return nfs4_handle_reclaim_lease_error(clp, status);
 	if (test_and_clear_bit(NFS4CLNT_SERVER_SCOPE_MISMATCH, &clp->cl_state))
 		nfs4_state_start_reclaim_nograce(clp);
-	if (!test_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state))
+	else
 		set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
 	clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 	clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-- 
2.52.0

