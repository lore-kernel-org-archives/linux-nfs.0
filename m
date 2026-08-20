Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 735513C10AF;
	Thu, 20 Aug 2026 19:34:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=90.155.50.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787254465; cv=none; b=r11YQtdnnyZP/siaIZzsd2q6NeTzz0QRJ/8adHaJjm/3ZkcRnf7QoZUgT+Qs5JNn1GetX81YmDJLQy66fqRnhDlKb8i6r05aos7WDFdumhV+24k/8rwt7Yj0P2YdlEu7PuYVlEtYc+E3ZzkGDyrrTSACpaYcV3lU6DprFpppdMU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787254465; c=relaxed/simple;
	bh=4zwJd2wc9utKN9dsHFSIeRcyfrm9y/w8Y8BBYn2jXQM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HBnpfmB1NgE1SZhFyTGssWXIzIsnuVID4kj5kVFaSNd+Vr6Ob+xsMaGzSbNnIeHFNlQGVRpFFH6kSyeOKnThMRgakgkT9oX/1V/CmVX20bYJkAWyK7/wNtzdoRR3D4nJVT66wHgjmLMgWDHLnElT1vheBKY95cw0muvETZzXRHQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=gK+a6hxJ; arc=none smtp.client-ip=90.155.50.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gK+a6hxJ"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
	References:In-Reply-To:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-Type:Content-ID:Content-Description;
	bh=LzEUj4hlm5g43Y8sYo0gJEtX4l9xsY1tZauPsEw2Wqo=; b=gK+a6hxJT7qvWllQUtPGM8F6CP
	c/+4Zz6aBT8Bi3I6i7eFeH2Qj+B8NY8VDHA3xOgk0qesJuC6WVisRTI73/rfDhI0AVKFYUcomlAyV
	GRJP9ae6EKC7VbNqbPUFtpGJADRW8Qz3oLfsyvn4zRe14CiFLI0yqkg+l44bIMbZz5qEyd9d5TGUl
	YZJ7UNsC5PrcqbEdE3EqrSCIipNgjIW9CD8bTJR2upzWZAltzDokJXCQamLsGNmXCmG3c6Ucoulfg
	V6pAILiCli0k2vTtvb/K5MwSGA2u1DwSR35QNsR1oeFX6jO7qqJji4M3DcoHIYAcne4UnY+L2DS/d
	K/XT99Sg==;
Received: from willy by casper.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wx8WH-0000000GALj-1JTQ;
	Thu, 20 Aug 2026 19:33:45 +0000
From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
To: Christian Brauner <brauner@kernel.org>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	Chris Mason <clm@fb.com>,
	David Sterba <dsterba@suse.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-block@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	fuse-devel@lists.linux.dev,
	linux-nfs@vger.kernel.org,
	devel@lists.orangefs.org,
	Pavel Begunkov <asml.silence@gmail.com>
Subject: [PATCH 6/7] orangefs: Remove launder_folio implementation
Date: Thu, 20 Aug 2026 20:33:39 +0100
Message-ID: <20260820193343.3852967-7-willy@infradead.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260820193343.3852967-1-willy@infradead.org>
References: <20260820193343.3852967-1-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

There doesn't seem to be a good reason to implement ->launder_folio
in orangefs.  Leave orangefs_launder_folio() alone as it is used
in several places and removing it entirely would be tricky.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/orangefs/inode.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/orangefs/inode.c b/fs/orangefs/inode.c
index 7143b64b5b25..c1f5658ba8af 100644
--- a/fs/orangefs/inode.c
+++ b/fs/orangefs/inode.c
@@ -616,7 +616,6 @@ static const struct address_space_operations orangefs_address_operations = {
 	.release_folio = orangefs_release_folio,
 	.free_folio = orangefs_free_folio,
 	.migrate_folio = filemap_migrate_folio,
-	.launder_folio = orangefs_launder_folio,
 	.direct_IO = orangefs_direct_IO,
 };
 
-- 
2.47.3

