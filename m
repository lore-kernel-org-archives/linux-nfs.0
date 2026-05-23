Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A1B9A33F588;
	Sat, 23 May 2026 17:55:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779558933; cv=none; b=h8nyNguUacX3J+nfil7W6FiENPoMkcQz5SrGjN8YnruJUt20CsGuvW3VGMHGLUhEcPuKs8NJ7x8SMWCYo1o2TCxFd6I5lhQ65jITEYs5VKJJXVUU70k5QQ4DFEdiUyHvSuz9f5vBp3SAtEUj7p+caPwxMIMwdlYu6SYwsb0dPA0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779558933; c=relaxed/simple;
	bh=R3TwlcGQ9Xmi8vrOdCdmDCY7yPMZ24GcwIIOd+RcbTk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Xqv7weA4wTGoweo6aANvuqlrV9BhpoQknEEyKrfamhwack0fE8mtHrpBEj9Mb/IjOGxaSkdTVQxEHM5KC753o9YzoJ8Q9MLO5kaFmEqPzP1ixkEnJog+SCkOXMgvUhSJEi6PnDvEmrEgn5JXoC/y37aDxjOP0SvqhA92tOCrMP8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XHmgC1IK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XHmgC1IK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 50B621F00A3A;
	Sat, 23 May 2026 17:55:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779558932;
	bh=CZp/X5zLgPC9r1L7fUvb/ePIYWMAGoK4GAELkUrcd6A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XHmgC1IKsMvTM0+2evr64HcGx16lMmVQxeLsbzqY++DoYRk4cRBp7HalnPlBMftcC
	 SxgU0WB5nl4VEdUeM5DqdHgEmCtWE8ZmMoisQWZNGjx3UxyMH6kKnLIvIknCvqG78W
	 9DPcb0sWiVFHr4pXHDqNUdCcMRGeXhGZjXpcsRTFz3ktZ6U/o33frEVAMUboeAO80b
	 9PFdW5yU5Zt7qNf8QvoeVI82N62fOcPNRbE8s6REYzOHoqb2rMh7xwyEZKzOLHD1en
	 wFbmxmiRtlOWQQbHfw+BASgeYU4qs4yBf1qbPCNlkrIdRKKwbaAfuq5qUKC9ar0XYi
	 QbnnugkUrUatg==
From: "Mike Rapoport (Microsoft)" <rppt@kernel.org>
Date: Sat, 23 May 2026 20:54:19 +0300
Subject: [PATCH 07/17] NFSD: replace __get_free_page() with kmalloc() in
 nfsd_buffered_readdir()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260523-b4-fs-v1-7-275e36a83f0e@kernel.org>
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

nfsd_buffered_readdir() allocates a staging buffer with __get_free_page().

kmalloc() is a better API for such use and it also provides better
scalability and more debugging possibilities.

Replace use of __get_free_page() with kmalloc().

Signed-off-by: Mike Rapoport (Microsoft) <rppt@kernel.org>
---
 fs/nfsd/vfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index eafdf7b7890f..c99e54b23cd9 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2407,7 +2407,7 @@ static __be32 nfsd_buffered_readdir(struct file *file, struct svc_fh *fhp,
 	loff_t offset;
 	struct readdir_data buf = {
 		.ctx.actor = nfsd_buffered_filldir,
-		.dirent = (void *)__get_free_page(GFP_KERNEL)
+		.dirent = kmalloc(PAGE_SIZE, GFP_KERNEL)
 	};
 
 	if (!buf.dirent)
@@ -2458,7 +2458,7 @@ static __be32 nfsd_buffered_readdir(struct file *file, struct svc_fh *fhp,
 		offset = vfs_llseek(file, 0, SEEK_CUR);
 	}
 
-	free_page((unsigned long)(buf.dirent));
+	kfree((buf.dirent));
 
 	if (host_err)
 		return nfserrno(host_err);

-- 
2.53.0

