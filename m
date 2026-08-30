Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 652FD1F12F8;
	Sun, 30 Aug 2026 04:19:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788063554; cv=none; b=PFt8FnJ+5mncwtyRsNnXuvpfXDaVDGsMxEVww4Ln4voOzjVWCJXN80qPr+Xfd5uK6aPPCqVCiF8fQ0wvb/5QKBdgSwTpZlFM2jhZK2BVRSxbgxRh6jPvXfuWHQLCZswwAg3oApRqIy0FhfFbsslQURDKv8j1iRpBMeWTRthq2w8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788063554; c=relaxed/simple;
	bh=1BfozxAkZI4GJuY+2tupzCtnc4HTR8TVO9JGgWl3duU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=aQzatYU69DUazxEjS8vtdLp09up0UAnapWX21LpKOvhH07TCq/Kmh278VNcfISS1NcDockDZ2Jb4zlQ+CF5e3U6hzxVFzAZ3lqtYoUQi5M0aGiEH6io7G3emlglDkva+i2kJiizKrV7ar6ULyM1ROTzSY4koc22y3QkKrM/pUIs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=kq9hbcwK; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kq9hbcwK"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=dejHJnjtKaOM8kEBucRI9H7VqzSRiRdAVrdQgRGUFkI=; b=kq9hbcwKXkJ4J1vRrFYKTsZrzz
	6lUCw4ImNf0uzG7wmavDvL2d1b1zE8A/RpsFFBEd2KjgADVNelaeu+Cc2ft0JaNcevE7WuveiN7Hb
	tuuPLC7wUk69v4nkxbWpYMUDTfv9hB1Rd+51IvuOI4rXruVCB/9lK9RX1+qkSSlUe/PNQoGfnKbnr
	FbqvDhWB9HA1L6PBoHuVyoe3P+DiWEWuQlRK2pYw1HhzYEuIWWYCtbW/rzc5y5iVbW1pda9V9RBwl
	edUQp11krj3umqsJsfHJRhphqubpVr29NMhHxEytCZURqMJYmtIFItwO3XcpwP+SOtdsg84LGxNjv
	2q6HPnXQ==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x0X0Z-000000000hb-1c0i;
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
Subject: [PATCH 6/9] ntfs: Remove redundant FGP_NOFS from ntfs_wof_collect_dest()
Date: Sun, 30 Aug 2026 05:18:53 +0100
Message-ID: <20260830041901.2668-7-willy@infradead.org>
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
just reclaiming from the filesystem.  Use mapping_gfp_mask() instead of
GFP_NOFS as this will preserve flags like GFP_MOVABLE.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/ntfs/wof.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/ntfs/wof.c b/fs/ntfs/wof.c
index 8f84c2212eee..c981b4a3b695 100644
--- a/fs/ntfs/wof.c
+++ b/fs/ntfs/wof.c
@@ -464,10 +464,9 @@ static int ntfs_wof_collect_dest(struct address_space *mapping,
 			folio = target;
 			is_target = true;
 		} else {
-			folio = __filemap_get_folio(
-				mapping, index,
-				FGP_LOCK | FGP_CREAT | FGP_NOFS | FGP_NOWAIT,
-				GFP_NOFS);
+			folio = __filemap_get_folio(mapping, index,
+					FGP_LOCK | FGP_CREAT | FGP_NOWAIT,
+					mapping_gfp_mask(mapping));
 			if (IS_ERR(folio))
 				return PTR_ERR(folio);
 			is_target = false;
-- 
2.47.3

