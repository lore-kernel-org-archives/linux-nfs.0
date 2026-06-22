Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com [115.124.30.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98A01280A51;
	Mon, 22 Jun 2026 06:00:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782108050; cv=none; b=HUxQ8+3Q7WFqtSICsTFHhNuNvqFH8fSkdUPwEnft5VXyyhPjqCs+WvBE8inbKO7H2NoBoVH8PtYnD+K9Qn6OvEGS/IEIyZZKLT2hekbvQ6jWDzfgbeHHo2JPl/lRN9telgdVSXx+zYvQOX+aIMQpl7THvz/vYzEBweMnGdWOUGw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782108050; c=relaxed/simple;
	bh=yFn14TsG+dBdbYo22tsXRVY/GQie74Fiot4Ih0qR8OM=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=J+ItkLd90k58JOSDSAc04b6LFJ4blO0ZBHzr30DiB2u2sqgp9q8gGruCU7WdFVbOUUiKBgeoIq/BCCHwa8bmhtA73PDiBXJ9l3nQuo15oT4NKQx98VZEZ/Rrl3ZmayiUq+wZ12TM7gRfH+mMCUtYd3uPUKjerN/DXwKnF+5XhvQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=peEns2wI; arc=none smtp.client-ip=115.124.30.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="peEns2wI"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1782108039; h=From:To:Subject:Date:Message-Id:MIME-Version;
	bh=8QChs0znYXOzmMnPHkO1EpMOdyETth1B13Rh22KHUOg=;
	b=peEns2wIgqDcrFPkfSjRXgXHIo5aE2tzDPK/DL7XhSlfA0QC2fHO3lo5WTKbirzHl6yt4+mxQ7fGkri9ZQRxNmGli2GXZHEyY1LivAdN7lfnDc8fhtru4fj/VT9OASaBkJ05GyoZOd9aRnjxO6xwNbYpII/lF4KKGrJR+AgjG0Q=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R751e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037033178;MF=jefflexu@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0X5IYQD8_1782108038;
Received: from localhost(mailfrom:jefflexu@linux.alibaba.com fp:SMTPD_---0X5IYQD8_1782108038 cluster:ay36)
          by smtp.aliyun-inc.com;
          Mon, 22 Jun 2026 14:00:38 +0800
From: Jingbo Xu <jefflexu@linux.alibaba.com>
To: trondmy@kernel.org,
	anna@kernel.org,
	linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	joseph.qi@linux.alibaba.com
Subject: [PATCH] NFS: invalidate i_blocks after COMMIT to fix stale block count on NFSv4
Date: Mon, 22 Jun 2026 14:00:38 +0800
Message-Id: <20260622060038.13731-1-jefflexu@linux.alibaba.com>
X-Mailer: git-send-email 2.19.1.6.gb485710b
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

NFSv4 COMMIT compound does not include GETATTR, and nfs4_commit_done_cb
does not refresh inode attributes. Meanwhile, every WRITE marks
NFS_INO_INVALID_BLOCKS via nfs_post_op_update_inode_force_wcc_locked.

After COMMIT, i_blocks remains stale until the next stat() triggers a
full revalidation. In writeback-heavy workloads where COMMITs happen
without intervening stat() calls, the cached block count can stay
indefinitely wrong.

Mark NFS_INO_INVALID_BLOCKS on successful COMMIT completion so that the
next nfs_getattr requesting STATX_BLOCKS will issue a GETATTR with
SPACE_USED, fetching the correct value from the server.

This matches NFSv3 behavior where nfs3_commit_done already calls
nfs_refresh_inode with the wcc_data post-op attributes.

Reproduce with xfstests generic/694 on NFSv4.0 loopback:

  Server:
    mount /dev/vdc /data/test
    mount /dev/vdd /data/scratch
    exportfs -o insecure,rw,sync,no_root_squash,fsid=1 127.0.0.1:/data/test
    exportfs -o insecure,rw,sync,no_root_squash,fsid=2 127.0.0.1:/data/scratch

  Client:
    mount -t nfs -o vers=4.0 localhost:/data/test /mnt/test
    mount -t nfs -o vers=4.0 localhost:/data/scratch /mnt/scratch

  local.config:
    export TEST_FS_MOUNT_OPTS="-o vers=4.0"
    export MOUNT_OPTIONS="-o vers=4.0"
    export FSTYP=nfs
    export TEST_DEV=localhost:/data/test
    export SCRATCH_DEV=localhost:/data/scratch
    export TEST_DIR=/mnt/test
    export SCRATCH_MNT=/mnt/scratch

This fixes xfstests generic/694.

Assisted-by: Qoder:Qwen3.7-Max
Signed-off-by: Jingbo Xu <jefflexu@linux.alibaba.com>
---
 fs/nfs/write.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d7c399763ad9..88c5c9f7434c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1851,6 +1851,8 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 		/* Latency breaker */
 		cond_resched();
 	}
+	if (status >= 0)
+		nfs_set_cache_invalid(data->inode, NFS_INO_INVALID_BLOCKS);
 
 	nfs_init_cinfo(&cinfo, data->inode, data->dreq);
 	nfs_commit_end(cinfo.mds);
-- 
2.19.1.6.gb485710b

