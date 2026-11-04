Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793791514;
	b=S0glNnHQOMSH3dvtDSsA8dqt7u2n4NNgi6+zRgZFoDMpK7gabz+8tosCe/I75GzdgVa0
	 DbwqZRjA+wK+F10L7XdXeWMk6MExLRfOtpGplGRUiBZ+nzaBgR2icAv6SRAjWGpxQPNh8
	 mOLzNASjyPgM7t1YshdEsup8c77OF14mVuRVKifULd1WiakXfkDBI/95UO7hCiOTRWdoM
	 8qgSnXuVLq4ebTWkmzRYGy3S/F52Wj6Wp/EW7N/AcEti3qjfMiYkVQOUao5Z5Zjjld7/l
	 YC1n2USLdPEkTWqQ5XU3gQu+KVDKdruMzDiOoaQAbCXXvjMh6zLcyGCDEk2pBGztRZg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793791514;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:MIME-Version:Content-Transfer-Encoding:X-Scanned-By;
	bh=1bmSYxpIghxtRs3ovTARDPUfWXAaKkg4sPK93IvfUvk=;
	b=5NUruFFPPbxluCOdeFGzIXKoXM+BebY9h1ViAbJmreCFun1R4CpePayB3vv9de4h108w
	 up1a/cRucIpgg1qNd+WmEPBQNDE36Xx+X5jmoF6LzSDekus9/ldnSFpXwT6N1Y/SrWfkl
	 QN5E7UZMCOP+sjZU6ED9jl092AjP1eSltJnAJlMweEMdJpxH1lWMR6mhEbz1ThrnXoiDU
	 jCt56k9PjqwACgOhqHegQbe614vJfGdAuBJFE0GMhUpAgXOQObVLx05RmVPR+Qf3hRfZa
	 YuzolefnG8J0E6Hqy0j9c9IH5+3gH5zlsXULwkd76mcXJsypp5eVd90zX3ieSoc70Ow==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=gQ0yLgbk;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FFCF606A31B
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 11:25:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0FFCF606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=gQ0yLgbk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1793791513;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=1bmSYxpIghxtRs3ovTARDPUfWXAaKkg4sPK93IvfUvk=;
	b=gQ0yLgbkrnKkq0V2FvW10YZbaSFL24D52iBKhJqpyLy6zvQ7JroXJ6Ohpz/F0717ssW8ed
	8NcMOuSyVT0As35pE3WSD1Mqqxkx+ChKo4Dd+IOdj/6xfmzUW8JUwBxkPOLM/7Xn8RkiE6
	BJEdw2Z1/59Vo0pJeyyulmJnB6ULBfI=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-125-qbXpg7_KONCK2U8GC3rqQg-1; Wed,
 04 Nov 2026 06:25:09 -0500
X-MC-Unique: qbXpg7_KONCK2U8GC3rqQg-1
X-Mimecast-MFC-AGG-ID: qbXpg7_KONCK2U8GC3rqQg_1793791508
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 610241955F10;
	Wed,  4 Nov 2026 11:25:08 +0000 (UTC)
Received: from rhel-developer-toolbox-latest.redhat.corp (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 949B4195608C;
	Wed,  4 Nov 2026 11:25:06 +0000 (UTC)
From: Roberto Bergantinos Corpas <rbergant@redhat.com>
To: trond.myklebust@hammerspace.com,
	anna.schumaker@hammerspace.com
Cc: linux-nfs@vger.kernel.org,
	snitzer@kernel.org,
	ben.coddington@hammerspace.com,
	antonio.feijoo@suse.com,
	tigran.mkrtchyan@desy.de
Subject: [PATCH] NFSv4/flexfiles: couple back with NFSv3
Date: Wed,  4 Nov 2026 12:25:05 +0100
Message-ID: <20261104112505.2495943-1-rbergant@redhat.com>
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
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Commit 7a375cafc14e ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS on
fatal DS connect errors") uncovered an unexpected issue, EPROTONOSUPPORT
from a missing nfsv3 module during pNFS flexfiles I/O operation turned a
harmless WARN + fallback to MDS into a forever retry op.

Flexfiles is decoupled from NFSv3 after commit a68c6fbb638a ("nfs41:
drop dependency between flexfiles layout driver and NFSv3 modules"),
so we trusted on legacy symbol_request(nfs3_set_ds_client) ->
request_module at runtime to load NFSv3 module in case it's not loaded.

However this approach has some problematic scenarios, an unprivileged
container may be denied by SELinux policy to load nfsv3 module, leading
to writeback hang, other scenario is boot hang on NFSv4 root mounted
hosts, where we get deadlocked trying to fetch from the filesystem the
usermode helpers necessary for request_module to proceed.

So, couple back NFSv3 with flexfiles to make sure both are loaded on i.e.
mount time, and remove the scaffolding associated with symbol_request()
mechanism now that we have a hard dependency on the code with
nfs3_set_ds_client.

Fixes: 7a375cafc14e ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS on fatal DS connect errors")
Based-on-patch-by: Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
Suggested-by: Benjamin Coddington <ben.coddington@hammerspace.com>
Assisted-by: Claude Opus 4.6 <noreply@anthropic.com>
Signed-off-by: Roberto Bergantinos Corpas <rbergant@redhat.com>
---
 fs/nfs/Kconfig     |  2 +-
 fs/nfs/nfs4super.c |  3 ---
 fs/nfs/pnfs.h      |  5 -----
 fs/nfs/pnfs_nfs.c  | 34 ++--------------------------------
 4 files changed, 3 insertions(+), 41 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index fd430718d02b..b693f573c2ba 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -143,7 +143,7 @@ config PNFS_SCSI_LAYOUT
 
 config PNFS_FLEXFILE_LAYOUT
 	tristate
-	depends on NFS_V4
+	depends on NFS_V4 && NFS_V3
 	default NFS_V4
 
 config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 9c5895b551a1..f142e29a816c 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -297,9 +297,6 @@ static int __init init_nfs_v4(void)
 
 static void __exit exit_nfs_v4(void)
 {
-	/* Not called in the _init(), conditionally loaded */
-	nfs4_pnfs_v3_ds_connect_unload();
-
 	unregister_nfs_version(&nfs_v4);
 #ifdef CONFIG_NFS_V4_2
 	nfs4_xattr_cache_exit();
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 2774d4adf4c3..e5a8547e050e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -504,7 +504,6 @@ void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds);
 struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(const struct net *net,
 				      struct list_head *dsaddrs,
 				      u32 version, gfp_t gfp_flags);
-void nfs4_pnfs_v3_ds_connect_unload(void);
 int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
 			  unsigned int retrans, unsigned int nconnect,
@@ -972,10 +971,6 @@ static inline struct nfs4_threshold *pnfs_mdsthreshold_alloc(void)
 	return NULL;
 }
 
-static inline void nfs4_pnfs_v3_ds_connect_unload(void)
-{
-}
-
 static inline bool nfs4_layout_refresh_old_stateid(nfs4_stateid *dst,
 		struct pnfs_layout_range *dst_range,
 		struct inode *inode)
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 7adb6f941cf2..7775ee6d087c 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -838,33 +838,6 @@ static void nfs4_clear_ds_conn_bit(struct nfs4_pnfs_ds *ds)
 	clear_and_wake_up_bit(NFS4DS_CONNECTING, &ds->ds_state);
 }
 
-static struct nfs_client *(*get_v3_ds_connect)(
-			struct nfs_server *mds_srv,
-			const struct sockaddr_storage *ds_addr,
-			int ds_addrlen,
-			int ds_proto,
-			unsigned int ds_timeo,
-			unsigned int ds_retrans,
-			unsigned int ds_nconnect);
-
-static bool load_v3_ds_connect(void)
-{
-	if (!get_v3_ds_connect) {
-		get_v3_ds_connect = symbol_request(nfs3_set_ds_client);
-		WARN_ON_ONCE(!get_v3_ds_connect);
-	}
-
-	return(get_v3_ds_connect != NULL);
-}
-
-void nfs4_pnfs_v3_ds_connect_unload(void)
-{
-	if (get_v3_ds_connect) {
-		symbol_put(nfs3_set_ds_client);
-		get_v3_ds_connect = NULL;
-	}
-}
-
 static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
 				 unsigned int timeo,
@@ -881,9 +854,6 @@ static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 
 	dprintk("--> %s DS %s\n", __func__, ds->ds_remotestr);
 
-	if (!load_v3_ds_connect())
-		return -EPROTONOSUPPORT;
-
 	list_for_each_entry(da, &ds->ds_addrs, da_node) {
 		dprintk("%s: DS %s: trying address %s\n",
 			__func__, ds->ds_remotestr, da->da_remotestr);
@@ -920,8 +890,8 @@ static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 		    xprtsec_policy != RPC_XPRTSEC_NONE)
 			ds_proto = XPRT_TRANSPORT_TCP_TLS;
 
-		clp = get_v3_ds_connect(mds_srv, &da->da_addr, da->da_addrlen,
-					ds_proto, timeo, retrans, nconnect);
+		clp = nfs3_set_ds_client(mds_srv, &da->da_addr, da->da_addrlen,
+					 ds_proto, timeo, retrans, nconnect);
 		if (IS_ERR(clp))
 			continue;
 		clp->cl_rpcclient->cl_softerr = 0;
-- 
2.55.0

