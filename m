Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNWANTED_LANGUAGE_BODY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 944FBC282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 22:11:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5082F21855
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 22:11:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OcV0JHZ5"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728236AbfAYWLr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 17:11:47 -0500
Received: from mail-pf1-f196.google.com ([209.85.210.196]:44287 "EHLO
        mail-pf1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726179AbfAYWLr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2019 17:11:47 -0500
Received: by mail-pf1-f196.google.com with SMTP id u6so5331717pfh.11
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2019 14:11:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=us2bHDK3g3XF93RdX+LkN+iJspgd41HpAdODfkus8ZQ=;
        b=OcV0JHZ5wo1u60Bwm9CBwzAOi5W/+OO8t+CjaSi98d1scKTJgMW/VoYAbP2Zl3gzat
         vzt/RBQzk5zVgS09nz4kSHqIK0Mi+XWiV25K3vvtZZ4QeilQBPH1dM7P3Be4liayik3E
         QcLD3/fDbIlYAUxsKuB7JQUDVAtG1XZqp5ztqU+x1GySvT3ekFYG7efHLY5HhnhSulPi
         Ee3QLrCPPjpf80c2QkPgb6gkWtYZxUWD25gOkzyjtMqIS2AhIZ1PJjlnudl0Zyn9fFlL
         FhwffGCEti+Sfk9yWIvXZ4d+FTatYf9AxTF5Jpg0YnYFVZjoI6Hi2psKmFFeXlWf+TM5
         U7iQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=us2bHDK3g3XF93RdX+LkN+iJspgd41HpAdODfkus8ZQ=;
        b=UBcdm/vnl3D9gvtmbmvZYPfv8+3/Ao/bdFmgBTpegSTaxzCREhGDLG2lCQA0Vc8wf6
         AYK0odv5YkZA8UG8MLCI3JxMCrgcDye5C7S0gD584D5vcYFh8j64aV5fA1fr+/CLUtFS
         vsg/vHjfyRfkJB8sIXlv/v+GzUYq13x9Isv6/bhP2/cLJPt27HYHuclRWM/pAg5IPQ8W
         FK6OioVZdNfVdGmlVAoXxkhqcLDbu6UxA78VcNq2xZ/bsVqX8kewInABWgDw1eZmSfWl
         UhP0gLNQ0pu6ftILpGV2uGE2XXHZS+QbXbap47CtNz+2UwUpnvcrCxQlVOiOTuJiyTOZ
         t/Uw==
X-Gm-Message-State: AJcUukdpEuI5P0J8tCCZyJb9oVfbG7cYtOICRWYFzCgbifDmgWR6xiIR
        blKLPRlYxec2jYL8f8VVUnZSMRTL
X-Google-Smtp-Source: ALg8bN6xmt16h3nFLQCQauOaxd7Wsh5+/aD2ZjJwF5bmmv5DI4tM1zUDVkAkvu/UTkUhOO8nh7d1ng==
X-Received: by 2002:a62:da5a:: with SMTP id w26mr12697860pfl.106.1548454306251;
        Fri, 25 Jan 2019 14:11:46 -0800 (PST)
Received: from seurat.1015granger.net ([148.87.23.44])
        by smtp.gmail.com with ESMTPSA id m3sm54276395pff.173.2019.01.25.14.11.45
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 14:11:45 -0800 (PST)
Subject: [PATCH RFC 5/5] NFS: Add trace events to report non-zero NFS status
 codes
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Fri, 25 Jan 2019 17:11:25 -0500
Message-ID: <154845426495.70638.4642038290001399722.stgit@seurat.1015granger.net>
In-Reply-To: <154845390550.70638.13083502621745566898.stgit@seurat.1015granger.net>
References: <154845390550.70638.13083502621745566898.stgit@seurat.1015granger.net>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

These can help field troubleshooting without needing the overhead
of a full network capture (ie, tcpdump).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs2xdr.c   |    7 ++++
 fs/nfs/nfs3xdr.c   |    7 ++++
 fs/nfs/nfs4trace.h |   25 +++++++++++++++
 fs/nfs/nfs4xdr.c   |   12 +++++--
 fs/nfs/nfstrace.c  |    1 +
 fs/nfs/nfstrace.h  |   85 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 133 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 76614311f957..bac3a4e2cb5d 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -22,6 +22,7 @@
 #include <linux/nfs.h>
 #include <linux/nfs2.h>
 #include <linux/nfs_fs.h>
+#include "nfstrace.h"
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
@@ -145,7 +146,13 @@ static int decode_stat(struct xdr_stream *xdr, enum nfs_stat *status)
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		return -EIO;
+	if (unlikely(*p != cpu_to_be32(NFS_OK)))
+		goto out_status;
+	*status = 0;
+	return 0;
+out_status:
 	*status = be32_to_cpup(p);
+	trace_nfs_xdr_status((int)*status);
 	return 0;
 }
 
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index e5619803a4f6..4aa3ffe1800e 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -21,6 +21,7 @@
 #include <linux/nfs3.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfsacl.h>
+#include "nfstrace.h"
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
@@ -337,7 +338,13 @@ static int decode_nfsstat3(struct xdr_stream *xdr, enum nfs_stat *status)
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		return -EIO;
+	if (unlikely(*p != cpu_to_be32(NFS3_OK)))
+		goto out_status;
+	*status = 0;
+	return 0;
+out_status:
 	*status = be32_to_cpup(p);
+	trace_nfs_xdr_status((int)*status);
 	return 0;
 }
 
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index b4557cf685fb..cd1a5c08da9a 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -524,6 +524,31 @@ TRACE_EVENT(nfs4_setup_sequence,
 		)
 );
 
+TRACE_EVENT(nfs4_xdr_status,
+		TP_PROTO(
+			u32 op,
+			int error
+		),
+
+		TP_ARGS(op, error),
+
+		TP_STRUCT__entry(
+			__field(u32, op)
+			__field(int, error)
+		),
+
+		TP_fast_assign(
+			__entry->op = op;
+			__entry->error = -error;
+		),
+
+		TP_printk(
+			"operation %d: nfs status %d (%s)",
+			__entry->op,
+			__entry->error, show_nfsv4_errors(__entry->error)
+		)
+);
+
 DECLARE_EVENT_CLASS(nfs4_open_event,
 		TP_PROTO(
 			const struct nfs_open_context *ctx,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 24e6a45a5726..38a4cbc18657 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -54,6 +54,7 @@
 #include <linux/nfs_fs.h>
 
 #include "nfs4_fs.h"
+#include "nfs4trace.h"
 #include "internal.h"
 #include "nfs4idmap.h"
 #include "nfs4session.h"
@@ -3188,11 +3189,14 @@ static bool __decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected,
 	opnum = be32_to_cpup(p++);
 	if (unlikely(opnum != expected))
 		goto out_bad_operation;
+	if (unlikely(*p != cpu_to_be32(NFS_OK)))
+		goto out_status;
+	*nfs_retval = 0;
+	return true;
+out_status:
 	nfserr = be32_to_cpup(p);
-	if (nfserr == NFS_OK)
-		*nfs_retval = 0;
-	else
-		*nfs_retval = nfs4_stat_to_errno(nfserr);
+	trace_nfs4_xdr_status(opnum, nfserr);
+	*nfs_retval = nfs4_stat_to_errno(nfserr);
 	return true;
 out_bad_operation:
 	dprintk("nfs: Server returned operation"
diff --git a/fs/nfs/nfstrace.c b/fs/nfs/nfstrace.c
index b60d5fbd7727..a90b363500c2 100644
--- a/fs/nfs/nfstrace.c
+++ b/fs/nfs/nfstrace.c
@@ -11,3 +11,4 @@
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(nfs_fsync_enter);
 EXPORT_TRACEPOINT_SYMBOL_GPL(nfs_fsync_exit);
+EXPORT_TRACEPOINT_SYMBOL_GPL(nfs_xdr_status);
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index bd60f8d1e181..a0d6910aa03a 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -969,6 +969,91 @@ TRACE_EVENT(nfs_commit_done,
 		)
 );
 
+TRACE_DEFINE_ENUM(NFS_OK);
+TRACE_DEFINE_ENUM(NFSERR_PERM);
+TRACE_DEFINE_ENUM(NFSERR_NOENT);
+TRACE_DEFINE_ENUM(NFSERR_IO);
+TRACE_DEFINE_ENUM(NFSERR_NXIO);
+TRACE_DEFINE_ENUM(NFSERR_ACCES);
+TRACE_DEFINE_ENUM(NFSERR_EXIST);
+TRACE_DEFINE_ENUM(NFSERR_XDEV);
+TRACE_DEFINE_ENUM(NFSERR_NODEV);
+TRACE_DEFINE_ENUM(NFSERR_NOTDIR);
+TRACE_DEFINE_ENUM(NFSERR_ISDIR);
+TRACE_DEFINE_ENUM(NFSERR_INVAL);
+TRACE_DEFINE_ENUM(NFSERR_FBIG);
+TRACE_DEFINE_ENUM(NFSERR_NOSPC);
+TRACE_DEFINE_ENUM(NFSERR_ROFS);
+TRACE_DEFINE_ENUM(NFSERR_MLINK);
+TRACE_DEFINE_ENUM(NFSERR_NAMETOOLONG);
+TRACE_DEFINE_ENUM(NFSERR_NOTEMPTY);
+TRACE_DEFINE_ENUM(NFSERR_DQUOT);
+TRACE_DEFINE_ENUM(NFSERR_STALE);
+TRACE_DEFINE_ENUM(NFSERR_REMOTE);
+TRACE_DEFINE_ENUM(NFSERR_WFLUSH);
+TRACE_DEFINE_ENUM(NFSERR_BADHANDLE);
+TRACE_DEFINE_ENUM(NFSERR_NOT_SYNC);
+TRACE_DEFINE_ENUM(NFSERR_BAD_COOKIE);
+TRACE_DEFINE_ENUM(NFSERR_NOTSUPP);
+TRACE_DEFINE_ENUM(NFSERR_TOOSMALL);
+TRACE_DEFINE_ENUM(NFSERR_SERVERFAULT);
+TRACE_DEFINE_ENUM(NFSERR_BADTYPE);
+TRACE_DEFINE_ENUM(NFSERR_JUKEBOX);
+
+#define nfs_show_status(x) \
+	__print_symbolic(x, \
+			{ NFS_OK, "OK" }, \
+			{ NFSERR_PERM, "PERM" }, \
+			{ NFSERR_NOENT, "NOENT" }, \
+			{ NFSERR_IO, "IO" }, \
+			{ NFSERR_NXIO, "NXIO" }, \
+			{ NFSERR_ACCES, "ACCES" }, \
+			{ NFSERR_EXIST, "EXIST" }, \
+			{ NFSERR_XDEV, "XDEV" }, \
+			{ NFSERR_NODEV, "NODEV" }, \
+			{ NFSERR_NOTDIR, "NOTDIR" }, \
+			{ NFSERR_ISDIR, "ISDIR" }, \
+			{ NFSERR_INVAL, "INVAL" }, \
+			{ NFSERR_FBIG, "FBIG" }, \
+			{ NFSERR_NOSPC, "NOSPC" }, \
+			{ NFSERR_ROFS, "ROFS" }, \
+			{ NFSERR_MLINK, "MLINK" }, \
+			{ NFSERR_NAMETOOLONG, "NAMETOOLONG" }, \
+			{ NFSERR_NOTEMPTY, "NOTEMPTY" }, \
+			{ NFSERR_DQUOT, "DQUOT" }, \
+			{ NFSERR_STALE, "STALE" }, \
+			{ NFSERR_REMOTE, "REMOTE" }, \
+			{ NFSERR_WFLUSH, "WFLUSH" }, \
+			{ NFSERR_BADHANDLE, "BADHANDLE" }, \
+			{ NFSERR_NOT_SYNC, "NOTSYNC" }, \
+			{ NFSERR_BAD_COOKIE, "BADCOOKIE" }, \
+			{ NFSERR_NOTSUPP, "NOTSUPP" }, \
+			{ NFSERR_TOOSMALL, "TOOSMALL" }, \
+			{ NFSERR_SERVERFAULT, "REMOTEIO" }, \
+			{ NFSERR_BADTYPE, "BADTYPE" }, \
+			{ NFSERR_JUKEBOX, "JUKEBOX" })
+
+TRACE_EVENT(nfs_xdr_status,
+		TP_PROTO(
+			int error
+		),
+
+		TP_ARGS(error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+		),
+
+		TP_fast_assign(
+			__entry->error = error;
+		),
+
+		TP_printk(
+			"error=%d (%s)",
+			__entry->error, nfs_show_status(__entry->error)
+		)
+);
+
 #endif /* _TRACE_NFS_H */
 
 #undef TRACE_INCLUDE_PATH

