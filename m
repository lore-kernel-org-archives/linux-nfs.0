Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CCDF43A5E8F
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 18:57:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790621875; cv=none; b=GBLJbAPGqmPKlGhyT/CuQb24UjK5FluQXsHUAS1qvVvx4GXUqH7exQszc8bPl7ira/wQ3y9AfUTCjkKE2lo1vBgWVEhMyil9QxfCLSV1QB7j8roPOV/meEu6lDvjfPubrUY7TwhmAjdapiM6koiHkGGi5WhXdaUJDAlexOjFHzM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790621875; c=relaxed/simple;
	bh=j6vzvFLksc0MO2MMQFwkF9VpkyeYXrKzELEhOZ8Tzqg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=UJLsZvLQd2EBLx141FwjuePHxT+ZBMl3fHuOnAUMRYPBbtm/+W9h5GotSnaChonUlB3vsVGQIoXa4vzHtNJq7wqxxso1+mr1y2ERf22NkwFtNE1YjW7Dyfa0qWeUm4FQI5/FIu54jfEvOJz1tEFerscpBR56g+/dEoPBqzw+hAY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ksRup1J+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ksRup1J+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1DF061F000FF;
	Mon, 28 Sep 2026 18:57:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790621873;
	bh=2wWatpmTOgnFUxaDvQ864hYp1/5VkGpZgY4QQcfVjOI=;
	h=From:To:Cc:Subject:Date;
	b=ksRup1J+hQlwjN1zGX+5QhnArd0BUWGRIYhGOAmloPnbclN5NRSVHKoWkyl+h1dUx
	 e5B9IqMML9TwNo7BSbPdioGzB6QSTbOTW/TPxkNMYLy1QC4ARFdthjcBljyIJrJdWI
	 ZYb0CAhpBEhPUYVQpVK/GhKi2Myp0jF9gXLk3Iy0ZOGgaov5rRTp3v+HpQIwOjMojo
	 qCSOh3iMeeeR2zUIua2H+2FFe6NbLweaFRMmxJ+xD/lgrdK+K1nB68s7mXIyGj0v4j
	 wUa3AMXwBAfdy1lRQNUOSwstygxNN4hgs1TIpi6O958ZV6yCuXbi2c6pt2UYqoTH3x
	 h+D0ON0ej+Zxg==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] NFS: don't release an open context from writeback
Date: Mon, 28 Sep 2026 14:57:48 -0400
Message-ID: <20260928185751.98682-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

v1 deferred the final deactivate_super() in nfs_sb_deactive() to nfsiod:
https://lore.kernel.org/linux-nfs/20260911184239.90154-1-snitzer@kernel.org/

Feedback on v1 was that it worked around the problem rather than fixing
it. That is fair: v1 made the last step of releasing an open context
safe to run from writeback, when the problem is that writeback releases
the open context at all. Testing bears that out, see below: with v1
applied the flusher still deadlocks, one step earlier, on I_SYNC.

Releasing an open context closes NFSv4 state and drops what may be the
last reference to the dentry, the inode and the superblock. The flusher
holds sb->s_umount and has set I_SYNC on the inode, so it can end up
waiting for itself on either. Writes normally avoid this because their
requests are released by the RPC release callback, on nfsiod. This
series fixes the three ways writeback does not:

Patch 1: a write that fails before it is sent is completed by
nfs_write_error() in the submitter. This is the deadlock that was hit
in the field, on a client whose server began returning AUTH_TOOWEAK.

Patch 2: nfs_initiate_pgio() and nfs_initiate_commit() drop their task
reference with rpc_put_task(), which runs the release callback in the
submitter if the task has already completed. This is the deadlock that
NeilBrown reported in 2014:
https://lore.kernel.org/linux-nfs/20140407135001.56ef9f36@notabene.brown/

Patch 3: the asynchronous LAYOUTCOMMIT that ->write_inode() sends has
the same problem as patch 2, with an inode and superblock reference of
its own in place of an open context, and no workqueue at all.

All three move the release to nfsiod, where every other write already
does it. None changes how or when a filesystem is shut down, and
nfs_sb_deactive() is left as it is.

Testing: NFSv3 over loopback, with a test-only knob that makes
nfs_do_writepage() see -EACCES in the pageio descriptor. Dirty a file
through a mapping after closing it, unmount, and let the periodic
flusher write it back. A plain umount is enough to leave the write
requests as the only thing keeping the superblock alive.

                  plain file           sillyrenamed file
  v1              shuts down, from     flusher hangs in evict(),
                  v1's work item       waiting for I_SYNC

  this series     shuts down, from     shuts down, from the release
                  the context's        of the sillyrename REMOVE
                  work item

Patches 2 and 3 close races and were not exercised by this test.

Changes since v1:
- Dropped "NFS: defer the final superblock deactivation".
- Fix the three places that release such references from writeback
  instead.
- Patch 1 carries a Fixes: tag; v1 had none.

Mike Snitzer (3):
  NFS: don't release the open context of a failed write from writeback
  NFS: don't run the release of a WRITE or COMMIT in the submitter
  NFSv4/pnfs: don't run the release of a LAYOUTCOMMIT in the submitter

 fs/nfs/inode.c         | 37 ++++++++++++++++++++++++++++++++++---
 fs/nfs/internal.h      |  1 +
 fs/nfs/nfs4proc.c      |  7 ++++++-
 fs/nfs/pagelist.c      |  3 ++-
 fs/nfs/write.c         |  8 +++++++-
 include/linux/nfs_fs.h |  2 ++
 6 files changed, 52 insertions(+), 6 deletions(-)


base-commit: 82e951e8628cdc0a5434c6f71ff1566b20e9912c
-- 
2.52.0

