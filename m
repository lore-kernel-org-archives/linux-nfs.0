Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNWANTED_LANGUAGE_BODY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D5C7C282CE
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 38B74218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:24:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uQpghJWN"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728226AbfBKQYa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:24:30 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:39230 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727620AbfBKQYa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:24:30 -0500
Received: by mail-it1-f196.google.com with SMTP id a6so27610218itl.4;
        Mon, 11 Feb 2019 08:24:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=j1T7XJ1FRRHWScn57cfBx1R8i9beLTzMK0Q98w9Jvxc=;
        b=uQpghJWNLAyzfxidB/peq7sNxAcFq2u2L187QCjNVkHh6mja06CJ91uSS45mcBqaHT
         /+g+tNU0vdMfKNilthn8C/4hYhvDIPZlXphOzs7pc8ly2j+5Xp9l7Tzdnj9EsXHfNfv4
         I5cF3RpDwh6obG5fTs+ktr1YaIDmDxglyzo4qqRdUXjVWIjJA5Cnixb6SvVVRtCGNwz3
         UsP/O7rkOMXQNECM6Msf76ImUxu/aXEa3PyUd4SogU/fK5/1tpvcrkf5v2Rv+fXaJgSn
         biFWY16h/AXyxB3YZvluyh1s44m34JldixrFhPWi360I3Ogf+FUvLHEezIQdmm8rOLqm
         xQiA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=j1T7XJ1FRRHWScn57cfBx1R8i9beLTzMK0Q98w9Jvxc=;
        b=qrcmfI9qCPv8vcALrY0h4YHuzrKCLdSwSz5bs3S37SzRl9KIm2jM0P6vRe5olKYMD+
         d+VzB/xmlV0iEIt1rGHbKioDm0l4zFmuLgmf7V3tZ+3JycIl/GBLnoEcZr2326IjcNQ6
         /5kqVw0pTXrA/xc00jfehA0r87p07jxslS4s/8dekFG9zVttYOIK5HmsiT+RgnnvR6AK
         GGJLagVHr1j1S6zvYb4AK1HLZ2HV2LZ/a8NYPxWugOwawL/8M4hDLvFTbCVAAZTA8Wyh
         8gQEzSCwqyglFxBPPEIlGq38q3m6e7PgLPBKxsW/v66jCSlXc3ZqiaLYzg69RUAUFSPq
         IfzQ==
X-Gm-Message-State: AHQUAuZyUWjq1Xr7u0TvCjbxrpcc+1WKR7cz3yB4kcOjuZWLaezj1G/Z
        qPpwN59xGCGBc2SJOtgMz6RqiJAQ
X-Google-Smtp-Source: AHgI3IZilUb8a4RQinIjgjifzXrfK8YaQRbNE+NLmDMuagixRp2Vk2/uSj688tApdlWrAv7Hs1tRug==
X-Received: by 2002:a24:c601:: with SMTP id j1mr216655itg.130.1549902268257;
        Mon, 11 Feb 2019 08:24:28 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id v19sm5292156itb.0.2019.02.11.08.24.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:24:27 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGOQ06029979;
        Mon, 11 Feb 2019 16:24:26 GMT
Subject: [PATCH v1 09/23] NFS: Add trace events to report non-zero NFS
 status codes
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:24:26 -0500
Message-ID: <20190211162426.2817.69452.stgit@manet.1015granger.net>
In-Reply-To: <20190211161920.2817.20881.stgit@manet.1015granger.net>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
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
index 7661431..bac3a4e 100644
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
index e561980..4aa3ffe 100644
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
index b4557cf..cd1a5c0 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -524,6 +524,31 @@
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
index 24e6a45..38a4cbc 100644
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
index b60d5fb..a90b363 100644
--- a/fs/nfs/nfstrace.c
+++ b/fs/nfs/nfstrace.c
@@ -11,3 +11,4 @@
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(nfs_fsync_enter);
 EXPORT_TRACEPOINT_SYMBOL_GPL(nfs_fsync_exit);
+EXPORT_TRACEPOINT_SYMBOL_GPL(nfs_xdr_status);
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index bd60f8d..a0d6910 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -969,6 +969,91 @@
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

