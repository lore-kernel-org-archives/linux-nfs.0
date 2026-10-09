Received: from smtp-o-3.desy.de (smtp-o-3.desy.de [131.169.56.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44FD928315D
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 16:08:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=131.169.56.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791562086; cv=none; b=d1/q2SbZ+GYbOpekaLw6IUDvj4CC5fYVUe4G3nJhfflUHhFbKHZw+CoKDYrEFgYRps0+5vTNWCAb4IvSu7nq9+IA1frlwvhkcM8nIfzZ1vFOKb6zTKBZDRa278MfFwv8xIJKnXT85nBWK2rBMSWcRCWRRJYH89Lfxcp/XmEqUYg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791562086; c=relaxed/simple;
	bh=tlz5nIBIhP+Y1aLogE1qaRM0lYJpT86+jsYW9y+zKD8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=JIDAfPbGWBdeiSxstF13PNR6D9FvQZwvAAQkQVoPLVhIlyULAva2hqJXfjldb29BDSKiHmbSUV3t9u/6vyLqmeCBB2vvD7q+RfbRXWlb9C9G2W5hxPXB9KLdxvjrUybXM4CWdPn/ytaxbDTbeykh26FDkXNtTPF4Rbi2Mu6wglw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de; spf=pass smtp.mailfrom=desy.de; dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b=q1QQ8D96; arc=none smtp.client-ip=131.169.56.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="q1QQ8D96"
Received: from smtp-o-2.desy.de (smtp-o-2.desy.de [131.169.56.155])
	by smtp-o-3.desy.de (Postfix) with ESMTP id B8E7411F81A
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 17:58:16 +0200 (CEST)
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [131.169.56.166])
	by smtp-o-2.desy.de (Postfix) with ESMTP id 7BA2413F653
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 17:58:09 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-2.desy.de 7BA2413F653
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1791561489; bh=xepcV98LoUS2Gtqnt3owlva8yAhUE+wWWyZ0xKkgmG8=;
	h=From:To:Cc:Subject:Date:From;
	b=q1QQ8D96RH7o8/nkziEoKICTvFTceAAnbVDevnzsMWdSX53OuWlOBOB+Z1Qa2WIVT
	 mwY4qeSvNpwLdcpHuNdv2YjMFY8i1a9cMX5VYIEPlifgnAsP/DRxFeg38HQDKn73os
	 DZE71ESr+FsYDik2HahL2ahLd0H5vvPEiHN9szcI=
Received: from smtp-m-3.desy.de (smtp-m-3.desy.de [131.169.56.131])
	by smtp-buf-3.desy.de (Postfix) with ESMTP id 6E7D9C0040;
	Fri,  9 Oct 2026 17:58:09 +0200 (CEST)
Received: from b1722.mx.srv.dfn.de (b1722.mx.srv.dfn.de [IPv6:2001:638:d:c302:acdc:1979:2:e7])
	by smtp-m-3.desy.de (Postfix) with ESMTP id 61F481A004F;
	Fri,  9 Oct 2026 17:58:09 +0200 (CEST)
Received: from smtp-intra-2.desy.de (smtp-intra-2.desy.de [IPv6:2001:638:700:1038::1:53])
	by b1722.mx.srv.dfn.de (Postfix) with ESMTP id D2A97160059;
	Fri, 09 Oct 2026 17:58:07 +0200 (CEST)
Received: from z-prx-2.desy.de (z-prx-2.desy.de [131.169.10.29])
	by smtp-intra-2.desy.de (Postfix) with ESMTP id B94A320044;
	Fri,  9 Oct 2026 17:58:07 +0200 (CEST)
Received: from localhost (localhost [IPv6:::1])
	by z-prx-2.desy.de (Postfix) with ESMTP id B05866053A;
	Fri,  9 Oct 2026 17:58:07 +0200 (CEST)
Received: from z-prx-2.desy.de ([IPv6:::1])
 by localhost (z-prx-2.desy.de [IPv6:::1]) (amavis, port 10026) with ESMTP
 id cj9CSzYe4Xka; Fri,  9 Oct 2026 17:58:07 +0200 (CEST)
Received: from nairi.desy.de (VPN0062.desy.de [131.169.253.61])
	by z-prx-2.desy.de (Postfix) with ESMTPSA id 6C49B60005;
	Fri,  9 Oct 2026 17:58:05 +0200 (CEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: trondmy@kernel.org,
	chuck.lever@oracle.com,
	jlayton@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfsv4/pnfs: use the MDS authflavor for data server connections
Date: Fri,  9 Oct 2026 17:58:02 +0200
Message-ID: <20261009155802.540179-1-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.56.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a pNFS client connects to an NFSv4.1 data server, the EXCHANGE_ID
is always attempted with RPCSEC_GSS krb5i first, even if the auth flavor
with the MDS is AUTH_SYS. On a host that runs rpc.gssd but has no usable
machine credential, every first contact with a data server therefore
upcalls to rpc.gssd before falling back to AUTH_SYS.

As nfs4_discover_server_trunking is serialized by nfs_clid_init_mutex
such an extra upcall creates a backlog of DS connections when many files
accessed in parallel.

Pass the authflavor of the MDS lease to nfs4_alloc_client() and skip
the krb5i attempt if the MDS already ended up with AUTH_SYS. Nothing
changes for the MDS itself, or for data servers of an MDS whose lease
was established with krb5i.

Fixes: 4edaa308888b ("NFS: Use "krb5i" to establish NFSv4 state whenever possible")
Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/internal.h   | 1 +
 fs/nfs/nfs4client.c | 7 ++++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index abc81f5ae578..1894c17af091 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -86,6 +86,7 @@ struct nfs_client_initdata {
 	struct xprtsec_parms xprtsec;
 	unsigned long connect_timeout;
 	unsigned long reconnect_timeout;
+	rpc_authflavor_t authflavor;		/* Auth flavor to use for DS connection */
 };
 
 /*
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b661f446ea49..e7b379f4b4d4 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -229,8 +229,12 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
 	/*
 	 * Set up the connection to the server before we add add to the
 	 * global list.
+	 *
+	 * Prefer krb5i unless the caller already knows AUTH_UNIX is required.
 	 */
-	err = nfs_create_rpc_client(clp, cl_init, RPC_AUTH_GSS_KRB5I);
+	err = -EINVAL;
+	if (cl_init->authflavor != RPC_AUTH_UNIX)
+		err = nfs_create_rpc_client(clp, cl_init, RPC_AUTH_GSS_KRB5I);
 	if (err == -EINVAL)
 		err = nfs_create_rpc_client(clp, cl_init, RPC_AUTH_UNIX);
 	if (err < 0)
@@ -812,6 +816,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 			.cert_serial = TLS_NO_CERT,
 			.privkey_serial = TLS_NO_PRIVKEY,
 		},
+		.authflavor = mds_clp->cl_rpcclient->cl_auth->au_flavor,
 	};
 	char buf[INET6_ADDRSTRLEN + 1];
 
-- 
2.56.0

