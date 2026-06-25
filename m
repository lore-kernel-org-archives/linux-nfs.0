Received: from mail-oo1-f46.google.com (mail-oo1-f46.google.com [209.85.161.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68A9F3DEFFB
	for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2026 12:05:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782389157; cv=none; b=ApLshfOEeN9CL8PQAzUS8sFiMNA5+naMm1fZpnjvqrQqSIgTEqlUjc1hkfQWq8uIAVy0F292dEqIz5DL0kA3pC7PJNe6qnHBmGJkgqIfCdvGwnbWywChp430CEeF5Ka/MLHtpCi387eQTMLy6gyIiFfavOOuw17JwBX4LTgNVnY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782389157; c=relaxed/simple;
	bh=kzqfBm+YoQprmFNWDfvbrOyf46OGQXv/nkplZ3mJA8Q=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Uv/H/vatU7IbpSw/wvJmDcHbs1UT7C8DcvFcHxi2n9RZpjCf1mbvXoYVrDJCIASopUeou05IAIfHuEGoWJua/ZqD6kZLpzfAh28ZJlhcIWHqix2unBXubWvAcmOfsPqxWvlvjVr52MmkEV7DA1SSCn50e+UyvbcYP1DviScnz6Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=ZKWsE4o5; arc=none smtp.client-ip=209.85.161.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ZKWsE4o5"
Received: by mail-oo1-f46.google.com with SMTP id 006d021491bc7-6a0de515e54so468198eaf.0
        for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2026 05:05:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1782389155; x=1782993955; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=mpcgSOfFSk0v2oQmngG8LYGj7iwosfJ3IA4LeTfZ4gQ=;
        b=ZKWsE4o5lZgu+zlnx6ci6QSUhEai4oEI9MqSUHDJX2SVKX0gRKpa46pHhJZ92FOqzC
         7LhqbXgW8uLcS2uxpkPq4jA/JgehK2A2JYXGbJrDFlmHLyfdhKzBmDbwCo6z5MNrSxMN
         74Lj4RiidPdrHMJ4XqGoTnQNBx8V9gQ5ONdCNUfHSMuHSWMn+8ACtoxEqzZGXLIC5FHs
         OCl7tiY4FvFoWMhIVoWMP3UWik2xa+ZwDXXuDa3rGxZlllWjjSO+v16Ptw+C1Q/qwVay
         uYBnECcZSmN/FjGZqrLF52BrmDI9zdE4OQ3BuYxeh27IYGbV2jgM+7q7NdYkANBe0asr
         U1Cw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1782389155; x=1782993955;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=mpcgSOfFSk0v2oQmngG8LYGj7iwosfJ3IA4LeTfZ4gQ=;
        b=gjJ7P1c5VqGgpR+wbEyPTKe3KmM1pMk8h6WsjdjCx4yv88AbT+CYMEpnVxWACeh1Ik
         ZugpSVIPmuxS3Xz9v6tUlAbPQ7oPd8Ov+8T9g0q5G5D30Yym/eHibbKl2Kiqc108h46L
         q9Uo97eSRzViRHPQO7gReBV3sf4pj9oZ4gjF/tx4BIE38G/AQ3c7NZtBazhEMD5QvDVZ
         UMA1m4aKC0C8zSB6gfjzgwe/GADQ1GSyTqpWUKnISSFI5jxWwWW4n5kpsXoHgwcar2Va
         KflnJqBOfOvfuBSUSm50rVaOcZU5iKAxCJZjz2FWc7/j77/DlAA5P4JMj7HN8F7iy4RA
         7kqA==
X-Gm-Message-State: AOJu0YwKwEg3j2KOujdItIzonXQXiYv3c3V5DkM7ITAOtwjAMsnFUny7
	khCOOatW9MhRI9lx9ZyPdZNjn2oKvO86/vvw08N3aHGGjHE3gVKQPkhW/jV5glkZyeQ4OFaYnWX
	ZU1BF
X-Gm-Gg: AfdE7cmRHhUXKWS1T5SaHB/szPbqy13bCvEm9YNhVkrjlQT96TfLwjKao9iJYOJJ7V7
	zQz5dlktaP6+Qm/i995UiRgjCGdmbINQTrJ3Cl5KOUVzwk/haU4hk4x+/WYey82nIFDasFyhSMS
	Cul+1U7yeqOHg8jnPlL8zEkGP1leAnRrIbcJQaxD0DwPV8aiba4pWVgU7zXWSVZ4CcWHwPSptVr
	T3Zr/c0vE31A+gCQnNRSPOwmOoyJXz4BJ+yDKnW9MXXVwk/ty4dSMCCeROrb8yXNzImV4Cc63fn
	EXeseg4F/0Fvd0IrCw5ZVhhJNzNTtK9v8VfAp8Hfj/MBlcsQUjiYUqG70O7OgBm5bY8O8N2Y1ed
	y+w5amHG5vqRWehss+z96Hw7/fiVJSCl3bY3IHUfABH9uCt5+nb/sxn9zSJrhwRUoBu/fBLNpiB
	o0BEhCkl3C/3Qszlksg1VpDZRSgJcmFT1wid7myDRnAbqxQIga
X-Received: by 2002:a05:6820:1b0f:b0:69e:49c:de38 with SMTP id 006d021491bc7-6a1127fd8d2mr7917381eaf.37.1782389155290;
        Thu, 25 Jun 2026 05:05:55 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4472e79af8fsm11123405fac.0.2026.06.25.05.05.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 25 Jun 2026 05:05:54 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] pNFS: honor clora_changed when recalling a layout
Date: Thu, 25 Jun 2026 08:05:49 -0400
Message-ID: <05e93230d2f58d9d8b23b083d8d89b21cb9f5184.1782388900.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1782388900.git.bcodding@hammerspace.com>
References: <cover.1782388900.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When the metadata server recalls a layout with clora_changed FALSE, the
layout is not changing and the client may complete its modified writes to
the storage devices before returning the layout (RFC 8881, Section
20.3.3).  Only when clora_changed is TRUE -- the server is restriping, or
a storage device has failed -- should the client stop writing to the
storage devices and redirect through the metadata server.

Since commit b739a5bd9d9f ("NFSv4/flexfiles: Cancel I/O if the layout is
recalled or revoked") the client cancels in-flight I/O on every recall,
regardless of clora_changed.  For an unchanged recall this abandons
writes whose data may already have reached the storage device; such a
write can then land after the LAYOUTRETURN, which the server sees as a
write without a layout.

Pass the recall's clora_changed value through
pnfs_mark_matching_lsegs_return() and only cancel in-flight I/O when the
layout is actually changing.  When it is not, the existing deferred
return path waits for the in-flight writes to drain before sending the
LAYOUTRETURN.  Other callers, which are tearing down or returning the
layout for their own reasons, continue to cancel as before.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_proc.c |  3 ++-
 fs/nfs/pnfs.c          | 22 +++++++++++++---------
 fs/nfs/pnfs.h          |  2 +-
 3 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f5cf76d36367..3fb10c8e4271 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -291,7 +291,8 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	pnfs_set_layout_stateid(lo, &args->cbl_stateid, NULL, true);
 	switch (pnfs_mark_matching_lsegs_return(lo, &free_me_list,
 				&args->cbl_range,
-				be32_to_cpu(args->cbl_stateid.seqid))) {
+				be32_to_cpu(args->cbl_stateid.seqid),
+				args->cbl_layoutchanged)) {
 	case 0:
 	case -EBUSY:
 		/* There are layout segments that need to be returned */
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7715e2bd5871..5becc70af16e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -432,7 +432,8 @@ bool nfs4_layout_refresh_old_stateid(nfs4_stateid *dst,
 			goto out;
 		}
 		/* Try to update the seqid to the most recent */
-		err = pnfs_mark_matching_lsegs_return(lo, &head, &range, 0);
+		err = pnfs_mark_matching_lsegs_return(lo, &head, &range, 0,
+						      true);
 		if (err != -EBUSY) {
 			dst->seqid = lo->plh_stateid.seqid;
 			*dst_range = range;
@@ -486,7 +487,7 @@ static int pnfs_mark_layout_stateid_return(struct pnfs_layout_hdr *lo,
 		.length = NFS4_MAX_UINT64,
 	};
 
-	return pnfs_mark_matching_lsegs_return(lo, lseg_list, &range, seq);
+	return pnfs_mark_matching_lsegs_return(lo, lseg_list, &range, seq, true);
 }
 
 static int
@@ -524,7 +525,7 @@ pnfs_layout_io_set_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 
 	spin_lock(&inode->i_lock);
 	pnfs_layout_set_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
-	pnfs_mark_matching_lsegs_return(lo, &head, &range, 0);
+	pnfs_mark_matching_lsegs_return(lo, &head, &range, 0, true);
 	spin_unlock(&inode->i_lock);
 	pnfs_free_lseg_list(&head);
 	dprintk("%s Setting layout IOMODE_%s fail bit\n", __func__,
@@ -1461,7 +1462,7 @@ _pnfs_return_layout(struct inode *ino)
 	}
 	valid_layout = pnfs_layout_is_valid(lo);
 	pnfs_clear_layoutcommit(ino, &tmp_list);
-	pnfs_mark_matching_lsegs_return(lo, &tmp_list, &range, 0);
+	pnfs_mark_matching_lsegs_return(lo, &tmp_list, &range, 0, true);
 
 
 	/* Don't send a LAYOUTRETURN if list was initially empty */
@@ -2621,7 +2622,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 			.iomode = IOMODE_ANY,
 			.length = NFS4_MAX_UINT64,
 		};
-		pnfs_mark_matching_lsegs_return(lo, &free_me, &range, 0);
+		pnfs_mark_matching_lsegs_return(lo, &free_me, &range, 0, true);
 		goto out_forget;
 	} else {
 		/* We have a completely new layout */
@@ -2652,6 +2653,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
  * @tmp_list: list header to be used with pnfs_free_lseg_list()
  * @return_range: describe layout segment ranges to be returned
  * @seq: stateid seqid to match
+ * @cancel_io: signal io be cancelled
  *
  * This function is mainly intended for use by layoutrecall. It attempts
  * to free the layout segment immediately, or else to mark it for return
@@ -2666,7 +2668,7 @@ int
 pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				const struct pnfs_layout_range *return_range,
-				u32 seq)
+				u32 seq, bool cancel_io)
 {
 	struct pnfs_layout_segment *lseg, *next;
 	struct nfs_server *server = NFS_SERVER(lo->plh_inode);
@@ -2692,7 +2694,8 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				continue;
 			remaining++;
 			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
-			pnfs_lseg_cancel_io(server, lseg);
+			if (cancel_io)
+				pnfs_lseg_cancel_io(server, lseg);
 		}
 
 	if (remaining) {
@@ -2727,7 +2730,8 @@ pnfs_mark_layout_for_return(struct inode *inode,
 	 * segments at hand when sending layoutreturn. See pnfs_put_lseg()
 	 * for how it works.
 	 */
-	if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs, range, 0) != -EBUSY) {
+	if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs, range, 0,
+					    true) != -EBUSY) {
 		const struct cred *cred;
 		nfs4_stateid stateid;
 		enum pnfs_iomode iomode;
@@ -2842,7 +2846,7 @@ static int pnfs_layout_return_unused_byserver(struct nfs_server *server,
 		pnfs_get_layout_hdr(lo);
 		pnfs_set_plh_return_info(lo, range->iomode, 0);
 		if (pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs,
-						    range, 0) != 0 ||
+						    range, 0, true) != 0 ||
 		    !pnfs_prepare_layoutreturn(lo, &stateid, &cred, &iomode)) {
 			spin_unlock(&inode->i_lock);
 			rcu_read_unlock();
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index eb39859c216c..673c2b244978 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -300,7 +300,7 @@ int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 int pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				const struct pnfs_layout_range *recall_range,
-				u32 seq);
+				u32 seq, bool cancel_io);
 int pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 		struct list_head *lseg_list);
 bool pnfs_roc(struct inode *ino, struct nfs4_layoutreturn_args *args,
-- 
2.53.0

