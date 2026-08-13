Received: from mail-ot1-f52.google.com (mail-ot1-f52.google.com [209.85.210.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76C283314AC
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:41:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653702; cv=none; b=DHFhrex+hBkqaxmwHMJC7qa6RJZ5BZ8qCB2LsgnExElZRJYrSZB5pcaQeeDvhC6YH9eneSJv2bKgBPFDucjfICxMCiD/UYwmDr/s4+Csg3i4uRTPLUgaNF4whJzLoryu61S+GtxsRJfvzDAv2HdnsxNlqBynI4qlda+QeZxUtPs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653702; c=relaxed/simple;
	bh=0Ut6Bf+daACwpUvXRP9jUHN44WFWpP0zodfmZhdD7iQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OfSJO7sQfF0JhrTC3AbVfg/yQSeUVvboK6K4X//TYjHVxE291KCJGfKRcw7ibTjCbsg2INA70wHjPzLYnK1vemjIJgecG1LAYgSQgbNKAM4Wo1QMmeNufdEpG62PdBwkkGDYHznKyQsd6/OotSM4ZCYGvfPu4hDwgfJd7EJRln8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=DZ9XFjPy; arc=none smtp.client-ip=209.85.210.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="DZ9XFjPy"
Received: by mail-ot1-f52.google.com with SMTP id 46e09a7af769-7eb1dc6bd53so256308a34.2
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:41:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653699; x=1787258499; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Rm54/Xr+RWG2qQzbIdS8vqBNYOzgjc/PrlNUuiqdb/c=;
        b=DZ9XFjPymFF3OFkJX/M09I7x9wabuBv/neDNDcX+OMj2TAE4DUxAhga4yP7lzQ3nXY
         8/y5eUVydVPWAsm7Kwl5+10/mhh2gD9Jb9FDpG80Z3wVwlnf8NT8u+QZ2To25XoawDT8
         mFreeuWk5gGXNhe8IqSDfEMTz9seP/jDgo25j/Ar4Iu6kCQAxuVfCODXwUDmR+ldFRWz
         UTbmYp9ngOtOkfHlnxVAXSJiuIjKSK0SxVILE+rPpbYyzn4FiyKj4QPpQuDKe49cQg0R
         16ny1SS2rLVlkTDpx/pjkPlMehxj6u1XDia5qraVh4wNQ7u6KFIYmisXY1L1EB+hUlWn
         MbwQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653699; x=1787258499;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Rm54/Xr+RWG2qQzbIdS8vqBNYOzgjc/PrlNUuiqdb/c=;
        b=eWDes7NYLAIOKSAvY+UsG3iNffeD9qMN/rYNXiaRyKt6X7SSypL4yu1aXJm2vvQVza
         H01gUSoGCsh6u8UVbfqFEs/gEYEuiauPlfq5kAAwlSDzHP8UJ4El6fs0xdFamVm6REtz
         I1Jkl8I3xXbqeSzz/skN0rhNyrJEQ+WRXIxCOWgsZN++4j9YvQZlhyctmYkTh8FOAzjB
         bJ+F4UACm3iu9EnB0hHSazhBR//2zFONdhNJa22/lyHtPSsbpAyXm1xu+sIqpzc7ABxr
         n9D1J0WsGh8rjhqXedXAfvgiRNAPc/j+fweqBh1S7kXcibiSxI9MvZBDFjgUn9rOIWUJ
         6mgg==
X-Gm-Message-State: AOJu0Yz6L+LLBiiYkuGhiAK6FJ0UlsaplyozNm1HB46u7nmQwOvAILvA
	kd73zsUtzkaEEFHZBnwvPOYED7J5AT7KSDc3LEtqv1qoBp7vLbvxMdfaMGyCiVa+qhA=
X-Gm-Gg: AR+sD13hT7GCQ6bTMFEWtrrHmGHLruJsCn0MGjVmsypH2ry0i2KNmxbDWkHRkTxrWZZ
	Auq2+au2l4+GGL529LnvmS+vJYgLzyWNIqjxvxJ5f9EquooiQ/wFMkJ6qcd4JgijElU67PJfj8T
	WyOMdxIgeSwDf5/3+xrDjyZsO714BbT1Yfq927mj+kYJ/dQvF1qOiV9kkkirVvSOLxzH1XlqYSq
	+pCPhLkxtt4Oa1j7YeN1D2iqIawtY79VesVhDiaZ/jDr2DJiR7JneSVJPOjhcng7SEWm+sI8iPo
	bQ9vA/ROWuvTpgBVkzjMFYBO1Q16x8WUCky+o4g+7XcNWwlOfN9DqNZHp3IMZedDQjvLl5rYUdO
	GiB4tQKPbCZWQWzT2gtAEXHD81PHVF/KfeGwlNHL+Ng0ONkWA+9aSOEy79N9YGClIqUukbcoIux
	f4mM+o4+bjtNrcj/S7QVZ2CJDR8MEIRpNLwlyl1IynJgf5MFTWJt1a0/SE6rBxF24bG7IkjAKsI
	O6doN86wn2VUWE16AO0f+CF
X-Received: by 2002:a05:6830:2aa2:b0:7e6:ef1d:4aeb with SMTP id 46e09a7af769-7f3de70ef43mr450409a34.15.1786653699219;
        Thu, 13 Aug 2026 13:41:39 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7f3c9e23b6fsm3087958a34.25.2026.08.13.13.41.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:41:38 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 5/6] NFSv4.1/pnfs: remember when a server needs a larger LAYOUTGET reply buffer
Date: Thu, 13 Aug 2026 16:41:30 -0400
Message-ID: <05a40a0ca55e214c9593b1cf717dde9b2b3d7bb9.1786653456.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653456.git.bcodding@hammerspace.com>
References: <cover.1786653456.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a LAYOUTGET only succeeds after escalating the reply buffer, every
layout fetched from that server is likely to need the larger buffer:
remember the escalated size on the nfs_server and use it as the floor
for subsequent LAYOUTGET reply buffers, skipping the doomed attempt at
the layout driver's default size.

This also lets the LAYOUTGET attached to OPEN benefit: the lgopen path
is best-effort with no retry of its own, so without the learned size
it would fail with NFS4ERR_TOOSMALL at every open against a server
handing out wide layouts, and layouts would only ever be acquired by
the I/O path's retry.

The field is a hint: reads and writes are racy by design, the value
only ever grows toward the session's maximum response size, and a
stale-low read merely costs one escalation round trip.

Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs.c             | 15 ++++++++++++---
 include/linux/nfs_fs_sb.h |  4 ++++
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b596a65c7ef2..e9ec960ac22d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1187,10 +1187,12 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
 	}
 
 	/*
-	 * A previous LAYOUTGET for this layout did not fit the reply
-	 * buffer: raise the layout driver's default up to the session's
-	 * maximum response size.
+	 * A previous LAYOUTGET on this layout or on this server did not
+	 * fit the reply buffer: raise the layout driver's default up to
+	 * the session's maximum response size.
 	 */
+	if (!min_reply_sz)
+		min_reply_sz = READ_ONCE(server->lg_reply_sz);
 	if (min_reply_sz) {
 		size_t npages = (min_reply_sz + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		if (npages > max_pages)
@@ -2393,6 +2395,13 @@ pnfs_update_layout(struct inode *ino,
 			goto lookup_again;
 		}
 	} else {
+		/*
+		 * A LAYOUTGET that only succeeded with an escalated reply
+		 * buffer: remember the size so that future LAYOUTGETs to
+		 * this server skip the attempt at the driver's default.
+		 */
+		if (reply_sz)
+			WRITE_ONCE(server->lg_reply_sz, reply_sz);
 		pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
 	}
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 34d294774f8c..3e6bae7e5221 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -248,6 +248,10 @@ struct nfs_server {
 						   that are supported on this
 						   filesystem */
 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
+	unsigned int		lg_reply_sz;	/* Learned LAYOUTGET reply
+						   buffer size, when the layout
+						   driver's default has proved
+						   too small */
 	struct rpc_wait_queue	roc_rpcwaitq;
 
 	/* the following fields are protected by nfs_client->cl_lock */
-- 
2.53.0

