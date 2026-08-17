Received: from oss.cyber.gouv.fr (oss.cyber.gouv.fr [51.159.188.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FAEC369D6D;
	Mon, 17 Aug 2026 21:16:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=51.159.188.251
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787001391; cv=none; b=r4FI0w6z5eaRuEhCRRc063uwUt6cPr11iYAIdgxNCzY7yHS/UqB1pDdDsEl9NAQHFrMpNu2sm7uvziDRpDBeEKAzZgPpdPALR98n1Ls7vWfYmxNKVfRlbnMkvIfSWo0vhlBZWLlxV26AcfD5/nHwOIYCWCYTKpOz/ROLWWYwqhM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787001391; c=relaxed/simple;
	bh=C7lQ7pmctxw0Dcae860NfoZ0kl78IyJ0q4hcci4CdzI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=UA1mG4Cz+Lrkr3haD4hCt7JWvtQu0p8MmkcsnnySrAMEaFFQtFJ62+8CnoPjK1jcs+arFG6BOzKj3MVqdwZhQte3gl4OsC4cDbMpAG0Zw3qAQ7hLrzh7r4DpVKosWyfv8sI9uV/QvC89RmzLr/kxc/hkx2nFQjC2pOvqCarl3hs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr; spf=pass smtp.mailfrom=oss.cyber.gouv.fr; dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b=DhdH2//4; arc=none smtp.client-ip=51.159.188.251
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b="DhdH2//4"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=oss.cyber.gouv.fr; s=default; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=FS3RtaKNSE7wZ7ObnXwm7ADmCEXLc36dZMwlnyXeo/M=; b=DhdH2//4XkqccUP+eeGQmTs03z
	5lgFj80zO6ywOKXSJJE49dFGlNdyOt4Zmd40uFmiSOeYWQNimTzTn59PMl1eP1tduu234E0e7G2Sw
	F2/OO/5z4Gr4bhtkEfBTPuQYnAnTU8/mkAHLNUCmzLe4D9A0NzZb6Wg1sQkLupXetW6XqBdI6SCjw
	yfd9ks0KW8SGBxCp2PhTc1EY0PpPeUJbaT206UEe7DgqHOoUD4VrHyTKa1tXYEjy59+pYvLnoBlhG
	7cTloMT+91OzVZz3E1dd+4xhQfqtJoruhUj8vVXMmxKbYK+e1Kj2zPUiO2FIuTsjBo0DcO8lGyY3V
	sOgRZ+kA==;
Received: from [151.115.150.205] (port=47636 helo=gepetto..)
	by pf-012.whm.fr-par.scw.cloud with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.99.5)
	(envelope-from <Jeremy.Jean@oss.cyber.gouv.fr>)
	id 1ww4h2-0000000DAG5-2Go2;
	Mon, 17 Aug 2026 23:16:28 +0200
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
To: linux-nfs@vger.kernel.org
Cc: trondmy@kernel.org,
	anna@kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
Subject: [PATCH] NFSv4.1: initialize referring call pointers before decoding
Date: Mon, 17 Aug 2026 21:16:00 +0000
Message-ID: <20260817211600.1651876-2-Jeremy.Jean@oss.cyber.gouv.fr>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - pf-012.whm.fr-par.scw.cloud
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - oss.cyber.gouv.fr
X-Get-Message-Sender-Via: pf-012.whm.fr-par.scw.cloud: authenticated_id: jeremy.jean@oss.cyber.gouv.fr
X-Authenticated-Sender: pf-012.whm.fr-par.scw.cloud: jeremy.jean@oss.cyber.gouv.fr
X-Source: 
X-Source-Args: 
X-Source-Dir: 

decode_cb_sequence_args() allocates csa_rclists with kmalloc_objs(), so
each referring_call_list starts uninitialized. decode_rc_list() assigns
rcl_refcalls only when rcl_nrefcalls is nonzero. A valid list with zero
referring calls therefore leaves the pointer uninitialized, and
nfs4_callback_sequence() later passes it to kfree(). KASAN reports a
double free in nfs_cb_sequence_empty_refcalls_test().

Initialize the pointer before decoding the list.

Fixes: 4aece6a19cf7 ("nfs41: cb_sequence xdr implementation")
Assisted-by: Codex:gpt-5
Signed-off-by: Jérémy Jean <Jeremy.Jean@oss.cyber.gouv.fr>
---
 fs/nfs/callback_xdr.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 4382baddc9ee..5857f57f0644 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -360,6 +360,7 @@ static __be32 decode_rc_list(struct xdr_stream *xdr,
 	int i;
 	__be32 status;
 
+	rc_list->rcl_refcalls = NULL;
 	status = decode_sessionid(xdr, &rc_list->rcl_sessionid);
 	if (status)
 		goto out;
-- 
2.47.3
