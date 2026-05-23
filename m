Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 957BD3191CA;
	Sat, 23 May 2026 17:56:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779558963; cv=none; b=d2n/D8eobPVdqG/mxX67o41na+eNFem3ffOieG7s4Zm9RdPZPLzGUIDV2B2FW+DcZdMEozDpbpI8sdSL+kDuovySIivppHGvKcUrf6V5guQGSnwDl9iAbEskeLfBkuA9mDwFB15peNR1ef/CoAnZ1tebSX2+qEZrwHTyzNf871s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779558963; c=relaxed/simple;
	bh=IHKFef2x/jyYY5uYqDXxJ7Z15M5ZTikaFgXsQ8rpbDo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=UqGhD9CdK4PdY2ty6lGGml/nUykoM575HLAiG1ZVGqaMADUL+QQXiwY6zvJ9rchYQShO2rvsaQa19NNBI2J7BBKgKZFe+zxAmr9rQqrJiELqOeeGkPnvPBp8OH/pvhwh2UVZya9NtoENRdvX5o32MaeElTF2jj4rV0OXoe/5YUM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=oZhkwgXq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="oZhkwgXq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3F4E91F00A3A;
	Sat, 23 May 2026 17:55:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779558962;
	bh=xn1afLPdDj00dLAc64xuCdT5ncjg8HMcRvLHoM078ak=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=oZhkwgXqudyq5TncLZzYhSy/KChNIJsYMPo7KO3BUs0B5I3D4uMMlIJHJ5H/ZsIiR
	 O7WDgdKc/37mYX8oVhIB+gQOs7nSvU3Wkc6MhR+TfDmZFcgB/B9ilaXie8CblGN9d0
	 KHAaqP8o4lh1HFEljI32jULXkHy6jjdEpet+Q/9ZjLd1IIUD9RwCL8TlSbnwXy2Ff+
	 529elZn3TrKG4mapsyPR44RG0R8lKa7ncAu3JbZz7V/nyli4itQLLBzlDHjolS+khv
	 Efkoiz0JR9RL0vbHFM55SfWM2z9m/9FY7WC1YyCJnnsu0Jf6lvKqAF9GJ0G7WAhp/b
	 WbyGsmdljEtLA==
From: "Mike Rapoport (Microsoft)" <rppt@kernel.org>
Date: Sat, 23 May 2026 20:54:23 +0300
Subject: [PATCH 11/17] isofs: replace __get_free_page() with kmalloc()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260523-b4-fs-v1-11-275e36a83f0e@kernel.org>
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

isofs_readdir() allocates a temporary buffer with __get_free_page().

kmalloc() is a better API for such use and it also provides better
scalability and more debugging possibilities.

Replace use of __get_free_page() with kmalloc().

Signed-off-by: Mike Rapoport (Microsoft) <rppt@kernel.org>
---
 fs/isofs/dir.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/isofs/dir.c b/fs/isofs/dir.c
index 2fd9948d606e..6d220eab531e 100644
--- a/fs/isofs/dir.c
+++ b/fs/isofs/dir.c
@@ -13,6 +13,7 @@
  */
 #include <linux/gfp.h>
 #include <linux/filelock.h>
+#include <linux/slab.h>
 #include "isofs.h"
 
 int isofs_name_translate(struct iso_directory_record *de, char *new, struct inode *inode)
@@ -255,7 +256,7 @@ static int isofs_readdir(struct file *file, struct dir_context *ctx)
 	struct iso_directory_record *tmpde;
 	struct inode *inode = file_inode(file);
 
-	tmpname = (char *)__get_free_page(GFP_KERNEL);
+	tmpname = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	if (tmpname == NULL)
 		return -ENOMEM;
 
@@ -263,7 +264,7 @@ static int isofs_readdir(struct file *file, struct dir_context *ctx)
 
 	result = do_isofs_readdir(inode, file, ctx, tmpname, tmpde);
 
-	free_page((unsigned long) tmpname);
+	kfree(tmpname);
 	return result;
 }
 

-- 
2.53.0

