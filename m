Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC4A83BB69F
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:23:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474982; cv=none; b=Ga+771YvevvfKnUMxwJy5kwmU8GStO6V6gKH6OwYrHi3skan8EfdQzwJEDeA2N8ZOboNIgdNjlcSd1aYTaPoVwGxeiWKv5Sas2rxGTp5RBE+wwUPZ7sQIOCXF2I6ODetpKoU6doJJHNTIGctKIjglkZXQVl5wp3vIv90+vI3HuU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474982; c=relaxed/simple;
	bh=2J7MUY4/hzAHfzwdJcLP5Fs/ndxWMPATRwZPrMhB5sA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=D6w95hdW/115dc3wqkx6wcWkPXaWgJ7v8AykPSsNzUPXnsx25pe8ydl37i9acdmyza9oCPYFPxD6SXG1XCmGVoNrK+3hTmVOHMN6i5YlRO2+yWDRLWcI/46CDYrTHmtqYw+tCoBeJLw/yv+hi3jir2qofWBQVyi2tzVNjwru3/0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=Gc8TG/GM; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Gc8TG/GM"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4b37dcfe9b2so1585974b6e.2
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:23:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474979; x=1790079779; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=253fxZQrJzL5zMKkSAHeVCnWoAvPnADIh2Yl5y2oqhE=;
        b=Gc8TG/GM/hoKCQU3R13Kh7bqTZz+amOq3sGJJeYChJZiq1ADcnqY+dQ21x6vTtcrhI
         3NZns/weOTAgGurObJRfxs9JhqDgUTn9+R05u7OSStO1y+BmArrQu5qdZkzBnu6EiL1e
         ov/FmWlCshC6Que7aBQKywoF1HywCeGYsg6vIklewS62YpC/XhXzEaq47fGrvPgVZ8+U
         hRE8Na19lmR3RrxfTHOd4/9/W+RIxvuyDPu3F7oOdWlzKZxVZgFwSy8z+4f27JJK9eSw
         MaZhwCjRvfnV2n7V5qL+X5KM87toltvygCUN2v9dTAFADIB2iPxtWBtdGJMAU8Gq3eLE
         SGEA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474979; x=1790079779;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=253fxZQrJzL5zMKkSAHeVCnWoAvPnADIh2Yl5y2oqhE=;
        b=Y8umNn31exRBnfS14VWGsLl+9pgBIQAP0NM6RjBa/fM4F+3O8dbcf2cEdUHrJOUxwS
         9snX0K+n0mxUHhVPwqumYg3k1dXDDAajnRJfoRlwTy3eEIm5Zz2/C9fneQwOtdxGYlTy
         TO/TnIQevmda1+lYhA3l0YjfB+dpGHECcaB/bPsxsU389ruRuQSxX3iAyiPftDCn/N45
         QyAAVa+wU9b/hBU374lyUQLrX5GUrEhntzXXezMz8D2P74Q1A7tfN9ol5OvWUxS9Ra4G
         RpMAR6UFU1qM+NR/rb34m7rdxrUB8EVYCf1A7YJqbS2Y5L0h2NO/LVUqAYVGM+qIau4F
         jwUA==
X-Gm-Message-State: AFuF++mbEy91lNJT7KkbzYiYecC+EEtOJV5Wxpm6/W6rUqg+LiVIX30H
	GrXoe2GKoP1chik+CRQTJM4mqE7elHwGbrJfeYCRODPmHI+QbMxbaT3eOfWE5tgaKeg=
X-Gm-Gg: AYBFou338TjfecOhpD6fTKNwRCCo7euFo1JzgdBhxPNa0sWztJexvvOyjacMipUtUHr
	rIV3Broc33z3rWRSn82O3WiH/gSumLfYBKkWzmRJoSpaOX1S2aQA5QWUUmc2Y9gVkH5cZBpzzed
	Q3BXum/TFz0VDVc0413A0gsqmwVNSdSOfKCyDnePQoVZNtat02MMPOBbDtOF0UpNo8bsIGlCYnD
	UxhRu0jw+LvzHRzduPmjQGEianelftWpzFIQg0mXVaYYA/ZuelOM8vz1+YN1hI+Fj7ksNWAkAbu
	CEvTNlcyZPwYBdTUr0TZa4/9g2zPF7dBIJVqEI+qG2jaCMsKHONsiFo5xQCeeNVT/wvI6Ti20BL
	JoISVOKDJgIz/iZYmBx5qYoXezNel2uDNedVuVYXwrJCia1cX/GuO717oPgLlP6DYyQn79EUTon
	tUy1AW82rDWDFu9fI4Ih2fgq/+UACiKn40bd80OrPhF5usqvk50zW0kR2Urq3TZZZ7n+jvXL4ek
	q9uhWKJzcX5XEWyCh1n72J2E4brbhvBJ8s=
X-Received: by 2002:a05:6808:f94:b0:4c1:2b62:35a4 with SMTP id 5614622812f47-4c7b36da270mr7548230b6e.5.1789474979394;
        Tue, 15 Sep 2026 05:22:59 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:58 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 24/24] NFSv4/flexfiles: Add a dataserver_nconnect cap
Date: Tue, 15 Sep 2026 08:22:26 -0400
Message-ID: <53c45be8b220b23b496d5ffcd942e94e59629f35.1789474702.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789474702.git.bcodding@hammerspace.com>
References: <cover.1789474702.git.bcodding@hammerspace.com>
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
index 3a1c012ba18e..5cde5db63d29 100644
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

