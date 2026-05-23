Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8699304972;
	Sat, 23 May 2026 17:56:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779558970; cv=none; b=cVeNyTmX5cKW82dz7g/6j+5MUD8JNx5yeRcIfktUpiI5CFnostwmq7q7NyPdDOXjPIo+zSf4XVt+JCiBj5Ap44J02tatN4qOHy/72lHi6wlkbnISzj0mtZk18VMloHz7bRHp1j19aKC5LsoUksL04lA6H6C+a5q4/SUaK0f54Q0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779558970; c=relaxed/simple;
	bh=1YSi5Q/4duH3X1f3c7sxJDgLdO0ztZpaoXFiqR71EUU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=JZwTAnAxIyw6FQINrOV+aI2i0Lzy4MlMnCFg1bGVRd7UVoHpBjiZgLI+t8vAWVMhkt6Vu0LqvEZMlYovRwCoJnoz2sDnmHsHORZODMUlPJDIBMXkIbHyQaXjiXxU+5vG1yW0VV0K+aCwEOVyiDRp1H2F7eHM/p8LxprelNmnj8g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Vemu1kcE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Vemu1kcE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B60BA1F000E9;
	Sat, 23 May 2026 17:56:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779558969;
	bh=jKo+LttHIUD1A+iCHOd4XzHNPdNF0nPTlnjXQ41S2wE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Vemu1kcEUmxAiAsIh4TQkBUpCC3eZFLAlCkzcG0Ph2QDZmgnFcsh7HLo7bRLypN8a
	 4O7sRSwfz2Si3bQK2prGFIm51brNn7HbhUaf390IGY4RTpOK9E8GLQB8JKv3yIPy0B
	 3OdF2356XNi2W9iVTCP19aIpZ2waAUBqPL7ZzV+8B2EMdYa3X/q7R3kTltzAJrZtQ4
	 tRoFYGSZ+KINhrDUrwdsnLgD0fHos/wX1o4WYbKLoqZlRnjjBayViPqjymIH+D+ySn
	 8Bt6vC1T0wx8wpclGTNSjEIacKIfZ77fy2GThGy2IPX0jx4CLFYSPKZfbwpZORl5W9
	 3GQkT9VAlRXUA==
From: "Mike Rapoport (Microsoft)" <rppt@kernel.org>
Date: Sat, 23 May 2026 20:54:24 +0300
Subject: [PATCH 12/17] fuse: replace __get_free_page() with kmalloc()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260523-b4-fs-v1-12-275e36a83f0e@kernel.org>
References: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
In-Reply-To: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
To: Jan Kara <jack@suse.com>, Mark Fasheh <mark@fasheh.com>, 
 Joel Becker <jlbec@evilplan.org>, Joseph Qi <joseph.qi@linux.alibaba.com>, 
 Ryusuke Konishi <konishi.ryusuke@gmail.com>, 
 Viacheslav Dubeyko <slava@dubeyko.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
 Dave Kleikamp <shaggy@kernel.org>, Theodore Ts'o <tytso@mit.edu>, 
 Miklos Szeredi <miklos@szeredi.hu>, 
 Andreas Hindborg <a.hindborg@kernel.org>, Breno Leitao <leitao@debian.org>, 
 Kees Cook <kees@kernel.org>, 
 "Tigran A. Aivazian" <aivazian.tigran@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 ocfs2-devel@lists.linux.dev, linux-nilfs@vger.kernel.org, 
 linux-nfs@vger.kernel.org, jfs-discussion@lists.sourceforge.net, 
 linux-ext4@vger.kernel.org, linux-mm@kvack.org, 
 "Mike Rapoport (Microsoft)" <rppt@kernel.org>
X-Mailer: b4 0.15.2

fuse_do_ioctl allocates memory for struct iov array using
__get_free_page().

kmalloc() is a better API for such use and it also provides better
scalability and more debugging possibilities.

Replace use of __get_free_page() with kmalloc().

Signed-off-by: Mike Rapoport (Microsoft) <rppt@kernel.org>
---
 fs/fuse/ioctl.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/fuse/ioctl.c b/fs/fuse/ioctl.c
index fdc175e93f74..3614ea603913 100644
--- a/fs/fuse/ioctl.c
+++ b/fs/fuse/ioctl.c
@@ -10,6 +10,7 @@
 #include <linux/fileattr.h>
 #include <linux/fsverity.h>
 
+#include <linux/slab.h>
 #define FUSE_VERITY_ENABLE_ARG_MAX_PAGES 256
 
 static ssize_t fuse_send_ioctl(struct fuse_mount *fm, struct fuse_args *args,
@@ -252,7 +253,7 @@ long fuse_do_ioctl(struct file *file, unsigned int cmd, unsigned long arg,
 
 	err = -ENOMEM;
 	ap.folios = fuse_folios_alloc(fm->fc->max_pages, GFP_KERNEL, &ap.descs);
-	iov_page = (struct iovec *) __get_free_page(GFP_KERNEL);
+	iov_page = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!ap.folios || !iov_page)
 		goto out;
 
@@ -400,7 +401,7 @@ long fuse_do_ioctl(struct file *file, unsigned int cmd, unsigned long arg,
 	}
 	err = 0;
  out:
-	free_page((unsigned long) iov_page);
+	kfree(iov_page);
 	while (ap.num_folios)
 		folio_put(ap.folios[--ap.num_folios]);
 	kfree(ap.folios);

-- 
2.53.0

