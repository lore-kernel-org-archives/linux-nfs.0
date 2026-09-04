Received: from mail-qv1-f51.google.com (mail-qv1-f51.google.com [209.85.219.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4A5850C2B7
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540828; cv=none; b=oWfvpez/3sduf2Ibowd6utOCcRkU47z52TYxKY32e3dHfMRbFGzfQPFwQryAhoUR4bfETUAkH5DjAR/K4Syojk7ajN6iwFnOzU4kYg9DkrwNH4PwODmq1vRTTC6YqzSppMuvplQNI4W/frt2WwHS1CP+GRK/SF0PL335JBu8FTk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540828; c=relaxed/simple;
	bh=zpuWsi6PdIsiYk944ZULr2yruM3l58CchMh9COalT20=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=EKuUG25uXWk1mbhca/C1/kEG2kAxngSqfByh0zfz0V1D1TTlr3PmXPas5LJUefD+O8tJjYFEQbOmwf4ilSP5soKV9wFHMSLu+nYNxoCHiE30g98t4wE7JaULnONyQDy2bfXQ6pXcqiYUHNdWzYzfkr1osHBDv4QlPlKQ6Advvdo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=YKIPK3Aw; arc=none smtp.client-ip=209.85.219.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="YKIPK3Aw"
Received: by mail-qv1-f51.google.com with SMTP id 6a1803df08f44-91041ee9230so10479066d6.2
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540826; x=1789145626; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=rJ0+oPOLTVa8t9ZHme2u/Xf4Q6Cr/mHIPWqXq/z/8eQ=;
        b=YKIPK3Aw3mAA/CccM5VoVNs9SlcoDs5S5L346fJvgOnTscp1MNF7AEIepH/SLqZcBL
         fZxFlXsXIRVWt3ulFDMmhuKvjmrcXN8UQqj5MY5nRrc7yq76GN6THkMNVYKsyZpgkRsN
         d4k6+V2lLchMKCWhYQW9DDIDld3BhBB1rrA2h59RU3e6LSOF/vJ/uWkUVhu98x3G7F0T
         HEphDjhP8ghXpd2fgs4N+H2kjhlDxBSQad14py+/l5P1rSat2uPGSothljm5Y/gdQpJ1
         UUTvwDInDsHlgfCJAuCt8IC6Fn8vbc6c1t476djI48o1ivanKqoWpQmNL6ECRcQATyXy
         KhWA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540826; x=1789145626;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=rJ0+oPOLTVa8t9ZHme2u/Xf4Q6Cr/mHIPWqXq/z/8eQ=;
        b=OR+OQEAYhtDKNiNCLlHG8cHKSSRR4YX4iYOlHVCZW+qMnZr0kOHcja9mcRF9fxyCyC
         W+i5MYEvftgPTx6jIyb82mGuLl1Qpq0cSqZrnmYsAiChM7veAKufcrWVTWiUfedWYtio
         xMgXgVN/M+34b8FEPpA+ZsmnYJwvyGpr/GqCHHtcd0mISJ7CNqxxH4orr1A3mdwP2UTD
         ugky6ZiXKyONW4VxtptEpk2dJMPFq++KE91+G1zXSKQxxyPXJyHm/NWReOWXT/O+jnzJ
         6iZufADlfE/8nDjPHc3IoiDdzAqHWepYHuL+hEAYmiMBzaQJGpZoVE+1fg2+AlhDo0Mh
         3OnQ==
X-Gm-Message-State: AFuF++md6EFyexQk9M+i9DH8bKfLt1vGzUJ+jeIzzqGkFD6nGzfJLGh1
	jw4qj9aX1BJRJZ2bN39BoLPDdlTShXhigkjcuZpO6XUlcCFoIWW3uRAqYtJFRlCLSj8=
X-Gm-Gg: AYBFou2lOuuIUoCbAsC5E509MSVkkIaZnM2PV1ZUPAEDWc3TbFSsW+PzJtpihSmA21Y
	lsYLLvAq9hvxXuU0QCrFdBW2XnPa57noxhR1hOMUza7FpTpvMhy7+A2+oP5CbAUkyC2aZXaNQJH
	QYxe7TYiDFuXwSVE6VbA55LfugPyrFu4fa0Gm2CFdnpBlDvSpv/5b1BkYM4oM64b3Fs8ggCZTBI
	zsNUhhsorQCIwMZyGocMysv2ptx7ISfnjkVZXHr6xFC2cxSbww1hpShb945NE1WUYWMu5uwvnhV
	oLWj5VJmPr3a0jmB4kBtKRkYV/+Tj+MUkt6TdORslZsWDk6770AvYJs1ZJurYZ8hq6W4o5o2aO8
	RSzL6jEntt5CItYOaCbRYKDT25fX4K6s7dROHhoUGkOBl/YUeW5UcM0eRI9PJP188iW7Fii91Gj
	Sv7G/izdTVI+ZGRD1CG22f/bp1Vee2qsc29/rYPBi0HyjElOq+Hw/VXuBOSKERgj5WEpf5zy0FW
	Wlefsf1NM2g6bxURhrA2RxF
X-Received: by 2002:a05:620a:454d:b0:939:5c62:fddd with SMTP id af79cd13be357-9398033d274mr636955085a.19.1788540825669;
        Fri, 04 Sep 2026 09:53:45 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:45 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 24/24] NFSv4/flexfiles: Add a dataserver_nconnect cap
Date: Fri,  4 Sep 2026 12:53:23 -0400
Message-ID: <eb088e5acf06883c2ac21418c39143905b2c2dec.1788530385.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788530385.git.bcodding@hammerspace.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
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
 fs/nfs/nfs4client.c                       |  6 +++++-
 fs/nfs/pnfs.h                             |  3 ++-
 fs/nfs/pnfs_nfs.c                         | 21 ++++++++++++++-------
 7 files changed, 38 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 57e0654cd98c..5995f32f07ec 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -267,7 +267,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 		goto out_test_devid;
 
 	status = nfs4_pnfs_ds_connect(s, ds, devid, dataserver_timeo,
-			     dataserver_retrans, 4,
+			     dataserver_retrans, 0, 4,
 			     s->nfs_client->cl_minorversion, true);
 	if (status) {
 		nfs4_mark_deviceid_unavailable(devid);
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 5cb09e5e2138..d52f485d0650 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -20,6 +20,7 @@
 
 static unsigned int dataserver_timeo = NFS_DEF_TCP_TIMEO;
 static unsigned int dataserver_retrans;
+static unsigned int dataserver_nconnect;
 
 static bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg);
 
@@ -418,6 +419,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 	 */
 	status = nfs4_pnfs_ds_connect(s, ds, &mirror_ds->id_node,
 			     dataserver_timeo, dataserver_retrans,
+			     dataserver_nconnect,
 			     mirror_ds->ds_versions[0].version,
 			     mirror_ds->ds_versions[0].minor_version,
 			     mirror_ds->ds_versions[0].tightly_coupled);
@@ -676,3 +678,8 @@ module_param(dataserver_timeo, uint, 0644);
 MODULE_PARM_DESC(dataserver_timeo, "The time (in tenths of a second) the "
 			"NFSv4.1  client  waits for a response from a "
 			" data server before it retries an NFS request.");
+module_param(dataserver_nconnect, uint, 0644);
+MODULE_PARM_DESC(dataserver_nconnect, "The maximum number of connections "
+			"the NFSv4.1 client opens to each data server, "
+			"capping the value inherited from the MDS nconnect "
+			"mount option.  0 (default) applies no cap.");
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index abc81f5ae578..48f7c0e25da1 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -251,6 +251,7 @@ extern struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 					     int ds_addrlen, int ds_proto,
 					     unsigned int ds_timeo,
 					     unsigned int ds_retrans,
+					     unsigned int ds_nconnect,
 					     u32 minor_version,
 					     bool tightly_coupled);
 extern struct rpc_clnt *nfs4_find_or_create_ds_client(struct nfs_client *,
@@ -260,7 +261,7 @@ extern void nfs4_session_limit_xasize(struct nfs_server *server);
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
index e6a589913666..fe779fb2ec72 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -794,7 +794,8 @@ static int nfs4_set_client(struct nfs_server *server,
 struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 		const struct sockaddr_storage *ds_addr, int ds_addrlen,
 		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
-		u32 minor_version, bool tightly_coupled)
+		unsigned int ds_nconnect, u32 minor_version,
+		bool tightly_coupled)
 {
 	struct rpc_timeout ds_timeout;
 	struct nfs_client *mds_clp = mds_srv->nfs_client;
@@ -832,6 +833,9 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
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
index 8b612f3679a3..719657f3f4e1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -504,7 +504,8 @@ struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(const struct net *net,
 void nfs4_pnfs_v3_ds_connect_unload(void);
 int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
-			  unsigned int retrans, u32 version, u32 minor_version,
+			  unsigned int retrans, unsigned int nconnect,
+			  u32 version, u32 minor_version,
 			  bool tightly_coupled);
 struct nfs4_pnfs_ds_addr *nfs4_decode_mp_ds_addr(struct net *net,
 						 struct xdr_stream *xdr,
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index c9bbcb765f4a..7adb6f941cf2 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -844,7 +844,8 @@ static struct nfs_client *(*get_v3_ds_connect)(
 			int ds_addrlen,
 			int ds_proto,
 			unsigned int ds_timeo,
-			unsigned int ds_retrans);
+			unsigned int ds_retrans,
+			unsigned int ds_nconnect);
 
 static bool load_v3_ds_connect(void)
 {
@@ -867,7 +868,8 @@ void nfs4_pnfs_v3_ds_connect_unload(void)
 static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
 				 unsigned int timeo,
-				 unsigned int retrans)
+				 unsigned int retrans,
+				 unsigned int nconnect)
 {
 	struct nfs_client *clp = ERR_PTR(-EIO);
 	struct nfs_client *mds_clp = mds_srv->nfs_client;
@@ -919,7 +921,7 @@ static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 			ds_proto = XPRT_TRANSPORT_TCP_TLS;
 
 		clp = get_v3_ds_connect(mds_srv, &da->da_addr, da->da_addrlen,
-					ds_proto, timeo, retrans);
+					ds_proto, timeo, retrans, nconnect);
 		if (IS_ERR(clp))
 			continue;
 		clp->cl_rpcclient->cl_softerr = 0;
@@ -942,6 +944,7 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 				 struct nfs4_pnfs_ds *ds,
 				 unsigned int timeo,
 				 unsigned int retrans,
+				 unsigned int nconnect,
 				 u32 minor_version,
 				 bool tightly_coupled)
 {
@@ -1033,7 +1036,8 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 
 			clp = nfs4_set_ds_client(mds_srv, &da->da_addr,
 						 da->da_addrlen, ds_proto,
-						 timeo, retrans, minor_version,
+						 timeo, retrans, nconnect,
+						 minor_version,
 						 tightly_coupled);
 			if (IS_ERR(clp))
 				continue;
@@ -1068,7 +1072,8 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
  */
 int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
-			  unsigned int retrans, u32 version, u32 minor_version,
+			  unsigned int retrans, unsigned int nconnect,
+			  u32 version, u32 minor_version,
 			  bool tightly_coupled)
 {
 	int err;
@@ -1088,11 +1093,13 @@ int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
 
 	switch (version) {
 	case 3:
-		err = _nfs4_pnfs_v3_ds_connect(mds_srv, ds, timeo, retrans);
+		err = _nfs4_pnfs_v3_ds_connect(mds_srv, ds, timeo, retrans,
+					       nconnect);
 		break;
 	case 4:
 		err = _nfs4_pnfs_v4_ds_connect(mds_srv, ds, timeo, retrans,
-					       minor_version, tightly_coupled);
+					       nconnect, minor_version,
+					       tightly_coupled);
 		break;
 	default:
 		dprintk("%s: unsupported DS version %d\n", __func__, version);
-- 
2.53.0

