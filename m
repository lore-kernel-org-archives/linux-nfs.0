Received: from pdx-out-012.esa.us-west-2.outbound.mail-perimeter.amazon.com (pdx-out-012.esa.us-west-2.outbound.mail-perimeter.amazon.com [35.162.73.231])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 55B9134A794;
	Wed, 19 Aug 2026 01:51:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=35.162.73.231
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787104285; cv=none; b=fsLd30S5OjSsJzoqnxj8CC7E+uZFiZ79tsVDd9NnidJIACIH663oo2YKPAONd0vtAHX52NKy19y7jFMmuXSIJavZ7oSrpLPOhgy09F03Ra1PsZfcVgiJh11z/rASOFujTeRRzuYr9b3XXeb7fgNmz0AlNCFJAjc0mjMPx2JdGcY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787104285; c=relaxed/simple;
	bh=TtDXPjSQgh6eXszht/Uw0nqmkVVPuouayoXzs+66SyQ=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=SVXXgtWukDMHIKuR224VgwTJWO9TsY98cvDs/pVp9MmOiXj+NN4uKUR8Oo3WHwnuxEgk0yi6OYeyDm8B3IKysnLkVM2pK3IQGO3VyIj4heQ4vERDujjEgfxLWKnvW8lyKG0CxgwaKRT0wN1LPlOxK+ipSkGCKxdyaYMXl7NVPyk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com; spf=pass smtp.mailfrom=amazon.com; dkim=pass (2048-bit key) header.d=amazon.com header.i=@amazon.com header.b=mbFNXNKK; arc=none smtp.client-ip=35.162.73.231
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amazon.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amazon.com header.i=@amazon.com header.b="mbFNXNKK"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazoncorp2;
  t=1787104284; x=1818640284;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=fNFxyzwXx4egvQoky0aNg43HXU0YoaIERl3Va15WIPc=;
  b=mbFNXNKKMawYQVELEmD/knWjYNxI0V8pPz7IM7tKG6P7p4AgfVM5KOm/
   J40Eijw5mX5As1qc8CsHXB+a5CuUNZsih5xOi49qCJYNg2sFf37JR+LRC
   rLX8YK3odVAhhc84Vx2HA/sNAhCIkosNMB5mDat4UK/NYAuPpCI/S+XCx
   jE+r7uofy3qOFZD0B9iu/oqp3YNRn6KwASPF699VPfYYhJflZF5A3yu8M
   JDb7iVK1jj2IycFti+PsVEB585GVJV6jOkh3de8UE+hKyDOTYkAjUEBEK
   Ql3QNf/VnjV1LZpuQi9ysnCNhiqbFJOIWzSgm8J5Br680PJGpyEbik03u
   w==;
X-CSE-ConnectionGUID: XJWysQakTC6E3yob1hOB7w==
X-CSE-MsgGUID: TJN4JoM3QT2FFxDRfTRyqg==
X-IronPort-AV: E=Sophos;i="6.25,230,1779148800"; 
   d="scan'208";a="26129028"
Received: from ip-10-5-6-203.us-west-2.compute.internal (HELO smtpout.naws.us-west-2.prod.farcaster.email.amazon.dev) ([10.5.6.203])
  by internal-pdx-out-012.esa.us-west-2.outbound.mail-perimeter.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 19 Aug 2026 01:51:24 +0000
Received: from EX19MTAUWB002.ant.amazon.com [205.251.233.111:25548]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.2.175:2525] with esmtp (Farcaster)
 id 631cbdfd-0931-4b71-8847-bb25d97b3089; Wed, 19 Aug 2026 01:51:23 +0000 (UTC)
X-Farcaster-Flow-ID: 631cbdfd-0931-4b71-8847-bb25d97b3089
Received: from EX19D001UWA001.ant.amazon.com (10.13.138.214) by
 EX19MTAUWB002.ant.amazon.com (10.250.64.231) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.45;
 Wed, 19 Aug 2026 01:51:23 +0000
Received: from dev-dsk-jamz-1e-e35f4cd9.us-east-1.amazon.com (10.189.35.140)
 by EX19D001UWA001.ant.amazon.com (10.13.138.214) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.45;
 Wed, 19 Aug 2026 01:51:22 +0000
From: Jimmy Zuber <jamz@amazon.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: [PATCH] NFS: Fix stale negative cache on failed nfs_mkdir()
Date: Wed, 19 Aug 2026 01:51:11 +0000
Message-ID: <20260819015111.2743908-1-jamz@amazon.com>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: EX19D036UWB001.ant.amazon.com (10.13.139.133) To
 EX19D001UWA001.ant.amazon.com (10.13.138.214)

Since commit 8376583b84a1 ("nfs: change mkdir inode_operation to return
alternate dentry if needed"), nfs_mkdir() no longer drops the dentry on
RPC failure.  A negative cache value can then result in spurious ENOENT
results for further operations within that directory, such as open or
stat.

We observed this breaking some applications where an EEXIST on mkdir
caused the application to assume the directory to exist, only to fail
operations within that directory due to the retained negative cache
entry.  The other create paths, nfs_create() and nfs_mknod(), still drop
the dentry on failure.  This patch restores the previous behavior.

Fixes: 8376583b84a1 ("nfs: change mkdir inode_operation to return alternate dentry if needed")
Cc: stable@vger.kernel.org # v6.15+
Signed-off-by: Jimmy Zuber <jamz@amazon.com>
---

We reproduced this against a local knfsd export over NFSv4.1.  The export is
mounted several times with "nosharecache" so that each mount acts as an
independent client with its own dcache:

  # /etc/exports
  /srv/nfs 127.0.0.1(rw,sync,no_subtree_check,no_root_squash,fsid=0)

  for i in $(seq 0 5); do
      mount -t nfs4 -o vers=4.1,nosharecache,acdirmin=30,acdirmax=60 \
          127.0.0.1:/ /mnt/nfs$i
  done

For each of 40 new cache/<id> directories, every mount stats the directory to
seed a negative entry, then all mounts race to mkdir it.  The winner writes a
file and renames it, and the losers that got EEXIST then read that file back.
On a vanilla v6.17 kernel, the 200 loser reads were:

  unpatched:   read OK   0 / ENOENT 200
  patched:     read OK 200 / ENOENT   0

 fs/nfs/dir.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index d812179..f0b493a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2437,6 +2437,8 @@ struct dentry *nfs_mkdir(struct mnt_idmap *idmap, struct inode *dir,
 	trace_nfs_mkdir_enter(dir, dentry);
 	ret = NFS_PROTO(dir)->mkdir(dir, dentry, &attr);
 	trace_nfs_mkdir_exit(dir, dentry, PTR_ERR_OR_ZERO(ret));
+	if (IS_ERR(ret))
+		d_drop(dentry);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(nfs_mkdir);
-- 
2.51.0

