Received: from smtp-o-2.desy.de (smtp-o-2.desy.de [131.169.56.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6082356767
	for <linux-nfs@vger.kernel.org>; Sat, 10 Oct 2026 22:19:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=131.169.56.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791670757; cv=none; b=YkGQIOgSK6JMhxm9LjvrMr0H9N49xuaW6zqXYq3Nn68wwbQovr0kk28oY3k1CYLVdQ/w3IOBN6xaTgZT4yfBFRngOiRhUPp4eGctlVYw/2degO2HyAa8P2CdnXtWAE1QKXK5IkjXiML2vhcuqS62gB+f/WlFSseR2e7bCz4HJSg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791670757; c=relaxed/simple;
	bh=ELJBnY3bmlspsbCulQ1mC/IoFAhcZfPvACrb/exef7E=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dgHseMkUAOYeVjuwknLDbYHRi2AB72pGxYWIsKxnHZNwDxP4Y/I51dwUq37JF87elbfSgLO7I4fwQhfKFUo1aY+J93dlv5TJ9tA3Aa3C6ILQoxej9U8Wgoe/YhMQm/Gpy7h4digjoKIcfxdI+jEb8G/kpPz1rZ7lKA3/IHA52Zs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de; spf=pass smtp.mailfrom=desy.de; dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b=V9VGNkLP; arc=none smtp.client-ip=131.169.56.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="V9VGNkLP"
Received: from smtp-buf-2.desy.de (smtp-buf-2.desy.de [131.169.56.165])
	by smtp-o-2.desy.de (Postfix) with ESMTP id 13D1013F648
	for <linux-nfs@vger.kernel.org>; Sun, 11 Oct 2026 00:19:07 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-2.desy.de 13D1013F648
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1791670747; bh=LVo/RC4VyefOdk1BJ8qD7lEGjbqZ7kngWQlLqdlwQS8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=V9VGNkLPyp5euZ5yt0ae95ZtzbonwWkMT+BVY+Cyx7u4V/Wbl4cw7vSvrPtulsf8Z
	 +l42TlnfS7dfJ5y+4k8pSk/mEmcw9xkCJCEm+8jE0hYBqbgh+5fcm5vGbxCi71g9X0
	 TOJzN7/mbbcGRJwBCm99Q9pHo3dLj23K6JhYMTXE=
Received: from smtp-m-1.desy.de (smtp-m-1.desy.de [IPv6:2001:638:700:1038::1:81])
	by smtp-buf-2.desy.de (Postfix) with ESMTP id 08287120043;
	Sun, 11 Oct 2026 00:19:07 +0200 (CEST)
Received: from c1722.mx.srv.dfn.de (c1722.mx.srv.dfn.de [IPv6:2001:638:d:c303:acdc:1979:2:e7])
	by smtp-m-1.desy.de (Postfix) with ESMTP id EF58840045;
	Sun, 11 Oct 2026 00:19:06 +0200 (CEST)
Received: from smtp-intra-1.desy.de (smtp-intra-1.desy.de [131.169.56.82])
	by c1722.mx.srv.dfn.de (Postfix) with ESMTP id 39B72100034;
	Sun, 11 Oct 2026 00:19:06 +0200 (CEST)
Received: from z-prx-2.desy.de (z-prx-2.desy.de [131.169.10.29])
	by smtp-intra-1.desy.de (Postfix) with ESMTP id 25D6E80046;
	Sun, 11 Oct 2026 00:19:06 +0200 (CEST)
Received: from localhost (localhost [IPv6:::1])
	by z-prx-2.desy.de (Postfix) with ESMTP id 1E9966053A;
	Sun, 11 Oct 2026 00:19:06 +0200 (CEST)
Received: from z-prx-2.desy.de ([IPv6:::1])
 by localhost (z-prx-2.desy.de [IPv6:::1]) (amavis, port 10026) with ESMTP
 id 2SO5JbSZfIGV; Sun, 11 Oct 2026 00:19:06 +0200 (CEST)
Received: from nairi.desy.de (VPN0276.desy.de [131.169.254.21])
	by z-prx-2.desy.de (Postfix) with ESMTPSA id 5AA2760005;
	Sun, 11 Oct 2026 00:19:04 +0200 (CEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	snitzer@kernel.org,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 2/2] pNFS/flexfiles: don't report an interrupted DS connect as a DS error
Date: Sun, 11 Oct 2026 00:18:39 +0200
Message-ID: <20261010221839.42172-3-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261010221839.42172-1-tigran.mkrtchyan@desy.de>
References: <20261010221839.42172-1-tigran.mkrtchyan@desy.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

If nfs4_pnfs_ds_connect() is interrupted by a signal,
nfs4_ff_layout_prepare_ds() records an NFS4ERR_NXIO error for the data
server, sends a LAYOUTERROR to the MDS and may mark the layout for
return. The data server is healthy in this case; only the calling task
was killed.

A bpftrace log of a killed task shows the connect failing with
-ERESTARTSYS, followed by a LAYOUTERROR for a data server that completed
the TCP handshake with the same client microseconds later (time in
microseconds, abridged):

  python3 rpc_create (ret)      1xx.yy.50.179:24009 err=-512
  kworker inet_sock_set_state   :735 -> 1xx.yy.50.179:24009 CLOSE -> SYN_SENT
  swapper inet_sock_set_state   :735 -> 1xx.yy.50.179:24009 SYN_SENT -> ESTABLISHED
  kworker inet_sock_set_state   :735 -> 1xx.yy.50.179:24009 ESTABLISHED -> FIN_WAIT1

  python3 nfs4_pnfs_ds_connect (ret) status=-512
  python3 nfs4_ff_layout_prepare_ds (ret) err=-512
  kworker rpc_request               nfs v4 LAYOUTERROR async task=3/6752
  kworker rpc_stats_latency         LAYOUTERROR backlog=66us rtt=315us exec=421us

Return the error to the caller without reporting a DS failure when the
connect ended with -ERESTARTSYS or -EINTR.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 4b443ceb2389..d4509060eef3 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -420,6 +420,11 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 			mirror->dss[dss_id].mirror_ds->ds_versions[0].wsize = max_payload;
 		goto out;
 	}
+	/* The connect was interrupted by a signal: this is not a DS error */
+	if (status == -ERESTARTSYS || status == -EINTR) {
+		ds = ERR_PTR(status);
+		goto out;
+	}
 noconnect:
 	ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
 				 mirror, dss_id, lseg->pls_range.offset,
-- 
2.56.0

