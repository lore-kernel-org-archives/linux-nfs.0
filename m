Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 149472C15B0;
	Sat, 23 May 2026 17:55:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779558956; cv=none; b=m68OuzQtWzJuT+8XvrEUZA8Xm/sC/S9fHOD4/49MzOY1q+0wreSOQa8gC9fT3RL6da9Y9UrBYRoJta8m8pVEnYzVHzEMqF8mfGah9JlceHAeERn7NWvFdU/vCtrVFVTDfbtYo976pZGa0tnqqxJeeEKWPtUFC8Y3b460jHZnGdI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779558956; c=relaxed/simple;
	bh=Wc2c8NjQ+LPTgG9EiPkpP4Thodyo3z11bkVysTs8d9M=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Zts9ULdzvrFqdeCGn4L6oimFZgXxcNjueLB5tXsU4ygxeZxHgsm0zkPsj8r5LWG61CvsAtxxDNhUB7OScFdI7BVQwQD7otiCr1vQ7+eB2a3Bd6QK0s/GqKoIKiDG0MIko6IecflnWKe0CGMXH2ds0PRxCXjuC5dssMCuJI3qFk8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FEaGA2By; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FEaGA2By"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BE1771F000E9;
	Sat, 23 May 2026 17:55:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779558954;
	bh=SxGF956OZDQJ04Ha1BVCIxFwqpuZT0QUw7PeeB2x8ho=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=FEaGA2ByUVUb4gzO0lRcyjGQi2EY/wCi4EyO6v8VtYTBWBx6YG7dKrg4vMqbF1ooV
	 WAUaxnU8AOp55vwtaP+3UQP9ccPWXV7xJpiq77GZF4K+RZRJH0UgOJsTSQrvBD4P6G
	 TnjCadP00pKGHQhzbjpVokPQrVZFpNTOwTpF3hLxUvaiX3A9L7Tq8RWx83HlFJyaBt
	 QEFNZTjsw+5/uNOPM2Bcb8E5O+3sF5zx3jplBNPReyTS53Zy8H+j6tiGYQb8h8G1Kg
	 646TOOJKUKfrQ3su+L3yeG4CfdpIKRXcovoEsdUEqQJhDFky4dSvKqdEKX99RF4YJY
	 NJA9X4Sl9FkZQ==
From: "Mike Rapoport (Microsoft)" <rppt@kernel.org>
Date: Sat, 23 May 2026 20:54:22 +0300
Subject: [PATCH 10/17] jbd2: replace __get_free_pages() with kmalloc()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260523-b4-fs-v1-10-275e36a83f0e@kernel.org>
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

jbd2_alloc() falls back from kmem_cache_alloc() to __get_free_pages() for
allocations larger than PAGE_SIZE.
But kmalloc() can handle such cases with essentially the same fallback.

Replace use of __get_free_pages() with kmalloc() and simplify
jbd2_free() as both kmem_cache_alloc() and kmalloc() allocations can be
freed with kfree().

Signed-off-by: Mike Rapoport (Microsoft) <rppt@kernel.org>
---
 fs/jbd2/journal.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index 4f397fcdb13c..1137b471e490 100644
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -2784,7 +2784,7 @@ void *jbd2_alloc(size_t size, gfp_t flags)
 	if (size < PAGE_SIZE)
 		ptr = kmem_cache_alloc(get_slab(size), flags);
 	else
-		ptr = (void *)__get_free_pages(flags, get_order(size));
+		ptr = kmalloc(size, flags);
 
 	/* Check alignment; SLUB has gotten this wrong in the past,
 	 * and this can lead to user data corruption! */
@@ -2795,10 +2795,7 @@ void *jbd2_alloc(size_t size, gfp_t flags)
 
 void jbd2_free(void *ptr, size_t size)
 {
-	if (size < PAGE_SIZE)
-		kmem_cache_free(get_slab(size), ptr);
-	else
-		free_pages((unsigned long)ptr, get_order(size));
+	kfree(ptr);
 };
 
 /*

-- 
2.53.0

