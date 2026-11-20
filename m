Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191080;
	b=Z8/7RwQUwJVj3viTMXNmVoY1YwQrIFqo0ncTFtvwX43pPqxZeljqQV5WvPMW2fHR4Bzt
	 KZ3e5PRxWa8gxKzaPssaiQtPHveivafCi3kr5hIx1T3PZ47PKANYmOD7XJH1QOGFOuWSn
	 2qJfvp0n9ULXnaJwCq3hf4P6gcYAA8rs1/SXCZralmq3FWiYORckJqitAecbPm9QlWhSH
	 no9Fjt2FLOjmTM1fCfncU+AI+BGTKEOhngmwF+ZiAsbMw+mnvtUKpscUhYPPNrs2D3vDA
	 S7FvGLRV3JMu72uzQf8tbjOMoI+82L0arICB103aIyzTDKq+3uJHkitzfpMtXPoVJyw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191080;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=tbqMmbbY0N4WHFolclwN02xgVLmDte5SGjO4TqvbfuY=;
	b=iBv7JJAiPoR0tNnqx2u3OtyMHgQAKaobJxzlxGxA460tTAVaxNAxPPEVHHd1eLMeJo9G
	 stWwzJ3tGA2uE/3y67e8qfI0YzD+ng4VrpI4Ic8Vau9WddHqxsdBE67m2ry9hpVZHHSr3
	 8JDnnXh9KMJ7ZTe4XfMzJUfvhflTUlUBw1J0rQGC96NDAQAb+7CAhWHfA/Ro8G/RTejym
	 5rCHv/UbmWQoCOx5UqX4ycbcB0EqT0T9OyM6BjvwS2Ba+pOUTn9+2lh6EChTMUmBz9+/w
	 bfo0y9drhJ48PamddZ+jGqOhmiTYx+k45nLwRkE0G3gzlKKULblxWZlZHG0srgp+VnA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Buj3M7bO;
	arc=none smtp.remote-ip=209.85.210.51
Received: from mail-ot1-f51.google.com (mail-ot1-f51.google.com [209.85.210.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC6F1606A320
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:11:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DC6F1606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Buj3M7bO
Received: by mail-ot1-f51.google.com with SMTP id 46e09a7af769-85a5455bd3cso646668a34.3
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 08:11:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795191079; x=1795795879; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=tbqMmbbY0N4WHFolclwN02xgVLmDte5SGjO4TqvbfuY=;
        b=Buj3M7bOmJiGXf4OeAe5TWUS+emzNMQDS3YN54mOzVkovtOp4gsM73TMkLncY+fuej
         8maTqk3xJOwaXyvWKrCoiSAva7d0b10QuUY7hyidgAcg2yZnuach5bpm+C2NnUZINfuF
         /ZEH91czYvYhlpHK9Xi7AYZ88NhwInIltT9xwWjkWpq7TJVtMFkI1XQp0WNpozpgv/Dt
         lkzttOIYBnd2kEj7svm8Xc7+cICuEQCjTVbO8lwFPJ39tlDOEGkKerOuXGboCR/sRxqj
         OuKfVgq+hhF09sMOxSYjL2ch33/j+kd2bmortGcNXVBlLc3eGOoWLZOU3VS7m0rJ+r1f
         pbPA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795191079; x=1795795879;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=tbqMmbbY0N4WHFolclwN02xgVLmDte5SGjO4TqvbfuY=;
        b=cbMA5n+bS8bib7GfxTN+KdOPDnvmHGPIPlksjTh0nRjZZLqxp47DCIz/61edlp8vKn
         +GfR6nNi/PKDBqKIGOlzDwWk5G04DJEhspXPCco987FerqVUwGcKnpYPhOVSrju84bEW
         AK/4J3PNk3GTK12tFWrK9CjSfFlVJ8vY3uf9Jm/xhEfot7In7UYK9Ldc6kZ8j+X13pO4
         nOeMV+ScqCRhbAtCc1k1CJJiA6yb1LdiuLql6FpBKLNySa0Nia8LuT3zGriN049kfxtt
         54hLODRurL9he/RxkWxuxtxSA0ZQnAFb2H8YbWyhRTdL+/diXfnTtFOXqtMiGNf83mtP
         NAlQ==
X-Gm-Message-State: APuU4Z8FXdlRnjsaHlSHoK79DafkkMZGHWlXHSpypZd53/Zu6XBjnXX+
	QH5nreGCiaW8zmzu6BEg1xxUj0N2UMu69BM+WrNsNYPx9AvEun2yuO8Fvr+Jkx+e/Rs=
X-Gm-Gg: AYBFou29xlEEBGCRZ5eXHmRbGM9iXVyQm3+oymgUePpsoXvN7SXF41NkjQMSgAg/Bou
	jU/xmBmsCgQkK/TsKJnQCqPqX5X3+DKlXawHC1oLrcp/xMVMC2c0suzL998jgTjMLgRDN6UjE+Z
	TSNRT4qgv6mhEnt6fSJOX4ZR73t3WgYHFy/YrfBxiYFE87B7N9XGseoC4LHfhw8VJskoSOQA5VU
	ERu7NaCI9heM9/XQvScvl7i8LpzFqA+OvKd93a6EFqv/+rZMix6p9PElmD7K4MW/hK3XxDFX5ld
	BrCUBx9lYlSuwCapeRG1MWSvZpbiCFLPOCyE5u4Y5Jr7ZxfizzWHESQHeAFuBp1JGDmXkozIlfE
	II9csX7vicxk/YI5r1r8uQ9lR+iIcUg4oSx3vewFkdM7G799QjUW87xhsWB09RXdjNa4CfAEMyP
	dqOdBHoEjJNnYqropgWjDv4TdfFnGRk5bPSp+c9CjLF70ffygDI/axapAgl7MYzUIMkaI/cKfB1
	tMdJYozzFgL5KoD8slZcgUgvj8XWZXflBeUXJtGsZGQBM4WgEGdREYocLGLEdvoDsgKqEL79+U+
	ue9Xz2NJcWFDJSlF5Lyv3ch+0qpAI/YJudPL7lC7gBoKXsgLvbOyetGyPOS6ETq21eKMYLsvCE8
	q/1cZ7FypJNjPJmClIV58GN84qiIzXwc=
X-Received: by 2002:a05:6830:349b:b0:862:bc33:daa4 with SMTP id 46e09a7af769-863157cd1ddmr3876258a34.8.1795191078587;
        Fri, 20 Nov 2026 08:11:18 -0800 (PST)
Received: from bcodding.csb.hammerspace.com (196.sub-174-201-28.myvzw.com. [174.201.28.196])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8631690fd36sm2441034a34.20.2026.11.20.08.11.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Nov 2026 08:11:18 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/4] pNFS/flexfiles: don't switch a busy mirrored write descriptor to the MDS
Date: Fri, 20 Nov 2026 11:10:50 -0500
Message-ID: <efbbac89fdfc01e012b3368afc24c32e2e7869dd.1795148523.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795148523.git.bcodding@hammerspace.com>
References: <cover.1795148523.git.bcodding@hammerspace.com>
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

nfs_pageio_reset_write_mds() replaces pg_ops before it completes the
descriptor, so the completion sees only mirror 0.  Requests queued on the
other mirrors are never sent or cleaned up, the mirror array they are
linked on is freed, and their folios never leave writeback.

ff_layout_pg_init_write() falls back to the MDS from a later pg_init while
other mirrors still hold requests: when the layout segment is gone, or when
a mirror's DS cannot be prepared.  After the previous patch the mirrors are
sent together, so this happens when one mirror's request is retried during
completion while the others still hold theirs, or when pg_init fails
partway through the mirror copies of a request.  In that case return
-EAGAIN as for a mirror count change, so error cleanup redirties the
queued requests, or requeues them for an O_DIRECT write, with the
flexfiles ops still in place; the next pg_init starts from an empty
descriptor and can switch safely.

ff_layout_write_pagelist() returning PNFS_NOT_ATTEMPTED has the same
problem through pnfs_write_through_mds().  For a mirrored layout, handle
the failure the way FF_FLAGS_NO_IO_THRU_MDS already does: mark the layout
for return with the failing device and return PNFS_TRY_AGAIN.  RFC 8435
section 7 asks the client to retry with a new layout before falling back
to the MDS, and section 8.2.3 leaves it to the server to decide, in that
layout, whether the errant mirror stays.  The retry's pg_init then uses
the new layout, or goes to the MDS if the server has none to give.  A
fatal error preparing the DS, such as -ENOMEM or a signal, is no
evidence against the device, so retry that one without returning the
layout: pg_init prepares the DS again and falls back to the MDS if that
fails too.  A single-mirror descriptor keeps using PNFS_NOT_ATTEMPTED:
pnfs_write_through_mds() switches it safely, since its only mirror is not
freed.

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Cc: stable@vger.kernel.org # v4.0+
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 39 ++++++++++++++++++++++----
 1 file changed, 34 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 3adfcc7d0cfc..338d1c08c1e1 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1133,6 +1133,22 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	nfs_pageio_reset_read_mds(pgio);
 }
 
+/*
+ * Switching to the MDS discards the mirror array, so it must not happen while
+ * any mirror still holds requests.
+ */
+static bool ff_layout_pg_mirrors_busy(struct nfs_pageio_descriptor *pgio)
+{
+	u32 i;
+
+	if (pgio->pg_mirror_count == 1)
+		return false;
+	for (i = 0; i < pgio->pg_mirror_count; i++)
+		if (!list_empty(&pgio->pg_mirrors[i].pg_list))
+			return true;
+	return false;
+}
+
 static void
 ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			struct nfs_page *req)
@@ -1198,6 +1214,8 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	pgio->pg_error = -EAGAIN;
 	return;
 out_mds:
+	if (ff_layout_pg_mirrors_busy(pgio))
+		goto out_eagain;
 	trace_pnfs_mds_fallback_pg_init_write(pgio->pg_inode,
 			0, NFS4_MAX_UINT64, IOMODE_RW,
 			NFS_I(pgio->pg_inode)->layout,
@@ -2458,15 +2476,26 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	nfs4_ff_layout_put_deviceid(mirror_ds);
 	if (ff_layout_avoid_mds_available_ds(lseg) && !ds_fatal_error)
 		return PNFS_TRY_AGAIN;
-	if (ff_layout_no_fallback_to_mds(lseg)) {
-		/*
-		 * FF_FLAGS_NO_IO_THRU_MDS: force fresh LAYOUTGET,
-		 * never fall through to MDS I/O.
-		 */
+	/*
+	 * FF_FLAGS_NO_IO_THRU_MDS forbids MDS I/O, and
+	 * pnfs_write_through_mds() cannot switch a mirrored descriptor.
+	 * Return the layout and retry with a fresh LAYOUTGET instead; a
+	 * mirrored write reaches the MDS only if the server then has no
+	 * layout to give, or pg_init cannot prepare the DS.
+	 */
+	if (ff_layout_no_fallback_to_mds(lseg) ||
+	    (FF_LAYOUT_MIRROR_COUNT(lseg) > 1 && !ds_fatal_error)) {
 		pnfs_error_mark_layout_for_return(hdr->inode, lseg,
 						  &mirror->dss[dss_id].devid);
 		return PNFS_TRY_AGAIN;
 	}
+	/*
+	 * A fatal error preparing the DS is no evidence against it; pg_init
+	 * of the retry prepares it again and falls back to the MDS if that
+	 * fails too.
+	 */
+	if (FF_LAYOUT_MIRROR_COUNT(lseg) > 1)
+		return PNFS_TRY_AGAIN;
 	trace_pnfs_mds_fallback_write_pagelist(hdr->inode,
 			hdr->args.offset, hdr->args.count,
 			IOMODE_RW, NFS_I(hdr->inode)->layout, lseg);
-- 
2.53.0

