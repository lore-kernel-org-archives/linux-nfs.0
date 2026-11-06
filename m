Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793989273;
	b=LFrlRzlCkPDXxqMiyL7vb3A+EP8GUM8svdKD0VkQXfXvSYd4uErW5g/X/YqfVJZ2QjRh
	 tCbp1pmWl7//RzFGuS5tXFxmebDOtTpcTJp4uU+GCCXjXyazuhN/59PJXZ90H6rBhqzUR
	 Bo3Ayu+v8EhnRQqkz/JtGeqNzuzi8QJTp4m0o+yiJTxbwmJ5ZgexqFCyBnJtzNOGCnJDR
	 BVbYYtkIK9OJGHlaqaG84Zw5uJfGRoBWmUmY0RN+ar4UzzxW7XXtIYrVDneV5I1ihWbzA
	 nDpGQrGBg+TKA5xfRapK/dNTyOHKeH85hV2zbY+rl14CtUROQt1xEkNX4QIfaiXlITQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793989273;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=fOXSRhKpMVHAY0PwkQKl8WfBGbcHOvR+Z3vQ4LdoRPU=;
	b=oCfD3vfip3UK7xqARyZw61QLqqIGYYXDQaFrQdaHYlG3VJO1NQsAQvn4c1H75yswp3ZW
	 ecI6ACf2Kn8WxwppuK8oD0ExCJBG6/biIUJEihqQfy3AFlSxWY9DbGYJLE8CvhhHqg6r/
	 WWrstGgbIck4AzatiuNtL9INvI2in197JteJVYxsizyGSxpdWnqAtZsu/oyMxwchMFrP0
	 jjFNPS0Ylgq8BF2wdVDIFtPgOHKhvI5aKoHb6wNFogpWiKenUodyXmM24DgQEkxHSEOvV
	 ZcsDDdwJ+S5jXVK2Xv9STkYxI9U3uecy80BAOXmxa0Ja+YXSEo7178Ezr+roxbMvuBg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bxLeM3OB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 91934606A337
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:21:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bxLeM3OB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DF34A1F008A6;
	Fri,  6 Nov 2026 18:21:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793989273;
	bh=fOXSRhKpMVHAY0PwkQKl8WfBGbcHOvR+Z3vQ4LdoRPU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bxLeM3OBSUg3riazhpDbuHpZgEAshvwbS3vajtktLAgxCJnDrTkhK1HrgkyWzi4bG
	 B919mdqmrCzMIwsX/a1busVgKgGtn1hyqsaHdhn3h5aGP1GrSPkoOSFLOepfS2RJz9
	 zaPD0t9LIR4x2MiFS5CS+GCa12JLieH1U/Lltdlai0Q52aQlB1WIWxcrq+dofsuegR
	 2+fqeMcf2k/qB7Xv7MtdEFuyUKWtU5VpCLKODr7xWSikX7Yq4yAAs2hPNZCEQfvRMz
	 Qeu2NEdvWOQqYTRm1ZtMjwrLQEKKQe/AKQL8gHE0M//OTABJ9dEmh/e/8huyCBs00y
	 eiXlDz5uXCOew==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v3 04/12] NFSv4/flexfiles: make dss_info->start_time write-once
Date: Fri,  6 Nov 2026 13:20:52 -0500
Message-ID: <20261106182105.78611-5-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261106182105.78611-1-snitzer@kernel.org>
References: <20261106182105.78611-1-snitzer@kernel.org>
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

From: Mike Snitzer <snitzer@hammerspace.com>

nfs4_ff_layoutstat_start_io() writes start_time under the stripe lock,
and ff_layout_encode_ff_layoutupdate() reads it without the lock.

ffl_duration is measured from the stripe's first I/O, so start_time is
written once and then only read.  Make it an atomic64_t, publish it
with atomic64_try_cmpxchg() so that the first I/O sets it, and read it
with atomic64_read().  Later I/O sees the value is set and does not
write it.  ffl->last_report_time is already published this way.

start_time then does not depend on the stripe lock, which a later patch
splits in two.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 16 +++++++++++++---
 fs/nfs/flexfilelayout/flexfilelayout.h |  5 +++--
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 57cd8b5d6d71d..dd493ff51d512 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -729,6 +729,17 @@ nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
 	return ktime_sub(now, start);
 }
 
+/* ffl_duration runs from the stripe's first I/O: publish start_time once. */
+static void
+nfs4_ff_layoutstat_set_start_time(struct nfs4_ff_layout_ds_stripe *dss_info,
+				  ktime_t now)
+{
+	s64 unset = 0;
+
+	if (!atomic64_read(&dss_info->start_time))
+		atomic64_try_cmpxchg(&dss_info->start_time, &unset, now);
+}
+
 static bool
 nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 			    u32 dss_id,
@@ -740,8 +751,7 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 	s64 last_report;
 
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
-	if (!mirror->dss[dss_id].start_time)
-		mirror->dss[dss_id].start_time = now;
+	nfs4_ff_layoutstat_set_start_time(&mirror->dss[dss_id], now);
 	if (mirror->report_interval != 0)
 		report_interval = (s64)mirror->report_interval * 1000LL;
 	else if (layoutstats_timer != 0)
@@ -3083,7 +3093,7 @@ ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
 	/* nfstime4 */
 	ff_layout_encode_nfstime(xdr,
 				 ktime_sub(ktime_get(),
-					   dss_info->start_time));
+					   atomic64_read(&dss_info->start_time)));
 	/* bool */
 	p = xdr_reserve_space(xdr, 4);
 	*p = cpu_to_be32(false);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 9ce09e02f1ad9..90a0ed1dd822e 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -87,11 +87,12 @@ struct nfs4_ff_layout_ds_stripe {
 	const struct cred __rcu		*ro_cred;
 	const struct cred __rcu		*rw_cred;
 	struct nfs_file_localio		nfl;
-	/* Protects read_stat, write_stat and start_time below */
+	/* Protects read_stat and write_stat below */
 	spinlock_t			lock ____cacheline_aligned_in_smp;
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
-	ktime_t				start_time;
+	/* Published once by the first I/O; see nfs4_ff_layoutstat_set_start_time() */
+	atomic64_t			start_time;
 };
 
 struct nfs4_ff_layout_mirror {
-- 
2.52.0

