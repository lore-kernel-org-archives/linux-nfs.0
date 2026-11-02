Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.181
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627824;
	b=5aGm1rPy+qgYgPo7GGel0s5CSLyW+t/6Wq4pFjUMncnnkGJplJ1FjW6PfO9FrvnnLGec
	 t/aEOCMaBAEUdHI0+PW9OZ41rv4OJ/7BeUtvl2dKlILJvb/aU5aPZWxZxoVyvMb72hfRZ
	 VDwnTM8tJyx0ZuXETTBY/iYK0aMxYvvHe1zqryiHZEI/56PikUgN8NATQFU05oz8edrUn
	 KuTrHT+Fnm6DLsaTuMc373uzDKmBYLK5ce7YydxUNyDdtyvUFXi+A9NUoqa0NDNw7PT20
	 zUhAV16guERloN39V7SoRsng1UpAJZvDUG1UrhA1JtkUiNPEfvbZQ2SkvukHWPlk70g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627824;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=Qji6DjJf8RZGGPaQoxhX/KHWxH4GckXHtPNuAkSDrek=;
	b=LggJMFGBccinLgyY4PPoyW5sax6xUBxrVqw7HO9Hf29E7oSiS2qCEiIZazKyOn3Nyr3F
	 9KPh7AHKSOAozMoja9OUHJ6COOyKolIIQTQNS2rbxd8Grd1XHAIymq0Z333QtnkFhu0/w
	 FCRbUsOnGFOn6JqH2mWf98T3bCeSYqWqpdO1eqXh/N589BXtm3CEtF/I0MMEFiSDxCd/k
	 QmNb4IEJJlXGs+3juT54cfwYdKWbI9mb+pKCFFIWO4aC3lwW8YyXkGdgF10bRBdoqkjf8
	 3jE4v9AHt1ZGSb8vvpazyG4nPy2ZaN9PVvJSKKOBeApxPxtv5bio5dx0vww3EwHAvvQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=iGZMxINq;
	arc=none smtp.remote-ip=209.85.167.181
Received: from mail-oi1-f181.google.com (mail-oi1-f181.google.com [209.85.167.181])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA7AF60A380A
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:57:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AA7AF60A380A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=iGZMxINq
Received: by mail-oi1-f181.google.com with SMTP id 5614622812f47-4b190cdc9feso2091370b6e.0
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 05:57:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793627822; x=1794232622; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Qji6DjJf8RZGGPaQoxhX/KHWxH4GckXHtPNuAkSDrek=;
        b=iGZMxINqFmUQws8Y27EdJ/51bHeH7MV8wCd6APQsAApnTwS4levTNPs5KWFyOA4DDV
         2vE7lGjBK5rF/QDyyZ9bPlyBFwTLqToFTMxawpMl7Iv0k71dN1Vt/xbzONXvPtY8g0SP
         TXc8Opgn/YQAfckiMRhgcrwMmkQJPL5OE90TOR8axEs2OMp3ctW677bETUR1/SLPlv8A
         cg3GoT4RrbZLbnqmDl1YBXJM+wiWnNJQt8E9aiE9x6XvHWsMx7JRoeREblihMLRdj7c1
         ZT/k3q7WO7FPhahp8T6aPkVYh/DucH5hZIhBYgycTdCmzmGJX0iEXrSUkZZ2UcBD9IDY
         d9ug==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793627822; x=1794232622;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Qji6DjJf8RZGGPaQoxhX/KHWxH4GckXHtPNuAkSDrek=;
        b=Mmx8/ZuM7yaOMbJLnvOXuaozCbrxvuosj86z0D6vg36K56gKujXvmMTiIC/GypZ1Qt
         3ydsAxtga/lcPzowYSmJoQScra4669X7BQ9UDzVZcBDD7NhlgpaVZ4QItiDRXu7jFV8+
         A+Q+FXvjMiTxW1TTvvJCqd4rAOpLxiBJbIQeOLDQRGZPnQkLnO/ZvExc5Rb5Khi22Aut
         SeU5xy4PJEIl1ZN4w7m0SuAhFrFueEUyt3NXvEuHYD7HAASbqVVRG0vXWyy6lKdA6PwJ
         L4WYXjfSLrhfG8Uyf415c+EbrLITAtUidyQ2vYzEiJ2CP+sDcAAHbIN1rNl9q+swFGNQ
         uHew==
X-Gm-Message-State: AFq9FYJJCYf9smB5l2lY5HQwyCPbUwLEFhd4g+TQhjlStV2GvzrgLjDS
	ZeZ95SZefKqtDBzDdHpOtJg9Fd0IIZWUr+akjkLfrgNn9R1+cP1QmRJWwotZF3n4BEc=
X-Gm-Gg: AYBFou1BU+SWiVb3qpuvSfGcWttFa+Akh12ioal+rYUtX79BYIId2bLgKcxjstN3QLB
	v4mYte4Km8JKOwXdC05uoIU3lgz6OddV54RryrJ/+ILIQCaUg/gVlgZbgb8NeihvoOEuHnS7BOQ
	/4Ej3cdbXc57i0HZ9mt393Ft1VFL5PzvWJU0RcdT9j8h/u9T0zyWnu2Gx73qOBuG2a6dQIOWSwE
	GyRfrqUlE9ljXGwWA/B9eF+r1ZKNtbeaZANoNr8haYxrgFNUE3IW8xVTxqHqyjmw9ayRfZB8fWu
	42TgVeQOVEbzboDF0aIywKO4ElmryYTUfDhjkaDM9XchVFHBrgRLCsJfSALK4FfRApWZ0zBfZXv
	datGVAraNL+SOdXvUm60Ih1+gz1TAe3AVH5ukRldw7S4r35cxQ8it3JaomiLQKMdehwgAqLicmn
	AmLT0Slltn/Og1CdUJP5WMy90sM7pDcP/ggOikolzwshjTjstvm5vG4XAVR0KblAhgeS6ui64B5
	ZVMBqfKZaJtwmZPUsx984YEY3hWizdlpEyBzzVb2yCu3dLY7GecGmgUxczt+/udbrecjg0ZPG1b
	ubDRCD6DGNgoRTpw24Js57LA6nw3P/DnuAfLmUbVahNcSI5HMFIus0ZAxzN87zszXli3BcP5
X-Received: by 2002:a05:6808:1907:b0:4cb:f21b:6f8e with SMTP id 5614622812f47-5640dda81f5mr7428166b6e.33.1793627822256;
        Mon, 02 Nov 2026 05:57:02 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fd95562sm7980806b6e.4.2026.11.02.05.57.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 05:57:01 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 6/6] pNFS/flexfiles: write through the MDS while a recalled layout drains
Date: Mon,  2 Nov 2026 08:56:53 -0500
Message-ID: <237de8be8f7a6bb082e381da0b83a192f1ba91e8.1793627813.git.bcodding@hammerspace.com>
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

When a layout carries FF_FLAGS_NO_IO_THRU_MDS and pnfs_update_layout()
returns no layout, ff_layout_pg_get_mirror_count_write() returns -EAGAIN,
and nfs_writepages() and the O_DIRECT reschedule path retry the write at
once.  pnfs_update_layout() returns no layout while NFS_LAYOUT_BULK_RECALL
is set, which lasts until the I/O on a recalled layout completes, so
writers spin for as long as that takes.

FF_FLAGS_NO_IO_THRU_MDS is a hint (RFC 8435, section 5.1.2), so while a
recall is draining, write through the MDS instead.

Fixes: 1d62e659c0bf ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS in pg_get_mirror_count_write")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c |  5 ++++-
 fs/nfs/pnfs.c                          | 19 +++++++++++++++++++
 fs/nfs/pnfs.h                          |  1 +
 3 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 9492d6bc1d1a..9777c83645ad 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1222,11 +1222,14 @@ ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 			NFS_I(pgio->pg_inode)->layout,
 			pgio->pg_lseg);
 	if (NFS_I(pgio->pg_inode)->layout &&
-	    ff_layout_hdr_no_fallback_to_mds(NFS_I(pgio->pg_inode)->layout)) {
+	    ff_layout_hdr_no_fallback_to_mds(NFS_I(pgio->pg_inode)->layout) &&
+	    !pnfs_layout_recall_draining(pgio->pg_inode)) {
 		/*
 		 * FF_FLAGS_NO_IO_THRU_MDS: no current lseg but the server's
 		 * policy forbids MDS fallback.  Surface -EAGAIN so writeback
 		 * retries rather than silently issuing the WRITE via MDS.
+		 * The flag is a hint (RFC 8435 5.1.2), so don't wait for a
+		 * draining recall.
 		 */
 		pgio->pg_error = -EAGAIN;
 		goto out;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5429ab72c4ba..6d6e2a1f8cb5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -593,6 +593,25 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 		set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 }
 
+/**
+ * pnfs_layout_recall_draining - check for a recalled layout still in use
+ * @inode: inode to check
+ *
+ * Returns true while I/O on a recalled layout keeps LAYOUTGET blocked.
+ */
+bool pnfs_layout_recall_draining(struct inode *inode)
+{
+	struct pnfs_layout_hdr *lo;
+	bool ret;
+
+	spin_lock(&inode->i_lock);
+	lo = NFS_I(inode)->layout;
+	ret = lo && test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
+	spin_unlock(&inode->i_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(pnfs_layout_recall_draining);
+
 static bool
 pnfs_cache_lseg_for_layoutreturn(struct pnfs_layout_hdr *lo,
 		struct pnfs_layout_segment *lseg)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 0fb3c7fd8a27..2a4a1d7699f1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -310,6 +310,7 @@ bool nfs4_layout_refresh_old_stateid(nfs4_stateid *dst,
 		struct pnfs_layout_range *dst_range,
 		struct inode *inode);
 void pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo);
+bool pnfs_layout_recall_draining(struct inode *inode);
 void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			     const nfs4_stateid *new,
 			     const struct cred *cred,
-- 
2.53.0

