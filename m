Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.151
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794185758;
	b=JYMffaqUpxoUYiiuM/MIj7XXPSMF8pNDDZeWUesk0uegZktge57un2cHTzTYAPOFTv0G
	 hNm99OlOSKecZ843vkJbKW0gQaYqdOm+FQMG03xSqzxSMCWh653u6JShmi7ftljIvZFnK
	 xS4mZPdysHdxZj2yFU1EsyaN5px8jdsCM4EDm3EzeJVMtTda7o0On8I/2vAy+90U1NbtO
	 u25n2znY+Wf/7Ye3CjDcUJzKnmOChyF6pFc7nSYn3gQoOJ4ZbFZ3SW6z2Vcs1keG25dS+
	 73urshDk0C/hC5EEOLdey3eN5all84AUGk6gIJx8VFvDAju82YLYqxRknp8gnJQfBjQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794185758;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=HoRGP7htCKhkq9NBAyYjcCvUUGt5xhNP06kHQOBkDmo=;
	b=kgN7iFALLjbrJVw0p8/9Z3EU8foOodCnS1vJksitpX7B+fNd6tpWXjbBTvZAH2euOMzl
	 tImQzPNe5NrxXs/Qw2Gw+nT1PAde1U1QFvYibkeuFk7Nf/zmucbwEFQsVvxr5ZsDMgaF1
	 mBl5jCe+QObDAps+hQXZMx5n58u1ibVKpTMp4VF46W3a8Q6F7dSoLOXV2wob2g6Jdy+2t
	 giO2wA7loKwnrU2mtTkZ3g3zHDiNGhCyfMPRMQoakVb6AlCkHJr7r6JtYkMqU7sj/DsEe
	 5FrvvOs+OaF0eE9r9tFIyL75DeSSYzcqp3WHKsGQrPNfxbIEdbHvPwh/8DnhuVZMUbQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=d3CynQmH;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=VcUFlg76;
	arc=none smtp.remote-ip=202.12.124.151
Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA67F606A320
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 00:55:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DA67F606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=d3CynQmH;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=VcUFlg76
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.stl.internal (Postfix) with ESMTP id 518021D00052
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 19:55:57 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-03.internal (MEProxy); Sun, 08 Nov 2026 19:55:57 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1794185757;
	 x=1794272157; bh=HoRGP7htCKhkq9NBAyYjcCvUUGt5xhNP06kHQOBkDmo=; b=
	d3CynQmHCwjWUKDApK7ubKHs6MgCVnDXKHivJkJK0DJ5kZu4s/GJeuEIBIL9qNQh
	npKQb1TqEM7iepRzMroOlQiAI7Q68Mc2WelslEVyUO/fsizChrLV9p43mAnCBm6q
	mlWs+36eT0xWH32llJXk5BCBy7HFPeV9VN4eZtG/sm3xucGvh46VV0SiblyZxESt
	gaPcQIoecOiVD7hBlsv60tezwJkqRMaOJOFiiPkQpU7yBU2LSJCXwHvHFMRpQ75B
	DM38Kw0GaukrJtSxI5zORy+CbWuatt6v6CSmZbqn47Qj3/QhmkbltuslSr2U9Lkl
	Azbn88IIAUniefPYjanUsg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794185757; x=1794272157; bh=H
	oRGP7htCKhkq9NBAyYjcCvUUGt5xhNP06kHQOBkDmo=; b=VcUFlg760uxHTox+B
	X3UXbxeBzCRFPAFRcdKAGyg/RselJLRFGxQH4KYYK4pgSJnEfpFDjTlYqYj1zRgd
	EMRmRoIz9cBkPSji70KD+6uLeytLHBSyxnJco8i94xdqgiJjEZJLY9X71HBBDkHo
	9PBUzL9NqiqrGUOzCZ6ImWT6rsxHnx/o5W8YjksMdrhUf67lXDTWGKQ0gdqPCVNl
	I+WhwcgL3uJs9ihDSEYcjTsCPuXFCgoscyD/JrWfFZa9IJCFCCAMEHMpTo3XMwEw
	z/cZyhZ6JZNspDahG3Ya2SrSIIAJRcBoq+V9p/4b6tc5n7/gd3h3yBE40HL8MWXM
	Y3hJQ==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794185757; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm3:rsa-sha256:bW3u7mlX6N5aYdKwb2mRlH4NVxPd+hF0nzd4g2T88S1P3/D
	i0G6t6DXopF3ip0qCA8PT/LX+1+X1LjxSmR4L9Xez3mT57PspAbMuhr9RGRK951t
	rufpiGrEkRwzb8RqaDjD5nmIa9JqEsWP6xbhHLRbZuyFcSTBeVlZvCL1xcrDQECv
	oFHOz8FI6hmwg3i1kgWqbLYbLp7/X1VjFHy6riiQwBvBmPAOfg3zBac5AT5gyIXt
	02CcAEJXCkywlu6ODmleJV1PKnob+XPJ+MiGqVfhPFMwKe4C4KtRMO/e8w4m3TgW
	kH/bnNx5XGyQOzinUCbc6uINQjj2cCTco3E4Pjg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:zGU01ZC2L/LOJ5g/OfX60cJXutKJW0qKafchckx2/l0=:BqACf5Oi5l5eTNVivY+ZgmYMKM3DjE0tckMm7bXHqyE=;
X-ME-Sender: <xms:HRrxagzqc2gsFbdIZe4bTZUgvGJy2d70b9ozkRAoRi0bX0a4_j8epg>
    <xme:HRrxarJV3uO6cO-z0DeE7vbNxyZ8jDhIqytXj4mvDmdVb9E9_T06qxxwZIj7gDG9C
    70giIQwiq-p-djzUNSA2kTq1MT5ZekB2TtjPZkMQVskNGXe3Wg>
X-ME-Received: <xmr:HRrxaqr70sXVXNn7RtNYNSlr0DwKbVdviLTDTvzNGsMzkL_iVXh_4n7WHRFXUlqf_PPKDho1-ScijewM2ZdP7P-d3tw6Rkk>
X-ME-Proxy-Cause: dmFkZTFWGJ+80GA11y6qFquDy/HO4Ri70ZTirHsfaM4N47KcR80WwfXX5JPo+zJfXW78U6
    3Owmbzev1aYo4THK3iSDehj4WN6aXct4YeYaetqJ0BnDRoRygTmbXKFGfQtvREuvjrQA0D
    7DDrepuHUNLLZ8wWwg/NGujQtXHHbZdroOa3ZgjrfXSpNNPhnOZXmPkv5dl6yXsbenPX6W
    p/fw9hwDPi9oFspS9XTZ6l+96/k4VB4mn6+coX15HpdT6rfzK4Mge0ONTnBptnIxN7edGu
    sbZKOnFGOYoiyYdhSB2adTMbzBXEf/139CK3ADDxwKBzMeeDMha+6HrPhVnL86t+ynSUWD
    gW47HqBL1F9oTWdq4CURQqbPycO2Or3h1qadBzlHiabdIkMSPmESPnOksRPFSk6Mp1xHcX
    Lf7w2IsxRYh25wZQ3GawkAkzx1q0Te2DUm/MFF4O0V2N1JdDNv2zed1GS+PeLCaCx27KGj
    GQkHgnJs69UxHlzulGBLPfeuLap9ngMbkMa+OUnRgK+CjvA9wPH/1kxpU70k7ssWm+/WKo
    Rzy+ugRg/gdKpbvDMLjOFKw/IH7hUyMziysM5axZzDX1eIvBUL/ArHu9RhyoyYSNUBq0hL
    tGMLakCqDH8XYr6A+OThHOsFrHJ58yRg4O8AOvSoXDdjJQA2iOiyzUS39t2Q
X-ME-Proxy: <xmx:HRrxaqINSbtHF57ujQgqtclaETxZeyzB254Dw9f1kKlQ-iY94mKvtw>
    <xmx:HRrxavQWyKJZFNgNt-MxgxE3kam1diOL9_IEKIcJOOORuNWkNfuf3Q>
    <xmx:HRrxaptXvdhrhhPVTiHlyMoJJQ_KfYsKJLLuuFPWCB-rFORrkStMvQ>
    <xmx:HRrxagbXcOhthTfsJXZhkM-0vQGH9sZ5eS6fhluld2TFOx0UIDTHLQ>
    <xmx:HRrxaoWjLKcFCu9_if0QG9wt7rbYRvfqkiPbB7SHo2xsW7tP0MES5irg>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 8 Nov 2026 19:55:55 -0500 (EST)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 8/8] nfs: use d_duplicate()
Date: Mon,  9 Nov 2026 11:52:37 +1100
Message-ID: <20261109005504.1804605-9-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261109005504.1804605-1-neilb@ownmail.net>
References: <20261109005504.1804605-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
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

From: NeilBrown <neil@brown.name>

As preparation for d_alloc_parallel() being allowed without the
directory locked, use d_duplicate() to duplicate a dentry for silly
rename.

This results in an in-lookup name, so d_lookup_done() must be called.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f10d88a13006..8309c22a3084 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2813,11 +2813,12 @@ int nfs_rename(const struct mnt_idmap *idmap, struct inode *old_dir,
 			spin_unlock(&new_dentry->d_lock);
 
 			/* copy the target dentry's name */
-			dentry = d_alloc(new_dentry->d_parent,
-					 &new_dentry->d_name);
-			if (!dentry)
+			dentry = d_duplicate(new_dentry);
+			if (IS_ERR(dentry)) {
+				/* Keep using -ETXTBSY error */
+				dentry = NULL;
 				goto out;
-
+			}
 			/* silly-rename the existing target ... */
 			err = nfs_sillyrename(new_dir, new_dentry);
 			if (err)
@@ -2882,8 +2883,10 @@ int nfs_rename(const struct mnt_idmap *idmap, struct inode *old_dir,
 		nfs_dentry_handle_enoent(old_dentry);
 
 	/* new dentry created? */
-	if (dentry)
+	if (dentry) {
+		d_lookup_done(dentry);
 		dput(dentry);
+	}
 	return error;
 }
 EXPORT_SYMBOL_GPL(nfs_rename);
-- 
2.50.0.107.gf914562f5916.dirty

