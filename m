Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B13A7379EFF
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 18:41:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784313679; cv=none; b=fsIrvEJrO6vqsXmS4Z1WvErX2tuN0GabqxvFCv4zGpH5J4aNOznoD2Pe8HyjVMXd7pMWRzvUuTrj+BSRb5IiUL2R8zq7QKpE+sNouN6WENJcYp3m86sC+3lBsqix9qf2DZHf/dq/Wsn0ZM9wyV/FRBSkz87PkbvbvkvogTZCpw4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784313679; c=relaxed/simple;
	bh=2w0BINObo+vwwD8t+vQu1c0C80+RRk8IJbAGDgayf3g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uNHawyruZwm81Ydta02gpoFdWrQK6k2AX1nlF8fKSCF6ErZxK/pbNCd9n//xKOE85ZW8yvQzusT6BA3p7yQCMqD1Xj4nv18kVNATKyY8fGO86aZPXLxGbjUICODsla5/TyjtsGkPNq5p9i+qJ+xD8Hd0DSeevj4qgkdeYnPF/yw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aIyNQPBi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aIyNQPBi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DB5801F00A3F;
	Fri, 17 Jul 2026 18:41:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784313677;
	bh=9S3jVfQaleg0wNLnJz6Frn1f3ZXGjxeyakzj5axVSFo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=aIyNQPBi7sakdz37xygb2wrphI5GJ6MCKXaCbHV5hsQJmhLtYHkvUNUfAQdFaUnlp
	 O0+Nh+xoR7Gm4jlLV1+JNNlG+8CrRTNvrOjY+qx0+//wv4qZVuIsOG4UoEC53qLkeC
	 yOgRGqpTjFlBo5WKZMMOn92c6pfFl4erLN6G462Ur7Ha00bObP/f98wLXHVge4wYNf
	 TBEDFpjiJ1zkD8HTOsz8cjSH80SGRnga7vwN8yHa007k/sdTloDqUW2t6T6PkodgG2
	 OXCSfrgq+1L/ID4rB7HwthtDH49IiiqHcidTgZkKPzJuSo1bw+d8wAdYn/ScQApp+u
	 a5WNEiTdXm0Fg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/6] NFSD: Relocate NFSv4-internal constants to state.h
Date: Fri, 17 Jul 2026 14:41:10 -0400
Message-ID: <20260717184112.507548-5-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260717184112.507548-1-cel@kernel.org>
References: <20260717184112.507548-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The COMPOUND encode-slack sizes and the state-management timeouts at
the tail of nfsd.h are evaluated only by NFSv4 code (nfs4state.c,
nfs4proc.c, and nfs4xdr.c). They nonetheless sit in nfsd.h, where
every NFSD translation unit, including the NFSv2 and NFSv3 paths
that have no use for them, has to parse them.

All three consumers already reach state.h through xdr4.h, so move
the block there. nfsd.h keeps the NFSv4 prototypes for now. Only the
pure constants move.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsd.h  | 18 ------------------
 fs/nfsd/state.h | 19 +++++++++++++++++++
 2 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 27e5384cd849..1886f6d42929 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -199,24 +199,6 @@ void		nfsd_lockd_shutdown(void);
 
 #ifdef CONFIG_NFSD_V4
 
-/* before processing a COMPOUND operation, we have to check that there
- * is enough space in the buffer for XDR encode to succeed.  otherwise,
- * we might process an operation with side effects, and be unable to
- * tell the client that the operation succeeded.
- *
- * COMPOUND_ERR_SLACK_SPACE - this is the minimum bytes of buffer space
- * needed to encode an operation which has failed with NFS4ERR_RESOURCE.
- * care is taken to ensure that we never fall below this level for any
- * reason.
- */
-#define COMPOUND_ERR_SLACK_SPACE	16     /* OP_SETATTR */
-
-#define NFSD_LAUNDROMAT_MINTIMEOUT      1   /* seconds */
-#define	NFSD_CLIENT_MAX_TRIM_PER_RUN	128
-#define	NFS4_CLIENTS_PER_GB		1024
-#define NFSD_DELEGRETURN_TIMEOUT	(HZ / 34)	/* 30ms */
-#define	NFSD_CB_GETATTR_TIMEOUT		NFSD_DELEGRETURN_TIMEOUT
-
 extern int nfsd4_is_junction(struct dentry *dentry);
 extern int register_cld_notifier(void);
 extern void unregister_cld_notifier(void);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2d00a411c663..c4627dc91e20 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -45,6 +45,25 @@
 #include "nfsfh.h"
 #include "nfsd.h"
 
+/*
+ * Before processing a COMPOUND operation, we have to check that there
+ * is enough space in the buffer for XDR encode to succeed.  otherwise,
+ * we might process an operation with side effects, and be unable to
+ * tell the client that the operation succeeded.
+ *
+ * COMPOUND_ERR_SLACK_SPACE - this is the minimum bytes of buffer space
+ * needed to encode an operation which has failed with NFS4ERR_RESOURCE.
+ * care is taken to ensure that we never fall below this level for any
+ * reason.
+ */
+#define COMPOUND_ERR_SLACK_SPACE	16     /* OP_SETATTR */
+
+#define NFSD_LAUNDROMAT_MINTIMEOUT      1   /* seconds */
+#define	NFSD_CLIENT_MAX_TRIM_PER_RUN	128
+#define	NFS4_CLIENTS_PER_GB		1024
+#define NFSD_DELEGRETURN_TIMEOUT	(HZ / 34)	/* 30ms */
+#define	NFSD_CB_GETATTR_TIMEOUT		NFSD_DELEGRETURN_TIMEOUT
+
 typedef struct {
 	u32             cl_boot;
 	u32             cl_id;
-- 
2.54.0

