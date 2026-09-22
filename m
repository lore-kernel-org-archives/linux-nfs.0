Received: from pdx-out-007.esa.us-west-2.outbound.mail-perimeter.amazon.com (pdx-out-007.esa.us-west-2.outbound.mail-perimeter.amazon.com [52.34.181.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87AA446982F;
	Tue, 22 Sep 2026 17:57:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=52.34.181.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790099831; cv=none; b=UNmSTPAm/x9EjnFoNxVQecabKVXV3oTYcZYy4pQeVKp3B2nWr+in49J8db8bALx5VfnP3wTeJfrE5tk1b6xADeXIhchfFIg49idbnJDgHo4JqAy12KAKnOwfhmE0WxTqN3cg/c37fzd9wVF4y2kUlZ/vv1Udz9eog83rF3LP5Xg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790099831; c=relaxed/simple;
	bh=Q8au4sTrqz4YIvyNguOhIkoAy69QlyaYpnbwvs4cJl0=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=LB2VaRsbx/8bZ2oNp1YyFiZtjy6LVGRIUXmajw6d1kdCzeSmWE5n8a97/EbUJj4J4EhHosmPoFyz2VZ/q7z76c/BxSqrVQdjvuK9KJrofZWoqvF3v5WQces440SW4HekpkJHVcqrH4CjHspXrXMcNM20TrmUuSPjfqpStOxjbRk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com; spf=pass smtp.mailfrom=amazon.com; dkim=pass (2048-bit key) header.d=amazon.com header.i=@amazon.com header.b=jHiQvgsv; arc=none smtp.client-ip=52.34.181.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amazon.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amazon.com header.i=@amazon.com header.b="jHiQvgsv"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazoncorp2;
  t=1790099830; x=1821635830;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=qN5XnQIzCII0JvDnuh1uh6pvZD1IP2URc4wRLzLGKJM=;
  b=jHiQvgsv0RB7uk1x0PbZzoLJovD+FH8fpBWUfZ76ulEP/AN9Jg3dxUMO
   dZWy1H1DJQgigwr7acXfkTFxrMyMibnsYu62dFli1kHsjAtfIGYUeYue2
   6r5VD6SdE6i2lWDPxpSaPytG4cnf7dOF9spb3xiTIWU0c/PEsTBKguOzc
   BJ2e9VrGStrXCA6cnMVGIy8fl+g/STflcBeMFmVD7/azqDoBiku/JLane
   T8Juu7pxvjS+wuAIxcQX7Aod8tRVGvHvVSqAT2KSqL45OjDm8Tkc5Grrw
   V0pHVV5XYUU1rAagw98YP68WfMbFHuEZ00/GXdilfzjge0w2hhqzCRWHY
   w==;
X-CSE-ConnectionGUID: JYPe3dSdRE2Jst86+ehwXA==
X-CSE-MsgGUID: Ghgc5jPVTNiP74Z4PG1YBg==
X-IronPort-AV: E=Sophos;i="6.27,116,1787011200"; 
   d="scan'208";a="29355524"
Received: from ip-10-5-12-219.us-west-2.compute.internal (HELO smtpout.naws.us-west-2.prod.farcaster.email.amazon.dev) ([10.5.12.219])
  by internal-pdx-out-007.esa.us-west-2.outbound.mail-perimeter.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 22 Sep 2026 17:57:10 +0000
Received: from EX19MTAUWB001.ant.amazon.com [205.251.233.51:27790]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.5.10:2525] with esmtp (Farcaster)
 id 7f634d42-ea37-4bd3-8072-578b37438cbd; Tue, 22 Sep 2026 17:57:09 +0000 (UTC)
X-Farcaster-Flow-ID: 7f634d42-ea37-4bd3-8072-578b37438cbd
Received: from EX19D001UWA001.ant.amazon.com (10.13.138.214) by
 EX19MTAUWB001.ant.amazon.com (10.250.64.248) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.49;
 Tue, 22 Sep 2026 17:57:09 +0000
Received: from dev-dsk-jamz-1e-e35f4cd9.us-east-1.amazon.com (10.189.35.140)
 by EX19D001UWA001.ant.amazon.com (10.13.138.214) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.49;
 Tue, 22 Sep 2026 17:57:08 +0000
From: Jimmy Zuber <jamz@amazon.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: NeilBrown <neilb@ownmail.net>, <linux-nfs@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>
Subject: [PATCH RESEND] NFS: Fix stale negative cache on failed nfs_mkdir()
Date: Tue, 22 Sep 2026 17:56:56 +0000
Message-ID: <20260922175656.2833041-1-jamz@amazon.com>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: EX19D037UWC004.ant.amazon.com (10.13.139.254) To
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

Resend of:
https://lore.kernel.org/linux-nfs/20260819015111.2743908-1-jamz@amazon.com/

No change to the patch itself; rebased onto v7.3-rc4 and Cc'ing NeilBrown as
the author of the Fixes: commit.  nfs_mkdir() in v7.3-rc4 still returns the
error without unhashing @dentry, and vfs_mkdir()'s error path only calls
end_creating()/end_dirop(), which unlocks the parent and dputs the dentry, so
the hashed negative dentry survives in the dcache.

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
index 49394123b..a26c459ff 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2490,6 +2490,8 @@ struct dentry *nfs_mkdir(struct mnt_idmap *idmap, struct inode *dir,
 	trace_nfs_mkdir_enter(dir, dentry);
 	ret = NFS_PROTO(dir)->mkdir(dir, dentry, &attr);
 	trace_nfs_mkdir_exit(dir, dentry, PTR_ERR_OR_ZERO(ret));
+	if (IS_ERR(ret))
+		d_drop(dentry);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(nfs_mkdir);

base-commit: c4e9f74da4389a6b3e505d329d99232915a6b9cd
-- 
2.50.1

