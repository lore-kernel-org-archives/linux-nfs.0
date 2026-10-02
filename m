Received: from smtp-o-3.desy.de (smtp-o-3.desy.de [131.169.56.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 26ADB46A5E6
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 08:48:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=131.169.56.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790930891; cv=none; b=QXOrtOkuDAo0NnbZYNcrlZj4SrTkVFJnDEIPO2Hg7XkfFxyD0ALB93CvEW9N8bqggLhZMWcG79tf4R8A4Dr3ejJ4Yc9lmU12lG7so7rWlDcbIKlayH8naL4tAbg89dXHVexoqApdO0j9U+szvVaeZCzeMER0ujjOJGT/j0I3Zrc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790930891; c=relaxed/simple;
	bh=WSoeiCq+XAmTymIls8nTc+a0Hfi9krm4xwBco+cOXfw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=pdmo4Wf6eSu2JSLKoOWEB6lqeB+61CMT7bNtCRNs67J0hLrJB8dMH2hBRqNWbzYdryFZx/us3gKyHyxoXk+MAr810Ji6yhldiAVVkunoV2JreJc1qko7AhQmVefzR50b3Zp+6EPSuXGmvi5jbC3u+MrDXPm1NgbYcCi+NPQ0m24=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de; spf=pass smtp.mailfrom=desy.de; dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b=hGdb3jip; arc=none smtp.client-ip=131.169.56.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="hGdb3jip"
Received: from smtp-o-1.desy.de (smtp-o-1.desy.de [131.169.56.154])
	by smtp-o-3.desy.de (Postfix) with ESMTP id 262ED11F929
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 10:38:07 +0200 (CEST)
Received: from smtp-buf-1.desy.de (smtp-buf-1.desy.de [131.169.56.164])
	by smtp-o-1.desy.de (Postfix) with ESMTP id DAD3B11F744
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 10:37:58 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-1.desy.de DAD3B11F744
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1790930278; bh=MWyLPElypXjPF2qU/io0TA6EI6ZgvcOirtSTomJBeaw=;
	h=From:To:Cc:Subject:Date:From;
	b=hGdb3jipO/u/t9viR35b5vObZvwngXkOyQjTbE1xNhOM4SM7TDiN2CfbtMp7SIFzG
	 9owmWsIrJIh6+wTHM537Rgx6UUCLmj+UtdDV9u/6ArvA1TvqnmQ3514AAdo9BEXx5I
	 PIZQrQ8epDnseVA18yohBX6mjKZqEbeVEtQQdK5I=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [IPv6:2001:638:700:1038::1:82])
	by smtp-buf-1.desy.de (Postfix) with ESMTP id CDAAC20056;
	Fri,  2 Oct 2026 10:37:58 +0200 (CEST)
Received: from a1722.mx.srv.dfn.de (a1722.mx.srv.dfn.de [194.95.233.47])
	by smtp-m-2.desy.de (Postfix) with ESMTP id B8BD3160043;
	Fri,  2 Oct 2026 10:37:58 +0200 (CEST)
Received: from smtp-intra-2.desy.de (smtp-intra-2.desy.de [IPv6:2001:638:700:1038::1:53])
	by a1722.mx.srv.dfn.de (Postfix) with ESMTP id 291223200A2;
	Fri, 02 Oct 2026 10:37:58 +0200 (CEST)
Received: from z-prx-1.desy.de (z-prx-1.desy.de [131.169.10.28])
	by smtp-intra-2.desy.de (Postfix) with ESMTP id 11B8320044;
	Fri,  2 Oct 2026 10:37:58 +0200 (CEST)
Received: from localhost (localhost [IPv6:::1])
	by z-prx-1.desy.de (Postfix) with ESMTP id CBE0F200531;
	Fri,  2 Oct 2026 10:37:57 +0200 (CEST)
Received: from z-prx-1.desy.de ([IPv6:::1])
 by localhost (z-prx-1.desy.de [IPv6:::1]) (amavis, port 10026) with ESMTP
 id AvuJpbtKuEVl; Fri,  2 Oct 2026 10:37:57 +0200 (CEST)
Received: from nairi.fritz.box (unknown [IPv6:2001:638:700:e064::ba])
	by z-prx-1.desy.de (Postfix) with ESMTPSA id 66B5B20011A;
	Fri,  2 Oct 2026 10:37:56 +0200 (CEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs/flexfile: fix doc of nfs4_ff_layout_prepare_ds function
Date: Fri,  2 Oct 2026 10:37:48 +0200
Message-ID: <20261002083748.2615982-1-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

fix mismatch between function doc description and actual code
introduced in commit f06bedfa62d5 ("pNFS/flexfiles: don't attempt
pnfs on fatal DS errors")

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 5c0216bd5fce..4b443ceb2389 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -371,7 +371,7 @@ ff_layout_init_mirror_ds(struct pnfs_layout_hdr *lo,
  * mirror should result in a LAYOUTRETURN. @fail_return is how we distinguish
  * between the two cases.
  *
- * Returns a pointer to a connected DS object on success or NULL on failure.
+ * Returns a pointer to a connected DS object on success or an ERR_PTR value on failure.
  */
 struct nfs4_pnfs_ds *
 nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
-- 
2.55.0

