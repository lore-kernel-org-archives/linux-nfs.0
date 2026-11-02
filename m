Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627822;
	b=13VtxMUCnJV+iO+okMEKJ0dTrBW6bK5YeKkF7jRyXM6xZ7BvMz6TPbYPfe33/gsEJm2i
	 85AhH1nDmm0pFYhbA5EN5Uj4Yhn0A4uvgnh0GtG6Yo9nRP+o842hMFK3fNNdVwUZ7a9pJ
	 6kG+KcgzUCOg5ftu84htN9EBo6SkA8VvqhA1KWvosWVG+xOpttazkfeM3ImsPfGjrVVj7
	 uLP1ghtioxAsRUVq4OUag3Q5Kybt3ZVVA8ZX3+UnaJjd4x/eFn+jpRbhyt97UjHQYaz1A
	 R5sRfaKpmGBx5ik10POckrNrPn53gi4TcTSSeY5KKm5AUvWEMWxNq/7A4MQ2aYmtoFQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627822;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=O8baMiaE0fhZda2TyIGfcVSoOSJpHnUj6SY3szVRUN8=;
	b=WeDy4/W+KnqwEE1LLZvlSo0AQTZ5+tH1j+MaIO1ttNeNKKxRCySOqPK3dorzZc5doRfm
	 wKTDKQ7i2R3p/FSDqAHcqOcM7vMG46rNiOYz0dpVEUywczIbPSUK2m0GDkoY/KiIm1WhI
	 3I4RtvO8veEQRlzk/r7jhk7QIIVsUXdAt4jhaAl+ddKyss6XnNoL0rM/0GxquXlLxxPmO
	 KmRofTmVO2rPDy+7m9Qjq/NXP3xDf7EVwSf5FSQvJqp0bOyhOVfhpe1kjhQXNouH/H11U
	 z1URZQ+0ABrfpno9N9ccaPCCZXuvFawUyaaD5RMnAOJFGgt41UCq1IQoR4IQaGpWiTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=mLROe5GO;
	arc=none smtp.remote-ip=209.85.210.50
Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com [209.85.210.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44C3760A261E
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:57:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 44C3760A261E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=mLROe5GO
Received: by mail-ot1-f50.google.com with SMTP id 46e09a7af769-847ac7ccd85so2006638a34.3
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 05:57:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793627821; x=1794232621; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=O8baMiaE0fhZda2TyIGfcVSoOSJpHnUj6SY3szVRUN8=;
        b=mLROe5GOoOhNE09bGauY3v7Y7xa3ol9e4b9oL0XHyKJQ74zbiX5qS3ZW7sNZQHsWoN
         1yniieIEUObI4vFwNYdvVMlT9Oh42NHyRpHPMpPHXUbgyUMHfq4VYTQCc8tqWzrreqkA
         4drMtpMXnBstm38ziFRKhXHSwz3dtKyQMPnFqV4beTmUCsd2ZD0+EQVssdZ3wf7i1Kpr
         JH/DZTWldRJ0UR/ffEvC9B9hXDMr5KmtA0ilPfpzJwMx8/j/LOjL1GRU8RikARU5ixH4
         W8BG6wP/4CXOu8OM2Qmc6L4/ZMnChzhRQoD2eblpMEWAwrStq4vaVyfVv7PJNTDwZCud
         IJFA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793627821; x=1794232621;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=O8baMiaE0fhZda2TyIGfcVSoOSJpHnUj6SY3szVRUN8=;
        b=BMf7ku8nwE1AY6riw0RPVlGfhB/H9XbOoaBKmOCQY0OzOKWnyw++hP0OqaptZ+4PG4
         uxfCuCKzVm2gZGbUW+jd/LErcZ1mjdGQTbM8Y3Zj7S+vpvGWMuDxsMC+/XcZlUzHI7xT
         TNBXIeVmJAm7+DWRHXLirPqmxt4jCWtxt0eqIVh9SmaQgblQHgrnlldtjqBMhJh4smVa
         rqrjxHywFkBeX6sETDspjJvvDNqjGlJlpTsbHOZYzyREjgtRm1giHBX44t22qT1pqjf7
         +uhg0Npr8u9LdCF6pRFisho7cfeqKJoyhAaMjkpzGg2Ewz8gWMLEHhLLCkHrTA89MZl0
         ic/Q==
X-Gm-Message-State: AFq9FYK0zf2Gzl7JfmytcbnyXdIk0DF4YIeDgMbzpF0Tqj/QcxSYxXy3
	QfYMBbUicfgofKkkzTQEb2tEiC/xwkyvYwEIo24y+8QBBdN051RVIn4TQzKV4H4NsOo=
X-Gm-Gg: AYBFou2sdE+T8/QiG/J/I3CmwT8npo7Jbh/PZoR4/P1CdPnJPbkER4EdQiJt4Mb8KcV
	bf5E4xDp+CXVpy7mWiT4n8wXt4hQ+1WDuRiZpTnVENvW0u13qD/rCaRWWp6/h6f7rSsCICdwFE1
	cWGkYXLg9+WV0dZtMVORJQH9ntA9GWgTVBvZN6/nNZaodSY3tVJpQ7W2fdKwO8F3e53KYXAL+0S
	1S3AkvW4Lu4ZKNYvZggkqlZYmF8BO0T6SSFQC+zbG8di+W+Vvgw2SeULe3qwm6KWF2mkRAC51jL
	JF/TDqmr99tTq8supwz2PRCamWlELCaNCeba3abJYHI7EWapF19VFiZGyL8PY86/akI/iGfBdFC
	S1fBwzyeJCfv0a2sc0NBnUOCBlp9qYS/JaOqzVvZDMVzVkHJ4vmom96P/HvTfZjZWmZc3gKrW9g
	i9yrTD0zs9ttZNg0tLkTMAtljQFJtmklPypE7VxIeiIJjyPITgflEvXlHli1mgLcXOgagPswacI
	GhBYRCVt1ao3V19Jg7hOnbzBQdTc8MHaIItaM0QB/KGDKkfp2gdroQ1i62+PbzmaNiQ4AqqEu+I
	J2ej9afuNeLb+YU2Vtmji6clFx3weoPhwJLmb3MawcWtRBGUNwFjGY9y0rYsyNujS24lReTh9g=
	=
X-Received: by 2002:a05:6808:1992:b0:4f4:be18:5de2 with SMTP id 5614622812f47-5640deea03dmr7297472b6e.13.1793627821070;
        Mon, 02 Nov 2026 05:57:01 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fd95562sm7980806b6e.4.2026.11.02.05.57.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 05:57:00 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 5/6] pNFS: answer a file recall with NFS4ERR_DELAY while I/O drains
Date: Mon,  2 Nov 2026 08:56:52 -0500
Message-ID: <9a4784a439d540b7ffdba1c201fce5f87e351b1e.1793627813.git.bcodding@hammerspace.com>
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

A layout stateid can be invalidated without a LAYOUTRETURN, for example by
pnfs_destroy_layout() after an NFS4ERR_BADHANDLE, while I/O still holds
its layout segments.  pnfs_check_callback_stateid() then answers a
CB_LAYOUTRECALL for the file with NFS4ERR_NOMATCHING_LAYOUT, so the server
treats the layout as returned while that I/O can still reach the storage
device.

If the recall matches the invalid layout stateid and a segment within the
recalled range is still in use, answer NFS4ERR_DELAY.  As for a valid
layout, cancel the I/O on those segments if clora_changed is set, but only
for the first such recall.  Set NFS_LAYOUT_BULK_RECALL so that I/O needing
a new layout goes through the MDS, or is retried if the layout doesn't
allow I/O through the MDS, rather than waiting on a LAYOUTGET the server
won't grant while the recall is outstanding.  The flag is cleared when the
last segment is freed, and the resent recall is answered
NFS4ERR_NOMATCHING_LAYOUT.  This relies on "pNFS: clear
NFS_LAYOUT_BULK_RECALL when an invalid layout's last segment is freed" to
clear the flag.

Fixes: bd3d16a887b0 ("NFSv4.1: Fix a potential layoutget/layoutrecall deadlock")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_proc.c | 12 ++++++++++++
 fs/nfs/pnfs.c          | 30 ++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h          |  3 +++
 3 files changed, 45 insertions(+)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 722bb5475a48..a132990194cb 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -276,6 +276,18 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		goto out;
 	}
 	pnfs_get_layout_hdr(lo);
+	if (!pnfs_layout_is_valid(lo) &&
+	    nfs4_stateid_match_other(&lo->plh_stateid, &args->cbl_stateid) &&
+	    pnfs_invalid_layout_busy(lo, &args->cbl_range,
+				     be32_to_cpu(args->cbl_stateid.seqid),
+				     args->cbl_layoutchanged &&
+				     !test_bit(NFS_LAYOUT_BULK_RECALL,
+					       &lo->plh_flags))) {
+		/* Block LAYOUTGET until I/O on the invalidated layout drains */
+		set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
+		rv = NFS4ERR_DELAY;
+		goto unlock;
+	}
 	rv = pnfs_check_callback_stateid(lo, &args->cbl_stateid, cps);
 	if (rv != NFS_OK)
 		goto unlock;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2d2904eb7d34..5429ab72c4ba 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2766,6 +2766,36 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 	return -ENOENT;
 }
 
+/**
+ * pnfs_invalid_layout_busy - check for I/O on segments of an invalid layout
+ * @lo: pointer to the invalid layout header
+ * @recall_range: range being recalled
+ * @seq: seqid of the recall
+ * @cancel_io: cancel I/O on the matching segments
+ *
+ * Returns true if any segment matching the recall is still in use.
+ */
+bool pnfs_invalid_layout_busy(struct pnfs_layout_hdr *lo,
+			      const struct pnfs_layout_range *recall_range,
+			      u32 seq, bool cancel_io)
+{
+	struct nfs_server *server = NFS_SERVER(lo->plh_inode);
+	struct pnfs_layout_segment *lseg;
+	bool busy = false;
+
+	assert_spin_locked(&lo->plh_inode->i_lock);
+
+	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
+		if (!pnfs_match_lseg_recall(lseg, recall_range, seq))
+			continue;
+		busy = true;
+		if (!cancel_io)
+			break;
+		pnfs_lseg_cancel_io(server, lseg, NULL);
+	}
+	return busy;
+}
+
 static void
 pnfs_mark_layout_for_return(struct inode *inode,
 			    const struct pnfs_layout_range *range,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 2774d4adf4c3..0fb3c7fd8a27 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -323,6 +323,9 @@ int pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				const struct pnfs_layout_range *recall_range,
 				u32 seq, bool cancel_io,
 				const struct nfs4_deviceid *devid);
+bool pnfs_invalid_layout_busy(struct pnfs_layout_hdr *lo,
+			      const struct pnfs_layout_range *recall_range,
+			      u32 seq, bool cancel_io);
 int pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 		struct list_head *lseg_list);
 bool pnfs_roc(struct inode *ino, struct nfs4_layoutreturn_args *args,
-- 
2.53.0

