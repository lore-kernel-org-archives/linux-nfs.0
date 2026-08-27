Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 428744D8D88
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 18:51:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787856698; cv=none; b=t+qgEG7iPbrO77MI0eDNmuAs2p5Kn+ErlWqWnsLS6HqU/Pmo+UJ01elYXB04u3OK8cPP0/IMQeJSMJ2jKlNE1WAbPrXpkjJQeWI44XKMCzH6kUJmU68dUh59lJc6nvAqQGUGs+6XybIi564o50MgzmTqnM0b9JKZm0gxfhgzReQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787856698; c=relaxed/simple;
	bh=vsx4WXQjzMsb2ZBjmzvZd2zpjUzfm9pdFZqSGatoTvU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=lfGRI80X/b160lAtPBV29I5GbqowMpl+vVueCrPYE8bYo2SAu9/iGY8RpLQK/VbU+g2YQOpHWNDbanaJTCFYOnWzUuAm1ONMsr9L2cosHj0zMCkeZDvIMfvFRTFuVqolONKrlYhmKT+vOEWfoHjEPeeOMFtbfay3OGR2zS1hbI4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FwEg+GBc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FwEg+GBc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 347821F000E9;
	Thu, 27 Aug 2026 18:51:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787856695;
	bh=auDKqc/+CtPE+bRKBKHiqsml9RIRt68sxezoiuMtRJQ=;
	h=From:To:Cc:Subject:Date;
	b=FwEg+GBcfxICyGmEPxf85PSqyOWbPlL0zld0jj6HrDcESYKrSL4U9jfipsl13YiQg
	 PpTQkH/lH18Q+EyXsolcL6K2PZRXj+AeoDJKJ+jYJdbGNjV8WpqnfixtujvcG7IY3h
	 ydE/pPIDxdfYZ5fFqr4nObNIkA/8Riny+9acDNey8I30Q3rHztheay3VuCigHzlBeI
	 zRUEqCWbBwHRowSrDJneS41RgjqAbMDdGub4kHWTcbHlNN/G3k7LvM4NBz4bcVjETj
	 +m5CG5aN9SpX0v/hgToStoLWye1le5zZQsxW+K6lJKqHl0R68a9k6ATDNURgsSQF+H
	 5L09BOq6Mz7tQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSD: Replace the use of include/trace/misc/nfs.h
Date: Thu, 27 Aug 2026 14:51:34 -0400
Message-ID: <20260827185134.197322-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

fs/nfsd/trace.h includes include/trace/misc/nfs.h for
show_nfs4_seq4_status() and show_rca_mask(). That header pulls in
linux/nfs.h, so every NFSD translation unit that reads trace.h also
sees the NFS_OK, NFSERR_*, and file-type enumerators.

I'm about to switch fs/nfsd/nfserr.h to an xdrgen-generated header,
which defines enum nfsstat and enum ftype with those same names. Any
translation unit that includes both headers then fails to build with
enumerator redefinition errors.

To address this, stop including trace/misc/nfs.h in fs/nfsd/trace.h.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/trace.h          | 45 +++++++++++++++++++++++++++++++++++++++-
 include/trace/misc/nfs.h | 22 --------------------
 2 files changed, 44 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 7d7a1483109a..2ae7f150a72c 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -13,7 +13,6 @@
 #include <linux/sunrpc/xprt.h>
 #include <trace/misc/fs.h>
 #include <trace/misc/fsnotify.h>
-#include <trace/misc/nfs.h>
 #include <trace/misc/sunrpc.h>
 
 #include "export.h"
@@ -790,6 +789,20 @@ TRACE_EVENT(nfsd_stateowner_replay,
 		__entry->opnum, __entry->status)
 );
 
+#define show_nfs4_seq4_status(x) \
+	__print_flags(x, "|", \
+		{ SEQ4_STATUS_CB_PATH_DOWN,		"CB_PATH_DOWN" }, \
+		{ SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING,	"CB_GSS_CONTEXTS_EXPIRING" }, \
+		{ SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED,	"CB_GSS_CONTEXTS_EXPIRED" }, \
+		{ SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED, "EXPIRED_ALL_STATE_REVOKED" }, \
+		{ SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED, "EXPIRED_SOME_STATE_REVOKED" }, \
+		{ SEQ4_STATUS_ADMIN_STATE_REVOKED,	"ADMIN_STATE_REVOKED" }, \
+		{ SEQ4_STATUS_RECALLABLE_STATE_REVOKED,	"RECALLABLE_STATE_REVOKED" }, \
+		{ SEQ4_STATUS_LEASE_MOVED,		"LEASE_MOVED" }, \
+		{ SEQ4_STATUS_RESTART_RECLAIM_NEEDED,	"RESTART_RECLAIM_NEEDED" }, \
+		{ SEQ4_STATUS_CB_PATH_DOWN_SESSION,	"CB_PATH_DOWN_SESSION" }, \
+		{ SEQ4_STATUS_BACKCHANNEL_FAULT,	"BACKCHANNEL_FAULT" })
+
 TRACE_EVENT_CONDITION(nfsd_seq4_status,
 	TP_PROTO(
 		const struct svc_rqst *rqstp,
@@ -1694,6 +1707,14 @@ TRACE_EVENT(nfsd_cb_setup_err,
 /* Not a real opcode, but there is no 0 operation. */
 #define _CB_NULL	0
 
+TRACE_DEFINE_ENUM(OP_CB_GETATTR);
+TRACE_DEFINE_ENUM(OP_CB_RECALL);
+TRACE_DEFINE_ENUM(OP_CB_LAYOUTRECALL);
+TRACE_DEFINE_ENUM(OP_CB_RECALL_ANY);
+TRACE_DEFINE_ENUM(OP_CB_NOTIFY);
+TRACE_DEFINE_ENUM(OP_CB_NOTIFY_LOCK);
+TRACE_DEFINE_ENUM(OP_CB_OFFLOAD);
+
 #define show_nfsd_cb_opcode(val)					\
 	__print_symbolic(val,						\
 		{ _CB_NULL,			"CB_NULL" },		\
@@ -1918,6 +1939,28 @@ TRACE_EVENT(nfsd_cb_offload,
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
+#define show_rca_mask(x) \
+	__print_flags(x, "|", \
+		{ BIT(RCA4_TYPE_MASK_RDATA_DLG),	"RDATA_DLG" }, \
+		{ BIT(RCA4_TYPE_MASK_WDATA_DLG),	"WDATA_DLG" }, \
+		{ BIT(RCA4_TYPE_MASK_DIR_DLG),		"DIR_DLG" }, \
+		{ BIT(RCA4_TYPE_MASK_FILE_LAYOUT),	"FILE_LAYOUT" }, \
+		{ BIT(RCA4_TYPE_MASK_BLK_LAYOUT),	"BLK_LAYOUT" }, \
+		{ BIT(RCA4_TYPE_MASK_OBJ_LAYOUT_MIN),	"OBJ_LAYOUT_MIN" }, \
+		{ BIT(RCA4_TYPE_MASK_OBJ_LAYOUT_MAX),	"OBJ_LAYOUT_MAX" }, \
+		{ BIT(RCA4_TYPE_MASK_OTHER_LAYOUT_MIN),	"OTHER_LAYOUT_MIN" }, \
+		{ BIT(RCA4_TYPE_MASK_OTHER_LAYOUT_MAX),	"OTHER_LAYOUT_MAX" })
+
 TRACE_EVENT(nfsd_cb_recall_any,
 	TP_PROTO(
 		const struct nfsd4_cb_recall_any *ra
diff --git a/include/trace/misc/nfs.h b/include/trace/misc/nfs.h
index 27781bd7a3f7..3146813fc4fe 100644
--- a/include/trace/misc/nfs.h
+++ b/include/trace/misc/nfs.h
@@ -359,28 +359,6 @@ TRACE_DEFINE_ENUM(IOMODE_ANY);
 		{ IOMODE_RW,			"RW" }, \
 		{ IOMODE_ANY,			"ANY" })
 
-TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_RDATA_DLG);
-TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_WDATA_DLG);
-TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_DIR_DLG);
-TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_FILE_LAYOUT);
-TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_BLK_LAYOUT);
-TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_OBJ_LAYOUT_MIN);
-TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_OBJ_LAYOUT_MAX);
-TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_OTHER_LAYOUT_MIN);
-TRACE_DEFINE_ENUM(RCA4_TYPE_MASK_OTHER_LAYOUT_MAX);
-
-#define show_rca_mask(x) \
-	__print_flags(x, "|", \
-		{ BIT(RCA4_TYPE_MASK_RDATA_DLG),	"RDATA_DLG" }, \
-		{ BIT(RCA4_TYPE_MASK_WDATA_DLG),	"WDATA_DLG" }, \
-		{ BIT(RCA4_TYPE_MASK_DIR_DLG),		"DIR_DLG" }, \
-		{ BIT(RCA4_TYPE_MASK_FILE_LAYOUT),	"FILE_LAYOUT" }, \
-		{ BIT(RCA4_TYPE_MASK_BLK_LAYOUT),	"BLK_LAYOUT" }, \
-		{ BIT(RCA4_TYPE_MASK_OBJ_LAYOUT_MIN),	"OBJ_LAYOUT_MIN" }, \
-		{ BIT(RCA4_TYPE_MASK_OBJ_LAYOUT_MAX),	"OBJ_LAYOUT_MAX" }, \
-		{ BIT(RCA4_TYPE_MASK_OTHER_LAYOUT_MIN),	"OTHER_LAYOUT_MIN" }, \
-		{ BIT(RCA4_TYPE_MASK_OTHER_LAYOUT_MAX),	"OTHER_LAYOUT_MAX" })
-
 #define show_nfs4_seq4_status(x) \
 	__print_flags(x, "|", \
 		{ SEQ4_STATUS_CB_PATH_DOWN,		"CB_PATH_DOWN" }, \
-- 
2.55.0

