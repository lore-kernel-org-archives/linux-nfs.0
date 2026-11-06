Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793989275;
	b=LMwpmmAXP6DESfrs07e/2k523oWVIbR41OUFVg6sKQTwBqARg9hkp3j6wET4Pm/Ry1Aj
	 czlp1c10O644FOnEqwewjQ3w3i+nw1WQ/L/U/AfiF+1V04mY3aEtNJCJ4U6VmbfXtIdfq
	 ZdFw2dZ1GloEcE3cXti3djr/f7l4Z/hxYCz44Kg+hyqbp4yHiu2RvPNZuq1/sKvhIRP4U
	 Y5uKUNTRyfzCxayQDisCCq/chCZ5n8OO1R9FMqnbFsu2dAWh9hYo8ZRFO2i8YEJN/D2mO
	 Rf+p7VhgxVbJpDf5UvZugvpw60GesPJ741P7gBOdFPLsUxHuYBcc6ua7HJbhdsUC23A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793989275;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=etzwXHaOFnuaKdMyR5iW7duktUlg4iYZnZhbLBpqT4A=;
	b=L3MCA1r+WLv8jnNqNId1S3NElGE1kjQ65YcNAhbhfjVLryFEHDOvWjrCvsjcsO1buFu3
	 OIuBE4kkeFgheAMuyEa+US+/RKTU6XMn/wbKQz3//yukez1m6nC5XeLgmEye+2pmPcEMj
	 RWz9pm6IOQJSHRzIWUakpHrLLsrA5mZ/8C8lS6buuDN+Fv1HcTwv3/RDPKajwmFzZl6WP
	 8u3UIH1bJaCobiHS9iMi1Nos0oCD8Q9R2GmG/edqLwCZduSsePzifGYdW0CVEinPpqX8b
	 J0QjddZy3u0QKJxJ36KHo0bu6TXm3pap5yUZVW6GeUCYXUc0VxQxHsgCArwHriQ08xw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PCOMOt1q;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13F72606A32F
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:21:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PCOMOt1q
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 722A11F008AB;
	Fri,  6 Nov 2026 18:21:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793989274;
	bh=etzwXHaOFnuaKdMyR5iW7duktUlg4iYZnZhbLBpqT4A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=PCOMOt1q/T3aK0UeNi2z+l8/1UNTDsd+dGbPCq0VIeEErRlmxMikxAA45EyAsqJ1p
	 JF8QM1Q0Nh4Muzbe0Ipv/NZgsgprnxrGiDo3/kCfeHvepP+SQUKa8Z6PYPoTwq+sA2
	 yJ9V2WGYREwvoqddB06Y/LlCvCvweBVXlQLLT4++x9Rd+HMI7UTZI+e08+m8r3RX0L
	 C2W8+0Qk4trQsl9en5SkG/206hpOrj6LTWElmGSVg3ceGmnPo86MLf+LmPjSeiw9Qi
	 SZTV6ewrlSMqjauynKI3rfnrGD08yefGvYfqLHYtOsYD0uFzAGFU3I4O0vIuZNeBDR
	 Ag8Kd9TbanjoQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v3 05/12] NFSv4/flexfiles: drop the redundant atomic from the busy timer
Date: Fri,  6 Nov 2026 13:20:53 -0500
Message-ID: <20261106182105.78611-6-snitzer@kernel.org>
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

nfs4_ff_busy_timer::n_ops is an atomic_t, but the stripe lock already
serializes every access to it.  Make it a plain int.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 6 ++----
 fs/nfs/flexfilelayout/flexfilelayout.h | 3 ++-
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index dd493ff51d512..81c3d9dd413e5 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -711,9 +711,8 @@ static void
 nfs4_ff_start_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
 {
 	/* first IO request? */
-	if (atomic_inc_return(&timer->n_ops) == 1) {
+	if (++timer->n_ops == 1)
 		timer->start_time = now;
-	}
 }
 
 static ktime_t
@@ -721,8 +720,7 @@ nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
 {
 	ktime_t start;
 
-	if (atomic_dec_return(&timer->n_ops) < 0)
-		WARN_ON_ONCE(1);
+	WARN_ON_ONCE(--timer->n_ops < 0);
 
 	start = timer->start_time;
 	timer->start_time = now;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 90a0ed1dd822e..483d730659713 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -64,9 +64,10 @@ struct nfs4_ff_io_stat {
 	ktime_t				aggregate_completion_time;
 };
 
+/* Both members are protected by the enclosing stripe's lock */
 struct nfs4_ff_busy_timer {
 	ktime_t start_time;
-	atomic_t n_ops;
+	int n_ops;
 };
 
 struct nfs4_ff_layoutstat {
-- 
2.52.0

