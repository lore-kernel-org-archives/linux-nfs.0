Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793299324;
	b=HGunSK5K+I/2XABI9YzdF6+NP5Izk5WN+KwLe4/41wrH8uMInpkqSxt81Dgpcu813Pqw
	 nvgXuVn6p91scqKs7mbUmNpNKJgYgG9itPC4UlM+leKuvwvTmMiBV//SSMwzGidDvCO0Q
	 LjHuJ6u7lvz31bWPf6uyXVbBsnL9lcmOvpvqx0miNPulGlPfRiN0lkBiVgqdN9U+5sGro
	 GraCd+CxoUpnGmFEMbyJF9c8JkkBcI4iDKrKsPfDS9DSlaaILIZ2Hdzka1kS47xUSHNi1
	 LL5nm8DbJS9e9Xv2zDy7Kjkk7wvwHXi4+pr2jFr+rHtNpovq9r+5rFx0ASNogwTk1Yw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793299324;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=mdGa58wfN8R4J8BP+JiDtaM45+E9sGvpc8y31CpGWY8=;
	b=ptp/MzsQ6JbW45X+NeOGKHDddrMuaunT2O7Sz+9LZ+iVKWzBeQfIx3eQWVunxUnQGqDd
	 cuUN6gxkutRiNNyvSgabXvN8DKB31ztMc0MH9pLf42gneudyVo4CuaUQRvf/ukyowzcOC
	 rs518L07TWXfkeL+Zk8O+EPpIdCivtWvy9lJqjkzofrdBLAc8BNHJGfoKZH46JfLhNOx3
	 W7igRYuEeGtg+RfXox+Q1dxEp+nynwyWC2m5hJOYFNYJ0EV20Y1Wj2Ih7QZrZVUQHjvTD
	 OwuS3TF8bEL+a7PmheBTnakVXygo6X5ZxepcSA4vgbe0ndPH1NcqzciVq6SfYeCio/g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=MqdLIrkw;
	arc=none smtp.remote-ip=209.85.210.53
Received: from mail-ot1-f53.google.com (mail-ot1-f53.google.com [209.85.210.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64657606A31E
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:42:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 64657606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=MqdLIrkw
Received: by mail-ot1-f53.google.com with SMTP id 46e09a7af769-843b6f8e2c7so2769087a34.1
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:42:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793299323; x=1793904123; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=mdGa58wfN8R4J8BP+JiDtaM45+E9sGvpc8y31CpGWY8=;
        b=MqdLIrkw8Z5KpnfpHaLyEtw54GK4zYcuu7wM9aPBzS6+bx96YxMoMRcYjiHZIaKewc
         l5o1djSrJwS+Wl/ln7hY6hIQ0r4RQO5GocdhU9J74MC2sRscZEt+nsUgnv6j+sj83vcl
         E/79voPRv3MY2hJpMXL3MvqrvhISxB1WrokB7OqybWUyOApicdvAZHnRbuUgN5OgSaWb
         a2bKgeCpJIY7QDcqNrUAguJcDbqkE1KdPkyahjLmmCnYt1tnaz/+mueb6KWIgMdvZbfF
         hGokLr3iG8u3/yAHDPSwTPdvAXx7N0BdZidQZxLtJGWycX2w3k7DOePNjoWdTJmhHTMC
         KdcQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793299323; x=1793904123;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=mdGa58wfN8R4J8BP+JiDtaM45+E9sGvpc8y31CpGWY8=;
        b=lXM0uyf2aqYWcTDq8J+Et7ouZjQN0xnKDsVbzCgVqB1t386+mV4tKFsgbgJP2Zlecz
         YoNN6XYraFrSiECu55kOUOUTLghbo02nQ053mK8D/l7tFFiLB9UPeajcD+aod5icjgzZ
         5nhJLU+ygGUAq/pDzeLg73GjtR8kHnxDUnB/eG+JPJOP8iOdG/tkViGD2Jr+cW9sFgic
         FyTTb7PmncZaWdIwmoVbZ5Ts9YOJk1P8YhDpwxajyp81tKSbQlXrP2Ps7aFyzwJWpR5q
         2nAzTgqgIU4b/qSRm2FWfMsbvkfHiUQbD1a5Wpr3oDokoM2IvETd2DHYQDEOd7/Jf8vp
         rhRQ==
X-Gm-Message-State: AFq9FYIH8c5GF41MM4ROQJR5ranlymgFTyY9XJxgva7sXKxRkV1l8BYw
	zPaof5MOEH3DCcPFAgTxR1Ml3UCgnBvShaT4cB8WeoHCBBN8TBfKDMty9KxLnF+gdIU=
X-Gm-Gg: AYBFou1zOrFoNdWRYBJfiU4diF5b/L2Xt7GtvhioOPzMzbQJtJi4HXHSI0gVFs/k5RR
	KQXC8uhd1WI9f5iWW/h0fneGWYAB2d9rW1dfjJqNu0gRzi59X1fDevvdcx609/mRrIFtpYkoks3
	7z4/fsl+ZKvUEcRvQS7K+oaTdKM3i37TlFwcZ3ic86HIvjKx7kMMyS+HaLdMCsb7/lk5F9zxuM5
	jmiGsbvarjibNFmqeoA4AGGGf/LwNSgyBDlXYNkuNiWnKDClcZ0sqYluiPXjEeZh+yotm8t+1Z/
	zD27UhW+0UZIR/OT2qsAXYNleOcUA7p6W6x5qeP+IkwtUxVqHnFzr8qyaAub1W/1BdHyxqdYR4h
	w38HNRAN1BLCXycHc7KwALF4mB9dfGpFe6AwfE5AmytMQMEB14ovoO99sHo8U5KY9ilX9a12h0O
	xXrSrFw1cTumUeDJMrAwiGF0OEO7vanCP2lGZTcFkhh7V4a6ZsYyJ8FC06awk16VrW0xyuf+2jJ
	hAzjm7bvsDrtdan+DHoJSWqWCFV29xObLHlWwvTq3B+8nEDCHb43oO7XSrK51JveuJ69i4ZgMPL
	hNhtinYC/UJHDbjI2/HgMcImlXkqvf7x/0MgAQS+Bu09R5WvLvUBQW2/gZRN2Mfct9nxQXU+7mU
	v
X-Received: by 2002:a05:6808:1512:b0:539:ad19:d0af with SMTP id 5614622812f47-5640dc1e093mr74909b6e.11.1793299323037;
        Thu, 29 Oct 2026 11:42:03 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640e23b76asm7161b6e.11.2026.10.29.11.42.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:42:02 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] pNFS: answer a file recall with NFS4ERR_DELAY while I/O drains
Date: Thu, 29 Oct 2026 14:41:53 -0400
Message-ID: <9eb93ea5d96e1e67ca2d4a003cad670066fa9228.1793298149.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793298149.git.bcodding@hammerspace.com>
References: <cover.1793298149.git.bcodding@hammerspace.com>
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
index 70b3429726c9..27322b6f0d0a 100644
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

