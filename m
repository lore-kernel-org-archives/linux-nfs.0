Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793299320;
	b=2Cs2s+dS64LODDUHpeRgc5ZtlpXWxa1bUtNlIZTxbiqNbYoSsIvCcAjPZnTjqpTmMQUk
	 ItSkhEvmZzF8Y4eD7boZRFAZwq2PZ6P/b1PT4hlMcTAl20YgUq9QpGgjgm+ukbJgW0vY9
	 kEkg6clONaOO7Iw3/HteVQTKJ5AwBdHatoEp3lPNRJgNeEvXkSHlNLX6HUnV7F4ZXAfbi
	 Vz1ZRvOyI5P15tssrJC6LKMmGzhHLwgeNcLAz8YCQu8EsNevFmaX3IGqK9iu8xIlY1fsG
	 lvxw8Tvn5MqaA42AnYZa7lnLlDmzpiNCxIxFHy09NG4Jzw8yzQ4tWeo2MvjU47U2AGw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793299320;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=kCkvYfSpv5meezm4S7EoTqsEQXJyrxV1WFdOSy4aup4=;
	b=3rGq1xsZKpmUQxmicy4HosXZB7WKWSZwx167BUmUi93xAARhxmQO6DaP8We7aTgJLW2l
	 JESE161O6VCgfIbou1Xepool39WMsAJWC6ny3e1eKsNbbL/hqZklvVBvjQCBEzVFrWkhR
	 RJ5xmMmtOy7VXCKp6oNX41xW0yYvOZP7SWY0xj+/rDgtNNItF+//A+S7QvpE0IxLNCrWp
	 n3xJ7FxN1uOhWGZcuCZVMKh0kMXJw7TVDV/gJ58ERCMaIkzdmYwwij3p9H3PLcy0gngPF
	 ZgAv07WAPILVb8Z3F8GcMfU+atRHWbhBAXkl04FiaszZ0kt6whbbFlkuBHZuO+7gZlQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=JmIETpal;
	arc=none smtp.remote-ip=209.85.210.42
Received: from mail-ot1-f42.google.com (mail-ot1-f42.google.com [209.85.210.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A20FC606A31C
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:41:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A20FC606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=JmIETpal
Received: by mail-ot1-f42.google.com with SMTP id 46e09a7af769-7f84a55cc06so1315193a34.2
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:41:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793299318; x=1793904118; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kCkvYfSpv5meezm4S7EoTqsEQXJyrxV1WFdOSy4aup4=;
        b=JmIETpaldAEAbCQoc6kDx4m3LPlB8sfmaPuikeA4Pc4+iEBcPuInkzc33HB/xjr7bt
         4yKuROem466ECP92RK8Ifry83SHY4Gnr6PBr0nguYRCO0l+DbRL5jCYyBdeecb8kwk9M
         NrXEvzfwO8hX7WPIwPfUVsY8ltwsT5YDKl3S2TdI9tSvbvf/iiRuMM6u6fzEBeD5BjpC
         pMw3x8obcvxg/twd6OVjBJXzjf5I6G0T1/BIEjW0Ke8Gp4Pt/MaL5xzvBthBdVEgmIj/
         QjfOqcrMfH7HeWDJnRqAmJEJEg4BagiOqCZkk0C6LT07ImlIw1MDx4x9540H9OwtRP2E
         bs5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793299318; x=1793904118;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=kCkvYfSpv5meezm4S7EoTqsEQXJyrxV1WFdOSy4aup4=;
        b=Nth2WniDeaNeQheI4LpsvuTRbzlikfiLDP8Z+Io464FRyyvy/FdkGU0NBCnz9CIRCA
         gC1efgDr+KhegelzKYByR039qlEO99t7iN9PPx7VT0XkL5MFG3e+YUQLJys8XfMm3/6K
         I6yaXKb9oge4wFwV70+g2i8Wi4mUPIFAIFRY03WzXHT/qsOM2zDynn46/ZTWgFCpH4xC
         bFjhknDVW6VKDReoxkGRfO93WJJ7tvnRt+cw3Lrdh2066pmYfHqFTsS1b5IZ2JUd+k9e
         q1+NjTy+adubhlCLgBMzCArXaT1WM0MLdYov48HA2TCOnUqMU++7Hpp+kRxwzy64b5xW
         bmfw==
X-Gm-Message-State: AFq9FYJjNal5TqyrGml92BVfGh/e/CWGJ3sBxxkFzJX0SdXFCGIuPlD3
	wk9zw4x51vbrPn7MCW0T0mSRmmZKlVI5x3zre/+Iepm35qNH2blFiZYUtpiDLORGzag=
X-Gm-Gg: AYBFou36Q9AkvfR8Blwri3DUEK2Mi+GDxdHo+aXPEiaWT11AENolRQRdnHnYIAUIn6O
	lOjqcFzvlq5yHkTC4ii42PftoH5TZuFPGaKTzNhIDLrEgElfSNLewaLyOSdYutZf6fDJA0mPBYY
	A+eDas3z3Dsr42dY0hgN2Hq9w5VoQR35tKDu04l201lnALXhZttUyM87ZpAEchRxEGjMyLu9Lh0
	5NgxZ+Efn77zSVbCrgh33w6AP6KQ9rza8be7FhEYXEPpQMSlD9m9R/yEGjR0vNHnpHdAyprW02T
	pwgu1x3B0opJTPbP+fvEBv+EAElvMrclr/IyaCMyZl5Dy4h/GAVTwDAOORSBdhhXI9ww/Bb5pgl
	6fqxcjrUPWWl04hplT0DxKonH/D6opQnhn7r60qQigoS5N85rURkJ++a5THXbyCHaCjCsLdw3j4
	SQ9r5skeEqe5cZ9pj0zT6w4TvdF6nzlrL4YSbLgdCAC42FK3HEzcSRQy9Z6cT93Cmc3eYsS8iqX
	+NGwpQYxAF/BVCbJLaE8Id0Xi3yv350WVNdwWGhsTEiYuqRZX47eQL+h9fgXdNVp7ZHQSZbi7Kn
	qRwViw+Uf54r1s6ZTaNRqOkaU6pAzrdOrId2mzVDu6lGVUfPLz4PvStYa6KpPyxIzyTh/LGmuoF
	Q
X-Received: by 2002:a05:6808:508e:b0:564:a01:8e43 with SMTP id 5614622812f47-5640df41f19mr48335b6e.59.1793299318250;
        Thu, 29 Oct 2026 11:41:58 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640e23b76asm7161b6e.11.2026.10.29.11.41.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:41:57 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] NFSv4: add a tracepoint for bulk CB_LAYOUTRECALL replies
Date: Thu, 29 Oct 2026 14:41:49 -0400
Message-ID: <1cdcfef536459c717d7acb3b1f5571a07724b249.1793298149.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793298149.git.bcodding@hammerspace.com>
References: <cover.1793298149.git.bcodding@hammerspace.com>
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

