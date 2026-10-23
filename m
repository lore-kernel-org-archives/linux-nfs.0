Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.146
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792720392;
	b=XhED/8fXY9t4vrhCOBRtqyjiXLNaVvRoqKPKn+cgBJlWMymhPCgWo4HugWU054GPDcZP
	 uROZw5DS/SsUBxBYuz+y1IqG6SYrBXi+n5hBS/4HzIffTe4FxG/mPhWAEtzH2qsDckMRk
	 H1U45Au79v9lOQjZNcNuhsJTDIW9ZlXmnGqEWyUPo9dkLt8dy2Af+s5Ysbw00EHZ3Wer0
	 g1i6vSuWh3pSXaCY1pNwJHkXh5r6uMitgx2iGYlNzpsXkNcIcyt8qvpcJFVUb71vfmP5f
	 trwLOJmx0YdVpxPP8kzs51Hampuhara6t5xb3RkB+rXq3CO9MORLNp0uLUJSV73ysmw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792720392;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=MnDjfXQvhYCS9cbXLtzi/mnGhccb8pedJ31lXybm9f8=;
	b=2zNw7jplah5nCmx/44+IYXhB6Np+r8bH4FnWcWANk13ubBdvpzr3zLkx+yz9WM/vQvIt
	 8EYhLQn6yQJfyud1XmlBUIIU37NSAnEA/XFHcm7LCpxeKP77ppd/w3NWtfmLKgW6+b4QO
	 ABfQkKMK7xZwpskhF46c5ZYEDGNx2p/Vqj/b0f+HmxiWj3GdO4BtSnx33j15fIcS+u3tZ
	 sSinTuEPvw4P3eGrw8COqPceiauWnCFtwz2VtBAsIV9l5KaSgbznvAiDs4o9nDtN6KX9O
	 G2sUc895Yo2OG5urvnvN0h5dJYeWGCVfjFzcF8DlB1iuO9IX66hfdGRdFw0h0SMB0SQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b="jh/AwZJl";
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=EY2wNQRL;
	arc=none smtp.remote-ip=202.12.124.146
Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4EED5606A324
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 01:53:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4EED5606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=jh/AwZJl;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=EY2wNQRL
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.stl.internal (Postfix) with ESMTP id AF5051D001B8
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 21:53:11 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Thu, 22 Oct 2026 21:53:11 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1792720391;
	 x=1792806791; bh=MnDjfXQvhYCS9cbXLtzi/mnGhccb8pedJ31lXybm9f8=; b=
	jh/AwZJljvqnlvwguxwcMvo4F9J1T83FkwgDzMnRHEcg/ffHX2AMnsoBOrvW0tlo
	6cwEgTZs6JaD+zfu5JPqk/QpNhcn2kHFRY+2HArKjY8wPNhgKXBVIisUxBIieJuo
	BdVKa/1yIRUWNf8dHRZzeJJDHUgds134A90svFfeHr4AF2+bLKvwEOd0zu6TdOl2
	Mzr6Nn5UN9bxuS/1WCJm8H1vUGmuofgHNOVyMRlRl/D5OlRAT1uYLJo3d9II02FS
	DJkaon3AVT6ZvWCR87tfxwtBYz3eY2YORxqxejkPhSXN6Thq0ZzvzTqYprYmo6MH
	nrDVvXLOQQey7Bk3i45m/A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1792720391; x=1792806791; bh=M
	nDjfXQvhYCS9cbXLtzi/mnGhccb8pedJ31lXybm9f8=; b=EY2wNQRL0XEeGH3ke
	fhknkEIyDKCqhvtNNVSABUzQBGg0bxOkxoC3qQ7GJ1RT938JkGTrMzoiU5XJn5vm
	wJYGoMjUppVjD+2AB60JnKrDdgzpiLzrlTOfApl+IPVY/RasEN0gSZyK+XdkP+Xh
	OuFglHZnmwdyY44mlWeVn1AomZa7OtM7IMAj/aVu26hx5BQohKggYYP1EuwO7Who
	vqfw22GO8uLQPHYWF86d0fFh6oeIRg8wl88OJ7/AQXIfpbfTWqvg4y44e9WX4gXs
	hMpKZq0VJ9WB2sQrRh96ou7xx3ub9+aiTrottcOHM/zNzxXTKhH54ZsiOdQpUE+q
	sLz0Q==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792720391; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:O9C19zMChFtpWAsPgcFad8hzrr1GqBgTehaTU6Oc0U/nq2U
	d+/by8lq5IZEhqni8OlXo+Px0E3MW70aBCpvkIsZi1cO7srT9zBD1dgO0KMBck4m
	I78jMiIFvjAnd1y83K3O8xQNcsWuTbf5i/VhwLuqGF3vXnmGSR5UyElG/Bbrcmhm
	8GOU/OnpIWYkmwi/FT7PamNgn5NVIiXCR5FMaSahQXfr+V2JQS0PcOTEgRpsJ14c
	Nv5ptDYSs7Mqti4u5qSWOKt0GJIB2yxiofKhg0OnS4uKlGOhzKs6pSQ/30U6ESt8
	zDc8r8cn6yIKbrtePup1fNjMl/0XleXXXI/Oy4Q==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:QWIPftl74jpgrYjmKu3JnLpD5/4WxHQ8cn497yenQfE=:Rj8mrG4OhoDtc/K0+ngf1ncfakHuLIQICnf7WPsuw6U=;
X-ME-Sender: <xms:B77aapvqKnWayVLdxSG-WskzeLeLI1Bl7QLZ7dB93BEjDfqCc82AGA>
    <xme:B77aalgnZlPQF7SCWvdDVApknBcvQgwqo_itGZowCy9aSWaxuIsGmztMxGcM3jWi5
    tjnkjZ6yxUTG4bDjxxOv1hUa5RBQPonQZvIROApobS7KzL_kg>
X-ME-Received: <xmr:B77aanaoFTtDNuOsGqBJ_tEvhQMTSGyXy_2YAco19dxutiG0_t_HaC1hYEMZILcuecNn7qBMnnDF2hID0-PsmlPI9ILm2Nk>
X-ME-Proxy-Cause: dmFkZTExLsW4SpLCAv0tdT8e4ZPZyVz4IupNhJEO2SD3abqv0hzNCt0wHCU9mnuewgcb3C
    8m9r5e3YKSPGnPB5PYtZBGCtADj2rC8TRrl1Bc3fUQAcoD/QlA9OXRwyejoKLjNMy4BgBR
    4LbEnQXkypLxZ3m4X/K/R9IRkdumNmSBKPe/sfK+vfZjOaMBax2CiZaO2EgzLsHG6TJvVg
    RpN12/waUzArwE0mLwMuNeArpooRt4XVRLhGwsa86uWcBuDyb7Qho3ZSdk2rEHCSbKf9p0
    4ukEKjRnVkvK5y+ofxTRlX1T622kiTdxG1JD6FQoOO8gRlRh/mERVb6ZQ5j3LkSoNAI4tB
    AIOXcyscG9mOK229rzjMebCA4vTLFzBu1yge0GP8lsvOXXet8bOwoLv/VVisAMNC0f9rvo
    3lbQuNynXCErCWqOAGbDZzUMv3dlIUweTHYv2/Sv98SesR5iSKDchXL3t0kgd47Y6WUU1O
    0chHWEFmSrM2KdDmhGj3F4G0WQtoNoKf/JovhRcfaHMO7Q0V2TcTG6xiGsBUmCDSb0qf7y
    6Dn5t1An+Icd5I7KxpFM/IENNqo0vNpMNmaXY8i/81L04BdsNs3MDDVoUdglMqQmjU0J6t
    PAEMa2sVEoJX3AdN4s1POjGg+k4FHx4eIUyx7KkGlBnRSzgIOYkev88DYqVA
X-ME-Proxy: <xmx:B77aasY1XRdyoK0r8ueakRe3vFC3h3bsozir1YhbGCjInGEiyYMLIg>
    <xmx:B77aakwySIvjB9VZJ6lqnnCdPNQbfNY2U8ACwBIpUf4BjnXStDA1cg>
    <xmx:B77aagfDbzM10crvHgoaiMbxh7tEu3358jZDZe9LmgPxyByPDDLR_Q>
    <xmx:B77aah4WvbUmxOlERb1QHt8AjCoV4GRUOr7cvRV4lrQMiJQD5rDmuw>
    <xmx:B77aasXfaNEYzKHqy8OTb2JLhqBGpMIoZHVHXfACUXWfJ9QTDqYeg1hC>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 22 Oct 2026 21:53:08 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 2/9] nfs: fix nfs_call_unlink()
Date: Fri, 23 Oct 2026 12:50:12 +1100
Message-ID: <20261023015239.2163480-3-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261023015239.2163480-1-neilb@ownmail.net>
References: <20261023015239.2163480-1-neilb@ownmail.net>
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

nfs_call_unlink() calls d_alloc_parallel() on a dentry which has not had
the d_hash calculated.  d_alloc_parallel() assume this is calculated and
doesn't calculate it itself.
So this will never find an existing dentry and so will not detect
the races it aims to detect.

This dentry ("alias") is never hashed so there is no lasting
inconsistency in the dcache.

Fixes: 565277f63c61 ("NFS: Fix a race in sillyrename")
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/unlink.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index c8d712204e64..11a46a993e11 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -125,6 +125,9 @@ static int nfs_call_unlink(struct dentry *dentry, struct inode *inode, struct nf
 	struct dentry *alias;
 
 	down_read_non_owner(&NFS_I(dir)->rmdir_sem);
+	data->args.name.hash = full_name_hash(dentry->d_parent,
+					      data->args.name.name,
+					      data->args.name.len);
 	alias = d_alloc_parallel(dentry->d_parent, &data->args.name);
 	if (IS_ERR(alias)) {
 		up_read_non_owner(&NFS_I(dir)->rmdir_sem);
-- 
2.50.0.107.gf914562f5916.dirty

