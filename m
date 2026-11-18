Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795027021;
	b=QjznQflHHunNxs2SKFU3k8uqTNNZCv9nOojgNhUFO7Le0MsN6R76zM6frFfXQ8QqkC8O
	 3/DReoGkOLZMUrptvno4diNTEOETltLUlhPmj5zw6KUUsD7wnDvrTOFSeAOKhMyobvWhx
	 /qMkoxhxCDb1F+oRmYnVLX+9GzBkJ+cMwhTp75FwC6L0WvR7KZFA8IhlIX/Yj1wNkL96X
	 wO7eNzKhF7/2OGbXb/hzOq//7X4lm8/lPpzRU9k+/BMxgQezCJBamfXUk17jxG879BDSW
	 j2QQWipJe7xx8Hiqjxaqs7419qj5K40VT44bHXAWT1RHLjgxvfWevEDjU73UWIhp9Zg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795027021;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=j8QXwRMqs869Eejn+qu8QSKONCjazQk/Ew5Ph9c0Ris=;
	b=tNmvAEXP+XwHcd6Ec7Q/j3b1D8lLH2l+/FhxUbfjbsFMXUIYqJt0X+d2cAmdTvBk1KYe
	 B88JMhx2/d28SIWXB6hd/XnV+17iu7hxkCeSUWiH005UzTxJziKtmei2+/PSHqVgwMewX
	 TuqBX5IVWe8YuDsgHmniTvRYvnFpsk0qIN2jVNosdxnvXOY72Mf1cXZC6kGVa4yxPPimP
	 rxlNYMDSvVwLONpypSVBsAYjz7i6CdclGWsMpfHaYp04HX9p0676lGWJOFC4jTERrJFrx
	 mrdxp75aJs+cOKGA2/29Yoqps4D8J5zvAgg0uqlBp39y/c7jmn3ogC9X7+C0Nfiko5A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=TtiXlDLw;
	arc=none smtp.remote-ip=209.85.161.49
Received: from mail-oo1-f49.google.com (mail-oo1-f49.google.com [209.85.161.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC866606A320
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 18:37:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EC866606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=TtiXlDLw
Received: by mail-oo1-f49.google.com with SMTP id 006d021491bc7-71ad099391dso765867eaf.3
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 10:37:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795027020; x=1795631820; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=j8QXwRMqs869Eejn+qu8QSKONCjazQk/Ew5Ph9c0Ris=;
        b=TtiXlDLwA5x8KvxWqWUVSUwKUBDSYc/gOw2jK5ZfTB/X1g/RmECD+Z/tfqUSTS77VC
         IjBngFNXjUOoUKri0yw8Uj9JIcmJr5QihyK3JyhURrAYU6YEHUk+8WEwCq0CEphT+htH
         rOnergyaIfgka6NhinvI4OszTCMHAsKbmllBV9BR4vsOS5Qinc/lkMJm3jGgxifbtTp0
         5pko9U8kk2UTC7Yqx5DPh6eg3CpOLOPyvMiaz7+5Z0/U8fYGsEuIy4epmgfaN82PHk0e
         USJTJgY9k+pdeq5v66x5MOZo9oO3Mx4+85ZKsgSxeGF28pl5Nh1a4U3qRvCEBx1bHT1w
         UPXw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795027020; x=1795631820;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=j8QXwRMqs869Eejn+qu8QSKONCjazQk/Ew5Ph9c0Ris=;
        b=g5TbTuKVlYdFIejvPzH1G6+gyokOuVic5LXosxbIWeFVEBEmpdjh6ZseM+AlrbqWlE
         +0ewVrPSiu08FzQAFOmV1JcRgwjwK+GTrSf6e8tf8uDPbEp5c6MlOOJ2/WCEMzcosvO8
         1pIUjbhorXm4s7VIS0I3e6MIdPCRySYiHt2s6KsRmTSCBWHyqO6WyA7MKkWHNgri3SDX
         BPnmRUlGphbSbFmLzfU447nk+1C9TyqdJ/A7DyL5U7dW9qE2NGXCBcji9YuDU7P2NYpj
         q4+WLKcuCJ0yW6Rt7TxS3GGrV567CxbZ4pNAf94976xvoVOUncihnKY2aJnyauEc5TNW
         8KSQ==
X-Gm-Message-State: APuU4Z+H0ijw23J91fQPf0dov2EvBoWNkheyRq+RUT3UO7wIG2c1oxs+
	RrElBmKTNUW6jQ6u15XMMK5C8LWWMFJMjO3neX8XNAbnQ9Mp979SU33wgeMKH92oWe0=
X-Gm-Gg: AYBFou1y4lql+xfA4X7iIC2uPU+3WyTqSPpz9uS7FxU0G0dDG0bhSig/V2Tk+O+iOx3
	GUn6buVD3ASAhTGp3/wSQ+YWBNGVqEWVbp49+xxEJigkuM8JV2hX7mnRyB33YS2zZRlFshKtbPR
	rGcWRC6td9gMYoSO6QeDuGmG9cB23kcrFjwDOol1EKLnC9b9adT6Zym6rAh8KwPMMziLevJF0+A
	sKS2NoaBs/NTPVDcPy9DlLfKErnQ7U/zs1A5G4umq67vfP89J2xYvYcENpPlzSpWXI8HKDZRE9m
	u3Nvk4xTfr+yQ6cuIhiIsxKu4ooM8NX/9c9/giwVmX81/bNG+J5MoN18stCZ+jkib0a5hYB7Z0t
	Q6HEX+E1j/5E6mEtZ8OY5iu6c2GjXvTILQB0eYZzAqb8RV6o8lUlfHEku59b9RQdK+kJQXQB2K2
	N4+UETESw5JVk/Tu3hsHjk5FNYerX+vlBEwsm0OAjmuEoqJnVPr/dU57NbsTLfh3xJiEzOCKk16
	CA1fQ348BeBher4tVHPozwfivGRRKjanZ28D0eEQYCTbiLu0AqfsVW716bX4ovjvLsoXEKnWsDN
	YTiGeX+XX7MoYdCucvJlQOmrBHT4RZgvDem3uoNzmzo1HWONnQlmbZWzkORDS3774kvesBVeR7T
	3
X-Received: by 2002:a05:6808:319b:b0:574:93c0:5aea with SMTP id 5614622812f47-57742a2c3aamr3170066b6e.63.1795027019719;
        Wed, 18 Nov 2026 10:36:59 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5777a8a6af8sm2341713b6e.9.2026.11.18.10.36.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Nov 2026 10:36:59 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] pNFS/flexfiles: remove the layout-header NO_IO_THRU_MDS bit
Date: Wed, 18 Nov 2026 13:36:53 -0500
Message-ID: <bf3238ce14d665e2ae095b41e2b8b89a62d5992b.1795024981.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795024981.git.bcodding@hammerspace.com>
References: <cover.1795024981.git.bcodding@hammerspace.com>
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

Nothing tests NFS4_FF_HDR_NO_IO_THRU_MDS since writes moved to the
inode's NFS_INO_NO_IO_THRU_MDS bit.  Remove it, its helper, and
nfs4_flexfile_layout::flags, which held only that bit.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c |  8 ++------
 fs/nfs/flexfilelayout/flexfilelayout.h | 16 ----------------
 fs/nfs/internal.h                      |  9 ++++-----
 3 files changed, 6 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 4eb12bbb7838..a522c3fe49e5 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -641,12 +641,8 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 	if (!p)
 		goto out_sort_mirrors;
 	fls->flags = be32_to_cpup(p);
-	if (fls->flags & FF_FLAGS_NO_IO_THRU_MDS) {
-		set_bit(NFS4_FF_HDR_NO_IO_THRU_MDS,
-			&FF_LAYOUT_FROM_HDR(lh)->flags);
-		/* Outlives this layout hdr; see NFS_INO_NO_IO_THRU_MDS */
+	if (fls->flags & FF_FLAGS_NO_IO_THRU_MDS)
 		nfs_set_no_io_thru_mds(lh->plh_inode);
-	}
 
 	p = xdr_inline_decode(&stream, 4);
 	if (!p)
@@ -1145,7 +1141,7 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	 * MDS there is no fallback to take, so wait for a layout on the
 	 * same terms as the -EAGAIN above.  The layout hdr that carried
 	 * FF_FLAGS_NO_IO_THRU_MDS may itself be gone by now, which is why
-	 * this asks the inode and not the hdr.
+	 * the flag is kept on the inode.
 	 */
 	if (!ff_layout_inode_no_fallback_to_mds(pgio->pg_inode, IOMODE_READ))
 		goto out_mds;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 5d5587fded76..bb60537b2b93 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -113,16 +113,12 @@ struct nfs4_ff_layout_segment {
 	struct nfs4_ff_layout_mirror	*mirror_array[] __counted_by(mirror_array_cnt);
 };
 
-/* nfs4_flexfile_layout::flags bit indices */
-#define NFS4_FF_HDR_NO_IO_THRU_MDS  0   /* any lseg has had FF_FLAGS_NO_IO_THRU_MDS */
-
 struct nfs4_flexfile_layout {
 	struct pnfs_layout_hdr generic_hdr;
 	struct pnfs_ds_commit_info commit_info;
 	struct list_head	mirrors;
 	struct list_head	error_list; /* nfs4_ff_layout_ds_err */
 	ktime_t			last_report_time; /* Layoutstat report times */
-	unsigned long		flags;
 };
 
 /*
@@ -186,18 +182,6 @@ ff_layout_no_fallback_to_mds(struct pnfs_layout_segment *lseg)
 	return FF_LAYOUT_LSEG(lseg)->flags & FF_FLAGS_NO_IO_THRU_MDS;
 }
 
-/*
- * Sticky hdr-level mirror of FF_FLAGS_NO_IO_THRU_MDS so callers that have
- * no current lseg (e.g. between LAYOUTRETURN and the next LAYOUTGET) can
- * still honor the no-MDS-fallback policy.
- */
-static inline bool
-ff_layout_hdr_no_fallback_to_mds(struct pnfs_layout_hdr *lo)
-{
-	return test_bit(NFS4_FF_HDR_NO_IO_THRU_MDS,
-			&FF_LAYOUT_FROM_HDR(lo)->flags);
-}
-
 static inline bool
 ff_layout_no_read_on_rw(struct pnfs_layout_segment *lseg)
 {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5af6a032f145..5b40364fc38f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -556,11 +556,10 @@ static inline bool nfs_file_io_is_buffered(struct nfs_inode *nfsi)
  * FF_FLAGS_NO_IO_THRU_MDS in ff_layout_alloc_lseg()).  The RFC 5661
  * mdsthreshold hint must not be acted on for such a file, since the only
  * thing pnfs_within_mdsthreshold() can ask for is the one thing the
- * layout forbids.  Servers are assumed to be consistent in their
- * no-fallback policy per file, the same assumption
- * ff_layout_hdr_no_fallback_to_mds() already makes; if one were not, the
- * only effect is that its mdsthreshold hint - a SHOULD - stops being
- * honored for an inode that is already in core.
+ * layout forbids.  Flexfiles also retries reads and writes that have no
+ * layout segment instead of sending them through the MDS, except
+ * writeback of a single locked folio (pg_allow_mds).  Servers are
+ * assumed to be consistent in their no-fallback policy per file.
  */
 #define NFS_INO_NO_IO_THRU_MDS	(30)
 
-- 
2.53.0

