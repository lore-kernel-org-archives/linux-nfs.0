Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.176
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793374233;
	b=M1zYG4iopyQgAEgnTtVPHrU/NFE+WfI7LYQwTTTXC34Uhm60eS4WFVLRUhncGBr8Rrla
	 +orexgd0ZgedUrQyRzyS1zOiq1FbsBX4JFVqUDhar17Q7VIiRRoWXoBaKQ8CRLmoworEN
	 ZtE6h8/6WTjm5p+iRtxkTyIIWLMZCu13RtDFi2JwMr4DNeqS9aCQIQkF8mubpAdLL2rNZ
	 ho5aClAXx2LN98zfn4Ym22aFGyDnOj88aW9ETvUiZBAwhKcZg1tZ8XQhEqVdDk6OjBIbX
	 UhYa8iPZ5JAGzymoekaQy63gE9S4LzfI1Qv1UNSUWPl/6rK107aSANq1Rq/GhSw/IMA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793374233;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=+xD3C2qUGNOzpcvkzpYTpNzYe/BylYYXW6VOdOvVpr0=;
	b=WgFTzcWylVMGeBgU6eGCwSwm4hK+jK9mQL1wTnlLO5ZqCXVqV5UsMDt+Rss1H6mt1/p6
	 aolTsLcGSdgolXQW+TL2djDR0mQT5TWT8hqhpzBUwE4lQmIUIBGU/aP5pbyykVPMtfBxD
	 n4ZPcDU8bxf5NuBBmi/mwTIATwJG0ogQuTBkvmQ2I2Hc0EGd4YNW4DEKZS31h+Fyq6SoD
	 UX+ajVqzCVE2JoNgv0pHfsJKZmQ0sGw6QlZmYFWt+Le8T98+M+BR9fh8SdyYignwJdWuh
	 Q6wPYfdrlZFjU8n/oEEY53uDpID+gdW83E0DQHpYqb3X+BkH1QXVjNGSHyJhISOCGFg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ht2Su+6Q;
	arc=none smtp.remote-ip=209.85.167.176
Received: from mail-oi1-f176.google.com (mail-oi1-f176.google.com [209.85.167.176])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D317D606A32D
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 15:30:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D317D606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ht2Su+6Q
Received: by mail-oi1-f176.google.com with SMTP id 5614622812f47-55e0090c580so303824b6e.3
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 08:30:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793374232; x=1793979032; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=+xD3C2qUGNOzpcvkzpYTpNzYe/BylYYXW6VOdOvVpr0=;
        b=ht2Su+6QptR9x+Br2PQbCLUBOdMHq3Gcdp1BVNN++TzPLsPv4Exzvdk0YU+Kyc4ki2
         pWALj4QFmPuwzm9VwVzm42I0E7ZMjcpDguhRg0snHoGwrLI2UW7U4J3ZP6Af7505dmT3
         d3a2vcYC/kVy9FcKUMWhb/bF2OYwxnReJTSdYOQW9RuzxhgDJPvFfSIuQfh43EsLvFNf
         IVinzVTNaYK9Hyamhyic98fEWzGCMNSNySPoWoxPA9iwLp7vzU/z751PjwiF0dO+jPak
         MYooaKytZsh3GG2pwUeWfu4U0RuIoGPWWnqdJ3QI/3LwhTRyHbiiySnTuQMN4KvicRgy
         Wogw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793374232; x=1793979032;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=+xD3C2qUGNOzpcvkzpYTpNzYe/BylYYXW6VOdOvVpr0=;
        b=W+3pGhfNOJqS7gDBGXeVhyNie1ne8al0AaV+lbvAiWHd/0X1X76QrBfhmnhDQizIxP
         iNOESg7m5Nwq5og21TLq3dQzSBCK/ukIB7ut2SEDTIhw6A8ACZtuyBSOiElXf+oADUiK
         MTQ7pMNajaaFYBqJbU2h5Cf7C+ONQaRDlZL89Dlh70lCQg2lk2HGxpQdykTJqSlbuBbw
         1Hqf2d9RHXO5Kd1EArBasfa3O6hiQPyYauT6VT5yDU+YXhIEq1FuuMrimdg8XZtKGJkf
         sqWE4bfnw4cUrG8VwrsK52jZRxjzyLmkY3voJUwgB/lHwZCUf8Yu0IR4SMTrMkud08cQ
         8gAQ==
X-Gm-Message-State: AFq9FYJHfZx5Ddam0RADzOVVBbNSvO+t8P7A4ntR4XdNQ+sRSg0NYa+r
	s/UijJ5LjRwxrfvrvQNK/m2tEFWch4k+XDCTzLp/WE3ptDzu0FEUXXhWhOmP0PSCj1A=
X-Gm-Gg: AYBFou2fjGnj4AQvnTU/ZndwZGWZJYH2JWgJUKeFL8POFpsJceaISVi2DRzf7YiSnNf
	OXk71ZcrhJjSftYqRwCthivnWnGzEg8fB/0kXQpHCpRXhIO6T/25366KKocA6GZydVK8/pP+Nzd
	KMvZ7VEDhJtaAYfBbppHnCiiwtARsPgEXdrKV0/0qcOaeKD49gp0/z9/KfjH3VV8spUaHAjOQXr
	e/mJpMh/ooZgD4ORxxpdY4chv8qxy7udMdZHBnhDeWbPtCr+4qQrY7vczqf75tSzTXHyQj1gbM7
	kQBQ6p201We6riRuDtoPNSzr0qSD+k/i8gJPD6f2viR9MeJLmKZbK1WqTXHgK527cIQ5aeZ88qZ
	SD22tiO/jfpb18osTO+zkwHgx4WjacAR+1IxUqF8PkhZKS8MM7SklmkDCw4w/PzM0/IL0tZivOw
	gsPhkBf5TDOoLYzTXqa6QdqNrtkE/a82prtmE3cafsv0HR88VPAFGGfzwmDkXabWHrr5MD444pk
	5lI2FjkjUS/EFOH2lB0cb2anIutoPfCRmHz0cVP3dUj1hgvX32bhGWk5ae5fofbFiTMNlbA46Dg
	KBYYqmIMpJhPB5gXl2/7ta4z5pSo2oRw06kCRaGDG55dbND9hkcaZvHkFvJxjTsPS8NQLzqcwxa
	8ex+jEzU+df0N1hJilZBRQRUU96SKocg=
X-Received: by 2002:a05:6808:1691:b0:4f0:1f76:8ca0 with SMTP id 5614622812f47-5640de71f92mr1880083b6e.56.1793374231569;
        Fri, 30 Oct 2026 08:30:31 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com (219.sub-174-201-19.myvzw.com. [174.201.19.219])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fe0fda0sm1840376b6e.13.2026.10.30.08.30.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Oct 2026 08:30:30 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/6] pNFS: answer a file recall with NFS4ERR_DELAY while I/O drains
Date: Fri, 30 Oct 2026 11:30:21 -0400
Message-ID: <4b7f08366e3ae2b89f01527e3a63e89cf7202e22.1793373378.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793373378.git.bcodding@hammerspace.com>
References: <cover.1793373378.git.bcodding@hammerspace.com>
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
index a23bcb8503be..b0bdd40de4dd 100644
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

