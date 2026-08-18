Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D0723E5585
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 18:41:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787078514; cv=none; b=NX5B+mfPiOx4ueF/xrU8BgAIweH8vY5X/GivIf3xkF/EVl2Qd/yOE8Ux6ty5RGL3mlkENXKjUbWDr+Vls9chzpR5j/t4X8b3ql8EtKtqaxsdYw/j6AflzhPrL2o37hIOPNYmwZ6mlRsuINUKtk3Km90X2WGLM25ZK6toqXxN+H4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787078514; c=relaxed/simple;
	bh=oaM7nbeZ9VWvOIEc1GlP3Xc/+AiPifymn9uMEIcqs+8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=EvJGLCXUZofGIFE63umAPPg1QzZuruWgom3Yjrrf4E6UZ6Uq0Bh2mpL0rAYyGWQizdmi5gbJTKM6ZVHG2kBioVSHSK4by/LVd+0ckfgEBx3HWdHhGxTe6W71+AM9RdmOULXHmww9tLZfBss8jddF/VfUyuVDoUOB9rc4WuEV1xE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NYeicUdl; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NYeicUdl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D6A991F000E9;
	Tue, 18 Aug 2026 18:41:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787078513;
	bh=wHK1CbjwTvL09e4lsT8CWB2wNj9VbEZh9cJOM9T3m+0=;
	h=From:To:Cc:Subject:Date;
	b=NYeicUdl4XVD0kMqtBPSXrhehaCG0X57zLaUVLAltIMN7Jm3AcLbFblY3NQOwDCOc
	 p+A1fF0SKtQ/B/CT6S1dPvMcxT+6oZszIjoiRDkyqYblRb5qgwwJFy1tzPCLNA5Jpg
	 iGU+Hf4pb+kOvmZ5ewDQuQlm5mDtXLauNXNfmj85ab/11PPhm0GCZFchIrKVPi22e0
	 UbEFjLGce1dthg/hTJ7Gf9ZPxlErIeIqfEaNJIvzMTeoB/4TpNxNhIHuZQGyQ1sFoJ
	 iI7x0rFBtU3mI0GjdhcNKymmvb69zI3qs0PLR6MkYmYBp/Ivv2jFmyMDwfPw+63PBY
	 MMPmGrUfrjR4Q==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSD: Resolve the recall-any mask names in the trace format
Date: Tue, 18 Aug 2026 14:41:51 -0400
Message-ID: <20260818184151.31180-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

RCA4_TYPE_MASK_* are enum constants, so the preprocessor cannot fold
them into the print format that show_rca_mask() builds for the
nfsd_cb_recall_any event. Nothing declares an eval map for them
either, so trace_event_eval_update() has no substitution to apply at
module load, and the event's format file ships the enumerator names
verbatim. trace-cmd and perf cannot decode the bmval0 field.

Declare the eval maps for the nine mask bits show_rca_mask() decodes.
The format then carries the shift counts as integers, the same shape
the SUNRPC trace points already emit from their BIT() flag decoders.

Fixes: 638593be55c0 ("NFSD: add CB_RECALL_ANY tracepoints")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/trace.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 3fa4d63cd30f..4fb1f32a3787 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1946,6 +1946,16 @@ TRACE_EVENT(nfsd_cb_offload,
 		__entry->fh_hash, __entry->count, __entry->status)
 );
 
+TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_RDATA_DLG);
+TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_WDATA_DLG);
+TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_DIR_DLG);
+TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_FILE_LAYOUT);
+TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_BLK_LAYOUT);
+TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_OBJ_LAYOUT_MIN);
+TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_OBJ_LAYOUT_MAX);
+TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_OTHER_LAYOUT_MIN);
+TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_OTHER_LAYOUT_MAX);
+
 #define show_rca_mask(x) \
 	__print_flags(x, "|", \
 		{ BIT(RCA4_TYPE_MASK_RDATA_DLG),	"RDATA_DLG" }, \
-- 
2.54.0

