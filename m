Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4CF99418361
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 15:02:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787670132; cv=none; b=GJ7Yh7Y1pkW6cQuMhRuoeaNI/QAPazIdxKa+2QdnxRt8knAXhk+RAsNfUdnvDJJ/AtqPWtZV/eCVWDSsjNEaEx2SgxYprH+I8tCgGYRtsf6fkCZ2rY6mk4CMiKkkMeTyzsiq34qYD5n2ntcAEZRZjDAEVrLgKys0DU5DbYaqyuY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787670132; c=relaxed/simple;
	bh=z7WInaHYApO6mdUR/VH/uNoG3D4aQUlC55Aex0Q9x/s=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=JHQ5p9z1BGRf+2Jbh1gVljknm2N8it32J6ovX2W8jJOYXmsdJRlXvF3EQj6rtqaEWSNTRvsJLz/VyxpFiD7eVt6u0TH0WWFDM8Qhlly5Kj/5wcJCHH8UyXEVsK5DmPy3AiD7xP/pg/FyL8F03Ny2dogA7k+hnb78XoaCFsGS8ik=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bMmVXl/y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bMmVXl/y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7E7E71F00A3D;
	Tue, 25 Aug 2026 15:02:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787670130;
	bh=YI3sDaBBouFuwjjyCe99fTqUYOOS+O8MN4CY3++V52s=;
	h=From:To:Cc:Subject:Date;
	b=bMmVXl/y60V34/UCa42EZkI3k+oYZU65r5rHjDSlgCVBiB8ylHfM0y07N3CNTwPbh
	 0E+xuH71LhpIvv+t5TlrI5swSNAgafP1fKmzT/sqbuiC0EUP0XXgzpItyGtvOyJOGY
	 vMcRXyfo4fKu8y0exQelUI2JOHp8U/q5bQSycGLqawUVpQlxvwEt2D9ux/TRt9NwQb
	 NOeprfhV2BlwTM+RXb/bKFgk8B81b1i2xOL8dIswoYGFui1lodMF+xVlCoCIbeFjBn
	 UCQ2GvQf5mP14sTor0CaoRi7ARtiY2NmR380U0cOFL4vA/J2aPHDVFKHYU+9iE2yA5
	 o+UF5eM7AykBA==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v2 0/4] NFS: Add directory delegation support for CB_NOTIFY
Date: Tue, 25 Aug 2026 11:02:05 -0400
Message-ID: <20260825150209.694646-1-anna@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@hammerspace.com>

These patches add support for the CB_NOTIFY callback operation from NFS
servers. Editing directory order or placement in our caches isn't easy
or practical the way things are structured now. Instead, I use CB_NOTIFY
as an indication that the client needs to refresh its view of the
directory.

Changes in v2:
 * Fix signed / unsigned type mixups
 * Don't try to share lookup code between NOTIFY4_REMOVE and NOTIFY4_ADD
 * Add handling for the NOTIFY4_ADD 'na_have_old_entry' case

Thoughts?
Anna


Anna Schumaker (4):
  NFS: Add an outline for the CB_NOTIFY operation
  NFS: Add support for CB_NOTIFY4_REMOVE_ENTRY
  NFS: Add support for CB_NOTIFY4_ADD_ENTRY
  NFS: Add support for CB_NOTIFY4_RENAME_ENTRY

 fs/nfs/callback.h      |  51 ++++++++++++
 fs/nfs/callback_proc.c | 147 ++++++++++++++++++++++++++++++++++
 fs/nfs/callback_xdr.c  | 175 ++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4_fs.h       |   2 +
 fs/nfs/nfs4xdr.c       |  33 +++++++-
 include/linux/nfs4.h   |   6 ++
 6 files changed, 409 insertions(+), 5 deletions(-)

-- 
2.55.0

