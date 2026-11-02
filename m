Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.41
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627818;
	b=W7Xsh7RP+2wkAuhq6e46WqQtU8wvmV756hZc5VxRptCBkBDHJeJKjbwFroUkuf3nia2u
	 T5J0JIKmc3EqMq4VZGjdulboYrb7yS9o4Zfb21X8bYTZk2zYe1ma6SCEMJWnOgmP/+Yla
	 cupGG7BnWZub7YzGbUa+2tLpV6LRlRA0zGQ58wQSPstGjA8K8NQ0thuHUvrMINGh159kz
	 ldSele6nkm10RYGE8AniBCH2Rt3WT2OAe5FKH0Cz1yqyn8DY9PaMkJqA15ZBKQ7m6pQQ/
	 06iZ90xtcNZzWChJenEMVHC7rCJBF/lOv51drnjhPVI42UmNeEPr6mnoXGA8wwk6E6A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627818;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=kCkvYfSpv5meezm4S7EoTqsEQXJyrxV1WFdOSy4aup4=;
	b=VcIaVrybohaIXJdfP+xCz7BZTuoGwEFRkEebFan2qZvp9/P30QUbOc1gXhr6n0LuxkQS
	 xlWjvRLzC3WjqAGiPKRRnJNnGnveJ9wpboxwCIV/BLRquOSJRU2tAXme/BvR5lRN1yrJG
	 7jC+rQF20z/DhdeWq5ccujPNi3iyq0xOb9YkS606MgpVCfFZCZUYWjkPQP1BMCTMoJfBp
	 Q2+aMLKH256yJbvf863wFV3LykSALkYYzOqnoTt+4yOilV15RaQf0QyZukbivVyuXEkA+
	 S/wZIsxBDxGAyozdY5wfZN4yPOUYtEKY62wPVA+VQ3ky4WWIOy3TRY5ElaHwxLqeRNw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=XClGTUPh;
	arc=none smtp.remote-ip=209.85.210.41
Received: from mail-ot1-f41.google.com (mail-ot1-f41.google.com [209.85.210.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 310A3606A32D
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:56:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 310A3606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=XClGTUPh
Received: by mail-ot1-f41.google.com with SMTP id 46e09a7af769-84d5e56f876so2210242a34.3
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 05:56:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793627817; x=1794232617; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kCkvYfSpv5meezm4S7EoTqsEQXJyrxV1WFdOSy4aup4=;
        b=XClGTUPhjjk2ztML9UIU90lwNTOZBBACkx2/nT5n9vR6nIUjm3LZYBHwAz0jPgtKA6
         eW/LnFUqcqSDHb8gQpT+yuBtKGU035vUGTH/koOuqb7IKL9GQckfhHrUy4LqOmsPrEHp
         fjtIbpCEVWZkn5wvoaNJACBuFIhpw57USbOPbB3fIIjLFddt2//MhjcR36W+QDtV/bBC
         jT1YiKv2FLxeT6FmiUwvjLY1OkMZUGJtXaiaU+S/xYDECEJiVZdbfZIacud1nnvVK+Bt
         a+qFPH+h35PAGsN1tGSv7JD9CwdfMMqvDGHkwiv4VnWHA2j6NKGaIUenWZcjaugzF3Vq
         Swkg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793627817; x=1794232617;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=kCkvYfSpv5meezm4S7EoTqsEQXJyrxV1WFdOSy4aup4=;
        b=AkUUhdWY/fgtP7fWKLVIRzXP8wnEFM7zzLaSnmnvDczRmQMX1oJxGaAYtVkRzMvpdD
         RWA3E1zXvq0N6OYciR2gISApIaR9OdQTCJ7iAcO/cIaYNhbLlGZMBpEwjqs3cQMKHdy+
         GZiG6rcrFzqUCOHI1ye5eWM7z51OKALz3szspRMEFGFJ2EqEubqnbsCqT1oayucm3Ton
         4eH3xMBUCv8BPpMXdPHaFBTxAUF1TDRkt4Kn1oczN6t3GcAelG4o17SEGD4ZniCcfidY
         e9XZtQaCCwIdqxUChZnqgAZKBwIwWxD1hSF5+i6mQKTpWF0KvxaZz8y99dMZSki7xlLf
         gFpg==
X-Gm-Message-State: AFq9FYIPCEoqoq/Rmlu6wR6gJ0ChYkhq+lxZU1Rk5TNewitQWQalqjSd
	gYLQqa47i0yvJcUUze6n9M4a0S3Rv8jOhmqyCUAG6UR1Gum6H4hHYfM6hl/7XKn8E3I=
X-Gm-Gg: AYBFou1XxQdL4T29Y476x7s9ensLj1TGKB93YHoOBwGBU9LpLgJo5k2aGzyA4QwF0Ad
	Lhur+YctquCQWbLTAiYbGQSB19FogW60kJhLKKr62QkKLpyStMMx75+YRoIU9WLDx4OQyNVMsi2
	8S3VnkHnBMqHS0OCR/zqpJk4W/AqOFAAcgDXRvzaaEvR3yRVmhyXBYiciv432E2KMsHFgxu6ECO
	x5nib/e7uIrTZMqqkCVhY74NUUBrx/tnqlDgklXpibUfjo2sZ0IL9DoduZBNyDJvb/YbsHiM5sb
	eNin3Vwm4gb4IZnY8x5n2ZQ34WSNqiR9eUbUf5gPCNE4fFkXssYrt7NrXcxufDh8ez6HwXm+z5Z
	4rNsd6Rlnwudy2BPlzzwb1RZv2czysCVXZeuZrpYVEekeRRMoL2RcLsJSzEGpB5j65SdivgTKTS
	8K7LCFM2s5EhIcE9KOxKkHdauyQF6Wa3lQpEUqB0BasLA10yZBWf2cniDK57CjnRdX1vaq8ahwG
	3SBsMyXREzqBsXFUjsEM6BtVqUiwRJGkv7dqGQN8nQPBrOr8DfnKEEMSSPuUpUpIytORQckohk5
	HBAvVpImbMytDDbZURUZPHkK2qndpeTiA4p865NlyRl4GqxJO1KqQbg2fa/X80OkGOfqFwfp
X-Received: by 2002:a05:6808:4f23:b0:4fb:a7f3:420d with SMTP id 5614622812f47-5640de58075mr6996355b6e.48.1793627816899;
        Mon, 02 Nov 2026 05:56:56 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fd95562sm7980806b6e.4.2026.11.02.05.56.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 05:56:56 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/6] NFSv4: add a tracepoint for bulk CB_LAYOUTRECALL replies
Date: Mon,  2 Nov 2026 08:56:48 -0500
Message-ID: <1cdcfef536459c717d7acb3b1f5571a07724b249.1793627813.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793627813.git.bcodding@hammerspace.com>
References: <cover.1793627813.git.bcodding@hammerspace.com>
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

From: Benjamin Coddington <bcodding@hammerspace.com>

There is a tracepoint for the reply to a CB_LAYOUTRECALL of a file, but
none for a recall by fsid or of all layouts.  Add
nfs4_cb_layoutrecall_bulk, which records the recall type, the fsid, and
whether the client replied NFS4ERR_DELAY or NFS4ERR_NOMATCHING_LAYOUT.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_proc.c |  7 +++++-
 fs/nfs/nfs4trace.h     | 49 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 9d836cb72e78..722bb5475a48 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -352,8 +352,13 @@ __be32 nfs4_callback_layoutrecall(void *argp, void *resp,
 	struct cb_layoutrecallargs *args = argp;
 	u32 res = NFS4ERR_OP_NOT_IN_SESSION;
 
-	if (cps->clp)
+	if (cps->clp) {
 		res = do_callback_layoutrecall(cps->clp, args, cps);
+		if (args->cbl_recall_type != RETURN_FILE)
+			trace_nfs4_cb_layoutrecall_bulk(cps->clp,
+							args->cbl_recall_type,
+							&args->cbl_fsid, -res);
+	}
 	return cpu_to_be32(res);
 }
 
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index b5c89eeef2bc..e5abc186ecc4 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1571,6 +1571,55 @@ TRACE_EVENT(nfs4_cb_layoutrecall_file,
 		)
 );
 
+TRACE_DEFINE_ENUM(RETURN_FSID);
+TRACE_DEFINE_ENUM(RETURN_ALL);
+
+#define show_layoutrecall_type(type) \
+	__print_symbolic(type, \
+		{ RETURN_FSID,	"FSID" }, \
+		{ RETURN_ALL,	"ALL" })
+
+TRACE_EVENT(nfs4_cb_layoutrecall_bulk,
+		TP_PROTO(
+			const struct nfs_client *clp,
+			u32 recall_type,
+			const struct nfs_fsid *fsid,
+			int error
+		),
+
+		TP_ARGS(clp, recall_type, fsid, error),
+
+		TP_STRUCT__entry(
+			__field(unsigned long, error)
+			__field(u32, recall_type)
+			__field(u64, fsid_major)
+			__field(u64, fsid_minor)
+			__string(dstaddr, clp ? clp->cl_hostname : "unknown")
+		),
+
+		TP_fast_assign(
+			__entry->error = error < 0 ? -error : 0;
+			__entry->recall_type = recall_type;
+			if (recall_type == RETURN_FSID) {
+				__entry->fsid_major = fsid->major;
+				__entry->fsid_minor = fsid->minor;
+			} else {
+				__entry->fsid_major = 0;
+				__entry->fsid_minor = 0;
+			}
+			__assign_str(dstaddr);
+		),
+
+		TP_printk(
+			"error=%ld (%s) type=%s fsid=%llx:%llx dstaddr=%s",
+			-__entry->error,
+			show_nfs4_status(__entry->error),
+			show_layoutrecall_type(__entry->recall_type),
+			__entry->fsid_major, __entry->fsid_minor,
+			__get_str(dstaddr)
+		)
+);
+
 #define show_stateid_type(type) \
 	__print_symbolic(type, \
 		{ NFS4_INVALID_STATEID_TYPE,	"INVALID" }, \
-- 
2.53.0

