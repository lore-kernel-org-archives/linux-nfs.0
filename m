Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793646673;
	b=mTBOxJGB6eKKEl2OdylCPsdr96k89ZBM7x8cjxgyCuwZ5Mf9YzC7nTd9LVqxPGXeUtpP
	 AHWQFiKRZ/rHbYURtSlQxGa1gAbsrHtNuYicstS8oMpoxoHFTXDT4tvlFHeekF8eBWWgt
	 kFc6zPpp3Yd/hkfVqciSsYCH9wg2Qy+h8Iv0iPAu4sMU5pMmqN9OBKtxP0oUbvVA+Iita
	 cpqgTUicWdEp2WzG9JrG0qbWY1jYXsxlqGz0xA+Ils9AUyq6BmcaUDUKvNOLs4SYZcCCo
	 bhH5EUvbH/o+XAX9spE+K2wcNvf4/Pm7VcjIMCKyBNWLvdT7bEVsep+VXJxwx9cyOPA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646673;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=Wj/S1siFwOuRVnhPPjfP2ZJ1b6gKM+k8R9c2TUy/Kos=;
	b=hNvu71H3IrtrWavx3K6eo0RWD8/T/mP45AZS68EwMabaa/soy5JIez31FMwbQPjIkLNu
	 aJPlt/B7DMMe6pbN1QflM06b4wWUrYKY63/U4PfkkibtN6cIl5CKIU2TXidroApkHUR82
	 im06x6bfw1+o1jZuJ76tK5gybh2HRyBLbd49rLWj9rC9fVNkQ3Mqw1M/zGBOq+MfXG5/L
	 tfCgiBfzbJXO+IOtvDNd6YBoOoH0jVERg6HnGmE82QTmSPht2HA4hILlKfMT177O9O1ks
	 BhEpXLPmXJiq7utzi6PhTpEmhpFSFasuAj98ErWGcn33eMhBfZjZ0CRiZPXYdbPW99A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FZ0QKOFu;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C15C2606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:11:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FZ0QKOFu
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 679721F00A18;
	Mon,  2 Nov 2026 19:11:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793646672;
	bh=Wj/S1siFwOuRVnhPPjfP2ZJ1b6gKM+k8R9c2TUy/Kos=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=FZ0QKOFuf0TaWci0vrCNPtp0gcEgkTxrBDrM4oBo1mJAYAJL7Seud1sfsLX/mKiun
	 l434Vg07pnmjKQK0PWr/GEkas/+93mijtstAqdTc+QbYEwCQ3ZCKbOHB86/7LriR+I
	 md4zyZvMoRD/RKs6ORytDJ/T61/Vsd5Zpyuq7CMuWSssfqF2r/w6KSqsSxqyFWzUS3
	 wKP9P+Zx1nJbQuNrjQKaQRYlVEf2exoHs17UUocFLhgTa8jym3sbPpxYwnY+e61mQ4
	 ANNOw6D/F9WhUlVKvTam4YKxcXknfPDVnHJ3VBA9piymSmvZo4VnmGJP6Jk79N/rW9
	 Ld7iX8cb0hNeA==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH 02/11] NFSv4/flexfiles: drop the now-unused per-mirror lock
Date: Mon,  2 Nov 2026 14:11:00 -0500
Message-ID: <20261102191109.13470-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261102191109.13470-1-snitzer@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
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

From: Jonathan Flynn <jonathan.flynn@hammerspace.com>

With layoutstats accounting moved to the per-stripe lock, nothing takes
mirror->lock any more.  Remove it.

The only users of mirror->lock in this tree were the layoutstats paths
the previous patch converted.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 1 -
 fs/nfs/flexfilelayout/flexfilelayout.h | 1 -
 2 files changed, 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index bac0b7f559201..7fc1369df8439 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -280,7 +280,6 @@ static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(u32 dss_count,
 	if (mirror == NULL)
 		return NULL;
 
-	spin_lock_init(&mirror->lock);
 	refcount_set(&mirror->ref, 1);
 	INIT_LIST_HEAD(&mirror->mirrors);
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 54aa492bc0bac..8fa2d8851166a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -99,7 +99,6 @@ struct nfs4_ff_layout_mirror {
 	u32				dss_count;
 	struct nfs4_ff_layout_ds_stripe *dss;
 	refcount_t			ref;
-	spinlock_t			lock;
 	unsigned long			flags;
 	u32				report_interval;
 };
-- 
2.52.0

