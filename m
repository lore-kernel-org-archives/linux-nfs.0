Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 764E729D26E
	for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2026 07:03:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774249391; cv=none; b=uY6Cg+xb6wiFR7O9DtSgIDUXEd7UeWZ9Y5szUQW/1wKzZvUIw0LkkbX2Vjg5bQw1xFtZ9hE1hZky7WrdJy7UmxIlsrO7iIi34Yu7cZMl4a2wyrJhFY/oCvQeE55oQ8oMt6UAC5WB8qi881AoCwlm537KJRFJcoXNXywk69ARzqw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774249391; c=relaxed/simple;
	bh=mcRJnMDl54rXhApXMemJQbhXB0V5/5qkqHqHl9n2DOw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=IYSugLtTuYSZx5hEjfheYVC6qyAQXQBao5bId73B/NyKOifevb+v8HvODtAkiU369SSFq88mXYuwZu+DrAT6pNM2iTdU/qi2Wxi3mF/gKY/J32Rve2hMko7bCC0myjvWSLyjbGLZrbDI7xvUxke6lFRV1r8bapV8nJ92SuvAFy8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=EQ3+/RfJ; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EQ3+/RfJ"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Content-Transfer-Encoding:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:In-Reply-To:References;
	bh=EemHXt8knMnn+WbtbSbKGvQ0W+IuntcxSwPyHWSWgZw=; b=EQ3+/RfJziGU49ZJocONakJ3nI
	PVq+4ws1bJEkAWL4palYeOTMZOrq/5LDKv2sZxZ3sEC+jd8YVZgnYn4/0Do9T4iD49gvJ404K88R/
	PIhbhzGg5NqeNB/PozlgZXyQnwxZcdRaRs5Cur+EUMD/GaZFDhu/xy/vOSGZdPdTSUqta2flH4HAn
	0L8GMqeI5aiPXLAzz6/lr1IADOuuP1QUb4HUDlDlWtHZnKubo7vxqJKUi+L2nzuwdTIYFFjDSEMY+
	eLefD2VefA4aKHe5FUrUCw4s2ICTVmWQ8Z/XPRNRplh6FIFXAx/fuHFg4EKzhRRqYfk/y6T7lz2mG
	GvQKK15w==;
Received: from 2a02-8389-2341-5b80-d601-7564-c2e0-491c.cable.dynamic.v6.surfer.at ([2a02:8389:2341:5b80:d601:7564:c2e0:491c] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.98.2 #2 (Red Hat Linux))
	id 1w4ZJd-0000000G9xT-2XVO;
	Mon, 23 Mar 2026 07:03:10 +0000
From: Christoph Hellwig <hch@lst.de>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS/blocklayout: print each device used for SCSI layouts
Date: Mon, 23 Mar 2026 08:03:06 +0100
Message-ID: <20260323070306.2939415-1-hch@lst.de>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

We already print device uses for block layouts, do the same for SCSI
layouts as that greatly helps understanding the operation of the client.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/dev.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index cc6327d97a91..bb35f88501ce 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -370,11 +370,14 @@ bl_open_path(struct pnfs_block_volume *v, const char *prefix)
 	if (!devname)
 		return ERR_PTR(-ENOMEM);
 
-	bdev_file = bdev_file_open_by_path(devname, BLK_OPEN_READ | BLK_OPEN_WRITE,
-					NULL, NULL);
+	bdev_file = bdev_file_open_by_path(devname,
+			BLK_OPEN_READ | BLK_OPEN_WRITE, NULL, NULL);
 	if (IS_ERR(bdev_file)) {
 		dprintk("failed to open device %s (%ld)\n",
 			devname, PTR_ERR(bdev_file));
+	} else {
+		pr_info("pNFS: using block device %s\n",
+			file_bdev(bdev_file)->bd_disk->disk_name);
 	}
 
 	kfree(devname);
-- 
2.47.3

