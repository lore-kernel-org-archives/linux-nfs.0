Received: from canpmsgout04.his.huawei.com (canpmsgout04.his.huawei.com [113.46.200.219])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C2BC1EB19B;
	Mon, 23 Mar 2026 01:21:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.219
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774228871; cv=none; b=e2NSWTUxQrn6yG1GfwtKzaeic8BN01U/bkdhY4+tn/DIY17p1JwL5MZBiPu9UCxcfpiXChEymJAjvvfLPSO7xZF3L0SDFCesmuobj6/dAFMfDYlVmw4CaMhlDqc8SAqXRr0YoR6afthvMTwBOb/HN2+vGqQbiZaVmbGWmMtsB/Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774228871; c=relaxed/simple;
	bh=+MxQgVy0WrDNiEahkajd88knw3xB3Tyf14U3HZXJjKs=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=M9pISCPPJkOtrsh9hw3Fo4EyqeHv5raVDRSx9fdZxJ1LdIvbyPItdZfyfhQxt9DkGZSCgfRx/AdzWaQofyQmnaGY6I0XHVlMP4LZMdQyPRasClKK8A2J9DEDUdE/VNTzgMVoU5dCwWz8bNftDnb8/k8RS7ABSbtJjZX53a7vopk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=iJnPb9cc; arc=none smtp.client-ip=113.46.200.219
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="iJnPb9cc"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=zJQ0Xohrtmr2fJV+Ux5Rb7EBv7iz4UwLOc9o26blc4k=;
	b=iJnPb9cckwud83n9W7SXcHLiWu6MiKxkMvGgpuaOZoLQoltoyV8KIJjyByxa456nQqO2OnsOO
	2o88qAIyFT798rCguYFWJIEesqSA96ME83JCcfxufvOBg7VdtLnhIkCL4YxA6fKrcnP9/2rc7Kq
	8MmMeuZCbIdlI+OCLE/su38=
Received: from mail.maildlp.com (unknown [172.19.162.144])
	by canpmsgout04.his.huawei.com (SkyGuard) with ESMTPS id 4ffFZj0C5sz1prp9;
	Mon, 23 Mar 2026 09:14:53 +0800 (CST)
Received: from kwepemj200013.china.huawei.com (unknown [7.202.194.25])
	by mail.maildlp.com (Postfix) with ESMTPS id F0A8D40567;
	Mon, 23 Mar 2026 09:20:59 +0800 (CST)
Received: from huawei.com (10.50.85.155) by kwepemj200013.china.huawei.com
 (7.202.194.25) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.1544.11; Mon, 23 Mar
 2026 09:20:59 +0800
From: Li Lingfeng <lilingfeng3@huawei.com>
To: <trondmy@kernel.org>, <anna@kernel.org>, <jlayton@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<chengzhihao1@huawei.com>, <houtao1@huawei.com>, <yi.zhang@huawei.com>,
	<yangerkun@huawei.com>, <zhangjian496@h-partners.com>,
	<lilingfeng@huaweicloud.com>, <lilingfeng3@huawei.com>
Subject: [PATCH] NFS: stop trying writing page after getting -EBADF
Date: Mon, 23 Mar 2026 09:16:30 +0800
Message-ID: <20260323011630.3547783-1-lilingfeng3@huawei.com>
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
 kwepemj200013.china.huawei.com (7.202.194.25)

We encountered an infinite loop in nfs_writepages. The process is as
follows:

nfs4_do_reclaim
 nfs4_reclaim_open_state
  __nfs4_reclaim_open_state // get -ESTALE
  nfs4_state_mark_recovery_failed
   nfs4_state_mark_open_context_bad
    set_bit // NFS_CONTEXT_BAD

wb_workfn
 wb_do_writeback
  wb_writeback
   writeback_sb_inodes
    __writeback_single_inode
     do_writepages
      nfs_writepages // loop here
       write_cache_pages
        nfs_writepages_callback
         nfs_do_writepage
          nfs_page_async_flush
           nfs_pageio_add_request
            nfs_pageio_add_request_mirror
             __nfs_pageio_add_request
              nfs_create_subreq
               nfs_page_create // return -EBADF

After a server restart, it may fail to recognize file handles sent by the
client and return -ESTALE. As a result, the client sets NFS_CONTEXT_BAD in
nfs_open_context.

During the writeback of dirty pages, the presence of NFS_CONTEXT_BAD
causes -EBADF to be returned. Since NFS_CONTEXT_BAD is not cleared and
-EBADF is treated as a non-fatal error, nfs_writepages() keeps retrying
and eventually falls into an infinite loop.

Exit the loop when -EBADF is encountered to avoid this issue.

Fixes: c6fd3511c339 ("NFS: Further fixes to the writeback error handling")
Link: https://lore.kernel.org/all/64fecc88-6b11-4fdf-a26f-271c4445be1a@huawei.com/
Signed-off-by: Li Lingfeng <lilingfeng3@huawei.com>
---
 fs/nfs/write.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1ed4b3590b1a..608b299b1613 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -692,7 +692,7 @@ int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 		nfs_pageio_complete(&pgio);
 		if (err == -EAGAIN && mntflags & NFS_MOUNT_SOFTERR)
 			break;
-	} while (err < 0 && !nfs_error_is_fatal(err));
+	} while (err < 0 && !nfs_error_is_fatal(err) && (err != -EBADF));
 	nfs_io_completion_put(ioc);
 
 	if (err > 0)
-- 
2.52.0

