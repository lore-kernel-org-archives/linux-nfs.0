Received: from mail-oi1-f179.google.com (mail-oi1-f179.google.com [209.85.167.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C4CC493643
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:30:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.179
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329803; cv=none; b=A0VRY8TrCg2c+wHO1nEYv3tde7+01vS4UyU+J8rmQh2YY5U5bX9Kds1sW/gcZj10PoBh/UkOAcJrd7VJ+eHdndjxdI1HO2amjIjmtkfArSKpzhG7vMd0YuJVOaKBHcJew7mwVH5Zn8lREoX/a1EirFt0XWDqRJetqlQnAeMlDIc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329803; c=relaxed/simple;
	bh=kBJb4zGK0nPUffVexJwb3ldg7HHdnjuLf1YQ4z5I704=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=mWw7MP2tmM3MXrQJ6cpjHd682AInXNta9V8BMUJrfQFVXHwl0/zn4YQihtiXRcJ1JNcvN69rEFx+Dw5Puyzm17MmoULjFmppAjF5EHTKmYQ9IwmvEJBbJl1XVrAClw1/MayGqHpgZdTwY+Uk25R4umTuBJan2s8T535CCaOurgM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=Vx2v21lw; arc=none smtp.client-ip=209.85.167.179
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Vx2v21lw"
Received: by mail-oi1-f179.google.com with SMTP id 5614622812f47-4b21f09ea42so982104b6e.2
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:30:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329801; x=1787934601; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6Sme0Lo03AqmzFHxAPmKw+gzCYusmRrDjEVVsEWyJgQ=;
        b=Vx2v21lwtkf5JgOtj9/xcRBk/apukuWWopGyHdeYw7oj8+mcz0/eJU3i9X5d2Ab6tW
         PfWebUP/wcVwsmI19imEEcg7Lao6ZjHYb9L7BF2D1mOV9P/TK+AxSgUy/9U47H4qFLTt
         iY201bnL1J+4eYx+YkFJMEJ2BJU8DZJk58UQy7txwfqUJbqXC+Yrr3eO2QxUVghcKwuu
         omxbyMz0k1ltjpET9Em7SpMMY5PIT8wHAYBfuoz6L34yYNA7VZQ+Qc8+85N2JTqo2Yil
         vyLdf1mqyz0Ltkkjew3jwIu4rOVihvmmCANylIftoA65BWqEhyJ9drJS/SOvho0wuUco
         ring==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329801; x=1787934601;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=6Sme0Lo03AqmzFHxAPmKw+gzCYusmRrDjEVVsEWyJgQ=;
        b=WHlnJKFMUuGWBsDl3U/BRHFze9w0qH33TBGr4UgfVP8OQWUB2CH6Jb6RxAN36loSuy
         +1kyXqXUdZ/8Gdz0SfScfZd+y8B8Zv4SqNvgT9Va71s7W3+tKFwZnD7XZIrXPxmC7yGr
         HRhSmhjg8RyWl708U/o/i/2xe4XwnGh2ljjZsO1TCLbTtBlj5JL5nTwa8FXEYfkkt34c
         7N4cjXwEMWNEXE3FVVX7sbbqF0OZwDbCFXvfNH+tLUbShBEqL1Nx5z1mbAkr2se/8lw8
         NBCDKd9O2GWSKf0CtzzVFdq2Zyd+98qGXeNGVqKCZNOUxCgzOaKjurPz+HBL3Yq+v1B5
         zydg==
X-Gm-Message-State: AOJu0YyARNi2goGL3JNCQqP5Ok3rh+Z6DK0gYWLK5TqlpXyp87OpjK2r
	Z00+kqWsB5oNfLt+Tzw/4nXdbh3RlxN0oGcIHcE0sX8bXpo5OPNDXh6194n8+A0lLpA=
X-Gm-Gg: AR+sD12RLc0+AX43g9Kr2M+61DIQGVjjpwY62ul3fb6Qg5Qt/ltYzPBJ3//x9P3FQcg
	jQG7aXRg/hyrbeq8+IIWnp5JOWwW/+JFqaqa2ZIAr1DJSdAKMjbmO9t7+lhxVWjrF9aBGkrBFsT
	ZMcl2Ajyk91ToanSm1kl0MsA6rwXqeCO8dp5LFYfxOhXMIvIEneyUddmk8pxT8ZNTFcjgCF9z2V
	U0xSgS0hlJk/1GerahSUNz+4XSv7lIGG+oZ+btHbqJWTB48T75ImmQyZHSplkTmvCNocKofVX9g
	KVR/Nj3o6n2Emxj6Yh42ltsQFT3FJThMfBSYnDLy/axEymhEnNP4SUS8iPt9jMoXm2tlDz9kyis
	7eTAoQex6C4j6avODsheFHzdx31f2zLz1PBjExU+nNb/yrXqvkkjvzzXLQbM3ojTy5TH7n59La7
	obfBKPyokCrGNder1IjgdPJ6u0Tldl4z1+nO9QTAzpARTsgDE9uHdVpl2bPguYKpFFYH0TJQzID
	Mu92NznaWwgztxtGXXB4BmU
X-Received: by 2002:a05:6808:c29a:b0:4a4:9e18:607a with SMTP id 5614622812f47-4b2ef4375b1mr8104615b6e.21.1787329799229;
        Fri, 21 Aug 2026 09:29:59 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:58 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 23/23] NFSv4/flexfiles: Add a dataserver_nconnect cap
Date: Fri, 21 Aug 2026 12:29:27 -0400
Message-ID: <32737bce921421c96015d788e93734b240a3a4d0.1787327939.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787327939.git.bcodding@hammerspace.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Data-server clients inherit the MDS nconnect setting.  A striping
mount multiplies that by every distinct data server: at the
anticipated scale of 1024 and nconnect=16 the client opens 16k
sockets plus their sunrpc slot tables, and striping already spreads
I/O across the data servers, so a high per-DS transport count buys
little for that workload.

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
index f0254ee6a9a8..b5f7fc0ac2a3 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -20,6 +20,7 @@
 
 static unsigned int dataserver_timeo = NFS_DEF_TCP_TIMEO;
 static unsigned int dataserver_retrans;
+static unsigned int dataserver_nconnect;
 
 static bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg);
 
@@ -430,6 +431,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 	 */
 	status = nfs4_pnfs_ds_connect(s, ds, &mirror_ds->id_node,
 			     dataserver_timeo, dataserver_retrans,
+			     dataserver_nconnect,
 			     mirror_ds->ds_versions[0].version,
 			     mirror_ds->ds_versions[0].minor_version);
 
@@ -687,3 +689,8 @@ module_param(dataserver_timeo, uint, 0644);
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
index 1ddd4610ae47..ff783a3a27bd 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -503,7 +503,8 @@ struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(const struct net *net,
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
index dbfb9da9d0f5..07f98957c96f 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -835,7 +835,8 @@ static struct nfs_client *(*get_v3_ds_connect)(
 			int ds_addrlen,
 			int ds_proto,
 			unsigned int ds_timeo,
-			unsigned int ds_retrans);
+			unsigned int ds_retrans,
+			unsigned int ds_nconnect);
 
 static bool load_v3_ds_connect(void)
 {
@@ -858,7 +859,8 @@ void nfs4_pnfs_v3_ds_connect_unload(void)
 static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
 				 unsigned int timeo,
-				 unsigned int retrans)
+				 unsigned int retrans,
+				 unsigned int nconnect)
 {
 	struct nfs_client *clp = ERR_PTR(-EIO);
 	struct nfs_client *mds_clp = mds_srv->nfs_client;
@@ -910,7 +912,7 @@ static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 			ds_proto = XPRT_TRANSPORT_TCP_TLS;
 
 		clp = get_v3_ds_connect(mds_srv, &da->da_addr, da->da_addrlen,
-					ds_proto, timeo, retrans);
+					ds_proto, timeo, retrans, nconnect);
 		if (IS_ERR(clp))
 			continue;
 		clp->cl_rpcclient->cl_softerr = 0;
@@ -933,6 +935,7 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
 				 unsigned int timeo,
 				 unsigned int retrans,
+				 unsigned int nconnect,
 				 u32 minor_version)
 {
 	struct nfs_client *clp = ERR_PTR(-EIO);
@@ -1023,7 +1026,8 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 
 			clp = nfs4_set_ds_client(mds_srv, &da->da_addr,
 						 da->da_addrlen, ds_proto,
-						 timeo, retrans, minor_version);
+						 timeo, retrans, nconnect,
+						 minor_version);
 			if (IS_ERR(clp))
 				continue;
 
@@ -1056,7 +1060,8 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
  */
 int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
-			  unsigned int retrans, u32 version, u32 minor_version)
+			  unsigned int retrans, unsigned int nconnect,
+			  u32 version, u32 minor_version)
 {
 	int err;
 
@@ -1075,11 +1080,12 @@ int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 
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

