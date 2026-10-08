Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5EC94A6CC0;
	Thu,  8 Oct 2026 14:09:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791468576; cv=none; b=Wgfn9PvOmjjnUipP8LUhUJLEh0qQTyJ0mvYkU+Vprwc9MqNEqwwZhziRRk/hAHrIGfsGD61gM8fFdJnYtEG6BBHWTubqQqwo6qitUf0WWOtIr8XVeXl0ZTwbn1DtXsPveZ+QgJZyaoIcXfDNBsCA7Q7IoKKe/rJSa2LNiVHxy8o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791468576; c=relaxed/simple;
	bh=v8qhE3icSlIdEpfnkG1TBLxjMWtC4XOdrj4gr0VgEp0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=r6w7fNHWOji6kts985aOgKrQlp0WfjZ04wDrmzKlYWkF20kDfDD53KkaLjSrYij7Amcj0EL9XTdttr4Uy7CDj8TcIopLKsp+80vlsmSZAyKo0HGpD/zxbGYMPVodKLA2XNhw/8fOdQk/+l8CXgpVSMMDZeQb3rk9VvmaQSzaaro=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nNlQz9B0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nNlQz9B0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A8DD91F000FF;
	Thu,  8 Oct 2026 14:09:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791468574;
	bh=ijFmE+eiP/D65HdFe9xO8hkVhOuxsCcTseHlv+OhInI=;
	h=From:To:Cc:Subject:Date;
	b=nNlQz9B0MiFbcC2yiYYybEm6CYZGprJ4Eyg/VYG7Kb2QsIJZQprZNdqJ2oqFquCld
	 jH/nWIae4zNyvftwpHu8Ip+eXxkX4k2ZCUvQAwTgfWtozk68ezNoK0nBiXJAMeubmP
	 LU0Ka1eqU5PAX/xpHUfXe8VGOASKxjSx++roUQS6UgDQpX+fbp85OuqWm8W/NYzC+X
	 /coKdqkzozTXdm6m+wsw3FIwp5RpxnETJeSVw8sAJ1e5gYSYz6ZnDPvBkWuLHrUHT8
	 dMm7/JDd5xEsrLVO1rMGoLEUN6NHd/8nU+jWC8uJWSH58lpj43FsBkFG8ulFFSeZp/
	 TGkv4Xr7zExZA==
From: Chuck Lever <cel@kernel.org>
To: Danny@lightningiq.io,
	Christian Brauner <brauner@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Amir Goldstein <amir73il@gmail.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: <linux-fsdevel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>,
	stable@vger.kernel.org,
	Danny Pidutti <danny_pidutti@hotmail.com>,
	Danny Pidutti <danny@lightningiq.io>,
	Benjamin Coddington <bcodding@hammerspace.com>
Subject: [PATCH v2] exportfs: Release the get_name() directory file synchronously
Date: Thu,  8 Oct 2026 10:09:03 -0400
Message-ID: <20261008140903.2784-1-cel@kernel.org>
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

Note for LTS backports: Kernels before v6.6 need the __fput_sync()
call guarded by current->flags & PF_KTHREAD, with a plain fput()
otherwise.

Fixes: 4a9d4b024a31 ("switch fput to task_work_add")
Cc: <stable@vger.kernel.org> # see above, needs adjustments for < v6.2
Reported-by: Danny Pidutti <danny_pidutti@hotmail.com>
Closes: https://lore.kernel.org/linux-fsdevel/DS4PR04MB9846BA3C16BC5ACED8B589228D952@DS4PR04MB9846.namprd04.prod.outlook.com/
Tested-by: Danny Pidutti <danny@lightningiq.io>
Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/exportfs/expfs.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Changes since v1:
- Add "Cc: stable" tag with annotation

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

