Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.216.98
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795136697;
	b=wQOC5Ltur0kqKerWRlhrWFRBaJ0c2org1Pi8OsNLpZXI6AEvKb/N7xfeN7glW6LK83nU
	 c0dyJLCbbR8MvkhSu1MaQ5Z4IGSraDwrj22DYsx1PreiVoQC42m5wQT8rxXMeKNMcI1qt
	 Ddn/PoLmtuIwbzJ1LQ1L7LJyNCSDA4EyrijoqdjsysogQWSXhj+5HgoCS4G6SMIsDKlZq
	 2ojUCE1lRhoNkOdd3pQeuSJ9Qx11zwTM70gCaTB0B9jRBj94lIjC8pRteQXAH21IaB2N0
	 5E8at0SoHorS0om3D8GsD7U6NYATanemELc8tq5Lv5xtcaSiBYEOUey7HSpMV/UGAsQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795136697;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=14zjSChbGtPtuIEC/eCtCmUR3/Z1H0ubiZMVkNUw7Yg=;
	b=FW/VKbbPbSb6aLnOKw8K7PNIST3m3Qbren0STrnkDb+74VOiBT18FrwHcmoIVFSFCT/Y
	 djREqMJM5P01623LC4JDB67xA/fkIuJBR/XA1ODW+sBXN8Pi7yeT7KBFB6gxinw94x139
	 Ikq6UGAxZg4gh1caaqWv1xf9Ql6lsjFHTM4KgNHcjdEzOMMlBpHCdA7J/iI/05RavtQGO
	 xlYtH6CAFta+YOTWE0ahKy7Frm1WNK5s8C1f6BIoMqypaW4I34pmfHEnOu7WFeOe8Iqsq
	 ZAtuzxB56NjdLeMBH1dt/hhP1Qd0DPq9OLhh3lDeV5SH/WQDdqWC3bmu0QYyZVZlr3g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=i1o4eelO;
	arc=none smtp.remote-ip=209.85.216.98
Received: from mail-pj1-f98.google.com (mail-pj1-f98.google.com [209.85.216.98])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EB92C606A325
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 01:04:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EB92C606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=i1o4eelO
Received: by mail-pj1-f98.google.com with SMTP id 98e67ed59e1d1-3ae1da332bcso211051a91.2
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 17:04:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1795136696; x=1795741496; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=14zjSChbGtPtuIEC/eCtCmUR3/Z1H0ubiZMVkNUw7Yg=;
        b=i1o4eelOcxxhAremUNpz1jVTTkbHb9fjYyAAI1GwOBG80DImiTshgnqTEGaWDDvPju
         KVcRJf2HM16eIKYbsplf4q/pLBqBzwIPc406R8rsw3kAaDn/CCtvU3o7ymbdVvBfQ9UE
         UsjqIvYPJARjRdN6mR9S8kkw9kmNNUBbiz2DxhVeBAzOj4t/tSRuaP2k4S1Q/phBRzin
         s2vrTvlriAymj5jAuAUARck6dKaC8KMKVLJp+RpFa1X4IOLTY+2YcdpaZmhtWsBULYSq
         qZBDzvqFk9mJ3jKkBAlxqC5+8+DvaqPSOM0Z6sARqyVJhRL1FH6CNwxZjYN0Bmm9Ubxe
         R99g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795136696; x=1795741496;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=14zjSChbGtPtuIEC/eCtCmUR3/Z1H0ubiZMVkNUw7Yg=;
        b=sPuBs6O4q4JHkGXQI2L67R9WMmFPiWwhdgxUunG9utL1hbTQiSzIhtGrDeCwXIJLMR
         7nMpCgIutYzkI+cfaQY6Wj8lxlfxsFNPNvR1ICSJeuoeE/8JiqBAIc8WCUwAQpTpH2H9
         qD+9zYyQ9R3dT6XTVAXl76LcqaQ6eYmXTAaVdMG5F822t9WfVlI9HwQOfwA20JP9+ISg
         C0QFW7yoysun/BlS5DjxtKUGhGEFq/+nZogU7C/y9qIzFNZL1oKKsMQlPRvPXfgiNwwy
         aX046OB3rtq4c35Q3UvDJpfkfzUbBZdWlu1/jxpGuYwQI/4/7gpncVLexOIExUn6f9Oq
         6zNw==
X-Forwarded-Encrypted: i=1; AL+hErGyjQMCkDtryZKyZz8RoZYfS0PqxlXjOGgIKHDLMWcuhS4tVEBLwg4vp6MEL2g7nQxHzmqtmW/gzoc=@vger.kernel.org
X-Gm-Message-State: APuU4Z/OxYRswQ1vUIni5YnQoFwPn5uXrKGU1bxBPHcXTaa77HAtZ/MP
	Ipvr3Nymsk7R+T0VIuRbIXGIY0npR9ipEV2xfmO5YGrNg887C8KW/Kb2gMWzVN9EnkOJrqYgYMT
	RTJYU/F09XTC4FV62CFOdKoZSRPSlM8IxlktX
X-Gm-Gg: AZFdTZdEGV/jCjhpehCXkRx8Gji+exv4CL42xnK8dcVJhWmWMd+TItDTqkamJd86Opk
	SjVpZO07oP5ShFnnIRTDkjSGdHMafpxZos5DTX9sVI1RqoV56QQ4rCSTjLuVaoz6V1MLHnNv7OB
	vY/JVlHqEtHl2jFx0YQ3k3beXGE2BKLDjyP44SPEjspHRNOZRiNpLivanWmiR/gJl3OMiELxy2S
	RGf7T/ABjlDKLv6+AYHdLQ+KgNsG1QQVW9lMsleZkikfcYFHbl0tDgNIf/Qxmw59YIBG/OfDQkm
	B7cLLjAnVDuQSztP01IunWYnSpryeH9dNQ8n5q1DN/cFcD/rqK/aji99/d0VBb5cuwB+6AUQBFI
	v3vPVQEtfiw1Rn5e1p8n89Ym79Iia2MMRBbk6K3c=
X-Received: by 2002:a17:90b:4ec4:b0:3b3:bf8f:9ccb with SMTP id 98e67ed59e1d1-3b41c8ffa94mr1008239a91.18.1795136696119;
        Thu, 19 Nov 2026 17:04:56 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 98e67ed59e1d1-3b41ae59fa2sm822937a91.8.2026.11.19.17.04.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 17:04:56 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id E95133400BB;
	Thu, 19 Nov 2026 17:04:54 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jon Curley <jcurley@everpuredata.com>,
	Eric Badger <ebadger@everpuredata.com>,
	Shiva Lingappa <slingappa@everpuredata.com>,
	stable@vger.kernel.org
Subject: [PATCH] NFSv4/pNFS: Don't cancel I/O when re-checking a deferred layoutreturn
Date: Fri, 20 Nov 2026 01:04:54 +0000
Message-ID: <20261120010454.2153387-1-tmenninger@everpuredata.com>
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

pnfs_layout_need_return() runs whenever a reference to a layout header
is put while a return is pending. It marks the segments covered by the
pending return and, if none of them is still in use, lets the caller
send the LAYOUTRETURN; otherwise the return stays deferred until they
drain.

Since commit b739a5bd9d9f ("NFSv4/flexfiles: Cancel I/O if the layout
is recalled or revoked"), this re-check also requests cancellation of
I/O on matching segments still in use. Changed-layout recalls,
error-driven returns, and file bulk returns already request cancellation
when initiating the return.

As segments drain, the pending return's sequence cutoff can advance,
so a later re-check can also cover newly acquired segments. Cancelling
their I/O can perpetuate a cancellation and retry cycle.

Disable cancellation in the deferred re-check, while retaining segment
invalidation and waiting for outstanding references to drain. Explicit
cancellation by the initiating paths is unchanged.

This was observed on 7.4-rc3 on a one-client one-DS system under
sustained direct-read I/O over pNFS/RDMA after restarting the nfs
service on the DS, with "NFS/flexfiles: Don't treat a locally aborted
read as a DS failure" applied. Once LAYOUTRETURNs were being sent again,
the re-check kept cancelling the reads of freshly obtained segments, at
about ten transport reconnects per second. With this change, once the DS
was back no reads were cancelled and no transports were reconnected.

Fixes: b739a5bd9d9f ("NFSv4/flexfiles: Cancel I/O if the layout is recalled or revoked")
Cc: stable@vger.kernel.org
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
 fs/nfs/pnfs.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 14f4a4b12ffd3..a60df3bdab921 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -480,15 +480,16 @@ pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 
 static int pnfs_mark_layout_stateid_return(struct pnfs_layout_hdr *lo,
 					   struct list_head *lseg_list,
-					   enum pnfs_iomode iomode, u32 seq)
+					   enum pnfs_iomode iomode, u32 seq,
+					   bool cancel_io)
 {
 	struct pnfs_layout_range range = {
 		.iomode = iomode,
 		.length = NFS4_MAX_UINT64,
 	};
 
-	return pnfs_mark_matching_lsegs_return(lo, lseg_list, &range, seq, true,
-					       NULL);
+	return pnfs_mark_matching_lsegs_return(lo, lseg_list, &range, seq,
+					       cancel_io, NULL);
 }
 
 static int
@@ -903,7 +904,7 @@ pnfs_layout_free_bulk_destroy_list(struct list_head *layout_list,
 		list_del_init(&lo->plh_bulk_destroy);
 		if (mode == PNFS_LAYOUT_FILE_BULK_RETURN) {
 			pnfs_mark_layout_stateid_return(lo, &lseg_list,
-							IOMODE_ANY, 0);
+							IOMODE_ANY, 0, true);
 		} else if (pnfs_mark_layout_stateid_invalid(lo, &lseg_list)) {
 			if (mode == PNFS_LAYOUT_BULK_RETURN)
 				set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
@@ -1405,7 +1406,8 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo)
 		return false;
 	return pnfs_mark_layout_stateid_return(lo, &lo->plh_return_segs,
 					       lo->plh_return_iomode,
-					       lo->plh_return_seq) != -EBUSY;
+					       lo->plh_return_seq,
+					       false) != -EBUSY;
 }
 
 static void pnfs_layoutreturn_before_put_layout_hdr(struct pnfs_layout_hdr *lo)

base-commit: aebb7274476403040d582c61478df8f4a7bf9cd3
-- 
2.53.0

