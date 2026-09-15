Received: from mail-oi2-f12.google.com (mail-oi2-f12.google.com [74.125.231.204])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 511BE3B6361
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.204
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474957; cv=none; b=RL1V6nLWbC/gw4rgvkN5PlhGN8XZqv3ZFKiDsA40Xy5IFcrh25g4pWnksqj++noLtfP6FzdMS4Uq5j7Hq/QiN5QD18qwyrLFGHh5c54sJYaW2aYLSj4hFlnBZtllm71GKJJmFqnG0l1f+KHymrR/o95Tff8oIzEbnU5zoNt5KwY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474957; c=relaxed/simple;
	bh=PWE5vO0Vqc0flgCKXq5LzTCo73RA/9TMQMDQwUvno90=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=f0TGOm5z9lN+vYt1XFnUybarwxAG+0foDFxLVrkBcVJiX9j+s8WqosnW9Kz2NQ066je1y4eECJvwxpDigs+Dv5leNlZzMKeizI84aH6gkI4DrHH9BMO3TmtPnaLglkf04LgZic7IS51i9haXiQSxMHAp4m6XuHfRpSLd3P51JnQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=H8cODPgp; arc=none smtp.client-ip=74.125.231.204
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="H8cODPgp"
Received: by mail-oi2-f12.google.com with SMTP id 5614622812f47-4b37a30eb3bso2056627b6e.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474955; x=1790079755; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=U7s9RqFfNmC/43sJH/vkem1CuLFb7gPj1DqmU+qmN1c=;
        b=H8cODPgpw4Nn2sh27Gm5eXvfRivcdXdrmpZXus9HuFspB0Hfid25EX+TUyBXeh3Xtt
         eWud0qT00XWrbA+Uf5lM3NbdvFFh/uCb9URdgS0TS+U30hRTds/5rrALb9ch2YvosEmw
         0KVsBQ1USFnwkZjJJNDA+wvgnBcZKVi4fI5U8QKW5AS+duFBilDp3UajPIjoUuMEAx2W
         3Qqt/rE5MCYsz3lW+RDP/G4kWQ0YX54R8tEykBfJb7+dyjdZ9kTTBXW/kn+2xJN+ZyJ6
         wd4FNfL32PuRom2yjFgdKRvIeDDY9MWu+QaVbJg32Vg5fZq1ylZikjIaACVyPuZe5WDQ
         MJWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474955; x=1790079755;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=U7s9RqFfNmC/43sJH/vkem1CuLFb7gPj1DqmU+qmN1c=;
        b=Cs+5ruRQXffN+N63Hg63rWTyfqKt9Z1H91ZmFxPRALMWH4H9MWg+VXuL/zztDXprGE
         DfjHU+aCHielHxHcO+Z50qsJAGl8RdsunG0q6h4v5Wvvg0Hxb2UILgmULIitCE6SC2+M
         9Tm/SAhphd+DQUjx2hMmraagt74139sBEE/9wBjp8t02YtuLRv3f3H05A3TfaubNHZj7
         4Ltlf81iSjbP5wFcJ0NIh/27BdrKRtacvHeIAbX98oQTpuo99pwS24XaJo/J3kcJn8AH
         fUve+VUp4pkW5gbL/cbnZ46n2eNaAqxdlB9sXB8zQmYqe60H+VbeEhKOKE7hP39s+BT5
         DHsQ==
X-Gm-Message-State: AFuF++m7UHnwdI93pi6z60y5PvUYZiKMdFLKdr+KBE6QBa51uszR6P1p
	jJgsSPCavptxeBnoUsOEPsUyuia8feEh0cwAWtnPSUuH1gjhsnnX1qNvL+9rl7WYdX0=
X-Gm-Gg: AYBFou1Wcrf4vPN7izsuATAaoD6ciz+49Ac8LTFWDKOxgIe7HaNJad+Q9Sx1cB5eAKK
	fMR2SiQ4lR4YQPiGASiFVaE1FyzjI259V9NG4nowgiptuRqE/t9jLydvxFNj+83dLWQk+VkT1qM
	ETKmc8Yi4HapSNeo0AW+GJ8V02ojaGz9sZa4XDoibf2Cmb2IWh0tYdNiHq/jVdS7uslRNrkXEtZ
	BhctqmonO4VS/XW3FJq94fzOFK4WL4cEzxaVRi6nL55jFVmJ4e8UhpBrBxdncJDU/t7mKuQcWAm
	WoGk4de3j6s7J5dsFrS1ih/43jZz01v2YnWC0P+h6qprce9ccJTuRzCCyRL/6tpvy3QcX+TIJaO
	01iStBxkaDEVeYF5g0N3kiCvHrkEf3bvEVZ+IsfHEdT0zHwm7/vWSibUNG9T14WsSfkr8niGN1D
	s83bkQpjXIO/I83k71Xpexx/Kw2vWaAqK3apc1Ixp/X9nZOy0r1COpLHDpCZYBEInIiCweDH1bt
	T0P3i7xXsKpn6tJozsb5rqEwuY6YCVGqR4=
X-Received: by 2002:a05:6808:14c9:b0:4c5:bdb8:e579 with SMTP id 5614622812f47-4c7b529a1ecmr8299369b6e.12.1789474954779;
        Tue, 15 Sep 2026 05:22:34 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:34 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 05/24] NFSv4/flexfiles: Use the full 64-bit offset for read DS selection
Date: Tue, 15 Sep 2026 08:22:07 -0400
Message-ID: <c97e5da23084368cb6a956fce08d96a7fa47522e.1789474702.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789474702.git.bcodding@hammerspace.com>
References: <cover.1789474702.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The read data-server selection helpers declare their offset parameter
as u32, truncating the file offset before nfs4_ff_layout_calc_dss_id()
computes the stripe index.  The write path already passes the full
offset; make the read path match.

Fixes: 4934ccbeaed3 ("NFSv4/flexfiles: Read path updates for striped layouts")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 54ee8f6051ee..4078da49a93a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -878,7 +878,7 @@ ff_layout_mark_ds_reachable(struct pnfs_layout_segment *lseg, u32 idx, u32 dss_i
 static struct nfs4_pnfs_ds *
 ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
 			     u32 start_idx, u32 *best_idx,
-			     u32 offset, u32 *dss_id,
+			     u64 offset, u32 *dss_id,
 			     bool check_device)
 {
 	struct nfs4_ff_layout_segment *fls = FF_LAYOUT_LSEG(lseg);
@@ -914,7 +914,7 @@ ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
 static struct nfs4_pnfs_ds *
 ff_layout_choose_any_ds_for_read(struct pnfs_layout_segment *lseg,
 				 u32 start_idx, u32 *best_idx,
-				 u32 offset, u32 *dss_id)
+				 u64 offset, u32 *dss_id)
 {
 	return ff_layout_choose_ds_for_read(lseg, start_idx, best_idx,
 					    offset, dss_id, false);
@@ -923,7 +923,7 @@ ff_layout_choose_any_ds_for_read(struct pnfs_layout_segment *lseg,
 static struct nfs4_pnfs_ds *
 ff_layout_choose_valid_ds_for_read(struct pnfs_layout_segment *lseg,
 				   u32 start_idx, u32 *best_idx,
-				   u32 offset, u32 *dss_id)
+				   u64 offset, u32 *dss_id)
 {
 	return ff_layout_choose_ds_for_read(lseg, start_idx, best_idx,
 					    offset, dss_id, true);
@@ -932,7 +932,7 @@ ff_layout_choose_valid_ds_for_read(struct pnfs_layout_segment *lseg,
 static struct nfs4_pnfs_ds *
 ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
 				  u32 start_idx, u32 *best_idx,
-				  u32 offset, u32 *dss_id)
+				  u64 offset, u32 *dss_id)
 {
 	struct nfs4_pnfs_ds *ds;
 
@@ -947,7 +947,7 @@ ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
 static struct nfs4_pnfs_ds *
 ff_layout_get_ds_for_read(struct nfs_pageio_descriptor *pgio,
 			  u32 *best_idx,
-			  u32 offset,
+			  u64 offset,
 			  u32 *dss_id)
 {
 	struct pnfs_layout_segment *lseg = pgio->pg_lseg;
-- 
2.53.0

