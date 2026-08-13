Received: from mail-oi1-f178.google.com (mail-oi1-f178.google.com [209.85.167.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 39E6E42C508
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653833; cv=none; b=TYvMuVeEEXvG+aWWv+qRXe89uGl1ahKqn/vUwP+3rEIuWqJIPV+zFqZwRGyO+ldxlwVqS0Uu7carP9qNRU74N/5hPBXM9qxHHFrkrpenaZXPniOh21Esay6GEbU5lENbFrWfBLb5680zWxGsoRROgQ9mKloL8DsngavqNNvK0SA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653833; c=relaxed/simple;
	bh=PN7PJDWYupwlWss/qHNYRORK/E+aePky283/lreTbyk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LetOGJa13xKHCzrcVKH8G12oLYh86OcOxs7rgTEcdCekZIccyaZ4BAjxcYiwTQr45XSrfaiedw6crsChzxf3PKpGvirgJgCjfHOSmHSNr+eykJRuKsdc9qQp4lX6LkNNveFBjaH1beTR8uQv07ialVD1hHv0INRI0r798ZOyEBY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=Fm+0o23U; arc=none smtp.client-ip=209.85.167.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Fm+0o23U"
Received: by mail-oi1-f178.google.com with SMTP id 5614622812f47-4af7283bf83so111277b6e.3
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653831; x=1787258631; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=JtNguqgysfEo2N+UVtkwESaYEdU4YDOEP3f8AXh8qiw=;
        b=Fm+0o23UzxP52CDi5ag/xGvRtneeAtHcWXFvAGHBKZc2BZSrbdhIUzWlXf14SJs9BY
         K5jIzNbfxlG35QfnIvuXI1aLFDEeV/Exd5j3v1cQJsTve23gXelA988ml8gCwFT5LRqv
         zTdi/BGwZZjVdMqCmNP+fVnC/UnlUjMgH3v03S0X0Da8zaduqNcZrfPHL1NDM+oY6CaU
         0LLMjnrbOXO2/6QnmON5dEx2Tox/jhYCu4aKA/yN8aWgu4GC91Epef/O2uJCHANBapME
         mQpQIkYVOwSBMk8lmEdD2TK0ZPcwk3WJLgYXU5bXnCLz/xbcdIW6UUwHULBo2CG4xaXR
         LATA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653831; x=1787258631;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=JtNguqgysfEo2N+UVtkwESaYEdU4YDOEP3f8AXh8qiw=;
        b=sHXYzVjRIwbXipGzrpBhsuJS8Zhf+PCzuL+41mtJyK6ADbC9YMruLgWzzFAZpWBtPD
         3WHHfjyxEvCt60yWws4JOzF80iFpGHSpZpVrLIF0HEzwTGLnLQhNtkUhwLx2Hi9oOe8k
         yMDsAJJanNauZluL7xN/cebUzrPRL9gvAhUGyue/jZurcxZ1Z2S1p9zt8BMZHOqmMUre
         uU93D0kpWPlgyFDQcwmJmMkKI9po4DhcvzvR6/qGGRizBw+ucUB3fXM0aZYOJ2bY0XP1
         ctZSv0VmGaAJTGlO3NPx1P7Y4m0BOxkY741rfc/VecX2yUtTXZginzXdjVioGa4IcTZR
         Hnkg==
X-Gm-Message-State: AOJu0YzQXaMUu8OMf3H5cPyy23CGlw0OMwGtI9SJH2iIr4wh0v7gwX0u
	vh8u6cfazaiJvixMaXJaQe9wZ5p1Lc3fjBQZfmqqvMNZEoh09zqoaFzqXY+qm5h03GE=
X-Gm-Gg: AR+sD11MfjdxYf43PP5/64WjJjBMxCw2GGMY25uvI2L3/fbutltExE3FZphU5Yy3MRu
	Z3DC/f7ph0uwtSL5hzBxhXVR6FUzMRSwlqz908Dzz0ku+dZOdTbKrHUaEIKYxVfPF7LbGZ/DLYJ
	kHlUbum802NZMmvg7fpnfj+WxT55Tb/a1b1liRgzJxhDs98oF5tsrixAO8u5HU7yTsyMAQCo/6S
	HdIoeABPWM17Ju2ibzv0H0ufBxGv/MOUh95M40ZAwdg5/MmSuy7pxAVL2ruS8RcJjgIA/P/TlBH
	vEof9SClELxptzbo6cqBlAgydsIds4NY108Y3Ft5Z6JVUIa97OHDokHXXpKJcgmacPcdCwDjngX
	vZFmeQKMjivLCYLiAgonVPZz29hRkuyRQrr9/3V5vlYvxBOptNgu4+8xo7s3A014h5U+kVULdgC
	PUOXd44CPK+g64E8JtnG+aKTk3+cahTqv2feOoBncg0x+4NO44NHDyFmHmtTZHeX0LylX5tjRjh
	4T1lJZ5ByI361OicsHLuUJ3
X-Received: by 2002:a05:6808:10d5:b0:493:a860:5809 with SMTP id 5614622812f47-4b240f9b0admr723484b6e.4.1786653831019;
        Thu, 13 Aug 2026 13:43:51 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:49 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 21/21] NFSv4/flexfiles: Add a dataserver_nconnect cap
Date: Thu, 13 Aug 2026 16:43:17 -0400
Message-ID: <1ee15f2bd1099ddace5e2baaa0d5bb31b8c4908c.1786653063.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653063.git.bcodding@hammerspace.com>
References: <cover.1786653063.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Data-server clients inherit the MDS nconnect setting.  A striping
mount multiplies that by every distinct data server: at ~1000 DSes
and nconnect=16 the client opens ~16k sockets plus their sunrpc slot
tables, and striping already spreads I/O across the data servers, so
a high per-DS transport count buys little for that workload.

Add a dataserver_nconnect module parameter to the flexfiles layout
driver alongside its existing dataserver_timeo and dataserver_retrans
knobs, and thread the value through nfs4_pnfs_ds_connect() to both
the v3 and v4 data-server client setup paths.  The default of 0
preserves today's inherit-from-MDS behavior, so the cap is opt-in
and non-regressing.  The files layout passes 0, unchanged.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/filelayout/filelayoutdev.c         |  2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  7 +++++++
 fs/nfs/internal.h                         |  3 ++-
 fs/nfs/nfs3client.c                       |  9 +++++++--
 fs/nfs/nfs4client.c                       |  5 ++++-
 fs/nfs/pnfs.h                             |  3 ++-
 fs/nfs/pnfs_nfs.c                         | 20 +++++++++++++-------
 7 files changed, 36 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 7226989ee4d5..35c7bcfaa773 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -279,7 +279,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 		goto out_test_devid;
 
 	status = nfs4_pnfs_ds_connect(s, ds, devid, dataserver_timeo,
-			     dataserver_retrans, 4,
+			     dataserver_retrans, 0, 4,
 			     s->nfs_client->cl_minorversion);
 	if (status) {
 		nfs4_mark_deviceid_unavailable(devid);
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 4ab55f0874d5..a870c9303bf8 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -20,6 +20,7 @@
 
 static unsigned int dataserver_timeo = NFS_DEF_TCP_TIMEO;
 static unsigned int dataserver_retrans;
+static unsigned int dataserver_nconnect;
 
 static bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg);
 
@@ -439,6 +440,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 	 */
 	status = nfs4_pnfs_ds_connect(s, ds, &mirror_ds->id_node,
 			     dataserver_timeo, dataserver_retrans,
+			     dataserver_nconnect,
 			     mirror_ds->ds_versions[0].version,
 			     mirror_ds->ds_versions[0].minor_version);
 
@@ -696,3 +698,8 @@ module_param(dataserver_timeo, uint, 0644);
 MODULE_PARM_DESC(dataserver_timeo, "The time (in tenths of a second) the "
 			"NFSv4.1  client  waits for a response from a "
 			" data server before it retries an NFS request.");
+module_param(dataserver_nconnect, uint, 0644);
+MODULE_PARM_DESC(dataserver_nconnect, "The maximum number of connections "
+			"the NFSv4.1 client opens to each data server, "
+			"capping the value inherited from the MDS nconnect "
+			"mount option.  0 (default) applies no cap.");
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index e4533f583632..21007ac2eb0a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -250,6 +250,7 @@ extern struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 					     int ds_addrlen, int ds_proto,
 					     unsigned int ds_timeo,
 					     unsigned int ds_retrans,
+					     unsigned int ds_nconnect,
 					     u32 minor_version);
 extern struct rpc_clnt *nfs4_find_or_create_ds_client(struct nfs_client *,
 						struct inode *);
@@ -258,7 +259,7 @@ extern void nfs4_session_limit_xasize(struct nfs_server *server);
 extern struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 			const struct sockaddr_storage *ds_addr, int ds_addrlen,
 			int ds_proto, unsigned int ds_timeo,
-			unsigned int ds_retrans);
+			unsigned int ds_retrans, unsigned int ds_nconnect);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index 5d97c1d38bb6..cf2f7be4b435 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -84,7 +84,8 @@ struct nfs_server *nfs3_clone_server(struct nfs_server *source,
  */
 struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 		const struct sockaddr_storage *ds_addr, int ds_addrlen,
-		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans)
+		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
+		unsigned int ds_nconnect)
 {
 	struct rpc_timeout ds_timeout;
 	unsigned long connect_timeout = ds_timeo * (ds_retrans + 1) * HZ / 10;
@@ -124,8 +125,12 @@ struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 		fallthrough;
 	case XPRT_TRANSPORT_RDMA:
 	case XPRT_TRANSPORT_TCP:
-		if (mds_clp->cl_nconnect > 1)
+		if (mds_clp->cl_nconnect > 1) {
 			cl_init.nconnect = mds_clp->cl_nconnect;
+			if (ds_nconnect)
+				cl_init.nconnect = min(cl_init.nconnect,
+						       ds_nconnect);
+		}
 	}
 
 	if (mds_srv->flags & NFS_MOUNT_NORESVPORT)
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 6a2f7522179c..56a2a9c57cb2 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -793,7 +793,7 @@ static int nfs4_set_client(struct nfs_server *server,
 struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 		const struct sockaddr_storage *ds_addr, int ds_addrlen,
 		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
-		u32 minor_version)
+		unsigned int ds_nconnect, u32 minor_version)
 {
 	struct rpc_timeout ds_timeout;
 	struct nfs_client *mds_clp = mds_srv->nfs_client;
@@ -831,6 +831,9 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 	case XPRT_TRANSPORT_TCP:
 		if (mds_clp->cl_nconnect > 1) {
 			cl_init.nconnect = mds_clp->cl_nconnect;
+			if (ds_nconnect)
+				cl_init.nconnect = min(cl_init.nconnect,
+						       ds_nconnect);
 			cl_init.max_connect = NFS_MAX_TRANSPORTS;
 		}
 	}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e0a7ae5fe8e9..0ae5329afdab 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -497,7 +497,8 @@ struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(const struct net *net,
 void nfs4_pnfs_v3_ds_connect_unload(void);
 int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
-			  unsigned int retrans, u32 version, u32 minor_version);
+			  unsigned int retrans, unsigned int nconnect,
+			  u32 version, u32 minor_version);
 struct nfs4_pnfs_ds_addr *nfs4_decode_mp_ds_addr(struct net *net,
 						 struct xdr_stream *xdr,
 						 gfp_t gfp_flags);
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index a94f4a2933cd..4740d41ef1c5 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -842,7 +842,8 @@ static struct nfs_client *(*get_v3_ds_connect)(
 			int ds_addrlen,
 			int ds_proto,
 			unsigned int ds_timeo,
-			unsigned int ds_retrans);
+			unsigned int ds_retrans,
+			unsigned int ds_nconnect);
 
 static bool load_v3_ds_connect(void)
 {
@@ -865,7 +866,8 @@ void nfs4_pnfs_v3_ds_connect_unload(void)
 static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
 				 unsigned int timeo,
-				 unsigned int retrans)
+				 unsigned int retrans,
+				 unsigned int nconnect)
 {
 	struct nfs_client *clp = ERR_PTR(-EIO);
 	struct nfs_client *mds_clp = mds_srv->nfs_client;
@@ -917,7 +919,7 @@ static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 			ds_proto = XPRT_TRANSPORT_TCP_TLS;
 
 		clp = get_v3_ds_connect(mds_srv, &da->da_addr, da->da_addrlen,
-					ds_proto, timeo, retrans);
+					ds_proto, timeo, retrans, nconnect);
 		if (IS_ERR(clp))
 			continue;
 		clp->cl_rpcclient->cl_softerr = 0;
@@ -940,6 +942,7 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
 				 unsigned int timeo,
 				 unsigned int retrans,
+				 unsigned int nconnect,
 				 u32 minor_version)
 {
 	struct nfs_client *clp = ERR_PTR(-EIO);
@@ -1030,7 +1033,8 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 
 			clp = nfs4_set_ds_client(mds_srv, &da->da_addr,
 						 da->da_addrlen, ds_proto,
-						 timeo, retrans, minor_version);
+						 timeo, retrans, nconnect,
+						 minor_version);
 			if (IS_ERR(clp))
 				continue;
 
@@ -1063,7 +1067,8 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
  */
 int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
-			  unsigned int retrans, u32 version, u32 minor_version)
+			  unsigned int retrans, unsigned int nconnect,
+			  u32 version, u32 minor_version)
 {
 	int err;
 
@@ -1082,11 +1087,12 @@ int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 
 	switch (version) {
 	case 3:
-		err = _nfs4_pnfs_v3_ds_connect(mds_srv, ds, timeo, retrans);
+		err = _nfs4_pnfs_v3_ds_connect(mds_srv, ds, timeo, retrans,
+					       nconnect);
 		break;
 	case 4:
 		err = _nfs4_pnfs_v4_ds_connect(mds_srv, ds, timeo, retrans,
-					       minor_version);
+					       nconnect, minor_version);
 		break;
 	default:
 		dprintk("%s: unsupported DS version %d\n", __func__, version);
-- 
2.53.0

