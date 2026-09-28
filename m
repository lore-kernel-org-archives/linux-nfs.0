Received: from mail-pj2-f41.google.com (mail-pj2-f41.google.com [74.125.227.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B983C46EC69
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 08:36:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790584578; cv=none; b=Oc/ctSxP+cEDBj1osNAXkFlLOZ7C1XYtMFqbwI0t4SpShVSi7bDPcDdOZ0/wI56fRFk/v90SA59vsFDTeQSPr/4GOnK1ibFnRxwCipNNnbMDC6jSa+PpaCzRix9E3OXtTfH82DHWmprmz9TOpW/kWfndguWy6BtsWxhrq8BRt/8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790584578; c=relaxed/simple;
	bh=FA2Revvh7pofuSLqWgjxDTK4Uql4qoS1SnjOV6NpwIY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=e12b1nLMtRCXPRWVi4893xGQRH7LR0LLpIui24dxfSVMdd/vYpqCTFPXP7EQTkwHKuq2/m+mt297RCqZE7oEjnd7U69o7Eh9Z6UTVDoL0raTDdi1h6rPeLzBDqA/QaOifBuWYSocQn+2YSH3oWZ21SQrf/oe12VczFNfxkKlksI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=nDlmMCuA; arc=none smtp.client-ip=74.125.227.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nDlmMCuA"
Received: by mail-pj2-f41.google.com with SMTP id 98e67ed59e1d1-3a0b6200eb0so2025375a91.2
        for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 01:36:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790584568; x=1791189368; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=9TpVPhBv76sMWLB51aKviOYNFdFTWM59ydnlqHTXjE4=;
        b=nDlmMCuAIy7i53T9wANrI5mdRjMZKMFAx0wecWTvePgPTx5DyN3MRcoCkbuAtwzcFB
         as7Sr1TLLWy9rvxRaTkGhb7fzR8m/aDM3Q31EfUqwGBgWx1kNydCdzHtxbR5Y/e8RWYn
         5R4JEUZrtZ/0u5yPr8ISLWVX7RA69X+uT8kyQUy5rU1OAO7F+miVob+StHZ0GrdVdZwt
         oWMFD4tdrSu6BtDVR9roXr5bwnoluJ5JzMWKWIMrh8SsqniSDn3dgEzC7ihHiksM0KXz
         /BWq3W9R0w4CC2L5nXCMsndo1VsEZptYzpaqq4/8fP4p7Halfz9jDTghv+3N5uhbYBHU
         opmw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790584568; x=1791189368;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=9TpVPhBv76sMWLB51aKviOYNFdFTWM59ydnlqHTXjE4=;
        b=zdit33zm+pPi87WhIt5p2vih1uY3/cmujG4rZjA6iBfh54ZF0xur9XGHTRc3w9uuIc
         y54rcBfdbPGAEOeW6aQBeJywOT88+VyOkp/IgIzeeTAy70AEXY8k3ujufI8JGgTjj21w
         sIj13VOIMzHCHr8W5biFLqVe4qRPr8BcYmwMy0/sAMtAtq8+vsNMImyT04U9LOsou0QE
         NirmZlABhUvTZYSRrpUe+HoJuiguuXkfQt/+9DkC14q1hnyI34nS6MSPo3e4TwBLY7oU
         g2A5oCwuMfXgBLFPbaldkl5KwhX0QR0W6lTWsVc/akljprTi79mDC8GISLX/WfSEWkdE
         vR+Q==
X-Gm-Message-State: AFq9FYJcmRU1d90AjHfw4ZyjoKWrc+NJa4RFXLWqaM/aki9UN/s14ok7
	tn35tmseBFUSS6eer941B8VtcZeODdPv0YUTbGfZX6QxZt/AqVUQMAuVKnOFtemU
X-Gm-Gg: AYBFou0tGxXP46jw7NaNqvYT+MaeUW/vMVQ6lDqecO+ooAQ7+tRlmyVKSBeR6Auuhl6
	CsT40qjTKSDZMSJfjB+GoD8XYWg2k3OOd3Wqb9vfLM7ZwFbD4lH6okqkxcHgPgauQEasTv4hv/C
	YV5VtqYNufgmDCVLJ9h7qk+eBho/3Q91CQGL41qtrYlzui6toitwiIjJyKgMAjVTwoSZsKNa1D6
	kEwqll196A7plCU40K65TdV+uTnbmwh/4upeb5wfiMEkpzSZnVr4f9Ec+PjlyDdjiwYCHzjxwuZ
	6ehoG5M1V1DNUzYg13rySPIqBfmTXx66Vs1c0okmSb54piArWS+X1p0vhZLfdKWyjiv78mDRxFd
	BETK0NIYiZSTXtIL5bAJqjEhCbonVCw1Uk57aVYX6VwPqvJTmEwKOcog3Yyg707xWGEzsLkWC+q
	GqVrHZz6DpaTbCdLKjU2bNLEubBdrZAgHCQpV3hPRH10HdC/Nkmyi+TH1uqf4WCT7Ap4QcGr8md
	OVol+Q=
X-Received: by 2002:a17:90b:4d91:b0:39e:6a80:b799 with SMTP id 98e67ed59e1d1-3a0bb60e3a4mr7354674a91.41.1790584568144;
        Mon, 28 Sep 2026 01:36:08 -0700 (PDT)
Received: from bintable.localdomain ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a46e593a5fsm1478328a91.2.2026.09.28.01.36.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 28 Sep 2026 01:36:07 -0700 (PDT)
From: Jinpyo Lee <bint4b13@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	bobtobabz@gmail.com,
	Jinpyo Lee <bint4b13@gmail.com>
Subject: [PATCH v2] nfsd: avoid dereferencing callback connection after unlocking
Date: Mon, 28 Sep 2026 17:34:24 +0900
Message-ID: <20260928083424.642863-1-bint4b13@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd4_process_cb_update() takes a reference on c->cn_xprt while
holding clp->cl_lock, but retains the raw nfsd4_conn pointer after
dropping the lock. The svc_xprt reference keeps the transport alive;
it does not retain the enclosing nfsd4_conn.

Concurrent transport-loss handling can unlink and free the connection
through nfsd4_conn_lost(). If setup_callback_client() subsequently
fails, the original error path evaluates c->cn_xprt through the freed
connection in order to release the transport reference, resulting in
a use-after-free read.

Store c->cn_xprt in a separate local variable and take its reference
while clp->cl_lock still protects the connection. After dropping the
lock, use only the independently referenced transport for callback
setup and error cleanup. This avoids dereferencing nfsd4_conn outside
its protected lifetime.

The KASAN reproducer established two NFSv4.1 connections, selected a
backchannel connection, caused normal transport-loss handling to
release that connection, and injected one task-scoped allocation
failure during callback setup. setup_callback_client() returned
-ENOMEM after the connection had been released. With this patch
applied, the affected error path completed without the original KASAN
report.

The fault injection makes the callback-setup failure deterministic; it
does not demonstrate a reliable remote-only trigger. A source
reproducer and the complete KASAN log are available privately on
request.

Basic NFSv4.2 and NFSv3 read/write/unmount smoke tests also passed.
fs/nfsd/nfs4callback.o was additionally compile-tested with GCC 13.3
without new warnings.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: a4abc6b12eb1 ("nfsd: Fix svc_xprt refcnt leak when setup callback client failed")
Assisted-by: LLM
Signed-off-by: Jinpyo Lee <bint4b13@gmail.com>
---
Changes in v2:

- Expand the description of the lifetime bug and runtime validation.
- No code changes.

 fs/nfsd/nfs4callback.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a6b31d3f2..70ab4fd32 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1800,6 +1800,7 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	struct nfs4_client *clp = cb->cb_clp;
 	struct nfsd4_session *ses = NULL;
 	struct nfsd4_conn *c;
+	struct svc_xprt *cb_xprt = NULL;
 	int err;
 
 	trace_nfsd_cb_bc_update(clp, cb);
@@ -1833,8 +1834,9 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	memcpy(&conn, &cb->cb_clp->cl_cb_conn, sizeof(struct nfs4_cb_conn));
 	c = __nfsd4_find_backchannel(clp);
 	if (c) {
-		svc_xprt_get(c->cn_xprt);
-		conn.cb_xprt = c->cn_xprt;
+		cb_xprt = c->cn_xprt;
+		svc_xprt_get(cb_xprt);
+		conn.cb_xprt = cb_xprt;
 		ses = c->cn_session;
 	}
 	spin_unlock(&clp->cl_lock);
@@ -1842,8 +1844,8 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	err = setup_callback_client(clp, &conn, ses);
 	if (err) {
 		nfsd4_mark_cb_down(clp);
-		if (c)
-			svc_xprt_put(c->cn_xprt);
+		if (cb_xprt)
+			svc_xprt_put(cb_xprt);
 		rcu_assign_pointer(clp->cl_cb_session, ses);
 		return;
 	}
