Received: from mail-qk1-f180.google.com (mail-qk1-f180.google.com [209.85.222.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A0734908CB
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 12:56:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.180
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788526580; cv=none; b=Vj/DINhuKBYp7Jk9i2IyS+KX3TWHS2FJ+CisyaIRbWHWDnxT6qg87sj5oAyglBVOZPtlv6Avj626pJy8xSqMH2+jfUICk40NiEDUbVHmmuhgeRddwgY32O3PA+NILF3NPdAhp/CdMzBBjlItRSXTQ3JRPccipC0o2Cwt/DUXjrQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788526580; c=relaxed/simple;
	bh=n2BX1B7oRCpzM1rO4grX4N2gwz10rYIIiwindX7va6M=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Enuk/BFzuMjsVMadULoeocciKEi4LEZMjAXhjBL51574ushb5GuD0cDk1vpOtJFpfxfYtGsOPyIPte1wU26/6lhbw5L++KQewQMmpEcJHDdza/NwJxY/Xx6rqeKhvXxKWbaxLQfb2YMN7VI7WQ7DJDxuVapttlOU/6KMMHgiI1o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=jauR0+CB; arc=none smtp.client-ip=209.85.222.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="jauR0+CB"
Received: by mail-qk1-f180.google.com with SMTP id af79cd13be357-9391e3b21fbso92152185a.2
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 05:56:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788526578; x=1789131378; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=PVfBlCHL5+VJJ9p4yy6bsq5ucfijkLK8oIyHP+RuiSM=;
        b=jauR0+CB6yCrdS1jQg2vLd5rEIpGgzE+05OOIWMuM6o0POOt15WPKeGrbDX4O2KIuM
         3jLR8jIbX9Xca8m+Hoz+9MfbLDOHtZNCDPpHrYL8a6D7H9AWg4BxA2S97FQ9BUmt3hba
         Hhmt2KwTPmZpjlRkoIueEkuGyOUz0f1aTHYtLZ3UW7++noDHC9UgZXTI+BK/Rd4FQuVu
         aYU6OO8AQBtXbo8ItlzeovYZQdGFkv9gfL5Gzb93ErLppvPaCFdMaYVfbUKStJWCN1em
         l4J6InuLe+eeguMwcgNoXXs5sUucFHwciIYsc8H01INK4luGn0n754tGeXDQ5TWsvynf
         Vmkw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788526578; x=1789131378;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=PVfBlCHL5+VJJ9p4yy6bsq5ucfijkLK8oIyHP+RuiSM=;
        b=lVAQdtj3xihLIRBStftglns4egbsp+lQ27X3q8sxpgD3wf1kQt7dGo4CmlqpbllKwI
         W/ZQ5pghe/YvK96B9JewG0wruPx5hQbDDvEqhnVoYbq9C668yCe+bGTHIPje2CIBYBFI
         kfZfnFEobGQqKVDVpaDUimyMRMRdMWnbk/isxOKp2QBdzqn6YvwZel6WJUpJcI1gn9UP
         sA9nBdJynzSFqd7Te24YiUmtX5uAgQFN75c/o/y6cqkAuYtiUQPICgz26WKpAuxsPJ3T
         U4mqP/1PzObFlXfnLcJYuyJBv4/gy2qpuNa6MOZL01ceiHm+4XSU3vZhOgj1+0hFgqx1
         WJeg==
X-Gm-Message-State: AFuF++lmQ1fCwN8bTB72ZnuhTirShaNwKUof6nRWDZW2MNCzcgo3SlBK
	MwYAnn+aYH/Rx0+T8GEsUTXPqGaZPIKt6oJvnDo7P2zzP3ALbjg955mAnrRHoZzcWsSSxjiRmCg
	nG3oq
X-Gm-Gg: AYBFou2gNfKjNcJ+73tKMkVvAj/fEOUL9vgqiDnXOzIAuBqHKhWnuY++Tbn3R7JH/AP
	aMhMV3LKBXUKD17gw2eWMKR8ihc8A4Ip9O5+kVXyQ2KlBsWx87D8cuJ23FZo+cHZpV9ujTe5KC7
	4le0wwLuxrrIBYEAXuvTJdD8/wRCmBKstH6HPAl93x3gisDBqn4S5KHY1ydQ7/rdnsLKjWcnPc/
	/JAH1w23Gkir7sI+yCXTmaLg+5c0n+g5u/MqndfCS31U/bZ7jD7HaQ6hm4X5M86uGpG4MYbijXh
	YcKuIcUI+XRJ9NpnklsLBibIlLjer/aHkWYd3t5Sn5ZzfYF/No2pUPG6zxVAq27+/A26HHDZAPN
	URlgjbn2rUud8rGyl1q8IgGidO0sX9A2z3+k4H950QrqT1RysbsYd1NnC50USgzMfjaq3bCUZXr
	zFZDaFGc721CHqZJQvIPmOdN6F3GsSvKQ0fqYVZUgNf5lUbmI5R4k9enPTwlRoagNoqPExLSCHw
	+ELCcJXO2NbvUiYcjkqxR/xUHCrFalWIg8=
X-Received: by 2002:a05:620a:234:b0:939:4b31:4669 with SMTP id af79cd13be357-93980434d0bmr460127885a.29.1788526577923;
        Fri, 04 Sep 2026 05:56:17 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fb2fd82sm203324985a.17.2026.09.04.05.56.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 05:56:17 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 3/6] NFSv4.1/pnfs: retry LAYOUTGET with a larger reply buffer on NFS4ERR_TOOSMALL
Date: Fri,  4 Sep 2026 08:56:04 -0400
Message-ID: <0491c3c0d70a4d1f79f92ec828e526116dc3121c.1788453839.git.bcodding@hammerspace.com>
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
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/pnfs.c | 45 ++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 38 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9bef2997f512..0c938d17b6c6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1167,11 +1167,12 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
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
@@ -1186,6 +1187,17 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
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
@@ -2145,6 +2157,7 @@ pnfs_update_layout(struct inode *ino,
 		.inode = ino,
 	};
 	unsigned long giveup = jiffies + (clp->cl_lease_time << 1);
+	size_t reply_sz = 0;
 	bool first;
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino))) {
@@ -2304,7 +2317,8 @@ pnfs_update_layout(struct inode *ino,
 	if (arg.length != NFS4_MAX_UINT64)
 		arg.length = PAGE_ALIGN(arg.length);
 
-	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &stateid, &arg, gfp_flags);
+	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &stateid, &arg, reply_sz,
+					     gfp_flags);
 	if (!lgp) {
 		lseg = ERR_PTR(-ENOMEM);
 		trace_pnfs_update_layout(ino, pos, count, iomode, lo, NULL,
@@ -2331,12 +2345,29 @@ pnfs_update_layout(struct inode *ino,
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
@@ -2450,7 +2481,7 @@ static void _lgopen_prepare_attached(struct nfs4_opendata *data,
 	lo = _pnfs_grab_empty_layout(ino, ctx);
 	if (!lo)
 		return;
-	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &current_stateid, &rng,
+	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &current_stateid, &rng, 0,
 					     nfs_io_gfp_mask());
 	if (!lgp) {
 		clear_and_wake_up_bit(NFS_LAYOUT_FIRST_LAYOUTGET, &lo->plh_flags);
@@ -2476,7 +2507,7 @@ static void _lgopen_prepare_floating(struct nfs4_opendata *data,
 	};
 	struct nfs4_layoutget *lgp;
 
-	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &current_stateid, &rng,
+	lgp = pnfs_alloc_init_layoutget_args(ino, ctx, &current_stateid, &rng, 0,
 					     nfs_io_gfp_mask());
 	if (!lgp)
 		return;
-- 
2.53.0

