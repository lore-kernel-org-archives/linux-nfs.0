Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793055715;
	b=W9R5NLQf/rUVwK9cq/jqycV1+cE7+EFX+YlRzEiRc90O32LbS2QFE8jDS+DHmOcaTNuA
	 46zFvBKJYH0JfWuJIbwDR3Ub3OV0rPPUuRZMtTfD5MY2r+NkdnNVqk8u1mJNHYHh3ioqT
	 RmkmBoufRCcPcXG07f3/ER8/CuLPjdUKbmwbHi7fHWf/OH1NoZdn01Q4wTw9mt25W8BY5
	 aqhBnhvcMuhZQNgsV8ac9BANoklv9fPxYHVuWMHgo0DmmIznyR+23VFhgKlU5JddWTmNv
	 2Jr3p01+OgnJFKkMhBIfZ/GKCmyYLlAQAkgLlv12LYSKwMvic86WGI++brNSNRsMp5Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793055715;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:X-Google-Original-From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=c0h4dPwM7Lc2ThvwHjpwKfbW4C8bAJIrwdRbNwJK6ik=;
	b=fQ+Fz6JI2sNSaBI932dFzq9wItS3X2FYi8x9u776Kmma3yhe7QpOkBSHy4JQxLpt3108
	 kBl9KwMM3l1gaN2FU7lnDt+i3f67FWK7UGeMVlXwzC3xCq9RaOi5iB1mOtuEfBAbAQhva
	 XtlgP6vV+G0TdiFUGsrAoKygS6VoYwOHiPKSepf8lHiNdMk3qCSG6oBwh5TaHtWFfxnOW
	 4hE7p60FdLIMd3jpulGwn7dTD0E62iv/evxgQytG7pVbp37Yr1sq4LljMiitjZftznonv
	 kPBjbAvuxi1x3VvuWVe6SvB35THKOCBms+clXobT30KVsh8ecMBNVVJr7BlW8RwBPlA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=JJA4LueD;
	arc=none smtp.remote-ip=209.85.221.46
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79B8D606A31B
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 23:01:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 79B8D606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=JJA4LueD
Received: by mail-wr1-f46.google.com with SMTP id ffacd0b85a97d-48e20edd106so3048059f8f.1
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 16:01:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1793055714; x=1793660514; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=c0h4dPwM7Lc2ThvwHjpwKfbW4C8bAJIrwdRbNwJK6ik=;
        b=JJA4LueDcJQO8MY4dVrb5Xb2+MSwjo5dLXPT75rPafojjir+k/OsWyG9+UrwTdhM+9
         pKIl0y/fpvExNndABZxIiVys+KKNt2agaeNb6vvMU8F4PMbPB0p406kPxzNBlu5s4sf3
         PFHyAnGP0t8N/Wuvna7ENMT7wsaLxaWJtoz1KE4ykuQGf1/cLEngOiapYlwtyNA/g4UA
         5eyTVqY4UTDfu0FyLphVkWzZdthBj2C+CoAM5MtYMrypUXtWIl9rmk51XucuQ/zYlbwE
         NpWpWL79pg1sYXtLkeAR3GngK3Pq2LBqDj8tsiPQ1rTO7z5ox3PMlpvgnZyNG8VYn9BR
         Gz6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793055714; x=1793660514;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=c0h4dPwM7Lc2ThvwHjpwKfbW4C8bAJIrwdRbNwJK6ik=;
        b=QdlB1go0RwI66O9Wcv+4xBNO7kQAQp6tlHb4+JIHuQGJR+fVJljnbmBLjHEED2q6W5
         DOWVeShPwEbNyGvPpy+3NB8N9YgSPod+3RqaT/MepuOJ3sAT7EKhJQifew/ZZ9fRA7c2
         1HFbKxhoi4hl89vNDImiu9L1T97KNt2oulEbBlVNdbIw0BaIJhJpULrj4AB2ECnqiZVA
         W8ILSWk4E6PdGuLFEiNzt8GQ64KyaAfmTTgwQ1hn5gSKwJ+l6Gyws3q5fMvUggUY5xce
         e7/et/eUoaqNN5bxEZCn1mTMPva0N1mDi+YSGmVFyU0z6uAsZX5p3WjKg//M6YDnHeLQ
         C/9w==
X-Forwarded-Encrypted: i=1; AKwUvBzZrs1L+WWYNWGGiX8JkzX27J5gAax48L4O1n+6AvFWeTFe6mc1+YrCb+KI6J7eahrQyBaSoBI3paM=@vger.kernel.org
X-Gm-Message-State: AFq9FYIK1S91XiT8wP7R2FUGahFN3x3LyQVsd3ovhNkFaVd4Hh+ViL6B
	kauX0qhu2gBRDhz1jyPbxygWwZ98Llqr2TOEzafU+GF/U+ee30pHnlc=
X-Gm-Gg: AYBFou0Li/cqevG17qSaKmbPKSgiaAojnuqkxmPV0Y8xYTsclee+6qfuwYBfBhtqrEs
	pusVcjNOIWYt4zif+UZmhSRdvFoOApaextOAoi2bqimxk2sKKBUFgUKA4JVwErs/RcY6zZE5JC3
	Nr5oqpsoFZCHCkWj17YaXF4bAmBXQ5JAmnsM0h76jarCroaW688E68ptwd7IhprK3BaUj65C59s
	eRAMbZzpN+sxy8X399597BS5u0pK2OVR7Tsx9Ull1YOOjEoku/S1hblXOGtVatSoTpdTYYaDsfX
	8D8zrsddXATg0WePWYCJ5+USKBfhgioNcIaZRPfWVnMkW6ch3aXzCy9ABD+TMRmT2yZUQROMkbJ
	C2NhFfObE8XVsym3+Q5ojx7hoM7IwfTOyEuEH3urz81ENoSI+l6TpbUOwrQuqdjhUBdEYCmzU8U
	7ub30NNQh0SF9G9AX2kFIJDWLVonZAzPeeew3iiiQy1nS3AWF9+El//d0Npqu3+lzHjN2lDw8u0
	BWTph9H2zhMZBD6/R0ny7Ch0aqKP9hN99u5/w==
X-Received: by 2002:adf:fe8f:0:b0:48c:67d6:a87a with SMTP id ffacd0b85a97d-48e3eb8bdbbmr11263342f8f.32.1793055713530;
        Mon, 26 Oct 2026 16:01:53 -0700 (PDT)
Received: from debian.. ([2001:41d0:303:db6b::])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e3eb40733sm14827198f8f.0.2026.10.26.16.01.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Oct 2026 16:01:52 -0700 (PDT)
From: Tristan Madani <tristmd@gmail.com>
X-Google-Original-From: Tristan Madani <tristan@talencesecurity.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	tristan@talencesecurity.com
Subject: [PATCH] nfsd: pin client reference across async copy reaper cleanup
Date: Mon, 26 Oct 2026 23:01:51 +0000
Message-ID: <20261026230151.2474608-1-tristan@talencesecurity.com>
X-Mailer: git-send-email 2.47.3
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

nfsd4_async_copy_reaper() detaches completed async copies from the
client list and later calls cleanup_async_copy(), which eventually
drops the stid reference via nfs4_put_stid().  That path accesses
stid->sc_client unconditionally, but the client is not pinned during
the cleanup phase.

A concurrent expire_client() or force_expire_client() can free the
client between the nn->client_lock drop and the cleanup loop, leaving
nfs4_put_stid() with a stale sc_client pointer.

This is the same missed pattern that Chuck Lever addressed in seven
other nfsd4_laundromat() paths with cl_rpc_users pinning (v7.3-rc2).
The async copy reaper was not covered by that series.

Fix this by:
  1. Skipping expired clients (cl_time == 0) during iteration.
  2. Taking a cl_rpc_users reference before moving the copy to the
     reaplist.
  3. Dropping the reference with put_client_no_renew() after
     cleanup_async_copy().

Export put_client_no_renew() so it is accessible from nfs4proc.c.

Fixes: ac0514f4d198 ("NFSD: Add a laundromat reaper for async copy state")
Cc: stable@vger.kernel.org
Signed-off-by: Tristan Madani <tristan@talencesecurity.com>
---
 fs/nfsd/nfs4proc.c  | 5 +++++
 fs/nfsd/nfs4state.c | 2 +-
 fs/nfsd/state.h     | 1 +
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 50c07561e31f3..1f36afceb1fe1 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1501,6 +1501,9 @@ void nfsd4_async_copy_reaper(struct nfsd_net *nn)
 			if (test_bit(NFSD4_COPY_F_OFFLOAD_DONE,
 				     &copy->cp_copy.cp_flags)) {
 				if (!--copy->cp_ttl) {
+					if (clp->cl_time == 0)
+						continue;
+					atomic_inc(&clp->cl_rpc_users);
 					list_del_init(&copy->copies);
 					list_add(&copy->copies, &reaplist);
 				}
@@ -1513,8 +1516,10 @@ void nfsd4_async_copy_reaper(struct nfsd_net *nn)
 	while (!list_empty(&reaplist)) {
 		copy = list_first_entry(&reaplist, struct nfsd4_async_copy,
 					copies);
+		clp = copy->cp_stid.sc_client;
 		list_del_init(&copy->copies);
 		cleanup_async_copy(copy);
+		put_client_no_renew(clp);
 	}
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9c4adf3110aea..10e864ca7407a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -252,7 +252,7 @@ static void put_client_no_renew_locked(struct nfs4_client *clp)
 		__put_client_locked(clp, false);
 }
 
-static void put_client_no_renew(struct nfs4_client *clp)
+void put_client_no_renew(struct nfs4_client *clp)
 {
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2d00a411c6634..1d3a7e35bb9ff 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -918,6 +918,7 @@ extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfsd4_shutdown_copy(struct nfs4_client *clp);
 void nfsd4_put_client(struct nfs4_client *clp);
 void nfsd4_async_copy_reaper(struct nfsd_net *nn);
+void put_client_no_renew(struct nfs4_client *clp);
 bool nfsd4_has_active_async_copies(struct nfs4_client *clp);
 void nfsd_update_cmtime_attr(struct file *f, unsigned int flags);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(struct xdr_netobj name,
-- 
2.47.3

