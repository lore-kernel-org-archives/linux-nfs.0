Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1BF7456DE4;
	Tue,  4 Aug 2026 10:55:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785840928; cv=none; b=HVoFiRV/PpIHQtvdtWoEVV8GZXsnfjJtElVU6P1LLKosMm+19tTDEhnfFe9Kk2FWj3xmdMXGQo5YA3funlVsSVcwUkPvSgNv0qtiEc9cZG6mbwjuI9/h8Sj+g6ts3jKWsegEPwAgCW+q2oEm7jNu2xHfeMvU0BdGzVBO8MqsHUI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785840928; c=relaxed/simple;
	bh=SHVtQ9W5JkS7JTpSO3lIycMZ8tLRLS4IEpYSXs1pusQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=q7hbCp+jO4RehdwiGM4DUCDi2Z2nFQi4J0aRriKZe/ph/06CwSVv8uMcl5RHJTzMVVulCMjJaq39iaE0fKtyuVwqfdQih4sW03zNasYYKP/cnf4RYsAv+bkeukpfXJJbjJEvkSnI9CfWXvHax/OpuOYAYD01zBofaq55dggDepk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NKVAIFKk; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NKVAIFKk"
Received: by smtp.kernel.org (Postfix) with ESMTPS id C9AFBC2BD00;
	Tue,  4 Aug 2026 10:55:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1785840926;
	bh=SHVtQ9W5JkS7JTpSO3lIycMZ8tLRLS4IEpYSXs1pusQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=NKVAIFKkDilH64pGd2pG6ArMAAGjK9DXFNqKJrOqzps9zQ5CvCVIdBNh1UoTQJzgu
	 ktm1MDDvlXU7qq3ciJbyCavacFm4UUnuVNN0TKKc1ccRfLOUGtRJuFC3iSWr5IJDWS
	 brheYMDcENq1OpPB7s5fR29hfjUXT/4QoRqA4UG27uBtVFuN6De0tfgdhTwrqkmhI5
	 I/ntLBIm4wxSjP8+98mO7sgtJHyI6LfiVpaCn2juOYAbMmEmGcmxp5kCV7Zrb+IHk3
	 1w3hRDMzW9GSAOp/OWfkA+WITzWQNhRBlLWw6J/mempKN1++574YLiEgmaYnGGVRgs
	 ZkYzEziNpIYqA==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8B36C55ABF;
	Tue,  4 Aug 2026 10:55:26 +0000 (UTC)
From: Junrui Luo via B4 Relay <devnull+moonafterrain.outlook.com@kernel.org>
Date: Tue, 04 Aug 2026 18:55:04 +0800
Subject: [PATCH 4/5] NFSv4/flexfiles: bound the filehandle version count
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260804-nfs-fixes-v1-4-1544df970e7c@outlook.com>
References: <20260804-nfs-fixes-v1-0-1544df970e7c@outlook.com>
In-Reply-To: <20260804-nfs-fixes-v1-0-1544df970e7c@outlook.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jonathan Curley <jcurley@purestorage.com>, 
 Michael Bommarito <michael.bommarito@gmail.com>, 
 Junrui Luo <moonafterrain@outlook.com>, Yuhao Jiang <danisjiang@gmail.com>, 
 stable@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2341;
 i=moonafterrain@outlook.com; h=from:subject:message-id;
 bh=HE7wEMko3m9Jwve0mVBI8y2cKV7TCTLF5kvH7eM8vzw=;
 b=owJ4nJvAy8zAJVb4wiKgu++DA+NptSSGrMKjMvsSGH+qKbNxX43ZtLXX5UhjmVqNyvttU35Fa
 B39u/rkmeiOUhYGMS4GWTFFluMFl75Z+G7R3eKzJRlmDisTyBAGLk4BmMi6Lwz/qzh4D77LeWte
 4Pj6daWfS19iZs7s3sklr4WLumyO8TIoMPxPeeF5w+afVU9VnuP9TpEe7pevLl5mzj7VuM5i07q
 zGuGcABtXTSg=
X-Developer-Key: i=moonafterrain@outlook.com; a=openpgp;
 fpr=C770D2F6384DB42DB44CB46371E838508B8EF040
X-Endpoint-Received: by B4 Relay for moonafterrain@outlook.com/default with
 auth_id=909
X-Original-From: Junrui Luo <moonafterrain@outlook.com>
Reply-To: moonafterrain@outlook.com

From: Junrui Luo <moonafterrain@outlook.com>

ff_layout_alloc_lseg() decodes fh_count from the flexfiles LAYOUTGET
body and passes it directly to kzalloc_objs() to size the
dss_info->fh_versions array. Commit 2c6bb3c40bc2 ("NFSv4/flexfiles:
reject zero filehandle version count") rejected a zero count, but
unlike the neighbouring mirror_array_cnt and dss_count the value
remains unbounded from above.

sizeof(struct nfs_fh) is 130, so an fh_count of 32264 or more pushes
get_order() past MAX_PAGE_ORDER and trips the page allocator's
WARN_ON_ONCE_GFP().

Reject implausible counts up front, as this function already does for
mirror_array_cnt and dss_count, and as filelayout_decode_layout() does
for the equivalent num_fh field.

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Reported-by: Yuhao Jiang <danisjiang@gmail.com>
Assisted-by: Claude:claude-opus-5
Cc: stable@vger.kernel.org
Signed-off-by: Junrui Luo <moonafterrain@outlook.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 3 ++-
 fs/nfs/flexfilelayout/flexfilelayout.h | 5 +++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index c4aa995026f6..bdc4b960eeb7 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -551,7 +551,8 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 			if (!p)
 				goto out_err_free;
 			fh_count = be32_to_cpup(p);
-			if (fh_count == 0) {
+			if (fh_count == 0 ||
+			    fh_count > NFS4_FLEXFILE_LAYOUT_MAX_FH_CNT) {
 				rc = -EINVAL;
 				goto out_err_free;
 			}
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index d024b8db4ce0..a4c7f9040084 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -27,6 +27,11 @@
  * otherwise let a server spin the GETDEVICEINFO decode loop. */
 #define NFS4_FLEXFILE_LAYOUT_MAX_MULTIPATH_CNT 4096
 
+/* Filter out insanely large filehandle version counts, which would
+ * otherwise let a server size a kernel allocation from the LAYOUTGET
+ * body. */
+#define NFS4_FLEXFILE_LAYOUT_MAX_FH_CNT 4096
+
 /* LAYOUTSTATS report interval in ms */
 #define FF_LAYOUTSTATS_REPORT_INTERVAL (60000L)
 #define FF_LAYOUTSTATS_MAXDEV 4

-- 
2.51.2


