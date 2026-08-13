Received: from mail-ot1-f42.google.com (mail-ot1-f42.google.com [209.85.210.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 076F23314AC
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:41:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653699; cv=none; b=Zh0B06B+K82aI/GcgWyGROibgBcAcr1BWTR2trF8JoAPCS7YFGcYddKPJfH5cMPmjW7/1AdbOTaT3Zs4Bhxkw5644fYy3ZgfCubErQvCky5idjf5Z4qz6yNz5itp1MqHBv3pJI7herKTWcD44jk/T4yeWiL5UU+oSR/A++0BLNI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653699; c=relaxed/simple;
	bh=8T9qH6Ue7HhZ1+TOj6dLYLbpGk5GPGf6Qvxa6NuNaKc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=VkdLdzvzdMbKMnFeEs2NeXhoHtXNWZJcH8yFD4CgIKKg3viirvKkTU7sDzj26rFNsRYcOsIZ2cLgwz1+6uF9nX96MK3c7rL0omwRT5UtyBvyRrd7VoZET503DfPssldHkegrqMGG++f/LfmhBVswKVLi9Kwcvqi3hYsK8KqnzdU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=HSbxGXFh; arc=none smtp.client-ip=209.85.210.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="HSbxGXFh"
Received: by mail-ot1-f42.google.com with SMTP id 46e09a7af769-7ee125ec926so287708a34.2
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:41:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653697; x=1787258497; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=tHhWs4zYCRLNsguF+/vmy2fysO8HLmu/JuFHef0qnMc=;
        b=HSbxGXFhpk56iBEQ+8uL6ylKhJObOxYJnZhYrfio/GNh7v0IWNKplpEMmr44wPB4JG
         NnVIXwEY0FerahuWof0/3ELeXM7Iw1guIMwqssOj3sQgphHjAXoVv1OWzp1UtlHZ43TX
         rfPRDRXGcxGWbVvWrpoPIL2t1q+rfFs1V9kLqnaCfppC1yFfvYWnpLvGlCo7uKtLcQqR
         ViRJ0ftZVTviWgYDuxqh9A085RxSV47dWfB9BKo44Vsx/A2SeIE5/DMb5VKksDxa3vgR
         radQx5p88tHCxQd46kMiQdNe/csiVd1fbBkIhzKWhlKlLd1GjshiL2BwFK4kf4y6pZ4N
         Ge8g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653697; x=1787258497;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=tHhWs4zYCRLNsguF+/vmy2fysO8HLmu/JuFHef0qnMc=;
        b=BDoJ3Q9s84qspbUuAv9AhFUw3O4DXpP78j9YkeyRQtNREQKvwQnTaBVSNHHtZgQnwD
         0orrxdJTpUGx5Wi7OJMAnzXbZvOlL3IKGUgjHWUQOtJrtjsNJ3hKsXUhntIIZZyYkdnC
         wU258xTHYLtSObVD2eN4iYBMlhkTMYVkA8C9cC+yfISMhTTvUI947k4hNB3HMBp+5hw/
         GuxW2kyBqZcMb+2tHlxUCkP1z/dC15UubUV0sK6Ub1qYCD5Ygm+ecRCv95SXu+1B8GS8
         bNR1EUhXffLuQSPc7k8i3xBegaAlxIi9jzkY7EqpniF1jkn+LVeZ0RID91k4eys+PhQH
         01mw==
X-Gm-Message-State: AOJu0Yy/Mi/xOzdP2Lxqwd+lPYaFP4K3e4iZfx5adokqIPFlIfdjzsBg
	Pqmu8rWC0s6pY9wd1Z1bo/3ddbKJ6EIaXSwjo4ZUY6wPF3CojI9DWMysmsEmPCWhhLA=
X-Gm-Gg: AR+sD102rIkZzevxLvyDq4lmj3AKF4CXT4Io1hRZD9lCkFv1ZgBgAYKhuIEnBbh0dcR
	rpcFiqfRNAhZ8H9/r6P7c00LnWCaYiD5xjftOsuqujQgzqHOxVl0oQEdjih1icsYD8cteNjb+3n
	cQBBNHyhCsf0qsC31oo8hCuNIJ9PTN0MvoRAwpIRTFB152xcOlbMXDgLVFFCprkueKByk1LTRJH
	1KbHPScCUh2VJJF3VMFvEuLuO4dG+2cA9rAwB9JUErJgN18+rfpq3pbSKXcHBrNF+pBz1/emuJO
	DxktIiQbvW3VUvD+QCZbyRpsjnw3CrdLzPFfKA6u2ZmVKwfojRozeS2ACTAIyqixpYYkpkp1N+7
	Lr6wiIRJiSL0QOZXXyr4Bvi1l4Jdv3BAf8iU6rvJxtu4LnFlFnllh3ulHkhtkAgkmAtOFWIycTm
	sNF0uae3RlqHOz8izvOpKGwqT7aqF67QAeZYrYQpdxasyLzXd0BbkMkI1QUiiGHWT44c2tZ8BOT
	deLVFL/GVvFctE/lWK9q/z6py13wMg2G7Y=
X-Received: by 2002:a05:6830:6602:b0:7ee:36e8:d0ba with SMTP id 46e09a7af769-7f3de5d783fmr572606a34.11.1786653696681;
        Thu, 13 Aug 2026 13:41:36 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7f3c9e23b6fsm3087958a34.25.2026.08.13.13.41.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:41:36 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 3/6] NFSv4.1/pnfs: retry LAYOUTGET with a larger reply buffer on NFS4ERR_TOOSMALL
Date: Thu, 13 Aug 2026 16:41:28 -0400
Message-ID: <fc0b7acee2bb88de24825e27d6598bbeca9669db.1786653456.git.bcodding@hammerspace.com>
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

Layout drivers cap the LAYOUTGET reply buffer with
max_layoutget_response; the flexfiles driver caps it at a single page,
which limits a striped layout segment to roughly 28 stripes.  A server
striping wider than that returns NFS4ERR_TOOSMALL, and the client
falls back to I/O through the MDS -- pNFS never engages for those
files.

Instead of failing over to the MDS on the first NFS4ERR_TOOSMALL,
retry the LAYOUTGET once with the reply buffer raised to the session's
maximum response size, the same bound GETDEVICEINFO already uses.  The
server offers no size hint in the TOOSMALL error, and the page array
is transient (freed when the RPC completes), so a single jump to the
ceiling is preferred over incremental growth.  If the layout does not
fit even the session-sized buffer, fall back to the MDS as before.

The common path is unchanged: the first LAYOUTGET for a layout is
still sent with the driver's default reply buffer, and larger buffers
are only ever allocated against servers that actually hand out wide
layouts.

Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs.c | 45 ++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 38 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 88deefd45202..b596a65c7ef2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1166,11 +1166,12 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
 	   struct nfs_open_context *ctx,
 	   const nfs4_stateid *stateid,
 	   const struct pnfs_layout_range *range,
-	   gfp_t gfp_flags)
+	   size_t min_reply_sz, gfp_t gfp_flags)
 {
 	struct nfs_server *server = pnfs_find_server(ino, ctx);
 	size_t max_reply_sz = server->pnfs_curr_ld->max_layoutget_response;
-	size_t max_pages = max_response_pages(server);
+	size_t session_pages = max_response_pages(server);
+	size_t max_pages = session_pages;
 	struct nfs4_layoutget *lgp;
 
 	dprintk("--> %s\n", __func__);
@@ -1185,6 +1186,17 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
 			max_pages = npages;
 	}
 
+	/*
+	 * A previous LAYOUTGET for this layout did not fit the reply
+	 * buffer: raise the layout driver's default up to the session's
+	 * maximum response size.
+	 */
+	if (min_reply_sz) {
+		size_t npages = (min_reply_sz + PAGE_SIZE - 1) >> PAGE_SHIFT;
+		if (npages > max_pages)
+			max_pages = min(npages, session_pages);
+	}
+
 	lgp->args.layout.pages = nfs4_alloc_pages(max_pages, gfp_flags);
 	if (!lgp->args.layout.pages) {
 		kfree(lgp);
@@ -2153,6 +2165,7 @@ pnfs_update_layout(struct inode *ino,
 		.inode = ino,
 	};
 	unsigned long giveup = jiffies + (clp->cl_lease_time << 1);
+	size_t reply_sz = 0;
 	bool first;
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino))) {
@@ -2311,7 +2324,8 @@ pnfs_update_layout(struct inode *ino,
 	if (arg.length != NFS4_MAX_UINT64)
 		arg.length = PAGE_ALIGN(arg.length);
 
-	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &stateid, &arg, gfp_flags);
+	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &stateid, &arg, reply_sz,
+					     gfp_flags);
 	if (!lgp) {
 		lseg = ERR_PTR(-ENOMEM);
 		trace_pnfs_update_layout(ino, pos, count, iomode, lo, NULL,
@@ -2338,12 +2352,29 @@ pnfs_update_layout(struct inode *ino,
 			break;
 		case -ENODATA:
 			/* The server returned NFS4ERR_LAYOUTUNAVAILABLE */
-		case -EMSGSIZE:
-			/* The layout exceeded loga_maxcount (NFS4ERR_TOOSMALL) */
 			pnfs_layout_set_fail_bit(
 				lo, pnfs_iomode_to_fail_bit(iomode));
 			lseg = NULL;
 			goto out_put_layout_hdr;
+		case -EMSGSIZE: {
+			/*
+			 * The layout exceeded loga_maxcount (NFS4ERR_TOOSMALL):
+			 * retry once with the reply buffer raised to the
+			 * session's maximum response size before falling back
+			 * to I/O through the MDS.
+			 */
+			size_t max = max_response_pages(server) << PAGE_SHIFT;
+
+			if (reply_sz < max) {
+				reply_sz = max;
+				exception.retry = 1;
+				break;
+			}
+			pnfs_layout_set_fail_bit(
+				lo, pnfs_iomode_to_fail_bit(iomode));
+			lseg = NULL;
+			goto out_put_layout_hdr;
+		}
 		default:
 			if (!nfs_error_is_fatal(PTR_ERR(lseg))) {
 				pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
@@ -2456,7 +2487,7 @@ static void _lgopen_prepare_attached(struct nfs4_opendata *data,
 	lo = _pnfs_grab_empty_layout(ino, ctx);
 	if (!lo)
 		return;
-	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &current_stateid, &rng,
+	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &current_stateid, &rng, 0,
 					     nfs_io_gfp_mask());
 	if (!lgp) {
 		pnfs_clear_first_layoutget(lo);
@@ -2482,7 +2513,7 @@ static void _lgopen_prepare_floating(struct nfs4_opendata *data,
 	};
 	struct nfs4_layoutget *lgp;
 
-	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &current_stateid, &rng,
+	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &current_stateid, &rng, 0,
 					     nfs_io_gfp_mask());
 	if (!lgp)
 		return;
-- 
2.53.0

