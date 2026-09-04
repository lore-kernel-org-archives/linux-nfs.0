Received: from mail-qk1-f175.google.com (mail-qk1-f175.google.com [209.85.222.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4A423B71DC
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540817; cv=none; b=W+deqGBY4XU9HWaHakuPBekjaT0IYdeo09ZEpxgPpz7OwM5/MbPjxFX5BoeFueIyhpD/RNgF2cABw9eu8rK3hF9sIT1HQ5eLRT9p6rUbpJ0cedOEWslreEndFuqLTfnrkt+NmSVpJDpU4x8Q/kPqniJlQT7tPP19hxZp+eEq3cc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540817; c=relaxed/simple;
	bh=PWE5vO0Vqc0flgCKXq5LzTCo73RA/9TMQMDQwUvno90=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=aIMniH20APiipbftV/b8OTKbGuqY8FuD8YO0/ERuSTGyzZJkm8+WWVYb/VtJNOmBxeL2C6NtBCkey5Pn2JkFsn9whBKlBTf3Nb1NIrkg2m9B63XnzTQsNxsaVuuZp2bvffr50HU0M4s6QH0IIiuyUSRQz7CQi70jnQLqvIFiX3A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=DUKIevMb; arc=none smtp.client-ip=209.85.222.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="DUKIevMb"
Received: by mail-qk1-f175.google.com with SMTP id af79cd13be357-92e57a753f9so130332785a.2
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540814; x=1789145614; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=U7s9RqFfNmC/43sJH/vkem1CuLFb7gPj1DqmU+qmN1c=;
        b=DUKIevMb6G+EEfgTFWV9glQzYVGs+P4WHsZlDx1OTxJCZn6BdlZXZsUJSQpZ8/MGxH
         LKcIWZePEL/SdK6rf2UlRpLOL560R8BaU3sc7EKuG4k7mAlqmIlcabxfTKiJgksfsIye
         WZnOdK8561N84nTSCfyp+NUE7xUMY1tZQt7JvyjHqoD3ALTGEa7yjXvfsbWJ+TPZyxt1
         4qgk4/sXQZMGWLJEjZAXM+3ZD0g7AnFguKdqPo9S/+fyJ+tTfRa8Qon5LiFjrKVp9DPr
         ElYL2sw2PV/DC9Jc/u7P35nD4fWH4wJz7SzcygmeA8akhgEidDfE3ol0MBInSztMr34S
         +Cvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540814; x=1789145614;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=U7s9RqFfNmC/43sJH/vkem1CuLFb7gPj1DqmU+qmN1c=;
        b=N0VMP2ICMckX8iB8KhpyAy3jYUWGaK5w0gvXHusrNtfqgq3VLJ8AwLLCzWuIL29Prs
         zprgns/B+m+zZaj+kBklo9aH6KR2FeFUGlnv8+jjUWj/wFbwf/ezrCfKwwuiVCAW8Uz+
         cHiahgpw56+0GepLzjm4weGwWKHvMWiJlEZ1w+oP+NudXBBsiREn0unMGvX2XQBEiKvI
         NSyPWQnfz2iAJkBLCDooaFTE9RptomqJC3DCwrE7Y36wjF5mwr5MqgldUZG3ZVibP+D5
         zKc8H31iWHpBDkAgKMMqkCuo2Llgu0A7tu774upFVYRCwCdpKLYxBtouFNPsB859ZCNP
         jKRg==
X-Gm-Message-State: AFuF++mY76joZ6atC1jtWuN2dY5tGhXPTM53jM+v26w+/qPPzEa8muYc
	B5vNsmiAWRWdkNGxlzP5SYB6F3yYo4No5AVoP2f+dkSNuWfESqyM5LMLJTaPqShvEFY=
X-Gm-Gg: AYBFou0lDXjstYZ3ULf8sTiMDxEYj3zPvEVYuRXzBmx+NYJVduu0lr1xj4CYKtjBMlC
	pr+7/iTgliwp83VnTZYlOFL3UCQkszaTENKUg8l4PdUyeI5uTGIYEqmKpW+Mta72JgWJA8wN4jI
	00yq1JXUDMFRWoVEIAR6U6uKwVZy7mGn4eqCVBf6fJrzcO+SWyPAKzHpWAquRq7fVS/m6LRIcR3
	8sNliNpVrxum7a8Rtmf3oVLoLckg9KOOU8/GVmxX2AFgdk1dhvRFVFRsz8dlAPGUPXFA/a6lahn
	S5lQ4U36wXHUsVVlUS2SpablorhrXC61k/I0CW6jF85wV388LCM3WYQ3WLZ/zOOse8LnsOKBNbx
	zjo5+R8r6I+MCsvxdoWSAiR5y+1IG1tGkY22f3jLrCXh4sCFsLUq7r1sikDsE6tw1/YLyodRv6o
	D+7TAey1ebpMPU+NKQg5Luy7fujnRPd6Rbun+wqqNTWEUHEiuGA3VGFx7O8Jf+/G4W/bdNE4MJB
	HEJCUhHy+QijYsX+IBa+93F
X-Received: by 2002:a05:620a:1722:b0:939:6de9:4cfa with SMTP id af79cd13be357-93980730585mr656146185a.45.1788540809432;
        Fri, 04 Sep 2026 09:53:29 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:29 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 05/24] NFSv4/flexfiles: Use the full 64-bit offset for read DS selection
Date: Fri,  4 Sep 2026 12:53:04 -0400
Message-ID: <c97e5da23084368cb6a956fce08d96a7fa47522e.1788530385.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788530385.git.bcodding@hammerspace.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
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

