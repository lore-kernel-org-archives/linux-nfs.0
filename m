Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41385330662;
	Sat, 23 May 2026 17:56:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779558993; cv=none; b=GoyTaCRI91dPSM1fM4JY/+pNFoZh3DQk7s4UHPR88cHz64iW8Uo5RYJpmmgMcc7YzwMGDRjmQ2OE0Z66Bo9lWRvlzPGRwDDPtbNHvQxhJ+5pcII7/+glZQden7N5BNa0LC2+lZaaIZW0TweMD2txTDuj8HrGe0qDqBSzrxtZyQU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779558993; c=relaxed/simple;
	bh=SBC0xcwck7YqyR4+c7ort1g4YhFB6ZS5sPCyTtNomsk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=dGZQon20cdrY7hGVO6ojcYud1Q2a6W3e3ZeSIC5uMSnk0eQqHm0VKhd++cJg0h9rauepHD43GYkZEddIkd/hCOBXidsjl8J+pd6Dhukk+kRok5VMLJf2TKgkHfXYxmwTTGQ5f5beHus3O5B2uBFDWE6Kp1bR7sgfaPAHWZYCYV0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nCSdfqNI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nCSdfqNI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2CA291F00A3A;
	Sat, 23 May 2026 17:56:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779558992;
	bh=avaAlGi99keULPCZbynNTnKAsRLlbRGsrJ8jPwcvMgE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=nCSdfqNIbpAILIl1hkV8eRrcN1BW63mPl1SXXJDMC2qdR5RyaxxJGoqPP46gwgR1S
	 +23QGRthqb5rkclytzrT4aNNh23BqD/SFor3S4bTV7lcsIexjJFjf/nTcfVKNnZdDl
	 zm9CpBj4O92KD7M+sFppTDfYRg0P+I0San410HCOyA9/hucFpDsekC0skrneiMae8f
	 s/FlJUMcGqpZ1eE2hEooc/JDON11jyXAJlM8GzjJCY6gaCzDLXOtxw70PzbGh78UeZ
	 t8GLZb8jdivXwzqrjSaSh/j10uwgwnPH68J080OEN8uh3h/W49iDDQ35JPS1eZv99G
	 yvks9jaAUnw4w==
From: "Mike Rapoport (Microsoft)" <rppt@kernel.org>
Date: Sat, 23 May 2026 20:54:27 +0300
Subject: [PATCH 15/17] configfs: replace __get_free_pages() with kzalloc()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260523-b4-fs-v1-15-275e36a83f0e@kernel.org>
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

configfs allocates staging buffers __get_free_pages().

kmalloc() is a better API for such use and it also provides better
scalability and more debugging possibilities.

Replace use of __get_free_pages() with kzalloc().

Signed-off-by: Mike Rapoport (Microsoft) <rppt@kernel.org>
---
 fs/configfs/file.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/configfs/file.c b/fs/configfs/file.c
index ef8c3cd10cc6..a48cece775a3 100644
--- a/fs/configfs/file.c
+++ b/fs/configfs/file.c
@@ -59,7 +59,7 @@ static int fill_read_buffer(struct file *file, struct configfs_buffer *buffer)
 	ssize_t count = -ENOENT;
 
 	if (!buffer->page)
-		buffer->page = (char *) get_zeroed_page(GFP_KERNEL);
+		buffer->page = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!buffer->page)
 		return -ENOMEM;
 
@@ -184,7 +184,7 @@ static int fill_write_buffer(struct configfs_buffer *buffer,
 	int copied;
 
 	if (!buffer->page)
-		buffer->page = (char *)__get_free_pages(GFP_KERNEL, 0);
+		buffer->page = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!buffer->page)
 		return -ENOMEM;
 
@@ -381,8 +381,7 @@ static int configfs_release(struct inode *inode, struct file *filp)
 	struct configfs_buffer *buffer = filp->private_data;
 
 	module_put(buffer->owner);
-	if (buffer->page)
-		free_page((unsigned long)buffer->page);
+	kfree(buffer->page);
 	mutex_destroy(&buffer->mutex);
 	kfree(buffer);
 	return 0;

-- 
2.53.0

