Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=111.22.67.137
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794816346;
	b=qW/rOC4AmqmpVniDuCKX0d5xxFegzs4gHRSiDufGuI/tTy6RY1/Qh2nyw18fK4zdy9vK
	 ToMH6ctJmosHffx1Qh73diOaG8g4vfNBzJAc5F5qFQ0IEt3oPvzMmrYqVXz7vGCA6G3nE
	 BvwBD4F/QnDMK3tKkgZ65zA/S7JL/LIbpdmsip2YzOS1boRE3Qw805XJ9IfOzZCfv1hSy
	 +7LoyEIXfVE2g2eQXGG378U2Kh5PvWVs7U/8e40Od5TTqLKflGXVJbH2G4o1I2m4qhACH
	 oCdzdO+O/xqeZigTQw9GbURZOY5NUldLopmGD7s1p3/zMyvdx/nUbMHjE+ICEEBF2NQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794816346;
	h=DMARC-Filter:DKIM-Signature:X-RM-TagInfo:X-RM-SPAM-FLAG:Received:
	 X-RM-TRANSID:X-RM-TagInfo:X-RM-SPAM-FLAG:Received:X-RM-TRANSID:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=6Avz1NW7TUudJTX++ez+xj7beQ7E+txia0kyE9b57xc=;
	b=GSXe+HlZAOqid532lL/FRCyphgRM+H1Sj12sNd/Nq8L0Bn8uMhKHEbw/jArJsE4DIpHk
	 B1SJYo6ZnNq4MXtEoWTILerp4+yEPpzYjyCKJ/N9dVBJ3iMdqS6iOwn07Bhr90IYHmeVx
	 Aj0bRKg/0rPxeYXxwNxZMFiqeuKXyvusGufnoqyxTERToYo7aYmpkNRnNpVlKSv1imHNE
	 aKl74cW6vQFGhl620drOUXhqA/6wppomgPigRqS4d3d+AcjDlHa+t/EdRgE4RMxqYc21m
	 8M33/KSAumru7pnHeNfAJrDVvCrd8jFTW34aoBlL8/bMVAvN+S+fzh2be7wSMgAuCYA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=cmss.chinamobile.com;
	spf=pass smtp.mailfrom=cmss.chinamobile.com;
	dkim=pass header.d=cmss.chinamobile.com header.i=@cmss.chinamobile.com header.a=rsa-sha256 header.s=default header.b=grpOFYAf;
	arc=none smtp.remote-ip=111.22.67.137
Received: from cmccmta4.chinamobile.com (cmccmta4.chinamobile.com [111.22.67.137])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id B277E606A31C;
	Mon, 16 Nov 2026 08:05:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B277E606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=cmss.chinamobile.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cmss.chinamobile.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=cmss.chinamobile.com header.i=@cmss.chinamobile.com header.a=rsa-sha256 header.s=default header.b=grpOFYAf
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=cmss.chinamobile.com; s=default; l=0;
	h=from:subject:message-id:to:cc:mime-version;
	bh=47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=;
	b=grpOFYAf/BGqCy8WbnRkBlQS+K6LyvEA2Bzu8ZRdN5QUZhHfWn6zHkpZ5byLQdpXiQodeQpCB2zPt
	 D+x8pgBSTDLNPL1/x1ZArqxZgNVkAgG51lmS77RGCNXn3XY0r8EEmFExA95+jFqX9pupiDXM8ApWCY
	 Bpw3MTw5MwFdTUgQ=
X-RM-TagInfo: emlType=0                                       
X-RM-SPAM-FLAG:00000000
Received:from spf.mail.chinamobile.com (unknown[10.188.0.87])
	by rmmx-syy-dmz-app04-12004 (RichMail) with SMTP id 2ee46afab95699e-9dbc1;
	Mon, 16 Nov 2026 16:05:42 +0800 (CST)
X-RM-TRANSID:2ee46afab95699e-9dbc1
X-RM-TagInfo: emlType=0                                       
X-RM-SPAM-FLAG:00000000
Received:from fedora (unknown[223.108.79.102])
	by rmsmtp-syy-appsvr01-12001 (RichMail) with SMTP id 2ee16afab9541e5-84257;
	Mon, 16 Nov 2026 16:05:42 +0800 (CST)
X-RM-TRANSID:2ee16afab9541e5-84257
From: Yiqing Wu <wuyiqing@cmss.chinamobile.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Yiqing Wu <wuyiqing@cmss.chinamobile.com>
Subject: [PATCH] pNFS: Fix use of uninitialized be_prev in ext_tree_encode_commit()
Date: Mon, 16 Nov 2026 16:05:31 +0800
Message-ID: <20261116080531.50982-1-wuyiqing@cmss.chinamobile.com>
X-Mailer: git-send-email 2.56.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Building with W=2 warns:

  fs/nfs/blocklayout/extent_tree.c:615:59: warning: be_prev may be used uninitialized [-Wmaybe-uninitialized]

When the encoded layoutcommit overflows the buffer,
ext_tree_encode_commit() breaks out of the extent loop with -ENOSPC
and computes lastbyte from be_prev, the last extent that was
successfully encoded.  be_prev is only assigned after an extent is
encoded, so if the first extent matching the filter already exceeds
the buffer, the loop breaks before be_prev is ever set and the error
path reads it uninitialized.

That path cannot be reached in practice: overflowing on the very
first extent would require a buffer smaller than the encoding of a
single extent (20 bytes for SCSI layouts, 48 bytes for block
layouts), but the callers always pass a full page or the server
wsize, which nfs_io_size() clamps to at least NFS_MIN_FILE_IO_SIZE.
GCC cannot prove this, and zero-initializing be_prev alone would
turn the theoretical read into a NULL dereference, so handle the
case explicitly and report U64_MAX, the same "no information" value
that is already used when bl_lwb is zero.

Signed-off-by: Yiqing Wu <wuyiqing@cmss.chinamobile.com>
---
 fs/nfs/blocklayout/extent_tree.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index 7393118c42a2..f78699317d8e 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -585,7 +585,7 @@ static int
 ext_tree_encode_commit(struct pnfs_block_layout *bl, __be32 *p,
 		size_t buffer_size, size_t *count, __u64 *lastbyte)
 {
-	struct pnfs_block_extent *be, *be_prev;
+	struct pnfs_block_extent *be, *be_prev = NULL;
 	int ret = 0;
 
 	spin_lock(&bl->bl_ext_lock);
@@ -612,9 +612,14 @@ ext_tree_encode_commit(struct pnfs_block_layout *bl, __be32 *p,
 		*lastbyte = (bl->bl_lwb != 0) ? bl->bl_lwb - 1 : U64_MAX;
 		bl->bl_lwb = 0;
 	} else {
-		*lastbyte = be_prev->be_f_offset + be_prev->be_length;
-		*lastbyte <<= SECTOR_SHIFT;
-		*lastbyte -= 1;
+		if (be_prev) {
+			*lastbyte = be_prev->be_f_offset + be_prev->be_length;
+			*lastbyte <<= SECTOR_SHIFT;
+			*lastbyte -= 1;
+		} else {
+			/* no extent fit in the buffer */
+			*lastbyte = U64_MAX;
+		}
 	}
 	spin_unlock(&bl->bl_ext_lock);
 
-- 
2.56.0



