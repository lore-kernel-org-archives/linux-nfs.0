Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.215.225
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795136820;
	b=new6rquAEzTvB97Rk7wl5SgVGpfXzyRGXKxN43+3CiL4o5E0Jh9EnxJpdkMTO8CUq6tV
	 shFYOZgi/+wDggdKtzxMorMawQVUtYBICMy83wIGbebkBwv0uJ8ksmZ5M8C18/63FHLmZ
	 6x02280fbUq3XlxshBetyz1tE7ghPFJW6A1ZnJuBv10CrYbBYiB04PJcvuzizqblDtc/2
	 wfabCQAgDbaGgaCTBBbHNkLm/tAX117EfD6fBzIIkXczVaRqzZEvFGKYu2JNU+Xd5Gsad
	 6fsIP9TxgZInk+tQ82pOi/iPGIAWMpEa3eJFzt/GoB/MJ5fIKKjFTB41niCuqHEQsSg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795136820;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=azpbeeR0UmmXKlAwsDU3rTomTiwLhVswnIguSA8HmN4=;
	b=rbCtA+Y7jh9JBtq3zftbtPGe4USfmAnhcpE8sQVoUabmouNTrbVVbw2gipoWLoIF6+9k
	 cphi+kAY/pinwqZB43C0m+Frobtsa0mTdcs8GyHUdJLFFxikNR5R6hrDxSvoahJ9Bs+To
	 p85DR6AJha2gefqulEhYFY8BPeWltNLMNTbuMmGZSo75u7ZLfbYZkgmHn+tsP26eaPq8+
	 jYZ18B3G+duSTQO4Zpmsmv/07EmBK3AZ2ARzs+ontFIR0lPGZjLPVk91min6pDPz2ZSYf
	 8OGGOyzgwJBHVLHpGdrtyRKHlhIqH8E0uwsztci7nyD8hGL6PRKF57nTay6gtP99mdA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=sNHCMxoK;
	arc=none smtp.remote-ip=209.85.215.225
Received: from mail-pg1-f225.google.com (mail-pg1-f225.google.com [209.85.215.225])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43737606A320
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 01:07:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 43737606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=sNHCMxoK
Received: by mail-pg1-f225.google.com with SMTP id 41be03b00d2f7-cdb9f760337so855133a12.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 17:07:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1795136819; x=1795741619; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=azpbeeR0UmmXKlAwsDU3rTomTiwLhVswnIguSA8HmN4=;
        b=sNHCMxoKSWnMHqi2heurqFOoJmbYTUZ1ydPiN/uY6pu66Ialos12XUTZNoCNtwVkXq
         JuZqkFQovQyKNnqtxI6NqsCbkXV29sURHtqFrJpwh6I340bRFH3YlLbSDOwLaSXaZGIi
         Hug0FY0uPk9Q3ZuXh5MDVtcLu1BdTi78gRSTl8ulOewYo0mj+ja9m1EUFV9WsEleVbbG
         1f1z0VcRmou3jfj5k39rfexokdBaFu9AmKBhesyPjJ6x/xoX/aVcpeiq5TXxFUwAAHFy
         B4Yyc3hU5ALZ8tID/p65P/uPpYIYVYD4b0ORWNDdL8I3HWNtp8IfR10LuqpX2tmk81BB
         UfPA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795136819; x=1795741619;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=azpbeeR0UmmXKlAwsDU3rTomTiwLhVswnIguSA8HmN4=;
        b=t6gRsYOqQgUHJB/71cFzruOeniPTsG8avKDsW+igkWsPYTkEVjYoZlo6b2WzXg3gDG
         AyQpJD1vb+1Poou98U9gohIlq7X0hjgjUwE9C2nSPHVjcGwrkVg29Vh7KCoWMYsvWYL4
         ty4AzkbF1aPXhAqbEAKvevE8ELPRwSecZq9JAkLMiNwR5j+AoE4TTS+/EHPhJ/0kvxrs
         VEFumrkzcKLFrUL6lUIbHhROQvWR+1+R+WGLz9s2jMmIhabpQ5mqRcDKm0QK4wSfk0RX
         MERHnOBcD8eb+2Q+mcXr+Y3LnFKjvj96xn7cpaypkKCQc1m8FtZdOcHe5XxjEzQ2dXHQ
         49Pg==
X-Forwarded-Encrypted: i=1; AL+hErEkKOM+9YZdaWmFPmkZTZvIjplsvI7FJfJmt2Z09FkfBh9ZedlgkgDLS70XzXBkPq9b8EWH+LscUEk=@vger.kernel.org
X-Gm-Message-State: APuU4Z/LDaY2F/FWzf0ilyeKC3kz35FL7YwFwQQUSamuF3U9LO0HBWKe
	S+HM3KLEBteNand53LF2+Tq/59gdF0RtAH7ApPtMM8sqU74hj+veJVcyNuNJdSQz6aFia2VeTrO
	6RGjQxkmuj3zF0cNBQxcUeme7N2VbanCOxQ7a
X-Gm-Gg: AZFdTZdl+SJMvkMaylkg+8Yp6njM5go6M7hoVF2UTo10eKrsqnK1Jwv9zivcc04mDER
	icJLrz1sCxaxtH/hzDSWuVKjg5MN9VwTvo1OZd3wSv+rWfBvA9SCCx4YAwhMO0jLT0wYHdCb5UC
	EeLv7Tphxi+1gUHYOz7t3XXJvwHsj6P3GOi2d1BD0lNYIV95ZVP2mY1504gwqic4jmOTRG4s+ei
	/MMnIVCUGZhraLZm26qWEWrWZQ8c3LYrik+ad2IFFgBAbjhBus5IoYzXam6u/TvYTH87NQqQcGa
	a7mdwWdhGycJZ12ikUOU+6tw4EeQPIaXz+7GeB/eLeolAKeB8eLZbG1QhjNkNey+QQNWeILh2ew
	Wl5e4z9PKsLE0awyB4XN9X4qUe6at9LhcgLdmccE=
X-Received: by 2002:a17:90b:5546:b0:3b0:a1c6:95ae with SMTP id 98e67ed59e1d1-3b41c941f9amr621799a91.31.1795136819434;
        Thu, 19 Nov 2026 17:06:59 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 98e67ed59e1d1-3b41cfc5245sm238009a91.0.2026.11.19.17.06.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 17:06:59 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id C9314340382;
	Thu, 19 Nov 2026 17:06:24 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Benjamin Coddington <bcodding@hammerspace.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
	Jon Curley <jcurley@everpuredata.com>,
	Eric Badger <ebadger@everpuredata.com>,
	Shiva Lingappa <slingappa@everpuredata.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: [PATCH] NFS/flexfiles: Don't treat a locally aborted read as a DS failure
Date: Fri, 20 Nov 2026 01:06:24 +0000
Message-ID: <20261120010624.2154348-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
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

When a flexfiles read asks for a pNFS resend, ff_layout_resend_pnfs_read()
treats the failure as a DS problem. It moves to the next mirror and sends
LAYOUTERROR, or, if no other mirror is usable, marks the layout for
return.

That is the wrong response when the client aborted the read itself.
Relevant cases which don't establish a new DS failure, and therefore no
longer drive another layout return:

    ECANCELED
        pnfs_lseg_cancel_io() cancelled the I/O because its layout
        segment was being returned or invalidated.

    EAGAIN with the current RPC attempt unsent and hdr->lseg invalid
        ff_layout_read_prepare_common() found the segment already
        invalidated and exited the task before transmission.

This was observed on 7.4-rc3 on a one-client one-DS system under
sustained direct-read I/O over pNFS/RDMA after restarting the nfs
service on the DS. Marking the layout for return cancels the reads of
the segments obtained in the meantime, which then fail the same way. The
client marked the layout for return from this path about 8,000 times a
second and reconnected transports about 300 times a second. With this
change, the layout was no longer marked for return from this path and
transports reconnected about 10 times a second.

Detect these local aborts before attempting DS failover and resend
through pNFS using the current mirror index as the starting point.
Skip the explicit LAYOUTERROR and layout-return requests in this
resend handler, leaving existing error recording unchanged.

Fixes: b739a5bd9d9f ("NFSv4/flexfiles: Cancel I/O if the layout is recalled or revoked")
Cc: stable@vger.kernel.org
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 5c289737366f2..31f17d79b270a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1313,6 +1313,16 @@ static void ff_layout_reset_write(struct nfs_pgio_header *hdr, bool retry_pnfs)
 	}
 }
 
+static bool ff_layout_read_aborted_locally(const struct nfs_pgio_header *hdr)
+{
+	const struct rpc_task *task = &hdr->task;
+
+	return task->tk_status == -ECANCELED ||
+	       (task->tk_status == -EAGAIN &&
+		!RPC_WAS_SENT(task) &&
+		!pnfs_is_valid_lseg(hdr->lseg));
+}
+
 static void ff_layout_resend_pnfs_read(struct nfs_pgio_header *hdr)
 {
 	u32 idx = hdr->pgio_mirror_idx + 1;
@@ -1320,6 +1330,15 @@ static void ff_layout_resend_pnfs_read(struct nfs_pgio_header *hdr)
 	u32 dss_id = 0;
 	struct nfs4_ff_layout_ds *mirror_ds;
 
+	/*
+	 * A local abort is no evidence against the DS, so skip DS failover
+	 * and don't request another layout return.
+	 */
+	if (ff_layout_read_aborted_locally(hdr)) {
+		pnfs_read_resend_pnfs(hdr, hdr->pgio_mirror_idx);
+		return;
+	}
+
 	mirror_ds = ff_layout_choose_any_ds_for_read(hdr->lseg, idx, &new_idx,
 						     hdr->args.offset, &dss_id);
 	if (IS_ERR(mirror_ds)) {

base-commit: aebb7274476403040d582c61478df8f4a7bf9cd3
-- 
2.53.0

