Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795124464;
	b=qRA/dCqzba/xUqJkf1SSirna/MjZiZpqs/rJHQ1/7Wcn3RDIzL7Gw5Wd/tLdhzibpzMS
	 gCFeyUCu3skLVpcvg1ZuLd/wC1s4uh9BbS4G7ZR56EogMoGikoyX8zp87D51z1Ct872GG
	 XV7l+RzOyJTIxNMM/ZZLrhUFwfZKoaM0UE5Zl0LJPxTlXVo2QLA4BiV8j16nmjUGr0v6J
	 YvpFx4OQdhRiJklo/Xfc4sLxtxEMqNGI5ZhjofMWVukMKl4UVdNkQDYqIk3VrQnmEXmCF
	 f9vkjNJNEZXVVFhEQAZexMwaTrTliAqFmvX2Yp7C7B1YJRr1LL4hIYY70k8i3lFS7Vw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795124464;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:
	 X-Google-Original-From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=+nVbn6aFsoNbCQ7aCl2HsSZwC2PgFRrT8PduzUC/8EU=;
	b=tep0AUipiY+BrjriwJTnur+pvNMifez8I3uSk7lRjumn6PnSz3/ALBMb9D1kUY+JXXsJ
	 Bu+i/fslEATwW5KwoEWx5o5rCoQEeKyVIhD6OEVSMYoBDH1Xl1KkT/h92adu/km67LOTJ
	 0iHwQ9bbycNHFcVnHK+SKsoj4h9HU/sFFQ91xJospSiP6y2ROCyybIDQwuX+4XkGOQx7a
	 4OO4oHl9CqaH+uitioc8MYfzNFl9rawS3clXgk7FrEkdw4VvswmhTgqlEWLuD3rFTiUO1
	 +qChz7as0ob6wcxBsrDxBoZ1KoulDyowfpUBE132Ud8rhDJwspefH2OQ9NyWeA1ROoQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b="e/c70FJ1";
	arc=none smtp.remote-ip=209.85.161.47
Received: from mail-oo1-f47.google.com (mail-oo1-f47.google.com [209.85.161.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D11B9606A320
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 21:41:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D11B9606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=e/c70FJ1
Received: by mail-oo1-f47.google.com with SMTP id 006d021491bc7-716b58a4365so134463eaf.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 13:41:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795124463; x=1795729263; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=+nVbn6aFsoNbCQ7aCl2HsSZwC2PgFRrT8PduzUC/8EU=;
        b=e/c70FJ1GUw9QA1Nb/0+Kb2FIQ4DBovP0OzoJENFwebdUNfAvvTiDLbSpEgOz4VF2u
         /R6SUqOdpi9Bf1xXrPPr+7L5eh2PKP+d/xg6eq3OtWT88RieolyMOfsFS2MbAyfjqIRe
         f39qBOKAx1fyqXOOstWBXRBm3j9oOVARAwozKK+lrm0Y+/bgezyyRJrhPoIXHcX56DHx
         7YJFDacMxfCTA/shKzBkdwZe1FrHHoJpzFY+crKLJFItWm16nO1sZdfzGnAVDixAWsY0
         q1+qSfeEASljSvbihc21w2oFVSEB2WcO4chReKrzUWKpnJ1KRXMmjQ7dm1fVZRbvpR1W
         5Ahg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795124463; x=1795729263;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=+nVbn6aFsoNbCQ7aCl2HsSZwC2PgFRrT8PduzUC/8EU=;
        b=GYOysf/ExWGnkuxcYkSFb9Y3xjRWpXgn6b1R5aBlZFw5xw47s6j0/xpusGi62XEDjP
         suRPpQ60Fy15CFUgp/VZfzDknv3JdlMYU1Erll4KexHL8bS2q/zG/6E9OOZ3sj+fiiw0
         GS6SYC8vqUzmp26CFFnnOkCCSwEnVB980Sx8gnZPbptjAI2xFlwWV3bWvHgwKzHWnCDc
         5nhWw2QtaLJASQ3PKHVuOzhBBX1Xxzg4EIXhQrHoFKB9rRkSSMDtDyghK3lgG53wHCeA
         HLwEh+/cMui3rtIDbmFlrHH2dPBqX+xNxXoU3r+QeiohOLM7ceOd00vQWKENDB7Uqx/g
         07JQ==
X-Gm-Message-State: APuU4Z9jEQ4bkSEwPW1W+s4mYDNwp2aiTGYqF0utW4DuYj3hfEkN9OQm
	AlYMDKIKP+2r1d6kNndcEodvMa9zySoyVEFeIIYGrRxNGZeoiTTVAaytShUhZ+PiRL4=
X-Gm-Gg: AYBFou2lr3uZAmYt5wrWHxRHPbgSs2MYjnbh+d68Ht+SptspVBzuBmU4qTPPtDplZC1
	h7dquW5hAq7NY2ZFXkwdOLQHk2wTngRZDQDSlhC5K6lMediKWNvQ2kQTGNgVyN506Qc/aBksKdb
	66pHjU0+9h3XIolvoeNLjhb0WGsYJu0cnZsNb+bSuyeXW+keb0Y5fxJTnGjKwxNzvRw9vJIuQ78
	RTlbWVVG//tuG72m+WIx92tKTE7OpA9ReIMoxp0XTCWpaYBouEqWCLmu60lrugBi+QooDUm6TFp
	T4gfDa4pTMoKnJdYAsX14YLYT3Rqvtr74FIR1O3sdrtyqt0r0RqXt7XKQAsExY4NjtS2YG9FCqU
	240yAo1xQLaBtPkPt4k52mK5JO/vQpQCQZFGtTI3pYl1z6F1wV/es069fh0kcCU9Ce0dV0Anx2f
	YvV68tyy76vSVhNtHiOgcJMNcCnqtUx1/ZCDElo4dF3lLpn/a2yK+fQF5Tc60DpfABwtGAuR6/y
	E9EY6E5yD7lLJ7DzmqFrDcH5kLRuVUw4f+YTvM99EEmerO84zF/e7yA4wThKPI4bScCohH5+ymu
	NFae0/eC95TqauuC+N+BSDtZlI+43JVBBSwW8y1fWMuloEruMl3XTQmsnLr89GVxaRtf
X-Received: by 2002:a05:6820:a29c:10b0:71a:f8c9:c6a1 with SMTP id 006d021491bc7-71b394c8c6cmr815490eaf.48.1795124462498;
        Thu, 19 Nov 2026 13:41:02 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8631670c44dsm642217a34.0.2026.11.19.13.41.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 13:41:02 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: calum.mackay@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH pynfs 0/2] rpc: fix two client connection failures
Date: Thu, 19 Nov 2026 16:40:58 -0500
Message-ID: <cover.1795124374.git.bcodding@hammerspace.com>
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

These fix two bugs in the pynfs RPC client, both seen while running the
4.1 server tests.

The first breaks --secure on a back-to-back run: the client rebinds the
reserved port left in TIME_WAIT by the previous run, connect() fails
with EADDRNOTAVAIL, and the error is replaced by EBADF, so the run ends
with "Initialization failed".

The second hangs a test when the server closes the connection: waiting
calls are never woken, and the polling thread dies in select() on the
closed socket's fd of -1.  With the fix those calls fail with an RPC
error and the test is reported as a FAILURE.

Benjamin Coddington (2):
  rpc: skip secure ports in TIME_WAIT and report connect errors
  rpc: fail pending calls when a connection closes

 rpc/rpc.py | 80 ++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 59 insertions(+), 21 deletions(-)


base-commit: cd4701827a8261fedbfb4c6e39029fb9671321a6
-- 
2.53.0

