Received: from fout-a4-smtp.messagingengine.com (fout-a4-smtp.messagingengine.com [103.168.172.147])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4AAE22BE03C
	for <linux-nfs@vger.kernel.org>; Thu,  2 Jul 2026 01:40:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.147
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782956446; cv=none; b=Tly+CgjLxgGsXUx3SmP65RDvlq6v5dU8O8e0tCAD+YkT1yBG27xYd30SNo9Fi6DnqiDf98AF21H8ED3IZU5tw+s9NC227D8y5Ektyo4v8M+n8DJeJbGT8HCT0ro3USdjAUlfaw38l5Ajwjc0RGJZ53PdDVTJK5U9WakHX33Qva0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782956446; c=relaxed/simple;
	bh=yCVX9B3HDyt5aDE4nmn1eBi/yFVydbPRt9Qcuhxv558=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=SYtsVG2JTrzGflGPmiW8fr/xcEG9gGRFRytll0Lp4lyNpKY1Sv5iI31Dc3gNwfd4j0d1pMDpJ0N6xiWy4OoyuOTdwdKmZGxfYKjBUFNc/t2ze23JK4HyHfUpV00bsUcZvVDzsZqykHDebCyU1hAIuPKPV6MCkkWOOQVaEwnxswE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=RwsAg98K; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=iDzLZUcR; arc=none smtp.client-ip=103.168.172.147
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="RwsAg98K";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="iDzLZUcR"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailfout.phl.internal (Postfix) with ESMTP id 9ABE6EC01B1;
	Wed,  1 Jul 2026 21:40:44 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-09.internal (MEProxy); Wed, 01 Jul 2026 21:40:44 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1782956444;
	 x=1783042844; bh=auTZ6VpC1GiuToLSBNj1jHSxHsjxUOofUamhVBcLLhw=; b=
	RwsAg98Kbd/toIGWK6yyKMdaE5YXLrHEdRNczVlHvcaZ63ujRNYv/RZjOO70noNH
	82s1hqy4T4YfslAj8hJd9sOiUjDq8RSPMmaWKmI9hgv7yyJdikxv5gw/XBGLtzhS
	R0tNa4J6EIxSpou5EaWUGEd5pqiyzEhfjAbwobf83o9X8WLAcCw7+106YxaKwZr+
	pJleDx/QqESQkEhJJLBJjLIBcAbxqRgEUJgtWiuThYQSofDQoIdM55n80MmKu6wI
	qgKw3T5AaEnJCvehfky0WKomPIYPwM/9VAqw9b/Tp15EtfhhrK3VAgNbtU3Ppg5O
	ulyBTMZyKKlQbyWv/Dc0Yg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1782956444; x=1783042844; bh=a
	uTZ6VpC1GiuToLSBNj1jHSxHsjxUOofUamhVBcLLhw=; b=iDzLZUcRp4tiZPVzS
	dqYrYck8i+q6YZaY9/AyjfpWdLmXvVhAcHoVc3cUq1agvXOH1tlfGOiIBoMPMRgk
	Gws0t/UlUmHHxTjPN76lkODvZrIDKfJafILBNCI2YO5YjBDwL/U3MAbdObbM+js7
	Zez6IhiAlbI018pid1r+9sLwZlhccrw4hWl81Q4joE+r1Ii8kFWfD7qIjFmKKR23
	lpzjYbykcr/kG1wD4QnbMMvsyvQidnzBsFRUp4gy995IV58b0Xz11+seRedfZAl4
	AcAo6Wvq+cC3dE7VcwjENbKtim/yQ8aTdII6qct9IRrQ7NCV9cQKSa3CvYPYWO7Q
	7pmeA==
X-ME-Sender: <xms:nMFFarDFFLg4BteQAtwGp3dDrpgOrGIUecXQ7jeicXvjdTS_wi_qeg>
    <xme:nMFFalONJeCflejj0M8MCM-Lkr9qYqXjKpDXrb8hgnE2azXO0A4fIbM9Pe1y3E7Kb
    rxwI1oIBoRB_XsKU-x_UYZpq3dW0prz172dFvAV62YY6Wqr>
X-ME-Received: <xmr:nMFFagYZPbgAb2DshK-9MBRUsXs9btlDvNScV8LiO_u9oJFUdSySPxwPNeiU3YTPPMWM0V_4fxBICfl-ExxhzuNhFbn7WxI>
X-ME-Proxy-Cause: dmFkZTEBVDJy6WgOC1zITKpnRUuNcLFM7G19761VI7n+OPl/n+VIkxww3h0C7czzFt+I7r
    ytkmwqa4AGn4/QjuSP2SJdWC9SgnMcizI//JMncoVj24eUV4rZkLucS0Y6dTI0LS+4OnSb
    Z7k4kwQfqKoF1gzhW6ifSW9bKWK8Cabx1rA9PolZ7jXqjUIh4GaRU0l8kVsKgFWEhFEEMu
    6V/ZRURWWPEAxk0PGk6wZ4+pi2wCCpL8a+ok+ZBU97Ge8op1UBVRcbFSPSMI1y48apX7uK
    IFXck2rHhwSCaTjGxBLqmQAEQtQUVlL6D7bYR7c/Jo+RtAs5q6gDaUQTOyu4IiskMdsNIJ
    WuTqobfZHGI1SvYdZk45fJj9KHXBknuflXPn5PBz4t/nBZxaYadiDVYuxkhbFbtQASf7V4
    mzUsEdhTOlH+09ehDx7DEPiKSR9e0v06hlCkTh8BgFvQ4pxuVqwectMvPR5p61fUrYWPuC
    RswGJ/xM2jJkCs5ShwhmgupZw9UU8Eb85WKJ3yba9xO/JJi1VIdOjIICFs9UQHjKFA3BGR
    PK4efrINjQ5Lx2I34ISfr/9SkwUuvDMvqd30Vw+hgltvDodzhR1gPq3GCP5wDO36YqSx+D
    YIYQSQEnVfs/C8x0gYkxPmn7D6Qsv3u7OglvevCSSgtpwzC25LFIwIRK7yGQ
X-ME-Proxy: <xmx:nMFFakt79H9T-cEKDADHIQgWLlXUgK-6jaztSg4LLUJ0yfugjWiK-Q>
    <xmx:nMFFaiOwdzv-LRnA9nydlM_HzvIEmXVEyUDOLarkVsVZ_fkDHUpKYw>
    <xmx:nMFFar6PqSP1LIqWV4OhXP7Vlhs4Ql-lMAH4layFigvBd0hltSzl8w>
    <xmx:nMFFaoReh9ukpetstpPJUOwHH9jasw2QadDQsN7XuIltShad6x6CJg>
    <xmx:nMFFasiSWqOlBCEQXEb6hhNa89GUAc41H0blcaLF2V2__z_WHIWfKsfi>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 1 Jul 2026 21:40:42 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH 07/10] nfsd: reduce range of directory lock in nfsd4_create_file()
Date: Thu,  2 Jul 2026 11:34:26 +1000
Message-ID: <20260702014000.3397240-8-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260702014000.3397240-1-neilb@ownmail.net>
References: <20260702014000.3397240-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

We only need to hold the lock taken by start_creating() until the create
has been attempted.  Holding for longer can serve no purpose.

The lock is currently held across the setattr call.  This might be the
intent but it serves no purpose.  Holding the lock prevents the name
from being removed or renamed, but it doesn't prevent a GETATTR or a
racing SETATTR or an OPEN.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4f730ac83cf8..9dfdeb6dc379 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -331,10 +331,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	if (d_really_is_negative(child)) {
 		status = nfsd4_vfs_create(fhp, &child, open);
-		if (status != nfs_ok)
-			goto out;
 		open->op_created = open->op_filp->f_mode & FMODE_CREATED;
 	}
+	end_creating(child);
+	if (status != nfs_ok)
+		goto out;
 
 	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
 	if (status != nfs_ok)
@@ -387,7 +388,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			open->op_bmval[2] &= ~FATTR4_WORD2_POSIX_ACCESS_ACL;
 	}
 out:
-	end_creating(child);
 	fh_drop_write(fhp);
 out_free:
 	nfsd_attrs_free(&attrs);
-- 
2.50.0.107.gf914562f5916.dirty

