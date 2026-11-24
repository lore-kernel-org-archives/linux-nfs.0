Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.70
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795543571;
	b=PGiHg22Mx2jOgP6qUPMTC4eHv+vpuduHVL5rluMPliHJ81DGhLIkiRWoj2xzj3m5cLZ1
	 APeyG9tpdn38BLAzlj8IkelWWL0Z9PMsM8EVU+1sITj5VAxE+E6Hx7ddQxmhBhSaCvn11
	 oJVM1dofJVam8AywmY7d7fZKznCgf48cLVDPpSCQbP6I98BEzbT06X4bJIyZhyRE6IZvZ
	 QnWmvNuZEzMe2KvVJdMBeca4fwz+zGN0xW6VfoCYck+39b5yK+9JpGwqB3q0Me8+erS5t
	 nxeEQ15f9NxMPHzGhqxo8OnhDj8OuEfqoGks5Q73LLcJ8mEnc3bN2EU9j4LpSWSoZwA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795543571;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=TTobbA6drSDZJWqbMt7F5A3mt5qZ/w+2ak4GVWngoJU=;
	b=TcVUsg9+9DFh7NX0CI7HFFa6Gobwo1aKaX5jN7gYApOg3IunVpn65FSfnNgmBBl+fJT8
	 vR5lBXoPX7I76d8OYYJir96dktlMBbBmjX25PqPfugcBuC5K7RBHJ5TWMo8WFuH4B+9DX
	 FuD6Wxa8JPHPIFEjkC27gXhOHw4cHKej+aMdrxgjZIXKVdLIMoqaYQoVPT6AxCQ/ROntS
	 H+r8WYseAMgE1vowmyKJEfoHP2fIXx9/YT9TCRUGFILczM9iu9EabSPPvIXNaAHxGdUOv
	 ngiv/OmQc/JNHyn6DCweM14lNuq8aPL+szhXC1sIjnUnHsWwAc8eJmxaBrcmB/4Jxng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=T8i36nVl;
	arc=none smtp.remote-ip=209.85.221.70
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6D7E606A68C
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 18:06:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A6D7E606A68C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=T8i36nVl
Received: by mail-wr1-f70.google.com with SMTP id ffacd0b85a97d-4a799d93bc3so2327534f8f.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 10:06:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795543569; x=1796148369; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=TTobbA6drSDZJWqbMt7F5A3mt5qZ/w+2ak4GVWngoJU=;
        b=T8i36nVl5IlmUDS277UW/wELWLM4zJuzGpb5XnB8k1V1TTYH8LXgY7jUWOaJTyllKB
         rE0eb7Aka8293LkouhlEFL6vmNZmCcEduCvHTspBpewnMGqUS1GX8DHDDfvOb8lSXywM
         /w3YWqF8DfIlTczmFxwIP/yKXPJIUCLLeVTN6snyivLaZ26kTtY/+ozrmIYUkW3P0ChJ
         lXn8A/Oc6h0kuHiVFwbtG0N1mUDPM+jfWKrIDYotL9E6HMAEAY0rZSfEd7E4LpDkmX3S
         cT754hL2n2XE7RR27IToMai7zoH9JRVXC3xTvGt/uJZUA21w0AZm8gsCNtIak8JlDiMc
         c7Lw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795543569; x=1796148369;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=TTobbA6drSDZJWqbMt7F5A3mt5qZ/w+2ak4GVWngoJU=;
        b=syWoibrG/2QYYF03ouAB5jRnNpUAhCjc6O7g2xVWzwsiVtaFKpAVeJdvDzUCOI4QfT
         AmCM0Pb+KhNU6jh3LZRtQQpg3JzjTUKLd/t9NXzJlYdvR4rku1MfeXVilYmp0mAKn0oa
         HoHgs9VaFHFrax4e7ct9FGBVkKmOD6Hly3So2W4iBwg4PCV46Dwx0Hu/UBH8ZVpfMxGN
         ZXy2TNSH4VbQFIVHkeIkERtejmIbX1ICZ+H4ZaB4BiKRh54bCzb4ARfGurlFG7/pNmrM
         I0EdJ9atEMkdcG5Nxr6tqnsKogRoRusYHGx1VT8DugnumX/jXhup6gF+hFxtNFoiYX+B
         ujgA==
X-Forwarded-Encrypted: i=1; AL+hErHJ0tAZAV4GpfiFFDBAUTAUg15sbp+Iu4TV8adH+x1luYKh56hBNhIi5nSSQXYeKC87JbsqOJHdNK8=@vger.kernel.org
X-Gm-Message-State: APuU4Z+ya6j4iPZowAUpBD23BIMemZ7g5SZ5KFGE4hOIYoIwU0LNlSXo
	68bqlpIOoFuGlCW2dCobu2Tf9lVb+LEAjcOFeZCXqRMfqI1bZX8TNuNUPnOzswtQth38GmDDVQ=
	=
X-Received: from wrwk12.prod.google.com ([2002:a5d:66cc:0:b0:4a2:fc3c:6409])
 (user=dmnk job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6000:2383:b0:4a8:8004:5261
 with SMTP id ffacd0b85a97d-4abb6d04250mr34532821f8f.44.1795543568707; Tue, 24
 Nov 2026 10:06:08 -0800 (PST)
Date: Tue, 24 Nov 2026 18:06:05 +0000
In-Reply-To: <20261124180606.73719-1-dmnk@google.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
References: <20261124180606.73719-1-dmnk@google.com>
X-Mailer: git-send-email 2.56.1.663.g77904e546d
Message-ID: <20261124180606.73719-2-dmnk@google.com>
Subject: [PATCH v2 1/2] nfsd: return GDD4_UNAVAIL when nfsd_file_acquire_dir() fails
From: Dominik Maier <dmnk@google.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
	Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, dmnk+artist@google.com
Content-Type: text/plain; charset="UTF-8"

The Linux NFS client requests a directory delegation by inserting
GET_DIR_DELEGATION between PUTFH and GETATTR in a single COMPOUND, and
_nfs4_proc_getattr() does not tolerate -EACCES. When
nfsd_file_acquire_dir() fails (for example for a non-owner doing stat()
on a mode 0711 directory without read permission), returning the error
aborts the COMPOUND before GETATTR and surfaces EACCES to stat().

Reply NFS4_OK with GDD4_UNAVAIL when nfsd_file_acquire_dir() fails,
matching the non-fatal nfsd_get_dir_deleg() path below so the delegation
is withheld while the trailing GETATTR still completes.

Fixes: 8b99f6a8c116 ("nfsd: wire up GET_DIR_DELEGATION handling")
Cc: stable@vger.kernel.org
Suggested-by: Chuck Lever <cel@kernel.org>
Signed-off-by: Dominik Maier <dmnk@google.com>
---
Note: matching your snippet, this folds any nfsd_file_acquire_dir()
error into GDD4_UNAVAIL; let me know if you prefer narrowing it to
status == nfserr_acces so errors like NFS4ERR_NOTDIR or NFS4ERR_WRONGSEC
still surface directly.
 fs/nfsd/nfs4proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b76320c265e1..dd17a6b47222 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2873,8 +2873,10 @@ nfsd4_get_dir_delegation(struct svc_rqst *rqstp,
 	__be32 status;
 
 	status = nfsd_file_acquire_dir(rqstp, &cstate->current_fh, &nf);
-	if (status != nfs_ok)
-		return status;
+	if (status != nfs_ok) {
+		gdd->gddrnf_status = GDD4_UNAVAIL;
+		return nfs_ok;
+	}
 
 	/*
 	 * Offer no notifications to an order-aware client. RFC8881bis section
-- 
2.56.1.831.g720f3f5937-goog

