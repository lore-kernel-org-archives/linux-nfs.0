Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B65C12C026C;
	Sun, 30 Aug 2026 04:19:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788063580; cv=none; b=MLsCEyTNup3xi7Ewm/dwO7aQpy5nJzwgLqhC2qeMpqOCtRz/LNPaYLCDAhNvsAec1l5YMNVFKr6PBBVeZXXBGhW2HuTaj7Fyae8hmCR6AOhnOldnKoyaBj/YyiV/bf0We3xpqwk+O4VH+MEgtKM/oe/fcZmzgIYo14OHSJHvEOc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788063580; c=relaxed/simple;
	bh=ua77bB9lJzzsPGvmDjWHUiYJnv0U/TicIHtRpmrjyIU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=h4KblhwYl7jJovXsUzQyQobe7VT7YQliHet6yj01ERuJ6oEHFZYmF62v4E+11eFOzYv4QignaoKK2CGWYgD4tVM/XaXQTjk6SW0Ua1kKeQ8jMOsfEqWZHugfx9Hx3IrQgz0SGP2jHR3+aLZhJXCMTO0Egly1/DZtkVkf7BqsXgU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=jmnyzAGh; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jmnyzAGh"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=tsfpWnTEEugF5BhxxP0f5NSzcOBwxx6do+o7r7CRpoM=; b=jmnyzAGhnXUs0+C5LS24e7OvOs
	zECGaQnz/K7uDPY+0u1wIf57vrFCgxSAVDmXvvj2TMBVH3TwhpYMMCjU/iKIiKTFWX3wS6ki66JzL
	u+cDYy9gVlfHAwnU21whEjN+K2q/N4jfjfUTBerTfCmMcehN/SHRRgR81UCMVMH1utVmJ4lkryx73
	gukk3XpXRgPtZ+cK2nFL5ks8imp9XnV9WbnbHY6KaDnzoVrezcKyrtL4QpAosis5BrPyRe81xoTst
	U6BQxwL8QcjppnnEieucNP8b4nPqOQuTwxvZKv4tOIF7s0w4u3IBCUeo+jof7AAqQejsMCVDHmuHG
	SfbA0xNQ==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x0X0Z-000000000hS-0u4B;
	Sun, 30 Aug 2026 04:19:03 +0000
From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
To: Christian Brauner <christian@brauner.io>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	Gao Xiang <xiang@kernel.org>,
	Chao Yu <chao@kernel.org>,
	"Theodore Tso" <tytso@mit.edu>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Hyunchul Lee <hyc.lee@gmail.com>,
	Phillip Lougher <phillip@squashfs.org.uk>,
	linux-erofs@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ntfs@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH 4/9] nfs: Remove redundant FGP_NOFS
Date: Sun, 30 Aug 2026 05:18:51 +0100
Message-ID: <20260830041901.2668-5-willy@infradead.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260830041901.2668-1-willy@infradead.org>
References: <20260830041901.2668-1-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The flags already include FGP_NOWAIT which prohibits all reclaim, not
just reclaiming from the filesystem.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 49394123bd09..e34125a8a2e2 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -447,7 +447,7 @@ static struct folio *nfs_readdir_folio_get_next(struct address_space *mapping,
 	struct folio *folio;
 
 	folio = __filemap_get_folio(mapping, index,
-			FGP_LOCK|FGP_CREAT|FGP_NOFS|FGP_NOWAIT,
+			FGP_LOCK | FGP_CREAT | FGP_NOWAIT,
 			mapping_gfp_mask(mapping));
 	if (IS_ERR(folio))
 		return NULL;
-- 
2.47.3

