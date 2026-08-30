Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30AAA2C11DE;
	Sun, 30 Aug 2026 04:19:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788063556; cv=none; b=fhyTjcPH15kM2uJk2/XH5a7bb/eFMFa8FE14naW5Mlg4T0naRrTto/acLUM9w6nvAzHGn+MAQfKu5P2xGvHMu56xHncnIyFtywkXsbP/KIQbSEbXAEBHFuxh/e1IZzkaH3XG9ERE31xdjfwDvtAD2Kl5RailKfGi3K/+rlY7SXE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788063556; c=relaxed/simple;
	bh=aWSEht8+k0dcbwQPIehIYxgvNbjB/2HtXEJKffN+Zak=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=f0+E5kKj9YhAojdQoMirSwcwyqDQ6t9v8M3CrQDGrhrx42EKB+TdpWvdHRNynVIt3eaNmn31BVhr2ga4mTeJgjMDmjvOuRDpfQysKANi94/aA0RqjstYQdh9ZTmLkc3Y7YPKoCTYYNCuI3lnWFceDe5u4nBdExh2p/c3wKfox+M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=WlAnPemS; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WlAnPemS"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=sAVqQaDD0nzQkp3zhExFeGOqa+2+Hy4Fdk9PRQI1fM0=; b=WlAnPemS/R3wjjMsjkr3aofwS9
	6+ju9+kQC8VWeYQe+2IMhIT2Ko4MIpm9T7B0Lmm4+/Uf13Fwv8n715o7H+hWFddniZcLhAJHjjiiT
	aA/migYecE82jkMkMMno5/JuEXsrfN8WoUpiMiBkPVeWqz6axs0dVwulU9dCBTp+IdoSnPAkf8xcF
	YL0wyjvMwNGrulHZepPot54Pow7G/n21dtGCExy83ftylOY2SG0+rm98uLlu8rzis9gkxjUassWDi
	GOIryltiIV4homH5urnoNY/qK3Nlb1+CoSZyheJTky/4EyXoGDGMC8FQvASOJOANDxQLnuv/J2DyQ
	0jOAQa3g==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x0X0Z-000000000hU-1DZI;
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
Subject: [PATCH 5/9] ntfs: Remove FGP_NOFS from __ntfs_inode_resident_attr_pwrite()
Date: Sun, 30 Aug 2026 05:18:52 +0100
Message-ID: <20260830041901.2668-6-willy@infradead.org>
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

I do not believe that FGP_NOFS is needed here.  This function is called
from one place (ntfs_inode_attr_pwrite) which calls either this function
or __ntfs_inode_non_resident_attr_pwrite().  The latter function does not
use FGP_NOFS in its calls to allocate pagecaache memory, so it should not
be needed here either.  If it turns out to be needed by both functions,
then we should use memalloc_nofs_save at a higher level to protect both
of them.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/ntfs/inode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/ntfs/inode.c b/fs/ntfs/inode.c
index 32edb4045178..36a0d6b26c02 100644
--- a/fs/ntfs/inode.c
+++ b/fs/ntfs/inode.c
@@ -3676,7 +3676,7 @@ static s64 __ntfs_inode_resident_attr_pwrite(struct inode *vi,
 	mark_mft_record_dirty(ctx->ntfs_ino);
 
 	/* Keep the first page clean and uptodate */
-	folio = __filemap_get_folio(mapping, 0, FGP_WRITEBEGIN | FGP_NOFS,
+	folio = __filemap_get_folio(mapping, 0, FGP_WRITEBEGIN,
 				   mapping_gfp_mask(mapping));
 	if (IS_ERR(folio)) {
 		err = PTR_ERR(folio);
-- 
2.47.3

