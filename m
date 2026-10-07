Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 965FC4C8C7F;
	Wed,  7 Oct 2026 16:47:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791391624; cv=none; b=C01wEm7ftwEmce9JFxcqih6bdFKVi+k7dGVv8lRDc+fnXaezmhTGVXLG3CXRfp37E/INCZ1I+RNzURygm7joVO8MaPBRIvdTnykDJ2eogCaAI7RNtSGdO8sJHfbYM62WqIQC8g0be8lYG3DvcEwrWIyTVKG+iBgmPBzLo4xtDHs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791391624; c=relaxed/simple;
	bh=UDEoScXYF15E3dSfKLAG951R79iypGD5ioltqZqLIGc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=IpUNNz5wbMM5ePBS39h/JBI2azarjokryEwAfmu3eJ3Ks0tR3wEU3nMecP0TM6SqRsoASRBEMXB0Nz46yyr408pgq9bxRHCtUri+Vbgi6JUAhaAZvNlvAgKGBXt7ufZEr0mv+JO28wjSaC6r+/ISqsoLYCMRWFvpttc/4LOiFfY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lWQcl+Je; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lWQcl+Je"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 64E911F000FF;
	Wed,  7 Oct 2026 16:46:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791391620;
	bh=OQCrU6qUkSE8sMyp6oyyMuXZKJibWCFEgOm4GSgBmlY=;
	h=From:To:Cc:Subject:Date;
	b=lWQcl+JeS3uD6vwJuTyFqRIx9B7hqDtinG91cih4dbHB/FQSmDqLTuA8QmgPCEPi6
	 2mdzmdE7Y4goaaekYE2dBUKcdbZFClXXuJzOW8iZWlXCzB6G7+q4KpgUlbsiM+TEEo
	 YBGg5Gvs9oB8ewz26qCx73RVAI/ckA7bq8CGf+0LU2Xur02sRAkqPdi2/zG7/OTk/h
	 Ff+ww/WuQRHZNX7zmejjXCNmBUGxwFdEi/NkTe3osgql9nkiJuMzJsv6PPUFh8iloX
	 Rpg3LJ4PzAbixgj9KsVwKDXcRiDoxBdNxgisA4P37JZa5hTU1tw4ebbIlfVoHnxL5o
	 7z8ttk+1ixTKA==
From: Chuck Lever <cel@kernel.org>
To: Danny@lightningiq.io,
	Christian Brauner <brauner@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Amir Goldstein <amir73il@gmail.com>
Cc: <linux-fsdevel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>,
	Danny Pidutti <danny_pidutti@hotmail.com>
Subject: [PATCH] exportfs: Release the get_name() directory file synchronously
Date: Wed,  7 Oct 2026 12:46:48 -0400
Message-ID: <20261007164648.50493-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

get_name() opens the parent directory with dentry_open() and
releases it with fput(). From a kernel thread, fput() defers the
final __fput() to the delayed_fput work item. NFSD threads are
kernel threads, and NFSD reaches get_name() through
exportfs_decode_fh() whenever a file handle's dentry is not
connected to the root.

On a filesystem with more directories than the dcache retains,
nearly every READDIRPLUS needs a reconnect. The deferred releases
arrive faster than the work item retires them, and each pending
file pins the directory's readdir state. On ext4 that state is the
htree fname cache for the last leaf block read. A 64-thread NFSv3
server under a parallel tree walk showed unreclaimable slab growing
by about 90 MB per second, and the same workload on a 5.15 kernel
ended in a global OOM.

Commit 5ff318f645eb ("nfsd: use __fput_sync() to avoid delayed
closing of files.") stopped NFSD's own closes from feeding the
delayed_fput queue but did not cover the exportfs reconnect path.

Release the file with __fput_sync(). get_name() opened the file
itself, read-only, on a directory, so __fput() involves nothing
that could wait on the caller.

Fixes: 4a9d4b024a31 ("switch fput to task_work_add")
Reported-by: Danny Pidutti <danny_pidutti@hotmail.com>
Closes: https://lore.kernel.org/linux-fsdevel/DS4PR04MB9846BA3C16BC5ACED8B589228D952@DS4PR04MB9846.namprd04.prod.outlook.com/
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/exportfs/expfs.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Mail from kernel.org to hotmail.com was rejected. kernel.org appears
to be on some deny-list. Reposting.


diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index eafd99507afe..b5768f94fbb5 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -336,7 +336,11 @@ static int get_name(const struct path *path, char *name, struct dentry *child)
 	}
 
 out_close:
-	fput(file);
+	/*
+	 * @file is the read-only directory opened above, so __fput()
+	 * cannot block on anything the caller holds.
+	 */
+	__fput_sync(file);
 out:
 	return error;
 }
-- 
2.55.0

