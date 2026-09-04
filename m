Received: from mail-qk1-f174.google.com (mail-qk1-f174.google.com [209.85.222.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8B2F4908DB
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 12:56:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788526583; cv=none; b=f5IFcYbc4pAyDdCm4d6DILEHRYkTt9L1h7a5bphJx41548rJqk7t1aIZtaTmsn234cV1y+rAifaG/jlRI9MgX2dpSumJLd4BrQFiRc5WdFUjYmxCImjxStx92tyE8SDi5Q1wLf68rZOZwCx58MaFn6pvaxOmUeMpdx7JGVNOVg4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788526583; c=relaxed/simple;
	bh=nwg2LLtuOI0HfPAgdSr/0Ksvk/hHs/5JziEYsvafIIM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qNIzQX+q/0T5aHkgmeHOX1dlSKEldrmYUiKmo4yKmIx8jZ6cRI8h2RFchHVkk7u+YW3bxlbv6qfoKB0QHWj+atCNjGSrExiAEUuIeQPK/EeLN83VuGbzyxo8D7c8RWiKx3UE6KeK2bKhuILn28yJaFq61wQkykaxPIeAvWLHsJQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=awWnK+9j; arc=none smtp.client-ip=209.85.222.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="awWnK+9j"
Received: by mail-qk1-f174.google.com with SMTP id af79cd13be357-939309d02d6so76547085a.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 05:56:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788526581; x=1789131381; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=BUP/dUrAuYVdgpJ4NI05CK5F5bu4G9rxB1BqOd4qO84=;
        b=awWnK+9j3/lNpA2X3lFdbcD89kSQR+LwS17BeZ2L3zgpmsfMm+y4EICd3mSZnp9kkp
         1VGX1oH3djmDIxYLkv/8bmR6eBxhBDYDAPeliIeGahkOGJn129e8b+yGdDgFVWsEcsMe
         Y7wQnB747IQu/xp9EZ0MAau0TJcH46HQm1x0UPBD9cX59/PlRDGt0jfiZMsUvcuK9nDL
         3PaPHSqT5gx0OX+NSmXhLnU1P0JjOaLmMXdd1fDTVddT9A7591jovKmit9NRkFfK6IKH
         bSC2AonY94XHeuohjG06d4otWl+66ZoU0Y3tqpV7dE+cQUSDLkbFud/A7hTFX1BofGfE
         xDFg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788526581; x=1789131381;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=BUP/dUrAuYVdgpJ4NI05CK5F5bu4G9rxB1BqOd4qO84=;
        b=BLwhS8rLkBeHbJWoEM2wYFlaI8hLqnjOWlzFOdTQdc7BaAxz1j6tdL8g/9RvjNxtPK
         CMRk45BknTnIlEgv5LUe9HkPMawWr0WVOPOBuPSGtArRzG8vfwTgpO/vFmH7fRyqWAVq
         Twnp/dn0XI50OrBnXehi9HKgWHlBl+4fvVbs/pMH1k3BmID24y2NxkbXJX4mw4WRU2y4
         6VaDGDmWhIc/YOcYw1bMplw5oE1DWz/OrrdmdWw64cYfnOPAHHkY0m/vNLxgP3volN0l
         Mqit4wpDT0Sr3pgbiNJN97IlLN36QOu3V/KhsBvXCZdiTCOSvZ+QvRCQ/w/WaHHv/b/y
         Ly2w==
X-Gm-Message-State: AFuF++mVs65PC5ggicOKpZqbY8mxjzJdH9BYdZX2ZsONlQidV7YpZ+yc
	Iq8TovrZTqRs+4CnvWAyXT4Wl8np+TL/VPPTBbbfjjJ4x0oSDxQgt0TwmFgMWeB+gmc=
X-Gm-Gg: AYBFou2B30gucyNj1CUTvAzsxRO217rczEQzTuB30/WOKKQbhimqwWxdKTiqTNe/Cf0
	AyBQ6YgZ8KF0R+YUwD7oFOAvwK3sjuIFNFztt+uHVWczXPVIMV4Rl+b9X/6QlwWg+RNEn4yUIhx
	8ALku4ggscTKArpLlq5GUsWe0Bxvr9aRU58YgRFgGdvDAXN0vV5uqIPVVcQ51HyapyrLLb2cFbK
	Sz6txfgXRP0JNa8aGTCYeewDJGrq6PPilzwe+Xs4EKzRsPnaCMGtY2bDyPJTD2vZtIDRMmANeIz
	i5h+2ZNJEr7OzBUuLO5PQ29ni+SbbM4cQLTxA6NYIeCkgDOVMZj6pu1tHoEmFz3pLRHNHw/nY73
	hAyqwjA5Xhfe4HbqWRR1NHYmQ60hos6nuSh/CpjCKmLl7R2W82fQnoIK6Khla61v9CMkpYzZstk
	y3QHq6TQrT6ffAPRGQuiC+lUbn1NANw4fteYXVLO17dmdE5OvV0db7Ho5hKGqMcRgcXY4myLLGU
	FO7WTV5mQPdDQZKDzQhzrCg
X-Received: by 2002:a05:620a:2617:b0:939:7683:33d5 with SMTP id af79cd13be357-9398037b951mr577132885a.19.1788526580399;
        Fri, 04 Sep 2026 05:56:20 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fb2fd82sm203324985a.17.2026.09.04.05.56.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 05:56:19 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 5/6] NFSv4.1/pnfs: remember when a server needs a larger LAYOUTGET reply buffer
Date: Fri,  4 Sep 2026 08:56:06 -0400
Message-ID: <528a8e5a95daf8e2fd6ad078b8a7892f7dee2cf7.1788453839.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788453839.git.bcodding@hammerspace.com>
References: <cover.1788453839.git.bcodding@hammerspace.com>
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
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/pnfs.c             | 15 ++++++++++++---
 include/linux/nfs_fs_sb.h |  4 ++++
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0c938d17b6c6..3e8d1a1fd827 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1188,10 +1188,12 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
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
@@ -2387,6 +2389,13 @@ pnfs_update_layout(struct inode *ino,
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

